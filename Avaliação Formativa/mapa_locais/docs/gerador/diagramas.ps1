param([string]$Saida)
Add-Type -AssemblyName System.Drawing

function Nova-Imagem($w, $h) {
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'ClearTypeGridFit'
    $g.Clear([System.Drawing.Color]::White)
    return @($bmp, $g)
}

function Cor($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }

function Caixa($g, $x, $y, $w, $h, $titulo, $linhas, $fundo, $borda) {
    $r = 14
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($x, $y, $r*2, $r*2, 180, 90)
    $path.AddArc($x+$w-$r*2, $y, $r*2, $r*2, 270, 90)
    $path.AddArc($x+$w-$r*2, $y+$h-$r*2, $r*2, $r*2, 0, 90)
    $path.AddArc($x, $y+$h-$r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    $g.FillPath((New-Object System.Drawing.SolidBrush (Cor $fundo)), $path)
    $g.DrawPath((New-Object System.Drawing.Pen (Cor $borda), 2.5), $path)
    $fTit = New-Object System.Drawing.Font 'Segoe UI', 17, ([System.Drawing.FontStyle]::Bold)
    $fTxt = New-Object System.Drawing.Font 'Segoe UI', 13
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = 'Center'
    $g.DrawString($titulo, $fTit, (New-Object System.Drawing.SolidBrush (Cor '#1F2328')), (New-Object System.Drawing.RectangleF $x, ($y+12), $w, 30), $fmt)
    $yy = $y + 46
    foreach ($l in $linhas) {
        $g.DrawString($l, $fTxt, (New-Object System.Drawing.SolidBrush (Cor '#3C4043')), (New-Object System.Drawing.RectangleF ($x+8), $yy, ($w-16), 24), $fmt)
        $yy += 23
    }
}

function Seta($g, $x1, $y1, $x2, $y2, $rotulo, $cor = '#5F6368', $duplo = $false, $dx = 0, $dy = -16) {
    $pen = New-Object System.Drawing.Pen (Cor $cor), 3
    $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 6, 7
    $pen.CustomEndCap = $cap
    if ($duplo) { $pen.CustomStartCap = $cap }
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    if ($rotulo) {
        $f = New-Object System.Drawing.Font 'Segoe UI', 12, ([System.Drawing.FontStyle]::Italic)
        $fmt = New-Object System.Drawing.StringFormat
        $fmt.Alignment = 'Center'
        $mx = ($x1 + $x2) / 2 + $dx; $my = ($y1 + $y2) / 2 + $dy
        $sz = $g.MeasureString($rotulo, $f)
        $g.FillRectangle([System.Drawing.Brushes]::White, ($mx - $sz.Width/2), $my, $sz.Width, $sz.Height)
        $g.DrawString($rotulo, $f, (New-Object System.Drawing.SolidBrush (Cor '#1A73E8')), (New-Object System.Drawing.RectangleF ($mx-200), $my, 400, 24), $fmt)
    }
}

# ---------------- Diagrama 1: arquitetura e conexões ----------------
$im = Nova-Imagem 1600 1150; $bmp = $im[0]; $g = $im[1]
$fT = New-Object System.Drawing.Font 'Segoe UI', 22, ([System.Drawing.FontStyle]::Bold)
$g.DrawString('Arquitetura e conexões do app Mapa de Locais', $fT, [System.Drawing.Brushes]::Black, 40, 22)

# faixa do dispositivo
$g.FillRectangle((New-Object System.Drawing.SolidBrush (Cor '#F6F8FA')), 30, 80, 860, 900)
$g.DrawRectangle((New-Object System.Drawing.Pen (Cor '#D0D7DE'), 2), 30, 80, 860, 900)
$fS = New-Object System.Drawing.Font 'Segoe UI', 14, ([System.Drawing.FontStyle]::Bold)
$g.DrawString('Celular Android (app Flutter)', $fS, (New-Object System.Drawing.SolidBrush (Cor '#57606A')), 46, 92)

Caixa $g 80 135 760 120 'Interface (screens, widgets, dialogs)' @('MapaScreen · ResultadosScreen · DetalhesScreen', 'LocalForm (Bottom Sheet) · confirmarExclusao (AlertDialog)') '#E8F0FE' '#1A73E8'
Caixa $g 80 315 760 110 'AppScope (InheritedWidget)' @('entrega o LocalService e o foco do mapa a todas as telas') '#FEF7E0' '#F9AB00'
Caixa $g 80 485 760 120 'LocalService  +  Model Local' @('listarLocais · observarLocal · adicionar · atualizar', 'excluir · alterarFavorito · popularExemplos  |  fromMap / toMap') '#E6F4EA' '#1E8E3E'
Caixa $g 80 665 760 120 'SDKs Firebase (firebase_core + cloud_firestore)' @('Firebase.initializeApp(DefaultFirebaseOptions)', 'cache local offline · snapshots em tempo real') '#FCE8E6' '#D93025'
Caixa $g 80 845 360 100 'flutter_map' @('TileLayer + MarkerLayer') '#F3E8FD' '#8430CE'
Caixa $g 480 845 360 100 'url_launcher' @('tel: · https://google.com/maps') '#F3E8FD' '#8430CE'

Seta $g 460 255 460 315 'StreamBuilder / chamadas' '#5F6368' $true 110 -12
Seta $g 460 425 460 485 'AppScope.of(context).service' '#5F6368' $false 130 -12
Seta $g 460 605 460 665 'Map <-> Local' '#5F6368' $true 90 -12

# configuração e serviços externos
Caixa $g 1010 135 560 160 'Configuração do Firebase' @('lib/firebase_options.dart', 'android/app/google-services.json', '(gerados pelo FlutterFire CLI)') '#FEF7E0' '#F9AB00'
Caixa $g 1010 345 560 160 'Modo desenvolvimento (opcional)' @('emulador local do Firestore', '--dart-define=USAR_EMULADOR=true', 'endereço 10.0.2.2:8080') '#F6F8FA' '#8C959F'
Caixa $g 1010 590 560 270 'Cloud Firestore (Google Cloud)' @('projeto: mapa-locais-gabriel', 'banco (default) · região nam5', 'coleção: locais (20 documentos)', 'firestore.rules valida cada gravação', 'leitura pública · escrita validada') '#FCE8E6' '#D93025'
Caixa $g 80 1020 360 110 'OpenStreetMap' @('tile.openstreetmap.org (imagens)') '#F3E8FD' '#8430CE'
Caixa $g 480 1020 360 110 'Android (Intents)' @('Discador · Google Maps (rotas)') '#F3E8FD' '#8430CE'

Seta $g 840 725 1010 725 'HTTPS / gRPC' '#D93025' $true 0 -30
Seta $g 1010 295 842 668 'initializeApp(options)' '#B06000' $false -30 -40
Seta $g 260 945 260 1020 'HTTPS' '#8430CE' $false 40 -12
Seta $g 660 945 660 1020 'Intent' '#8430CE' $false 40 -12
$bmp.Save((Join-Path $Saida 'diagrama_arquitetura.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# ---------------- Diagrama 2: navegação ----------------
$im = Nova-Imagem 1600 760; $bmp = $im[0]; $g = $im[1]
$g.DrawString('Fluxo de navegação (3 telas principais)', $fT, [System.Drawing.Brushes]::Black, 40, 22)

Caixa $g 60 150 380 190 'Tela 1 — Mapa' @('cidade selecionada', 'pesquisa', 'marcadores + prévia do local', 'botão "Ver resultados"') '#E8F0FE' '#1A73E8'
Caixa $g 610 150 380 190 'Tela 2 — Resultados' @('pesquisa · cidade', 'chips de categoria / favoritos', 'lista vinda do Firestore', 'Novo local · Editar · Excluir') '#E6F4EA' '#1E8E3E'
Caixa $g 1160 150 380 190 'Tela 3 — Detalhes' @('fotos · avaliação · horário', 'Ligar · Como chegar · Agendar', 'coração (favorito)', 'botão "Ver no mapa"') '#FCE8E6' '#D93025'

Seta $g 440 215 610 215 'pesquisar / Ver resultados' '#1F2328' $false 0 -30
Seta $g 610 275 440 275 'voltar' '#5F6368' $false 0 6
Seta $g 990 215 1160 215 'tocar no local' '#1F2328' $false 0 -30
Seta $g 1160 275 990 275 'voltar' '#5F6368' $false 0 6

# Ver no mapa (curva por baixo)
$pen = New-Object System.Drawing.Pen (Cor '#D93025'), 3
$pen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 6, 7
$g.DrawLines($pen, [System.Drawing.Point[]]@((New-Object System.Drawing.Point 1350, 340), (New-Object System.Drawing.Point 1350, 420), (New-Object System.Drawing.Point 250, 420), (New-Object System.Drawing.Point 250, 342)))
$fI = New-Object System.Drawing.Font 'Segoe UI', 12, ([System.Drawing.FontStyle]::Italic)
$g.FillRectangle([System.Drawing.Brushes]::White, 600, 408, 400, 24)
$g.DrawString('"Ver no mapa": volta à Tela 1 centralizando o local', $fI, (New-Object System.Drawing.SolidBrush (Cor '#D93025')), 610, 408)
# marcador do mapa -> detalhes
$pen2 = New-Object System.Drawing.Pen (Cor '#1A73E8'), 3
$pen2.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap 6, 7
$g.DrawLines($pen2, [System.Drawing.Point[]]@((New-Object System.Drawing.Point 250, 150), (New-Object System.Drawing.Point 250, 100), (New-Object System.Drawing.Point 1350, 100), (New-Object System.Drawing.Point 1350, 148)))
$g.FillRectangle([System.Drawing.Brushes]::White, 630, 88, 360, 24)
$g.DrawString('marcador > prévia > "Ver detalhes"', $fI, (New-Object System.Drawing.SolidBrush (Cor '#1A73E8')), 650, 88)

Caixa $g 60 500 470 200 'Barra inferior (todas as telas)' @('Mapa: volta à Tela 1', 'Favoritos: abre a Tela 2 filtrada', 'Perfil: Bottom Sheet com resumo', 'do banco (locais, favoritos, cidades)') '#FEF7E0' '#F9AB00'
Caixa $g 590 500 470 200 'Sobreposições da Tela 2' @('Formulário de cadastro/edição', '(Bottom Sheet com validação)', 'Confirmação de exclusão (AlertDialog)', 'Seletor de cidade (Bottom Sheet)') '#E6F4EA' '#1E8E3E'
Caixa $g 1120 500 420 200 'Mensagens' @('SnackBar verde: sucesso', 'SnackBar vermelho: erro traduzido', 'telas de vazio e de erro', 'com "Tentar novamente"') '#F3E8FD' '#8430CE'
$bmp.Save((Join-Path $Saida 'diagrama_navegacao.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
'ok'
