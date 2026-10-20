import * as admin from "firebase-admin";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

admin.initializeApp();

// interface PaymentSubmitted {
//   paymentByUID: string;
//   submittedOnDate: admin.firestore.Timestamp;
//   approvedOnDate?: admin.firestore.Timestamp;
// }

interface Payment {
  paymentID: string;
  paymentForTitle: string;
  description: string;
  amount: number;
  societyID: string;
  paymentByUID: string;
  paymentType: number;
  paymentStatus: number;
  dateTime: admin.firestore.Timestamp;
  receipt?: string;
}

interface ResidentAdmin {
  userID: string;
  userName: string;
  email: string;
  societyID: string;
  token?: string;
}

export const notifyResidentAdminsOnPaymentSubmitted =
  onDocumentCreated(
    "payments/{paymentID}/payments_submitted/{submissionId}",
    async (event) => {
      const snap = event.data;

      if (!snap) {
        console.log("No snapshot data");
        return;
      }

    //   const submissionData = snap.data() as PaymentSubmitted;

      const { paymentID, submissionId } = event.params;

      try {
        // 1. Get parent payment document
        const paymentDoc = await admin
          .firestore()
          .collection("payments")
          .doc(paymentID)
          .get();

        if (!paymentDoc.exists) {
          console.log("Payment document not found:", paymentID);
          return;
        }

        const paymentData = paymentDoc.data() as Payment;

        if (!paymentData || !paymentData.societyID) {
          console.log("Invalid payment data");
          return;
        }

        const societyID = paymentData.societyID;

        // 2. Fetch resident admins of same society
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

        // 3. Prepare notification
        const payload: admin.messaging.MulticastMessage = {
          tokens: tokens,
          notification: {
            title: "Payment received",
            body: `${paymentData.paymentForTitle} payment received`,
          },
          data: {
            paymentID: paymentID,
            submissionId: submissionId,
            type: "PAYMENT_SUBMITTED",
          },
        };

        // 4. Send notification
        const response = await admin.messaging().sendEachForMulticast(payload);

        console.log("Notifications sent:", response.successCount);
        console.log("Failures:", response.failureCount);

        // 5. Optional: clean invalid tokens
        response.responses.forEach((res, index) => {
          if (!res.success) {
            const errorCode = res.error?.code;

            if (
              errorCode === "messaging/registration-token-not-registered" ||
              errorCode === "messaging/invalid-registration-token"
            ) {
              console.log("Invalid token:", tokens[index]);
              // Optionally remove token from Firestore
            }
          }
        });

        return;
      } catch (error) {
        console.error("Error sending notifications:", error);
        return;
      }
    }
  );