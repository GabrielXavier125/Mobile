import 'package:flutter_test/flutter_test.dart';

import 'package:atividade/main.dart';

void main() {
  testWidgets('Lista de contatos e navegação para detalhes', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lista de contatos'), findsOneWidget);
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Bruno Costa'), findsOneWidget);
    expect(find.text('Carla Mendes'), findsOneWidget);

    await tester.tap(find.text('Ana Silva'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do contato'), findsOneWidget);
    expect(find.text('(11) 98765-4321'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Lista de contatos'), findsOneWidget);
  });
}
