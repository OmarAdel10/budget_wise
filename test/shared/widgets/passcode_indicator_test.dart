import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/widgets/passcode_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasscodeIndicator Tests', () {
    testWidgets('Displays the correct number of dots', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PasscodeIndicator(inputLength: 0)),
        ),
      );

      expect(find.byType(Container), findsNWidgets(4));
    });

    testWidgets('Fills the correct number of dots based on inputLength', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PasscodeIndicator(inputLength: 2)),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      int filledCount = 0;

      for (var container in containers) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.color == AppColors.primaryAccent) {
          filledCount++;
        }
      }

      expect(filledCount, 2);
    });

    testWidgets('All dots are empty when inputLength is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PasscodeIndicator(inputLength: 0)),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      for (var container in containers) {
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNull);
      }
    });

    testWidgets('All dots are filled when inputLength is 4', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PasscodeIndicator(inputLength: 4)),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      for (var container in containers) {
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.primaryAccent);
      }
    });
  });
}
