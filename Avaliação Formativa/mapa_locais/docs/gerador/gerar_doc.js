// Gera a Documentação Técnica do app Mapa de Locais (.docx)
// Uso: node gerar_doc.js <pasta docs do projeto> <arquivo de saída .docx>
const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, ImageRun, Table, TableRow, TableCell,
  WidthType, ShadingType, AlignmentType, TableOfContents, Header, Footer, PageNumber,
  PageBreak, LevelFormat, BorderStyle, VerticalAlign,
} = require('docx');

const DOCS = process.argv[2];
const SAIDA = process.argv[3];
const img = (rel) => fs.readFileSync(path.join(DOCS, rel));

const FONTE = 'Calibri';
const MONO = 'Consolas';
const AZUL = '1F4E79';
const LARGURA = 9071; // A4 com margens 3 cm / 2 cm, em DXA

// ---------- helpers de texto ----------
function runs(texto, base = {}) {
  // **negrito** e `código` dentro do texto
  return texto.split(/(\*\*[^*]+\*\*|`[^`]+`)/).filter(Boolean).map((t) => {
    if (t.startsWith('**')) return new TextRun({ ...base, text: t.slice(2, -2), bold: true });
    if (t.startsWith('`')) return new TextRun({ ...base, text: t.slice(1, -1), font: MONO, size: 20, color: '9A3412' });
    return new TextRun({ ...base, text: t });
  });
}
const p = (texto, opts = {}) => new Paragraph({ children: runs(texto), spacing: { after: 120, line: 288 }, alignment: AlignmentType.JUSTIFIED, ...opts });
const h1 = (texto) => new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(texto)], pageBreakBefore: true });
const h2 = (texto) => new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(texto)] });
const h3 = (texto) => new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(texto)] });
const bullet = (texto, nivel = 0) => new Paragraph({ children: runs(texto), numbering: { reference: 'marcadores', level: nivel }, spacing: { after: 60, line: 276 } });
// `lista` diferente reinicia a numeração em 1
const numero = (texto, lista = 1) => new Paragraph({ children: runs(texto), numbering: { reference: 'numeros', level: 0, instance: lista }, spacing: { after: 60, line: 276 } });
const legenda = (texto) => new Paragraph({ children: [new TextRun({ text: texto, italics: true, size: 18, color: '555555' })], alignment: AlignmentType.CENTER, spacing: { after: 240 } });

function codigo(linhas) {
  return linhas.map((l, i) => new Paragraph({
    children: [new TextRun({ text: l === '' ? ' ' : l, font: MONO, size: 17 })],
    shading: { type: ShadingType.CLEAR, color: 'auto', fill: 'F3F4F6' },
    spacing: { after: 0, before: i === 0 ? 120 : 0, line: 240 },
    indent: { left: 200, right: 200 },
    ...(i === linhas.length - 1 ? { spacing: { after: 200, line: 240 } } : {}),
  }));
}

function figura(rel, largura, alturaOriginal, larguraOriginal, textoLegenda) {
  const altura = Math.round(largura * alturaOriginal / larguraOriginal);
  return [
    new Paragraph({ children: [new ImageRun({ type: 'png', data: img(rel), transformation: { width: largura, height: altura } })], alignment: AlignmentType.CENTER, spacing: { before: 120, after: 60 }, keepNext: true }),
    legenda(textoLegenda),
  ];
}

// ---------- tabelas ----------
const bordaCinza = { style: BorderStyle.SINGLE, size: 4, color: 'BFBFBF' };
const bordas = { top: bordaCinza, bottom: bordaCinza, left: bordaCinza, right: bordaCinza };
const semBorda = { style: BorderStyle.NONE, size: 0, color: 'FFFFFF' };
const semBordas = { top: semBorda, bottom: semBorda, left: semBorda, right: semBorda };

function celula(conteudo, largura, { cabecalho = false, fill } = {}) {
  const paragrafos = (Array.isArray(conteudo) ? conteudo : [conteudo]).map((t) => (t instanceof Paragraph ? t : new Paragraph({
    children: runs(String(t), cabecalho ? { bold: true, color: 'FFFFFF' } : {}),
    spacing: { after: 40 },
  })));
  return new TableCell({
    children: paragrafos,
    width: { size: largura, type: WidthType.DXA },
    borders: bordas,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    shading: cabecalho ? { type: ShadingType.CLEAR, color: 'auto', fill: AZUL } : (fill ? { type: ShadingType.CLEAR, color: 'auto', fill } : undefined),
    verticalAlign: VerticalAlign.CENTER,
  });
}

function tabela(cabecalhos, linhas, larguras) {
  const total = larguras.reduce((a, b) => a + b, 0);
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: larguras,
    rows: [
      new TableRow({ tableHeader: true, children: cabecalhos.map((c, i) => celula(c, larguras[i], { cabecalho: true })) }),
      ...linhas.map((l, n) => new TableRow({ children: l.map((c, i) => celula(c, larguras[i], { fill: n % 2 ? 'F7F9FC' : undefined })) })),
    ],
  });
}
const espaco = () => new Paragraph({ children: [], spacing: { after: 120 } });

// Print do celular ao lado do texto
function telaComTexto(rel, textoLegenda, paragrafos) {
  const LIMG = 3500;
  const LTXT = LARGURA - LIMG;
  return new Table({
    width: { size: LARGURA, type: WidthType.DXA },
    columnWidths: [LIMG, LTXT],
    rows: [new TableRow({ children: [
      new TableCell({
        width: { size: LIMG, type: WidthType.DXA }, borders: semBordas,
        children: [
          new Paragraph({ children: [new ImageRun({ type: 'png', data: img(rel), transformation: { width: 215, height: 478 } })], alignment: AlignmentType.CENTER }),
          legenda(textoLegenda),
        ],
      }),
      new TableCell({ width: { size: LTXT, type: WidthType.DXA }, borders: semBordas, margins: { left: 200 }, children: paragrafos }),
    ] })],
  });
}

