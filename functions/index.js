const { setGlobalOptions } = require("firebase-functions/v2");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

exports.sendPush = onRequest(async (req, res) => {
  const { userId, taskTitle, taskId, taskDate, taskTime } = req.body;

  if (!userId || !taskTitle || !taskDate || !taskTime) {
    res.status(400).send("Missing fields (need userId, taskTitle, taskDate, taskTime)");
    return;
  }

  const userDoc = await admin.firestore().collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;

  if (!fcmToken) {
    res.status(404).send("No FCM token found for user");
    return;
  }

  // ✅ Format inside backend:
  const formattedDateTime = `${taskDate} at ${taskTime}`;

  const message = {
    notification: {
      title: taskTitle,
      body: formattedDateTime,
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      taskId: taskId || "",
    },
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);

    await admin.firestore()
      .collection("users")
      .doc(userId)
      .collection("notifications")
      .add({
        title: taskTitle,
        body: formattedDateTime,
        taskId: taskId || "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    logger.info("✅ Push sent:", response);
    res.status(200).json({ success: true, messageId: response });
  } catch (error) {
    logger.error("❌ Push error:", error);
    res.status(500).send(error.message);
  }
});
