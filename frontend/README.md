# HHBN Hotel Booking App - Flutter Frontend

This is a Flutter-based frontend for the HHBN Hotel Booking Management System.

## Project Structure

```
lib/
├── main.dart                 # Entry point of the application
├── screens/
│   ├── splash_screen.dart   # Initial splash screen with HHBN logo
│   ├── login_screen.dart    # Login screen with email/password
│   └── widgets/
│       └── custom_text_field.dart  # Reusable custom text field widget
├── utils/
│   ├── colors.dart          # App color constants
│   └── strings.dart         # App text constants
└── assets/
    ├── images/              # Image assets (logo, icons)
    └── fonts/               # Custom fonts
```

## Features

### Splash Screen
- Displays HHBN logo with tagline
- Auto-navigates to Login screen after 3 seconds
- Gradient background matching design

### Login Screen
- Email input field with validation
- Password input field with show/hide toggle
- Login button for email/password authentication
- Google Login button
- Forgot Password link
- Sign Up link for new users
- Beautiful gradient background
- Back button navigation

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart (included with Flutter)

### Installation

1. Navigate to the project directory:
```bash
cd frontend
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build for Release

#### Android
```bash
flutter build apk
```

#### iOS
```bash
flutter build ios
```

## Dependencies

- **flutter**: Core Flutter framework
- **cupertino_icons**: iOS-style icons
- **google_fonts**: Google Fonts integration

## Color Scheme

- **Primary Blue**: #1E5BA8
- **Dark Blue**: #0F3A5F
- **Light Blue**: #2E7BC4
- **Gradient Start**: #2D5A7B
- **Gradient End**: #1A3A5C

## TODO Items

The following features need to be implemented:

1. Email validation logic in login
2. Google Sign-In integration
3. Password reset functionality
4. Sign-up screen and functionality
5. Home screen after successful login
6. Backend API integration
7. Persistent authentication tokens
8. Error handling and user feedback
9. Password recovery email functionality

## Design Reference

The UI design is based on Figma mockups:
- Splash Screen displaying HHBN branding
- Login Screen with email/password fields
- Google Sign-In integration
- Responsive layout for mobile devices

## Notes

- All screens use a consistent gradient background
- Custom text fields with focus states
- Smooth navigation between screens
- Material Design 3 components
