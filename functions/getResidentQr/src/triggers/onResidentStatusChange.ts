import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import {
  createZkBioClient,
  RESIDENTS_COL,
} from "../utils/firestore";
import {
  provisionResidentInZkBio,
  revokeResidentInZkBio,
} from "../services/provisionResident";
import { ResidentDoc } from "../zkbio/types";

export const onResidentStatusChange = onDocumentUpdated(
  `${RESIDENTS_COL}/{uid}`,
  async (event) => {
    const before = event.data?.before.data() as ResidentDoc | undefined;
    const after = event.data?.after.data() as ResidentDoc | undefined;
    const uid = event.params.uid;

    if (!before || !after || before.status === after.status) return;
    if (!after.societyID) return;

    let client;
    try {
      client = await createZkBioClient(after.societyID);
    } catch {
      return;
    }

    if (after.status === 1 && before.status !== 1) {
      try {
        await provisionResidentInZkBio(uid, client, after, after.societyID);
      } catch (e) {
        console.error("Failed to provision resident in ZKBio:", e);
      }
    }

    if (after.status !== 1 && before.status === 1 && before.zkPin) {
      try {
        await revokeResidentInZkBio(before.zkPin, client, uid);
      } catch (e) {
        console.error("Failed to revoke resident in ZKBio:", e);
      }
    }
  }
);
