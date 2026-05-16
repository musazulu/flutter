# 📷 ANPR Mobile App

A Flutter mobile app that captures vehicle licence plates using the phone camera and sends them to a Python ANPR backend for detection, OCR, and blacklist checking.

---

## 🧱 System Overview

```
[Flutter Mobile App]  →  POST /detect (image)  →  [Python Flask API]
                                                        ↓
                                                   YOLOv8 + EasyOCR
                                                        ↓
                                                   SQLite Database
```

---

## ✅ Prerequisites

Before running this app, make sure you have the following installed:

| Tool | Version | Download |
|------|---------|----------|
| Flutter SDK | >= 3.35.0 | https://docs.flutter.dev/get-started/install |
| Dart SDK | >= 3.9.0 | Bundled with Flutter |
| Android Studio | Latest | https://developer.android.com/studio |
| Android SDK | API 21+ | Via Android Studio |
| A physical Android device OR emulator | — | — |

> **iOS users:** Xcode is also required. See [Flutter iOS setup](https://docs.flutter.dev/get-started/install/macos/mobile-ios).

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/musazulu/flutter.git
cd flutter
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Connect your device

Plug in your Android phone via USB and enable **USB Debugging** in Developer Options.

Verify your device is detected:

```bash
flutter devices
```

You should see your device listed.

### 4. Configure the backend IP address

Open `lib/main.dart` and find this line:

```dart
Uri.parse("http://192.168.110.50:5000/detect"),
```

Replace `192.168.110.50` with the **local IP address of the machine running the Python backend**.

To find your machine's IP:
- **Windows:** Run `ipconfig` in CMD → look for `IPv4 Address`
- **Linux/Mac:** Run `ifconfig` or `ip a`

> ⚠️ Both your phone and the backend machine must be on the **same Wi-Fi network**.

### 5. Start the Python backend

Make sure the ANPR Python backend is running before launching the app.

```bash
# On the backend machine
cd anpr_project_clean
python api.py
```

The API will start on `http://0.0.0.0:5000`.

### 6. Run the Flutter app

```bash
flutter run
```

Or to build a release APK:

```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 How to Use the App

1. Launch the app on your phone
2. Point the camera at a vehicle licence plate
3. Tap **📸 Capture Plate**
4. The app sends the image to the backend
5. The detected plate is shown on screen:
   - ✅ **Green** = Normal plate detected
   - 🚨 **Red** = BLACKLISTED plate detected

---

## 🗂️ Project Structure

```
anpr_app/
├── lib/
│   └── main.dart          # Main app logic (camera + API call)
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── assets/
│   ├── best.tflite        # YOLO model (TFLite)
│   └── labels.txt         # Detection labels
├── pubspec.yaml           # Flutter dependencies
├── pubspec.lock           # Locked dependency versions
└── requirements.txt       # All packages with exact versions
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| camera | 0.10.6 | Access device camera |
| http | 1.6.0 | Send HTTP requests to backend |

Full list of all packages (including transitive) is in [`requirements.txt`](./requirements.txt).

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---------|-----|
| `No cameras available` | Run on a physical device, not a desktop |
| `Connection refused` | Check backend IP in `main.dart` and ensure Flask is running |
| `Error: $e` on screen | Check that phone and backend are on the same Wi-Fi |
| Build fails | Run `flutter doctor` and fix any reported issues |
| Plate not detected | Ensure good lighting and hold camera steady |

---

## 🔗 Related

- **Backend repo:** [anpr_project_clean](https://github.com/musazulu) — Python Flask + YOLOv8 + EasyOCR
- **Flutter docs:** https://docs.flutter.dev
