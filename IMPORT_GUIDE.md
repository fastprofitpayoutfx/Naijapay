# NaijaPay Flutter Project: Import Guide

This guide provides comprehensive instructions for importing and running the NaijaPay project in a Flutter development environment.

## Quick Import Steps

1. **Download the Project**
   - In Replit, click on the three dots (⋮) in the file explorer
   - Select "Download as zip"
   - Save and extract the ZIP file to your desired location

2. **Open in Flutter IDE**
   - Open Android Studio or VS Code
   - Select "Open an existing project/folder"
   - Navigate to and select the extracted project folder

3. **Install Dependencies**
   - Open a terminal in the project directory
   - Run: `flutter pub get`
   
4. **Run the Project**
   - Connect a device or start an emulator
   - Run: `flutter run`

## Common Import Issues & Fixes

### Fix 1: Missing .env File
The app requires a `.env` file in the root directory:

```bash
# Create .env file
echo "API_URL=https://api.naijapay.example.com" > .env
echo "API_KEY=your_api_key_here" >> .env
```

### Fix 2: Import Issues
If you see errors related to missing imports, check these common issues:

1. **DateFormat errors**: 
   - Ensure the intl package is imported correctly
   - In files using DateFormat, verify the import exists: `import 'package:intl/intl.dart';`

2. **Provider errors**:
   - Ensure provider package is imported in screens using it
   - Add: `import 'package:provider/provider.dart';`

3. **Shimmer effects**:
   - Import shimmer: `import 'package:shimmer/shimmer.dart';`

### Fix 3: Package Version Conflicts
If you have version conflicts:

```bash
flutter clean
flutter pub get
```

If problems persist, try specifying exact versions in pubspec.yaml:

```yaml
dependencies:
  provider: ^6.0.5
  flutter_secure_storage: ^8.0.0
  intl: ^0.18.0
  # other dependencies...
```

## Detailed Setup Guide

### 1. Flutter SDK Setup

Ensure you have Flutter installed correctly:

```bash
# Check Flutter installation
flutter doctor

# Fix any issues reported by Flutter doctor
```

### 2. Project Dependencies

This project uses several key packages:

- **provider**: State management
- **http**: API requests
- **flutter_secure_storage**: Secure storage
- **intl**: Formatting dates and numbers
- **image_picker**: For profile images
- **shimmer**: Loading effects
- **flutter_svg**: SVG image support

If you encounter issues with any specific feature, make sure its package is installed correctly.

### 3. Run Configuration

For optimal performance:

- **Android**: Ensure Gradle is configured correctly
- **iOS**: Requires macOS and Xcode
- **Web**: Use Chrome for best debugging experience

## Troubleshooting Specific Issues

### Provider Error
If you see errors about 'Provider' not being defined:

```dart
// Add at the top of the file
import 'package:provider/provider.dart';
```

### DateFormat Error
If DateFormat is not found:

```dart
// Add at the top of the file
import 'package:intl/intl.dart';
```

### UI Widget Issues
If the app crashes on startup:

```bash
# Clear derived/build files and cache
flutter clean
flutter pub get
```

### API Connection Issues
The app uses mock data by default. When connecting to real APIs:

1. Update .env file with actual API endpoints
2. Check NetworkImage URLs in dashboard_screen.dart

## Running the App

Standard run:
```bash
flutter run
```

Specify a device:
```bash
flutter devices
flutter run -d <device_id>
```

Release mode (better performance):
```bash
flutter run --release
```

## Project Structure Explained

- **lib/config/**: App theme and configuration
- **lib/models/**: Data models for the app
- **lib/screens/**: All UI screens
- **lib/services/**: API services and data handling
- **lib/utils/**: Helper functions and constants
- **lib/widgets/**: Reusable UI components

## Need Further Help?

Refer to the official Flutter documentation or community forums.
- [Flutter Docs](https://docs.flutter.dev)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Community](https://flutter.dev/community)