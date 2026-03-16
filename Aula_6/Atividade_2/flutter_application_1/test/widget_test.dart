import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('temperature controls update the displayed value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TemperaturaApp()));

    expect(find.text('22 °C'), findsOneWidget);
    expect(find.text('Confortavel'), findsOneWidget);

    await tester.tap(find.text('Aumentar'));
    await tester.pump();

    expect(find.text('23 °C'), findsOneWidget);

    await tester.tap(find.text('Diminuir'));
    await tester.pump();

    expect(find.text('22 °C'), findsOneWidget);
  });
}
