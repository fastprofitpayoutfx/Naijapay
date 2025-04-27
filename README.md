# NaijaPay - Nigerian Mobile Payment App

A comprehensive Nigerian-focused mobile payment application built with Flutter. This app provides essential payment services tailored for the Nigerian market.

## Features

- **User Authentication**: Secure login, registration, and profile management
- **Dashboard**: View account balance and recent transactions at a glance
- **Money Transfers**: Transfer funds to any Nigerian bank account
- **Bill Payments**: Pay electricity, water, TV, and other utility bills
- **Airtime & Data**: Purchase airtime and data bundles for any Nigerian network
- **Transaction History**: Track and filter all your financial activities

## Project Structure

```
lib/
  ├── config/              # App configuration and theme
  ├── models/              # Data models
  ├── screens/             # All UI screens
  ├── services/            # API services, auth, and storage
  ├── utils/               # Helper functions and constants
  ├── widgets/             # Reusable UI components
  └── main.dart            # Entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / Xcode for device emulation
- An editor (VS Code, Android Studio, etc.)

### Installation

1. Clone this repository
2. Navigate to the project directory
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## Environment Setup

The app requires a `.env` file in the root directory with the following variables:
```
API_URL=https://api.naijapay.example.com
API_KEY=your_api_key_here
```

## Key UI Screenshots

- Splash and Onboarding
- Authentication (Login/Register)
- Dashboard and Home
- Transfer Money
- Bill Payments
- Airtime & Data
- Transaction History

## API Integration

This app is designed to integrate with backend APIs for:
- User authentication
- Bank account verification
- Money transfers
- Bill payments
- Airtime/data purchases
- Transaction history

## Dependencies

- `provider`: State management
- `http`: API requests
- `flutter_secure_storage`: Secure data storage
- `hive_flutter`: Local data caching
- `flutter_dotenv`: Environment variable management
- `intl`: Date and number formatting
- `image_picker`: User profile image selection
- `carousel_slider`: UI carousel elements
- `shimmer`: Loading effects
- `flutter_svg`: SVG image support
- `local_auth`: Biometric authentication
- `url_launcher`: Open external URLs