<?php

    if (IsSet($_POST["params"]) && IsSet($_POST["access"]) && IsSet($_POST["hash"])){

        $protocolo = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https://' : 'http://';
        $dominio = $_SERVER['HTTP_HOST'];
        $url = $protocolo . $dominio . '/siflex3/backend/query_db.php'; 

        $dados = [
            'cod'    => 'BANK-1',
            'params' => $_POST["params"],
            'access' => $_POST["access"], 
            'hash'   => $_POST["hash"]
        ];
//echo $url;
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $dados);

        $resultado_json = curl_exec($ch);

        $linhas = json_decode($resultado_json, true);
        if (is_array($linhas)) {
            foreach ($linhas as &$linha) {
                if (isset($linha['sucess']) && isset($linha['oper']) && isset($linha['message']) && isset($_POST["workspaceId"])) {
                    if($linha['oper']=='INSERT' && $linha['sucess']==1 && isset($linha['nsuCode'])){
                        $worspace_id = $_POST["workspaceId"];
                        $nsuCode = $linha['nsuCode'];
                        $dados = json_decode($_POST["params"],true);
                        $dados["nsuCode"] = str_pad($linha['nsuCode'], 12, "0", STR_PAD_LEFT);
                        $dados["bankNumber"] = $linha['bankNumber'];
                        $dados["issueDate"] = $dados["nsuDate"];
                        $dados["nominalValue"] = number_format((float)$dados["nominalValue"], 2, '.', '');
                        if($dados["protestType"] == "SEM_PROTESTO"){
                            unset($dados["protestQuantityDays"]);
                        }
                        $dados["messages"] = [$dados["messages"]];
                        $dados["payer"] = new stdClass();
                        $dados["payer"]->documentType = $dados["payer_documentType"];
                        unset($dados["payer_documentType"]);
                        $dados["payer"]->documentNumber = $dados["payer_documentNumber"];
                        unset($dados["payer_documentNumber"]);
                        $dados["payer"]->name = $dados["payer_name"];
                        unset($dados["payer_name"]);
                        $dados["payer"]->address = $dados["payer_address"];
                        unset($dados["payer_address"]);
                        $dados["payer"]->neighborhood = $dados["payer_neighborhood"];
                        unset($dados["payer_neighborhood"]);
                        $dados["payer"]->city = $dados["payer_city"];
                        unset($dados["payer_city"]);
                        $dados["payer"]->state = $dados["payer_state"];
                        unset($dados["payer_state"]);
                        $dados["payer"]->zipCode = $dados["payer_zipCode"];
                        unset($dados["payer_zipCode"]);
                        $dados["key"] = new stdClass();
                        $dados["key"]->type = "CNPJ";
                        $dados["key"]->dictKey = "00519547000106";

                        $url = $protocolo . $dominio . '/siflex3/backend/bank/set_bills.php'; 
                        $payload = [
                            'workspaceId' => $worspace_id,
                            'payload' => $dados
                        ];
                        $ch = curl_init($url);
                        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                        curl_setopt($ch, CURLOPT_POST, true);
                        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
                        curl_setopt($ch, CURLOPT_HTTPHEADER, [
                            'Content-Type: application/json',
                            'Content-Length: ' . strlen(json_encode($payload))
                        ]);

                        $resultado_json = curl_exec($ch);
                        $linhas = json_decode($resultado_json, true);

                        var_dump($linhas);
                        exit;


                    }
                }
            }
            unset($linha);
        }

        // 7. Retorna o resultado final modificado em formato JSON
        header('Content-Type: application/json');
        echo json_encode($rows);
    }
?>
