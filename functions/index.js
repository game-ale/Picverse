const { initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');

initializeApp();

const db = getFirestore();

function buildNotificationMessage(notification) {
  switch (notification.type) {
    case 'like':
      return `${notification.actorUsername} liked your post`;
    case 'comment':
      return `${notification.actorUsername} commented on your post`;
    case 'follow':
      return `${notification.actorUsername} started following you`;
    default:
      return 'You have a new notification';
  }
}

exports.sendPushOnNotificationCreate = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const notification = snapshot.data();
    if (!notification || !notification.userId) {
      return;
    }

    const userDoc = await db.collection('users').doc(notification.userId).get();
    if (!userDoc.exists) {
      return;
    }

    const userData = userDoc.data() || {};
    const tokens = Array.isArray(userData.fcmTokens)
      ? userData.fcmTokens.filter((token) => typeof token === 'string' && token.length > 0)
      : [];

    if (tokens.length === 0) {
      return;
    }

    const message = buildNotificationMessage(notification);

    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: 'Picverse',
        body: message,
      },
      data: {
        notificationId: snapshot.id,
        type: String(notification.type || ''),
        actorId: String(notification.actorId || ''),
        actorUsername: String(notification.actorUsername || ''),
        postId: String(notification.postId || ''),
      },
    });

    const invalidTokens = [];
    response.responses.forEach((result, index) => {
      if (!result.success) {
        const errorCode = result.error && result.error.code ? result.error.code : '';
        if (
          errorCode === 'messaging/registration-token-not-registered' ||
          errorCode === 'messaging/invalid-registration-token'
        ) {
          invalidTokens.push(tokens[index]);
        }
      }
    });

    if (invalidTokens.length > 0) {
      await db.collection('users').doc(notification.userId).update({
        fcmTokens: FieldValue.arrayRemove(...invalidTokens),
      });
    }
  }
);
