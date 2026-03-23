import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Dados fixos de cada contato (lista manual).
class Contato {
  const Contato({
    required this.nome,
    required this.telefone,
    required this.cor,
    required this.icone,
  });

  final String nome;
  final String telefone;
  final Color cor;
  final IconData icone;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ListaContatos(),
    );
  }
}

class ListaContatos extends StatelessWidget {
  const ListaContatos({super.key});

  static const List<Contato> contatos = [
    Contato(
      nome: 'Ana Silva',
      telefone: '(11) 98765-4321',
      cor: Color(0xFF1565C0),
      icone: Icons.phone_android,
    ),
    Contato(
      nome: 'Bruno Costa',
      telefone: '(21) 91234-5678',
      cor: Color(0xFF2E7D32),
      icone: Icons.contact_phone,
    ),
    Contato(
      nome: 'Carla Mendes',
      telefone: '(31) 99887-6655',
      cor: Color(0xFF6A1B9A),
      icone: Icons.person,
    ),
    Contato(
      nome: 'Diego Ramos',
      telefone: '(41) 97777-1111',
      cor: Color(0xFFC62828),
      icone: Icons.smartphone,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de contatos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: contatos.length,
        separatorBuilder: (context, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = contatos[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: c.cor.withValues(alpha: 0.2),
              foregroundColor: c.cor,
              child: Icon(c.icone),
            ),
            title: Text(c.nome),
            subtitle: Text(c.telefone),
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => DetalheContato(
                    nome: c.nome,
                    telefone: c.telefone,
                    cor: c.cor,
                    icone: c.icone,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetalheContato extends StatelessWidget {
  const DetalheContato({
    super.key,
    required this.nome,
    required this.telefone,
    required this.cor,
    required this.icone,
  });

  final String nome;
  final String telefone;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do contato'),
        backgroundColor: cor.withValues(alpha: 0.25),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: cor.withValues(alpha: 0.2),
              foregroundColor: cor,
              child: Icon(icone, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              nome,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              telefone,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ligando para $nome...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.call),
              label: const Text('Ligar'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
