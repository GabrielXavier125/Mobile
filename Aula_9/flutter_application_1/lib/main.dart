import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AppBanco()));
}

class AppBanco extends StatefulWidget {
  @override
  _AppBancoState createState() => _AppBancoState();
}

class _AppBancoState extends State<AppBanco> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _tarefas = [];

  Future<Database> _criarBanco() async {
    final caminho = await getDatabasesPath();
    final path = join(caminho, 'banco.db');

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tarefas (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> inserirTarefas(String nome) async {
    final db = await _criarBanco();
    
    await db.insert('tarefas', {'nome': nome});

    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final db = await _criarBanco();
    
    final List<Map<String, dynamic>> tarefas = await db.query('tarefas');

    setState(() {
      _tarefas = tarefas;
    });
  }

  Future<void> deletarTarefa(int id) async {
    final db = await _criarBanco();
    await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
    carregarTarefas();
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarefas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Nova Tarefa'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      inserirTarefas(_controller.text);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tarefas[index]['nome']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deletarTarefa(_tarefas[index]['id']),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}