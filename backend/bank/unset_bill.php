<?php
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: PATCH");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    require_once __DIR__ . '/token.php'; 

    $input = json_decode(file_get_contents("php://input"), true) ?: $_POST;

    $workspace_id = $input['workspace_id'] ?? null;
    $bankNumber = $input['bankNumber'] ?? null;
    $operation = $input['operation'] ?? null;
    $operation_value = $input['op_value'] ?? null;

    if (!$workspace_id || !$bankNumber || !$operation || !$operation_value) {
        http_response_code(400);
        echo json_encode(["error" => "Campos obrigatorios faltando (workspace_id, bankNumber, operation e operation value)"]);
        exit;
    }

    $url = str_replace('{WORKSPACE_ID}',$workspace_id,URL_ALTER);

//echo $url;
//exit;

    $payload = [
        "covenantCode" => CONVENIO_NUM,
        "bankNumber" => $bankNumber,
        $operation => $operation_value
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer " . trim(TOKEN),
        "x-santander-client-id: " . trim(CLIENT_ID),
        "X-Application-Key: " . trim(CLIENT_ID),
        "workspaceId: " . trim($workspace_id),
        "Content-Type: application/json",
        "Accept: application/json"
    ]);

    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PATCH");
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSLCERT, CERT_FILE);
    curl_setopt($ch, CURLOPT_SSLKEY, KEY_FILE);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

    $resposta = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    // CAPTURA O ERRO REAL ANTES DE FECHAR O HANDLE
    $curlErrorNo = curl_errno($ch);
    $curlErrorMsg = curl_error($ch);

    curl_close($ch);

    if ($httpCode === 200 || $httpCode === 201 || $httpCode === 204) {
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Operacao '{$operation}' realizada com sucesso no Santander!"
        ]);
    } else {
        http_response_code($httpCode === 0 ? 500 : $httpCode);
        echo json_encode([
            "success" => false,
            "message" => "Erro ao processar boleto. Codigo HTTP: " . $httpCode,
            "curl_error_code" => $curlErrorNo,
            "curl_error_message" => $curlErrorMsg,
            "details" => json_decode($resposta, true) ?: $resposta 
        ]);
    }

?>
