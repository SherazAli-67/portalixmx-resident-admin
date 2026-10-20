import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

admin.initializeApp();

interface Complaint {
  id: string;
  complaint: string;
  complaintBy: string;
  residentAdminID: string;
  societyID: string;
  status: string | number; // ✅ supports both string & number
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

interface Resident {
  userID: string;
  userName: string;
  token?: string;
}

export const notifyResidentOnComplaintStatusUpdate =
  onDocumentUpdated("complaints/{complaintId}", async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;

    if (!beforeSnap || !afterSnap) {
      console.log("Missing snapshot data");
      return;
    }

    const beforeData = beforeSnap.data() as Complaint;
    const afterData = afterSnap.data() as Complaint;

    // ✅ 1. Only proceed if status changed
    if (beforeData.status === afterData.status) {
      console.log("Complaint status not changed");
      return;
    }

    try {
      // ✅ 2. Fetch resident
      const residentDoc = await admin
        .firestore()
        .collection("residents")
        .doc(afterData.complaintBy)
        .get();

      if (!residentDoc.exists) {
        console.log("Resident not found:", afterData.complaintBy);
        return;
      }

      const residentData = residentDoc.data() as Resident;

      if (!residentData.token) {
        console.log("No FCM token for resident");
        return;
      }

      // ✅ 3. Normalize status (handle string & number)
      const status = afterData.status;

      let title = "Complaint Update";
      let body = "Your complaint status has been updated";

      console.log("Complaint status:", status);

      switch (status) {
        case 1:
        case "inProgress":
          title = "Complaint In Progress";
          body = "Your complaint is now being worked on";
          break;

        case 2:
        case "resolved":
          title = "Complaint Resolved ✅";
          body = "Your complaint has been resolved";
          break;

        case 3:
        case "rejected":
          title = "Complaint Rejected ❌";
          body = "Your complaint has been rejected";
          break;

        case 0:
        case "pending":
        default:
          title = "Complaint Pending";
          body = "Your complaint is pending review";
      }

      // ✅ 4. Prepare notification
      const payload: admin.messaging.Message = {
        token: residentData.token,
        notification: {
          title,
          body,
        },
        data: {
          complaintId: event.params.complaintId,
          type: "COMPLAINT_STATUS_UPDATE",
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