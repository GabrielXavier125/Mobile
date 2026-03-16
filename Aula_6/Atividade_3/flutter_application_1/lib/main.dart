import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pedra Papel Tesoura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F8B8D)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        useMaterial3: true,
      ),
      home: const JogoApp(),
    );
  }
}

class JogoApp extends StatefulWidget {
  const JogoApp({super.key});

  @override
  State<JogoApp> createState() => _JogoAppState();
}

class _JogoAppState extends State<JogoApp> with SingleTickerProviderStateMixin {
  IconData iconeComputador = Icons.help_outline;
  String resultado = 'Escolha uma opcao';
  int pontosJogador = 0;
  int pontosComputador = 0;
  int totalPartidas = 0;
  String ultimaEscolhaJogador = '-';
  String ultimaEscolhaComputador = '-';
  int animacaoResultadoTick = 0;
  String tipoResultado = 'neutro';
  final int pontosParaCampeonato = 5;
  final List<String> opcoes = ['pedra', 'papel', 'tesoura'];

  late final AnimationController entradaController;
  late final Animation<double> fadePlacar;
  late final Animation<double> fadeResultado;
  late final Animation<double> fadeAcoes;
  late final Animation<Offset> slidePlacar;
  late final Animation<Offset> slideResultado;
  late final Animation<Offset> slideAcoes;

