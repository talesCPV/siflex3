<?php
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: PATCH");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    // 1. Inclui o arquivo que gera o token automaticamente
    require_once __DIR__ . '/token.php';

    // 2. Verifica se os parâmetros foram enviados via POST
    $workspace_id = $_POST['workspace_id'] ?? null;
    $webhook      = $_POST['webhook_url'] ?? null;

    if (!$workspace_id || !$webhook) {
        http_response_code(400);
        echo "<b>Erro:</b> Os parâmetros 'workspace_id' e 'webhook_url' são obrigatórios via método POST.<br>";
        exit();
    }

    /**
     * Função responsável por adicionar o webhook na Workspace via PUT
     */
    function adicionarWebhookSantander($workspace_id, $webhook) {
        // Rota de atualização da Workspace (Exige método PUT)
        $url = str_replace('WORKSPACE_ID',$workspace_id,URL_WORKSPACE_ID);
        // https://trust-open.api.santander.com.br/collection_bill_management/v2/workspaces/366cec67-a0a5-4d4f-b537-4bc280e062df

        // Payload correto para a API de Cobrança/Workspace do Santander
        $payload = json_encode([
            "description"=> "Workspace de Cobrança Flexibus",
            "covenants"=> [
                [
                "code" => trim((string)CONVENIO_NUM)
                ]
            ],
            "webhookURL" => trim($webhook),
//            "webhookKey"=> WEBHOOK_KEY,
            "bankSlipBillingWebhookActive" => true,
            "pixBillingWebhookActive" => true
        ]);

//var_dump($payload);

        // Inicializa o cURL
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);
        // O Santander exige PATCH para atualizar as propriedades da Workspace existente
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH'); 
        curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . TOKEN,
                'X-Application-Key: ' . CLIENT_ID,
                'Content-Type: application/json',
                'Accept: application/json'
            ],
            
            // Configurações de mTLS (Certificado Digital)
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSLCERT => CERT_FILE,
            CURLOPT_SSLKEY => KEY_FILE,
            CURLOPT_CAINFO => CAINFO,
            CURLOPT_SSLCERTPASSWD => CERT_PASSWORD,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        if (curl_errno($ch)) {
            $errorMsg = curl_error($ch);
            curl_close($ch);
            throw new Exception("Erro de conexão cURL no Webhook: " . $errorMsg);
        }

        curl_close($ch);

        // O Santander retorna 200 OK ou 204 No Content se a atualização for aceita
        if ($httpCode === 200 || $httpCode === 204) {
            return true;
        } else {
            throw new Exception("Erro ao configurar Webhook ({$httpCode}): " . $response);
        }
    }

    // ========================================================
    // EXECUÇÃO DO FLUXO
    // ========================================================
    try {
        // CORREÇÃO: Passando o $webhook como segundo parâmetro da função
        $sucesso = adicionarWebhookSantander($workspace_id, $webhook);
        
        if ($sucesso) {
            http_response_code(200);
            echo "<b>Sucesso!</b> Webhook configurado com sucesso para a URL: " . htmlspecialchars($webhook) . " na Workspace: <u>" . htmlspecialchars($workspace_id) . "</u>";
        }

    } catch (Exception $e) {
        http_response_code(500);
        echo "<span style='color:red;'><b>Falha no processo:</b> " . $e->getMessage() . "</span>";
    }

?>