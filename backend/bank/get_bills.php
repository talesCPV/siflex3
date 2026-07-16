<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

require_once __DIR__ . '/token.php';

$workspace_id = $_GET['workspace_id'] ?? null;
$dataInicio = $_GET['data_inicio'] ?? null;
$dataFim    = $_GET['data_fim'] ?? null;
$statusBusca = isset($_GET['status']) ? strtoupper(trim($_GET['status'])) : 'LIQUIDADO'; // Padrão se omitido
$pagina     = isset($_GET['pagina']) ? (int)$_GET['pagina'] : 1;
$limite     = isset($_GET['limite']) ? (int)$_GET['limite'] : 50;

$dataIniTipo = isset($_GET['data_range']) ? ($_GET['data_range']=='REG'?'registrationDateInitial':($_GET['data_range']=='DUE'?'dueDateInitial':'paymentDateInitial')):'dueDateInitial'; // Registro(REG), Vencimento(DUE), Pagamento(PAY)
$dataFinTipo = isset($_GET['data_range']) ? ($_GET['data_range']=='REG'?'registrationDateFinal'  :($_GET['data_range']=='DUE'?'dueDateFinal'  :'paymentDateFinal'  )):'dueDateFinal'; // Registro(REG), Vencimento(DUE), Pagamento(PAY)

if (!$dataInicio || !$dataFim) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "erro" => "Os parâmetros 'data_inicio' e 'data_fim' no formato YYYY-MM-DD são obrigatórios."
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // Parâmetros de data aceitos na rota de lote do barramento de Workspaces do Santander
    $queryParams = http_build_query([
        'covenantCode'       => defined('CONVENIO_NUM') ? trim(CONVENIO_NUM) : '1226029',
        $dataIniTipo  => trim($dataInicio),
        $dataFinTipo  => trim($dataFim),
        'status'      => $statusBusca,
        'page'        => (int)(($pagina > 1) ? ($pagina - 1) : 0),
        'size'        => (int)$limite
    ]);

    $urlSondaGlobal = rtrim(URL_WORKSPACES, '/') . '/' . $workspace_id . '/bank_slips?' . $queryParams;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $urlSondaGlobal);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPGET, true);

    // Envia cabeçalho identificador corporativo exigido pelo WAF da Akamai
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) FlexibusApp/2.0');

    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . TOKEN,
        'X-Application-Key: ' . CLIENT_ID,
        'Content-Type: application/json',
        'Accept: application/json'
    ]);

    // mTLS Produção ativa
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
    curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);
    curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);
    curl_setopt($ch, CURLOPT_CAINFO, defined('CAINFO') ? CAINFO : __DIR__ . '/cacert.pem');

    if (defined('CERT_PASSWORD') && !empty(CERT_PASSWORD)) {
        curl_setopt($ch, CURLOPT_SSLCERTPASSWD, CERT_PASSWORD);
    }

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        $errorMsg = curl_error($ch);
        curl_close($ch);
        throw new Exception("Erro de conexão cURL / mTLS: " . $errorMsg);
    }

    curl_close($ch);

    http_response_code($httpCode);
    $dadosBanco = json_decode($response, true);
    
    if ($httpCode === 200 || $httpCode === 206) {
        echo json_encode([
            "sucesso" => true,
            "periodo" => "{$dataInicio} ate {$dataFim}",
            // Descompacta a lista contida na propriedade nativa de retorno de lote 'content'
            "boletos" => $dadosBanco['content'] ?? $dadosBanco['_content'] ?? $dadosBanco ?? []
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            "sucesso" => false,
            "erro" => "Erro de autenticação ou parâmetro no barramento de Workspaces.",
            "status_http" => $httpCode,
            "detalhes" => $dadosBanco ?: strip_tags($response)
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "sucesso" => false,
        "erro" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

?>