// Dois prints de celular lado a lado, cada um com legenda
function duasTelas(rel1, leg1, rel2, leg2) {
  const L = LARGURA / 2;
  const coluna = (rel, leg) => new TableCell({
    width: { size: L, type: WidthType.DXA }, borders: semBordas,
    children: [
      new Paragraph({ children: [new ImageRun({ type: 'png', data: img(rel), transformation: { width: 200, height: 444 } })], alignment: AlignmentType.CENTER }),
      legenda(leg),
    ],
  });
  return new Table({
    width: { size: LARGURA, type: WidthType.DXA },
    columnWidths: [L, L],
    rows: [new TableRow({ cantSplit: true, children: [coluna(rel1, leg1), coluna(rel2, leg2)] })],
  });
}

// ============================ CONTEÚDO ============================
const capa = [
  new Paragraph({ children: [new TextRun({ text: 'SENAI — Avaliação Formativa', size: 26, color: '555555' })], alignment: AlignmentType.CENTER, spacing: { before: 600 } }),
  new Paragraph({ children: [new TextRun({ text: 'Desenvolvimento de Aplicação Mobile com Flutter', size: 26, color: '555555' })], alignment: AlignmentType.CENTER, spacing: { after: 2400 } }),
  new Paragraph({ children: [new TextRun({ text: 'Mapa de Locais', size: 64, bold: true, color: AZUL })], alignment: AlignmentType.CENTER }),
  new Paragraph({ children: [new TextRun({ text: 'Documentação Técnica', size: 40, color: '333333' })], alignment: AlignmentType.CENTER, spacing: { after: 240 } }),
  new Paragraph({ children: [new TextRun({ text: 'Aplicação de localização em Flutter com Firebase Cloud Firestore:', size: 24 })], alignment: AlignmentType.CENTER }),
  new Paragraph({ children: [new TextRun({ text: 'funcionalidades, conexões e funcionamento interno', size: 24 })], alignment: AlignmentType.CENTER, spacing: { after: 2800 } }),
  new Paragraph({ children: [new TextRun({ text: 'Aluno: ', bold: true, size: 24 }), new TextRun({ text: 'Gabriel Xavier', size: 24 })], alignment: AlignmentType.CENTER }),
  new Paragraph({ children: [new TextRun({ text: 'Repositório: ', bold: true, size: 24 }), new TextRun({ text: 'github.com/GabrielXavier125/Mobile', size: 24 })], alignment: AlignmentType.CENTER }),
  new Paragraph({ children: [new TextRun({ text: 'Projeto Firebase: ', bold: true, size: 24 }), new TextRun({ text: 'mapa-locais-gabriel', size: 24 })], alignment: AlignmentType.CENTER }),
  new Paragraph({ children: [new TextRun({ text: 'Outubro de 2026 — versão 1.0', size: 24 })], alignment: AlignmentType.CENTER, spacing: { before: 240 } }),
];

const sumario = [
  new Paragraph({ children: [new PageBreak()] }),
  new Paragraph({ children: [new TextRun({ text: 'Sumário', bold: true, size: 32, color: AZUL })], spacing: { after: 240 } }),
  new TableOfContents('Sumário', { hyperlink: true, headingStyleRange: '1-2' }),
];

const s1 = [
  h1('1. Introdução'),
  h2('1.1 Problemática'),
  p('Uma empresa deseja disponibilizar um aplicativo que permita aos usuários localizar serviços e estabelecimentos em diferentes cidades. O usuário precisa selecionar a cidade, pesquisar o que procura, filtrar os resultados, abrir os detalhes de um estabelecimento e marcar locais como favoritos. Além disso, novos locais precisam ser cadastrados e os registros existentes precisam poder ser alterados ou excluídos — portanto os dados não podem ficar fixos no código: eles precisam estar em um banco de dados em nuvem.'),
  h2('1.2 Objetivo'),
  p('Desenvolver o aplicativo **Mapa de Locais**, um guia de estabelecimentos (academias, restaurantes, hospitais, farmácias, mercados e cafés) com foco em **Limeira (SP)** — a cidade da turma — e também **São Paulo, Campinas e Jundiaí**, exigidas pelo enunciado, com mapa real, pesquisa, filtros, tela de detalhes e favoritos. Todos os dados ficam na coleção `locais` do **Firebase Cloud Firestore**, com operações completas de cadastro, leitura, edição e exclusão (CRUD).'),
  h2('1.3 Escopo'),
  bullet('**Três telas principais**, seguindo o wireframe da avaliação: Mapa, Resultados e Detalhes.'),
  bullet('Cadastro e edição em **Bottom Sheet** e exclusão com **diálogo de confirmação**, sem criar uma quarta tela.'),
  bullet('Banco de dados **Cloud Firestore** configurado com **FlutterFire CLI** e protegido por **regras de segurança**.'),
  bullet('Plataforma alvo: **Android** (testado no emulador Pixel 8, Android 16).'),
  bullet('Testes automatizados de unidade, de widget e de integração, além dos testes obrigatórios T01 a T11.'),
  h2('1.4 Sobre este documento'),
  p('Este documento descreve o aplicativo do ponto de vista técnico: **o que ele faz** (seção 3), **como se conecta** ao Firebase, ao mapa e ao Android (seção 4), **como o código está organizado** (seção 5), **como foi testado** (seção 6) e **como executá-lo** (seção 7). O código-fonte completo está no repositório indicado na capa, na pasta `Avaliação Formativa/mapa_locais`.'),
];

