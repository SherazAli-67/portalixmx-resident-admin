/**
 * Notify society residents when an event, poll, or visible fund report is created.
 *
 * Deploy (example):
 *   firebase deploy --only \
 *     functions:onCommunityEventCreated,\
 *     functions:onCommunityPollCreated,\
 *     functions:onFundReportCreated,\
 *     functions:onFundReportUpdated
 *
 * Assumptions:
 * - FCM token field on residents docs: `token`
 * - Approved residents: `status === 1` (UserStatus.approved)
 * - Fund report visibility field: `showToResidents`
 * - Adjust `data.route` values to match the resident app routes
 */

import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { initializeApp, getApps } from "firebase-admin/app";
import { logger } from "firebase-functions";

if (getApps().length === 0) initializeApp();

const RESIDENTS = "residents";
const USER_STATUS_APPROVED = 1;
const FCM_BATCH_SIZE = 500;

async function getSocietyResidentTokens(societyID: string): Promise<string[]> {
  const snap = await getFirestore()
    .collection(RESIDENTS)
    .where("societyID", "==", societyID)
    .get();

  const tokens = new Set<string>();
  for (const doc of snap.docs) {
    const data = doc.data();
    if (data.status !== USER_STATUS_APPROVED) continue;
    if (typeof data.token === "string" && data.token.length > 0) {
      tokens.add(data.token);
    }
  }
  return [...tokens];
}

async function notifyResidents(opts: {
  societyID: string;
  title: string;
  body: string;
  data: Record<string, string>;
}): Promise<{ sent: number }> {
  const tokens = await getSocietyResidentTokens(opts.societyID);
  if (tokens.length === 0) {
    logger.info("No resident tokens for society", { societyID: opts.societyID });
    return { sent: 0 };
  }

  const messaging = getMessaging();
  let sent = 0;

  for (let i = 0; i < tokens.length; i += FCM_BATCH_SIZE) {
    const chunk = tokens.slice(i, i + FCM_BATCH_SIZE);
    const result = await messaging.sendEachForMulticast({
      tokens: chunk,
      notification: {
        title: opts.title,
        body: opts.body,
      },
      data: opts.data,
      android: { priority: "high" },
      apns: {
        payload: {
          aps: {
            sound: "default",
            contentAvailable: true,
          },
        },
      },
    });
    sent += result.successCount;

    if (result.failureCount > 0) {
      logger.warn("Some FCM sends failed", {
        societyID: opts.societyID,
        failureCount: result.failureCount,
        successCount: result.successCount,
      });
    }
  }

  return { sent };
}

function asNonEmptyString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

/** New community calendar event → notify all approved residents in the society. */
export const onCommunityEventCreated = onDocumentCreated(
  "community_calendar_events/{eventId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const societyID = asNonEmptyString(data.societyID);
    if (!societyID) {
      logger.warn("Event missing societyID", { eventId: event.params.eventId });
      return;
    }

    const eventTitle = asNonEmptyString(data.eventTitle) ?? "A new event was posted";

    const result = await notifyResidents({
      societyID,
      title: "New community event",
      body: eventTitle,
      data: {
        type: "community_event",
        id: String(event.params.eventId),
        societyID,
        route: "/community-calendar",
      },
    });

    logger.info("Event notification sent", {
      eventId: event.params.eventId,
      societyID,
      sent: result.sent,
    });
  },
);

/** New community poll → notify all approved residents in the society. */
export const onCommunityPollCreated = onDocumentCreated(
  "community_polls/{pollId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const societyID = asNonEmptyString(data.societyID);
    if (!societyID) {
      logger.warn("Poll missing societyID", { pollId: event.params.pollId });
      return;
    }

    const question = asNonEmptyString(data.question) ?? "A new poll was posted";

    const result = await notifyResidents({
      societyID,
      title: "New community poll",
      body: question,
      data: {
        type: "community_poll",
        id: String(event.params.pollId),
        societyID,
        route: "/community-polls",
      },
    });

    logger.info("Poll notification sent", {
      pollId: event.params.pollId,
      societyID,
      sent: result.sent,
    });
  },
);

async function notifyFundReportIfVisible(
  reportId: string,
  data: FirebaseFirestore.DocumentData,
): Promise<void> {
  if (data.showToResidents !== true) return;

  const societyID = asNonEmptyString(data.societyID);
  if (!societyID) {
    logger.warn("Fund report missing societyID", { reportId });
    return;
  }

  const title = asNonEmptyString(data.title) ?? "A new fund report was shared";

  const result = await notifyResidents({
    societyID,
    title: "New fund report",
    body: title,
    data: {
      type: "fund_report",
      id: String(reportId),
      societyID,
      route: "/fund-management",
    },
  });

  logger.info("Fund report notification sent", {
    reportId,
    societyID,
    sent: result.sent,
  });
}

/** Fund report created with showToResidents === true. */
export const onFundReportCreated = onDocumentCreated(
  "fund_reports/{reportId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    await notifyFundReportIfVisible(event.params.reportId, snap.data());
  },
);

/**
 * Fund report updated so showToResidents flips false → true
 * (e.g. publish later).
 */
export const onFundReportUpdated = onDocumentUpdated(
  "fund_reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const becameVisible =
      before.showToResidents !== true && after.showToResidents === true;
    if (!becameVisible) return;

    await notifyFundReportIfVisible(event.params.reportId, after);
  },
);