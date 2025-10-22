# 🌿 Mental Health App – Flutter Wellness Companion

<p align="center">
  <strong>A modern cross-platform Flutter app designed to improve mental wellness through self-awareness, guided sessions, and community support.</strong>
</p>

---

## 🧘 Overview

**Mental Health App** is a multi-language mobile application built with **Flutter** that helps users monitor their mental wellbeing, connect with supportive communities, and track personal growth.

The app provides a **minimalist UI**, **smooth transitions**, and a **curved bottom navigation bar**, creating a calm and pleasant user experience.

---

## ✨ Key Features

### 🏠 Home Screen

- Personalized dashboard with username and avatar.
- Motivational quotes and mental wellness reminders.

### 💬 Community

- Join meaningful discussions about mental health.
- Connect with others for emotional support.

### 📅 Sessions

- Log or track therapy and meditation sessions.
- Monitor session summaries and progress over time.

### 👤 Profile

- Edit your name and profile picture in real-time.
- Updates reflect instantly across all pages.

---

## 🌍 Localization

This app supports **three languages**:

- 🇺🇸 English (`en`)
- 🇻🇳 Vietnamese (`vi`)
- 🇷🇺 Russian (`ru`)

You can switch languages dynamically using:

```dart
MentalHealthApp.setLocale(context, Locale('vi'));
```

---

## 🧩 Architecture & Tech Stack

| Component                | Description                                 |
| ------------------------ | ------------------------------------------- |
| **Framework**            | Flutter (Material Design 3)                 |
| **Language**             | Dart                                        |
| **Architecture Pattern** | MVVM-like Stateful Widgets                  |
| **Navigation**           | `curved_navigation_bar`                     |
| **Localization**         | `flutter_localizations`, `AppLocalizations` |
| **Animation**            | `AnimatedSwitcher` + `FadeTransition`       |
| **UI Theme**             | Urbanist font, soft green palette           |
| **Platforms**            | Android & iOS                               |

---

## ⚙️ Project Structure

```
lib/
│
├── main.dart                 # Entry point of the app
├── home_screen.dart          # Home dashboard
├── sessions_screen.dart      # Meditation & therapy tracking
├── community_screen.dart     # Community chat section
├── profile_screen.dart       # User profile page
└── l10n/
    └── app_localizations.dart # Handles multilingual support
```

---

## 🎨 UI & Navigation

The app uses **CurvedNavigationBar** for smooth and natural navigation between core sections:

| Icon | Page            | Description          |
| ---- | --------------- | -------------------- |
| 🏠   | HomeScreen      | Overview and welcome |
| 🎥   | SessionsScreen  | Therapy & meditation |
| 💬   | CommunityScreen | Chat and community   |
| 👤   | ProfileScreen   | Manage profile info  |

---

## 🛠️ Installation & Run

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Android Studio or VS Code
- Android Emulator or iOS Simulator

### Setup Steps

1️⃣ **Clone the Repository**

```bash
git clone https://github.com/yourusername/mental_health_app.git
cd mental_health_app
```

2️⃣ **Install Dependencies**

```bash
flutter pub get
```

3️⃣ **Run the App**

```bash
flutter run
```

4️⃣ **Build for Release**

```bash
flutter build apk --release
```

---

## 📱 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/2d0cdbce-2d91-4149-846d-e2b0d643db79" width="220" />
  <img src="https://github.com/user-attachments/assets/502c7aff-5e54-4ff4-b5c9-e74cde4871cc" width="220" />
  <img src="https://github.com/user-attachments/assets/4579506e-f408-4988-8e7b-200f7799a8cb" width="220" />
</p>

---

## 💡 Future Improvements

- [ ] Add dark mode 🌙
- [ ] Integrate Firebase Authentication 🔥
- [ ] Add mood tracking & journaling 📓
- [ ] AI-powered mood suggestions 🤖
- [ ] Push notifications for daily check-ins 🔔

---

## 🧠 Developer Skills

<p align="left">
  <img src="https://skillicons.dev/icons?i=dart,flutter,java,kotlin,swift" alt="Mobile" />
  <img src="https://skillicons.dev/icons?i=git,github,vscode,androidstudio,postman,figma" alt="Tools" />
</p>

---

## 📜 License

This project is licensed under the **MIT License**.
See the `LICENSE` file for details.

---

<p align="center">
  ⭐ If you find this project helpful, please give it a <b>Star</b> on GitHub to support development! ⭐
</p>