const s2 = [
  h1('2. Visão geral da solução'),
  p('O aplicativo é escrito em **Flutter/Dart** e roda no Android. Ele se comunica com três serviços externos: o **Cloud Firestore** (banco de dados), o **OpenStreetMap** (imagens do mapa) e os **aplicativos do próprio Android** (discador e Google Maps). A figura abaixo resume as camadas internas do app e essas conexões.'),
  ...figura('diagramas/diagrama_arquitetura.png', 600, 1150, 1600, 'Figura 1 — Arquitetura do aplicativo e suas conexões externas'),
  h2('2.1 Tecnologias e versões'),
  tabela(['Tecnologia', 'Versão', 'Uso no projeto'], [
    ['Flutter / Dart', '3.47.6 / 3.13.5', 'Interface e lógica do aplicativo'],
    ['firebase_core', '4.15.0', 'Inicialização e conexão com o projeto Firebase'],
    ['cloud_firestore', '6.10.0', 'Leitura e gravação na coleção `locais`'],
    ['Firebase CLI / FlutterFire CLI', '15.33.0 / 1.4.1', 'Criação do projeto, regras e geração do `firebase_options.dart`'],
    ['flutter_map + latlong2', '8.3.2 + 0.10.1', 'Mapa real com marcadores (OpenStreetMap)'],
    ['url_launcher', '6.3.3', 'Ações "Ligar" e "Como chegar"'],
    ['fake_cloud_firestore', '4.3.0', 'Firestore em memória para os testes'],
    ['integration_test', 'SDK do Flutter', 'Teste de ponta a ponta no emulador'],
    ['Android Gradle Plugin / Gradle', '9.1.0 / 9.3.1', 'Build do aplicativo Android'],
    ['Android', 'API 36 (Android 16)', 'Emulador Pixel 8 usado nos testes'],
  ], [2700, 1900, 4471]),
  espaco(),
  h2('2.2 Projeto Firebase'),
  tabela(['Item', 'Valor'], [
    ['Projeto', '`mapa-locais-gabriel` (nome de exibição: Mapa Locais Flutter)'],
    ['Plano', 'Spark (gratuito)'],
    ['Banco de dados', 'Cloud Firestore, modo nativo, banco `(default)`, região `nam5`'],
    ['Coleção principal', '`locais` — 20 documentos de exemplo: 10 em Limeira, 4 em Campinas, 3 em Jundiaí e 3 em São Paulo. Os locais são fictícios (nomes, telefones e avaliações inventados), posicionados em ruas reais.'],
    ['Aplicativo registrado', 'Android, pacote `com.exemplo.mapa_locais`'],
    ['Regras de segurança', 'Arquivo `firestore.rules`, publicado com `firebase deploy`'],
  ], [2700, 6371]),
];

