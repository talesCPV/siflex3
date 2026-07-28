<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

require_once __DIR__ . '/token.php';

$workspace_id = $_GET['workspace_id'] ?? null;
$nsuCode      = $_GET['nsu_code'] ?? null; // Vamos buscar pelo identificador do boleto

if (!$workspace_id || !$nsuCode) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "erro" => "Os parâmetros 'workspace_id' e 'nsu_code' são obrigatórios para consulta unitária."
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $covenantCode = defined('CONVENIO_NUM') ? trim(CONVENIO_NUM) : '1226029';

    // 1. Monta os parâmetros de consulta unitária para o boleto em aberto
    // O Santander permite buscar um título específico usando filtros dedicados na query string
    $params = [
        'covenantCode' => $covenantCode,
        'status' => 'EM_ABERTO',
        'paymentDateInitial' => '2026-07-28',
        'paymentDateFinal'   => '2026-08-31',
        'nsuCode'      => str_pad($nsuCode, 12, "0", STR_PAD_LEFT) // "000000000010"
    ];

//var_dump($params);
//exit;

    $queryParams = http_build_query($params);

    // 2. Aponta para a rota base correta do barramento de Workspaces
    $urlSondaUnitária = rtrim(URL_WORKSPACES, '/') . '/' . $workspace_id . '/bank_slips?' . $queryParams;

echo $urlSondaUnitária;
exit;

    // Caso a sua URL_WORKSPACES já mude dependendo da versão, use a rota padrão mapeada do manual:
    // $urlSondaUnitária = "https://santander.com.br{$workspace_id}/bank_slips/{$nsuFormatado}?covenantCode={$covenantCode}";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $urlSondaUnitária);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPGET, true);

    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) FlexibusApp/2.0');

    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . trim(TOKEN),
        'X-Application-Key: ' . trim(CLIENT_ID),
        'x-santander-client-id: ' . trim(CLIENT_ID),
        'workspaceId: ' . trim($workspace_id),
        'Content-Type: application/json',
        'Accept: application/json'
    ]);

    // Ignora emissor local por estar em Localhost
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);
    curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        throw new Exception("Erro cURL: " . curl_error($ch));
    }
    curl_close($ch);

    http_response_code($httpCode);
    $dadosBanco = json_decode($response, true);
    
    if ($httpCode === 200) {
        echo json_encode([
            "sucesso" => true,
            "boleto" => $dadosBanco
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            "sucesso" => false,
            "erro" => "Erro ao consultar boleto de forma unitária.",
            "status_http" => $httpCode,
            "detalhes" => $dadosBanco ?: $response
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["sucesso" => false, "erro" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
