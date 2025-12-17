# Pro Darts Scorer

A fully functional, offline-first Darts scoring application for Android, built with Flutter.

## Features

- **Game Modes**: X01 (301, 501) with Double In/Out/Master Out, Cricket (Standard & Cut-Throat).
- **Match Flow**: Multi-player (1-5), Leg/Set tracking, Undo functionality.
- **Scoring**: Dart-by-dart input optimized for touch, real-time stats (Average, First 9, MPR).
- **Data Persistence**: Local database (SQLite via Drift) stores players, matches, turns, and stats.
- **Backup/Restore**: Export database to file/Drive and restore (Offline-first architecture).
- **Theming**: Dark mode support.

## Architecture

- **Domain-Driven Design (Simplified)**:
  - `lib/domain`: Core business logic (Scoring Engines) and Entities.
  - `lib/data`: Data persistence (Drift tables) and Repositories.
  - `lib/presentation`: Flutter UI and Riverpod State Management.
- **State Management**: `flutter_riverpod` handles the active match state and dependency injection.
- **Database**: `drift` for SQLite abstraction.

## Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Android Toolchain

## Getting Started

1.  **Clone/Open the project**:
    Navigate to the `darts_app` directory.

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate Code** (Crucial for Drift):
    Since this project uses `drift` and `json_serializable` (via manual or generated logic), you must run the build runner to generate the database code (`database.g.dart`).
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
    *Note: The codebase provided includes manual mocks or setup where possible, but Drift mandates code generation for the `AppDatabase` class.*

4.  **Run the App**:
    ```bash
    flutter run
    ```

## Running Tests

Unit tests are included for the scoring logic.

```bash
flutter test
```

Files:
- `test/scoring/x01_test.dart`: Verifies 301/501 rules, bust logic, and win conditions.
- `test/scoring/cricket_test.dart`: Verifies accumulation of marks and scoring points.

## Data Schema

The database `darts_app.sqlite` contains:
- `Players`: Profiles.
- `Matches`: Match settings/metadata.
- `MatchPlayers`: Join table for players in a match.
- `Turns`: Granular dart-by-dart history.
- `Locations`: Match venues.

## Backup & Restore

Navigate to **Home > Settings / Backup**.
- **Export**: Uses the system share sheet to send the `.sqlite` file to Google Drive, Email, or save to local storage.
- **Import**: Picks a `.sqlite` file and replaces the current database. *Warning: This overwrites local data.*

## Design Decisions

- **Scoring Engine**: Separated from UI to allow easier testing and future "Simulate Match" features.
- **Turn History**: We store every turn to allow complete replay ability or "Match Resume".
- **Validation**: X01 Bust checks happen in the Engine layer, preventing invalid states in the DB.

## Building for Android

To create an APK for testing on your physical device:

1.  **Generate Code**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

2.  **Build the APK**:
    ```bash
    flutter build apk --release
    ```

3.  **Locate the APK**:
    The generated file will be at:
    `build/app/outputs/flutter-apk/app-release.apk`

4.  **Install**:
    - Connect your phone via USB (ensure USB Debugging is on).
    - Run: `flutter install` 
    - OR copy the APK file to your phone and open it.
