importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyDLtL9qbSt8F-ySSSswzOc3iBdBgSSlHhk",
  authDomain: "toolucs-7cbc3.firebaseapp.com",
  projectId: "toolucs-7cbc3",
  storageBucket: "toolucs-7cbc3.firebasestorage.app",
  messagingSenderId: "70648687498",
  appId: "1:70648687498:web:6f01ad31ceb9fa679cb673",
  measurementId: "G-TQXZ0DE65V"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: payload.notification.image || '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
