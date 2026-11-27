# Milestone 1 — Tutor Finder

## 1. What Is Done and What Is Not

### Done
- **Feature-first structure:** Organized under `lib/core/` (`data`, `router`, `theme`, `utils`) and `lib/features/{auth,tutors,bookings,reviews}/{domain,data,presentation}/`.
- **All 7 proposed screens connected via `go_router`:** Sign in / Sign up (`/auth`), Find tutors (`/tutors`), Tutor profile (`/tutors/:tutorId`), Book a session (`/tutors/:tutorId/book`), My bookings (`/bookings`), Edit tutor profile (`/profile/edit` and `/tutors/:tutorId/edit`), and Leave a review (`/bookings/:bookingId/review`), with Material 3 `NavigationBar` bottom navigation.
- **State in Riverpod + `freezed` models:** Immutable `@freezed` models (`AppUser`, `Subject`, `TutorProfile`, `Booking`, `Review`) and in-memory repositories behind interfaces (`AuthRepository`, `TutorRepository`, `AiSuggestionService`, `BookingRepository`, `ReviewRepository`), with state stored in Riverpod providers.
- **Automated tests:** 33 unit and widget tests passing across auth, tutors, fake AI suggestions, reviews, bookings, and navigation.

### Not Done (Planned for Milestone 2 and Final Submission)
- Firebase Auth and Cloud Firestore backend persistence.
- Local persistence (`drift` SQLite cache and `shared_preferences`).
- Real REST web service and live AI suggestion integration with user consent.
- Camera permission handling and profile photo capture.
- GitHub Actions CI, `development`/`production` flavours, and signed release build.

---

## 2. Who Did What (Pull Requests Authored & Reviewed)

| Member | Pull Requests Authored | Pull Requests Reviewed |
|---|---|---|
| **Selamawit Amare** (`selamawit5`) | PR #1 (`setup/init-flutter`), PR #2 (`setup/packages-and-folders`), PR #4 (`feat/bookings`), PR #5 (`feat/app-theme`), PR #10 (`feat/app-router` wiring), PR #11 (`test/bookings`), PR #13 (`test/navigation`), PR #14 (`docs/milestone-1`) | PR #7 (`feat/auth`), PR #8 (`feat/tutors-ui`), PR #12 (`test/auth`) |
| **Melkamu Philipose** (`MelkamuPhilipos`) | PR #3 (`feat/freezed-models`), PR #7 (`feat/auth`), PR #12 (`test/auth`) | PR #6 (`feat/tutors-ai-reviews`), PR #9 (`test/tutors-ai-reviews`), PR #14 (`docs/milestone-1`) |
| **Rediet Assefa** (`redietassefa`) | PR #8 (`feat/tutors-ui`), PR #10 (`feat/app-router` filter sync), PR #13 (`test/navigation`) | PR #4 (`feat/bookings`), PR #11 (`test/bookings`) |
| **Tsegaye Shewamare** (`tse-coder`) | PR #6 (`feat/tutors-ai-reviews`), PR #9 (`test/tutors-ai-reviews`) | PR #3 (`feat/freezed-models`), PR #5 (`feat/app-theme`), PR #10 (`feat/app-router`) |

---

## 3. Group Self-Score (10 Points — Written Before Tagging `m1`)

| Criterion | Score | Evidence |
|---|---|---|
| All proposed screens present and navigable | 3 / 3 | All 7 screens from `PROPOSAL.md` exist and are reachable via `go_router` bottom navigation and parameterized detail routes (`/tutors/:tutorId`, `/tutors/:tutorId/book`, `/bookings/:bookingId/review`). |
| Feature-first structure; state in providers, not widgets | 2 / 2 | Code is organized into `lib/core` and `lib/features/<feature>/{domain,data,presentation}` with `freezed` models, repository interfaces, and Riverpod providers managing application state. |
| Tests present; analyzer and tests clean in the pasted output | 1 / 1 | 33 unit and widget tests pass across all features, and both `flutter analyze --fatal-infos` and `flutter test` pass with zero issues in the output below. |
| Repository hygiene: branches, pull requests, readable history | 1 / 1 | All work was completed on feature and test branches, merged through 14 Pull Requests with descriptive commit messages and peer reviews, with `project.yaml` updated and `proposal` tagged. |
| Individual oral check (recorded per member) | 3 / 3 | All 4 group members walked through the full codebase together and prepared to trace, explain layers, and make live edits across features during the lab oral check. |
| **Total (Self-Score)** | **10 / 10** | |

---

## 4. One Thing Our Group Will Change Before Milestone 2

We will write unit and widget tests inside each feature Pull Request and agree on exact widget constructors and provider interfaces before branching so integration requires fewer last-minute fixes.

---

## 5. Analyzer and Test Output (Run on Tagged Commit)

### `flutter analyze --fatal-infos`
```text
PS C:\Users\hp\mobile-application-development-course\tutor_finder> flutter analyze --fatal-infos
Analyzing tutor_finder...
No issues found! (ran in 4.9s)
flutter test
Text
PS C:\Users\hp\mobile-application-development-course\tutor_finder> flutter test
00:09 +33: All tests passed!