importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAT36FtvrU53SKXhwHsIpz3nQeFaFpKH0c",
  authDomain: "edunudge-ceed4.firebaseapp.com",
  projectId: "edunudge-ceed4",
  storageBucket: "edunudge-ceed4.firebasestorage.app",
  messagingSenderId: "638701611026",
  appId: "1:638701611026:web:195bf37eb4e885907a50cb",
  measurementId: "G-1KD3XGJL0V"
});

const messaging = firebase.messaging();

// รับ background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title;
  const notificationOptions = {
    body: payload.notification?.body,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
