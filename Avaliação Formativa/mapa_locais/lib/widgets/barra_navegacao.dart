import 'package:flutter/material.dart';

import '../dialogs/perfil_sheet.dart';
import '../models/cidade.dart';
import '../screens/resultados_screen.dart';

/// Abas inferiores do wireframe: Mapa, Favoritos e Perfil.
/// "Favoritos" abre a tela de resultados filtrada e "Perfil" abre um Bottom
/// Sheet, mantendo o app com três telas principais.
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({super.key, required this.abaAtual});

  static const mapa = 0;
  static const favoritos = 1;
  static const perfil = 2;

  final int abaAtual;

  void _selecionar(BuildContext context, int aba) {
    if (aba == perfil) {
      mostrarPerfil(context);
    } else if (aba == mapa) {
      Navigator.popUntil(context, (rota) => rota.isFirst);
    } else if (abaAtual != favoritos) {
      Navigator.popUntil(context, (rota) => rota.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResultadosScreen(cidade: Cidade.todas, apenasFavoritos: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: abaAtual,
      height: 68,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      indicatorColor: Colors.grey.shade200,
      onDestinationSelected: (aba) => _selecionar(context, aba),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
        NavigationDestination(
            icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
