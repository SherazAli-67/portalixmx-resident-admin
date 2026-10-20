import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { formatDateTime } from "../zkbio/zkbioClient";
import {
  ACCESS_REQUESTS_COL,
  createZkBioClient,
  db,
  getResident,
  getSocietyConfig,
  RESIDENTS_COL,
} from "../utils/firestore";
import { AccessRequestDoc } from "../zkbio/types";

export const onAccessRequestApproved = onDocumentUpdated(
  `${ACCESS_REQUESTS_COL}/{requestId}`,
  async (event) => {
    const before = event.data?.before.data() as AccessRequestDoc | undefined;
    const after = event.data?.after.data() as AccessRequestDoc | undefined;

    if (!before || !after) return;
    if (before.status === after.status) return;
    if (after.status !== "approved") return;
    if (!after.requestByUID || !after.societyID) return;

    const society = await getSocietyConfig(after.societyID);
    const amenityMap = society.amenityAccLevelMap ?? {};
    const amenityLevelId = amenityMap[after.requestedAccessTitle ?? ""];
    if (!amenityLevelId) return;

    let client;
    try {
      client = await createZkBioClient(after.societyID);
    } catch {
      return;
    }

    const resident = await getResident(after.requestByUID);
    if (!resident.zkPin || resident.status !== 1) return;

    const requestedDate = after.requestedForDate
      ? new Date(after.requestedForDate)
      : new Date();
    const timeParts = (after.requestedForTime ?? "00:00").split(":");
    requestedDate.setHours(parseInt(timeParts[0], 10), parseInt(timeParts[1], 10), 0, 0);
    const accEnd = new Date(requestedDate.getTime() + 4 * 60 * 60 * 1000);

    const existingLevels = resident.zkAccLevelIds ?? society.defaultAccLevelIds ?? [];
    const mergedLevels = Array.from(new Set([...existingLevels, amenityLevelId]));

    await client.addPerson({
      pin: resident.zkPin,
      name: resident.userName ?? "Resident",
      accLevelIds: mergedLevels,
      accStartTime: formatDateTime(requestedDate),
      accEndTime: formatDateTime(accEnd),
    });
    await client.syncPersonLevel(resident.zkPin, mergedLevels);

    await db.collection(RESIDENTS_COL).doc(after.requestByUID).set(
      { zkAccLevelIds: mergedLevels },
      { merge: true }
    );

    await event.data?.after.ref.set(
      { zkAccessGrantedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );
  }
);
