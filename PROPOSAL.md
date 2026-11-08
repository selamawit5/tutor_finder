# Project proposal

## 1. Tutor Finder: Tutoring Marketplace

An app that helps students and parents to find and book trusted tutors for school subjects and other skills so that students get good help at a fair price.

## 2. Group

| Name | Role |
|---|---|
| Selamawit Amare | Team lead and Test |
| Rediet Assefa | UI and navigation |
| Melkamu Philipose | Firebase and local storage |
| Tsegaye Shewamare | REST service and AI feature |

## 3. The problem

Many students find some subjects very hard, and they want a tutor to get better grades. But they do not know who can teach them. Today they ask friends and family, or they look for a notice on a board. Parents have the same problem. They want a good tutor for their child, but they cannot easily see who the tutor is, what the tutor studied, when the tutor is free and how much the tutor asks. Good tutors also have no easy way to show themselves to the students and parents who need them. The problem is not only about school subjects. Many people also look for help to learn other skills and courses, like languages, computer skills or music.

We talked to Semhal Dawit a Grade 11 natural science student at Aygoda school. She wants to get good grades in physics and chemistry, and she needs a tutor to do that. She told us she wants a platform where she can find the best tutors and see their profiles. She wants to know if a tutor has already graduated or is still learning, when the tutor is available and which subjects the tutor teaches. This is what we will build.

A mobile app is a good solution because students and parents use their phones every day. A tutor's free time changes often, so a booking request must reach the tutor fast. The app can also keep the last tutor list on the phone, so it still opens when the internet is slow.

## 4. Users

**1, Student.** A school or university student who wants help in a subject or wants to learn a skill. The student needs to search tutors, read their profiles and ask for a session. The student will use the app a few times a week, and more before exams.

**2, Parent.** A parent who looks for a tutor for his or her child. The parent needs to see who the tutor is, what the tutor studied, the price and the free times, and to book a session for the child. The parent will use the app a few times a month.

**3, Tutor.** A graduate or a student who can teach a subject or a skill. The tutor needs to make a profile that shows if he or she has graduated or is still learning, the subjects and skills, the price and the free times. The tutor also needs to accept or refuse requests. The tutor will open the app a few times a week.

## 5. User stories

1. As a student, parent or tutor, I want to sign up and sign in so that my profile and bookings are saved. (**must**)
2. As a student or parent, I want to search tutors by subject or skill, and filter by grade level, so that I find the right tutor. When the internet is slow, I want to still see the last list. (**must**)
3. As a student or parent, I want to open a tutor profile and see if the tutor has graduated or is still learning, the school, the subjects, the free times, the price and the rating, so that I can decide who to book. (**must**)
4. As a student or parent, I want to ask for a session at a time the tutor is free so that the student gets help before the exam. (**must**)
5. As a tutor, I want to make and change my profile, with my education, subjects, skills, price and free times, so that students and parents can find me. (**must**)
6. As a tutor, I want to accept or refuse booking requests so that I control my time. (**must**)
7. As a student or parent, I want to give a rating and a short review after a finished session so that other people can trust the ratings. (**should**)
8. As a student, I want to write my problem in one sentence and get tutor suggestions so that I find a good match faster. (**should**)

## 6. Screens

| Screen | Purpose | User stories |
|---|---|---|
| Sign in / Sign up | Make an account, choose student, parent or tutor, and sign in | 1 |
| Find tutors | Search box, filters for subject, skill and grade level, list of tutors, box to describe the problem | 2, 8 |
| Tutor profile | Photo, graduated or still learning, school, subjects and skills, free times, price, reviews | 3 |
| Book a session | Choose subject and a free time, send the request | 4 |
| My bookings | Student or parent sees the request status and leaves a review. Tutor accepts or refuses | 4, 6, 7 |
| Edit tutor profile | Tutor changes education, subjects, skills, price, free times and photo | 5 |
| Leave a review | Stars and a short comment after a finished session | 7 |

## 7. Data model

