<?php

    require_once __DIR__ . '/token.php';

    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    $ch = curl_init();

    curl_setopt($ch, CURLOPT_URL, URL_WORKSPACES. "?_page=1&_limit=50");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'GET');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . TOKEN,
        'X-Application-Key: ' . CLIENT_ID,
        'Content-Type: application/json'
    ]);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true); // Garante a validação do certificado do banco
    curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);   // Envia o seu certificado
    curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);     // Envia a sua chave privada
    curl_setopt($ch, CURLOPT_CAINFO, CAINFO);
    curl_setopt($ch, CURLOPT_SSLCERTPASSWD, CERT_PASSWORD);

    // Executa a chamada HTTP contra a API do Santander
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    // Captura erros de conexão cURL (ex: arquivo de certificado não encontrado ou inválido)
    if (curl_errno($ch)) {
        $errorMsg = curl_error($ch);
        curl_close($ch);
        http_response_code(500);
        echo json_encode([
            'error' => 'Erro de conexão cURL / mTLS',
            'details' => $errorMsg
        ]);
        exit;
    }

    curl_close($ch);

    // Repassa a resposta e o código de status recebidos diretamente do banco
    http_response_code($httpCode);
    print $response;

?>
