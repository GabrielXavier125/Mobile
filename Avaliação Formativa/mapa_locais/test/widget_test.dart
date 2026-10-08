import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/app.dart';
import 'package:mapa_locais/data/locais_exemplo.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/services/local_service.dart';

/// Serviço que sempre falha, para simular erro de conexão (T11).
class _ServicoComErro extends LocalService {
  _ServicoComErro() : super(firestore: FakeFirebaseFirestore());

  @override
  Stream<List<Local>> listarLocais() => Stream.error(Exception('sem conexão'));
}

void main() {
  late FakeFirebaseFirestore firestore;
  late LocalService service;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    service = LocalService(firestore: firestore);
    await service.popularExemplos();
  });

  Future<void> abrirApp(WidgetTester tester, {LocalService? servico}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MinhaAplicacao(service: servico ?? service, carregarTilesMapa: false));
    await tester.pumpAndSettle();
  }

  Future<void> abrirResultados(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('botao_ver_resultados')));
    await tester.pumpAndSettle();
  }

  Finder marcadores() => find.byWidgetPredicate(
      (w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('marcador_'));

  testWidgets('T01 — mapa mostra a cidade e os marcadores vindos do banco', (tester) async {
    await abrirApp(tester);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('Buscar locais, endereços ou categorias...'), findsOneWidget);
    expect(marcadores(), findsNWidgets(8));
    expect(find.text('Ver resultados (8)'), findsOneWidget);
  });

  testWidgets('T03 — selecionar Campinas troca os marcadores', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.byKey(const Key('seletor_cidade')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campinas'));
    await tester.pumpAndSettle();

    expect(find.text('Campinas'), findsOneWidget);
    expect(marcadores(), findsNWidgets(6));
  });

  testWidgets('T02/T04 — pesquisa e filtro por categoria nos resultados', (tester) async {
    await abrirApp(tester);
    await tester.enterText(find.byKey(const Key('campo_pesquisa_mapa')), 'Academia');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Resultados'), findsOneWidget);
    expect(find.text('5 locais encontrados'), findsOneWidget);
    expect(find.text('Academia Fitness'), findsOneWidget);
    expect(find.text('Cantina Bella Vista'), findsNothing);

    await tester.enterText(find.byKey(const Key('campo_pesquisa')), '');
    await tester.ensureVisible(find.text('Restaurantes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurantes'));
    await tester.pumpAndSettle();
    expect(find.text('Cantina Bella Vista'), findsOneWidget);
    expect(find.text('Academia Fitness'), findsNothing);
  });

  testWidgets('T10 — navegação mapa → resultados → detalhes → voltar', (tester) async {
    await abrirApp(tester);
    await abrirResultados(tester);
    await tester.tap(find.text('Academia Fitness'));
    await tester.pumpAndSettle();

    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('Rua Augusta, 1500 - Consolação'), findsOneWidget);
    expect(find.text('Ver no mapa'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Resultados'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Cidade selecionada'), findsOneWidget);
  });

  testWidgets('"Ver no mapa" volta ao mapa com o local em destaque', (tester) async {
    await abrirApp(tester);
    await abrirResultados(tester);
    await tester.tap(find.byKey(const Key('filtro_cidade')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas as cidades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Café do Largo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('botao_ver_no_mapa')));
    await tester.pumpAndSettle();

    expect(find.text('Cidade selecionada'), findsOneWidget);
    expect(find.text('Campinas'), findsOneWidget);
    expect(find.text('Café do Largo'), findsWidgets); // rótulo + prévia
    expect(find.text('Ver detalhes'), findsOneWidget);
  });

  testWidgets('T05 — cadastrar local pelo formulário', (tester) async {
    await abrirApp(tester);
    await abrirResultados(tester);
    await tester.tap(find.byKey(const Key('botao_cadastrar')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsWidgets, reason: 'valida campos vazios');

    await tester.enterText(find.byKey(const Key('campo_nome')), 'Academia Teste');
    await tester.enterText(find.byKey(const Key('campo_avaliacao')), '4,5');
    await tester.enterText(find.byKey(const Key('campo_distancia')), '0,3');
    await tester.enterText(find.byKey(const Key('campo_descricao')), 'Criada no teste');
    await tester.ensureVisible(find.byKey(const Key('botao_salvar')));
    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pumpAndSettle();

    expect(find.textContaining('cadastrado com sucesso'), findsOneWidget);
    expect(find.text('Academia Teste'), findsOneWidget);
    final docs = await firestore.collection('locais').where('nome', isEqualTo: 'Academia Teste').get();
    expect(docs.docs.single.data()['cidade'], 'São Paulo');
    expect(docs.docs.single.data()['latitude'], isNotNull);
  });

  testWidgets('T07 — editar local', (tester) async {
    await abrirApp(tester);
    await abrirResultados(tester);
    await tester.tap(find.byTooltip('Opções').first); // Farmácia Vida & Saúde (mais próxima)
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar local'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('campo_horario')), '08:00 - 20:00');
    await tester.ensureVisible(find.byKey(const Key('botao_salvar')));
    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pumpAndSettle();

    expect(find.textContaining('atualizado com sucesso'), findsOneWidget);
    final docs = await firestore.collection('locais').where('nome', isEqualTo: 'Farmácia Vida & Saúde').get();
    expect(docs.docs.single.data()['horario'], '08:00 - 20:00');
  });

  testWidgets('T08 — excluir pede confirmação', (tester) async {
    await abrirApp(tester);
    await abrirResultados(tester);
    expect(find.text('Farmácia Vida & Saúde'), findsOneWidget);

    await tester.tap(find.byTooltip('Opções').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir local?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Farmácia Vida & Saúde'), findsOneWidget, reason: 'cancelar não exclui');

    await tester.tap(find.byTooltip('Opções').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('excluído'), findsOneWidget);
    expect(find.text('Farmácia Vida & Saúde'), findsNothing);
    expect((await firestore.collection('locais').get()).docs.length, locaisExemplo.length - 1);
  });

  testWidgets('T09 — favoritar e desfavoritar na tela de detalhes', (tester) async {
    await abrirApp(tester);
    await abrirResultados(tester);
    await tester.tap(find.text('Academia Fitness'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsWidgets);
    await tester.tap(find.byKey(const Key('botao_favorito')));
    await tester.pumpAndSettle();
    expect(find.text('Adicionado aos favoritos!'), findsOneWidget);
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);

    await tester.tap(find.byKey(const Key('botao_favorito')));
    await tester.pumpAndSettle();
    expect(find.text('Removido dos favoritos.'), findsOneWidget);
    expect(find.byTooltip('Adicionar aos favoritos'), findsOneWidget);
  });

  testWidgets('aba Favoritos lista apenas os favoritos', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('2 locais encontrados'), findsOneWidget);
    expect(find.text('Café do Largo'), findsOneWidget);
  });

  testWidgets('T11 — banco vazio mostra mensagem e permite carregar exemplos', (tester) async {
    await abrirApp(tester, servico: LocalService(firestore: FakeFirebaseFirestore()));
    await abrirResultados(tester);
    expect(find.text('Nenhum local cadastrado.'), findsOneWidget);

    await tester.tap(find.text('Cadastrar locais de exemplo'));
    await tester.pumpAndSettle();
    expect(find.text('Locais de exemplo cadastrados!'), findsOneWidget);
    expect(find.text('Farmácia Vida & Saúde'), findsOneWidget);
  });

  testWidgets('T11 — erro de conexão mostra mensagem', (tester) async {
    await abrirApp(tester, servico: _ServicoComErro());
    expect(find.text('Erro ao carregar os locais do Firestore.'), findsOneWidget);
    await abrirResultados(tester);
    expect(find.text('Erro ao carregar os locais.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
