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
      expect(r.length, 2);
      expect(r.every((l) => l.categoria == 'Hospital'), isTrue);
    });

    test('combina cidade, categoria e favoritos', () {
      expect(filtrarLocais(locais, '', 'Limeira', 'Academia').length, 5);
      expect(filtrarLocais(locais, '', 'Jundiaí', 'Academia').length, 1);
      final favoritos = filtrarLocais(locais, '', 'Todas', 'Todos', apenasFavoritos: true);
      expect(favoritos.every((l) => l.favorito), isTrue);
      expect(favoritos, isNotEmpty);
    });

    test('ordena do mais próximo para o mais distante', () {
      final r = filtrarLocais(locais, '', 'Limeira', 'Todos');
      final distancias = r.map((l) => l.distancia).toList();
      expect(distancias, [...distancias]..sort());
    });

    test('lista vazia quando nada corresponde', () {
      expect(filtrarLocais(locais, 'xyz inexistente', 'Todas', 'Todos'), isEmpty);
      expect(filtrarLocais(<Local>[], '', 'Todas', 'Todos'), isEmpty);
    });
  });

  group('dados de exemplo', () {
    test('ao menos 10 locais, 5+ na cidade principal e todas as cidades com locais', () {
      expect(locaisExemplo.length, greaterThanOrEqualTo(10));
      expect(locaisExemplo.where((l) => l.cidade == 'Limeira').length, greaterThanOrEqualTo(5),
          reason: 'a tela inicial (Limeira) precisa de ao menos 5 marcadores');
      for (final cidade in ['Limeira', 'São Paulo', 'Campinas', 'Jundiaí']) {
        expect(locaisExemplo.where((l) => l.cidade == cidade), isNotEmpty);
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
