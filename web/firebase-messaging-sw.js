importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

firebase.initializeApp({
    apiKey: "AIzaSyAcgL8--sthP0zm9gcTRLgKKDX0ioXd_0M",
    appId: "1:398051540701:web:bf384056f7cef09bc6e534",
    messagingSenderId: "398051540701",
    projectId: "chat-demo-c58d4",
    authDomain: "chat-demo-c58d4.firebaseapp.com",
    databaseURL: 'https://chat-demo-c58d4.firebaseio.com',
    storageBucket: 'chat-demo-c58d4.appspot.com',
    measurementId: "G-04KDZMDXQ9"
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});



// Handle incoming messages when the app is in the background
messaging.setBackgroundMessageHandler(function(payload) {
    // Handle background message and return a promise
    // for showing a notification
    return self.registration.showNotification("New Message", {
        body: payload.data.message,
    });
});

// Install event listener for service worker
self.addEventListener('install', (event) => {
  event.waitUntil(
    self.skipWaiting()  // This is important to activate the new service worker immediately
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    self.clients.claim()  // This is important to ensure the service worker takes control of the page
  );
});