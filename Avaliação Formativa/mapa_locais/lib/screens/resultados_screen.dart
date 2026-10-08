import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../dialogs/confirm_delete.dart';
import '../dialogs/seletor_cidade.dart';
import '../models/categoria.dart';
import '../models/cidade.dart';
import '../models/local.dart';
import '../utils/filtros.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

/// Tela 2 — Lista de resultados vinda do Firestore, com pesquisa, filtros por
/// cidade/categoria/favoritos e as ações de cadastrar, editar e excluir.
class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({
    super.key,
    required this.cidade,
    this.pesquisa = '',
    this.apenasFavoritos = false,
  });

  final String cidade;
  final String pesquisa;
  final bool apenasFavoritos;

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  late final _pesquisaController = TextEditingController(text: widget.pesquisa);
  late String _cidade = widget.cidade;
  late bool _apenasFavoritos = widget.apenasFavoritos;
  String _categoria = Categoria.todos;
  Stream<List<Local>>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= AppScope.of(context).service.listarLocais();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  void _recarregar() {
    setState(() => _stream = AppScope.of(context).service.listarLocais());
  }

  Future<void> _trocarCidade() async {
    final cidade = await selecionarCidade(context, atual: _cidade, incluirTodas: true);
    if (cidade != null) setState(() => _cidade = cidade);
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)));
  }

  Future<void> _cadastrar() async {
    final service = AppScope.of(context).service;
    final novo = await abrirFormularioLocal(
      context,
      cidadeInicial: _cidade == Cidade.todas ? null : _cidade,
    );
    if (novo == null || !mounted) return;
    try {
      await service.adicionar(novo);
      if (mounted) mostrarSucesso(context, '"${novo.nome}" cadastrado com sucesso!');
    } catch (e) {
      if (mounted) mostrarErro(context, 'Não foi possível cadastrar. ${descreverErro(e)}');
    }
  }

  Future<void> _editar(Local local) async {
    final service = AppScope.of(context).service;
    final editado = await abrirFormularioLocal(context, local: local);
    if (editado == null || !mounted) return;
    try {
      await service.atualizar(editado);
      if (mounted) mostrarSucesso(context, '"${editado.nome}" atualizado com sucesso!');
    } catch (e) {
      if (mounted) mostrarErro(context, 'Não foi possível salvar. ${descreverErro(e)}');
    }
  }

  Future<void> _excluir(Local local) async {
    final service = AppScope.of(context).service;
    final confirmou = await confirmarExclusao(context, local.nome);
    if (!confirmou || !mounted) return;
    try {
      await service.excluir(local.id);
      if (mounted) mostrarSucesso(context, '"${local.nome}" excluído.');
    } catch (e) {
      if (mounted) mostrarErro(context, 'Não foi possível excluir. ${descreverErro(e)}');
    }
  }

  Future<void> _popularExemplos() async {
    try {
      await AppScope.of(context).service.popularExemplos();
      if (mounted) mostrarSucesso(context, 'Locais de exemplo cadastrados!');
    } catch (e) {
      if (mounted) mostrarErro(context, 'Não foi possível cadastrar. ${descreverErro(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_apenasFavoritos ? 'Favoritos' : 'Resultados'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              key: const Key('campo_pesquisa'),
              controller: _pesquisaController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou categoria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _pesquisaController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar pesquisa',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_pesquisaController.clear),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                key: const Key('filtro_cidade'),
                dense: true,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(_cidade == Cidade.todas ? 'Todas as cidades' : _cidade,
                    style: const TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _trocarCidade,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _Chip(
                  rotulo: 'Todos',
                  selecionado: _categoria == Categoria.todos,
                  onTap: () => setState(() => _categoria = Categoria.todos),
                ),
                _Chip(
                  rotulo: 'Favoritos',
                  icone: Icons.favorite,
                  selecionado: _apenasFavoritos,
                  onTap: () => setState(() => _apenasFavoritos = !_apenasFavoritos),
                ),
                for (final c in Categoria.lista)
                  _Chip(
                    rotulo: c.plural,
                    selecionado: _categoria == c.nome,
                    onTap: () => setState(() => _categoria = c.nome),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _Mensagem(
                    icone: Icons.cloud_off,
                    titulo: 'Erro ao carregar os locais.',
                    texto: descreverErro(snapshot.error!),
                    acao: 'Tentar novamente',
                    onAcao: _recarregar,
                  );
                }

                final todos = snapshot.data ?? [];
                if (todos.isEmpty) {
                  return _Mensagem(
                    icone: Icons.inbox_outlined,
                    titulo: 'Nenhum local cadastrado.',
                    texto: 'A coleção "locais" está vazia. Cadastre um local '
                        'ou carregue os exemplos.',
                    acao: 'Cadastrar locais de exemplo',
                    onAcao: _popularExemplos,
                  );
                }

                final locais = filtrarLocais(
                  todos,
                  _pesquisaController.text,
                  _cidade,
                  _categoria,
                  apenasFavoritos: _apenasFavoritos,
                );
                if (locais.isEmpty) {
                  return const _Mensagem(
                    icone: Icons.search_off,
                    titulo: 'Nenhum local encontrado.',
                    texto: 'Tente outra pesquisa, cidade ou categoria.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: locais.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Text(
                          '${locais.length} ${locais.length == 1 ? 'local encontrado' : 'locais encontrados'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    final local = locais[index - 1];
                    return LocalCard(
                      key: ValueKey(local.id),
                      local: local,
                      onTap: () => _abrirDetalhes(local),
                      onEditar: () => _editar(local),
                      onExcluir: () => _excluir(local),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('botao_cadastrar'),
        onPressed: _cadastrar,
        icon: const Icon(Icons.add),
        label: const Text('Novo local'),
      ),
      bottomNavigationBar: BarraNavegacao(
        abaAtual: widget.apenasFavoritos ? BarraNavegacao.favoritos : BarraNavegacao.mapa,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.rotulo, required this.selecionado, required this.onTap, this.icone});

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(rotulo),
        avatar: icone == null
            ? null
            : Icon(icone, size: 16, color: selecionado ? Colors.redAccent : Colors.grey),
        selected: selecionado,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: cores.primary,
        backgroundColor: Colors.grey.shade100,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: selecionado ? cores.onPrimary : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem({
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acao,
    this.onAcao,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(titulo, style: textos.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(texto, style: textos.bodyMedium, textAlign: TextAlign.center),
            if (acao != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onAcao, child: Text(acao!)),
            ],
          ],
        ),
      ),
    );
  }
}
