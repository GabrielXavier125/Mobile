import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/data/locais_exemplo.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/services/local_service.dart';

/// Testa o CRUD do LocalService contra um Firestore em memória.
void main() {
  late FakeFirebaseFirestore firestore;
  late LocalService service;

  const novo = Local(
    id: '',
    nome: 'Padaria Nova',
    categoria: 'Café',
    cidade: 'Jundiaí',
    avaliacao: 4.1,
    distancia: 0.9,
    horario: '06:00 - 20:00',
    descricao: 'Pães artesanais',
    favorito: false,
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = LocalService(firestore: firestore);
  });

  test('T05 — Create: adicionar grava na coleção "locais"', () async {
    final id = await service.adicionar(novo);
    final doc = await firestore.collection('locais').doc(id).get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['nome'], 'Padaria Nova');
  });

  test('T06 — Read: listarLocais emite os documentos', () async {
    await service.adicionar(novo);
    final locais = await service.listarLocais().first;
    expect(locais.single.nome, 'Padaria Nova');
    expect(locais.single.id, isNotEmpty);
  });

  test('T07 — Update: atualizar altera nome e horário', () async {
    final id = await service.adicionar(novo);
    await service.atualizar(novo.copyWith(id: id, nome: 'Padaria Renovada', horario: '07:00 - 21:00'));
    final local = await service.observarLocal(id).first;
    expect(local!.nome, 'Padaria Renovada');
    expect(local.horario, '07:00 - 21:00');
  });

  test('T08 — Delete: excluir remove o documento', () async {
    final id = await service.adicionar(novo);
    await service.excluir(id);
    expect((await firestore.collection('locais').doc(id).get()).exists, isFalse);
    expect(await service.observarLocal(id).first, isNull);
  });

  test('T09 — Favorito: marcar e desmarcar', () async {
    final id = await service.adicionar(novo);
    await service.alterarFavorito(id, true);
    expect((await service.observarLocal(id).first)!.favorito, isTrue);
    await service.alterarFavorito(id, false);
    expect((await service.observarLocal(id).first)!.favorito, isFalse);
  });

  test('popularExemplos cadastra todos os locais de exemplo', () async {
    await service.popularExemplos();
    final locais = await service.listarLocais().first;
    expect(locais.length, locaisExemplo.length);
  });
}
