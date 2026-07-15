<?php

require_once __DIR__ . '/certificados.php';

function obterAccessTokenSantander() {
    // Montagem do corpo aceito em ambas as variantes do gateway v2 do Santander
    $bodyData = http_build_query([
        'grant_type'    => 'client_credentials',
        'client_id'     => CLIENT_ID,
        'client_secret' => CLIENT_SECRET,
        'scope'         => $scope ?? 'cobranca.read' //'cobranca.read', 'collection-bills.read'
    ]);

    // Cria a credencial Base64 padrão internacional OAuth2 (pode ser exigida no Sandbox)
    $base64Credentials = base64_encode(CLIENT_ID . ':' . CLIENT_SECRET);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, URL_TOKEN);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $bodyData);
    
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/x-www-form-urlencoded',
            'X-Application-Key: ' . CLIENT_ID,
            'X-Scope: cobranca.read', // Injeta o escopo no cabeçalho (exigência de algumas proxies Akamai)
            // 'Authorization: Basic ' . $base64Credentials // Descomente esta linha APENAS se der erro 401 no token
        ],
        CURLOPT_SSLCERT => CERT_FILE,
        CURLOPT_SSLKEY => KEY_FILE,
    ]);

    if (defined('CERT_PASSWORD') && CERT_PASSWORD !== '') {
        curl_setopt($ch, CURLOPT_SSLKEYPASSWD, CERT_PASSWORD);
    }

    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        $errorMsg = curl_error($ch);
        curl_close($ch);
        throw new Exception("Erro de conexao cURL no Token: " . $errorMsg);
    }

    curl_close($ch);

    if ($httpCode === 200) {
        $data = json_decode($response, true);
        $rawToken = $data['access_token'] ?? null;

        if ($rawToken) {
            $cleanToken = str_replace(["\r\n", "\n", "\r", " "], "", $rawToken);
            return trim($cleanToken);
        }
        return null;
    } else {
        throw new Exception("Erro ao gerar Token Santander ({$httpCode}): " . $response);
    }
}

try {
    $token = obterAccessTokenSantander();
    if ($token) {
//echo $token;        
        define('TOKEN', $token);
    } else {
        define('TOKEN', '');
    }
} catch (Exception $e) {
    define('TOKEN', '');
    header("Content-Type: application/json; charset=UTF-8");
    http_response_code(500);
    echo json_encode([
        "error" => "Falha ao obter o token no arquivo de chaves", 
        "detalhes" => $e->getMessage()
    ]);
    exit;
}
?>
