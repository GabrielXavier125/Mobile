import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Mensagens de sucesso/erro exibidas após as operações no banco.
void mostrarSucesso(BuildContext context, String mensagem) {
  _mostrar(context, mensagem, Icons.check_circle, Colors.green.shade700);
}

void mostrarErro(BuildContext context, String mensagem) {
  _mostrar(context, mensagem, Icons.error, Colors.red.shade700);
}

void _mostrar(BuildContext context, String mensagem, IconData icone, Color cor) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: cor,
        content: Row(
          children: [
            Icon(icone, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensagem)),
          ],
        ),
      ),
    );
}

/// Traduz os erros mais comuns do Firestore para o usuário.
String descreverErro(Object erro) {
  if (erro is FirebaseException) {
    switch (erro.code) {
      case 'permission-denied':
        return 'Operação bloqueada pelas regras de segurança do Firestore.';
      case 'unavailable':
        return 'Sem conexão com o servidor. Verifique a internet.';
      case 'not-found':
        return 'O registro não existe mais no banco.';
      default:
        return erro.message ?? 'Erro no Firestore (${erro.code}).';
    }
  }
  return 'Erro inesperado: $erro';
}
