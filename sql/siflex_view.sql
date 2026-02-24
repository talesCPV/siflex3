DROP VIEW vw_analise_frota;
 CREATE VIEW vw_analise_frota AS
    SELECT 
        `ANA`.`id` AS `id`,
        `ANA`.`id_emp` AS `id_emp`,
        `ANA`.`data_analise` AS `data_analise`,
        `ANA`.`num_carro` AS `num_carro`,
        `ANA`.`exec` AS `exec`,
        `ANA`.`func` AS `func`,
        `ANA`.`local` AS `local`,
        `ANA`.`valor` AS `valor`,
        `ANA`.`obs` AS `obs`,
        `ANA`.`serv_exec` AS `serv_exec`,
        `EMP`.`fantasia` AS `empresa`,
        EMP.cnpj,
        EMP.endereco,
        EMP.num,
        EMP.cidade,
        EMP.estado
    FROM
        (`tb_analise_frota` `ANA`
        JOIN `tb_empresa` `EMP` ON ((`ANA`.`id_emp` = `EMP`.`id`)));
        
SELECT * FROM vw_analise_frota;

DROP VIEW vw_serv_exec;
 CREATE VIEW vw_serv_exec AS
    SELECT 
        `SERV`.`id` AS `id`,
        `SERV`.`id_emp` AS `id_emp`,
        `SERV`.`data_exec` AS `data_exec`,
        `SERV`.`num_carro` AS `num_carro`,
        `SERV`.`nf` AS `nf`,
        `SERV`.`pedido` AS `pedido`,
        `SERV`.`func` AS `func`,
        `SERV`.`obs` AS `obs`,
        `SERV`.`valor` AS `valor`,
        `EMP`.`fantasia` AS `empresa`,
        COALESCE(EMP.nome,"") AS razao_social,
        EMP.bairro,
        EMP.cep,
        EMP.email,
        EMP.cnpj,
        EMP.endereco,
        EMP.num,
        EMP.cidade,
        EMP.estado,
        COALESCE(EMP.nome,"") AS RazSocTom,
        COALESCE(EMP.endereco,"") AS LogTom,
        COALESCE(EMP.bairro,"") AS BairroTom,
        COALESCE(EMP.cep,"") AS CepTom,
        COALESCE(EMP.comp,"") AS ComplEndTom,
        COALESCE(EMP.im,"") AS IMTom,
        COALESCE(EMP.email,"") AS EMail_1,
        COALESCE(EMP.tel,"") AS Telefone,
        COALESCE(EMP.cnpj,"") AS CpfCnpjTom,
        COALESCE(EMP.num,"") AS NumEndTom,
        COALESCE(EMP.cidade,"") AS MunTom,
        COALESCE(EMP.estado,"") AS SiglaUFTom
    FROM
        (`tb_serv_exec` `SERV`
        JOIN `tb_empresa` `EMP` ON ((`SERV`.`id_emp` = `EMP`.`id`)));
        
SELECT * FROM vw_serv_exec;

DROP VIEW vw_func;
 CREATE VIEW vw_func AS
	SELECT FUNC.*, COALESCE(CAR.cargo,"") AS cargo, IF(CAR.tipo='HORA',1,0) AS horista,
    IF(FUNC.status="ATIVO",1,0) AS ativo, COALESCE(CAR.cbo,"") AS cbo,
    (SELECT GROUP_CONCAT(id_setor SEPARATOR ",") FROM tb_func_setor WHERE id_func=FUNC.id) AS id_setores,
    (SELECT GROUP_CONCAT(SETOR.nome SEPARATOR ",") FROM tb_func_setor AS FUNSET INNER JOIN tb_setores AS SETOR ON SETOR.id=FUNSET.id_setor WHERE FUNSET.id_func=FUNC.id) AS setores
    FROM tb_funcionario AS FUNC    
	INNER JOIN tb_cargos AS CAR
	ON FUNC.id_cargo = CAR.id
    ORDER BY FUNC.nome;        
        
SELECT * FROM vw_func;
SELECT * FROM tb_func_setor;
SELECT * FROM tb_setores;

DROP VIEW vw_ferias;
-- CREATE VIEW vw_ferias AS
	SELECT FUNC.*, FER.*,
    IF(FUNC.status="ATIVO",1,0) AS ativo
    FROM tb_funcionario AS FUNC    
	LEFT JOIN tb_ferias AS FER	
	ON FUNC.id_cargo = FER.id_func
    ORDER BY FUNC.nome;

