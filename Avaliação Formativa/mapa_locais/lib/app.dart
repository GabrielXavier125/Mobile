import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'models/local.dart';
import 'screens/mapa_screen.dart';
import 'services/local_service.dart';

class MinhaAplicacao extends StatefulWidget {
  const MinhaAplicacao({super.key, this.service, this.carregarTilesMapa = true});

  /// Permite injetar um serviço com Firestore falso nos testes.
  final LocalService? service;
  final bool carregarTilesMapa;

  @override
  State<MinhaAplicacao> createState() => _MinhaAplicacaoState();
}

class _MinhaAplicacaoState extends State<MinhaAplicacao> {
  late final LocalService _service = widget.service ?? LocalService();
  final _focoMapa = ValueNotifier<Local?>(null);

  @override
  void dispose() {
    _focoMapa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const preto = Color(0xFF1F2328);
    final esquema = ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
      primary: preto,
      onPrimary: Colors.white,
      secondary: const Color(0xFF1A73E8),
      surface: Colors.white,
    );

    return AppScope(
      service: _service,
      focoMapa: _focoMapa,
      carregarTilesMapa: widget.carregarTilesMapa,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mapa de Locais',
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          colorScheme: esquema,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: preto,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: preto,
            foregroundColor: Colors.white,
          ),
        ),
        home: const MapaScreen(),
      ),
    );
  }
}
