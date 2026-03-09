import 'package:flutter/material.dart';

// PARTE 1 - Estrutura Inicial

/// Passo 1 - Criar o main()
void main() {
  runApp(const MyApp());
}

/// Passo 2 - Criar o MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false ,
      home: TodoPage());
  }
}

// PARTE 2 - Criando a Tela com Estado

/// Passo 3 - Criar a TodoPage
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

/// Estado da TodoPage
class _TodoPageState extends State<TodoPage> {
  // PARTE 3 - Criando o Estado

  /// Passo 4 - Criar a Lista
  final List<String> tarefas = [];

  /// Passo 5 - Criar o Controller
  final TextEditingController controller = TextEditingController();

  // PARTE 5 - Criando Função para Adicionar

  /// Passo 6 - Criar função adicionarTarefa
  void adicionarTarefa() {
    setState(() {
      tarefas.add(controller.text);
    });
    controller.clear();
    print(tarefas);
  }

  // PARTE 7 - Removendo Tarefa

  /// Passo 8 - Criar função removerTarefa
  void removerTarefa(int index) {
    setState(() {
      tarefas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Tarefas")),
      // PARTE 4 - Montando o Layout
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Digite uma tarefa...",
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          // Passo 7 - Conectar o Botão
          ElevatedButton(
            onPressed: adicionarTarefa,
            child: const Text("Adicionar"),
          ),
          // PARTE 6 - Exibindo a Lista
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tarefas[index]),
                  // Passo 9 - Adicionar botão de excluir
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removerTarefa(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
