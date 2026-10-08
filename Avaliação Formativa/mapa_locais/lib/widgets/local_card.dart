import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/formatos.dart';
import 'local_imagem.dart';

/// Item da lista de resultados: imagem, nome, categoria, distância e avaliação,
/// com menu para editar ou excluir.
class LocalCard extends StatelessWidget {
  const LocalCard({
    super.key,
    required this.local,
    required this.onTap,
    required this.onEditar,
    required this.onExcluir,
  });

  final Local local;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cinza = Colors.grey.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: LocalImagem(
                  categoria: local.categoria,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            local.nome,
                            style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (local.favorito) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${local.categoria} · ${local.cidade}',
                        style: textos.bodySmall?.copyWith(color: cinza)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 15, color: cinza),
                        const SizedBox(width: 3),
                        Text(formatarDistancia(local.distancia), style: textos.bodySmall),
                        const SizedBox(width: 12),
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                        const SizedBox(width: 2),
                        Text(formatarNumero(local.avaliacao), style: textos.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                icon: const Icon(Icons.more_vert),
                onSelected: (opcao) => opcao == 'editar' ? onEditar() : onExcluir(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Excluir', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
