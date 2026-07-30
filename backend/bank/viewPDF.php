<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

require_once __DIR__ . '/token.php';

$filename            = $_POST['filename'] ?? null;
$digitableLine          = '03399122630290000000700000901017915550000000100'; //$_POST['digitableLine'] ?? null;
$payerDocumentNumber   = $_POST['payerDocumentNumber'] ?? null;


if (!$filename || !$digitableLine || !$payerDocumentNumber) {
    http_response_code(400);
    echo json_encode([
        "sucesso" => false,
        "erro" => "Os parâmetros 'filename', 'digitableLine' e 'payerDocumentNumber' são obrigatórios para busca do título."
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $url =  str_replace('{digitableLine}',$digitableLine,URL_COB_PDF);  // 

    $payload = json_encode(["payerDocumentNumber" => $payerDocumentNumber]);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    // DEFINA COMO POST (O endpoint de impressão exige POST)
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) FlexibusApp/2.0');

    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . trim(TOKEN),
        'X-Application-Key: ' . trim(CLIENT_ID),
        'x-santander-client-id: ' . trim(CLIENT_ID),
        'Content-Type: application/json',
        'Accept: application/json',
        'Content-Length: ' . strlen($payload)
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

//var_dump($response);
//exit;
    $dadosBanco = json_decode($response, true);

    if ($httpCode === 200) {
        // O Santander retorna o PDF em Base64 na chave 'conteudoBase64' ou 'documentoBase64'
//        $chavePdf = isset($dadosBanco['conteudoBase64']) ? 'conteudoBase64' : (isset($dadosBanco['documentoBase64']) ? 'documentoBase64' : null);

        if (isset($dadosBanco['link'])) {
            $urlPdfSantander = $dadosBanco['link'];
            $pdfBinario = file_get_contents($urlPdfSantander);


            if ($pdfBinario === false) {
                throw new Exception("Falha ao baixar o PDF do link fornecido pelo banco.");
            }

            // 2. DEFINE O CAMINHO (PATH) ONDE O ARQUIVO SERÁ SALVO
            // Substitua '/caminho/da/sua/pasta/' pelo diretório real no seu servidor (ex: __DIR__ . '/boletos/')
            // Garanta que essa pasta tenha permissão de escrita (Chmod 775 ou 777)
            $diretorioSalvamento = __DIR__ . '/../../boletos/';
            
            // Cria a pasta automaticamente se ela não existir
            if (!is_dir($diretorioSalvamento)) {
                mkdir($diretorioSalvamento, 0755, true);
            }

            $nomeArquivo =  $filename . ".pdf";
            $pathCompleto = $diretorioSalvamento . $nomeArquivo;

            // 3. SALVA O ARQUIVO NO PATH DEFINIDO
            file_put_contents($pathCompleto, $pdfBinario);


/*            
            if (ob_get_contents()) ob_end_clean();
            header("Content-Type: application/pdf");
            header("Content-Disposition: inline; filename=\"boleto_{$bankNumber}.pdf\"");
            echo json_encode(["sucesso" => true, "boleto" => $dadosBanco], JSON_UNESCAPED_UNICODE);
            exit;
*/
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
