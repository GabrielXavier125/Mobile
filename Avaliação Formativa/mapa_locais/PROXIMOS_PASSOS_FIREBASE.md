# Pendências para concluir a Avaliação Formativa

## Situação atual (28/10/2026)

| Item | Status |
|---|---|
| Telas, CRUD, pesquisa, filtros, favoritos, navegação | ✅ Prontos |
| Projeto Firebase `mapa-locais-gabriel` (conta Gmail pessoal) | ✅ Criado |
| Cloud Firestore (região `nam5`) + coleção `locais` | ✅ Criado |
| `flutterfire configure` (`firebase_options.dart`, `google-services.json`) | ✅ Feito |
| Regras de segurança publicadas | ✅ Publicadas e testadas (dado inválido → 403) |
| 10+ locais cadastrados no Firestore | ✅ 20 locais |
| Testes no Firestore real (integração T01–T10 + 31 unidade/widget) | ✅ Passando no Pixel 8 |
| **Print do Console do Firestore** | ⏳ **Falta** |
| **Documentação técnica (exigida pelo professor)** | ⏳ **Falta** |

## 📌 Documentação técnica — exigência do professor

Além do `README.md`, o professor pediu uma **documentação técnica** do projeto que explique:

- **Funcionalidades:** o que cada tela faz (mapa, resultados, detalhes), o fluxo de uso e as
  ações (pesquisar, filtrar, cadastrar, editar, excluir, favoritar, ver no mapa, ligar, rotas).
- **Conexões:** como o app se conecta ao Firebase (`firebase_core`, `firebase_options.dart`,
  `google-services.json`), como lê e grava no Cloud Firestore (coleção `locais`, `snapshots()`
  em tempo real, CRUD), regras de segurança, mapa (OpenStreetMap) e integrações com o
  Android (discador e Google Maps).
- **Funcionamento interno:** arquitetura em camadas, modelo de dados, testes e como executar.

---

## O que falta fazer

### 1. Print do Console do Firestore

1. Abrir <https://console.firebase.google.com/project/mapa-locais-gabriel/firestore> logado com
   o **Gmail pessoal** (a conta `@aluno.senai.br` não tem acesso ao projeto).
2. Clicar na coleção `locais` para mostrar os documentos e campos.
3. Salvar o print como `docs/prints/firestore_console.png`.

### 2. Gerar a documentação técnica (Word/PDF)

Com o print do Firestore e as capturas das telas, gerar o documento descrito acima e salvá-lo em
`docs/`.

### 3. Enviar para o GitHub

```bash
git add .
git commit -m "Adiciona print do Firestore e documentação técnica"
git push
```

### 4. Preparar a apresentação

- Abrir o emulador com `iniciar_emulador.bat` antes de apresentar (sem ele, nesta rede o
  emulador fica sem internet).
- Revisar `lib/services/local_service.dart` (CRUD) e `firestore.rules` (segurança).

---

## Como o Firebase foi configurado (referência)

```bash
firebase login                                   # Gmail pessoal (contas da escola não podem criar projetos)
firebase projects:create mapa-locais-gabriel     # + aceite dos termos no Console
firebase deploy --only firestore:rules --project mapa-locais-gabriel   # ativou a API, criou o banco e publicou as regras
flutterfire configure --project=mapa-locais-gabriel --platforms=android
```

Os dados foram cadastrados pelo próprio app (Resultados → "Cadastrar locais de exemplo").

## Desenvolver sem o Firebase real (emulador local)

```bash
firebase emulators:start --only firestore --project demo-mapa-locais
flutter run --dart-define=USAR_EMULADOR=true
```

## Dicas

- **Emulador sem internet:** use `iniciar_emulador.bat` (escolhe servidores DNS que funcionam).
- **Acentos no caminho:** use `dart analyze` em vez de `flutter analyze` nesta pasta;
  `android/gradle.properties` já tem `android.overridePathCheck=true`.
- **Comando `firebase` não encontrado:** feche e reabra o VS Code (o PATH foi atualizado) ou use
  `& "$env:APPDATA\npm\firebase.cmd"`.
