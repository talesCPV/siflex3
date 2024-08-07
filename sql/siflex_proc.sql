/* FUNCTIONS */

 DROP PROCEDURE sp_getHash;
DELIMITER $$
	CREATE PROCEDURE sp_getHash(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SELECT SHA2(CONCAT(Iemail, Isenha), 256) AS HASH;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_allow;
DELIMITER $$
	CREATE PROCEDURE sp_allow(
		IN Iallow varchar(80),
		IN Ihash varchar(64)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @quer =CONCAT('SET @allow = (SELECT ',@access,' IN ',Iallow,');');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
	END $$
DELIMITER ;

/* LOGIN */

 DROP PROCEDURE sp_login;
DELIMITER $$
	CREATE PROCEDURE sp_login(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @hash = (SELECT SHA2(CONCAT(Iemail, Isenha), 256));
		SELECT *, SUBSTRING_INDEX(email,"@",1) AS nick FROM tb_user WHERE hash=@hash;
	END $$
DELIMITER ;

/* USER */

 DROP PROCEDURE sp_setUser;
DELIMITER $$
	CREATE PROCEDURE sp_setUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iemail varchar(80),
		IN Isenha varchar(30),
        IN Iaccess int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iemail="")THEN
				DELETE FROM tb_mail WHERE de=Iid OR para=Iid;
				DELETE FROM tb_user WHERE id=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_user (email,hash,access)VALUES(Iemail,SHA2(CONCAT(Iemail, Isenha), 256),Iaccess);            
                ELSE
					IF(Isenha="")THEN
						UPDATE tb_user SET email=Iemail, access=Iaccess WHERE id=Iid;
                    ELSE
						UPDATE tb_user SET email=Iemail, hash=SHA2(CONCAT(Iemail, Isenha), 256), access=Iaccess WHERE id=Iid;
                    END IF;
                END IF;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_viewUser;
DELIMITER $$
	CREATE PROCEDURE sp_viewUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT id,email,id_func,access, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil FROM tb_user AS USR WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS id_func, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_updatePass;
DELIMITER $$
	CREATE PROCEDURE sp_updatePass(	
		IN Ihash varchar(64),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @call_id = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@call_id > 0)THEN
			UPDATE tb_user SET hash = SHA2(CONCAT(email, Isenha), 256) WHERE id=@call_id;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_check_usr_mail;
DELIMITER $$
	CREATE PROCEDURE sp_check_usr_mail(
		IN Ihash varchar(64)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call>0)THEN
			SELECT COUNT(*) AS new_mail FROM tb_mail WHERE para = @id_call AND nao_lida=1;
		ELSE
			SELECT 0 AS new_mail ;
        END IF;
	END $$
DELIMITER ;

	/* PERMISSÂO */

 DROP PROCEDURE sp_set_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_set_usr_perm_perf(	
		IN Iaccess varchar(50),
		IN Ihash varchar(64),
        In Iid int(11),
		IN Inome varchar(30)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@access IN(0))THEN
			IF(Iid = 0 AND Inome != "")THEN
				INSERT INTO tb_usr_perm_perfil (nome) VALUES (Inome);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_usr_perm_perfil WHERE id=Iid;
				ELSE
					UPDATE tb_usr_perm_perfil SET nome = Inome WHERE id=Iid;
                END IF;
            END IF;			
			SELECT * FROM tb_usr_perm_perfil;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_view_usr_perm_perf(	
		IN Iaccess varchar(50),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@access IN (0))THEN
			SET @quer = CONCAT('SELECT * FROM tb_usr_perm_perfil WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

/* CALENDAR */

 DROP PROCEDURE sp_view_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_view_calendar(	
		IN Ihash varchar(64),
		IN IdataIni date,
		IN IdataFin date
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM tb_calendario WHERE id_user=@id_call AND data_agd>=IdataIni AND data_agd<=IdataFin;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_set_calendar(	
		IN Ihash varchar(64),
		IN Idata date,
		IN Iobs varchar(255)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			SET @exist = (SELECT COUNT(*) FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata);
			IF(@exist AND Iobs = "")THEN
				DELETE FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata; 
			ELSE
				INSERT INTO tb_calendario (id_user, data_agd, obs) VALUES(@id_call, Idata, Iobs)
                ON DUPLICATE KEY UPDATE obs=Iobs;
			END IF;
        END IF;
	END $$
DELIMITER ;

/* MAIL */

 DROP PROCEDURE sp_set_mail;
DELIMITER $$
	CREATE PROCEDURE sp_set_mail(	
		IN Ihash varchar(64),
        IN Iid_to int(11),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			INSERT INTO tb_mail (de,para,txt) VALUES (@id_call,Iid_to,Imessage);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_mail;
DELIMITER $$
	CREATE PROCEDURE sp_view_mail(	
		IN Ihash varchar(64),
        IN Isend boolean
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Isend)THEN
				SELECT MAIL.*, USR.email AS mail_from
					FROM tb_mail AS MAIL 
					INNER JOIN tb_user AS USR
					ON MAIL.de = USR.id AND para = @id_call;            
            ELSE
				SELECT MAIL.*, USR.email AS mail_to
					FROM tb_mail AS MAIL 
					INNER JOIN tb_user AS USR
					ON MAIL.para = USR.id AND de = @id_call;            
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_del_mail;
DELIMITER $$
	CREATE PROCEDURE sp_del_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			DELETE FROM tb_mail WHERE data = Idata AND de = Iid_from AND para = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_mark_mail;
DELIMITER $$
	CREATE PROCEDURE sp_mark_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			UPDATE tb_mail SET nao_lida=0 WHERE data = Idata AND de = Iid_from AND para = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_all_mail_adress;
DELIMITER $$
	CREATE PROCEDURE sp_all_mail_adress(	
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT id,email FROM tb_user WHERE id != @id_call ORDER BY email ASC;
	END $$
DELIMITER ; 

/* ADMIN */
 DROP PROCEDURE sp_set_setor;
DELIMITER $$
	CREATE PROCEDURE sp_set_setor(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid_setor int(11),
		IN Inome varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_setor = 0)THEN
				INSERT INTO tb_setores (nome) VALUES (Inome);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_setores WHERE id=Iid_setor;
				ELSE
					UPDATE tb_setores SET nome = Inome WHERE id=Iid_setor;
                END IF;
            END IF;			
			SELECT * FROM tb_setores;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_setor;
DELIMITER $$
	CREATE PROCEDURE sp_view_setor(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_setores WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_cargo;
DELIMITER $$
	CREATE PROCEDURE sp_set_cargo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid_cargo int(11),
		IN Icargo varchar(30),
        IN Isalario double,
        IN Imensal boolean,
        IN Icbo varchar(8)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_cargo = 0)THEN
				INSERT INTO tb_cargos (cargo,salario,mensal,cbo) VALUES (Icargo, Isalario, Imensal, Icbo);
            ELSE
				IF(Icargo = "")THEN
					DELETE FROM tb_cargos WHERE id=Iid_cargo;
				ELSE
					UPDATE tb_cargos SET cargo = Icargo, salario=Isalario, mensal=Imensal, cbo=Icbo WHERE id=Iid_cargo;
                END IF;
            END IF;			
			SELECT * FROM tb_cargos;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_cargo;
DELIMITER $$
	CREATE PROCEDURE sp_view_cargo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer = CONCAT('SELECT * FROM tb_cargos WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS cargo, 0.00 AS salario, 0 AS mensal, NULL as cbo;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_und;
DELIMITER $$
	CREATE PROCEDURE sp_set_und(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid_und int(11),
		IN Inome varchar(30),
		IN Isigla varchar(8)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_und = 0)THEN
				INSERT INTO tb_und (nome,sigla) VALUES (Inome,Isigla);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_und WHERE id=Iid_und;
				ELSE
					UPDATE tb_und SET nome=Inome, sigla=Isigla WHERE id=Iid_und;
				END IF;
            END IF;			
			SELECT * FROM tb_und;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_und;
DELIMITER $$
	CREATE PROCEDURE sp_view_und(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_und WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_vale;
DELIMITER $$
	CREATE PROCEDURE sp_view_vale(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_func int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_vales WHERE id_func=Iid_func ORDER BY data DESC;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_vale;
 DELIMITER $$
	CREATE PROCEDURE sp_set_vale(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
		IN Iid_func int(11),
        IN Ivalor double,
        IN Iquitado boolean,
		IN Iobs varchar(200),
        IN Idata datetime
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid > 0) THEN
				IF(Ivalor <= 0)THEN
					DELETE FROM tb_vale WHERE id=Iid;
                    DELETE FROM tb_vale_pgto WHERE id_vale=Iid;
                ELSE
					UPDATE tb_vale SET quitado=Iquitado, valor=Ivalor, obs=Iobs, data=Idata WHERE id=Iid;
                END IF;
			ELSE
				INSERT INTO tb_vale (id_func,valor,obs,data) VALUES (Iid_func,Ivalor,Iobs,Idata);
			END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_vale_pgto;
DELIMITER $$
	CREATE PROCEDURE sp_set_vale_pgto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
        IN Ivalor double,
        IN Idata datetime,
		IN Iobs varchar(200)        
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Ivalor <= 0)THEN
				DELETE FROM tb_vale_pgto WHERE id=Iid;
            ELSE            
				INSERT INTO tb_vale_pgto (id_vale,valor,obs,data) VALUES (Iid,Ivalor,Iobs,Idata);
            END IF;
        END IF;
		SELECT * FROM tb_vale_pgto WHERE id_vale=Iid;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_vale_pgto;
DELIMITER $$
	CREATE PROCEDURE sp_view_vale_pgto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_vale int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_vale_pgto WHERE id_vale=Iid_vale ORDER BY data;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_feriado;
DELIMITER $$
	CREATE PROCEDURE sp_set_feriado(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid int(11),
		IN Inome varchar(40),
		IN Idia int(11),
		IN Imes int(11),
		IN Iano int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid = 0)THEN
				INSERT INTO tb_feriados (nome,dia,mes,ano) VALUES (Inome,Idia,Imes,Iano);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_feriados WHERE id=Iid;
				ELSE
					UPDATE tb_feriados SET nome=Inome, dia=Idia, mes=Imes, ano=Iano WHERE id=Iid;
				END IF;
            END IF;			
			SELECT * FROM tb_feriados;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_imposto;
DELIMITER $$
	CREATE PROCEDURE sp_view_imposto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_imp varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT IMP.nome, ALQ.* 
						FROM tb_imposto AS IMP
						INNER JOIN tb_aliquota AS ALQ
						ON ALQ.id_imp = IMP.id
						AND IMP.id IN (',Iid_imp,')
						ORDER BY ALQ.ini_range ASC;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
DELIMITER ;

/* FUNCIONÁRIO */
-- id,nome,nasc,rg,cpf,pis,end,num,cidade,bairro,uf,cep,data_adm,data_dem,id_cargo,id_setor,tel,cel,ativo,obs
 DROP PROCEDURE sp_set_func;
DELIMITER $$
	CREATE PROCEDURE sp_set_func(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(30),
		IN Inasc date,
		IN Irg varchar(15),
		IN Icpf varchar(15),
		IN Ipis varchar(15),
		IN Iend varchar(60),
		IN Inum varchar(6),
		IN Icidade varchar(30),
		IN Ibairro varchar(40),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Idata_adm datetime,
		IN Idata_dem datetime,
		IN Iid_cargo int(11),
		IN Iid_setor int(11),
		IN Itel varchar(15),
		IN Icel varchar(15),
		IN Iativo boolean,
		IN Iobs varchar(200)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @status = (SELECT IF(Iativo,'ATIVO','DEMIT'));
			INSERT INTO tb_funcionario (id,nome,data_nasc,rg,cpf,pis,endereco,num,cidade,bairro,estado,cep,data_adm,id_cargo,id_setor,tel,cel,obs,status) 
				VALUES (Iid,Inome,Inasc,Irg,Icpf,Ipis,Iend,Inum,Icidade,Ibairro,Iuf,Icep,Idata_adm,Iid_cargo,Iid_setor,Itel,Icel,Iobs,@status)
				ON DUPLICATE KEY UPDATE
				nome=Inome,data_nasc=Inasc,rg=Irg,cpf=Icpf,pis=Ipis,endereco=Iend,num=Inum,cidade=Icidade,bairro=Ibairro,estado=Iuf,cep=Icep,data_adm=Idata_adm,
				data_dem=Idata_dem,id_cargo=Iid_cargo,id_setor=Iid_setor,tel=Itel,cel=Icel,status=@status,obs=Iobs;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_func;
DELIMITER $$
	CREATE PROCEDURE sp_view_func(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Iativo boolean
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_func WHERE ativo = ',Iativo,' AND ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY nome;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_del_func;
DELIMITER $$ 
	CREATE PROCEDURE sp_del_func(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_funcionario WHERE id=Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_func_ponto;
DELIMITER $$ 
	CREATE PROCEDURE sp_set_func_ponto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_func int(11),
        IN Ientrada datetime,
        IN Isaida datetime
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_relogio_ponto(id,id_func,entrada,saida) VALUES (Iid,Iid_func,Ientrada,Isaida)
			ON DUPLICATE KEY UPDATE entrada=Ientrada, saida=Isaida;			
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_ferias;
DELIMITER $$
	CREATE PROCEDURE sp_view_ferias(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Iativo boolean
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_func WHERE ativo = ',Iativo,' AND ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY nome;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

/* EMPRESAS */

 DROP PROCEDURE sp_view_emp;
DELIMITER $$
	CREATE PROCEDURE sp_view_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_empresa WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_emp;
DELIMITER $$
	CREATE PROCEDURE sp_set_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Irazao_social varchar(80),    
		IN Ifant varchar(40),
		IN Icnpj varchar(14),
		IN Iie varchar(14),
		IN Iim varchar(14),
		IN Iend varchar(60),
		IN Inum varchar(6),
		IN Icomp varchar(50),
		IN Ibairro varchar(60),
		IN Icidade varchar(30),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Icliente BOOLEAN,
		IN Iramo varchar(80),
		IN Itel varchar(15),
		IN Iemail varchar(80)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_empresa (id,razao_social,fantasia,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,cliente,ramo,tel,email) 
				VALUES (Iid,Irazao_social,Ifant,Icnpj,Iie,Iim,Iend,Inum,Icomp,Ibairro,Icidade,Iuf,Icep,Icliente,Iramo,Itel,Iemail) 
				ON DUPLICATE KEY UPDATE
				razao_social=Irazao_social,fantasia=Ifant,cnpj=Icnpj,ie=Iie,im=Iim,end=Iend,num=Inum,comp=Icomp,bairro=Ibairro,
                cidade=Icidade,uf=Iuf,cep=Icep,cliente=Icliente,ramo=Iramo,tel=Itel,email=Iemail ;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_del_emp;
DELIMITER $$ 
	CREATE PROCEDURE sp_del_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_empresa WHERE id=Iid;
            UPDATE tb_produto SET id_emp=NULL WHERE id_emp=Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

/* PRODUTO */

 DROP PROCEDURE sp_set_prod;
DELIMITER $$
	CREATE PROCEDURE sp_set_prod(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_emp int(11),
		IN Idescricao varchar(80),
		IN Iestoque double,
		IN Iestq_min double,
		IN Iund varchar(10),
		IN Incm varchar(8),
		IN Icod_int int(11),
		IN Icod_bar varchar(15),
		IN Icod_forn varchar(20),
		IN Iconsumo BOOLEAN,
        IN Icusto double,
		IN Imarkup double,
        IN Ilocal varchar(20)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_produto (id,id_emp,descricao,estoque,estq_min,und,ncm,cod_int,cod_bar,cod_forn,consumo,custo,markup,local)
				VALUES (Iid,Iid_emp,Idescricao,Iestoque,Iestq_min,Iund,Incm,Icod_int,Icod_bar,Icod_forn,Iconsumo,Icusto,Imarkup,Ilocal)
				ON DUPLICATE KEY UPDATE
				id_emp=Iid_emp,descricao=Idescricao,estoque=Iestoque,estq_min=Iestq_min,und=Iund,ncm=Incm,cod_int=Icod_int,
                cod_bar=Icod_bar,cod_forn=Icod_forn,consumo=Iconsumo,custo=Icusto,markup=Imarkup,local=Ilocal;
        END IF;
	END $$
DELIMITER ;


 DROP PROCEDURE sp_view_prod;
DELIMITER $$
	CREATE PROCEDURE sp_view_prod(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_prod WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_del_prod;
DELIMITER $$ 
	CREATE PROCEDURE sp_del_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_prod_reserva WHERE id_prod = Iid;
			DELETE FROM tb_produto WHERE id=Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_reserv_prod;
DELIMITER $$
	CREATE PROCEDURE sp_set_reserv_prod(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_prod int(11),
		IN Iid_proj int(11),
		IN Iid_user int(11),
		IN Iqtd double,
		IN Ipago BOOLEAN
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_prod_reserva (id_prod,id_proj,id_user,qtd,pago)
				VALUES (Iid_prod,Iid_proj,Iid_user,Iqtd,Ipago)
				ON DUPLICATE KEY UPDATE
				qtd=Iqtd, pago=Ipago;
			IF(Ipago = 1)THEN
				UPDATE tb_produto SET estoque = estoque-Iqtd WHERE id=Iid_prod;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* ANÁLISE DE FROTA  E SERVIÇO EXECUTADO*/

 DROP PROCEDURE sp_view_analise_frota;
DELIMITER $$
	CREATE PROCEDURE sp_view_analise_frota(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Iexec varchar(3),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_analise_frota WHERE ',Ifield,' ',Isignal,' ',Ivalue,'AND exec IN (',Iexec,') AND data_analise BETWEEN "',Idt_ini,'" AND "',Idt_fin,'" ORDER BY data_analise;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_view_serv_exec;
DELIMITER $$
	CREATE PROCEDURE sp_view_serv_exec(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_serv_exec WHERE ',Ifield,' ',Isignal,' ',Ivalue,'AND data_exec BETWEEN "',Idt_ini,'" AND "',Idt_fin,'" ORDER BY data_exec;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_set_serv_exec;
DELIMITER $$
	CREATE PROCEDURE sp_set_serv_exec(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_emp int(11),
		IN Idata_exec date,
		IN Inum_carro varchar(15),
        IN Inf varchar(10),
        IN Ifunc varchar(150),
        IN Ipedido varchar(15),
        IN Ivalor double,
        IN Iobs varchar(500)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id = (SELECT IF(Iid = 0,'DEFAULT',Iid));
			INSERT INTO tb_serv_exec (id,id_emp,data_exec,num_carro,nf,func,pedido,valor,obs)
				VALUES (@id,Iid_emp,Idata_exec,Inum_carro,Inf,Ifunc,Ipedido,Ivalor,Iobs)
				ON DUPLICATE KEY UPDATE
				id_emp=Iid_emp, data_exec=Idata_exec, num_carro=Inum_carro, nf = Inf, 
                func=Ifunc, pedido=Ipedido, valor=Ivalor, obs=Iobs;
		END IF;
	END $$
	DELIMITER ;

DELIMITER $$
	CREATE PROCEDURE sp_del_serv_exec(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_serv_exec WHERE id = Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_view_pcp;
DELIMITER $$
	CREATE PROCEDURE sp_view_pcp(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Idt date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @ini = (SELECT IF(dayofweek(Idt) = 1,DATE_ADD(Idt, INTERVAL -6 DAY),DATE_ADD(Idt, INTERVAL 2-dayofweek(Idt) DAY)));
			SET @fin = (SELECT IF(dayofweek(Idt) = 1,Idt,DATE_ADD(Idt, INTERVAL 8-dayofweek(Idt) DAY)));        
			SELECT * FROM tb_pcp_2 WHERE data_serv BETWEEN @ini AND @fin ORDER BY data_serv; 
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_set_pcp;
DELIMITER $$
	CREATE PROCEDURE sp_set_pcp(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Idt date,
        IN Iid_setor int(11),
        IN Ivalor varchar(300)
    )
BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(TRIM(Ivalor) = "")THEN
				DELETE FROM tb_pcp_2 WHERE data_serv = Idt AND id_setor = Iid_setor;
            ELSE
				INSERT INTO tb_pcp_2 (data_serv, id_setor,valor) VALUES (Idt,Iid_setor,Ivalor)
				ON DUPLICATE KEY UPDATE valor=Ivalor;
            END IF;
        END IF;
	END $$
	DELIMITER ;

/* COTAÇÕES */

 DROP PROCEDURE sp_view_cotacao;
DELIMITER $$
	CREATE PROCEDURE sp_view_cotacao(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN

			SET @quer =CONCAT('SELECT COT.*, ITN.id_prod            
								FROM vw_cotacoes AS COT 
								LEFT JOIN vw_cot_itens AS ITN 
                                ON COT.id = ITN.id_ped 
                                WHERE ',Ifield,' ',Isignal,' ',Ivalue,' 
                                AND data_ped BETWEEN "',Idt_ini,'" 
                                AND "',Idt_fin,'" 
                                ORDER BY data_ped;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_set_pedido;
DELIMITER $$
	CREATE PROCEDURE sp_set_pedido(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_ped int(11),
        IN Iid_emp int(11),
        IN Idata_ped date,
        IN Idata_ent date,
        IN Iresp varchar(30),
        IN Icomp varchar(30),
        IN Inum_ped varchar(60),
        IN Idesconto double,
        IN Icond_pgto varchar(300),
        IN Iobs varchar(300)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inum_ped="")THEN
				SET @pedido = (SELECT CONCAT(SUBSTRING(CURDATE(),3,2),SUBSTRING(CURDATE(),6,2),SUBSTRING(CURDATE(),9,2),"-",(SELECT (COUNT(*)+1) AS new_ped FROM tb_pedido WHERE data_ped = CURDATE())));
			ELSE 
				SET @pedido = Inum_ped;
			END IF;
            
            INSERT INTO tb_pedido (id,origem,id_emp,data_ped,data_ent,resp,comp,num_ped,desconto,cond_pgto,obs)
            VALUES (Iid_ped,"SAN",Iid_emp,Idata_ped,Idata_ent,Iresp,Icomp,@pedido,Idesconto,Icond_pgto,Iobs)
            ON DUPLICATE KEY UPDATE
            id_emp=Iid_emp,data_ped=Idata_ped, data_ent=Idata_ent, num_ped=Inum_ped, desconto=Idesconto, 
            cond_pgto=Icond_pgto,obs=Iobs;
            
            IF(Iid_ped = 'DEFAULT')THEN
				SELECT * FROM tb_pedido WHERE id=(SELECT max(id) FROM tb_pedido);
            ELSE
				SELECT * FROM tb_pedido WHERE id=Iid_ped;
            END IF;
        END IF;
    
	END $$
	DELIMITER ;
    
 DROP PROCEDURE sp_view_item_cot;
DELIMITER $$
	CREATE PROCEDURE sp_view_item_cot(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_ped int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_item_cot WHERE id_ped = Iid_ped;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;    
    

-- DROP PROCEDURE sp_set_item_ped;
DELIMITER $$
	CREATE PROCEDURE sp_set_item_ped(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_prod int(11),
        IN Iid_ped int(11),
        IN Iqtd double,
        IN Ipreco double,
        IN Iund varchar(10),
        IN Iserv varchar(5)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_item_ped (id,id_prod,id_ped,qtd,preco,und,serv) 
            VALUES (Iid,Iid_prod,Iid_ped,Iqtd,Ipreco,Iund,Iserv)
			ON DUPLICATE KEY UPDATE 
			qtd=Iqtd,preco=Ipreco,und=Iund,serv=Iserv;
        END IF;
	END $$
	DELIMITER ;    

-- DROP PROCEDURE sp_del_cot;    
DELIMITER $$
	CREATE PROCEDURE sp_del_cot(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_ped int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_item_ped WHERE id_ped = Iid_ped;
			DELETE FROM tb_pedido WHERE id = Iid_ped;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
	DELIMITER ;    

-- DROP PROCEDURE sp_change_cot;    
DELIMITER $$
	CREATE PROCEDURE sp_change_cot(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_ped int(11),
        IN Istatus varchar(7)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			UPDATE tb_pedido SET status=Istatus WHERE id = Iid_ped;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
	DELIMITER ;       
    
/* RELOGIO DE PONTO */

 DROP PROCEDURE sp_view_relogio_ponto;
DELIMITER $$
	CREATE PROCEDURE sp_view_relogio_ponto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iinicio date,
        IN Ifinal date,
        IN Ifunc varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN	
			SET @quer =CONCAT('SELECT HE.*,FUNC.nome
				FROM tb_hora_extra AS HE
				INNER JOIN tb_funcionario AS FUNC
				ON HE.id_func = FUNC.id
				AND entrada BETWEEN "',Iinicio,'" AND "',Ifinal,'"
				AND id_func IN(',Ifunc,');');
                
-- 			SELECT @quer;
 			PREPARE stmt1 FROM @quer;
 			EXECUTE stmt1;
	
		ELSE
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_relogio_ponto;
DELIMITER $$
	CREATE PROCEDURE sp_set_relogio_ponto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Ient datetime,
        IN Isai datetime,
        IN Iid_func int(11)
    )
BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id = (SELECT IF(COUNT(*) = 0,"DEFAULT",id) AS id FROM tb_hora_extra WHERE DATE(entrada) = DATE(Ient) AND id_func = Iid_func);
			INSERT INTO tb_pcp_2 (id,id_func,entrada,saida) VALUES (@id,Iid_func,Ient,Isai)
			ON DUPLICATE KEY UPDATE entrada=Ient, saida=Isai;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_view_icms;
DELIMITER $$
	CREATE PROCEDURE sp_view_icms(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_icms WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;            
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_edtICMS;
DELIMITER $$
	CREATE PROCEDURE sp_edtICMS(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_uf int(11),
        IN Ivalor double
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			UPDATE tb_icms SET valor=Ivalor WHERE id=Iid_uf;
        END IF;

		SELECT * FROM tb_icms;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_view_serv_exec_nfs;
DELIMITER $$
	CREATE PROCEDURE sp_view_serv_exec_nfs(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_serv_exec WHERE ',Ifield,' ',Isignal,' ',Ivalue,'AND data_exec BETWEEN "',Idt_ini,'" AND "',Idt_fin,'" ORDER BY data_exec;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;
    /* COMPRAS */
    
     DROP PROCEDURE sp_view_compra;
DELIMITER $$
	CREATE PROCEDURE sp_view_compra(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN

			SET @quer =CONCAT('SELECT ENT.*, EMP.fantasia, EMP.id AS emp_id, EMP.endereco,
								EMP.num, EMP.cidade, EMP.estado, EMP.bairro
								FROM tb_entrada AS ENT
								INNER JOIN tb_empresa AS EMP 
								ON ENT.id_emp = EMP.id
								AND ',Ifield,' ',Isignal,' ',Ivalue,' 
								AND data_ent BETWEEN "',Idt_ini,'" 
								AND "',Idt_fin,'"
								ORDER BY ENT.data_ent DESC;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
	DELIMITER ;
    
	DROP PROCEDURE sp_set_compra;
DELIMITER $$
	CREATE PROCEDURE sp_set_compra(
		IN Iallow varchar(80),
		IN Ihash varchar(64),        
		IN Iid int(11),
        IN Inf varchar(10),
		IN Iid_emp int(11),
        IN Idt_ent date,
        IN Iresp varchar(15),
        IN Istatus varchar(7),
        IN Iobs varchar(150)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid=0)THEN
				INSERT INTO tb_entrada (id, nf, id_emp, data_ent, resp, status, OBS)
				VALUES (@id,Inf,Iid_emp,Idt_ent,Iresp,Istatus,Iobs);
            ELSE
				 UPDATE tb_entrada 
                 SET nf=Inf, id_emp=Iid_emp, data_ent=Idt_ent, resp=Iresp, status=Istatus, OBS=Iobs
                 WHERE id=Iid;
            END IF;
		END IF;    
	END $$
DELIMITER ;
    
-- DROP PROCEDURE sp_view_item_compra;
DELIMITER $$
	CREATE PROCEDURE sp_view_item_compra(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN IidCompra int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT IC.*, PROD.descricao, PROD.unidade, PROD.cod, PROD.cod_bar AS cod_cli, ROUND((IC.qtd * IC.preco),2) as total
				FROM tb_item_compra AS IC 
				INNER JOIN tb_produto AS PROD
				ON PROD.id = IC.id_prod
				AND id_ent=IidCompra;
        END IF;
	END $$
	DELIMITER ;
    
    
 DROP PROCEDURE sp_set_item_compra;
DELIMITER $$
	CREATE PROCEDURE sp_set_item_compra(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_prod int(11),
        IN Iid_comp int(11),
        IN Iqtd double,
        IN Ipreco double
    )
BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iqtd = 0)THEN
				DELETE FROM tb_item_compra WHERE id=Iid;
            ELSE
				IF(Iid=0)THEN
                INSERT INTO tb_item_compra (id_prod, id_ent, qtd, preco)
					VALUES (Iid_prod,Iid_comp,Iqtd,Ipreco);
                ELSE
					UPDATE tb_item_compra
					SET id_prod=Iid_prod, id_ent=Iid_comp, qtd=Iqtd, preco=Ipreco
                    WHERE id=Iid;                
                END IF;
			END IF;
        END IF;	
	END $$
DELIMITER ;
    
 DROP PROCEDURE sp_del_compra;
DELIMITER $$
	CREATE PROCEDURE sp_del_compra(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN IidCompra int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF((SELECT status FROM tb_entrada WHERE id=IidCompra) = "ABERTO")THEN
				DELETE FROM tb_item_compra WHERE id_ent=IidCompra;
				DELETE FROM tb_entrada WHERE id=IidCompra;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_fecha_compra;
DELIMITER $$
	CREATE PROCEDURE sp_fecha_compra(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN IidCompra int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF((SELECT status FROM tb_entrada WHERE id=IidCompra) = "ABERTO")THEN
				UPDATE tb_entrada SET status = "FECHADO" WHERE id=IidCompra;
                
				UPDATE tb_produto as prod INNER JOIN tb_item_compra as item 
				SET prod.estoque = (prod.estoque + item.qtd), prod.preco_comp = item.preco 
				WHERE prod.id=item.id_prod 
				AND item.id_ent = IidCompra;
            END IF;
        END IF;
	END $$
DELIMITER ;