const s3 = [
  h1('3. Funcionalidades'),
  p('O app possui três telas principais, uma barra de navegação inferior (Mapa, Favoritos e Perfil) e janelas sobrepostas para cadastro, edição, exclusão e escolha de cidade. Todas as informações exibidas vêm do Cloud Firestore em tempo real.'),
  h2('3.1 Tela 1 — Mapa principal'),
  telaComTexto('prints/tela1_mapa.png', 'Tela 1 — Mapa principal', [
    p('Ponto de entrada do aplicativo (`screens/mapa_screen.dart`).', { alignment: AlignmentType.LEFT }),
    bullet('**Cidade selecionada:** o app abre em **Limeira**. Toque em "Limeira ▾" para escolher entre Limeira, São Paulo, Campinas e Jundiaí; o mapa se desloca para a cidade escolhida.'),
    bullet('**Pesquisa:** o campo "Buscar locais, endereços ou categorias…" abre a Tela 2 já filtrada pelo texto digitado e pela cidade.'),
    bullet('**Mapa real:** imagens do OpenStreetMap no estilo **Suave** (cores leves), com as opções **Colorido** e **Escuro** (modo noturno). O ponto azul pulsante representa a posição do usuário (simulada no centro da cidade).'),
    bullet('**Marcadores:** um pino na cor da categoria para cada local, com o ícone num círculo branco. Ao tocar, o pino cresce, mostra um balão com o nome e um cartão com avaliação, distância e "Ver detalhes".'),
    bullet('**Botões laterais:** zoom (+/−), "Minha localização" (recentraliza o mapa) e "Camadas" (abre o seletor de estilos).'),
    bullet('**Ver resultados (N):** abre a Tela 2 com os locais da cidade.'),
  ]),
  h2('3.2 Tela 2 — Resultados'),
  telaComTexto('prints/tela2_resultados.png', 'Tela 2 — Resultados', [
    p('Lista os locais lidos do Firestore (`screens/resultados_screen.dart`).', { alignment: AlignmentType.LEFT }),
    bullet('**Pesquisa** por nome ou categoria, sem diferenciar maiúsculas e acentos ("farmacia" encontra "Farmácia").'),
    bullet('**Filtro de cidade** (inclui "Todas as cidades") e **chips de categoria**: Todos, Favoritos, Academias, Restaurantes, Hospitais, Farmácias, Mercados e Cafés.'),
    bullet('Cada item mostra **imagem, nome, categoria, cidade, distância e avaliação**, ordenados do mais próximo para o mais distante.'),
    bullet('**Tocar no item** abre a Tela 3. O menu **⋮** oferece **Editar** e **Excluir**.'),
    bullet('O botão **Novo local** abre o formulário de cadastro.'),
    bullet('Mostra estados de **carregando**, **nenhum resultado**, **banco vazio** (com botão "Cadastrar locais de exemplo") e **erro de conexão** (com "Tentar novamente").'),
  ]),
  h2('3.3 Tela 3 — Detalhes do local'),
  telaComTexto('prints/tela3_detalhes.png', 'Tela 3 — Detalhes', [
    p('Recebe o local selecionado e acompanha o documento no Firestore em tempo real (`screens/detalhes_screen.dart`).', { alignment: AlignmentType.LEFT }),
    bullet('**Galeria** com 5 imagens ilustrativas da categoria (indicador 1/5 e pontos).'),
    bullet('**Nome, categoria, avaliação** (estrelas e nota), **distância** e **horário**, com o selo **Aberto/Fechado** calculado a partir da hora atual.'),
    bullet('**Ações rápidas:** **Ligar** abre o discador com o telefone do local; **Como chegar** abre a rota no Google Maps; **Agendar** escolhe data e hora da visita.'),
    bullet('**Sobre:** descrição, endereço, cidade, telefone e horário de funcionamento.'),
    bullet('**Coração (favorito):** grava o campo `favorito` no Firestore. **Compartilhar** copia as informações do local.'),
    bullet('**Ver no mapa:** volta à Tela 1 centralizando o local, com o rótulo e o cartão de prévia.'),
  ]),
  h2('3.4 Cadastro e edição de locais'),
  telaComTexto('prints/cadastro_formulario.png', 'Formulário em Bottom Sheet', [
    p('O mesmo formulário (`widgets/local_form.dart`) serve para cadastrar (vazio) e editar (preenchido com os dados atuais). Ele abre em um **Bottom Sheet** e valida os campos antes de gravar:', { alignment: AlignmentType.LEFT }),
    bullet('**Nome:** obrigatório, até 80 caracteres.'),
    bullet('**Categoria e cidade:** escolhidas em listas, o que evita valores inválidos.'),
    bullet('**Horário:** obrigatório, no formato `HH:MM - HH:MM` ou "24 horas".'),
    bullet('**Avaliação:** número de 0 a 5. **Distância:** número de 0 a 500 km. Os dois aceitam vírgula ou ponto.'),
    bullet('**Descrição:** obrigatória, até 500 caracteres. **Endereço e telefone:** opcionais.'),
    p('No cadastro, a latitude e a longitude do local são geradas perto do centro da cidade escolhida para posicionar o marcador no mapa. Na edição, a posição é mantida, exceto quando a cidade muda.', { alignment: AlignmentType.LEFT }),
  ]),
  h2('3.5 Exclusão com confirmação'),
  telaComTexto('prints/exclusao_confirmacao.png', 'Confirmação de exclusão', [
    p('A exclusão **nunca acontece direto ao tocar no botão**. O app abre um `AlertDialog` (`dialogs/confirm_delete.dart`) com o nome do local e o aviso de que a ação não pode ser desfeita.', { alignment: AlignmentType.LEFT }),
    bullet('**Cancelar:** fecha o diálogo sem alterar nada.'),
    bullet('**Excluir:** remove o documento do Firestore e mostra uma mensagem verde de confirmação. Como a lista usa leitura em tempo real, o item desaparece na mesma hora.'),
  ]),
  h2('3.6 Favoritos e Perfil'),
  bullet('**Favoritar:** o coração da Tela 3 inverte o campo `favorito` do documento. A mudança aparece em todas as telas (o item na lista ganha um coração vermelho).'),
  bullet('**Aba Favoritos:** abre a Tela 2 já filtrada, mostrando só os favoritos de todas as cidades. O chip "Favoritos" faz o mesmo dentro da tela de resultados.'),
  bullet('**Aba Perfil:** abre um Bottom Sheet com o resumo do banco (total de locais, favoritos e cidades) e o status da conexão com o Cloud Firestore.'),
  h2('3.7 Fluxo de navegação'),
  ...figura('diagramas/diagrama_navegacao.png', 600, 760, 1600, 'Figura 2 — Navegação entre as três telas e as janelas sobrepostas'),
  p('A navegação usa `Navigator.push` para ir do mapa aos resultados e dos resultados aos detalhes, e `Navigator.pop` (botão voltar) para retornar. "Ver no mapa" usa `Navigator.popUntil` para voltar à primeira tela e avisa o mapa, por meio de um `ValueNotifier` compartilhado, qual local deve ser centralizado.'),
  h2('3.8 Mensagens e tratamento de erros'),
  p('Toda operação no banco termina com uma mensagem (`utils/mensagens.dart`): **SnackBar verde** para sucesso ("Local cadastrado com sucesso!", "Adicionado aos favoritos!") e **SnackBar vermelha** para erro. Os erros mais comuns do Firestore são traduzidos para o usuário:'),
  tabela(['Código do Firestore', 'Mensagem exibida'], [
    ['`permission-denied`', 'Operação bloqueada pelas regras de segurança do Firestore.'],
    ['`unavailable`', 'Sem conexão com o servidor. Verifique a internet.'],
    ['`not-found`', 'O registro não existe mais no banco.'],
    ['outros', 'Mensagem original do Firestore, com o código do erro.'],
  ], [2700, 6371]),
  h2('3.9 Requisitos funcionais'),
  tabela(['Código', 'Requisito', 'Como foi atendido', 'Onde'], [
    ['RF01', 'Selecionar cidade', 'Seletor no mapa e filtro na lista (Limeira, São Paulo, Campinas, Jundiaí + "Todas")', '`mapa_screen`, `seletor_cidade`'],
    ['RF02', 'Pesquisar', 'Por nome ou categoria, sem acentos/maiúsculas', '`utils/filtros.dart`'],
    ['RF03', 'Consultar Firestore', 'Leitura em tempo real com `snapshots()`', '`local_service.dart`'],
    ['RF04', 'Filtrar', 'Categoria, cidade e favoritos', '`resultados_screen.dart`'],
    ['RF05', 'Cadastrar local', 'Formulário → `locais.add()`', '`local_form.dart`'],
    ['RF06', 'Editar local', 'Formulário preenchido → `doc(id).update()`', '`resultados_screen.dart`'],
    ['RF07', 'Excluir local', 'Confirmação → `doc(id).delete()`', '`confirm_delete.dart`'],
    ['RF08', 'Detalhes', 'Todas as informações do documento', '`detalhes_screen.dart`'],
    ['RF09', 'Favoritar', 'Atualiza o campo `favorito`', '`detalhes_screen.dart`'],
    ['RF10', 'Navegação', 'Mapa ⇄ Resultados ⇄ Detalhes, "Ver no mapa", barra inferior', '`barra_navegacao.dart`'],
  ], [900, 1700, 3971, 2500]),
];

