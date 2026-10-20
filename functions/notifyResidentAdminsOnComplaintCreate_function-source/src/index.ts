import * as admin from "firebase-admin";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

admin.initializeApp();

interface Complaint {
  id: string;
  complaint: string;
  images: string[];
  complaintBy: string;
  residentAdminID: string;
  societyID: string;
  status: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

interface ResidentAdmin {
  userID: string;
  userName: string;
  email: string;
  societyID: string;
  token?: string;
}

export const notifyResidentAdminsOnComplaintCreate =
  onDocumentCreated("complaints/{complaintId}", async (event) => {
    const snap = event.data;

    if (!snap) {
      console.log("No snapshot data");
      return;
    }

    const data = snap.data() as Complaint;

    if (!data || !data.societyID) {
      console.log("Invalid complaint data");
      return;
    }

    const societyID = data.societyID;
    const complaintId = event.params.complaintId;

    try {
      // 1. Fetch resident admins of same society
      const adminsSnapshot = await admin
        .firestore()
        .collection("resident-admins")
        .where("societyID", "==", societyID)
        .get();

      if (adminsSnapshot.empty) {
        console.log("No resident admins found for society:", societyID);
        return;
      }

      const tokens: string[] = [];

      adminsSnapshot.forEach((doc) => {
        const adminData = doc.data() as ResidentAdmin;

        console.log("Resident admin:", adminData.userName);

        if (adminData.token) {
          tokens.push(adminData.token);
        }
      });

      if (tokens.length === 0) {
        console.log("No FCM tokens found");
        return;
      }

      // 2. Prepare notification payload
      const payload: admin.messaging.MulticastMessage = {
        tokens: tokens,
        notification: {
          title: "New Complaint",
          body: data.complaint || "A new complaint has been submitted",
        },
        data: {
          complaintId: complaintId,
          type: "COMPLAINT",
        },
      };

      // 3. Send notifications
      const response = await admin.messaging().sendEachForMulticast(payload);

      console.log("Notifications sent:", response.successCount);
      console.log("Failures:", response.failureCount);

      // 4. Optional: Clean invalid tokens
      response.responses.forEach((res, index) => {
        if (!res.success) {
          const errorCode = res.error?.code;

          if (
            errorCode === "messaging/registration-token-not-registered" ||
            errorCode === "messaging/invalid-registration-token"
          ) {
            console.log("Invalid token:", tokens[index]);
            // Optional: remove token from Firestore here
          }
        }
      });

      return;
    } catch (error) {
      console.error("Error sending notifications:", error);
      return;
    }
  });