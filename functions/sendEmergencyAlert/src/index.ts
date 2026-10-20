import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, DocumentSnapshot } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { initializeApp, getApps } from "firebase-admin/app";

if (getApps().length === 0) initializeApp();

const RESIDENTS = "residents";
const RESIDENT_ADMINS = "resident-admins";

function isUid(id: unknown): id is string {
    return typeof id === "string" && id.length > 20;
}

function pickSender(
    adminSnap: DocumentSnapshot,
    residentSnap: DocumentSnapshot,
): DocumentSnapshot | null {
    if (adminSnap.exists) return adminSnap;
    if (residentSnap.exists) return residentSnap;
    return null;
}

export const sendEmergencyAlert = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Must be signed in.");
    }

    const uid = request.auth.uid;
    const db = getFirestore();

    const [adminSnap, residentSnap] = await Promise.all([
        db.collection(RESIDENT_ADMINS).doc(uid).get(),
        db.collection(RESIDENTS).doc(uid).get(),
    ]);

    const senderSnap = pickSender(adminSnap, residentSnap);
    if (!senderSnap) {
        throw new HttpsError("not-found", "User not found.");
    }

    const sender = senderSnap.data()!;
    const contactIds: string[] = Array.isArray(sender.emergencyContacts)
        ? sender.emergencyContacts.filter(
            (id: unknown) => isUid(id) && id !== uid,
        )
        : [];

    if (contactIds.length === 0) {
        throw new HttpsError("failed-precondition", "No emergency contacts.");
    }

    const contactSnaps = await Promise.all(
        contactIds.flatMap((id) => [
            db.collection(RESIDENTS).doc(id).get(),
            db.collection(RESIDENT_ADMINS).doc(id).get(),
        ]),
    );

    const tokens = new Set<string>();
    for (const snap of contactSnaps) {
        if (!snap.exists) continue;
        const data = snap.data()!;
        if (data.societyID !== sender.societyID) continue;
        if (typeof data.token === "string" && data.token.length > 0) {
            tokens.add(data.token);
        }
    }

    if (tokens.size === 0) {
        throw new HttpsError("failed-precondition", "No reachable contacts.");
    }

    const senderName = sender.userName || "A resident";
    await getMessaging().sendEachForMulticast({
        tokens: [...tokens],
        notification: {
            title: "Emergency alert",
            body: `${senderName} needs help.`,
        },
        data: {
            type: "emergency",
            senderId: uid,
            route: "/emergency-calls",
        },
        android: { priority: "high" },
        apns: { payload: { aps: { sound: "default", contentAvailable: true } } },
    });

    return { sent: tokens.size };
});