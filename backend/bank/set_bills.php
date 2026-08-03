<?php
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    // Importa suas chaves, certificados e gerador de token já estruturados
    require_once __DIR__ . '/token.php'; 

    // 1. Captura os dados enviados para o script via POST
    $input = json_decode(file_get_contents("php://input"), true) ?: $_POST;

    $workspaceId = $input['workspace_id'] ?? null;
    $payload = json_decode($input['payload']) ?? null;         
    

//    var_dump($payload);
//    exit;

    // Validação básica dos campos cruciais antes de gastar processamento
    if (!$workspaceId || !$payload) {
        http_response_code(400);
        echo json_encode(["error" => "Campos obrigatorios faltando (workspace_id, payload)"]);
        exit;
    }

    $jsonPayload = json_encode($payload);

//var_dump($jsonPayload);
//exit;
// string(601) "{"nsuCode":"000000000050","nsuDate":"2026-08-03","environment":"PRODUCAO","covenantCode":"1226029","payer":{"documentType":"CNPJ","documentNumber":"00519547000106","name":"FLEXIBUS SANFONADOS","address":"AV DR ROSALVO DE ALMEIDA TELLES 2070","neighborhood":"NOVA CACAPAVA","city":"CACAPAVA","state":"SP","zipCode":"12283-020"},"bankNumber":"14","clientNumber":"A7","dueDate":"2026-09-02","issueDate":"2026-08-03","nominalValue":"1.00","documentKind":"BOLETO_DEPOSITO_APORTE","protestType":"SEM_PROTESTO","paymentType":"REGISTRO","key":{"type":"CNPJ","dictKey":"00519547000106"},"messages":["Teste 7"]}"
// string(668) "{"nsuCode":"000000000010","nsuDate":"2026-07-28","environment":"PRODUCAO","covenantCode":"1226029","payer":{"documentType":"CNPJ","documentNumber":"00519547000106","name":"FLEXIBUS SANFONADOS","address":"AV. DR. ROSALVO DE ALMEIDA TELLES,270 NO","neighborhood":"NOVA CACAPAVA","city":"CACAPAVA","state":"SP","zipCode":"12283-020"},"bankNumber":"9","clientNumber":"A5","dueDate":"2026-08-31","issueDate":"2026-07-28","nominalValue":"1.00","documentKind":"BOLETO_DEPOSITO_APORTE","protestType":"SEM_PROTESTO","paymentType":"REGISTRO","key":{"type":"CNPJ","dictKey":"00519547000106"},"messages":["Teste"],"digitableLine":"03399122630290000000700000901017915550000000100"}"
// string(601) "{"nsuCode":"000000000058","nsuDate":"2026-08-03","environment":"PRODUCAO","covenantCode":"1226029","payer":{"documentType":"CNPJ","documentNumber":"00519547000106","name":"FLEXIBUS SANFONADOS","address":"AV DR ROSALVO DE ALMEIDA TELLES 2070","neighborhood":"NOVA CACAPAVA","city":"CACAPAVA","state":"SP","zipCode":"12283-020"},"bankNumber":"13","clientNumber":"A8","dueDate":"2026-09-02","issueDate":"2026-08-03","nominalValue":"1.00","documentKind":"BOLETO_DEPOSITO_APORTE","protestType":"SEM_PROTESTO","paymentType":"REGISTRO","key":{"type":"CNPJ","dictKey":"00519547000106"},"messages":["Teste 8"]}"

    $url = str_replace("WORKSPACE_ID",$workspaceId,URL_COBRANCAS);

    // 4. Executa a chamada POST via cURL com os parâmetros de segurança corrigidos anteriormente
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonPayload);

    // Força o protocolo e o User-Agent contra bloqueios do WAF Akamai
    curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_2);
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AplicacaoCobranca/1.0');

    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer " . trim(TOKEN),
        "x-santander-client-id: " . trim(CLIENT_ID),
        "X-Application-Key: " . trim(CLIENT_ID),
        "workspaceId: " . trim($workspaceId),
        "Content-Type: application/json",
        "Accept: application/json"
    ]);


    // Vincula obrigatoriamente os certificados digitais de mTLS
    curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);
    curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);

    // Ignora validação local de CA (ideal para ambiente Localhost)
//    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, $api_mode =='PRODUCAO' ? true : false);
//    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, $api_mode =='PRODUCAO' ? 2    : false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if ($response === false) {
        $error_msg = curl_error($ch);
        http_response_code(500);
        echo json_encode(["error" => "Erro de conexao cURL no Localhost", "detalhes" => $error_msg]);
        curl_close($ch);
        exit;
    }

    curl_close($ch);

    // 5. Retorna o resultado enviado pelo banco para quem chamou o script PHP
    http_response_code($httpCode);
    echo $response;


?>