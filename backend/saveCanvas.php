<?php
// Configura o cabeçalho para responder em formato JSON
header('Content-Type: application/json');

// Verifica se a requisição foi feita via POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['sucesso' => false, 'mensagem' => 'Método não permitido.']);
    exit;
}

// 1. Verifica se o arquivo foi enviado corretamente sem erros
if (!isset($_FILES['foto']) || $_FILES['foto']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(['sucesso' => false, 'mensagem' => 'Nenhum arquivo enviado ou erro no upload.']);
    exit;
}

// 2. Recebe e trata o caminho/patch enviado
// Se não for enviado, define uma pasta padrão 'uploads/'
//$path = isset($_POST['path']) ? trim($_POST['path']) : 'uploads/';

$path = getcwd().$_POST["path"];
$filename = $_POST["filename"];

//echo $path;

// Garante que o caminho termine com uma barra '/'
if (substr($path, -1) !== '/') {
    $path .= '/';
}

// 3. Cria a pasta automaticamente se ela não existir
if (!is_dir($path)) {
    // Cria a pasta com permissões de leitura e escrita (0755)
    if (!mkdir($path, 0755, true)) {
        echo json_encode(['sucesso' => false, 'mensagem' => 'Falha ao criar o diretório de destino.']);
        exit;
    }
}

// 4. Valida se o arquivo enviado é realmente uma imagem JPEG
$finfo = new finfo(FILEINFO_MIME_TYPE);
$mimeType = $finfo->file($_FILES['foto']['tmp_name']);

if ($mimeType !== 'image/jpeg') {
    echo json_encode(['sucesso' => false, 'mensagem' => 'Apenas arquivos JPG/JPEG são permitidos.']);
    exit;
}

// 5. Gera um nome único para o arquivo para evitar duplicações
//$nomeArquivo = uniqid('foto_', true) . '.jpg';
$caminhoCompleto = $path . $filename;

//echo $caminhoCompleto;

// 6. Move o arquivo temporário para o destino final no servidor
if (move_uploaded_file($_FILES['foto']['tmp_name'], $caminhoCompleto)) {
    echo json_encode([
        'sucesso' => true,
        'mensagem' => 'Imagem salva com sucesso!',
        'caminho' => $caminhoCompleto
    ]);
} else {
    echo json_encode(['sucesso' => false, 'mensagem' => 'Erro ao mover o arquivo para a pasta final.']);
}
