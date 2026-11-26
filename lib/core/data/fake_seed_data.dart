import 'package:tutor_finder/features/auth/domain/app_user.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/reviews/domain/review.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

final List<AppUser> seedUsers = [
  const AppUser(
    id: 'u1',
    name: 'Semhal Dawit',
    email: 'semhal@example.com',
    role: UserRole.student,
  ),
  const AppUser(
    id: 'u2',
    name: 'Dawit Tesfaye',
    email: 'dawit@example.com',
    role: UserRole.parent,
  ),
  const AppUser(
    id: 't1',
    name: 'Abebe Kebede',
    email: 'abebe@example.com',
    role: UserRole.tutor,
  ),
  const AppUser(
    id: 't2',
    name: 'Hanna Mekonnen',
    email: 'hanna@example.com',
    role: UserRole.tutor,
  ),
  const AppUser(
    id: 't3',
    name: 'Yonas Bekele',
    email: 'yonas@example.com',
    role: UserRole.tutor,
  ),
];

final List<Subject> seedSubjects = [
  const Subject(
    id: 's1',
    name: 'Physics',
    type: SubjectType.schoolSubject,
    gradeLevel: 'Grade 11-12',
  ),
  const Subject(
    id: 's2',
    name: 'Chemistry',
    type: SubjectType.schoolSubject,
    gradeLevel: 'Grade 11-12',
  ),
  const Subject(
    id: 's3',
    name: 'Mathematics',
    type: SubjectType.schoolSubject,
    gradeLevel: 'Grade 9-12',
  ),
  const Subject(
    id: 's4',
    name: 'English Speaking',
    type: SubjectType.skill,
    gradeLevel: 'All Levels',
  ),
  const Subject(
    id: 's5',
    name: 'Python Programming',
    type: SubjectType.skill,
    gradeLevel: 'Beginner',
  ),
];

final List<TutorProfile> seedTutors = [
  const TutorProfile(
    userId: 't1',
    name: 'Abebe Kebede',
    bio: 'Physics graduate helping Grade 11 and 12 students master mechanics and exam questions.',
    educationStatus: EducationStatus.graduated,
    school: 'Addis Ababa University',
    fieldOfStudy: 'BSc in Physics',
    subjectIds: ['s1', 's3'],
    pricePerHour: 250,
    availability: ['Mon 16:00', 'Wed 16:00', 'Sat 10:00'],
    ratingAverage: 4.8,
    ratingCount: 12,
  ),
  const TutorProfile(
    userId: 't2',
    name: 'Hanna Mekonnen',
    bio: 'Final-year Chemical Engineering student who loves making chemistry simple and clear.',
    educationStatus: EducationStatus.learning,
    school: 'AAiT',
    fieldOfStudy: 'Chemical Engineering',
    subjectIds: ['s2', 's1'],
    pricePerHour: 200,
    availability: ['Tue 17:00', 'Thu 17:00', 'Sun 14:00'],
    ratingAverage: 4.6,
    ratingCount: 8,
  ),
  const TutorProfile(
    userId: 't3',
    name: 'Yonas Bekele',
    bio: 'Software engineer teaching Python basics and fluent English communication.',
    educationStatus: EducationStatus.graduated,
    school: 'Bahir Dar University',
    fieldOfStudy: 'Computer Science',
    subjectIds: ['s4', 's5'],
    pricePerHour: 300,
    availability: ['Fri 18:00', 'Sat 15:00'],
    ratingAverage: 4.9,
    ratingCount: 15,
  ),
];

final List<Booking> seedBookings = [
  Booking(
    id: 'b1',
    requestedById: 'u1',
    studentName: 'Semhal Dawit',
    tutorId: 't1',
    subjectId: 's1',
    start: DateTime(2026, 11, 28, 16, 0),
    durationMinutes: 60,
    status: BookingStatus.pending,
    createdAt: DateTime(2026, 11, 25, 10, 0),
  ),
  Booking(
    id: 'b2',
    requestedById: 'u1',
    studentName: 'Semhal Dawit',
    tutorId: 't2',
    subjectId: 's2',
    start: DateTime(2026, 11, 22, 17, 0),
    durationMinutes: 60,
    status: BookingStatus.completed,
    createdAt: DateTime(2026, 11, 20, 9, 30),
  ),
];

final List<Review> seedReviews = [
  Review(
    id: 'r1',
    bookingId: 'b2',
    reviewerId: 'u1',
    reviewerName: 'Semhal Dawit',
    tutorId: 't2',
    rating: 5,
    comment: 'Explained stoichiometry very clearly before my quiz!',
    createdAt: DateTime(2026, 11, 22, 18, 30),
  ),
];
