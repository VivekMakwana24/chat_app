var firebaseConfig = {
    apiKey: "AIzaSyAcgL8--sthP0zm9gcTRLgKKDX0ioXd_0M",
    appId: "1:398051540701:web:bf384056f7cef09bc6e534",
    messagingSenderId: "398051540701",
    projectId: "chat-demo-c58d4",
    authDomain: "chat-demo-c58d4.firebaseapp.com",
    databaseURL: 'https://chat-demo-c58d4.firebaseio.com',
    storageBucket: 'chat-demo-c58d4.appspot.com',
    measurementId: "G-04KDZMDXQ9"
};

firebase.initializeApp(firebaseConfig);
firebase.analytics();

var messaging = firebase.messaging()

messaging.usePublicVapidKey('Your Key');

messaging.getToken().then((currentToken) => {
    console.log(currentToken)
})