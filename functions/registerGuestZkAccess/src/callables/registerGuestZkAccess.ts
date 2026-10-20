import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  createZkBioClient,
  getResident,
  requireApprovedResident,
  requireAuthUid,
} from "../utils/firestore";
import { registerGuestInZkBio } from "../services/registerGuest";

export const registerGuestZkAccess = onCall(async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const visitorId = request.data?.visitorId as string | undefined;
  if (!visitorId) {
    throw new HttpsError("invalid-argument", "visitorId is required");
  }

  const resident = await getResident(uid);
  requireApprovedResident(resident);
  if (!resident.societyID) {
    throw new HttpsError("failed-precondition", "Resident has no society");
  }

  const client = await createZkBioClient(resident.societyID);
  try {
    return await registerGuestInZkBio(uid, visitorId, client, resident.societyID);
  } catch (e) {
    const message = e instanceof Error ? e.message : "Failed to register guest";
    throw new HttpsError("internal", message);
  }
});
