import { setGlobalOptions } from "firebase-functions/v2";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { initializeApp, getApps } from "firebase-admin/app";

if (getApps().length === 0) initializeApp();

setGlobalOptions({ region: "us-central1" });

const SOCIETIES = "societies";

export const listSocietiesForSignup = onCall(async () => {
    try {
        const snap = await getFirestore().collection(SOCIETIES).get();
        return {
            societies: snap.docs.map((doc) => {
                const data = doc.data();
                const id = typeof data.id === "string" && data.id.length > 0 ? data.id : doc.id;
                const name = typeof data.name === "string" ? data.name : "";
                return { id, name };
            }),
        };
    } catch (e) {
        throw new HttpsError("internal", "Failed to list societies.");
    }
});
