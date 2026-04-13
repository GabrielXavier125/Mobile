import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' show join;

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro Inteligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

// ─── Model ───────────────────────────────────────────────────────────────────

class Item {
  final int? id;
  final String titulo;
  final String descricao;
  final String data;

  Item({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
      };

  factory Item.fromMap(Map<String, dynamic> map) => Item(
        id: map['id'],
        titulo: map['titulo'],
        descricao: map['descricao'],
        data: map['data'] ?? '',
      );
}

// ─── Database Helper ─────────────────────────────────────────────────────────

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'cadastro.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE dados (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT,
          descricao TEXT,
          data TEXT
        )
      '''),
    );
  }

  static Future<int> inserir(Item item) async {
    final db = await database;
    return db.insert('dados', item.toMap());
  }

  static Future<List<Item>> listar() async {
    final db = await database;
    final maps = await db.query('dados', orderBy: 'titulo ASC');
    return maps.map(Item.fromMap).toList();
  }

  static Future<int> atualizar(Item item) async {
    final db = await database;
    return db.update(
      'dados',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<int> remover(int id) async {
    final db = await database;
    return db.delete('dados', where: 'id = ?', whereArgs: [id]);
  }
}

// ─── Home Page ───────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> _itens = [];

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    final itens = await DatabaseHelper.listar();
    setState(() => _itens = itens);
  }

  Future<void> _removerItem(int id) async {
    await DatabaseHelper.remover(id);
    await _carregarItens();
  }

  void _abrirFormulario({Item? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioPage(item: item, onSalvar: _carregarItens),
      ),
    );
  }

  void _confirmarRemocao(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja remover este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removerItem(id);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cadastro Inteligente'),
      ),
      body: _itens.isEmpty
          ? const Center(
              child: Text(
                'Nenhum item cadastrado',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _itens.length,
              itemBuilder: (context, index) {
                final item = _itens[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      item.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.descricao),
                        if (item.data.isNotEmpty)
                          Text(
                            'Criado em: ${item.data}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    onTap: () => _abrirFormulario(item: item),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarRemocao(item.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        tooltip: 'Novo item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Form Page ───────────────────────────────────────────────────────────────

class FormularioPage extends StatefulWidget {
  final Item? item;
  final VoidCallback onSalvar;

  const FormularioPage({super.key, this.item, required this.onSalvar});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _descricaoCtrl;

  bool get _editando => widget.item != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.item?.titulo ?? '');
    _descricaoCtrl = TextEditingController(text: widget.item?.descricao ?? '');
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final agora = DateTime.now();
    final dataFormatada =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';

    final item = Item(
      id: widget.item?.id,
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      data: _editando ? widget.item!.data : dataFormatada,
    );

    if (_editando) {
      await DatabaseHelper.atualizar(item);
    } else {
      await DatabaseHelper.inserir(item);
    }

    widget.onSalvar();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_editando ? 'Editar Item' : 'Novo Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
