import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/v2/https";
import { ZkBioClient } from "../zkbio/zkbioClient";
import { ResidentDoc, SocietyZkBioDoc } from "../zkbio/types";

if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();

const RESIDENTS_COL = "residents";
const SOCIETIES_COL = "societies";
const VISITORS_SUB = "visitors";
const ACCESS_REQUESTS_COL = "access_requests";
const GUARD_LOGS_SUB = "guard_logs";

export { RESIDENTS_COL, SOCIETIES_COL, VISITORS_SUB, ACCESS_REQUESTS_COL, GUARD_LOGS_SUB };

export async function getSocietyConfig(societyId: string): Promise<SocietyZkBioDoc> {
  const doc = await db.collection(SOCIETIES_COL).doc(societyId).get();
  if (!doc.exists) {
    throw new HttpsError("not-found", `Society ${societyId} not found`);
  }
  return doc.data() as SocietyZkBioDoc;
}

export function getZkBioToken(societyId: string): string {
  const envKey = `ZKBIO_TOKEN_${societyId}`;
  const token = process.env[envKey] ?? process.env.ZKBIO_ACCESS_TOKEN;
  if (!token) {
    throw new HttpsError(
      "failed-precondition",
      `ZKBio access token not configured for society ${societyId}`
    );
  }
  return token;
}

export async function createZkBioClient(societyId: string): Promise<ZkBioClient> {
  const society = await getSocietyConfig(societyId);
  if (!society.zkbioEnabled) {
    throw new HttpsError("failed-precondition", "ZKBio is not enabled for this society");
  }
  if (!society.zkbioServerUrl || !society.zkbioServerPort) {
    throw new HttpsError("failed-precondition", "ZKBio server URL/port not configured");
  }
  const accessToken = getZkBioToken(societyId);
  return new ZkBioClient({
    serverUrl: society.zkbioServerUrl,
    serverPort: society.zkbioServerPort,
    accessToken,
  });
}

export async function getResident(uid: string): Promise<ResidentDoc> {
  const doc = await db.collection(RESIDENTS_COL).doc(uid).get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Resident not found");
  }
  return doc.data() as ResidentDoc;
}

export function requireAuthUid(authUid: string | undefined): string {
  if (!authUid) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }
  return authUid;
}

export function requireApprovedResident(resident: ResidentDoc): void {
  if (resident.status !== 1) {
    throw new HttpsError(
      "permission-denied",
      "Account must be approved before accessing ZKBio credentials"
    );
  }
}

export function requireZkPin(resident: ResidentDoc): string {
  if (!resident.zkPin) {
    throw new HttpsError(
      "failed-precondition",
      "Resident is not provisioned in ZKBio. Contact your society admin."
    );
  }
  return resident.zkPin;
}

export function visLevelsString(levels?: string[]): string {
  return (levels ?? []).join(",");
}
