import '../models/categoria.dart';
import '../models/cidade.dart';
import '../models/local.dart';

const _acentos = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcentos = 'aaaaaeeeeiiiiooooouuuucn';

/// Deixa o texto minúsculo e sem acentos para comparar "farmacia" com "Farmácia".
String normalizar(String texto) {
  final buffer = StringBuffer();
  for (final char in texto.toLowerCase().trim().split('')) {
    final i = _acentos.indexOf(char);
    buffer.write(i >= 0 ? _semAcentos[i] : char);
  }
  return buffer.toString();
}

/// Aplica pesquisa (nome ou categoria), cidade, categoria e favoritos em memória
/// e ordena pelo mais próximo.
List<Local> filtrarLocais(
  List<Local> locais,
  String texto,
  String cidade,
  String categoria, {
  bool apenasFavoritos = false,
}) {
  final termo = normalizar(texto);

  final resultado = locais.where((local) {
    final correspondeCidade = cidade == Cidade.todas || local.cidade == cidade;
    final correspondeCategoria =
        categoria == Categoria.todos || local.categoria == categoria;
    final correspondeTexto = termo.isEmpty ||
        normalizar(local.nome).contains(termo) ||
        normalizar(local.categoria).contains(termo);
    final correspondeFavorito = !apenasFavoritos || local.favorito;

    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto &&
        correspondeFavorito;
  }).toList();

  resultado.sort((a, b) => a.distancia.compareTo(b.distancia));
  return resultado;
}
