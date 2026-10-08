import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/cidade.dart';
import '../models/local.dart';
import '../utils/coordenadas.dart';
import '../utils/formatos.dart';

/// Abre o formulário em um Bottom Sheet. Sem [local] é um cadastro; com
/// [local] o formulário vem preenchido para edição. Retorna o local montado
/// ou null se o usuário cancelar.
Future<Local?> abrirFormularioLocal(
  BuildContext context, {
  Local? local,
  String? cidadeInicial,
}) {
  return showModalBottomSheet<Local>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => LocalForm(local: local, cidadeInicial: cidadeInicial),
  );
}

class LocalForm extends StatefulWidget {
  const LocalForm({super.key, this.local, this.cidadeInicial});

  final Local? local;
  final String? cidadeInicial;

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();

  late final _nome = TextEditingController(text: widget.local?.nome);
  late final _endereco = TextEditingController(text: widget.local?.endereco);
  late final _telefone = TextEditingController(text: widget.local?.telefone);
  late final _horario = TextEditingController(text: widget.local?.horario ?? '08:00 - 18:00');
  late final _avaliacao = TextEditingController(
      text: widget.local == null ? '' : formatarNumero(widget.local!.avaliacao));
  late final _distancia = TextEditingController(
      text: widget.local == null ? '' : formatarNumero(widget.local!.distancia));
  late final _descricao = TextEditingController(text: widget.local?.descricao);

  late String _categoria = Categoria.nomes.contains(widget.local?.categoria)
      ? widget.local!.categoria
      : Categoria.nomes.first;
  late String _cidade = Cidade.nomes.contains(widget.local?.cidade)
      ? widget.local!.cidade
      : (Cidade.nomes.contains(widget.cidadeInicial) ? widget.cidadeInicial! : Cidade.nomes.first);

  bool get _editando => widget.local != null;

  @override
  void dispose() {
    for (final c in [_nome, _endereco, _telefone, _horario, _avaliacao, _distancia, _descricao]) {
      c.dispose();
    }
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final original = widget.local;
    // Mantém a posição no mapa; gera uma nova se for cadastro ou mudança de cidade.
    final manterPosicao = original != null && original.temCoordenadas && original.cidade == _cidade;
    final posicao = manterPosicao ? null : coordenadaAleatoria(_cidade);

    final local = Local(
      id: original?.id ?? '',
      nome: _nome.text.trim(),
      categoria: _categoria,
      cidade: _cidade,
      avaliacao: lerNumero(_avaliacao.text) ?? 0,
      distancia: lerNumero(_distancia.text) ?? 0,
      horario: _horario.text.trim(),
      descricao: _descricao.text.trim(),
      favorito: original?.favorito ?? false,
      endereco: _endereco.text.trim(),
      telefone: _telefone.text.trim(),
      latitude: posicao?.latitude ?? original?.latitude,
      longitude: posicao?.longitude ?? original?.longitude,
    );
    Navigator.pop(context, local);
  }

  String? _obrigatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    const espaco = SizedBox(height: 12);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          // Respeita a barra de navegação do Android abaixo dos botões.
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.of(context).viewPadding.bottom),
          children: [
            Text(
              _editando ? 'Editar local' : 'Cadastrar local',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('campo_nome'),
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome *', prefixIcon: Icon(Icons.store)),
              validator: (v) {
                final erro = _obrigatorio(v);
                if (erro != null) return erro;
                return v!.trim().length > 80 ? 'Use no máximo 80 caracteres' : null;
              },
            ),
            espaco,
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: const Key('campo_categoria'),
                    initialValue: _categoria,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Categoria *'),
                    items: [
                      for (final c in Categoria.lista)
                        DropdownMenuItem(value: c.nome, child: Text(c.nome)),
                    ],
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: const Key('campo_cidade'),
                    initialValue: _cidade,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Cidade *'),
                    items: [
                      for (final c in Cidade.nomes) DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) => setState(() => _cidade = v!),
                  ),
                ),
              ],
            ),
            espaco,
            TextFormField(
              key: const Key('campo_endereco'),
              controller: _endereco,
              decoration: const InputDecoration(labelText: 'Endereço', prefixIcon: Icon(Icons.map_outlined)),
            ),
            espaco,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('campo_telefone'),
                    controller: _telefone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Telefone'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('campo_horario'),
                    controller: _horario,
                    decoration: const InputDecoration(
                      labelText: 'Horário *',
                      hintText: '06:00 - 22:00',
                    ),
                    validator: (v) {
                      final erro = _obrigatorio(v);
                      if (erro != null) return erro;
                      return horarioValido(v!) ? null : 'Use HH:MM - HH:MM ou 24 horas';
                    },
                  ),
                ),
              ],
            ),
            espaco,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('campo_avaliacao'),
                    controller: _avaliacao,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Avaliação *',
                      hintText: '0 a 5',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                    validator: (v) {
                      final n = lerNumero(v ?? '');
                      if (n == null) return 'Informe um número';
                      return (n < 0 || n > 5) ? 'Entre 0 e 5' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('campo_distancia'),
                    controller: _distancia,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Distância *',
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: (v) {
                      final n = lerNumero(v ?? '');
                      if (n == null) return 'Informe um número';
                      return (n < 0 || n > 500) ? 'Entre 0 e 500' : null;
                    },
                  ),
                ),
              ],
            ),
            espaco,
            TextFormField(
              key: const Key('campo_descricao'),
              controller: _descricao,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Descrição *', alignLabelWithHint: true),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('botao_salvar'),
                    onPressed: _salvar,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
