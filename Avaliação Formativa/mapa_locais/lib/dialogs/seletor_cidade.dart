import 'package:flutter/material.dart';

import '../models/cidade.dart';

/// Bottom Sheet para escolher a cidade. Com [incluirTodas], oferece também
/// a opção "Todas as cidades" (usada no filtro de resultados).
Future<String?> selecionarCidade(
  BuildContext context, {
  required String atual,
  bool incluirTodas = false,
}) {
  final opcoes = [if (incluirTodas) Cidade.todas, ...Cidade.nomes];

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecione a cidade', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final cidade in opcoes)
              ListTile(
                leading: Icon(
                  cidade == Cidade.todas ? Icons.public : Icons.location_city,
                ),
                title: Text(cidade == Cidade.todas ? 'Todas as cidades' : cidade),
                trailing: cidade == atual
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary)
                    : null,
                onTap: () => Navigator.pop(context, cidade),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
