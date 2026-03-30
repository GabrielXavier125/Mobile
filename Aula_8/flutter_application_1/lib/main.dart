import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: SalvarTextoApp()),
  );
}

class SalvarTextoApp extends StatefulWidget {
  @override
  _SalvarTextoAppState createState() => _SalvarTextoAppState();
}

class _SalvarTextoAppState extends State<SalvarTextoApp> {
  TextEditingController _textController = TextEditingController();
  String textoSalvo = '';

  void salvarTexto() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('texto', _textController.text);

    setState(() {
      textoSalvo = _textController.text;
    });
  }

  void carregarTexto() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      textoSalvo = prefs.getString('texto') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    carregarTexto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salvar Texto com SharedPreferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Digite algo para salvar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarTexto,
              child: Text('Salvar Texto'),
            ),
            SizedBox(height: 20),
            Text('Texto salvo: $textoSalvo'),
          ],
        ),
      ),
    );
  }

}
