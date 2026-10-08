# ⚠️ O que ainda falta: ligar o app ao Firebase real

## Situação atual

| Item | Status |
|---|---|
| Telas, CRUD, pesquisa, filtros, favoritos, navegação | ✅ Prontos |
| Testes automatizados (31 de unidade/widget + integração T01–T10) | ✅ Passando |
| Regras de segurança (`firestore.rules`) | ✅ Escritas e validadas no **emulador local** — ⏳ falta publicar |
| Projeto no Firebase / banco Cloud Firestore | ⏳ **Falta criar** |
| `lib/firebase_options.dart` | ⏳ **Provisório** — falta gerar com o FlutterFire |
| 10+ locais cadastrados no Firestore | ⏳ Falta popular o banco real |
| Print do Console do Firestore | ⏳ Falta tirar |

Até agora o app foi testado com o **emulador local do Firestore** (um banco que roda no
computador). Enquanto os passos abaixo não forem feitos, um `flutter run` normal **não carrega
dados**, porque `firebase_options.dart` aponta para um projeto de demonstração
(`demo-mapa-locais`).

---

## Passo a passo (cerca de 10 minutos)

Todos os comandos são executados **dentro da pasta `mapa_locais`**.

### 1. Fazer login no Firebase CLI

```bash
firebase login
```

O comando mostra um link e um código de sessão. Abra o link, entre com sua conta Google,
copie o **código de autorização** exibido e finalize com:

```bash
firebase login SEU_CODIGO
```

Confira com `firebase login:list`.

### 2. Criar o projeto no Firebase

Pelo Console (como no tutorial, item 9.2): <https://console.firebase.google.com> →
**Adicionar projeto** → nome `mapa-locais-flutter` → concluir.

Ou pelo terminal (o ID precisa ser único no mundo):

```bash
firebase projects:create mapa-locais-gabriel --display-name "Mapa Locais Flutter"
```

### 3. Criar o banco Cloud Firestore

Console → **Firestore Database** → **Criar banco de dados** → local
**`southamerica-east1` (São Paulo)** → **modo de produção** (as regras do projeto serão
publicadas no passo 5).

Ou pelo terminal:

```bash
firebase firestore:databases:create "(default)" --location=southamerica-east1 --project SEU_PROJECT_ID
```

### 4. Configurar o Flutter com o FlutterFire CLI

```bash
flutterfire configure --project=SEU_PROJECT_ID --platforms=android
```

Isso **substitui** `lib/firebase_options.dart` pelo arquivo real e cria
`android/app/google-services.json`. Não edite esses arquivos à mão.

> Se aparecer "flutterfire não é reconhecido", use
> `dart pub global run flutterfire_cli:flutterfire configure ...` ou adicione
> `%LOCALAPPDATA%\Pub\Cache\bin` ao PATH.

### 5. Publicar as regras de segurança

```bash
firebase deploy --only firestore:rules,firestore:indexes --project SEU_PROJECT_ID
```

### 6. Popular o banco (mínimo de 10 locais)

```bash
flutter run
```

No app: **Ver resultados** → **Cadastrar locais de exemplo**. Isso cadastra 20 locais
(São Paulo, Campinas e Jundiaí).

### 7. Rodar os testes no banco real

```bash
flutter test
flutter test integration_test -d emulator-5554
```

O teste de integração cria, edita, favorita e exclui um local próprio, sem mexer nos outros.

### 8. Tirar o print do Firestore e atualizar a documentação

1. Console → Firestore Database → coleção `locais` → salvar o print como
   `docs/prints/firestore_console.png`.
2. No `README.md`, atualizar a seção 10 (testes executados no banco real) e a seção 11 (print).

### 9. Enviar para o GitHub

```bash
git add .
git commit -m "Configura Firebase real (FlutterFire + regras + dados)"
git push
```

---

## Desenvolver sem o Firebase real (emulador local)

```bash
# terminal 1 — banco local (precisa do Java do Android Studio no PATH)
firebase emulators:start --only firestore --project demo-mapa-locais

# terminal 2 — app apontando para o emulador
flutter run --dart-define=USAR_EMULADOR=true
```

Depois que o `flutterfire configure` substituir o `firebase_options.dart`, o modo emulador
continua funcionando só com a flag `USAR_EMULADOR=true`.

## Dica: emulador sem internet

Em redes de escola/empresa o emulador Android pode ficar sem internet (o mapa fica cinza).
Abra-o com `iniciar_emulador.bat`: ele escolhe servidores DNS que funcionam na rede atual.
