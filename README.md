# ClassCheck

**ClassCheck** is a university mobile application built with Flutter and Firebase that allows students to check in to class and reflect on their learning experience.

## Features

- **GPS Location Verification** — Confirms students are physically present in the classroom
- **QR Code Scanning** — Students scan instructor-displayed QR codes at check-in and class end
- **Pre-Class Reflection** — Students share previous topic, expected topic, and mood (1–5 scale)
- **Post-Class Reflection** — Students summarize what they learned and provide feedback
- **Instructor Dashboard** — Create classes, start sessions, display QR codes, view attendance
- **Offline Support** — Firebase offline persistence caches data and syncs when reconnected

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (iOS & Android) |
| Backend & Database | Firebase (Auth, Cloud Firestore) |
| Auth | Email/Password + Google Sign-In |

## Getting Started

### Prerequisites

- Flutter SDK 3.29+ installed
- A Firebase project created at [Firebase Console](https://console.firebase.google.com/)
- Android Studio or Xcode for running on devices/emulators

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd ClassCheck
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Enable **Authentication** (Email/Password + Google Sign-In)
   - Enable **Cloud Firestore**
   - Download and add:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # App widget + auth routing
├── config/
│   └── theme.dart         # App theme
├── models/                # Data models
├── services/              # Auth, Firestore, Location services
├── screens/
│   ├── auth/              # Login, Register
│   ├── student/           # Check-in, Finish, Reflections, History
│   └── instructor/        # Class management, Sessions, QR, Attendance
├── widgets/               # Reusable widgets (MoodSelector, QrDisplay, etc.)
└── utils/                 # Constants, Validators, Helpers
```

## User Roles

| Role | Description |
|---|---|
| **Student** | Checks in to class, submits pre- and post-class reflections |
| **Instructor** | Creates classes, starts sessions, displays QR codes, views attendance |
