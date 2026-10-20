import * as admin from "firebase-admin";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

admin.initializeApp();

interface Resident {
  userID: string;
  userName: string;
  email: string;
  phoneNum?: string;
  createdAt: admin.firestore.Timestamp;
  profileImg?: string;
  societyID: string;
  emergencyContacts: string[];
  status: string;
  houseNumber?: string;
  token?: string;
}

interface ResidentAdmin {
  userID: string;
  userName: string;
  email: string;
  societyID: string;
  token?: string;
}

export const notifyResidentAdminsOnResidentCreate =
  onDocumentCreated("residents/{residentId}", async (event) => {
    const snap = event.data;

    if (!snap) {
      console.log("No snapshot data");
      return;
    }

    const residentData = snap.data() as Resident;

    if (!residentData || !residentData.societyID) {
      console.log("Invalid resident data");
      return;
    }

    const societyID = residentData.societyID;
    const residentId = event.params.residentId;

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

      // 2. Prepare notification
      const payload: admin.messaging.MulticastMessage = {
        tokens: tokens,
        notification: {
          title: "New Resident Registered",
          body: `${residentData.userName} has joined your society`,
        },
        data: {
          residentId: residentId,
          type: "NEW_RESIDENT",
        },
      };

      // 3. Send notification
      const response = await admin.messaging().sendEachForMulticast(payload);

      console.log("Notifications sent:", response.successCount);
      console.log("Failures:", response.failureCount);

      // 4. Optional: clean invalid tokens
      response.responses.forEach((res, index) => {
        if (!res.success) {
          const errorCode = res.error?.code;

          if (
            errorCode === "messaging/registration-token-not-registered" ||
            errorCode === "messaging/invalid-registration-token"
          ) {
            console.log("Invalid token:", tokens[index]);
            // Optional: remove token from Firestore
          }
        }
      });

      return;
    } catch (error) {
      console.error("Error sending notifications:", error);
      return;
    }
  });