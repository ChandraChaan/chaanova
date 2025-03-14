# **Chaanova**

Chaanova is a **modern online learning platform** built with **Flutter Web** and **Firebase**, designed to provide seamless **online classes**, **student registration**, and **secure payment integration**. The platform is optimized for **fast loading times**, featuring a **real-time loading timer** to enhance the user experience.

## 🚀 **Features**
✅ **Online Classes** – Deliver high-quality, interactive virtual classes  
✅ **Student Registration** – Smooth onboarding with a secure registration system  
✅ **Payment Integration** – Seamless fee payments with multiple gateways  
✅ **Fast Performance** – Optimized Flutter Web build with minimal loading time  
✅ **Real-time Loading Timer** – Displays accurate page load duration for user experience transparency  
✅ **Firebase Backend** – Secure and scalable backend services

---

## 📌 **Tech Stack**
- **Frontend:** Flutter Web
- **State Management:** BLoC (Business Logic Component)
- **Backend:** Firebase (Firestore, Authentication, Cloud Functions)
- **Payments:** Stripe / Razorpay (TBD)
- **Hosting:** Firebase Hosting

---

## 🛠 **Getting Started**

### **1️⃣ Prerequisites**
Ensure you have the following installed on your machine:
- **Flutter SDK** (Latest stable version) → [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (Included with Flutter)
- **Firebase CLI** → [Install Firebase CLI](https://firebase.google.com/docs/cli)
- **Git** (Version Control)

### **2️⃣ Clone the Repository**
```bash
git clone https://github.com/ChandraChaan/chaanova.git
cd chaanova
```

### **3️⃣ Install Dependencies**
```bash
flutter pub get
```

### **4️⃣ Configure Firebase**
1. Create a new project on [Firebase Console](https://console.firebase.google.com/)
2. Enable Firestore, Authentication, and any other required services
3. Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS)
4. Place them inside the respective folders:
    - `android/app/google-services.json`
    - `ios/Runner/GoogleService-Info.plist`

### **5️⃣ Run the App**
For **Flutter Web**:
```bash
flutter run -d chrome
```
For **Mobile (Android/iOS)**:
```bash
flutter run
```

---

## 🎡 Project Structure (Following Clean Architecture)

```
lib/
│── core/                     # Common utilities, constants
│── data/                     # Data sources, repositories
│── domain/                   # Business logic, use cases
│── presentation/             # UI & State Management (BLoC)
│── main.dart                 # Entry point
```

---

## 🌟 Future Enhancements
📈 **AI-based Recommendations** for courses  
💬 **Live Chat Support** for students and teachers  
🛋 **Offline Mode** for accessing recorded classes

---

## 🐝 License
This project is licensed under the **MIT License**.

---

## 💬 Contributing
We welcome contributions! Feel free to fork the repository and submit a pull request.

---

## 📧 Contact
For any queries or support, feel free to contact us via GitHub or email.

---

🚀 **Built with Flutter & Firebase for the best online learning experience!** 🎉  

