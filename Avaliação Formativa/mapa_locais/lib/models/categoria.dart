import 'package:flutter/material.dart';

/// Categoria de estabelecimento: nome gravado no Firestore, rótulo do filtro,
/// ícone e cor usados nas imagens ilustrativas.
class Categoria {
  final String nome;
  final String plural;
  final IconData icone;
  final Color cor;
  final List<IconData> iconesFotos;

  const Categoria(this.nome, this.plural, this.icone, this.cor, this.iconesFotos);

  static const todos = 'Todos';

  static const lista = [
    Categoria('Academia', 'Academias', Icons.fitness_center, Color(0xFF5C6BC0), [
      Icons.fitness_center,
      Icons.sports_gymnastics,
      Icons.directions_run,
      Icons.self_improvement,
      Icons.pool,
    ]),
    Categoria('Restaurante', 'Restaurantes', Icons.restaurant, Color(0xFFEF6C00), [
      Icons.restaurant,
      Icons.ramen_dining,
      Icons.local_pizza,
      Icons.lunch_dining,
      Icons.wine_bar,
    ]),
    Categoria('Hospital', 'Hospitais', Icons.local_hospital, Color(0xFFE53935), [
      Icons.local_hospital,
      Icons.medical_services,
      Icons.monitor_heart,
      Icons.vaccines,
      Icons.healing,
    ]),
    Categoria('Farmácia', 'Farmácias', Icons.local_pharmacy, Color(0xFF00897B), [
      Icons.local_pharmacy,
      Icons.medication,
      Icons.health_and_safety,
      Icons.spa,
      Icons.storefront,
    ]),
    Categoria('Mercado', 'Mercados', Icons.local_grocery_store, Color(0xFF43A047), [
      Icons.local_grocery_store,
      Icons.shopping_basket,
      Icons.eco,
      Icons.bakery_dining,
      Icons.storefront,
    ]),
    Categoria('Café', 'Cafés', Icons.local_cafe, Color(0xFF6D4C41), [
      Icons.local_cafe,
      Icons.coffee_maker,
      Icons.bakery_dining,
      Icons.icecream,
      Icons.menu_book,
    ]),
  ];

  static const _padrao = Categoria('Outro', 'Outros', Icons.place, Color(0xFF757575), [
    Icons.place,
    Icons.storefront,
    Icons.location_city,
    Icons.map,
    Icons.photo,
  ]);

  static List<String> get nomes => lista.map((c) => c.nome).toList();

  static Categoria porNome(String nome) =>
      lista.firstWhere((c) => c.nome == nome, orElse: () => _padrao);
}
