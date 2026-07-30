<?php

    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    require_once __DIR__ . '/token.php';

    $input = json_decode(file_get_contents("php://input"), true) ?: $_POST;
    $nomeWorkspace = $input['nome'] ?? 'workspace_sem_nome';

    function criarWorkspaceSantander($nomeWorkspace) {

        $payload = [
            "type" => "BILLING",
            "description" => trim($nomeWorkspace),
            "covenants" => [
                [
                    "code" => trim(CONVENIO_NUM)
                ]
            ],
            "webhookURL" => WEBHOOK_COB, 
            "bankSlipBillingWebhookActive" => true,
            "pixBillingWebhookActive" => true
        ];


//var_dump($payload)        ;
//exit;
        // Inicializa o cURL
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, URL_WORKSPACES);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . TOKEN,
                'X-Application-Key: ' . CLIENT_ID,
                'Content-Type: application/json'
            ],
            
            // Configurações obrigatórias de mTLS (Certificado Digital)
            CURLOPT_SSLCERT => CERT_FILE,
            CURLOPT_SSLKEY => KEY_FILE,
            CURLOPT_CAINFO => CAINFO,
            CURLOPT_SSLCERTPASSWD => CERT_PASSWORD,
        ]);

        // Executa a requisição
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        // Verifica erros de conexão cURL
        if (curl_errno($ch)) {
            $errorMsg = curl_error($ch);
            curl_close($ch);
            throw new Exception("Erro de conexão cURL no Workspace: " . $errorMsg);
        }

        curl_close($ch);

        // Processa a resposta do banco (Espera-se o Status 201)
        if ($httpCode === 201) {
            $data = json_decode($response, true);
            
            // Retorna o ID da Workspace gerada (Ajuste o índice baseado no JSON de resposta do banco)
            return $data['workspaceId'] ?? $data['id'] ?? null;
        } else {
            throw new Exception("Erro ao criar Workspace ({$httpCode}): " . $response);
        }
    }

    try {

    //    echo "2. Solicitando criação de nova Workspace...<br>";
        $workspaceId = criarWorkspaceSantander($nomeWorkspace);
        
//        print $workspaceId;
//        exit;

        if ($workspaceId) {
    //echo $workspaceId; 
        sleep(30);
            require_once __DIR__ . '/get_workspaces.php'; 
        } else {
            echo "Workspace criada, mas o ID não foi mapeado no JSON de retorno.<br>";
        }

    } catch (Exception $e) {
        echo "<span style='color:red;'><b>Falha no processo:</b> " . $e->getMessage() . "</span><br>";
    }

?>