# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build release APK
flutter build apk --release

# Clean build artifacts
flutter clean
```

## Architecture

This is a Flutter mobile app using **Provider** for state management and **Dio** for HTTP. The code is in Indonesian (comments, variable names) as the team is Indonesian-speaking.

### Layer Structure

```
lib/
├── config/        # API endpoints, routes, theme
├── models/        # Data classes (DTOs)
├── services/      # Data layer: API calls and local storage
├── viewmodels/    # ChangeNotifier classes (business logic)
├── views/         # Screens (one file per screen)
├── widgets/       # Shared UI components
├── app.dart       # MultiProvider setup and MaterialApp
└── main.dart      # Entry point
```

### Navigation

Route definitions live in [lib/config/app_routes.dart](lib/config/app_routes.dart). Flow:
- **SplashScreen** (`/`) checks stored token → redirects to `/dashboard` or `/login`
- **LoginScreen** / **RegisterScreen** → on success, push to `/dashboard`

### State Management

Three `ChangeNotifier` ViewModels registered in `app.dart`:
- **AuthViewModel** — login/register/logout, current user, auth errors
- **DashboardViewModel** — dashboard UI state and dummy data
- **CourseProvider** — course list data

### Services

- **ApiService** (`lib/services/api_service.dart`) — Dio client with an interceptor that injects the Bearer token from storage on every request and handles 401 by clearing storage and redirecting to login.
- **AuthService** (`lib/services/auth_service.dart`) — wraps login, register, and logout API calls.
- **StorageService** (`lib/services/storage_service.dart`) — SharedPreferences wrapper for token and user info persistence.

### API

Base URL and all endpoint paths are defined in [lib/config/api_config.dart](lib/config/api_config.dart). The backend is a Laravel app using Sanctum token auth. The base URL points to a local development server (`192.168.110.167:8000`) and must be updated for other environments.

### Theme

Defined in [lib/config/app_theme.dart](lib/config/app_theme.dart):
- **Primary:** Navy Blue `#00146B`
- **Secondary:** Purple `#8B008B`
- **Font:** Poppins (via `google_fonts`)
- Global styles for buttons, text fields, cards, and AppBar are set there — prefer extending these rather than adding inline styles.

### Shared Widgets

- **CustomButton** — handles loading state
- **CustomTextField** — label + input with optional suffix icon
- **MenuCard** — icon + title card used in the dashboard grid
