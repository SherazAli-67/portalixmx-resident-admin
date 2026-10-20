import * as admin from "firebase-admin";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

admin.initializeApp();

interface Payment {
  paymentID: string;
  paymentForTitle: string;
  description: string;
  amount: number;
  societyID: string;
  paymentByUID: string;
  paymentType: string | number;
  paymentStatus: string | number;
  dateTime: admin.firestore.Timestamp;
  receipt?: string;
}

interface Resident {
  userID: string;
  userName: string;
  societyID: string;
  token?: string;
}

export const notifyResidentsOnPaymentCreated =
  onDocumentCreated("payments/{paymentId}", async (event) => {
    const snap = event.data;

    if (!snap) {
      console.log("No snapshot data");
      return;
    }

    const paymentData = snap.data() as Payment;

    if (!paymentData || !paymentData.societyID) {
      console.log("Invalid payment data");
      return;
    }

    const societyID = paymentData.societyID;
    const paymentId = event.params.paymentId;

    try {
      // ✅ 1. Fetch all residents of same society
      const residentsSnapshot = await admin
        .firestore()
        .collection("residents")
        .where("societyID", "==", societyID)
        .get();

      if (residentsSnapshot.empty) {
        console.log("No residents found for society:", societyID);
        return;
      }

      const tokens: string[] = [];

      residentsSnapshot.forEach((doc) => {
        const resident = doc.data() as Resident;

        if (resident.token) {
          tokens.push(resident.token);
        }
      });

      if (tokens.length === 0) {
        console.log("No FCM tokens found");
        return;
      }

      // ✅ 2. Prepare notification
      const payload: admin.messaging.MulticastMessage = {
        tokens: tokens,
        notification: {
          title: "New Payment Request",
          body: `${paymentData.paymentForTitle} - Amount: ${paymentData.amount}`,
        },
        data: {
          paymentId: paymentId,
          type: "NEW_PAYMENT_REQUEST",
        },
      };

      // ✅ 3. Send notification
      const response = await admin.messaging().sendEachForMulticast(payload);

      console.log("Notifications sent:", response.successCount);
      console.log("Failures:", response.failureCount);

      // ✅ 4. Optional: clean invalid tokens
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