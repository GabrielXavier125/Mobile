import 'package:flutter/material.dart';

import '../widgets/mapa_locais.dart';

/// Bottom Sheet para escolher o estilo visual do mapa.
Future<EstiloMapa?> selecionarEstiloMapa(BuildContext context, {required EstiloMapa atual}) {
  return showModalBottomSheet<EstiloMapa>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estilo do mapa', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final estilo in EstiloMapa.values)
                    Expanded(
                      child: _OpcaoEstilo(
                        estilo: estilo,
                        selecionado: estilo == atual,
                        onTap: () => Navigator.pop(context, estilo),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OpcaoEstilo extends StatelessWidget {
  const _OpcaoEstilo({required this.estilo, required this.selecionado, required this.onTap});

  final EstiloMapa estilo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final destaque = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        key: ValueKey('estilo_${estilo.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selecionado ? destaque : Colors.grey.shade300, width: selecionado ? 3 : 1),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: estilo.cores,
                ),
              ),
              child: Center(
                child: Icon(Icons.location_on, size: 30, color: estilo == EstiloMapa.escuro ? Colors.white : const Color(0xFFE53935)),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(estilo.icone, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    estilo.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500),
                  ),
                ),
              ],
            ),
            Text(
              estilo.descricao,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
