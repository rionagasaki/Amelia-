const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp(functions.config().firebase);

//  URLから「CloudFunctions」呼び出し
exports.send_AgeRequest_Notifications = functions.region("asia-northeast1").firestore.document('/Following/{requestId}').onUpdate(())
//  アプリから「CloudFunctions」呼び出し
exports.pushSubmitFromApp = functions.https.onCall((request, response) => {

  const token = "FCMToken";
  const payload = {
          notification: {
            title: "フレンド申請",
            body: "フレンド申請が届きました。アプリを開いて確認してみよう。",
            badge: "1",             //バッジ数
            sound:"default"         //プッシュ通知音
          }
        };

  pushToDevice(token,payload);

});

//  FCM部分
function pushToDevice(token, payload){
  // priorityをhighにしとく。
  const options = {
    priority: "high",
  };

  admin.messaging().sendToDevice(token, payload, options)
  .then(pushResponse => {
    return { text: token };
  })
  .catch(error => {
    throw new functions.https.HttpsError('unknown', error.message, error);
  });
}