const s4 = [
  h1('4. Conexões'),
  p('Esta seção explica como o aplicativo se conecta a cada serviço externo: Firebase, Cloud Firestore, OpenStreetMap e aplicativos do Android.'),
  h2('4.1 Conexão com o Firebase'),
  p('A configuração seguiu o fluxo oficial do Firebase para Flutter: **Firebase CLI + FlutterFire CLI + firebase_core + cloud_firestore**.'),
  numero('`firebase login` — autenticação da conta Google no Firebase CLI.'),
  numero('Criação do projeto `mapa-locais-gabriel` e do banco Cloud Firestore.'),
  numero('`flutterfire configure --project=mapa-locais-gabriel --platforms=android` — registrou o app Android no projeto e gerou os arquivos de configuração.'),
  numero('`flutter pub add firebase_core cloud_firestore` — pacotes do Firebase.'),
  p('O FlutterFire CLI gerou e alterou estes arquivos:'),
  tabela(['Arquivo', 'Função'], [
    ['`lib/firebase_options.dart`', 'Identificadores do projeto (apiKey, appId, projectId…) usados por `Firebase.initializeApp`. Gerado automaticamente — não deve ser editado à mão.'],
    ['`android/app/google-services.json`', 'Mesma configuração no formato do Android.'],
    ['`android/settings.gradle.kts` e `app/build.gradle.kts`', 'Plugin `com.google.gms.google-services` (4.4.4), que lê o `google-services.json` no build.'],
    ['`firebase.json` / `.firebaserc`', 'Projeto padrão, regras do Firestore e configuração do emulador local.'],
  ], [3300, 5771]),
  espaco(),
  p('A conexão acontece no início do `main.dart`, antes de a interface ser desenhada:'),
  ...codigo([
    'Future<void> main() async {',
    '  WidgetsFlutterBinding.ensureInitialized();',
    '',
    '  await Firebase.initializeApp(',
    '    options: DefaultFirebaseOptions.currentPlatform,',
    '  );',
    '',
    '  if (usarEmulador) {   // --dart-define=USAR_EMULADOR=true',
    "    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);",
    '  }',
    '',
    '  runApp(const MinhaAplicacao());',
    '}',
  ]),
  p('A `apiKey` presente em `firebase_options.dart` **não é uma senha**: ela apenas identifica o projeto. Quem protege os dados são as regras de segurança do Firestore (seção 4.4).'),
  h2('4.2 Leitura dos dados em tempo real'),
  p('A leitura usa `snapshots()`, que mantém uma conexão aberta com o Firestore: sempre que um documento é criado, alterado ou excluído — pelo app ou pelo Console do Firebase —, o servidor envia a nova versão e a interface é redesenhada automaticamente por um `StreamBuilder`.'),
  ...codigo([
    'Stream<List<Local>> listarLocais() {',
    '  return locais.snapshots().map((snapshot) {',
    '    return snapshot.docs',
    '        .map((doc) => Local.fromMap(doc.id, doc.data()))',
    '        .toList();',
    '  });',
    '}',
  ]),
  bullet('**Mapa e Resultados** escutam `listarLocais()` (coleção inteira).'),
  bullet('**Detalhes** escuta `observarLocal(id)` (um único documento), o que atualiza o coração na hora e detecta se o local foi excluído.'),
  bullet('O SDK mantém um **cache local**: os dados já carregados continuam visíveis se a conexão cair, e as gravações aparecem na tela imediatamente, antes mesmo da confirmação do servidor.'),
  bullet('Pesquisa e filtros são aplicados **em memória** sobre a lista recebida (seção 5.3), como sugerido no tutorial.'),
  h2('4.3 Gravação dos dados (CRUD)'),
  p('Todas as operações passam pela classe `LocalService` (`services/local_service.dart`). As telas nunca acessam o Firestore diretamente.'),
  tabela(['Operação', 'Comando no Firestore', 'Método do LocalService', 'Acionado por'], [
    ['Create', '`locais.add(map)`', '`adicionar(local)`', 'Botão "Novo local"'],
    ['Read', '`locais.snapshots()`', '`listarLocais()` / `observarLocal(id)`', 'Mapa, Resultados, Detalhes'],
    ['Update', '`locais.doc(id).update(map)`', '`atualizar(local)`', 'Menu ⋮ → Editar'],
    ['Update parcial', "`doc(id).update({'favorito': v})`", '`alterarFavorito(id, v)`', 'Coração (Detalhes)'],
    ['Delete', '`locais.doc(id).delete()`', '`excluir(id)`', 'Menu ⋮ → Excluir + confirmação'],
    ['Create em lote', '`batch.set(...)` + `commit()`', '`popularExemplos()`', 'Botão "Cadastrar locais de exemplo"'],
  ], [1500, 2700, 2500, 2371]),
  espaco(),
  ...codigo([
    'Future<String> adicionar(Local local) async {',
    '  final ref = await locais.add(local.toMap());   // ID gerado pelo Firestore',
    '  return ref.id;',
    '}',
    '',
    'Future<void> atualizar(Local local) async {',
    '  await locais.doc(local.id).update(local.toMap());',
    '}',
    '',
    'Future<void> excluir(String id) async {',
    '  await locais.doc(id).delete();',
    '}',
    '',
    'Future<void> alterarFavorito(String id, bool favorito) async {',
    "  await locais.doc(id).update({'favorito': favorito});",
    '}',
  ]),
  p('Nas telas, cada chamada fica dentro de `try/catch`: em caso de sucesso aparece a mensagem verde; em caso de falha, a mensagem vermelha traduzida (seção 3.8).'),
  h2('4.4 Segurança: regras do Firestore'),
  p('O banco **não fica aberto**. As regras (`firestore.rules`) são executadas nos servidores do Google e validam cada requisição, mesmo que alguém tente acessar o banco sem usar o aplicativo:'),
  tabela(['Regra', 'Efeito'], [
    ['Qualquer coleção diferente de `locais`', 'Leitura e escrita **negadas**.'],
    ['Leitura de `locais`', 'Pública — o app é um guia de estabelecimentos.'],
    ['Cadastro e edição', 'Aceitos apenas se o documento seguir o modelo: somente campos conhecidos, campos obrigatórios presentes e tipos corretos.'],
    ['Valores', 'Nome com 1 a 80 caracteres; categoria e cidade dentro das listas permitidas; avaliação de 0 a 5; distância de 0 a 500; limites de tamanho em horário, descrição, endereço e telefone; coordenadas válidas.'],
  ], [3000, 6071]),
  espaco(),
  ...codigo([
    'match /locais/{localId} {',
    '  allow read: if true;',
    '  allow create, update: if localValido(request.resource.data);',
    '  allow delete: if true;',
    '}',
  ]),
  p('**Teste das regras:** no emulador local, um documento válido foi aceito (HTTP 200) e foram recusados (HTTP 403 — PERMISSION_DENIED) documentos com avaliação 9, com campo extra (`admin`), com cidade fora da lista, sem o campo `nome`, além de leitura e escrita em outra coleção. No projeto real, uma gravação com campo fora do modelo também retornou 403.'),
  p('**Limitação conhecida:** sem login, qualquer pessoa ainda pode excluir um local. O próximo passo (desafio nível 3) é adicionar Firebase Authentication e exigir `request.auth` para cadastro, edição e exclusão.'),
  h2('4.5 Mapa: OpenStreetMap'),
  bullet('O mapa usa o pacote `flutter_map`, que baixa as imagens ("tiles") de `tile.openstreetmap.org` por **HTTPS** e as monta conforme o zoom e a posição.'),
  bullet('As requisições se identificam com o nome do pacote do app (`userAgentPackageName`), como exige a política de uso do OpenStreetMap, e o mapa exibe a atribuição "OpenStreetMap contributors".'),
  bullet('**Estilos:** o Suave e o Escuro são filtros de cor (`ColorFilter.matrix`) aplicados às imagens no próprio aparelho, sem outro servidor. O Suave reduz a saturação e clareia (parques verdes e água azul continuam visíveis); o Escuro inverte as cores e puxa para azul-marinho; o Colorido mostra o mapa original.'),
  bullet('**Marcadores coloridos:** a cor e o ícone vêm do modelo `Categoria` (academia, restaurante, hospital, farmácia, mercado e café), o que ajuda a reconhecer o tipo de local de longe.'),
  bullet('Cada marcador é posicionado pela latitude e longitude gravadas no documento (`MarkerLayer`).'),
  bullet('Não é necessária chave de API. O Google Maps foi descartado porque exige uma conta de faturamento.'),
  duasTelas('prints/mapa_seletor_estilo.png', 'Seletor de estilo do mapa', 'prints/mapa_escuro.png', 'Estilo Escuro (modo noturno)'),
  h2('4.6 Integrações com o Android'),
  tabela(['Recurso', 'Como funciona'], [
    ['Ligar', '`url_launcher` abre o discador com `tel:` e o número do local.'],
    ['Como chegar', 'Abre `https://www.google.com/maps/dir/?api=1&destination=lat,lng` no Google Maps ou no navegador.'],
    ['Permissões (`AndroidManifest.xml`)', '`INTERNET` (Firestore e mapa) e declarações `<queries>` para as intenções `DIAL` (tel) e `VIEW` (https), exigidas a partir do Android 11.'],
    ['Agendar e Compartilhar', 'Seletores de data e hora nativos do Material; o compartilhamento copia o texto para a área de transferência.'],
  ], [3000, 6071]),
  h2('4.7 Ambiente de desenvolvimento'),
  bullet('**Emulador local do Firestore:** com `firebase emulators:start --only firestore` e `flutter run --dart-define=USAR_EMULADOR=true`, o app usa um banco que roda no próprio computador (endereço `10.0.2.2:8080`, que é o computador visto de dentro do emulador Android). Isso permitiu desenvolver e testar as regras antes de ligar o projeto real.'),
  bullet('**Rede da escola:** o emulador Android ficava sem internet porque o primeiro servidor DNS da rede não responde. O script `iniciar_emulador.bat` testa os DNS do computador e inicia o emulador com os que funcionam (`-dns-server`).'),
  bullet('**Acentos no caminho:** o projeto fica na pasta "Avaliação Formativa". O plugin Android recusa caminhos com acentos no Windows, por isso `android/gradle.properties` contém `android.overridePathCheck=true`. A análise de código é feita com `dart analyze`.'),
];

