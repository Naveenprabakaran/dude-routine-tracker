# Dude Routine Tracker — Complete Build Guide

## What You're Building
A dark-mode Flutter app that tracks your 11 daily tasks, sends notifications at each task time, shows progress, monthly reports with bar charts, and lets you write daily notes. Everything works **100% offline**.

---

## Project Folder Structure

```
dude_routine_tracker/
├── lib/
│   ├── main.dart                    ← App entry point + navigation
│   ├── theme.dart                   ← Dark theme colors & styles
│   ├── models/
│   │   ├── task_model.dart          ← Task data model (Hive)
│   │   ├── task_model.g.dart        ← Hive adapter (auto-generated)
│   │   ├── note_model.dart          ← Note data model (Hive)
│   │   └── note_model.g.dart        ← Hive adapter (auto-generated)
│   ├── services/
│   │   ├── storage_service.dart     ← All Hive read/write operations
│   │   ├── notification_service.dart← Schedule & manage notifications
│   │   └── task_seeder.dart         ← Seeds daily tasks from template
│   ├── screens/
│   │   ├── dashboard_screen.dart    ← Today's tasks + progress ring
│   │   ├── report_screen.dart       ← Monthly bar chart + streak
│   │   ├── notes_screen.dart        ← Daily journal/notes
│   │   └── settings_screen.dart     ← Notifications + schedule view
│   └── widgets/
│       ├── task_card.dart           ← Individual task card with YES/NO
│       └── progress_ring.dart       ← Circular progress indicator
├── android/
│   ├── app/
│   │   ├── build.gradle             ← App build config
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  ← Permissions & components
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── res/
│   │           ├── drawable/launch_background.xml
│   │           └── values/styles.xml
│   ├── build.gradle                 ← Project build config
│   ├── settings.gradle
│   └── gradle.properties
└── pubspec.yaml                     ← Dependencies
```

---

## Step 1: Install Flutter SDK

### Windows
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (avoid paths with spaces)
3. Add `C:\flutter\bin` to your system PATH
4. Open a new terminal and run: `flutter doctor`

### macOS
```bash
# Using Homebrew (recommended)
brew install --cask flutter

# Or download manually from https://docs.flutter.dev/get-started/install/macos
```

### Linux (Ubuntu/Debian)
```bash
sudo snap install flutter --classic
flutter sdk-path
```

---

## Step 2: Install Android Studio + SDK

1. Download Android Studio: https://developer.android.com/studio
2. Install it and open it
3. Go to: **Tools → SDK Manager**
4. Under **SDK Platforms**, install: **Android 14 (API 34)** and **Android 8.0 (API 26)**
5. Under **SDK Tools**, install:
   - Android SDK Build-Tools
   - Android Emulator
   - Android SDK Platform-Tools
   - Command-line Tools

6. Accept Android licenses:
```bash
flutter doctor --android-licenses
# Press 'y' for each license
```

---

## Step 3: Verify Flutter Setup

Run this command — everything should show a green checkmark:
```bash
flutter doctor
```

Expected output:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Android Studio
[✓] Connected device
```

If you see warnings about Android licenses, run:
```bash
flutter doctor --android-licenses
```

---

## Step 4: Set Up the Project

### Option A: Copy files into a new Flutter project (Recommended for beginners)

```bash
# Create a fresh Flutter project
flutter create dude_routine_tracker
cd dude_routine_tracker

# Now REPLACE the generated files with the files provided in this package:
# - Replace pubspec.yaml
# - Replace all files in lib/
# - Replace android/app/src/main/AndroidManifest.xml
# - Replace android/app/build.gradle
# - Replace android/build.gradle
# - Replace android/settings.gradle
# - Replace android/gradle.properties
```

### Option B: Use the project directly

```bash
# Navigate to the project directory
cd dude_routine_tracker

# Get all dependencies
flutter pub get
```

---

## Step 5: Install Dependencies

```bash
flutter pub get
```

This downloads all packages listed in `pubspec.yaml`:
- `hive` + `hive_flutter` — Local database
- `flutter_local_notifications` — Push notifications
- `timezone` — Timezone support for scheduled notifications
- `fl_chart` — Bar charts in reports
- `intl` — Date formatting

---

## Step 6: Run on Emulator (for testing)

### Create an Android emulator:
1. Open Android Studio
2. Go to: **Tools → Device Manager**
3. Click **Create Device**
4. Choose: **Pixel 6** → **Next**
5. Select API level **33** or **34** → **Download** → **Next** → **Finish**
6. Click the play ▶ button to start the emulator

### Run the app:
```bash
# List available devices
flutter devices

# Run the app (it will auto-detect your emulator)
flutter run

