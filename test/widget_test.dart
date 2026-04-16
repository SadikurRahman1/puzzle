import 'package:flutter_test/flutter_test.dart';

import 'package:puzzle/main.dart';

void main() {
  testWidgets('Home screen shows puzzle size options', (WidgetTester tester) async {
    await tester.pumpWidget(const PuzzleApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('3 x 3'), findsOneWidget);
    expect(find.text('4 x 4'), findsOneWidget);
    expect(find.text('5 x 5'), findsOneWidget);
  });
}
