import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

admin.initializeApp();

interface Resident {
  userID: string;
  userName: string;
  email: string;
  societyID: string;
  status: number; // 0 = pending, 1 = approved
  token?: string;
}

export const notifyResidentOnStatusUpdate =
  onDocumentUpdated("residents/{residentId}", async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;

    if (!beforeSnap || !afterSnap) {
      console.log("Missing snapshot data");
      return;
    }

    const beforeData = beforeSnap.data() as Resident;
    const afterData = afterSnap.data() as Resident;

    // ✅ 1. Check if status actually changed
    if (beforeData.status === afterData.status) {
      console.log("Status not changed");
      return;
    }

    // ✅ 2. Check token exists
    if (!afterData.token) {
      console.log("No FCM token for resident");
      return;
    }

    try {
      let title = "Account Status Updated";
      let body = "Your account status has been updated";

      // ✅ 3. Customize message based on status
      if (afterData.status === 1) {
        title = "Account Approved 🎉";
        body = "Your account has been approved by the admin";
      } else if (afterData.status === 0) {
        title = "Account Pending";
        body = "Your account is now pending approval";
      }

      // ✅ 4. Prepare payload
      const payload: admin.messaging.Message = {
        token: afterData.token,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "RESIDENT_STATUS_UPDATE",
          status: String(afterData.status),
        },
      };

      // ✅ 5. Send notification
      const response = await admin.messaging().send(payload);

      console.log("Notification sent:", response);

      return;
    } catch (error) {
      console.error("Error sending notification:", error);
      return;
    }
  });