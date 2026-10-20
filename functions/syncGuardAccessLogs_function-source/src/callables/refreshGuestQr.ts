import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  createZkBioClient,
  getResident,
  requireApprovedResident,
  requireAuthUid,
} from "../utils/firestore";
import { refreshGuestQrInZkBio } from "../services/registerGuest";

export const refreshGuestQr = onCall(async (request) => {
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
    return await refreshGuestQrInZkBio(uid, visitorId, client);
  } catch (e) {
    const message = e instanceof Error ? e.message : "Failed to refresh guest QR";
    throw new HttpsError("internal", message);
  }
});
