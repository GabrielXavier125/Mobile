import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/locais_exemplo.dart';
import '../models/local.dart';

/// Camada de acesso ao Cloud Firestore. As telas nunca falam com o banco
/// diretamente: todas as operações de CRUD passam por esta classe.
class LocalService {
  LocalService({FirebaseFirestore? firestore})
      : locais = (firestore ?? FirebaseFirestore.instance).collection('locais');

  final CollectionReference<Map<String, dynamic>> locais;

  /// READ — lista todos os locais em tempo real (snapshots).
  Stream<List<Local>> listarLocais() {
    return locais.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Local.fromMap(doc.id, doc.data())).toList();
    });
  }

  /// READ — acompanha um único documento; emite null se ele for excluído.
  Stream<Local?> observarLocal(String id) {
    return locais.doc(id).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? null : Local.fromMap(doc.id, data);
    });
  }

  /// CREATE — cria um documento com ID gerado pelo Firestore.
  Future<String> adicionar(Local local) async {
    final ref = await locais.add(local.toMap());
    return ref.id;
  }

  /// UPDATE — altera os dados de um documento existente.
  Future<void> atualizar(Local local) async {
    await locais.doc(local.id).update(local.toMap());
  }

  /// DELETE — exclui um documento.
  Future<void> excluir(String id) async {
    await locais.doc(id).delete();
  }

  /// UPDATE parcial — altera somente o campo `favorito`.
  Future<void> alterarFavorito(String id, bool favorito) async {
    await locais.doc(id).update({'favorito': favorito});
  }

  /// Cadastra os locais de exemplo de uma só vez (batch).
  Future<void> popularExemplos() async {
    final batch = locais.firestore.batch();
    for (final local in locaisExemplo) {
      batch.set(locais.doc(), local.toMap());
    }
    await batch.commit();
  }
}
