import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/categoria.dart';
import '../models/local.dart';
import '../utils/coordenadas.dart';

/// Estilos de mapa alternados pelo botão de camadas.
enum EstiloMapa { claro, padrao }

/// Mapa real (OpenStreetMap / CARTO) com a posição do usuário e um marcador
/// para cada local.
class MapaLocais extends StatelessWidget {
  const MapaLocais({
    super.key,
    required this.controller,
    required this.centro,
    required this.posicaoUsuario,
    required this.locais,
    required this.selecionado,
    required this.onSelecionar,
    this.estilo = EstiloMapa.claro,
    this.carregarTiles = true,
  });

  final MapController controller;
  final LatLng centro;
  final LatLng posicaoUsuario;
  final List<Local> locais;
  final Local? selecionado;
  final ValueChanged<Local?> onSelecionar;
  final EstiloMapa estilo;
  final bool carregarTiles;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: centro,
        initialZoom: 13.2,
        minZoom: 4,
        maxZoom: 18,
        backgroundColor: const Color(0xFFEDEDED),
        onTap: (_, _) => onSelecionar(null),
      ),
      children: [
        if (carregarTiles) _camadaDeTiles(context),
        MarkerLayer(
          markers: [
            Marker(
              point: posicaoUsuario,
              width: 64,
              height: 64,
              child: const _PosicaoUsuario(),
            ),
            for (final local in locais)
              Marker(
                key: ValueKey('marcador_${local.id}'),
                point: posicaoDoLocal(local),
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: _Pino(
                  local: local,
                  selecionado: local.id == selecionado?.id,
                  onTap: () => onSelecionar(local),
                ),
              ),
            if (selecionado != null)
              Marker(
                point: posicaoDoLocal(selecionado!),
                width: 190,
                height: 34,
                alignment: const Alignment(1.15, -2.6),
                child: _Rotulo(nome: selecionado!.nome),
              ),
          ],
        ),
        if (carregarTiles)
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors', style: TextStyle(fontSize: 11)),
            backgroundColor: Colors.white70,
          ),
      ],
    );
  }

  /// Mapa do OpenStreetMap; no estilo "claro" recebe um filtro cinza para
  /// ficar parecido com o wireframe.
  TileLayer _camadaDeTiles(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.exemplo.mapa_locais',
      tileBuilder: estilo == EstiloMapa.claro
          ? (context, tile, _) => ColorFiltered(colorFilter: _filtroCinzaClaro, child: tile)
          : null,
    );
  }

  static const _filtroCinzaClaro = ColorFilter.matrix([
    0.18, 0.61, 0.06, 0, 38, //
    0.18, 0.61, 0.06, 0, 38, //
    0.18, 0.61, 0.06, 0, 40, //
    0, 0, 0, 1, 0,
  ]);
}

class _Pino extends StatelessWidget {
  const _Pino({required this.local, required this.selecionado, required this.onTap});

  final Local local;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? Categoria.porNome(local.categoria).cor : const Color(0xFF3C4043);
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: local.nome,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Icon(Icons.location_on, size: 44, color: cor, shadows: const [
              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Icon(Categoria.porNome(local.categoria).icone, size: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Text(
          nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PosicaoUsuario extends StatelessWidget {
  const _PosicaoUsuario();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Você está aqui',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A73E8).withValues(alpha: 0.18),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A73E8),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
            ),
          ),
        ],
      ),
    );
  }
}
