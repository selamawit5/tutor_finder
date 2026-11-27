# AI Usage — Tutor Finder (Milestone 1)

## Group
- **Selamawit Amare** (`selamawit5`)
- **Rediet Assefa** (`redietassefa`)
- **Melkamu Philipose** (`MelkamuPhilipos`)
- **Tsegaye Shewamare** (`tse-coder`)

## AI Tools Used
- **AI coding and study assistant:** Used as a learning, boilerplate, testing, and code-review aid during Milestone 1.

## What AI Was Used For
1. **Understanding frameworks and architecture:**
   - Explaining feature-first folder structure (`lib/core` and `lib/features/<feature>/{domain,data,presentation}`).
   - Understanding Riverpod 3 (`NotifierProvider`, `AsyncNotifierProvider`), `freezed` 4 (`abstract class` models), and `go_router` (`StatefulShellRoute.indexedStack` and parameterized routes).
2. **Boilerplate and UI drafting:**
   - Drafting initial templates for the `@freezed` domain models, `fake_seed_data.dart`, shared Material 3 `AppTheme`, `BookingRepository` / `InMemoryBookingRepository`, booking screens (`BookSessionScreen`, `MyBookingsScreen`), and `app_router.dart`.
3. **Writing and debugging tests:**
   
4. **Code review and documentation:**


## How We Verified and Controlled All AI-Assisted Code
- Every group member read, edited, ran, and understood all code before committing or merging.
- Ran `dart run build_runner build --delete-conflicting-outputs`, `dart format lib test`, `flutter analyze --fatal-infos` (0 issues), and `flutter test` (33 passing tests) locally.
- Every change was submitted on feature/test branches and reviewed through GitHub Pull Requests before merging into `main`.