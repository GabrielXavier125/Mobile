import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/data/locais_exemplo.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/utils/filtros.dart';
import 'package:mapa_locais/utils/formatos.dart';

void main() {
  final locais = [
    for (var i = 0; i < locaisExemplo.length; i++) locaisExemplo[i].copyWith(id: 'doc$i'),
  ];

  group('filtrarLocais', () {
    test('T02 — pesquisa "Academia" encontra pelo nome ou categoria', () {
      final r = filtrarLocais(locais, 'Academia', 'Todas', 'Todos');
      expect(r, isNotEmpty);
      expect(r.every((l) => l.categoria == 'Academia' || l.nome.contains('Academia')), isTrue);
    });

    test('pesquisa ignora maiúsculas e acentos', () {
      final r = filtrarLocais(locais, 'FARMACIA', 'Todas', 'Todos');
      expect(r.map((l) => l.categoria).toSet(), {'Farmácia'});
    });

    test('T03 — filtro por cidade (Campinas)', () {
      final r = filtrarLocais(locais, '', 'Campinas', 'Todos');
      expect(r, isNotEmpty);
      expect(r.every((l) => l.cidade == 'Campinas'), isTrue);
    });

    test('T04 — filtro por categoria', () {
      final r = filtrarLocais(locais, '', 'Todas', 'Hospital');
      expect(r.length, 3);
      expect(r.every((l) => l.categoria == 'Hospital'), isTrue);
    });

    test('combina cidade, categoria e favoritos', () {
      expect(filtrarLocais(locais, '', 'Jundiaí', 'Academia').length, 2);
      final favoritos = filtrarLocais(locais, '', 'Todas', 'Todos', apenasFavoritos: true);
      expect(favoritos.every((l) => l.favorito), isTrue);
      expect(favoritos, isNotEmpty);
    });

    test('ordena do mais próximo para o mais distante', () {
      final r = filtrarLocais(locais, '', 'São Paulo', 'Todos');
      final distancias = r.map((l) => l.distancia).toList();
      expect(distancias, [...distancias]..sort());
    });

    test('lista vazia quando nada corresponde', () {
      expect(filtrarLocais(locais, 'xyz inexistente', 'Todas', 'Todos'), isEmpty);
      expect(filtrarLocais(<Local>[], '', 'Todas', 'Todos'), isEmpty);
    });
  });

  group('dados de exemplo', () {
    test('ao menos 10 locais e 5 por cidade (marcadores no mapa)', () {
      expect(locaisExemplo.length, greaterThanOrEqualTo(10));
      for (final cidade in ['São Paulo', 'Campinas', 'Jundiaí']) {
        expect(locaisExemplo.where((l) => l.cidade == cidade).length, greaterThanOrEqualTo(5));
      }
      expect(locaisExemplo.every((l) => horarioValido(l.horario)), isTrue);
    });
  });

  group('formatos', () {
    test('estaAberto respeita o horário de funcionamento', () {
      expect(estaAberto('06:00 - 22:00', DateTime(2026, 1, 1, 10)), isTrue);
      expect(estaAberto('06:00 - 22:00', DateTime(2026, 1, 1, 23)), isFalse);
      expect(estaAberto('18:00 - 02:00', DateTime(2026, 1, 1, 1)), isTrue);
      expect(estaAberto('24 horas', DateTime(2026, 1, 1, 3)), isTrue);
      expect(estaAberto('horário livre', DateTime(2026, 1, 1, 3)), isNull);
    });

    test('lerNumero aceita vírgula ou ponto', () {
      expect(lerNumero('4,5'), 4.5);
      expect(lerNumero('1.2'), 1.2);
      expect(lerNumero('abc'), isNull);
      expect(formatarDistancia(1.25), '1,3 km');
    });
  });
}
