import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/local.dart';

/// Bottom Sheet da aba "Perfil": resumo do banco de dados e sobre o app.
Future<void> mostrarPerfil(BuildContext context) {
  final service = AppScope.of(context).service;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      final textos = Theme.of(context).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: StreamBuilder<List<Local>>(
            stream: service.listarLocais(),
            builder: (context, snapshot) {
              final locais = snapshot.data ?? const <Local>[];
              final favoritos = locais.where((l) => l.favorito).length;
              final cidades = locais.map((l) => l.cidade).toSet().length;
              final carregando = !snapshot.hasData && !snapshot.hasError;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 36)),
                  const SizedBox(height: 8),
                  Text('Visitante', style: textos.titleLarge),
                  Text('Mapa de Locais · versão 1.0.0', style: textos.bodySmall),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _Indicador(valor: carregando ? '…' : '${locais.length}', rotulo: 'Locais'),
                      _Indicador(valor: carregando ? '…' : '$favoritos', rotulo: 'Favoritos'),
                      _Indicador(valor: carregando ? '…' : '$cidades', rotulo: 'Cidades'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      snapshot.hasError ? Icons.cloud_off : Icons.cloud_done,
                      color: snapshot.hasError ? Colors.red : Colors.green,
                    ),
                    title: const Text('Cloud Firestore'),
                    subtitle: Text(snapshot.hasError
                        ? 'Erro ao conectar com o banco de dados'
                        : 'Dados sincronizados da coleção "locais"'),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(valor, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