  @override
  void initState() {
    super.initState();
    entradaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    fadePlacar = CurvedAnimation(
      parent: entradaController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    fadeResultado = CurvedAnimation(
      parent: entradaController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );
    fadeAcoes = CurvedAnimation(
      parent: entradaController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    slidePlacar = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entradaController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );
    slideResultado =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: entradaController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
    slideAcoes = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entradaController,
            curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    entradaController.forward();
  }

  @override
  void dispose() {
    entradaController.dispose();
    super.dispose();
  }

  void jogar(String escolhaUsuario) {
    final numero = Random().nextInt(3);
    final escolhaComputador = opcoes[numero];
    String? mensagemCampeao;

    setState(() {
      totalPartidas++;
      ultimaEscolhaJogador = escolhaUsuario;
      ultimaEscolhaComputador = escolhaComputador;
      iconeComputador = _iconeDaOpcao(escolhaComputador);

      if (escolhaUsuario == escolhaComputador) {
        resultado = 'Empate';
        tipoResultado = 'empate';
      } else if ((escolhaUsuario == 'pedra' &&
              escolhaComputador == 'tesoura') ||
          (escolhaUsuario == 'papel' && escolhaComputador == 'pedra') ||
          (escolhaUsuario == 'tesoura' && escolhaComputador == 'papel')) {
        pontosJogador++;
        resultado = 'Voce venceu!';
        tipoResultado = 'vitoria';

        if (pontosJogador == pontosParaCampeonato) {
          resultado = 'Voce ganhou o campeonato!';
          mensagemCampeao = resultado;
          pontosJogador = 0;
          pontosComputador = 0;
        }
      } else {
        pontosComputador++;
        resultado = 'Computador venceu!';
        tipoResultado = 'derrota';

        if (pontosComputador == pontosParaCampeonato) {
          resultado = 'Computador ganhou o campeonato!';
          mensagemCampeao = resultado;
          pontosJogador = 0;
          pontosComputador = 0;
        }
      }

      animacaoResultadoTick++;
    });

    if (mensagemCampeao != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemCampeao!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void resetarPlacar() {
    setState(() {
      pontosJogador = 0;
      pontosComputador = 0;
      totalPartidas = 0;
      ultimaEscolhaJogador = '-';
      ultimaEscolhaComputador = '-';
      resultado = 'Placar resetado. Escolha uma opcao';
      tipoResultado = 'neutro';
      animacaoResultadoTick++;
      iconeComputador = Icons.help_outline;
    });
  }

  IconData _iconeDaOpcao(String opcao) {
    if (opcao == 'pedra') {
      return Icons.landscape;
    }
    if (opcao == 'papel') {
      return Icons.pan_tool;
    }
    return Icons.content_cut;
  }

  Color _corDoResultado() {
    if (resultado.contains('venceu') && resultado.contains('Voce')) {
      return const Color(0xFF1D7A44);
    }
    if (resultado.contains('Computador')) {
      return const Color(0xFF9D2222);
    }
    if (resultado.contains('Empate')) {
      return const Color(0xFF465A78);
    }
    return const Color(0xFF2F3E4E);
  }

  Color _corDaEscolha(String valor) {
    if (valor == 'pedra') {
      return const Color(0xFF577590);
    }
    if (valor == 'papel') {
      return const Color(0xFF43AA8B);
    }
    if (valor == 'tesoura') {
      return const Color(0xFFF3722C);
    }
    return const Color(0xFF7D8597);
  }

  Color _corGlowResultado() {
    if (tipoResultado == 'vitoria') {
      return const Color(0xFF1D7A44);
    }
    if (tipoResultado == 'derrota') {
      return const Color(0xFF9D2222);
    }
    if (tipoResultado == 'empate') {
      return const Color(0xFF577590);
    }
    return const Color(0xFF8EA7B8);
  }

  Widget _botaoEscolha({
    required IconData icone,
    required String texto,
    required String valor,
  }) {
    return FilledButton.icon(
      onPressed: () => jogar(valor),
      icon: Icon(icone),
      label: Text(texto),
      style: FilledButton.styleFrom(
        backgroundColor: _corDaEscolha(valor),
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressoJogador = pontosJogador / pontosParaCampeonato;
    final progressoComputador = pontosComputador / pontosParaCampeonato;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F8B8D), Color(0xFF3AAFA9)],
            ),
          ),
        ),
        title: const Text(
          'Pedra Papel Tesoura',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD7F4EF), Color(0xFFFFF1DE), Color(0xFFEAF4FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: fadePlacar,
                      child: SlideTransition(
                        position: slidePlacar,
                        child: Card(
                          color: const Color(
                            0xFFFFFFFF,
                          ).withValues(alpha: 0.88),
                          shadowColor: const Color(
                            0xFF43AA8B,
                          ).withValues(alpha: 0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Campeonato ate 5 pontos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 72,
                                      child: Text('Voce'),
                                    ),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progressoJogador,
                                        borderRadius: BorderRadius.circular(8),
                                        minHeight: 10,
                                        color: const Color(0xFF43AA8B),
                                        backgroundColor: const Color(
                                          0xFFDAF0E9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$pontosJogador/$pontosParaCampeonato',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 72,
                                      child: Text('PC'),
                                    ),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progressoComputador,
                                        borderRadius: BorderRadius.circular(8),
                                        minHeight: 10,
                                        color: const Color(0xFFE76F51),
                                        backgroundColor: const Color(
                                          0xFFF5D7CF,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$pontosComputador/$pontosParaCampeonato',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: fadeResultado,
                      child: SlideTransition(
                        position: slideResultado,
                        child: Card(
                          elevation: 2,
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                          shadowColor: const Color(
                            0xFF577590,
                          ).withValues(alpha: 0.28),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'Escolha do Computador',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _corDaEscolha(
                                          ultimaEscolhaComputador,
                                        ).withValues(alpha: 0.2),
                                        _corDaEscolha(
                                          ultimaEscolhaComputador,
                                        ).withValues(alpha: 0.06),
                                      ],
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 280),
                                    child: Icon(
                                      iconeComputador,
                                      key: ValueKey<IconData>(iconeComputador),
                                      size: 96,
                                      color: const Color(0xFF264653),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _corGlowResultado().withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _corGlowResultado().withValues(
                                        alpha: 0.32,
                                      ),
                                    ),
                                  ),
                                  child: TweenAnimationBuilder<double>(
                                    key: ValueKey<int>(animacaoResultadoTick),
                                    tween: Tween(begin: 0.9, end: 1),
                                    duration: const Duration(milliseconds: 420),
                                    curve: Curves.elasticOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      resultado,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: _corDoResultado(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Partidas jogadas: $totalPartidas',
                                  style: const TextStyle(
                                    color: Color(0xFF52606D),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Chip(
                                      avatar: const Icon(
                                        Icons.person,
                                        size: 16,
                                      ),
                                      label: Text(ultimaEscolhaJogador),
                                      backgroundColor: _corDaEscolha(
                                        ultimaEscolhaJogador,
                                      ).withValues(alpha: 0.18),
                                      side: BorderSide.none,
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      avatar: const Icon(
                                        Icons.smart_toy,
                                        size: 16,
                                      ),
                                      label: Text(ultimaEscolhaComputador),
                                      backgroundColor: _corDaEscolha(
                                        ultimaEscolhaComputador,
                                      ).withValues(alpha: 0.18),
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: fadeAcoes,
                      child: SlideTransition(
                        position: slideAcoes,
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                _botaoEscolha(
                                  icone: Icons.landscape,
                                  texto: 'Pedra',
                                  valor: 'pedra',
                                ),
                                _botaoEscolha(
                                  icone: Icons.pan_tool,
                                  texto: 'Papel',
                                  valor: 'papel',
                                ),
                                _botaoEscolha(
                                  icone: Icons.content_cut,
                                  texto: 'Tesoura',
                                  valor: 'tesoura',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: resetarPlacar,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Resetar Placar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F8B8D),
                                side: const BorderSide(
                                  color: Color(0xFF0F8B8D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
