import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF24445C)),
      ),
      home: const TemperaturaApp(),
    ),
  );
}

class TemperaturaApp extends StatefulWidget {
  const TemperaturaApp({super.key});

  @override
  State<TemperaturaApp> createState() => _TemperaturaAppState();
}

class _TemperaturaAppState extends State<TemperaturaApp> {
  int temperatura = 22;

  void aumentar() {
    setState(() {
      temperatura++;
    });
  }

  void diminuir() {
    setState(() {
      temperatura--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visualForTemperature(temperatura);
    final progress = ((temperatura + 5) / 45).clamp(0.0, 1.0);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: visual.background,
          ),
        ),
        child: Stack(
          children: [
            _GlowOrb(
              alignment: const Alignment(-1.1, -0.9),
              color: visual.highlight.withValues(alpha: 0.45),
              size: 220,
            ),
            _GlowOrb(
              alignment: const Alignment(1.0, -0.15),
              color: Colors.white.withValues(alpha: 0.16),
              size: 180,
            ),
            _GlowOrb(
              alignment: const Alignment(0.9, 1.0),
              color: visual.accent.withValues(alpha: 0.28),
              size: 260,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Painel Climatico',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajuste a temperatura e acompanhe o clima com uma interface mais viva.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.16,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'Estado atual',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.86,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 450,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutBack,
                                          ),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        visual.icon,
                                        key: ValueKey(visual.label),
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.18),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    visual.label,
                                    key: ValueKey(visual.label),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Text(
                                    visual.description,
                                    key: ValueKey(visual.description),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.80,
                                          ),
                                          height: 1.35,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Temperatura',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.74,
                                                ),
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              transitionBuilder:
                                                  (child, animation) {
                                                    return ScaleTransition(
                                                      scale: animation,
                                                      child: FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                              child: Text(
                                                '$temperatura °C',
                                                key: ValueKey(temperatura),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w700,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 72,
                                        height: 150,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            width: double.infinity,
                                            height: 134 * progress,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  visual.accent,
                                                  visual.highlight,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _TemperatureButton(
                                        label: 'Diminuir',
                                        icon: Icons.remove,
                                        onPressed: diminuir,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _TemperatureButton(
                                        label: 'Aumentar',
                                        icon: Icons.add,
                                        emphasized: true,
                                        onPressed: aumentar,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  _TemperatureVisual _visualForTemperature(int value) {
    if (value < 15) {
      return const _TemperatureVisual(
        label: 'Frio intenso',
        description: 'Clima fresco com energia de inverno e tons profundos.',
        icon: Icons.ac_unit_rounded,
        background: [Color(0xFF0A2342), Color(0xFF174A7E), Color(0xFF56CFE1)],
        accent: Color(0xFF8EECF5),
        highlight: Color(0xFFD7F9FF),
      );
    }

    if (value < 30) {
      return const _TemperatureVisual(
        label: 'Confortavel',
        description: 'Equilibrio ideal para um ambiente leve e agradavel.',
        icon: Icons.wb_sunny_rounded,
        background: [Color(0xFF0B3D2E), Color(0xFF2D6A4F), Color(0xFF95D5B2)],
        accent: Color(0xFFFFD166),
        highlight: Color(0xFFFFF0A8),
      );
    }

    return const _TemperatureVisual(
      label: 'Calor alto',
      description: 'Temperatura elevada com visual vibrante e mais dramatico.',
      icon: Icons.local_fire_department_rounded,
      background: [Color(0xFF5F0F40), Color(0xFF9A031E), Color(0xFFFB8B24)],
      accent: Color(0xFFFFC15E),
      highlight: Color(0xFFFFE6A7),
    );
  }
}

class _TemperatureVisual {
  const _TemperatureVisual({
    required this.label,
    required this.description,
    required this.icon,
    required this.background,
    required this.accent,
    required this.highlight,
  });

  final String label;
  final String description;
  final IconData icon;
  final List<Color> background;
  final Color accent;
  final Color highlight;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 110, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}

class _TemperatureButton extends StatelessWidget {
  const _TemperatureButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: emphasized
            ? Colors.white.withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.18),
        foregroundColor: emphasized ? const Color(0xFF16324F) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 10), Text(label)],
      ),
    );
  }
}
