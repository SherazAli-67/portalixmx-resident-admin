import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  createZkBioClient,
  getResident,
  requireApprovedResident,
  requireAuthUid,
  requireZkPin,
} from "../utils/firestore";

export const getResidentQr = onCall(async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const resident = await getResident(uid);
  requireApprovedResident(resident);
  const zkPin = requireZkPin(resident);
  if (!resident.societyID) {
    throw new HttpsError("failed-precondition", "Resident has no society");
  }

  const client = await createZkBioClient(resident.societyID);
  const qrPayload = await client.getPersonQr(zkPin);
  return { qrPayload, fetchedAt: new Date().toISOString() };
});
