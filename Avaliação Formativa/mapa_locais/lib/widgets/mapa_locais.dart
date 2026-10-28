import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/categoria.dart';
import '../models/local.dart';
import '../utils/coordenadas.dart';

/// Estilos visuais do mapa, escolhidos pelo botão de camadas.
/// Todos usam as imagens do OpenStreetMap; "suave" e "escuro" aplicam um
/// filtro de cor sobre elas.
enum EstiloMapa {
  suave('Suave', 'Cores leves e limpas', Icons.wb_sunny_outlined,
      [Color(0xFFF6F3EC), Color(0xFFD5EACB), Color(0xFFB4DAE6)]),
  colorido('Colorido', 'Mapa original do OpenStreetMap', Icons.palette_outlined,
      [Color(0xFFF2EFE9), Color(0xFFF7C9A0), Color(0xFFA6D8B4)]),
  escuro('Escuro', 'Modo noturno', Icons.dark_mode_outlined,
      [Color(0xFF1B2330), Color(0xFF2C3A4F), Color(0xFF41618A)]);

  const EstiloMapa(this.nome, this.descricao, this.icone, this.cores);

  final String nome;
  final String descricao;
  final IconData icone;

  /// Cores usadas na miniatura do seletor de estilos.
  final List<Color> cores;
}

/// Mapa real (OpenStreetMap) com a posição do usuário e um marcador colorido
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
    this.estilo = EstiloMapa.suave,
    this.carregarTiles = true,
    this.animar = true,
  });

  final MapController controller;
  final LatLng centro;
  final LatLng posicaoUsuario;
  final List<Local> locais;
  final Local? selecionado;
  final ValueChanged<Local?> onSelecionar;
  final EstiloMapa estilo;
  final bool carregarTiles;

  /// Animação contínua do ponto do usuário (desligada nos testes automatizados).
  final bool animar;

  @override
  Widget build(BuildContext context) {
    final escuro = estilo == EstiloMapa.escuro;

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: centro,
        initialZoom: 13.6,
        minZoom: 4,
        maxZoom: 18,
        backgroundColor: escuro ? const Color(0xFF1B2330) : const Color(0xFFF2EFE9),
        onTap: (_, _) => onSelecionar(null),
      ),
      children: [
        if (carregarTiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.exemplo.mapa_locais',
            tileBuilder: switch (estilo) {
              EstiloMapa.suave => (context, tile, _) => ColorFiltered(colorFilter: _filtroSuave, child: tile),
              EstiloMapa.escuro => (context, tile, _) => ColorFiltered(colorFilter: _filtroEscuro, child: tile),
              EstiloMapa.colorido => null,
            },
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: posicaoUsuario,
              width: 80,
              height: 80,
              child: _PosicaoUsuario(animar: animar),
            ),
            for (final local in locais)
              Marker(
                key: ValueKey('marcador_${local.id}'),
                point: posicaoDoLocal(local),
                width: 56,
                height: 64,
                alignment: Alignment.topCenter,
                child: _Pino(
                  local: local,
                  selecionado: local.id == selecionado?.id,
                  onTap: () => onSelecionar(local),
                ),
              ),
            if (selecionado != null)
              // Balão centralizado logo acima do pino selecionado
              Marker(
                point: posicaoDoLocal(selecionado!),
                width: 230,
                height: 36,
                alignment: const Alignment(0, -5.3),
                child: _Rotulo(local: selecionado!),
              ),
          ],
        ),
        if (carregarTiles) _Creditos(escuro: escuro),
      ],
    );
  }

  /// Reduz a saturação pela metade e clareia: mantém parques verdes e água
  /// azul, mas sem o excesso de cor do mapa original.
  static const _filtroSuave = ColorFilter.matrix([
    0.62, 0.29, 0.03, 0, 24, //
    0.09, 0.82, 0.03, 0, 24, //
    0.09, 0.29, 0.56, 0, 26, //
    0, 0, 0, 1, 0,
  ]);

  /// Inverte as cores e puxa para um azul-marinho (modo noturno).
  static const _filtroEscuro = ColorFilter.matrix([
    -0.17, -0.57, -0.06, 0, 205, //
    -0.17, -0.57, -0.06, 0, 215, //
    -0.15, -0.50, -0.05, 0, 235, //
    0, 0, 0, 1, 0,
  ]);
}

/// Marcador em forma de gota, na cor da categoria, com o ícone num círculo branco.
class _Pino extends StatelessWidget {
  const _Pino({required this.local, required this.selecionado, required this.onTap});

  final Local local;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoria = Categoria.porNome(local.categoria);
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: local.nome,
        child: AnimatedScale(
          scale: selecionado ? 1.22 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          alignment: Alignment.bottomCenter,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(
                Icons.location_on,
                size: 56,
                color: categoria.cor,
                shadows: const [Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))],
              ),
              Positioned(
                top: 10,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: selecionado ? Border.all(color: categoria.cor, width: 2) : null,
                  ),
                  child: Icon(categoria.icone, size: 15, color: categoria.cor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Balão com o nome do local selecionado.
class _Rotulo extends StatelessWidget {
  const _Rotulo({required this.local});

  final Local local;

  @override
  Widget build(BuildContext context) {
    final cor = Categoria.porNome(local.categoria).cor;
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                local.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ponto azul da posição do usuário, com um halo que pulsa.
class _PosicaoUsuario extends StatefulWidget {
  const _PosicaoUsuario({required this.animar});

  final bool animar;

  @override
  State<_PosicaoUsuario> createState() => _PosicaoUsuarioState();
}

class _PosicaoUsuarioState extends State<_PosicaoUsuario> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    if (widget.animar) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1A73E8);
    return Tooltip(
      message: 'Você está aqui',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Halo que cresce e some
              Container(
                width: 24 + 56 * t,
                height: 24 + 56 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: azul.withValues(alpha: 0.35 * (1 - t)),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: azul,
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(0, 1))],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Crédito exigido pela licença do OpenStreetMap, em um selo discreto.
class _Creditos extends StatelessWidget {
  const _Creditos({required this.escuro});

  final bool escuro;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: (escuro ? Colors.black : Colors.white).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '© OpenStreetMap contributors',
          style: TextStyle(fontSize: 10, color: escuro ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}
