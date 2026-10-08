import 'package:latlong2/latlong.dart';

/// Cidade disponível para seleção, com o ponto central usado no mapa.
class Cidade {
  final String nome;
  final LatLng centro;

  const Cidade(this.nome, this.centro);

  static const todas = 'Todas';

  static const lista = [
    Cidade('São Paulo', LatLng(-23.5613, -46.6565)),
    Cidade('Campinas', LatLng(-22.9056, -47.0608)),
    Cidade('Jundiaí', LatLng(-23.1857, -46.8978)),
  ];

  static List<String> get nomes => lista.map((c) => c.nome).toList();

  static Cidade porNome(String nome) =>
      lista.firstWhere((c) => c.nome == nome, orElse: () => lista.first);
}
