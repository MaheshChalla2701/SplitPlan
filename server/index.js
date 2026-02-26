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
    startExpensesListener();
});

// ─── Firestore Listener ────────────────────────────────────────────────────────
function startFirestoreListener() {
    let isInitialLoad = true;
    let initialDocs = new Set();

    db.collection("payment_requests")
        .orderBy("createdAt", "desc")
        .onSnapshot(
            (snapshot) => {
                // On startup Firestore sends all existing docs as "added"
                if (isInitialLoad) {
                    isInitialLoad = false;
                    snapshot.docs.forEach((doc) => initialDocs.add(doc.id));
                    console.log(`Listening for payment request updates (${snapshot.size} existing docs ignored)`);
                    return;
                }

                snapshot.docChanges().forEach((change) => {
                    const docId = change.doc.id;
                    const data = change.doc.data();

                    // Edge case: Sometimes initial load docs get "added" again or we just want to be safe
                    if (change.type === "added" && initialDocs.has(docId)) {
                        return;
                    }

                    if (change.type === "added") {
                        handlePaymentEvent(docId, data, "CREATE");
                    } else if (change.type === "modified") {
                        handlePaymentEvent(docId, data, "UPDATE");
                    } else if (change.type === "removed") {
                        handlePaymentEvent(docId, data, "DELETE");
                    }
                });
            },
            (error) => {
                console.error("Firestore listener error:", error);
            }
        );
}

// ─── Notification Logic ────────────────────────────────────────────────────────
async function handlePaymentEvent(requestId, request, eventType) {
    const { toUserId, fromUserId, amount, description, status } = request;

    if (!toUserId || !fromUserId || toUserId === fromUserId) return;

    try {
        // Send notification to the RECIPIENT for new requests
        // For updates/deletes, notify the OTHER person (if I paid it, notify the requester)
        const isSender = eventType === "CREATE";
        const targetUserId = isSender ? toUserId : fromUserId;
        const actorUserId = isSender ? fromUserId : toUserId;

        // Get target user's FCM token and notification preferences
        const targetDoc = await db.collection("users").doc(targetUserId).get();
        const targetData = targetDoc.data();
        const fcmToken = targetData?.fcmToken;
        const notificationsEnabled = targetData?.notificationsEnabled ?? true;
        const mutedUids = targetData?.mutedUids || [];

        if (!fcmToken) {
            console.log(`No FCM token for user ${targetUserId}, skipping.`);
            return;
        }

        if (notificationsEnabled === false) {
            console.log(`Notifications disabled by user ${targetUserId}, skipping.`);
            return;
        }

        if (mutedUids.includes(actorUserId)) {
            console.log(`Notifications from ${actorUserId} muted by user ${targetUserId}, skipping.`);
            return;
        }

        // Get actor's name
        const actorDoc = await db.collection("users").doc(actorUserId).get();
        const actorName = actorDoc.data()?.name ?? "Someone";

        const desc = description && description.trim().length > 0 ? description : "a payment";
        const formattedAmount = Number(amount).toLocaleString("en-IN", {
            maximumFractionDigits: 2,
        });

        let title = "";
        let body = "";

        if (eventType === "CREATE") {
            title = "💸 New Payment Request";
            body = `${actorName} requested ₹${formattedAmount} for ${desc}`;
        } else if (eventType === "UPDATE") {
            if (status === "paid") {
                title = "✅ Payment Received";
                body = `${actorName} paid ₹${formattedAmount} for ${desc}`;
            } else if (status === "declined") {
                title = "❌ Request Declined";
                body = `${actorName} declined your request for ₹${formattedAmount}`;
            } else {
                title = "📝 Request Updated";
                body = `The request for ₹${formattedAmount} was updated`;
            }
        } else if (eventType === "DELETE") {
            title = "🗑️ Request Cancelled";
            body = `${actorName} cancelled the request for ₹${formattedAmount}`;
        }

        // Send push notification via FCM
        await messaging.send({
            token: fcmToken,
            notification: {
                title,
                body,
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
                eventType: eventType,
            },
        });

        console.log(`✅ [${eventType}] Notification sent to ${targetUserId} for request ${requestId}`);
    } catch (error) {
        console.error(`❌ Error sending [${eventType}] notification for ${requestId}:`, error);
    }
}

// ─── Group Expenses Listener ───────────────────────────────────────────────────
function startExpensesListener() {
    let isInitialLoad = true;
    let initialDocs = new Set();

    db.collection("expenses")
        .orderBy("createdAt", "desc")
        .onSnapshot(
            (snapshot) => {
                // On startup Firestore sends all existing docs as "added"
                if (isInitialLoad) {
                    isInitialLoad = false;
                    snapshot.docs.forEach((doc) => initialDocs.add(doc.id));
                    console.log(`Listening for expenses updates (${snapshot.size} existing docs ignored)`);
                    return;
                }

                snapshot.docChanges().forEach((change) => {
                    const docId = change.doc.id;
                    const data = change.doc.data();

                    if (change.type === "added" && initialDocs.has(docId)) {
                        return;
                    }

                    if (change.type === "added") {
                        handleExpenseCreateEvent(docId, data);
                    }
                });
            },
            (error) => {
                console.error("Expenses listener error:", error);
            }
        );
}

async function handleExpenseCreateEvent(expenseId, expenseData) {
    const { groupId, description, amount, createdBy } = expenseData;

    try {
        // Fetch group details to get memberIds & group name
        const groupDoc = await db.collection("groups").doc(groupId).get();
        if (!groupDoc.exists) return;

        const groupData = groupDoc.data();
        const memberIds = groupData.memberIds || [];

        // Fetch creator details
        const creatorDoc = await db.collection("users").doc(createdBy).get();
        const creatorName = creatorDoc.data()?.name ?? "Someone";

        const formattedAmount = Number(amount).toLocaleString("en-IN", {
            maximumFractionDigits: 2,
        });
        const desc = description && description.trim().length > 0 ? description : "an expense";

        const title = `🧾 New Group Expense`;
        const body = `${creatorName} added ₹${formattedAmount} for ${desc} in ${groupData.name}`;

        // Send to all members EXCEPT createdBy
        const targetMemberIds = memberIds.filter(id => id !== createdBy);

        for (const targetUserId of targetMemberIds) {
            const targetDoc = await db.collection("users").doc(targetUserId).get();
            const targetData = targetDoc.data();
            const fcmToken = targetData?.fcmToken;
            const notificationsEnabled = targetData?.notificationsEnabled ?? true;
            const mutedUids = targetData?.mutedUids || [];

            if (!fcmToken) continue;

            if (notificationsEnabled === false) {
                console.log(`Notifications disabled by user ${targetUserId}, skipping group expense.`);
                continue;
            }

            if (mutedUids.includes(createdBy) || mutedUids.includes(groupId)) {
                console.log(`Notifications for group ${groupId} or user ${createdBy} muted by user ${targetUserId}, skipping group expense.`);
                continue;
            }

            await messaging.send({
                token: fcmToken,
                notification: {
                    title,
                    body,
                },
                android: {
                    notification: {
                        channelId: "payment_requests", // Can reuse the same channel for heads-up alerts
                        priority: "high",
                        sound: "default",
                    },
                },
                data: {
                    expenseId: expenseId,
                    groupId: groupId,
                    type: "group_expense",
                },
            });
            console.log(`✅ [CREATE_EXPENSE] Notification sent to ${targetUserId} for expense ${expenseId}`);
        }
    } catch (error) {
        console.error(`❌ Error sending [CREATE_EXPENSE] notification for ${expenseId}:`, error);
    }
}
