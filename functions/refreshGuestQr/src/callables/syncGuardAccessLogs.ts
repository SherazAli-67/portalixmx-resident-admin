import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  createZkBioClient,
  db,
  getResident,
  GUARD_LOGS_SUB,
  requireAuthUid,
  SOCIETIES_COL,
} from "../utils/firestore";

interface TransactionRecord {
  eventTime?: string;
  pin?: string;
  name?: string;
  eventName?: string;
  eventPointName?: string;
}

export const syncGuardAccessLogs = onCall(async (request) => {
  const uid = requireAuthUid(request.auth?.uid);
  const resident = await getResident(uid);
  if (!resident.societyID) {
    throw new HttpsError("failed-precondition", "User has no society");
  }

  const since = request.data?.since as string | undefined;
  const client = await createZkBioClient(resident.societyID);
  const transactions = (await client.listTransactions({ pageNo: 1, pageSize: 100 })) as TransactionRecord[];

  const societyId = resident.societyID;
  const batch = db.batch();
  let count = 0;

  for (const tx of transactions) {
    if (!tx.eventTime) continue;
    if (since && tx.eventTime < since) continue;

    const logId = `${tx.eventTime}_${tx.pin ?? "unknown"}_${tx.eventPointName ?? ""}`.replace(/[^a-zA-Z0-9_-]/g, "_");
    const ref = db.collection(SOCIETIES_COL).doc(societyId).collection(GUARD_LOGS_SUB).doc(logId);
    batch.set(
      ref,
      {
        zkEventTime: tx.eventTime,
        zkPersonPin: tx.pin ?? null,
        doorName: tx.eventPointName ?? "",
        eventName: tx.eventName ?? "",
        visitorName: tx.name ?? null,
        syncedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    count++;
  }

  if (count > 0) {
    await batch.commit();
  }

  return { synced: count };
});