DROP VIEW vw_setor;
 CREATE VIEW vw_setor AS
	SELECT FUNC.id AS id_func, COALESCE(SETOR.nome,"") AS setor, COALESCE(SETOR.id,0) AS id_setor
	FROM tb_funcionario AS FUNC
	LEFT JOIN tb_setores AS SETOR
	ON FUNC.id_setor = SETOR.id;
    
SELECT * FROM vw_setor;    

DROP VIEW vw_feriado;
 CREATE VIEW vw_feriado AS
SELECT *, CONCAT(LPAD(dia,2,0),'/',LPAD(mes,2,0)) AS data
FROM tb_feriados 
ORDER BY mes,dia;

SELECT * FROM vw_feriado; 

DROP VIEW vw_cot_itens;
 CREATE VIEW vw_cot_itens AS
	SELECT ITN.id_ped, GROUP_CONCAT(PRD.cod SEPARATOR ',') AS id_prod
	FROM tb_item_ped AS ITN
	INNER JOIN tb_produto AS PRD
	ON ITN.id_prod = PRD.id
	GROUP BY ITN.id_ped;

SELECT * FROM vw_cot_itens; 

DROP VIEW vw_cot_preco;
 CREATE VIEW vw_cot_preco AS
	SELECT PED.*, TRUNCATE(IFNULL(SUM(ITN.preco * ITN.qtd),0),2) AS VALOR
	FROM tb_pedido AS PED
	LEFT JOIN tb_item_ped AS ITN
	ON ITN.id_ped = PED.id
	GROUP BY PED.id ORDER BY data_ped DESC;

SELECT * FROM vw_cot_preco ORDER BY data_ped DESC; 

-- DROP VIEW vw_cotacoes;
-- CREATE VIEW vw_cotacoes AS
	    SELECT 
        `COT`.`id` AS `id`,
        `COT`.`id_emp` AS `id_emp`,
        `COT`.`data_ped` AS `data_ped`,
        `COT`.`data_ent` AS `data_ent`,
        `COT`.`resp` AS `resp`,
        `COT`.`comp` AS `comp`,
        `COT`.`num_ped` AS `num_ped`,
        `COT`.`status` AS `status`,
        `COT`.`desconto` AS `desconto`,
        `COT`.`cond_pgto` AS `cond_pgto`,
        `COT`.`obs` AS `obs`,
        `COT`.`origem` AS `origem`,
        `COT`.`path` AS `path`,
        `COT`.`VALOR` AS `VALOR`,
        COALESCE(`EMP`.`fantasia`, '') AS `EMPRESA`,
        COALESCE(`EMP`.`cnpj`, '') AS `CNPJ`,
        COALESCE(`EMP`.`ie`, '') AS `IE`,
        COALESCE(`EMP`.`endereco`, '') AS `END`,
        COALESCE(`EMP`.`estado`, '') AS `UF`,
        COALESCE(`EMP`.`cep`, '') AS `CEP`,
        COALESCE(`EMP`.`bairro`, '') AS `BAIRRO`,
        COALESCE(`EMP`.`cidade`, '') AS `CIDADE`,
        COALESCE(`EMP`.`num`, '') AS `NUM`,
        COALESCE(`EMP`.`tel`, '') AS `TEL`
    FROM
        (`vw_cot_preco` `COT`
        LEFT JOIN `tb_empresa` `EMP` ON ((`COT`.`id_emp` = `EMP`.`id`)));

SELECT * FROM vw_cotacoes ORDER BY data_ped DESC; 

DROP VIEW vw_ped_icms;
 CREATE VIEW vw_ped_icms AS
	SELECT PED.id AS id_ped, ICMS.valor, ICMS.sigla 
	FROM tb_pedido AS PED
	INNER JOIN tb_empresa AS EMP
	INNER JOIN tb_icms AS ICMS
	ON EMP.id = PED.id_emp
	AND ICMS.sigla = EMP.estado;

SELECT * FROM vw_ped_icms;

DROP VIEW vw_item_cot;
 CREATE VIEW vw_item_cot AS
	SELECT ITN.*, ROUND((ITN.qtd*ITN.preco), 2) AS TOTAL, PRD.descricao, PRD.unidade, PRD.CFOP, PRD.ncm, PRD.cod AS cod_prod, 
    ICMS.valor AS ICMS, ROUND((ITN.qtd*ITN.preco) * (ICMS.valor/100), 2) AS TOT_ICMS
		FROM tb_item_ped AS ITN
		INNER JOIN tb_produto AS PRD
		INNER JOIN vw_ped_icms AS ICMS
		ON ITN.id_prod = PRD.id
		AND ITN.id_ped = ICMS.id_ped;

SELECT * FROM vw_item_cot;


