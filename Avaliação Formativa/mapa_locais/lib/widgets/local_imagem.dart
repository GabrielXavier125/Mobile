import 'package:flutter/material.dart';

import '../models/categoria.dart';

/// Imagem ilustrativa do local, gerada a partir da categoria
/// (o projeto não usa Firebase Storage).
class LocalImagem extends StatelessWidget {
  const LocalImagem({
    super.key,
    required this.categoria,
    this.indice = 0,
    this.tamanhoIcone = 36,
    this.borderRadius = BorderRadius.zero,
  });

  final String categoria;
  final int indice;
  final double tamanhoIcone;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final cat = Categoria.porNome(categoria);
    final icone = cat.iconesFotos[indice % cat.iconesFotos.length];
    final hsl = HSLColor.fromColor(cat.cor);
    final clara = hsl.withLightness((hsl.lightness + 0.25 + indice * 0.03).clamp(0, 0.9)).toColor();

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [clara, cat.cor],
          ),
        ),
        child: Center(
          child: Icon(icone, size: tamanhoIcone, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ),
    );
  }
}
