# Flutter Project: Matchday MVP

A Flutter project designed for managing soccer matches with features such as player alignment, match creation, and user authentication.

## Requirements

To run this project, ensure you have the following installed:

- **Flutter SDK**: Download Flutter
- **Dart SDK**: Comes with Flutter.
- **Git**: Download Git

## Getting Started

1. Clone the Repository
   Use the following command to clone this project:

```bash
git clone https://github.com/your-username/matchday-mvp.git
```

Navigate to the project directory:

```bash
cd matchday-mvp
```

2. Install Dependencies
   Run the following command to fetch the required dependencies:

```bash
flutter pub get
```

3. Set Up Platforms
   Depending on your target platform, initialize the necessary files:

```bash
flutter create .
```

## Running the App

**Android**
Connect an Android device or start an emulator.

Run the command:

```bash
flutter run
```

**IOS**
Connect an iOS device or start the simulator.

Ensure you have Xcode installed and properly configured.

Run:

```bash
flutter run
```

**Web**
To build and serve the app for web:

```bash
flutter run -d chrome
```

**Desktop (Windows, macOS, Linux)**
Ensure desktop support is enabled in your Flutter installation.

Run:

```bash
flutter run -d <platform>
```

Replace <platform> with windows, macos, or linux.

## Folder Structure

lib/: Main application code.
assets/: Images and other static assets.
test/: Unit and widget tests.

## Customization Notes

If you need to adjust native configurations:

Android: Modify files in android/.
iOS: Modify files in ios/.
Web: Update files in web/ for custom HTML or manifest changes.
Troubleshooting

1. Dependencies Not Resolving
   If dependencies fail to install, try running:

```bash
flutter pub cache repair
```

2. Platform-Specific Issues
   If you encounter platform errors, ensure the Flutter SDK is properly configured for that platform:

Flutter Setup for Android
Flutter Setup for iOS 3. Regenerate Platform Files
If platform directories are missing, run:

```bash
flutter create .
```

## License

abrah and uim
