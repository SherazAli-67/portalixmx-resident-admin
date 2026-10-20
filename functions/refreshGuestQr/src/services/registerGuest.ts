import * as admin from "firebase-admin";
import { formatDateTime, ZkBioClient } from "../zkbio/zkbioClient";
import {
  db,
  getResident,
  getSocietyConfig,
  RESIDENTS_COL,
  VISITORS_SUB,
  visLevelsString,
} from "../utils/firestore";
import { RegisterGuestResult, VisitorDoc } from "../zkbio/types";

async function resolveVisitorPin(
  client: ZkBioClient,
  certNum: string,
  phone?: string
): Promise<string> {
  try {
    await client.getVisitorQrByCert(certNum, phone);
  } catch {
    // cert lookup may fail before pin is indexed; fall through
  }
  // ZKBio assigns visitor pins starting around 800000001; after registration
  // getQrCodeByCert works. For pin storage we use cert-based refresh when pin unknown.
  return certNum;
}

export async function registerGuestInZkBio(
  uid: string,
  visitorId: string,
  client: ZkBioClient,
  societyId: string
): Promise<RegisterGuestResult> {
  const resident = await getResident(uid);
  if (!resident.zkPin) {
    throw new Error("Host resident is not provisioned in ZKBio");
  }
  if (!resident.societyID) {
    throw new Error("Resident has no society");
  }

  const visitorRef = db
    .collection(RESIDENTS_COL)
    .doc(uid)
    .collection(VISITORS_SUB)
    .doc(visitorId);
  const visitorSnap = await visitorRef.get();
  if (!visitorSnap.exists) {
    throw new Error("Visitor not found");
  }
  const visitor = visitorSnap.data() as VisitorDoc;
  if (visitor.visitorType !== "guest") {
    throw new Error("Only guest visitors support ZKBio QR access");
  }
  if (visitor.zkCheckedOutAt) {
    throw new Error("Visitor visit has already ended");
  }

  const society = await getSocietyConfig(societyId);
  const certNum = visitor.zkCertNum ?? `VIS-${visitorId}`;
  const startTime = visitor.fromDateTime?.toDate() ?? new Date();
  const endTime = visitor.toDateTime?.toDate() ?? new Date(Date.now() + 86400000);
  const visLevels = visLevelsString(society.defaultVisLevelIds);

  if (!visitor.zkRegisteredAt) {
    await client.addVisitorRegistration({
      persPersonPin: resident.zkPin,
      certNum,
      visitEmpName: visitor.name ?? "Guest",
      visitEmpPhone: visitor.contact,
      visitReason: "Guest visit",
      visitorCount: "1",
      startTime: formatDateTime(startTime),
      endTime: formatDateTime(endTime),
      visLevels,
    });
  }

  let zkVisEmpPin = visitor.zkVisEmpPin ?? certNum;
  let qrPayload: string;

  try {
    if (visitor.zkVisEmpPin) {
      qrPayload = await client.getVisitorQr(visitor.zkVisEmpPin);
    } else {
      qrPayload = await client.getVisitorQrByCert(certNum, visitor.contact);
    }
  } catch {
    qrPayload = await client.getVisitorQrByCert(certNum, visitor.contact);
    zkVisEmpPin = await resolveVisitorPin(client, certNum, visitor.contact);
  }

  const fetchedAt = new Date().toISOString();
  await visitorRef.set(
    {
      zkCertNum: certNum,
      zkVisEmpPin,
      zkRegisteredAt: visitor.zkRegisteredAt ?? admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return { qrPayload, fetchedAt, zkVisEmpPin, zkCertNum: certNum };
}

export async function refreshGuestQrInZkBio(
  uid: string,
  visitorId: string,
  client: ZkBioClient
): Promise<{ qrPayload: string; fetchedAt: string }> {
  const visitorRef = db
    .collection(RESIDENTS_COL)
    .doc(uid)
    .collection(VISITORS_SUB)
    .doc(visitorId);
  const visitorSnap = await visitorRef.get();
  if (!visitorSnap.exists) {
    throw new Error("Visitor not found");
  }
  const visitor = visitorSnap.data() as VisitorDoc;
  if (!visitor.zkRegisteredAt) {
    throw new Error("Visitor is not registered in ZKBio");
  }

  const certNum = visitor.zkCertNum ?? `VIS-${visitorId}`;
  let qrPayload: string;
  if (visitor.zkVisEmpPin && !visitor.zkVisEmpPin.startsWith("VIS-")) {
    qrPayload = await client.getVisitorQr(visitor.zkVisEmpPin);
  } else {
    qrPayload = await client.getVisitorQrByCert(certNum, visitor.contact);
  }

  return { qrPayload, fetchedAt: new Date().toISOString() };
}

export async function checkoutGuestInZkBio(
  uid: string,
  visitorId: string,
  client: ZkBioClient
): Promise<void> {
  const visitorRef = db
    .collection(RESIDENTS_COL)
    .doc(uid)
    .collection(VISITORS_SUB)
    .doc(visitorId);
  const visitorSnap = await visitorRef.get();
  if (!visitorSnap.exists) return;
  const visitor = visitorSnap.data() as VisitorDoc;
  const certNum = visitor.zkCertNum ?? `VIS-${visitorId}`;

  if (visitor.zkRegisteredAt && !visitor.zkCheckedOutAt) {
    try {
      await client.checkoutVisitor(certNum);
    } catch {
      // best-effort checkout
    }
    await visitorRef.set(
      { zkCheckedOutAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );
  }
}
