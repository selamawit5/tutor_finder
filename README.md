# Tutor Finder: Tutoring Marketplace

An app that helps students to find and book trusted tutors for their
courses so that they get affordable help.

Group project for the Mobile Application Development course (Flutter).

## Team

| Name | Student ID | GitHub |
|---|---|---|
| Selamawit Amare | UGR/0193/16 | [selamawit5](https://github.com/selamawit5) |
| Rediet Assefa | UGR/0072/16 | [redietassefa](https://github.com/redietassefa) |
| Melkamu Philipose | UGR/1557/16 | [MelkamuPhilipos](https://github.com/MelkamuPhilipos) |
| Tsegaye Shewamare | UGR/2048/16 | [tse-coder](https://github.com/tse-coder) |

## Problem

Students who struggle with a course often do not know who can help them,
and good tutors have no easy way to reach students. Tutor Finder connects
the two in one place.

## Planned features

- Sign up and sign in as a student, parent or tutor
- Search tutors by subject or skill, and filter by grade level
- Tutor profiles: graduated or still learning, school, subjects, free
  times, price and rating
- Book a session at a time the tutor is free
- Tutors accept or refuse requests
- Ratings and reviews after a finished session
- Last tutor list saved on the phone for slow internet
- Camera for the tutor profile photo
- AI tutor suggestions from a short description of the problem

## Status

Milestone 1 is complete: all 7 screens from the proposal are implemented and
navigable via `go_router`, application state is managed in Riverpod providers
with `freezed` models and in-memory repositories behind interfaces, and all
unit and widget tests pass cleanly.

## Setup, architecture and screenshots

### Architecture
The project uses a feature-first layout:
- `lib/core/` — shared seed data (`fake_seed_data.dart`), `go_router` setup (`app_router.dart`), Material 3 theme (`app_theme.dart`), and helpers.
- `lib/features/{auth,tutors,bookings,reviews}/{domain,data,presentation}/` — `freezed` models and repository interfaces (`domain`), in-memory implementations (`data`), and Riverpod providers + screens (`presentation`).

### Run Locally
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-infos
flutter test
flutter run

Course
Mobile Application Development, Flutter 3.47.7.