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

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });
/*
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});*/
