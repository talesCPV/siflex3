<?php

    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: DELETE, POST");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    require_once __DIR__ . '/token.php';

    // 1. Captura o ID do Workspace enviado no POST (JSON ou form-data)
    $input = json_decode(file_get_contents("php://input"), true) ?: $_POST;
    $workspaceId = $input['id'] ?? null;

    // Valida se o ID foi fornecido
    if (!$workspaceId) {
        http_response_code(400);
        echo json_encode([
            "sucesso" => false,
            "erro" => "O parâmetro 'id' do workspace é obrigatório."
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    try {
        // 2. Monta a URL de exclusão específica: base_url/{workspace_id}
        $urlExclusao = rtrim(URL_WORKSPACES, '/') . '/' . trim($workspaceId);

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $urlExclusao);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        // Configura o cURL para disparar explicitamente o método DELETE
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');

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

        if (curl_errno($ch)) {
            $errorMsg = curl_error($ch);
            curl_close($ch);
            throw new Exception("Erro de conexão cURL no mTLS: " . $errorMsg);
        }

        curl_close($ch);

        // O Santander responde com HTTP 204 quando o registro é deletado com sucesso
        if ($httpCode === 204) {
            http_response_code(200);
            echo json_encode([
                "sucesso" => true,
                "mensagem" => "Workspace excluído com sucesso do banco de dados do Santander."
            ], JSON_UNESCAPED_UNICODE);
        } else {
            // Trata erros de ID inexistente (geralmente 404 ou 400)
            http_response_code($httpCode);
            echo json_encode([
                "sucesso" => false,
                "erro" => "O banco retornou um erro ao tentar excluir.",
                "status_http" => $httpCode,
                "resposta_banco" => json_decode($response, true) ?: $response
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