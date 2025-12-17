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

## How to Run on Another PC

### Option A: Just Play the Game (Android Only)
If your friend just wants to play on their Android phone:
1.  Run `one_click_build.bat` on your computer.
2.  Send them the file: `build/app/outputs/flutter-apk/app-release.apk`.
3.  They install and play.

### Option B: Run the Project (For Development/Windows)
If you want to run the project on their computer (e.g., to play on Windows or edit code):

**Step 1: Prepare (On YOUR Computer)**
1.  Run `clean_for_transfer.bat`.
    *   This deletes temporary files to make the folder small.
2.  Zip the entire `stick_hero_flutter` folder.
3.  Send the zip file to your friend.

**Step 2: Run (On FRIEND'S Computer)**
1.  Unzip the folder.
2.  **Double-click `one_click_build.bat`**.
    *   **Magic Script**: This script will check if they have Flutter.
    *   **If missing**, it will ask to download and install it automatically (~1GB).
    *   It will then set up the project and build the APK.
3.  The APK will open in a folder when done.

## Dependencies
- `shared_preferences`: For storing high scores.
- `vibration`: For haptic feedback.
- `google_fonts`: For custom typography.

Enjoy the game!
