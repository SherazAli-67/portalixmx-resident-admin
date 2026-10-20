import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

admin.initializeApp();

interface AccessRequest {
  id: string;
  requestByUID: string;
  requestedAccessTitle: string;
  residentAdminID: string;
  societyID: string;
  status: string | number; // ✅ FIXED
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

interface Resident {
  userID: string;
  userName: string;
  token?: string;
}

export const notifyResidentOnAccessRequestStatusUpdate =
  onDocumentUpdated("access_requests/{requestId}", async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;

    if (!beforeSnap || !afterSnap) {
      console.log("Missing snapshot data");
      return;
    }

    const beforeData = beforeSnap.data() as AccessRequest;
    const afterData = afterSnap.data() as AccessRequest;

    // ✅ 1. Only proceed if status changed
    if (beforeData.status === afterData.status) {
      console.log("Access request status not changed");
      return;
    }

    try {
      // ✅ 2. Fetch resident
      const residentDoc = await admin
        .firestore()
        .collection("residents")
        .doc(afterData.requestByUID)
        .get();

      if (!residentDoc.exists) {
        console.log("Resident not found:", afterData.requestByUID);
        return;
      }

      const residentData = residentDoc.data() as Resident;

      if (!residentData.token) {
        console.log("No FCM token for resident");
        return;
      }

      // ✅ 3. Normalize status
      const status = afterData.status;

      let title = "Access Request Update";
      let body = `Your request for ${afterData.requestedAccessTitle} has been updated`;

      switch (status) {
        case 1:
        case "approved":
          title = "Access Approved ✅";
          body = `Your request for ${afterData.requestedAccessTitle} has been approved`;
          break;

        case 2:
        case "rejected":
          title = "Access Rejected ❌";
          body = `Your request for ${afterData.requestedAccessTitle} has been rejected`;
          break;

        case 0:
        case "pending":
        default:
          title = "Access Pending";
          body = `Your request for ${afterData.requestedAccessTitle} is pending`;
      }

      // ✅ 4. Prepare notification
      const payload: admin.messaging.Message = {
        token: residentData.token,
        notification: {
          title,
          body,
        },
        data: {
          requestId: event.params.requestId,
          type: "ACCESS_REQUEST_STATUS_UPDATE",
          status: String(status),
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