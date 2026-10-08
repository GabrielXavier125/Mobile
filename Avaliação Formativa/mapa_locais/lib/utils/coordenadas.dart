import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/cidade.dart';
import '../models/local.dart';

/// Gera uma coordenada aleatória a até ~2,5 km do centro da cidade, usada
/// quando um local é cadastrado pelo formulário (sem latitude/longitude).
LatLng coordenadaAleatoria(String cidade, {Random? random}) {
  final r = random ?? Random();
  final centro = Cidade.porNome(cidade).centro;
  return LatLng(
    centro.latitude + (r.nextDouble() - 0.5) * 0.045,
    centro.longitude + (r.nextDouble() - 0.5) * 0.045,
  );
}

/// Posição do local no mapa. Documentos antigos sem coordenadas recebem uma
/// posição estável (derivada do ID) perto do centro da cidade.
LatLng posicaoDoLocal(Local local) {
  if (local.temCoordenadas) return LatLng(local.latitude!, local.longitude!);
  return coordenadaAleatoria(local.cidade, random: Random(local.id.hashCode));
}
