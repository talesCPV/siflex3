<?php

    $query_db = array(
        /* LOGIN */
        "LOG-0"  => 'CALL sp_login("x00", "x01");', // USER, PASS

        /* USERS */
        "USR-0"  => 'CALL sp_viewUser(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "USR-1"  => 'CALL sp_setUser(@access,@hash,x00,"x01","x02","x03");', // ID, EMAIL, PASS, ACCESS
        "USR-2"  => 'CALL sp_updatePass(@hash,"x00");', // PASS
        "USR-3"  => 'CALL sp_check_usr_mail(@hash);', //

        /* CALENDAR */
        "CAL-0"  => 'CALL sp_view_calendar(@hash,"x00","x01");', // DT_INI, DT_FIN
        "CAL-1"  => 'CALL sp_set_calendar(@hash,"x00","x01");', // DT_AGD, OBS

        /* MAIL */
        "MAIL-0"  => 'CALL sp_set_mail(@hash,"x00","x01");', // ID_TO, MESSAGE
        "MAIL-1"  => 'CALL sp_view_mail(@hash,x00);', // I_SEND
        "MAIL-2"  => 'CALL sp_all_mail_adress(@hash);', //      
        "MAIL-3"  => 'CALL sp_del_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO
        "MAIL-4"  => 'CALL sp_mark_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO

        /* FUNCIONÁRIOS */
        "FUN-0"  => 'CALL sp_view_func(@access,@hash,"x00","x01","x02",x03);', // FIELD,SIGNAL, VALUE, ATIVO
        "FUN-1"  => 'CALL sp_set_func(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09","x10","x11","x12","x13","x14","x15","x16","x17","x18","x19","x20");', // id,nome,nasc,rg,cpf,pis,end,num,cidade,bairro,uf,cep,data_adm,data_dem,id_cargo,id_setor,tel,cel,ativo,obs,reg,nick
        "FUN-2"  => 'CALL sp_del_func(@access,@hash,x00);', // ID
        "FUN-3"  => 'CALL sp_view_vale(@access,@hash,x00);', // ID_FUNC
        "FUN-4"  => 'CALL sp_set_vale(@access,@hash,x00,x01,"x02",x03,"x04","x05");', // ID,ID_FUNC,VALOR,QUITADO,OBS,DATA
        "FUN-5"  => 'CALL sp_view_vale_pgto(@access,@hash,x00);', // ID_FUNC
        "FUN-6"  => 'CALL sp_set_vale_pgto(@access,@hash,x00,"x01","x02","x03");', // ID, VALOR, DATA, OBS
        "FUN-7"  => 'CALL sp_set_func_setor(@access,@hash,x00,x01);', // ID_FUNC, ID_SETOR

        /* EMPRESAS */
        "EMP-0"  => 'CALL sp_view_emp(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "EMP-1"  => 'CALL sp_set_emp(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09","x10","x11","x12","x13","x14","x15","x16");', // id,razao_social,fant,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,cliente,ramo,tel,email
        "EMP-2"  => 'CALL sp_del_emp(@access,@hash,x00);', // ID

        /* PRODUTOS */
        "PROD-0" => 'CALL sp_view_prod(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "PROD-1" => 'CALL sp_set_prod(@access,@hash,x00,x01,"x02","x03","x04","x05","x06","x07","x08","x09",x10,"x11","x12","x13");',
        "PROD-2" => 'CALL sp_del_prod(@access,@hash,x00);', // ID
        "PROD-3" => 'CALL sp_set_reserv_prod(@access,@hash,x00,x01,x02,"x03",x04);', // ID_PROD, ID_PROJ,ID_USER,QTD,PAGO      
        "PROD-4" => 'CALL sp_inventario(@access,@hash,x00,"x01","x02")', // ID_PROD, QTD, OPERAÇÃO

        /* ADMIN */
        "ADM-0"  => 'CALL sp_set_setor(@access,@hash,x00,"x01");', // ID_SETOR, NOME
        "ADM-1"  => 'CALL sp_view_setor(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "ADM-2"  => 'CALL sp_set_cargo(@access,@hash,x00,"x01",x02,x03,"x04");', // ID_CARGO, CARGO, SALARIO, MENSAL, CBO
        "ADM-3"  => 'CALL sp_view_cargo(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "ADM-4"  => 'CALL sp_set_und(@access,@hash,x00,"x01","x02");', // ID,NOME, SIGLA
        "ADM-5"  => 'CALL sp_view_und(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "ADM-6"  => 'SELECT * FROM vw_feriado;',
        "ADM-7"  => 'CALL sp_set_feriado(@access,@hash,x00,"x01",x02,x03,x04)', // ID,Nome,Dia,Mes,Ano

        /* SYSTEMA */
        "SYS-0"  => 'CALL sp_set_usr_perm_perf(@access,@hash,x00,"x01");', // ID, NOME
        "SYS-1"  => 'CALL sp_view_usr_perm_perf(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE

        /* RELOGIO DE PONTO */
        "REL-0"  => 'CALL sp_view_relogio_ponto(@access,@hash,"x00","x01","x02",x03);', // DATA INICIO, DATA FINAL,FUNC,hide
        "REL-1"  => 'CALL sp_set_relogio_ponto(@access,@hash,"x00","x01",x02,x03);', // Entrada, Saída, Id_func, hide
        "REL-2"  => 'CALL sp_del_relogio_ponto(@access,@hash,"x00",x01);', // Entrada, Id_func

        /* ANÁLISE DE FROTA */
        "ANA-0" => 'CALL sp_view_analise_frota(@access,@hash,"x00","x01","x02","x03","x04","x05");', // FIELD,SIGNAL, VALUE, EXEC, DT_INI, DT_FIN
        "ANA-1" => 'CALL sp_set_analise_frota(@access, @hash, x00, x01,"x02","x03",x04,"x05","x06","x07","x08");', // ID,ID_EMP,DATA_ANALISE,NUM_CARRO,EXEC,FUNC,LOCAL,VALOR,OBS
        "ANA-2" => 'CALL sp_del_analise_frota(@access,@hash,x00);', // ID
        "ANA-3" => 'SELECT * FROM tb_tipo_serv ORDER BY id;',
        "ANA-4" => 'CALL sp_set_tipo_serv(@access,@hash,x00,"x01","x02");', // ID, Serviço, Valor




        /* SERVIÇO EXECUTADO */
        "SERV-0" => 'CALL sp_view_serv_exec(@access,@hash,"x00","x01","x02","x03","x04");', // FIELD,SIGNAL, VALUE, DT_INI, DT_FIN
        "SERV-1" => 'CALL sp_set_serv_exec(@access, @hash, x00, x01,"x02","x03","x04","x05","x06","x07","x08");', // ID,ID_EMP,DATA_ANALISE,NUM_CARRO,NF,FUNC,PEDIDO,VALOR,OBS
        "SERV-2" => 'CALL sp_del_serv_exec(@access,@hash,x00);', // ID

        /* TOOLS */
        "TOOL-0" => 'CALL sp_view_pcp(@access, @hash, "x00");', // data
        "TOOL-1" => 'CALL sp_set_pcp(@access, @hash, "x00",x01,"x02");', // data, id_setor, valor

        /* COTAÇÕES */
        "COT-0" => 'CALL sp_view_cotacao(@access,@hash,"x00","x01","x02","x03","x04");', // FIELD,SIGNAL, VALUE, DT_INI, DT_FIN
        "COT-1" => 'CALL sp_set_cotacao(@access,@hash,"x00",x01,"x02","x03","x04","x05","x06","x07","x08","x09");', //ID_PED,ID_EMP, DT_PED, DT_ENTREGA,VENDEDOR,COMPRADOR,NUM_PED,DESCONTO,COND_PGTO,OBS
        "COT-2" => 'CALL sp_view_item_cot(@access,@hash,x00);', // ID_PED
        "COT-3" => 'CALL sp_set_item_cot(@access,@hash,"x00",x01,x02,"x03","x04","x05");', // id,id_prod,id_ped,qtd,valor,und
        "COT-4" => 'CALL sp_del_cot(@access,@hash,x00);', // ID_PED
        "COT-5" => 'CALL sp_change_cot(@access,@hash,x00,"x01");', // ID_PED,STATUS
        "COM-6" => 'CALL sp_view_compra(@access,@hash,"x00","x01","x02","x03","x04");', // FIELD,SIGNAL, VALUE, DT_INI, DT_FIN
        "COM-7" => 'CALL sp_set_compra(@access,@hash,x00,"x01",x02,"x03","x04","x05","x06");', // ID, NF, ID_EMP, DATA_ENT, RESP, STATUS, OBS
        "COM-8" => 'CALL sp_view_item_compra(@access,@hash,x00);', //ID_COMPRA
        "COT-9" => 'CALL sp_set_item_compra(@access,@hash,x00,x01,x02,"x03","x04");', // id,id_prod,id_comp,qtd,valor
        "COT-10"=> 'CALL sp_del_compra(@access,@hash,x00);', // ID_PED
        "COT-11"=> 'CALL sp_fecha_compra(@access,@hash,x00);', // ID_PED

        /* FINANCEIRO */

        "FIN-0" => 'CALL sp_view_imposto(@access,@hash,"x00");', // ID_IMPOSTOS ex: 1,2,3
        "FIN-1" => 'CALL sp_view_icms(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "FIN-2" => 'CALL sp_edtICMS(@access,@hash,x00,"x01");', // ID, VALOR
        "FIN-3" => 'CALL sp_view_pedido(@access,@hash,"x00","x01","x02","x03","x04");',
        "FIN-4" => 'CALL sp_view_item_ped(@access,@hash,x00);', // ID_PED
        "FIN-5" => 'CALL sp_view_contas_a_pagar(@access,@hash,"x00","x01","x02","x03","x04");', // FIELD,SIGNAL, VALUE,dt_ini, dt_fin
        "FIN-6" => 'CALL sp_set_contas_a_pagar(@access,@hash,x00,x01,"x02","x03","x04","x05","x06","x07","x08","x09");', // id,id_cli,nome,beneficiario,venc,valor,codigo_pgto,tipo,centro_custo,pago
        "FIN-7" => 'CALL sp_check_pagamento(@access,@hash,x00,x01,"x02","x03","x04");', // ID,pago,pago_dia,tipo,obs
        "FIN-8" => 'CALL sp_view_pix(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "FIN-9" => 'CALL sp_set_pix(@access,@hash,x00,"x01","x02","x03","x04",x05);', // id,nome,cidade,chave,org_ref,id_ref
        "FIN-10" => 'CALL sp_view_a_receber(@access,@hash,"x00","x01","x02","x03","x04");', // FIELD,SIGNAL, VALUE,dt_ini, dt_fin
        "FIN-11" => 'CALL sp_set_a_receber(@access,@hash,x00,x01,"x02","x03","x04","x05","x06","x07",x08);', // id,id_cli,nome,venc,valor,tipo,nf,obs,pgto
        "FIN-12" => 'CALL sp_view_analytics(@access,@hash,"x00","x01","x02","x03");', // ENTRADA,SAIDA,DT_INI,DT_FIN

        /* SEGURANÇA */

        "SEG-0" => 'CALL sp_viewEPI(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "SEG-1" => 'CALL sp_setEPI(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08");', // ID,descricao,marca,estq,estq_min,und,cod_bar,num_ca,local
        "SEG-2" => 'CALL sp_set_epi_func(@access,@hash,x00,x01,"x02","x03");', //id_func, id_epi, qtd, data

        /* PROCESSO */
        "PRC-0" => 'CALL sp_view_proc(@access,@hash,"x00");', // NOME
        "PRC-1" => 'CALL sp_set_proc(@access,@hash,x00,"x01");', // ID,NOME
        "PRC-2" => 'CALL sp_view_etapa_proc(@access,@hash,x00);', // FIELD,SIGNAL,ID_PROCESSO
        "PRC-3" => 'CALL sp_set_etapa_proc(@access,@hash,x00,x01,x02,"x03");', // ID,ID_PROCESSO,ID_SETOR,DESCRIÇÃO
        "PRC-4" => 'CALL sp_proc_detail(@access,@hash,x00);', // ID_PROC
        "PRC-5" => 'CALL sp_up_etapa_proc(@access,@hash,x00);', // ID_ETAPA

        /* ORDEM DE SERVIÇO */
        "OS-0" => 'CALL sp_view_os_proc(@access,@hash,"x00","x01","x02","x03","x04");', //  FIELD,SIGNAL, VALUE,DT_INI,DT_FIN
        "OS-1" => 'CALL sp_set_os(@access,@hash,x00,x01,x02,"x03","x04");', // ID,ID_PROC,ID_EMP,DT_ENTREGA,OBS
        "OS-2" => 'CALL sp_view_os(@access,@hash,"x00");', // SCANNER
        "OS-3" => 'CALL sp_view_apt("x00");', // SCANNER
        "OS-4" => 'CALL sp_set_apt(@access,@hash,"x00",x01);', // SCANNER, ID_FUNC
        "OS-5" => 'CALL sp_close_os(@access,@hash,x00,x01);', // ID_OS, STATUS(0 = ENCERRADA, 1 = ABERTA)

        /* SANFONA DE ÔNIBUS */
        "SAN-0" => 'CALL sp_view_sanf_onibus(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "SAN-1"=> 'CALL sp_sanf_onibus(@access,@hash,x00,"x01","x02","x03","x04",x05,x06,x07,"x08","x09","x10","x11","x12","x13","x14","x15","x16","x17","x18","x19","x20","x21","x22");', // id,nome,marca,modelo,chassi,ano,qtd_barras,qtd_dob_teto,qtd_dob_chao,alt,larg,alt_teto,alt_lateral,larg_teto,alt_sanf,alt_sanf_cost,larg_sanf,topo_sanf,base_sanf,larg_corredor,larg_chao,dist_carro,obs

        /* BOLETOS */
        "BOL-0" => 'CALL sp_view_boletos(@access,@hash,"x00","x01");', // DT_INI, DT_FIN
        "BOL-1" => 'CALL sp_set_boletos(@access,@hash,x00,"x01","x02","x03","x04","x05");', // cod_pgto,cliente,valor,venc,pgto,nf


                

    );


?>