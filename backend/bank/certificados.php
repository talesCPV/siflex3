<?php

    // API MODE : SANDBOX || PRODUCAO
    $api_mode = 'SANDBOX'/*'PRODUCAO'*/;

    // DADOS BANCÁRIOS
    define('CC_NUM', '130011898'); // 
    define('BANK_NUM', '033'); // 
    define('CONVENIO_NUM', $api_mode == 'PRODUCAO' ?'1226029':'00334455'); // SANDBOX:00334455 | PRODUÇAO:1226029

    // CLIENT ID
    define('CLIENT_ID', $api_mode == 'PRODUCAO' ? '2jg0FdFoeVwQQsT7Wum3t3K7gh3nkG4B':'5P8skdRxn44iqJRbxcvtTZyaiFFDGago');
    define('CLIENT_SECRET', $api_mode == 'PRODUCAO' ? '40QFH1ebz6ufMkcL':'UxBspeUN1od9mCqh');

    // CERTIFICADOS
    define('CERT_FILE', __DIR__ . '/certificados/certificado.crt');
    define('KEY_FILE', __DIR__ . '/certificados/chave_privada.key');
    define('PEM_FILE', __DIR__ . '/certificados/certificado.pem');
    define('CERT_PASSWORD', '#Ridicula1');
    define('CAINFO', __DIR__ . '/certificados/cacert-2026-05-14.pem');

    // WEBHOOKS
    define('WEBHOOK_KEY', 'flex0169'); 
    define('WEBHOOK_COB', 'https://www.flexibus.com.br/webhooks/cobranca.php');

    // ENDPOINTS
    $url_matrix = $api_mode == 'PRODUCAO' ? 'https://trust-open.api.santander.com.br' : 'https://trust-sandbox.api.santander.com.br';

    // POST: recepção do Access Token
    define('URL_TOKEN'        ,$url_matrix."/auth/oauth/v2/token");
    // POST e GET: criação e consulta de Workspaces
    define('URL_WORKSPACES'   ,$url_matrix."/collection_bill_management/v2/workspaces");
    // GET, PATCH e DELETE: consulta por Workspace_ID, alteração e exclusão de Workspace
    define('URL_WORKSPACE_ID' ,$url_matrix."/collection_bill_management/v2/workspaces/WORKSPACE_ID");
    // POST e PATCH: registro e alteração de Boletos
    define('URL_COBRANCAS'    ,$url_matrix."/collection_bill_management/v2/workspaces/WORKSPACE_ID/bank_slips");
    // POST: geração da imagem do boleto em PDF
    define('URL_COB_PDF'      ,$url_matrix."/collection_bill_management/v2/bills/{bankNumber}.{covenantCode}/bank_slips");
    // GET (SONDA): consulta de boletos registrados via API
    define('URL_COB_VIEW'     ,$url_matrix."/ collection_bill_management/v2/workspaces/{WORKSPACE_ID}/bank_slips/{BANK_SLIP_ID}");
    // GET: consulta detalhes de boleto registrado no convênio – Nosso Número:
    define('URL_COB_NN'       ,$url_matrix."/collection_bill_management/v2/bills?beneficiaryCode=1234567&bankNumber=1234567890123");
    // GET: consulta detalhes de boleto registrado no convênio – Seu Número:
    define('URL_COB_SN'       ,$url_matrix."/collection_bill_management/v2/bills?beneficiaryCode=1234567 &clientNumber=123456789012345&dueDate=2023-01-01&nominalValue=3.45");
    // GET: consulta detalhes de um boleto registrado no convênio, por Tipo:
    define('URL_BILL_ID'      ,$url_matrix."/collection_bill_management/v2/bills/{bill_id}?tipoConsulta=default");

?>