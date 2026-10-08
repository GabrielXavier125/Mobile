import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/models/local.dart';

void main() {
  group('Local (Model)', () {
    test('fromMap converte os tipos do Firestore', () {
      final local = Local.fromMap('abc', {
        'nome': 'Academia Fitness',
        'categoria': 'Academia',
        'cidade': 'São Paulo',
        'avaliacao': 5, // int no Firestore deve virar double
        'distancia': 1.2,
        'horario': '06:00 - 22:00',
        'descricao': 'Completa',
        'favorito': true,
        'latitude': -23.5,
        'longitude': -46.6,
      });

      expect(local.id, 'abc');
      expect(local.nome, 'Academia Fitness');
      expect(local.avaliacao, 5.0);
      expect(local.distancia, 1.2);
      expect(local.favorito, isTrue);
      expect(local.temCoordenadas, isTrue);
    });

    test('fromMap usa valores padrão quando campos estão ausentes', () {
      final local = Local.fromMap('x', {});
      expect(local.nome, '');
      expect(local.avaliacao, 0);
      expect(local.favorito, isFalse);
      expect(local.temCoordenadas, isFalse);
    });

    test('toMap e fromMap são simétricos', () {
      const original = Local(
        id: 'id1',
        nome: 'Café do Largo',
        categoria: 'Café',
        cidade: 'Campinas',
        avaliacao: 4.8,
        distancia: 0.5,
        horario: '07:00 - 19:00',
        descricao: 'Cafés especiais',
        favorito: true,
        endereco: 'Largo do Rosário, 50',
        telefone: '(19) 3200-2006',
        latitude: -22.9,
        longitude: -47.06,
      );
      final copia = Local.fromMap('id1', original.toMap());

      expect(copia.toMap(), original.toMap());
      expect(original.toMap().containsKey('id'), isFalse, reason: 'o ID é o nome do documento');
    });
  });
}
