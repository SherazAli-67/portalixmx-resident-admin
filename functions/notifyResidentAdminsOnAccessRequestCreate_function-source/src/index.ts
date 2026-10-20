import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

interface AccessRequest {
  id: string;
  requestByUID: string;
  requestedAccessTitle: string;
  requestedAccessImage: string;
  residentAdminID: string;
  societyID: string;
  requestedForDate: admin.firestore.Timestamp;
  requestedForTime: {
    hour: number;
    minute: number;
  };
  createdAt: admin.firestore.Timestamp;
  status: string;
  updatedAt: admin.firestore.Timestamp;
}

interface ResidentAdmin {
  userID: string;
  userName: string;
  email: string;
  societyID: string;
  token?: string;
}

export const notifyResidentAdminsOnAccessRequestCreate =
  functions.firestore.onDocumentCreated(
    "access_requests/{requestId}",
    async (event) => {
      const data = event.data?.data() as AccessRequest | undefined;

      if (!data || !data.societyID) {
        console.log("No valid access request data found");
        return;
      }

      const societyID = data.societyID;
      const requestId = event.params.requestId;

      try {
        // 1. Get all resident admins of same society
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
          console.log("No FCM tokens found for admins");
          return;
        }

        // 2. Prepare notification
        const payload: admin.messaging.MulticastMessage = {
          tokens: tokens,
          notification: {
            title: "New Access Request",
            body: `${data.requestedAccessTitle} request received`,
          },
          data: {
            requestId,
            type: "ACCESS_REQUEST",
          },
        };

        // 3. Send notification
        const response = await admin.messaging().sendEachForMulticast(payload);

        console.log("Notifications sent:", response.successCount);

        console.log("Failures:", response.failureCount);

        return;
      } catch (error) {
        console.error("Error sending notifications:", error);
        return;
      }
    }
  );