const s5 = [
  h1('5. Arquitetura e organização do código'),
  h2('5.1 Camadas e responsabilidades'),
  p('O código segue a estrutura recomendada no tutorial, com separação entre **Model**, **serviço** e **telas**. Isso isola o banco da interface e permitiu testar as telas com um Firestore falso.'),
  tabela(['Pasta / arquivo', 'Responsabilidade'], [
    ['`main.dart`', 'Inicializa o Firebase e abre o app.'],
    ['`app.dart`', '`MaterialApp`, tema visual (wireframe), idioma pt-BR e criação do `LocalService`.'],
    ['`app_scope.dart`', '`InheritedWidget` que entrega o `LocalService` e o "foco do mapa" a todas as telas (injeção de dependência).'],
    ['`models/`', '`Local` (fromMap/toMap/copyWith), `Cidade` (4 cidades e coordenadas; Limeira é a inicial) e `Categoria` (6 categorias, ícones e cores).'],
    ['`services/local_service.dart`', 'Único ponto de acesso ao Firestore: CRUD, favoritos e carga de exemplos.'],
    ['`screens/`', 'As três telas: `mapa_screen`, `resultados_screen`, `detalhes_screen`.'],
    ['`widgets/`', 'Componentes reutilizáveis: card da lista, formulário, mapa, imagem ilustrativa, barra inferior.'],
    ['`dialogs/`', 'Confirmação de exclusão, seletor de cidade e aba Perfil.'],
    ['`utils/`', 'Filtros e pesquisa, formatação (km, nota, horário aberto/fechado), coordenadas e mensagens.'],
    ['`data/locais_exemplo.dart`', 'Os 20 locais usados para popular o banco.'],
  ], [3000, 6071]),
  espaco(),
  p('**Fluxo de uma operação:** a tela chama um método do `LocalService` → o serviço converte o `Local` em `Map` (`toMap`) e usa o `cloud_firestore` → o Firestore aplica as regras e grava → o `snapshots()` devolve a nova lista → o `StreamBuilder` redesenha as telas. O projeto tem cerca de **2.900 linhas** de código no app e **580** nos testes.'),
  h2('5.2 Modelo de dados — coleção locais'),
  tabela(['Campo', 'Tipo', 'Obrigatório', 'Exemplo'], [
    ['nome', 'string', 'sim', '"Academia Fitness"'],
    ['categoria', 'string', 'sim', '"Academia"'],
    ['cidade', 'string', 'sim', '"Limeira"'],
    ['avaliacao', 'number (0–5)', 'sim', '4.8'],
    ['distancia', 'number (km)', 'sim', '1.2'],
    ['horario', 'string', 'sim', '"06:00 - 22:00"'],
    ['descricao', 'string', 'sim', '"Academia completa com musculação…"'],
    ['favorito', 'boolean', 'sim', 'false'],
    ['endereco', 'string', 'não', '"Rua Senador Vergueiro, 1100 - Centro"'],
    ['telefone', 'string', 'não', '"(19) 3400-1003"'],
    ['latitude / longitude', 'number', 'não', '-22.5598 / -47.4066'],
  ], [2200, 1700, 1300, 3871]),
  espaco(),
  p('Os oito primeiros campos são os definidos no tutorial. Os campos complementares alimentam a tela de detalhes e o mapa. O **ID do documento** é gerado pelo Firestore e guardado no campo `id` do Model, para identificar o documento na edição, na exclusão e no favorito. A conversão é feita por `Local.fromMap` e `toMap`; números inteiros vindos do banco são convertidos para `double`.'),
  h2('5.3 Pesquisa e filtros'),
  p('A função `filtrarLocais` (`utils/filtros.dart`) recebe a lista vinda do Firestore e aplica quatro critérios ao mesmo tempo: **cidade** ("Todas" ou igual), **categoria** ("Todos" ou igual), **texto** (contido no nome ou na categoria) e **apenas favoritos**. Antes de comparar, o texto passa por `normalizar`, que converte para minúsculas e remove acentos. O resultado é ordenado pela distância.'),
];

