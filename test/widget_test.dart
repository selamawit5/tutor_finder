import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_finder/app.dart';

void main() {
  testWidgets('TutorFinderApp renders sign in screen initially', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TutorFinderApp()));
    await tester.pumpAndSettle();

    expect(find.text('Tutor Finder'), findsOneWidget);
  });
}
