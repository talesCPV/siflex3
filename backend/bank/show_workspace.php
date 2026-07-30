<?php

    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    require_once __DIR__ . '/token.php';

    // 1. Captura o ID do Workspace enviado no POST (JSON ou form-data)
    $input = json_decode(file_get_contents("php://input"), true) ?: $_POST;
    $workspace_id = $input['id'] ?? null;

    // Valida se o ID foi fornecido
    if (!$workspace_id) {
        http_response_code(400);
        echo json_encode([
            "sucesso" => false,
            "erro" => "O parâmetro 'id' do workspace é obrigatório."
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

        // 2. Monta a URL de exclusão específica: base_url/{workspace_id}
        $url = str_replace('WORKSPACE_ID',$workspace_id,URL_WORKSPACE_ID);

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        // Configura o cURL para disparar explicitamente o método DELETE
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'GET');

        // Cabeçalhos padrão de autenticação do Santander
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . TOKEN,
            'X-Application-Key: ' . CLIENT_ID,
            'Content-Type: application/json'
        ]);

        // Configurações mTLS obrigatórias do banco
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
        curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);
        curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);
        curl_setopt($ch, CURLOPT_CAINFO, CAINFO);
        curl_setopt($ch, CURLOPT_SSLCERTPASSWD, CERT_PASSWORD);

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