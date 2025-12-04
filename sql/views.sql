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
        EMP.nome AS razao_social,
        EMP.bairro,
        EMP.cep,
        EMP.email,
        EMP.cnpj,
        EMP.endereco,
        EMP.num,
        EMP.cidade,
        EMP.estado
    FROM
        (`tb_serv_exec` `SERV`
        JOIN `tb_empresa` `EMP` ON ((`SERV`.`id_emp` = `EMP`.`id`)));
        
SELECT * FROM vw_serv_exec;

DROP VIEW vw_func;
 CREATE VIEW vw_func AS
	SELECT FUNC.*,  SETOR.setor, COALESCE(CAR.cargo,"") AS cargo, IF(CAR.tipo='HORA',1,0) AS horista,
    IF(FUNC.status="ATIVO",1,0) AS ativo, COALESCE(CAR.cbo,"") AS cbo
    FROM tb_funcionario AS FUNC    
	INNER JOIN tb_cargos AS CAR
	INNER JOIN vw_setor AS SETOR
	ON FUNC.id_cargo = CAR.id
	AND FUNC.id = SETOR.id_func
    ORDER BY FUNC.nome;
        
SELECT * FROM vw_func;

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
	GROUP BY PED.id;

SELECT * FROM vw_cot_preco; 

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

SELECT * FROM vw_cotacoes; 

 	DROP VIEW vw_pedidos;
 	CREATE VIEW vw_pedidos AS 
    SELECT 
        `COT`.`id` AS `id`,
        `COT`.`id_emp` AS `id_emp`,
        `COT`.`data_ped` AS `data_ped`,
        `COT`.`num_ped` AS `num_ped`,
        `COT`.`status` AS `status`,
        `COT`.`VALOR` AS `VALOR`,
        COALESCE(`EMP`.`nome`, '') AS `xNome`,
        COALESCE(`EMP`.`cnpj`, '') AS `CNPJ`,
        COALESCE(`EMP`.`ie`, '') AS `IE`,
		COALESCE(`EMP`.`im`, '') AS `IM`,
		COALESCE(`EMP`.`email`, '') AS `email`,
        COALESCE(`EMP`.`endereco`, '') AS `xLgr`,
        COALESCE(`EMP`.`num`, '') AS `nro`,
        COALESCE(`EMP`.`estado`, '') AS `UF`,
        COALESCE(`EMP`.`cep`, '') AS `CEP`,
        COALESCE(`EMP`.`bairro`, '') AS `xBairro`,
        COALESCE(`EMP`.`comp`, '') AS `XCpl`,
		COALESCE(`EMP`.`cidade`, '') AS `xMun`,
        COALESCE(`EMP`.`tel`, '') AS `fone`
    FROM
        (`vw_cot_preco` `COT`
        LEFT JOIN `tb_empresa` `EMP` ON ((`COT`.`id_emp` = `EMP`.`id`)));
        
SELECT * FROM vw_pedidos;   

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

DROP VIEW vw_item_ped;
 CREATE VIEW vw_item_ped AS
	SELECT PRD.cod AS cProd,
    PRD.descricao AS xProd,
    PRD.ncm AS NCM,
    PRD.CFOP AS CFOP,
    PRD.unidade AS uCom,
    ROUND(ITN.qtd,4) AS qCom,
	ROUND(ITN.preco,10) AS vUnCom,
	ROUND((ITN.qtd*ITN.preco),2) AS vProd,
    PRD.unidade AS uTrib,
	ITN.qtd AS qTrib,
    ROUND(ITN.preco,10) AS vUnTrib,    
	ROUND((ITN.qtd*ITN.preco),2) AS vBC,
    ROUND(ICMS.valor,4) AS pICMS,
    ROUND((ITN.qtd*ITN.preco) * (ICMS.valor/100), 2) AS vICMS
		FROM tb_item_ped AS ITN
		INNER JOIN tb_produto AS PRD
		INNER JOIN vw_ped_icms AS ICMS
		ON ITN.id_prod = PRD.id
		AND ITN.id_ped = ICMS.id_ped;

SELECT * FROM vw_item_ped;


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
 