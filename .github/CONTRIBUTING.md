# Contributing to BANTAI Rider App

Thank you for contributing to the BANTAI Rider App. This project is a Flutter
client for BANTAI riders, and contributions are welcome for bug fixes,
improvements, documentation, and new features.

## Before You Start

- Check existing issues and pull requests before starting work.
- Open an issue first for significant changes or new features.
- Keep changes focused and explain the user-facing impact in the pull request.
- Do not commit `.env`, credentials, API keys, or other secrets.

## Project Overview

The app is built with Flutter and communicates with the BANTAI NestJS API.
Authentication and API access are organized using a layered structure:

- `domain/` contains entities and repository contracts.
- `data/` contains models, remote data sources, and repository
  implementations.
- `features/` contains user-facing flows, controllers, screens, and widgets.
- `core/` contains shared networking, configuration, themes, and assets.

See the [README](../README.md) for the current project structure and API
endpoints.

## Development Setup
 
### Prerequisites

- Flutter stable channel with Dart SDK `3.13.4` or compatible.
- Android Studio or Xcode for the platform you are developing on.
- Access to a running BANTAI API instance.

### Configure the App

1. Copy the example environment file:

   ```bash
   copy .env.example .env
   ```

   On macOS or Linux, use `cp .env.example .env`.

2. Set `API_BASE_URL` in `.env` to the API base URL. For an Android emulator,
   the local API is typically available at:

   ```text
   http://10.0.2.2:3000/api/v1
   ```

   Environment files are bundled into the client application, so do not put
   secrets in them.

### Install and Run

From the project directory:

```bash
flutter pub get
flutter run
```

## Making Changes

- Follow the existing Dart and Flutter patterns.
- Keep widgets focused on presentation and user interaction.
- Put API and persistence concerns in the `data/` layer.
- Put shared application behavior in `core/` or the appropriate feature.
- Update the README or other documentation when behavior or setup changes.
- Add or update tests for changed behavior.

## Branches and Commits

Create a branch from `main` using one of these formats:

```text
feature/short-description
fix/short-description
docs/short-description
```

Use clear, imperative commit messages. Conventional Commits are encouraged,
for example:

```text
feat: add rider profile screen
fix: handle expired access tokens
docs: update local setup instructions
```

## Quality Checks

Run the same checks used by CI before opening a pull request:

```bash
flutter analyze
flutter test
flutter build apk --release
```

If you change iOS-specific behavior and have access to macOS, also run:

```bash
flutter build ios --release --no-codesign
```

## Pull Requests

Open a pull request against `main` with:

- A concise title describing the change.
- A description of what changed and why.
- Steps for testing the change.
- Screenshots or recordings for UI changes, when useful.
- Notes about API, environment, or migration changes.

Before requesting review, confirm:

- [ ] I tested the change locally.
- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes.
- [ ] I updated documentation where needed.
- [ ] I did not include secrets or generated build artifacts.

## Code of Conduct

Please follow the repository's [Code of Conduct](CODE_OF_CONDUCT.md). Be
respectful, inclusive, and constructive in issues, reviews, and discussions.
