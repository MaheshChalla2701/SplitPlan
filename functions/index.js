/* eslint-disable max-len */
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Triggered when a new payment request document is created in Firestore.
 * Reads the recipient's FCM token from their user document and sends a
 * push notification to their Android device.
 */
exports.onPaymentRequestCreated = onDocumentCreated(
    "paymentRequests/{requestId}",
    async (event) => {
        const request = event.data.data();
        if (!request) return;

        const { toUserId, fromUserId, amount, description } = request;

        // Don't notify if sender and recipient are the same (shouldn't happen)
        if (!toUserId || toUserId === fromUserId) return;

        try {
            // Fetch the recipient's Firestore document to get their FCM token
            const recipientDoc = await getFirestore()
                .collection("users")
                .doc(toUserId)
                .get();

            const recipientData = recipientDoc.data();
            const fcmToken = recipientData?.fcmToken;

            if (!fcmToken) {
                console.log(`No FCM token for user ${toUserId}, skipping notification.`);
                return;
            }

            // Fetch the sender's name for a friendly notification body
            const senderDoc = await getFirestore()
                .collection("users")
                .doc(fromUserId)
                .get();
            const senderName = senderDoc.data()?.name ?? "Someone";

            const desc = description && description.trim().length > 0
                ? description
                : "a payment";

            const formattedAmount = Number(amount).toLocaleString("en-IN", {
                maximumFractionDigits: 2,
            });

            // Send the push notification via FCM
            await getMessaging().send({
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
                    requestId: event.params.requestId,
                    type: "payment_request",
                },
            });

            console.log(`Notification sent to user ${toUserId}`);
        } catch (error) {
            console.error("Error sending payment request notification:", error);
        }
    },
);
