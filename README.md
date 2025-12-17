# Stick Hero Flutter

A Flutter clone of the Stick Hero game with extra features.

## Features
- **Landscape Mode**: Optimized for landscape gameplay.
- **Two Modes**:
  - **Easy**: Standard gameplay.
  - **Hard**: Faster stick growth, narrower platforms.
- **High Scores**: Saves your best score for each mode locally.
- **Vibration**: Haptic feedback when you fall.
- **Enhanced UI**: Smooth animations and clean design.

## Setup Instructions

**AUTOMATED BUILD:**
I have included a script `build_app.bat` that will do everything for you (initialize, add permissions, and build).

1.  **Install Flutter**: Ensure Flutter is installed and in your PATH.
2.  **Run Script**: Double-click `build_app.bat` or run it from the terminal:
    ```cmd
    build_app.bat
    ```
3.  **Get APK**: The script will generate the APK at `build/app/outputs/flutter-apk/app-release.apk`.

**Manual Setup:**
If you prefer manual steps:

1.  **Initialize Flutter Project**:
    Open a terminal in this directory (`stick_hero_flutter`) and run:
   ```bash
   flutter create .
   ```
   This will generate the `android`, `ios`, `web`, etc. folders.

2. **Add Permissions (Android)**:
   To enable vibration, open `android/app/src/main/AndroidManifest.xml` and add the following permission inside the `<manifest>` tag:
   ```xml
   <uses-permission android:name="android.permission.VIBRATE"/>
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Dependencies
- `shared_preferences`: For storing high scores.
- `vibration`: For haptic feedback.
- `google_fonts`: For custom typography.

Enjoy the game!
