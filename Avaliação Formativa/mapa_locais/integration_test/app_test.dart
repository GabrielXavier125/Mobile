// Teste de integração: roda o app no dispositivo/emulador conectado ao
// Cloud Firestore real e percorre os testes obrigatórios T01–T10.
//
//   flutter test integration_test -d emulator-5554
//
// O teste cria, edita e exclui um local próprio ("Local Teste Integração"),
// sem alterar os demais documentos da coleção.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mapa_locais/app.dart';
import 'package:mapa_locais/firebase_options.dart';
import 'package:mapa_locais/main.dart' show usarEmulador;
import 'package:mapa_locais/services/local_service.dart';

const nomeTeste = 'Local Teste Integração';
const nomeEditado = 'Local Teste Editado';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late LocalService service;

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (usarEmulador) FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
    service = LocalService();
    // Remove sobras de execuções anteriores.
    for (final local in await service.listarLocais().first) {
      if (local.nome == nomeTeste || local.nome == nomeEditado) await service.excluir(local.id);
    }
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsWidgets);
  }

  Future<void> tocar(WidgetTester tester, Finder finder) async {
    await esperar(tester, finder);
    // Fecha mensagens (SnackBar) que poderiam cobrir o botão.
    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  testWidgets('T01–T10 no Firestore real', (tester) async {
    await tester.pumpWidget(MinhaAplicacao(service: service));

    // T01 — Conexão: dados do Firestore aparecem no mapa.
    await esperar(tester, find.textContaining('Ver resultados ('));
    final locais = await service.listarLocais().first;
    expect(locais.length, greaterThanOrEqualTo(10), reason: 'checklist: ao menos 10 locais');

    // T03 — Cidade: selecionar Campinas.
    await tocar(tester, find.byKey(const Key('seletor_cidade')));
    await tocar(tester, find.text('Campinas'));
    expect(find.text('Campinas'), findsOneWidget);

    // T02 — Pesquisa por "Academia".
    await tester.enterText(find.byKey(const Key('campo_pesquisa_mapa')), 'Academia');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await esperar(tester, find.text('Academia Power Fit'));
    expect(find.text('Café do Largo'), findsNothing);

    // T04 — Filtro por categoria.
    await tester.enterText(find.byKey(const Key('campo_pesquisa')), '');
    await tocar(tester, find.text('Cafés'));
    await esperar(tester, find.text('Café do Largo'));
    expect(find.text('Academia Power Fit'), findsNothing);
    await tocar(tester, find.text('Todos'));

    // T05 — Create.
    await tocar(tester, find.byKey(const Key('botao_cadastrar')));
    await tester.enterText(find.byKey(const Key('campo_nome')), nomeTeste);
    await tester.enterText(find.byKey(const Key('campo_avaliacao')), '4,2');
    await tester.enterText(find.byKey(const Key('campo_distancia')), '0,1');
    await tester.enterText(find.byKey(const Key('campo_descricao')), 'Criado pelo teste de integração');
    await tocar(tester, find.byKey(const Key('botao_salvar')));
    await esperar(tester, find.textContaining('cadastrado com sucesso'));
    final criados = await FirebaseFirestore.instance
        .collection('locais')
        .where('nome', isEqualTo: nomeTeste)
        .get();
    expect(criados.docs, hasLength(1), reason: 'documento gravado no Firestore');

    // T06 — Read: sair e voltar para a tela; o registro continua lá.
    await tocar(tester, find.byTooltip('Voltar'));
    await tocar(tester, find.byKey(const Key('botao_ver_resultados')));
    await esperar(tester, find.text(nomeTeste));

    // T10/T09 — Abrir detalhes e marcar/desmarcar favorito.
    await tocar(tester, find.text(nomeTeste));
    await esperar(tester, find.text('Sobre'));
    await tocar(tester, find.byKey(const Key('botao_favorito')));
    await esperar(tester, find.byTooltip('Remover dos favoritos'));
    expect((await criados.docs.single.reference.get()).data()!['favorito'], isTrue);
    await tocar(tester, find.byKey(const Key('botao_favorito')));
    await esperar(tester, find.byTooltip('Adicionar aos favoritos'));
    expect((await criados.docs.single.reference.get()).data()!['favorito'], isFalse);
    await tocar(tester, find.byTooltip('Voltar'));

    // T07 — Update: editar nome e horário.
    final card = find.ancestor(of: find.text(nomeTeste), matching: find.byType(Card));
    await tocar(tester, find.descendant(of: card, matching: find.byTooltip('Opções')));
    await tocar(tester, find.text('Editar'));
    await tester.enterText(find.byKey(const Key('campo_nome')), nomeEditado);
    await tester.enterText(find.byKey(const Key('campo_horario')), '09:00 - 17:00');
    await tocar(tester, find.byKey(const Key('botao_salvar')));
    await esperar(tester, find.text(nomeEditado));
    final editado = (await criados.docs.single.reference.get()).data()!;
    expect(editado['nome'], nomeEditado);
    expect(editado['horario'], '09:00 - 17:00');

    // T08 — Delete com confirmação.
    final cardEditado = find.ancestor(of: find.text(nomeEditado), matching: find.byType(Card));
    await tocar(tester, find.descendant(of: cardEditado, matching: find.byTooltip('Opções')));
    await tocar(tester, find.text('Excluir'));
    expect(find.text('Excluir local?'), findsOneWidget);
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));
    await esperar(tester, find.textContaining('excluído'));
    expect(find.text(nomeEditado), findsNothing);
    expect((await criados.docs.single.reference.get()).exists, isFalse);

    // T10 — Navegação de volta ao mapa.
    await tocar(tester, find.byTooltip('Voltar'));
    expect(find.text('Cidade selecionada'), findsOneWidget);
  });
}
