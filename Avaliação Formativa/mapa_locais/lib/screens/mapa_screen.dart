import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../app_scope.dart';
import '../dialogs/seletor_cidade.dart';
import '../dialogs/seletor_estilo_mapa.dart';
import '../models/cidade.dart';
import '../models/local.dart';
import '../utils/coordenadas.dart';
import '../utils/formatos.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/local_imagem.dart';
import '../widgets/mapa_locais.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

/// Tela 1 — Mapa principal: cidade selecionada, pesquisa e marcadores dos
/// locais cadastrados no Firestore.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _mapController = MapController();
  final _pesquisaController = TextEditingController();

  String _cidade = Cidade.lista.first.nome;
  String? _selecionadoId;
  EstiloMapa _estilo = EstiloMapa.suave;

  AppScope? _scope;
  Stream<List<Local>>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    if (!identical(scope, _scope)) {
      _scope?.focoMapa.removeListener(_aoReceberFoco);
      _scope = scope;
      _stream = scope.service.listarLocais();
      scope.focoMapa.addListener(_aoReceberFoco);
    }
  }

  @override
  void dispose() {
    _scope?.focoMapa.removeListener(_aoReceberFoco);
    _pesquisaController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Chamado quando a tela de detalhes pede "Ver no mapa".
  void _aoReceberFoco() {
    final local = _scope!.focoMapa.value;
    if (local == null) return;
    _scope!.focoMapa.value = null;
    setState(() {
      if (Cidade.nomes.contains(local.cidade)) _cidade = local.cidade;
      _selecionadoId = local.id;
    });
    _mapController.move(posicaoDoLocal(local), 16);
  }

  Future<void> _trocarCidade() async {
    final cidade = await selecionarCidade(context, atual: _cidade);
    if (cidade == null || !mounted) return;
    setState(() {
      _cidade = cidade;
      _selecionadoId = null;
    });
    _mapController.move(Cidade.porNome(cidade).centro, 13.2);
  }

  void _zoom(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + delta).clamp(4, 18).toDouble());
  }

  Future<void> _trocarEstilo() async {
    final estilo = await selecionarEstiloMapa(context, atual: _estilo);
    if (estilo != null && mounted) setState(() => _estilo = estilo);
  }

  void _abrirResultados() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          cidade: _cidade,
          pesquisa: _pesquisaController.text.trim(),
        ),
      ),
    );
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)));
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Cabecalho(
              cidade: _cidade,
              pesquisaController: _pesquisaController,
              onTrocarCidade: _trocarCidade,
              onPesquisar: _abrirResultados,
            ),
            Expanded(
              child: StreamBuilder<List<Local>>(
                stream: _stream,
                builder: (context, snapshot) {
                  final locais = (snapshot.data ?? const <Local>[])
                      .where((l) => l.cidade == _cidade)
                      .toList();
                  final selecionado = locais.where((l) => l.id == _selecionadoId).firstOrNull;

                  return Stack(
                    children: [
                      MapaLocais(
                        controller: _mapController,
                        centro: Cidade.porNome(_cidade).centro,
                        posicaoUsuario: Cidade.porNome(_cidade).centro,
                        locais: locais,
                        selecionado: selecionado,
                        estilo: _estilo,
                        carregarTiles: scope.carregarTilesMapa,
                        animar: scope.animarMapa,
                        onSelecionar: (local) => setState(() => _selecionadoId = local?.id),
                      ),
                      // Sombra suave separando o cabeçalho do mapa
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 14,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x26000000), Color(0x00000000)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(),
                      if (snapshot.hasError)
                        const _AvisoErro(mensagem: 'Erro ao carregar os locais do Firestore.'),
                      Positioned(
                        right: 16,
                        bottom: selecionado == null ? 104 : 170,
                        child: Column(
                          children: [
                            _GrupoBotoes(
                              botoes: [
                                _BotaoMapa(icone: Icons.add, dica: 'Aproximar', onPressed: () => _zoom(1)),
                                _BotaoMapa(icone: Icons.remove, dica: 'Afastar', onPressed: () => _zoom(-1)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _GrupoBotoes(
                              botoes: [
                                _BotaoMapa(
                                  icone: Icons.my_location,
                                  dica: 'Minha localização',
                                  cor: const Color(0xFF1A73E8),
                                  onPressed: () {
                                    setState(() => _selecionadoId = null);
                                    _mapController.move(Cidade.porNome(_cidade).centro, 14);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _GrupoBotoes(
                              botoes: [
                                _BotaoMapa(
                                  icone: Icons.layers_outlined,
                                  dica: 'Alterar estilo do mapa',
                                  onPressed: _trocarEstilo,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 32,
                        child: selecionado == null
                            ? Center(
                                child: FilledButton.icon(
                                  key: const Key('botao_ver_resultados'),
                                  onPressed: _abrirResultados,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                    elevation: 3,
                                  ),
                                  icon: const Icon(Icons.format_list_bulleted),
                                  label: Text('Ver resultados (${locais.length})'),
                                ),
                              )
                            : _PreviaLocal(
                                local: selecionado,
                                onAbrir: () => _abrirDetalhes(selecionado),
                                onFechar: () => setState(() => _selecionadoId = null),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BarraNavegacao(abaAtual: BarraNavegacao.mapa),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.cidade,
    required this.pesquisaController,
    required this.onTrocarCidade,
    required this.onPesquisar,
  });

  final String cidade;
  final TextEditingController pesquisaController;
  final VoidCallback onTrocarCidade;
  final VoidCallback onPesquisar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('seletor_cidade'),
            onTap: onTrocarCidade,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 28),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cidade selecionada',
                          style: textos.bodySmall?.copyWith(color: Colors.grey.shade600)),
                      Row(
                        children: [
                          Text(cidade,
                              style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('campo_pesquisa_mapa'),
            controller: pesquisaController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onPesquisar(),
            decoration: InputDecoration(
              hintText: 'Buscar locais, endereços ou categorias...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Pesquisar',
                icon: const Icon(Icons.arrow_forward),
                onPressed: onPesquisar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão branco arredondado que agrupa botões do mapa (ex.: + e −).
class _GrupoBotoes extends StatelessWidget {
  const _GrupoBotoes({required this.botoes});

  final List<Widget> botoes;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < botoes.length; i++) ...[
            if (i > 0) Container(width: 28, height: 1, color: Colors.grey.shade300),
            botoes[i],
          ],
        ],
      ),
    );
  }
}

class _BotaoMapa extends StatelessWidget {
  const _BotaoMapa({required this.icone, required this.dica, required this.onPressed, this.cor});

  final IconData icone;
  final String dica;
  final VoidCallback onPressed;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: dica,
      icon: Icon(icone, color: cor ?? const Color(0xFF3C4043)),
      onPressed: onPressed,
    );
  }
}

class _PreviaLocal extends StatelessWidget {
  const _PreviaLocal({required this.local, required this.onAbrir, required this.onFechar});

  final Local local;
  final VoidCallback onAbrir;
  final VoidCallback onFechar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onAbrir,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: LocalImagem(
                  categoria: local.categoria,
                  tamanhoIcone: 28,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(local.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${local.categoria} · ${formatarDistancia(local.distancia)}',
                        style: textos.bodySmall),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                        Text(' ${formatarNumero(local.avaliacao)}', style: textos.bodySmall),
                        const Spacer(),
                        Flexible(
                          child: Text('Ver detalhes',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textos.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(tooltip: 'Fechar', icon: const Icon(Icons.close), onPressed: onFechar),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvisoErro extends StatelessWidget {
  const _AvisoErro({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(mensagem, style: TextStyle(color: Colors.red.shade900))),
        ],
      ),
    );
  }
}
