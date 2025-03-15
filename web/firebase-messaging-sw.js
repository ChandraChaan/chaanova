importScripts("https://www.gstatic.com/firebasejs/10.8.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.8.1/firebase-messaging-compat.js");

// Your Firebase configuration (Ensure it matches your app's Firebase setup)
firebase.initializeApp({
      apiKey: 'AIzaSyBC0kj-qArDQT-qoXtJJOEhf5puXAvpvwY',
      appId: '1:401705689244:web:240b92527b27c446654d59',
      messagingSenderId: '401705689244',
      projectId: 'chaanova-4cfe6',
      authDomain: 'chaanova-4cfe6.firebaseapp.com',
      storageBucket: 'chaanova-4cfe6.firebasestorage.app',
      measurementId: 'G-L16KNC8C1W',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Received background message ", payload);

  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: "/icons/icon-192x192.png", // Update this path with your app icon
  });
});