# Or specify the device
flutter run -d emulator-5554
```

---

## Step 7: Run on a Real Android Phone

1. Enable **Developer Options** on your phone:
   - Go to **Settings → About Phone**
   - Tap **Build Number** 7 times
   - You'll see "You are now a developer!"

2. Enable **USB Debugging**:
   - Go to **Settings → Developer Options**
   - Turn on **USB Debugging**

3. Connect phone via USB cable

4. On your phone, tap **Allow** when asked to trust the computer

5. Run:
```bash
flutter devices    # Should show your phone
flutter run        # Builds and installs the app
```

---

## Step 8: Build the APK

### Debug APK (for testing, no signing required):
```bash
flutter build apk --debug
```
APK location: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (smaller, faster, for sharing):
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Fat APK (works on all devices, larger file):
```bash
flutter build apk --release --split-per-abi
```
This creates separate APKs for arm64, arm32, and x86_64 — smaller individual files.

---

## Step 9: Install APK on Your Phone

### Method 1: Via USB (while phone is connected)
```bash
flutter install
```

### Method 2: Copy APK file
1. Copy `app-release.apk` to your phone
2. Open the file on your phone
3. If prompted, allow "Install from unknown sources"
4. Tap **Install**

### Method 3: ADB (Android Debug Bridge)
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Notification Setup Notes

### The app automatically schedules notifications when it first launches.

If notifications don't appear:
1. Open the app
2. Go to **Settings** tab
3. Tap **"Reschedule All Notifications"**
4. Also check: **Phone Settings → Apps → Dude Routine → Notifications → Allow**

### For Android 12+:
The app requests exact alarm permission. If denied:
- Go to **Phone Settings → Apps → Special App Access → Alarms & Reminders**
- Enable for Dude Routine

---

## Troubleshooting Common Issues

### "flutter: command not found"
- Make sure Flutter's `bin` folder is in your PATH
- Restart your terminal after adding to PATH

### "Android SDK not found"
```bash
flutter config --android-sdk /path/to/android/sdk
# Common paths:
# Windows: C:\Users\YourName\AppData\Local\Android\Sdk
# macOS: ~/Library/Android/sdk
# Linux: ~/Android/Sdk
```

### Build fails with Gradle error
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### "Hive box not found" error
This means the app tried to read before Hive initialized. Make sure `StorageService.init()` is called before `runApp()` in `main.dart` — it already is in our code.

### Notifications not working on emulator
Emulators don't always show notifications reliably. Test on a real device for notifications.

### App crashes on launch
```bash
flutter logs    # View real-time logs
# or
adb logcat      # View Android logs
```

---

## Customizing Your Routine

To change the tasks, edit `lib/services/task_seeder.dart`:

```dart
static final List<Map<String, dynamic>> _taskTemplates = [
  {'name': 'Wake Up',   'hour': 6,  'minute': 30, 'label': '6:30 AM'},
  // Add/remove tasks here
  // hour uses 24-hour format: 13 = 1 PM, 22 = 10 PM
];
```

Also update `lib/services/notification_service.dart` → `scheduleAllRoutineNotifications()` to match.

---

## App Architecture Overview

```
User opens app
     │
     ▼
main.dart
  ├─ StorageService.init()     → Opens Hive database
  ├─ NotificationService.init() → Sets up notifications
  └─ runApp(DudeRoutineApp)
          │
          ▼
     MainNavigator (Bottom Nav)
     ├─ DashboardScreen    → Today's tasks
     ├─ ReportScreen       → Monthly stats + chart
     ├─ NotesScreen        → Daily journal
     └─ SettingsScreen     → Preferences

Data Flow:
  TaskSeeder → creates TaskModel → StorageService (Hive) → UI
  NotificationService → schedules notifications → OS → User taps → App opens
```

---

## Dependencies Explained

| Package | Purpose |
|---------|---------|
| `hive` | Fast local key-value database |
| `hive_flutter` | Flutter integration for Hive |
| `flutter_local_notifications` | Schedule & show push notifications |
| `timezone` | Handle timezones for accurate notification scheduling |
| `fl_chart` | Beautiful bar/line charts |
| `intl` | Date formatting (e.g., "Monday, Jan 15") |

---

## Quick Command Reference

```bash
flutter pub get          # Install dependencies
flutter run              # Run in debug mode
flutter run --release    # Run in release mode
flutter build apk        # Build debug APK
flutter build apk --release  # Build release APK
flutter clean            # Clean build cache
flutter doctor           # Check setup
flutter devices          # List connected devices
flutter logs             # View app logs
```

---

## File Size & Performance

- Debug APK: ~80-100 MB (includes debug symbols)
- Release APK: ~15-25 MB (optimized)
- Split per ABI APK: ~8-12 MB (smallest, recommended for sharing)

The app uses no internet — all data is stored on the device using Hive.