```
A, User: id, name, email, role (student, parent or tutor), photoUrl
B, TutorProfile: userId, bio, educationStatus (graduated or learning), school, fieldOfStudy,
   subjectIds, pricePerHour, availability, ratingAverage, ratingCount
C, Subject: id, name, type (school subject or skill), gradeLevel
D, Booking: id, requestedById, studentName, tutorId, subjectId, start, durationMinutes,
   status (pending, accepted, declined, completed, cancelled), createdAt
E, Review: id, bookingId, reviewerId, tutorId, rating (1 to 5), comment, createdAt
F. CachedTutor: tutorId, data, savedAt
```

A user with the role tutor has one tutor profile. A booking connects one tutor, one subject and the student or parent who asked for it. A review belongs to one finished booking, so a person can rate a tutor only once for each session.

## 8. Data sources

- **On the phone:** we use drift (SQLite) to keep the last tutor list, so the app works when the internet is slow or off. We use shared_preferences for small settings, like the last filter.
- **REST web service:** we will build a small service. It gives the list of subjects and skills with their grade levels, and it receives the AI suggestion request (see section 9). The app talks to it through a repository interface. For tests we use a fake version.
- **Firebase:** Firebase Auth for sign in. Cloud Firestore for tutor profiles, bookings and reviews. We will write security rules so that a user can change only his or her own profile and bookings. If we have time, Firebase Storage for profile photos.

In the demo we will use fake tutors and fake bookings. We will not store real personal data.

## 9. Device feature and AI feature

**Device feature: camera.** User story 5 needs it, so a tutor can take a profile photo. The app asks for the camera permission only when the tutor taps "Take photo". If the tutor says no, the app explains why it needs the camera and offers two other choices: pick a photo from the gallery, or use the first letters of the name. We will handle and test every permission result.

**AI feature: tutor suggestions.** User story 8 needs it. The student writes a short problem, for example "I do not understand Newton's laws in physics". The AI suggests the right subject and the best tutors from the list. We send only this text and the list of subject names, through our REST service, to an AI model. We have not chosen the provider yet. We send no name, email or other personal data. The feature sits behind an interface. The app asks for consent before the first use and shows that the result is an AI suggestion. If the AI does not work, or the user says no, normal search still works.

## 10. Risks

| Risk | Likelihood | Plan |
|---|---|---|
| A tutor says something false about his or her education | Medium | The profile shows that education is told by the tutor. Only people with a finished booking can review. We add a report button if we have time. |
| Safety of students, who are often young | Medium | We do not show phone numbers or home addresses. A parent can book for a child. Bookings are requests only, and the app asks to meet in a safe place. |
| The project becomes too big (chat, payments) | Medium | No chat and no payments. The price is only information. A booking is a simple request with a status. |
| The AI service is not available, costs money or gives bad answers | Medium | We keep the AI behind an interface, use a free option or simple rules, and normal search always works. |
| Slow internet makes downloads and Firebase work hard | High | We save data on the phone, use the Firebase emulators for development, and start big downloads early. |

## 11. Milestone plan

- **Milestone 1 (week 6):** all screens with navigation (go_router) and state in memory (Riverpod, freezed models), using fake data. Stories 1 to 6 work with fake data. Stories 7 and 8 have their screens.
- **Milestone 2 (week 10):** real data. Firebase Auth and Firestore for stories 1 to 7, drift for the offline list in story 2, the REST service for subjects and skills, and unit and widget tests running in GitHub Actions.
- **Final submission (week 14):** camera (story 5) with all permission results, AI suggestions (story 8) with consent, an integration test, development and production flavours, a signed release build, and the README, AI_USAGE.md, PRIVACY.md and USER_TEST.md.

## 12. AI-use plan

We plan to use AI assistants to learn (for example, to understand Riverpod or Firestore rules), to write simple boilerplate, to suggest tests and to review code. We will understand, run and test any AI-written code before we merge it. We will write all AI use in AI_USAGE.md, as syllabus/policies.md asks.
