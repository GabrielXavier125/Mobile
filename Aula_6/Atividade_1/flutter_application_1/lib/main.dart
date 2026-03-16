import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const TrafficLightShowcaseApp());
}

class TrafficLightShowcaseApp extends StatelessWidget {
  const TrafficLightShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3DDC97),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Color(0xFFD6E3F0),
          ),
        ),
      ),
      home: const SemaforoApp(),
    );
  }
}

class SemaforoApp extends StatefulWidget {
  const SemaforoApp({super.key});

  @override
  State<SemaforoApp> createState() => _SemaforoAppState();
}

class _SemaforoAppState extends State<SemaforoApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int estado = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void mudarSemaforo() {
    setState(() {
      estado = (estado + 1) % 3;
    });
  }

  SignalState get currentSignal {
    switch (estado) {
      case 0:
        return const SignalState(
          index: 0,
          title: 'Fluxo liberado',
          subtitle: 'Veiculos podem seguir com seguranca.',
          pedestrianLabel: 'Pedestre: aguarde',
          pedestrianHint: 'Travessia bloqueada no momento.',
          accent: Color(0xFF3DDC97),
          secondary: Color(0xFF0F8A5F),
          icon: Icons.directions_car_filled_rounded,
          pedestrianIcon: Icons.pan_tool_alt_rounded,
        );
      case 1:
        return const SignalState(
          index: 1,
          title: 'Atencao total',
          subtitle: 'Reducao de velocidade e preparo para parada.',
          pedestrianLabel: 'Pedestre: prepare-se',
          pedestrianHint: 'O sinal vai mudar em instantes.',
          accent: Color(0xFFF8C146),
          secondary: Color(0xFFC98012),
          icon: Icons.warning_amber_rounded,
          pedestrianIcon: Icons.access_time_filled_rounded,
        );
      default:
        return const SignalState(
          index: 2,
          title: 'Parada obrigatoria',
          subtitle: 'Travessia aberta com prioridade para pedestres.',
          pedestrianLabel: 'Pedestre: atravesse',
          pedestrianHint: 'Faixa liberada com seguranca.',
          accent: Color(0xFFFF5A6B),
          secondary: Color(0xFFB4233D),
          icon: Icons.do_not_disturb_on_rounded,
          pedestrianIcon: Icons.directions_walk_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signal = currentSignal;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF08101D), Color(0xFF0D1B2E), Color(0xFF07111F)],
          ),
        ),
        child: Stack(
          children: [
            const _BackgroundGlow(
              alignment: Alignment.topLeft,
              color: Color(0xFF1F8A70),
              size: 240,
            ),
            const _BackgroundGlow(
              alignment: Alignment.bottomRight,
              color: Color(0xFF103F91),
              size: 280,
            ),
            const _BackgroundGlow(
              alignment: Alignment(0.15, -0.25),
              color: Color(0x66F8C146),
              size: 180,
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 760;

                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.10),
                                  Colors.white.withValues(alpha: 0.04),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: signal.accent.withValues(alpha: 0.18),
                                  blurRadius: 42,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 18,
                                  sigmaY: 18,
                                ),
                                child: Flex(
                                  direction: isWide
                                      ? Axis.horizontal
                                      : Axis.vertical,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: isWide ? 28 : 0,
                                          bottom: isWide ? 0 : 28,
                                        ),
                                        child: _buildInfoPanel(theme, signal),
                                      ),
                                    ),
                                    Expanded(child: _buildVisualPanel(signal)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(ThemeData theme, SignalState signal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: signal.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: signal.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.traffic_rounded, size: 18, color: signal.accent),
              const SizedBox(width: 8),
              Text(
                'Controle urbano interativo',
                style: TextStyle(
                  color: signal.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Semaforo de transito com visual premium.',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 14),
        Text(
          'Cada toque atualiza o sinal com transicoes suaves, brilho dinamico e um painel de status mais expressivo.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                signal.accent.withValues(alpha: 0.22),
                signal.secondary.withValues(alpha: 0.18),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(signal.title),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: Icon(signal.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        signal.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  signal.subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Color(0xFFF5F7FA),
                  ),
                ),
                const SizedBox(height: 16),
                _StatusPill(
                  color: signal.accent,
                  icon: signal.pedestrianIcon,
                  title: signal.pedestrianLabel,
                  subtitle: signal.pedestrianHint,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoChip(label: 'Estado ${signal.index + 1}/3', value: 'Dinâmico'),
            const _InfoChip(label: 'Transicao', value: 'Animada'),
            const _InfoChip(label: 'Painel', value: 'Interativo'),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [signal.accent, signal.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: signal.accent.withValues(alpha: 0.34),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: mudarSemaforo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              icon: const Icon(Icons.touch_app_rounded),
              label: const Text(
                'Mudar semaforo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualPanel(SignalState signal) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(_pulseController.value);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF172230), Color(0xFF0C121B)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _TrafficLightBulb(
                    color: const Color(0xFFFF5A6B),
                    isActive: estado == 2,
                    pulse: pulse,
                  ),
                  const SizedBox(height: 18),
                  _TrafficLightBulb(
                    color: const Color(0xFFF8C146),
                    isActive: estado == 1,
                    pulse: pulse,
                  ),
                  const SizedBox(height: 18),
                  _TrafficLightBulb(
                    color: const Color(0xFF3DDC97),
                    isActive: estado == 0,
                    pulse: pulse,
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 110,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF263748), Color(0xFF101821)],
                ),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1722),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: signal.accent.withValues(alpha: 0.26),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Icon(
                      signal.pedestrianIcon,
                      key: ValueKey(signal.pedestrianLabel),
                      size: 34,
                      color: signal.index == 2
                          ? const Color(0xFF3DDC97)
                          : signal.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      signal.pedestrianLabel,
                      key: ValueKey(signal.pedestrianHint),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SignalState {
  const SignalState({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.pedestrianLabel,
    required this.pedestrianHint,
    required this.accent,
    required this.secondary,
    required this.icon,
    required this.pedestrianIcon,
  });

  final int index;
  final String title;
  final String subtitle;
  final String pedestrianLabel;
  final String pedestrianHint;
  final Color accent;
  final Color secondary;
  final IconData icon;
  final IconData pedestrianIcon;
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrafficLightBulb extends StatelessWidget {
  const _TrafficLightBulb({
    required this.color,
    required this.isActive,
    required this.pulse,
  });

  final Color color;
  final bool isActive;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final glowSpread = isActive ? 18 + (10 * pulse) : 0.0;
    final glowBlur = isActive ? 28 + (12 * pulse) : 0.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      scale: isActive ? 1.03 : 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isActive
                ? [Colors.white, color, color.withValues(alpha: 0.82)]
                : [
                    const Color(0xFF48525F),
                    const Color(0xFF2E3640),
                    const Color(0xFF1D232B),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? color.withValues(alpha: 0.60)
                  : Colors.black.withValues(alpha: 0.24),
              blurRadius: glowBlur,
              spreadRadius: glowSpread,
            ),
            insetShadow(
              color: Colors.black.withValues(alpha: isActive ? 0.08 : 0.32),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: isActive ? 0.24 : 0.08),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  static BoxShadow insetShadow({required Color color}) {
    return BoxShadow(
      color: color,
      blurRadius: 18,
      spreadRadius: -8,
      offset: const Offset(0, 10),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFD7E2ED),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9DB0C6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
