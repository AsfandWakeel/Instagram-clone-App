const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ✅ HTTP endpoint for sending push
exports.sendPushHttp = functions.https.onRequest(async (req, res) => {
  try {
    const {token, title, body, imageUrl, postId} = req.body;

    if (!token || !title || !body) {
      return res.status(400).json({error: "Missing fields"});
    }

    const message = {
      token,
      notification: {
        title,
        body,
        image: imageUrl || undefined,
      },
      data: {
        postId: postId || "",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    await admin.messaging().send(message);
    return res.status(200).json({success: true, message: "Push sent"});
  } catch (err) {
    console.error("Push error", err);
    return res.status(500).json({error: err.message});
  }
});
