/// Representa um estabelecimento armazenado na coleção `locais` do Firestore.
class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;

  // Campos complementares (opcionais) usados na tela de detalhes e no mapa.
  final String endereco;
  final String telefone;
  final double? latitude;
  final double? longitude;

  const Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
    this.endereco = '',
    this.telefone = '',
    this.latitude,
    this.longitude,
  });

  bool get temCoordenadas => latitude != null && longitude != null;

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    return Local(
      id: id,
      nome: data['nome'] ?? '',
      categoria: data['categoria'] ?? '',
      cidade: data['cidade'] ?? '',
      avaliacao: (data['avaliacao'] ?? 0).toDouble(),
      distancia: (data['distancia'] ?? 0).toDouble(),
      horario: data['horario'] ?? '',
      descricao: data['descricao'] ?? '',
      favorito: data['favorito'] ?? false,
      endereco: data['endereco'] ?? '',
      telefone: data['telefone'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
      'endereco': endereco,
      'telefone': telefone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Local copyWith({
    String? id,
    String? nome,
    String? categoria,
    String? cidade,
    double? avaliacao,
    double? distancia,
    String? horario,
    String? descricao,
    bool? favorito,
    String? endereco,
    String? telefone,
    double? latitude,
    double? longitude,
  }) {
    return Local(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      cidade: cidade ?? this.cidade,
      avaliacao: avaliacao ?? this.avaliacao,
      distancia: distancia ?? this.distancia,
      horario: horario ?? this.horario,
      descricao: descricao ?? this.descricao,
      favorito: favorito ?? this.favorito,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
