import * as admin from "firebase-admin";
import { formatDateTime, ZkBioClient } from "../zkbio/zkbioClient";
import {
  db,
  getSocietyConfig,
  RESIDENTS_COL,
} from "../utils/firestore";
import { ResidentDoc } from "../zkbio/types";

export async function provisionResidentInZkBio(
  uid: string,
  client: ZkBioClient,
  resident: ResidentDoc,
  societyId: string
): Promise<string> {
  const society = await getSocietyConfig(societyId);
  const zkPin = resident.zkPin ?? `R-${uid.substring(0, 8).toUpperCase()}`;
  const accLevelIds = resident.zkAccLevelIds ?? society.defaultAccLevelIds ?? [];

  await client.addPerson({
    pin: zkPin,
    name: resident.userName ?? "Resident",
    accLevelIds,
  });

  if (accLevelIds.length > 0) {
    await client.syncPersonLevel(zkPin, accLevelIds);
  }

  await db.collection(RESIDENTS_COL).doc(uid).set(
    {
      zkPin,
      zkAccLevelIds: accLevelIds,
      zkProvisionedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return zkPin;
}

export async function revokeResidentInZkBio(
  zkPin: string,
  client: ZkBioClient,
  uid: string
): Promise<void> {
  await client.personLeave(zkPin);
  await db.collection(RESIDENTS_COL).doc(uid).set(
    {
      zkPin: admin.firestore.FieldValue.delete(),
      zkProvisionedAt: admin.firestore.FieldValue.delete(),
    },
    { merge: true }
  );
}

export function toZkDateTime(date: Date): string {
  return formatDateTime(date);
}