const s6 = [
  h1('6. Testes'),
  h2('6.1 Estratégia'),
  tabela(['Tipo', 'Arquivo', 'Qtde.', 'O que verifica'], [
    ['Unidade', '`test/local_test.dart`', '3', 'Conversões do Model (`fromMap`, `toMap`, valores padrão).'],
    ['Unidade', '`test/filtros_test.dart`', '10', 'Pesquisa, filtros, ordenação, dados de exemplo, horário aberto/fechado.'],
    ['Unidade', '`test/local_service_test.dart`', '6', 'CRUD do `LocalService` contra um Firestore em memória.'],
    ['Widget', '`test/widget_test.dart`', '12', 'Fluxos das telas (T01–T11) com Firestore em memória.'],
    ['Integração', '`integration_test/app_test.dart`', '1', 'Fluxo completo no emulador Android, no **Firestore real**: pesquisa, cidade, filtro, cadastro, leitura, favorito, edição e exclusão.'],
  ], [1300, 2900, 800, 4071]),
  espaco(),
  p('**Resultado (28/10/2026):** os 31 testes de unidade e de widget e o teste de integração passaram no emulador **Pixel 8 (Android 16)** conectado ao projeto `mapa-locais-gabriel`. O teste de integração cria, edita, favorita e exclui um local próprio, sem alterar os outros documentos.'),
  h2('6.2 Testes obrigatórios'),
  tabela(['ID', 'Teste', 'Procedimento', 'Resultado'], [
    ['T01', 'Conexão', 'Abrir o app e verificar se os dados do Firestore aparecem', 'Passou'],
    ['T02', 'Pesquisa', 'Pesquisar por "Academia"', 'Passou'],
    ['T03', 'Cidade', 'Selecionar Campinas', 'Passou'],
    ['T04', 'Filtro', 'Selecionar uma categoria', 'Passou'],
    ['T05', 'Create', 'Cadastrar um novo local e verificar no Firestore', 'Passou'],
    ['T06', 'Read', 'Fechar/reabrir a tela e verificar o registro', 'Passou'],
    ['T07', 'Update', 'Editar nome ou horário e confirmar a alteração', 'Passou'],
    ['T08', 'Delete', 'Excluir um local e confirmar que desapareceu', 'Passou'],
    ['T09', 'Favorito', 'Marcar e desmarcar um local', 'Passou'],
    ['T10', 'Navegação', 'Abrir resultados e detalhes e retornar', 'Passou'],
    ['T11', 'Erro', 'Simular ausência de dados/erro e verificar mensagem', 'Passou'],
  ], [700, 1400, 5471, 1500]),
  espaco(),
  p('T01 a T10 são cobertos pelo teste de integração no Firestore real e pelos testes de widget. O T11 é verificado pelos testes de widget com um banco vazio (mensagem "Nenhum local cadastrado." e botão de exemplos) e com uma falha de conexão simulada (mensagem "Erro ao carregar os locais." e "Tentar novamente").'),
  h2('6.3 Evidência no Firestore'),
  ...figura('prints/firestore_console.png', 600, 953, 1919, 'Figura 3 — Console do Firebase: coleção locais com os documentos e os campos de um local'),
];

