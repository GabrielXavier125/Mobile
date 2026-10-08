import 'package:flutter/widgets.dart';

import 'models/local.dart';
import 'services/local_service.dart';

/// Disponibiliza para todas as telas o serviço do Firestore e o "foco" do mapa
/// (local que deve ser mostrado quando o usuário toca em "Ver no mapa").
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.service,
    required this.focoMapa,
    this.carregarTilesMapa = true,
    required super.child,
  });

  final LocalService service;
  final ValueNotifier<Local?> focoMapa;

  /// Desligado nos testes automatizados, que não têm acesso à internet.
  final bool carregarTilesMapa;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      service != oldWidget.service || carregarTilesMapa != oldWidget.carregarTilesMapa;
}
