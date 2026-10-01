# BANTAI Responder App

Flutter application for BANTAI responders.

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   │   └── network_settings.dart # NestJS base URL, paths, and timeout
│   ├── network/
│   │   └── api_client.dart       # JSON HTTP client and API errors
│   └── theme/
│       └── app_theme.dart        # App-wide Material theme tokens
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart
│   ├── models/
│   │   └── auth_tokens_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── auth_tokens.dart
│   └── repositories/
│       └── auth_repository.dart  # Auth contract used by controllers
├── features/                     # Feature-focused application code
│   └── auth/
│       ├── controllers/
│       │   ├── login_controller.dart
│       │   └── signup_controller.dart
│       ├── screens/
│       │   ├── login.dart
│       │   └── signup.dart
│       └── widgets/
│           ├── login_form.dart
│           ├── login_header.dart
│           ├── login_text_field.dart
│           └── social_auth_button.dart
└── main.dart                     # Dependency wiring and app entry point
```

## How The Layers Work

`main.dart` creates one `ApiClient`, injects it into `AuthRemoteDataSource`, wraps that in `AuthRepositoryImpl`, and passes the repository into the login screen. This keeps widgets independent of HTTP details.

The authentication flow is split into four layers:

- `domain` defines the `AuthRepository` contract and `AuthTokens` entity. It does not know about Flutter or HTTP.
- `data` implements that contract. The remote data source maps login and signup requests to the NestJS API, while the model maps token JSON into the domain entity.
- `features/auth/controllers` owns form state, validation, loading, and user actions.
- `features/auth/screens` and `widgets` render the UI and handle navigation/snackbars.

`AppTheme` is the single starting point for Material theme customization. Add typography, spacing, component themes, and dark mode there as the product design develops.

## Environment Configuration

Copy `.env.example` to `.env` before running the app. `.env` is ignored by Git and is loaded by `main.dart` with `flutter_dotenv`.

`API_BASE_URL` should point to the NestJS API, for example `http://10.0.2.2:3000/api/v1` for an Android emulator. Keep secrets out of this file: Flutter environment files are bundled into the client application and are not secure storage.

## NestJS Connection

The API URL and timeout are read from `.env`; endpoint paths remain code constants in `NetworkSettings`.

The configured endpoints are:

- Login: `POST /auth/local/signin`
- Signup: `POST /auth/local/signup`
- Refresh: `POST /auth/refresh`

The existing NestJS server currently exposes login and refresh. Its `ManualSignupDto` exists, but the signup controller route and service flow still need to be added before the app's signup action can succeed.

## Getting Started

Install Flutter, then run:

```bash
flutter pub get
flutter run
```

Run static analysis and tests with:

```bash
flutter analyze
flutter test
```
