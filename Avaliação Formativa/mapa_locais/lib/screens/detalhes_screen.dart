import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../models/local.dart';
import '../utils/coordenadas.dart';
import '../utils/formatos.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/local_imagem.dart';

/// Tela 3 — Detalhes do local selecionado. Acompanha o documento em tempo
/// real para refletir o favorito e eventuais edições.
class DetalhesScreen extends StatefulWidget {
  const DetalhesScreen({super.key, required this.local});

  final Local local;

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  static const _totalFotos = 5;

  final _paginas = PageController();
  int _fotoAtual = 0;
  bool _salvandoFavorito = false;
  Stream<Local?>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream ??= AppScope.of(context).service.observarLocal(widget.local.id);
  }

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  Future<void> _alternarFavorito(Local local) async {
    setState(() => _salvandoFavorito = true);
    try {
      await AppScope.of(context).service.alterarFavorito(local.id, !local.favorito);
      if (mounted) {
        mostrarSucesso(context,
            local.favorito ? 'Removido dos favoritos.' : 'Adicionado aos favoritos!');
      }
    } catch (e) {
      if (mounted) mostrarErro(context, 'Não foi possível atualizar. ${descreverErro(e)}');
    } finally {
      if (mounted) setState(() => _salvandoFavorito = false);
    }
  }

  void _compartilhar(Local local) {
    final texto = '${local.nome} (${local.categoria})\n'
        '${local.endereco.isEmpty ? local.cidade : '${local.endereco}, ${local.cidade}'}\n'
        'Horário: ${local.horario} · Avaliação: ${formatarNumero(local.avaliacao)}';
    Clipboard.setData(ClipboardData(text: texto));
    mostrarSucesso(context, 'Informações copiadas para a área de transferência.');
  }

  Future<void> _abrirLink(Uri uri, String erro) async {
    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu && mounted) mostrarErro(context, erro);
    } catch (_) {
      if (mounted) mostrarErro(context, erro);
    }
  }

  void _ligar(Local local) {
    if (local.telefone.isEmpty) {
      mostrarErro(context, 'Este local não possui telefone cadastrado.');
      return;
    }
    final numero = local.telefone.replaceAll(RegExp(r'[^0-9+]'), '');
    _abrirLink(Uri(scheme: 'tel', path: numero), 'Não foi possível abrir o discador.');
  }

  void _comoChegar(Local local) {
    final p = posicaoDoLocal(local);
    _abrirLink(
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '${p.latitude},${p.longitude}',
      }),
      'Não foi possível abrir as rotas.',
    );
  }

  Future<void> _agendar(Local local) async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      helpText: 'Agendar visita',
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 90)),
      initialDate: agora,
    );
    if (data == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      helpText: 'Horário da visita',
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (hora == null || !mounted) return;
    final dia = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
    mostrarSucesso(context, 'Visita a ${local.nome} agendada para $dia às ${hora.format(context)}.');
  }

  void _verNoMapa(Local local) {
    AppScope.of(context).focoMapa.value = local;
    Navigator.popUntil(context, (rota) => rota.isFirst);
  }

  void _verTodasFotos(Local local) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (var i = 0; i < _totalFotos; i++)
              LocalImagem(
                categoria: local.categoria,
                indice: i,
                tamanhoIcone: 28,
                borderRadius: BorderRadius.circular(8),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Local?>(
      stream: _stream,
      initialData: widget.local,
      builder: (context, snapshot) {
        final local = snapshot.hasError ? widget.local : snapshot.data;

        if (local == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Este local foi excluído do banco de dados.')),
            bottomNavigationBar: const BarraNavegacao(abaAtual: BarraNavegacao.mapa),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                key: const Key('botao_favorito'),
                tooltip: local.favorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                onPressed: _salvandoFavorito ? null : () => _alternarFavorito(local),
                icon: Icon(
                  local.favorito ? Icons.favorite : Icons.favorite_border,
                  color: local.favorito ? Colors.redAccent : null,
                ),
              ),
              IconButton(
                tooltip: 'Compartilhar',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _compartilhar(local),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _galeria(local),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _conteudo(local),
              ),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FilledButton.icon(
                  key: const Key('botao_ver_no_mapa'),
                  onPressed: () => _verNoMapa(local),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ver no mapa'),
                ),
              ),
              const BarraNavegacao(abaAtual: BarraNavegacao.mapa),
            ],
          ),
        );
      },
    );
  }

  Widget _galeria(Local local) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _paginas,
                  itemCount: _totalFotos,
                  onPageChanged: (i) => setState(() => _fotoAtual = i),
                  itemBuilder: (_, i) => LocalImagem(
                    categoria: local.categoria,
                    indice: i,
                    tamanhoIcone: 72,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${_fotoAtual + 1}/$_totalFotos',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _totalFotos; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _fotoAtual ? 8 : 6,
                height: i == _fotoAtual ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _fotoAtual ? Colors.black87 : Colors.grey.shade300,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _conteudo(Local local) {
    final textos = Theme.of(context).textTheme;
    final cinza = Colors.grey.shade700;
    final aberto = estaAberto(local.horario, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(local.nome, style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(local.categoria, style: textos.bodyMedium?.copyWith(color: cinza)),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                local.avaliacao >= i
                    ? Icons.star_rounded
                    : (local.avaliacao >= i - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                size: 20,
                color: const Color(0xFFFFB300),
              ),
            const SizedBox(width: 6),
            Text(formatarNumero(local.avaliacao),
                style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(' de 5', style: textos.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _InfoCurta(icone: Icons.place_outlined, texto: formatarDistancia(local.distancia)),
            _InfoCurta(
              icone: Icons.schedule,
              texto: local.horario,
              destaque: aberto == null ? null : (aberto ? 'Aberto' : 'Fechado'),
              corDestaque: aberto == true ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Acao(icone: Icons.call_outlined, rotulo: 'Ligar', onTap: () => _ligar(local)),
            _Acao(icone: Icons.near_me_outlined, rotulo: 'Como chegar', onTap: () => _comoChegar(local)),
            _Acao(icone: Icons.event_outlined, rotulo: 'Agendar', onTap: () => _agendar(local)),
          ],
        ),
        const Divider(height: 32),
        Text('Sobre', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(local.descricao.isEmpty ? 'Sem descrição.' : local.descricao, style: textos.bodyMedium),
        const SizedBox(height: 12),
        _LinhaInfo(icone: Icons.map_outlined, rotulo: 'Endereço',
            valor: local.endereco.isEmpty ? 'Não informado' : local.endereco),
        _LinhaInfo(icone: Icons.location_city, rotulo: 'Cidade', valor: local.cidade),
        _LinhaInfo(icone: Icons.phone_outlined, rotulo: 'Telefone',
            valor: local.telefone.isEmpty ? 'Não informado' : local.telefone),
        _LinhaInfo(icone: Icons.schedule, rotulo: 'Funcionamento', valor: local.horario),
        const Divider(height: 32),
        Row(
          children: [
            Text('Fotos', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () => _verTodasFotos(local),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('Ver todas'), Icon(Icons.chevron_right, size: 18)],
              ),
            ),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: GestureDetector(
                    onTap: () => _paginas.animateToPage(i + 1,
                        duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                    child: LocalImagem(
                      categoria: local.categoria,
                      indice: i + 1,
                      tamanhoIcone: 26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _InfoCurta extends StatelessWidget {
  const _InfoCurta({required this.icone, required this.texto, this.destaque, this.corDestaque});

  final IconData icone;
  final String texto;
  final String? destaque;
  final Color? corDestaque;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        if (destaque != null)
          Text('$destaque · ', style: TextStyle(color: corDestaque, fontWeight: FontWeight.w600)),
        Text(texto),
      ],
    );
  }
}

class _Acao extends StatelessWidget {
  const _Acao({required this.icone, required this.rotulo, required this.onTap});

  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(icone, size: 22),
            ),
            const SizedBox(height: 6),
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({required this.icone, required this.rotulo, required this.valor});

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          SizedBox(
            width: 104,
            child: Text(rotulo, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