-- 	DROP VIEW vw_date_range;
 	CREATE VIEW vw_date_range AS
SELECT date, WEEKOFYEAR(date) AS semana, DAYOFWEEK(date) AS dia_semana FROM 
(SELECT ADDDATE('2020-01-01',t4.i*10000 + t3.i*1000 + t2.i*100 + t1.i*10 + t0.i) date FROM
 (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t0,
 (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
 (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
 (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
 (SELECT 0 i UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4) v;
 
 SELECT * FROM vw_date_range WHERE date BETWEEN '2024-02-01' AND '2024-02-29';
 
 SELECT CURDATE();
 SELECT SUBSTRING(CURDATE(),3,2);
 SELECT SUBSTRING(CURDATE(),6,2);
 SELECT SUBSTRING(CURDATE(),9,2);
 
 SELECT CONCAT(SUBSTRING(CURDATE(),3,2),SUBSTRING(CURDATE(),6,2),SUBSTRING(CURDATE(),9,2),"-",(SELECT (COUNT(*)+1) AS new_ped FROM tb_pedido WHERE data_ped = CURDATE()));
 
 DROP VIEW vw_serv_exec_nfs;
-- CREATE VIEW vw_serv_exec_nfs AS
    SELECT 
        `SERV`.`id` AS `id`,
        `SERV`.`id_emp` AS `id_emp`,
        `SERV`.`data_exec` AS `data_exec`,
        `SERV`.`num_carro` AS `num_carro`,
        `SERV`.`nf` AS `nf`,
        `SERV`.`pedido` AS `pedido`,
        `SERV`.`func` AS `func`,
        `SERV`.`obs` AS `obs`,
        `SERV`.`valor` AS `valor`,
        `EMP`.`fantasia` AS `empresa`,
        EMP.nome AS RazSocTom,
        EMP.endereco AS LogTom,
        EMP.bairro AS BairroTom,
        EMP.cep AS CepTom,
        EMP.comp AS ComplEndTom,
        EMP.im AS IMTom,
        EMP.email AS EMail_1,
        EMP.tel AS Telefone,
        EMP.cnpj AS CpfCnpjTom,
        EMP.num AS NumEndTom,
        EMP.cidade AS MunTom,
        EMP.estado AS SiglaUFTom
    FROM
        (`tb_serv_exec` `SERV`
        JOIN `tb_empresa` `EMP` ON ((`SERV`.`id_emp` = `EMP`.`id`)));
        
SELECT * FROM vw_serv_exec;
SELECT * FROM vw_prod;
 
 
 	DROP VIEW IF EXISTS vw_os;
 	CREATE VIEW vw_os AS
   SELECT OS.*, PRO.nome AS processo, EMP.fantasia AS cliente,
	(SELECT CONCAT(ROUND((SELECT COUNT(*) FROM tb_apontamento WHERE id_os=OS.id)/
	(SELECT COUNT(*) FROM vw_apontamento WHERE id_os=OS.id) * 100,0),"%"))AS ok,
    COALESCE((SELECT setor FROM vw_apontamento WHERE id_os=OS.id AND ok=0 LIMIT 1),"CONCLUIDA") AS setor
	 FROM tb_os AS OS
	 INNER JOIN tb_processo AS PRO
	 INNER JOIN tb_empresa AS EMP
	 ON OS.id_proc = PRO.id
	 AND OS.id_emp = EMP.id;
 
 SELECT * FROM vw_os;
 /**/
 

 
 SELECT CONCAT(id_etapa,"|",id_setor,"|",setor)  AS setor
 FROM vw_apontamento WHERE id_os=3 AND ok=0 LIMIT 1;
 
 /**/
   DROP VIEW IF EXISTS vw_etapa_setor;
 CREATE VIEW vw_etapa_setor AS
 SELECT ETP.*, STR.nome AS setor
 FROM tb_etapa_proc AS ETP
 INNER JOIN  tb_setores AS STR
 ON ETP.id_setor = STR.id
 ORDER BY ETP.id_processo,ETP.id;
 
 SELECT * FROM vw_etapa_setor;
 
--  DROP VIEW IF EXISTS vw_os_proc;
 CREATE VIEW vw_os_proc AS
 SELECT OS.id AS id_os, PROC.id_processo, PROC.id AS id_etapa, PROC.id_setor, PROC.descricao, PROC.setor 
 FROM tb_os AS OS
 INNER JOIN vw_etapa_setor AS PROC
 ON OS.id_proc = PROC.id_processo
 ORDER BY PROC.id;
 
  SELECT * FROM vw_os_proc;
 
-- DROP VIEW IF EXISTS vw_apontamento;
-- CREATE VIEW vw_apontamento AS
 SELECT OS.*, APT.id_func, COALESCE(APT.exec,0) AS ok, COALESCE(APT.obs,"") AS obs,
 (@row_number := @row_number + 1) AS row_num  

 FROM vw_os_proc AS OS
 LEFT JOIN tb_apontamento AS APT
 ON APT.id_os = OS.id_os  
 AND APT.id_etapa = OS.id_etapa,
 (SELECT @row_number := 0) AS r
 ORDER BY OS.id_etapa;
 
 SELECT * FROM vw_apontamento;
 
 SELECT COUNT(*) FROM vw_apontamento WHERE id_os=2 AND ok=0;
 
-- DROP VIEW IF EXISTS vw_contas_a_pagar;
 CREATE VIEW vw_contas_a_pagar AS
 SELECT CPG.*, IFNULL(EMP.fantasia,"FORNECEDOR SEM REGISTRO") AS fornecedor
 FROM tb_contas_a_pagar AS CPG
 LEFT JOIN tb_empresa AS EMP
 ON CPG.id_cli = EMP.id;
 
 SELECT * FROM vw_contas_a_pagar;
 
 
 -- DROP VIEW IF EXISTS vw_a_receber;
 CREATE VIEW vw_a_receber AS
 SELECT ARB.*, IFNULL(EMP.fantasia,"FORNECEDOR SEM REGISTRO") AS cliente
	 FROM tb_a_receber AS ARB
	 LEFT JOIN tb_empresa AS EMP
	 ON ARB.id_cli = EMP.id;
 
 SELECT * FROM vw_a_receber;
 
 
-- DROP VIEW IF EXISTS vw_compras;
 CREATE VIEW vw_compras AS
	SELECT ENT.*, EMP.fantasia, EMP.id AS emp_id, EMP.endereco,
		EMP.num, EMP.cidade, EMP.estado, EMP.bairro,
		(SELECT GROUP_CONCAT(id_prod SEPARATOR ",") FROM tb_item_compra WHERE id_ent=ENT.id) AS id_prod,
		(SELECT GROUP_CONCAT(TRIM(PROD.descricao) SEPARATOR ",") FROM tb_produto AS PROD INNER JOIN tb_item_compra AS ITEM ON ITEM.id_prod=PROD.id WHERE ITEM.id_ent=ENT.id) AS prod,
        (SELECT ROUND(SUM(qtd*preco),2) FROM tb_item_compra WHERE id_ent=ENT.id) AS total
		FROM tb_entrada AS ENT
		INNER JOIN tb_empresa AS EMP 
		ON ENT.id_emp = EMP.id
		ORDER BY ENT.data_ent DESC;
 
 SELECT * FROM vw_compras;
 
  DROP VIEW IF EXISTS vw_hora_extra;
 CREATE VIEW vw_hora_extra AS
 SELECT HE.*,FUNC.nome
	FROM tb_hora_extra AS HE
	INNER JOIN tb_funcionario AS FUNC
	ON HE.id_func = FUNC.id
    ORDER BY nome,entrada;
 
  SELECT * FROM vw_hora_extra;
  
  
DROP VIEW IF EXISTS vw_analytics;
 CREATE VIEW vw_analytics AS
	SELECT id_cli,nome,beneficiario AS credor,"FLEXIBUS SANFONADOS LTDA." AS devedor,venc,(valor * -1) AS valor,cod_pgto,pgto,pgto_dia,tipo, "SAÍDA" AS modalidade, centro_custo
	FROM vw_contas_a_pagar
	UNION ALL
	SELECT RCB.id_cli,RCB.nome,RCB.beneficiario as credor,COALESCE(EMP.fantasia,"") AS devedor,RCB.venc,RCB.valor,RCB.cod_pgto,RCB.pgto,RCB.pgto_dia,RCB.tipo, "ENTRADA" AS modalidade, "" AS centro_custo
	FROM vw_a_receber AS RCB
    LEFT JOIN tb_empresa AS EMP
    ON RCB.id_cli = EMP.id
	ORDER BY venc;
    
SELECT * FROM vw_analytics;


DROP VIEW IF EXISTS vw_posts;
 CREATE VIEW vw_posts AS
	SELECT PST.*, USR.email,
    (SELECT COUNT(*) FROM tb_post_message WHERE id_post = PST.id) AS messages
	FROM tb_post AS PST
	INNER JOIN tb_user AS USR
	ON PST.id_user = USR.id
	ORDER BY data_hora ASC ;
    
    SELECT * FROM vw_posts;