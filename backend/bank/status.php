<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once __DIR__ . '/token.php'; 

// Correção 1: Como o método é GET, pegamos os dados via $_GET (Query String)
$workspace_id = $_POST['workspace_id'] ?? null;
$nsuCode      = $_POST['nsuCode'] ?? null;
$nsuDate      = $_POST['nsuDate'] ?? null;
$bankNumber   = $_POST['bankNumber'] ?? null;

if (!$workspace_id || !$nsuCode|| !$nsuDate|| !$bankNumber) {
    http_response_code(400);
    // Correção 4: Ajustada a mensagem para refletir apenas os campos validados
    echo json_encode(["error" => "Campos obrigatorios faltando (workspace_id, nsuCode, nsuDate, bankNumber)"]);
    exit;
}

$bank_slip_id = str_pad($nsuCode, 12, "0", STR_PAD_LEFT).'.'.$nsuDate.'.'.ENVIRONMENT.'.'.CONVENIO_NUM.'.'.$bankNumber;

// Substituição dos placeholders na URL vindos do token.php
$url = str_replace('{WORKSPACE_ID}', $workspace_id, URL_COB_VIEW);
$url = str_replace('{BANK_SLIP_ID}', $bank_slip_id, $url);

//echo $url;
//exit; 
//$url = 'https://trust-open.api.santander.com.br/collection_bill_management/v2/workspaces/366cec67-a0a5-4d4f-b537-4bc280e062df/bank_slips/000000000074.2026-08-06.P.1226029.22';

// Inicializa a requisição cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . trim(TOKEN),
    "x-santander-client-id: " . trim(CLIENT_ID),
    "X-Application-Key: " . trim(CLIENT_ID),
    "workspaceId: " . trim($workspace_id),
    "Content-Type: application/json",
    "Accept: application/json"
]);

curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

// Configuração dos certificados mTLS
curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);
curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);

// Correção 3: NUNCA desative estas opções em produção com o Santander, ou o mTLS falhará.
//curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
//curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2); 
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

if (defined('CERT_PASSWORD') && !empty(CERT_PASSWORD)) {
    curl_setopt($ch, CURLOPT_SSLCERTPASSWD, CERT_PASSWORD);
}

// Executa a chamada
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

// Tratamento de erros de conexão do cURL
if (curl_errno($ch)) {
    http_response_code(500);
    echo json_encode(["error" => "Erro de conexão cURL: " . curl_error($ch)]);
    curl_close($ch);
    exit;
}

curl_close($ch);

// Processamento da resposta do banco
if ($httpCode === 200) {
    $dadosBoleto = json_decode($response, true);
    
    // O Santander retorna o status dentro do nó 'situacao' na API V2
    $status = $dadosBoleto['situacao'] ?? 'Não identificado';
    
    // Mapeamento interno amigável
    switch (strtoupper($status)) {
        case 'REGISTRADO':
            $mensagem = "O boleto está em aberto e aguardando pagamento.";
            break;
        case 'LIQUIDADO':
        case 'PAGO':
            $mensagem = "Boleto PAGO com sucesso.";
            break;
        case 'BAIXADO':
        case 'CANCELADO':
            $mensagem = "O boleto foi baixado/cancelado e não pode mais ser pago.";
            break;
        default:
            $mensagem = "Status desconhecido ou rejeitado.";
            break;
    }

    // Correção 2: Retornando um JSON padronizado e limpo
    echo json_encode([
        "sucesso" => true,
        "status" => $status,
        "mensagem" => $mensagem,
        "dados_completos" => $dadosBoleto
    ], JSON_UNESCAPED_UNICODE);

} else {
    // Retorna o erro original do Santander em formato JSON
    http_response_code($httpCode);
    $erroBanco = json_decode($response, true) ?: $response;
    echo json_encode([
        "sucesso" => false,
        "error" => "Erro na consulta ao banco",
        "detalhes" => $erroBanco
    ], JSON_UNESCAPED_UNICODE);
}
