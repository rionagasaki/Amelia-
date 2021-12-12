console.log("Hello World");
const { firestore } = require('firebase-admin');
const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp(functions.config().firebase);

exports.send_AgeRequest_Notifications = functions.region("asia-northeast1").firestore
.document('/Following/{requestId}')
.onUpdate( (event, snapshot) => {
   console.log("event",event);
   console.log(snapshot);

  const follow = event.data().followData
  const name = event.data().name
     console.log("follow:",followData);
     console.log("name:",name)

// uidを使って相手のfcm token を取得
  const token = followData.fcmToken
  console.log("token:",token);


// fcm token を使ってpush通知

// 通知の内容
 const payload = {
    notification: {
       title: "Amelia",
       body: "フレンド申請が来ています",
       sound: "default",

    }
} ;      
});
