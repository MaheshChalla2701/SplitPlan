const express = require("express");
const admin = require("firebase-admin");

// ─── Firebase Admin Init ───────────────────────────────────────────────────────
// FIREBASE_SERVICE_ACCOUNT env var must contain the full JSON content
// of your Firebase service account key file.
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const messaging = admin.messaging();

// ─── Express Health-Check ──────────────────────────────────────────────────────
// Render pings this endpoint to keep the server alive (use an uptime monitor).
const app = express();

app.get("/", (req, res) => {
    res.send("SplitPlan Notification Server is running ✅");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
    startFirestoreListener();
});

// ─── Firestore Listener ────────────────────────────────────────────────────────
function startFirestoreListener() {
    let isInitialLoad = true;

    db.collection("paymentRequests")
        .orderBy("createdAt", "desc")
        .onSnapshot(
            (snapshot) => {
                // On startup Firestore sends all existing docs as "added" — skip them.
                if (isInitialLoad) {
                    isInitialLoad = false;
                    console.log(
                        `Listening for new payment requests (${snapshot.size} existing docs ignored)`
                    );
                    return;
                }

                snapshot.docChanges().forEach((change) => {
                    if (change.type === "added") {
                        handleNewPaymentRequest(change.doc.id, change.doc.data());
                    }
                });
            },
            (error) => {
                console.error("Firestore listener error:", error);
            }
        );
}

// ─── Notification Logic ────────────────────────────────────────────────────────
async function handleNewPaymentRequest(requestId, request) {
    const { toUserId, fromUserId, amount, description } = request;

    if (!toUserId || !fromUserId || toUserId === fromUserId) return;

    try {
        // Get recipient's FCM token
        const recipientDoc = await db.collection("users").doc(toUserId).get();
        const fcmToken = recipientDoc.data()?.fcmToken;

        if (!fcmToken) {
            console.log(`No FCM token for user ${toUserId}, skipping.`);
            return;
        }

        // Get sender's name for a friendly notification
        const senderDoc = await db.collection("users").doc(fromUserId).get();
        const senderName = senderDoc.data()?.name ?? "Someone";

        const desc =
            description && description.trim().length > 0 ? description : "a payment";

        const formattedAmount = Number(amount).toLocaleString("en-IN", {
            maximumFractionDigits: 2,
        });

        // Send push notification via FCM
        await messaging.send({
            token: fcmToken,
            notification: {
                title: "💸 New Payment Request",
                body: `${senderName} requested ₹${formattedAmount} for ${desc}`,
            },
            android: {
                notification: {
                    channelId: "payment_requests",
                    priority: "high",
                    sound: "default",
                },
            },
            data: {
                requestId: requestId,
                type: "payment_request",
            },
        });

        console.log(`✅ Notification sent to user ${toUserId} for request ${requestId}`);
    } catch (error) {
        console.error(`❌ Error sending notification for request ${requestId}:`, error);
    }
}
