import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Atividade Aula 8',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AtividadeHomePage(),
    );
  }
}

class AtividadeHomePage extends StatelessWidget {
  const AtividadeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Atividades SharedPreferences'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sticky_note_2_outlined), text: 'Notas'),
              Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Compras'),
            ],
          ),
        ),
        body: const TabBarView(children: [AppNotas(), ListaComprasPage()]),
      ),
    );
  }
}

class AppNotas extends StatefulWidget {
  const AppNotas({super.key});

  @override
  State<AppNotas> createState() => _AppNotasState();
}

class _AppNotasState extends State<AppNotas> {
  List<String> notas = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarNotas();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void adicionarNota() {
    if (controller.text.isNotEmpty) {
      setState(() {
        notas.add(controller.text);
        controller.clear();
      });
      salvarNotas();
    }
  }

  void removerNota(int index) {
    setState(() {
      notas.removeAt(index);
    });
    salvarNotas();
  }

  Future<void> salvarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notas', notas);
  }

  Future<void> carregarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notas = prefs.getStringList('notas') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Digite uma nota',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => adicionarNota(),
            ),
          ),
          ElevatedButton(
            onPressed: adicionarNota,
            child: const Text('Salvar Nota'),
          ),
          Expanded(
            child: notas.isEmpty
                ? const Center(child: Text('Nenhuma nota ainda'))
                : ListView.builder(
                    itemCount: notas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notas[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removerNota(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  final TextEditingController controller = TextEditingController();
  List<String> itens = [];
  List<bool> comprado = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void adicionarItem() {
    if (controller.text.isEmpty) {
      return;
    }

    setState(() {
      itens.add(controller.text);
      comprado.add(false);
      controller.clear();
    });

    salvarDados();
  }

  void alternarComprado(int index) {
    setState(() {
      comprado[index] = !comprado[index];
    });

    salvarDados();
  }

  void removerItem(int index) {
    setState(() {
      itens.removeAt(index);
      comprado.removeAt(index);
    });

    salvarDados();
  }

  void limparLista() {
    setState(() {
      itens.clear();
      comprado.clear();
    });

    salvarDados();
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('itens', itens);
    await prefs.setStringList(
      'comprado',
      comprado.map((item) => item.toString()).toList(),
    );
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final itensSalvos = prefs.getStringList('itens') ?? [];
    final listaBool = prefs.getStringList('comprado') ?? [];

    setState(() {
      itens = itensSalvos;
      comprado = listaBool.map((item) => item == 'true').toList();
      while (comprado.length < itens.length) {
        comprado.add(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalComprados = comprado.where((item) => item).length;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Adicionar item',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => adicionarItem(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: adicionarItem,
                    child: const Text('Adicionar Item'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: itens.isEmpty ? null : limparLista,
                    child: const Text('Limpar Lista'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Itens: ${itens.length} | Comprados: $totalComprados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: itens.isEmpty
                ? const Center(child: Text('Nenhum item na lista'))
                : ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final itemComprado = comprado[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: itemComprado,
                            onChanged: (_) => alternarComprado(index),
                          ),
                          title: Text(
                            itens[index],
                            style: TextStyle(
                              color: itemComprado
                                  ? Colors.green.shade700
                                  : null,
                              decoration: itemComprado
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removerItem(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
