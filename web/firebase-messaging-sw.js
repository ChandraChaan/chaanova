importScripts("https://www.gstatic.com/firebasejs/10.8.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.8.1/firebase-messaging-compat.js");

// Initialize Firebase (Ensure these credentials match your Firebase project)
firebase.initializeApp({
  apiKey: "AIzaSyBC0kj-qArDQT-qoXtJJOEhf5puXAvpvwY",
  appId: "1:401705689244:web:240b92527b27c446654d59",
  messagingSenderId: "401705689244",
  projectId: "chaanova-4cfe6",
  authDomain: "chaanova-4cfe6.firebaseapp.com",
  storageBucket: "chaanova-4cfe6.appspot.com", // Fixed storage bucket URL
  measurementId: "G-L16KNC8C1W",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log("[Firebase Messaging] Background Message Received: ", payload);

  // Extract notification details safely
  const notificationTitle = payload?.notification?.title || "New Notification";
  const notificationBody = payload?.notification?.body || "You have a new message.";
  const notificationOptions = {
    body: notificationBody,
    icon: "/icons/default-notification.png", // You can remove this line if no icon is needed
    badge: "/icons/badge.png", // Badge icon for PWA (optional)
    vibrate: [200, 100, 200], // Vibration pattern (optional)
  };

  // Show notification
  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener("notificationclick", (event) => {
  console.log("[Firebase Messaging] Notification Clicked: ", event.notification);
  event.notification.close();

  // Open app or focus existing tab
  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((windowClients) => {
        if (windowClients.length > 0) {
          return windowClients[0].focus();
        }
        return clients.openWindow("/");
      })
  );
});