const s7 = [
  h1('7. Instalação e execução'),
  h2('7.1 Pré-requisitos'),
  bullet('Flutter 3.47 (Dart 3.13) e Android SDK com um emulador (Pixel 8, Android 16).'),
  bullet('Node.js com Firebase CLI (`npm install -g firebase-tools`) e FlutterFire CLI (`dart pub global activate flutterfire_cli`) — apenas para reconfigurar o Firebase.'),
  h2('7.2 Executar o app'),
  numero('Abrir o emulador com `iniciar_emulador.bat` (corrige o DNS da rede da escola).', 2),
  numero('Na pasta `mapa_locais`: `flutter pub get`.', 2),
  numero('`flutter run`.', 2),
  numero('Se a coleção estiver vazia, usar "Cadastrar locais de exemplo" na tela de resultados.', 2),
  h2('7.3 Comandos úteis'),
  ...codigo([
    'flutter test                                    # 31 testes de unidade e widget',
    'flutter test integration_test -d emulator-5554  # teste de ponta a ponta no Firestore real',
    'dart analyze                                    # análise estática do código',
    'firebase deploy --only firestore:rules          # publicar as regras de segurança',
    '',
    '# desenvolvimento sem o banco real:',
    'firebase emulators:start --only firestore --project demo-mapa-locais',
    'flutter run --dart-define=USAR_EMULADOR=true',
  ]),
];

const s8 = [
  h1('8. Requisitos não funcionais, limitações e conclusão'),
  h2('8.1 Requisitos não funcionais atendidos'),
  bullet('Desenvolvido em Flutter/Dart e executando em Android.'),
  bullet('Banco Cloud Firestore configurado com FlutterFire.'),
  bullet('Código organizado em pastas (models, services, screens, widgets, dialogs, utils, data).'),
  bullet('Exclusões sempre pedem confirmação.'),
  bullet('Mensagens de sucesso e de erro em todas as operações de banco.'),
  bullet('Banco protegido por regras de segurança, sem acesso aberto.'),
  bullet('Sem erros na análise estática (`dart analyze`) e com todos os testes passando.'),
  h2('8.2 Limitações e melhorias futuras'),
  tabela(['Limitação atual', 'Melhoria proposta'], [
    ['Sem login: qualquer pessoa pode cadastrar/editar (dados validados) e excluir.', 'Firebase Authentication e regras com `request.auth`, separando usuários e administradores (nível 3).'],
    ['Favoritos são um campo do local, iguais para todos os usuários.', 'Lista de favoritos por usuário em uma subcoleção (nível 5).'],
    ['Imagens são ilustrações por categoria.', 'Fotos reais com Firebase Storage (nível 1).'],
    ['Distância é um valor gravado; a posição do usuário é simulada no centro da cidade.', 'GPS real (pacote geolocator) e cálculo da distância pelas coordenadas.'],
    ['Filtros aplicados em memória.', 'Consultas com `where()`/`orderBy()` e índices no Firestore (nível 4).'],
  ], [4300, 4771]),
  espaco(),
  p('**Desafio extra implementado — nível 2 (mapa real):** o mapa usa o OpenStreetMap com marcadores posicionados pelas coordenadas de cada documento.'),
  h2('8.3 Conclusão'),
  p('O aplicativo atende ao wireframe e aos requisitos da avaliação: três telas, dados no Cloud Firestore, pesquisa, filtros, CRUD completo, favoritos e navegação. A separação entre Model, serviço e telas deixou o código simples de manter e de testar, e o uso de `snapshots()` tornou a interface reativa: qualquer alteração no banco aparece imediatamente em todas as telas.'),
  p('O desenvolvimento por etapas — primeiro com o emulador local do Firestore e depois com o projeto real — permitiu validar as regras de segurança antes de publicá-las. O projeto também mostrou que um banco em nuvem precisa ser protegido: mesmo sem login, as regras impedem dados fora do modelo e o acesso a outras coleções. O próximo passo natural é a autenticação de usuários.'),
  h2('Referências'),
  bullet('Firebase para Flutter: https://firebase.google.com/docs/flutter/setup'),
  bullet('Cloud Firestore — adicionar e gerenciar dados: https://firebase.google.com/docs/firestore/manage-data/add-data'),
  bullet('Regras de segurança do Cloud Firestore: https://firebase.google.com/docs/firestore/security/get-started'),
  bullet('flutter_map: https://docs.fleaflet.dev'),
  bullet('Política de uso dos tiles do OpenStreetMap: https://operations.osmfoundation.org/policies/tiles/'),
];

// ============================ DOCUMENTO ============================
const doc = new Document({
  creator: 'Gabriel Xavier',
  title: 'Mapa de Locais — Documentação Técnica',
  description: 'Documentação técnica do app Flutter + Firebase Cloud Firestore',
  styles: {
    default: { document: { run: { font: FONTE, size: 22 } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 34, bold: true, color: AZUL, font: FONTE },
        paragraph: { spacing: { before: 120, after: 240 }, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: AZUL, space: 4 } } } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 27, bold: true, color: '2E74B5', font: FONTE },
        paragraph: { spacing: { before: 300, after: 120 }, outlineLevel: 1, keepNext: true } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 24, bold: true, color: '404040', font: FONTE },
        paragraph: { spacing: { before: 200, after: 80 }, outlineLevel: 2, keepNext: true } },
    ],
  },
  numbering: {
    config: [
      { reference: 'marcadores', levels: [
        { level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 500, hanging: 260 } } } },
        { level: 1, format: LevelFormat.BULLET, text: '◦', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1000, hanging: 260 } } } },
      ] },
      { reference: 'numeros', levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: '%1.', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 500, hanging: 300 } } } },
      ] },
    ],
  },
  sections: [
    {
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1701, bottom: 1134, left: 1701, right: 1134 } } },
      children: [...capa, ...sumario],
    },
    {
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1701, bottom: 1134, left: 1701, right: 1134 } } },
      headers: { default: new Header({ children: [new Paragraph({ children: [new TextRun({ text: 'Mapa de Locais — Documentação Técnica', size: 18, color: '808080' })], alignment: AlignmentType.RIGHT })] }) },
      footers: { default: new Footer({ children: [new Paragraph({ children: [new TextRun({ children: ['Página ', PageNumber.CURRENT, ' de ', PageNumber.TOTAL_PAGES], size: 18, color: '808080' })], alignment: AlignmentType.CENTER })] }) },
      children: [...s1, ...s2, ...s3, ...s4, ...s5, ...s6, ...s7, ...s8],
    },
  ],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync(SAIDA, buf);
  console.log('gerado:', SAIDA, buf.length, 'bytes');
});
