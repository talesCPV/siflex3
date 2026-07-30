<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

require_once __DIR__ . '/token.php';

$payer_documentNumber   = $_POST['documentNumber'] ?? null;


if (!$payer_documentNumber) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "erro" => "Os parâmetros 'payer_documentNumber' é obrigatório para busca do título."
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 1. ALTERE A SUA URL_BOL_PDF PARA O ENDPOINT CORRETO DE IMPRESSÃO DO WORKSPACE:
    // Formato oficial: https://trust-open.api.santander.com.br/collection_bill_management/v2/workspaces/{seu_workspace_id}/bank_slips/impressao
    // (Substitua a string abaixo pelo seu Workspace ID real)
    $url = "https://santander.com.br";

    // 2. Monte o corpo passando o Nosso Número / ID dentro de um array
    $payloadData = json_encode([
        "nossosNumeros" => [ $payer_documentNumber ] // O número do boleto vai aqui dentro
    ]);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    // DEFINA COMO POST (O endpoint de impressão exige POST)
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payloadData);

    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) FlexibusApp/2.0');

    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . trim(TOKEN),
        'X-Application-Key: ' . trim(CLIENT_ID),
        'x-santander-client-id: ' . trim(CLIENT_ID),
        'Content-Type: application/json',
        'Accept: application/json',
        'Content-Length: ' . strlen($payloadData)
    ]);

    // Ignora emissor local
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

    $dadosBanco = json_decode($response, true);

    if ($httpCode === 200) {
        // O Santander retorna o PDF em Base64 na chave 'conteudoBase64' ou 'documentoBase64'
        $chavePdf = isset($dadosBanco['conteudoBase64']) ? 'conteudoBase64' : (isset($dadosBanco['documentoBase64']) ? 'documentoBase64' : null);

        if ($chavePdf && isset($dadosBanco[$chavePdf])) {
            $pdfBinario = base64_decode($dadosBanco[$chavePdf]);
            
            if (ob_get_contents()) ob_end_clean();
            
            header("Content-Type: application/pdf");
            header("Content-Disposition: inline; filename=\"boleto_{$payer_documentNumber}.pdf\"");
            echo $pdfBinario;
            exit;
        }

        http_response_code(200);
        echo json_encode(["sucesso" => true, "boleto" => $dadosBanco], JSON_UNESCAPED_UNICODE);
    } else {
        http_response_code($httpCode);
        echo json_encode([
            "sucesso" => false,
            "erro" => "Erro ao processar impressão do boleto.",
            "status_http" => $httpCode,
            "detalhes" => $dadosBanco ?: $response
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["sucesso" => false, "erro" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
