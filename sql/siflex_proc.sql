/* FUNCTIONS */

-- DROP PROCEDURE sp_getHash;
DELIMITER $$
	CREATE PROCEDURE sp_getHash(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SELECT SHA2(CONCAT(Iemail, Isenha), 256) AS HASH;
	END $$
DELIMITER ;

-- DROP PROCEDURE sp_allow;
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

-- DROP PROCEDURE sp_login;
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

 DROP PROCEDURE IF EXISTS sp_check_usr_mail;
DELIMITER $$
	CREATE PROCEDURE sp_check_usr_mail(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call>0)THEN        
			SELECT COUNT(*) AS new_mail FROM tb_mail WHERE id_to = @id_call AND looked=0;
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

 DROP PROCEDURE IF EXISTS sp_sys_alert;
DELIMITER $$
	CREATE PROCEDURE sp_sys_alert(	
		IN Ihash varchar(64),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@access=0)THEN
			INSERT INTO tb_mail (id_from,id_to,message) SELECT 0,USR.id,Imessage FROM tb_user AS USR;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_mail;
DELIMITER $$
	CREATE PROCEDURE sp_set_mail(	
		IN Ihash varchar(64),
        IN Iid_to int(11),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			INSERT INTO tb_mail (id_from,id_to,message) VALUES (@id_call,Iid_to,Imessage);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_mail;
DELIMITER $$
	CREATE PROCEDURE sp_view_mail(	
		IN Ihash varchar(64),
        IN Isend boolean
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Isend)THEN
            SELECT MAIL.*, COALESCE(USR.email,"SIFLEX") AS mail_from
				FROM tb_mail AS MAIL 
				LEFT JOIN tb_user AS USR
				ON MAIL.id_from = USR.id
				WHERE MAIL.id_to = @id_call;
/*            
				SELECT MAIL.*, USR.email AS mail_from
					FROM tb_mail AS MAIL 
					INNER JOIN tb_user AS USR
					ON MAIL.id_from = USR.id AND MAIL.id_to = @id_call;  
*/
            ELSE
				SELECT MAIL.*, USR.email AS mail_to
					FROM tb_mail AS MAIL 
					INNER JOIN tb_user AS USR
					ON MAIL.id_to = USR.id AND MAIL.id_from = @id_call;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_del_mail;
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
			DELETE FROM tb_mail WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_mark_mail;
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
			UPDATE tb_mail SET looked=1 WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
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
-- id,nome,nasc,rg,cpf,pis,end,num,cidade,bairro,uf,cep,data_adm,data_dem,id_cargo,tel,cel,ativo,obs,reg,nick
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
-- 		IN Iid_setor int(11),
		IN Itel varchar(15),
		IN Icel varchar(15),
		IN Iativo boolean,
		IN Iobs varchar(200),
        IN Ireg varchar(5),
		IN Inick varchar(20)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @status = (SELECT IF(Iativo,'ATIVO','DEMIT'));
			INSERT INTO tb_funcionario (id,nome,data_nasc,rg,cpf,pis,endereco,num,cidade,bairro,estado,cep,data_adm,id_cargo,tel,cel,obs,status,reg,nick) 
				VALUES (Iid,Inome,Inasc,Irg,Icpf,Ipis,Iend,Inum,Icidade,Ibairro,Iuf,Icep,Idata_adm,Iid_cargo,Itel,Icel,Iobs,@status,Ireg,Inick)
				ON DUPLICATE KEY UPDATE
				nome=Inome,data_nasc=Inasc,rg=Irg,cpf=Icpf,pis=Ipis,endereco=Iend,num=Inum,cidade=Icidade,bairro=Ibairro,estado=Iuf,cep=Icep,data_adm=Idata_adm,
				data_dem=Idata_dem,id_cargo=Iid_cargo,tel=Itel,cel=Icel,status=@status,obs=Iobs, reg=Ireg, nick=Inick;
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

 DROP PROCEDURE sp_set_func_setor;
DELIMITER $$ 
	CREATE PROCEDURE sp_set_func_setor(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_func int(11),
		IN Iid_setor int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @has = (SELECT COUNT(*) FROM tb_func_setor WHERE id_func=Iid_func AND id_setor=Iid_setor);
			IF(@has)THEN
				DELETE FROM tb_func_setor WHERE id_func=Iid_func AND id_setor=Iid_setor;
            ELSE
				INSERT INTO tb_func_setor (id_func,id_setor) VALUES (Iid_func,Iid_setor);	
            END IF;
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
        
			IF(Iid = 0)THEN
				SET @cod = (SELECT IF(Icod_int="",MAX(cod)+1,Icod_int)FROM tb_produto);
				INSERT INTO tb_produto (id,id_emp,descricao,estoque,etq_min,unidade,ncm,cod,cod_bar,cod_cli,consumo,preco_comp,margem,local)
				VALUES (DEFAULT,Iid_emp,Idescricao,Iestoque,Iestq_min,Iund,Incm,@cod,Icod_bar,Icod_forn,Iconsumo,Icusto,Imarkup,Ilocal);           
            ELSE
				IF(Idescricao="")THEN
					DELETE FROM tb_prod_reserva WHERE id_prod = Iid;
					DELETE FROM tb_produto WHERE id=Iid;  
                ELSE
					UPDATE tb_produto SET 
						id_emp=Iid_emp,descricao=Idescricao,estoque=Iestoque,etq_min=Iestq_min,unidade=Iund,ncm=Incm,cod=Icod_int,
						cod_bar=Icod_bar,cod_cli=Icod_forn,consumo=Iconsumo,preco_comp=Icusto,margem=Imarkup,local=Ilocal
					WHERE id=Iid;                
                END IF;            
            END IF;
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
        IN Ifunc varchar(150),
        IN Ihide bool
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN	
			SET @quer =CONCAT('SELECT * FROM vw_hora_extra
				WHERE entrada >= "',Iinicio,'" AND   entrada <="',Ifinal,'"
				AND id_func IN(',Ifunc,')
                AND hide = ',Ihide,';');
                
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

 DROP PROCEDURE sp_set_relogio_ponto;
DELIMITER $$
	CREATE PROCEDURE sp_set_relogio_ponto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Ient datetime,
        IN Isai datetime,
        IN Iid_func int(11),
        IN Ihide bool
    )
BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id = (SELECT IF(COUNT(*) = 0,"DEFAULT",id) AS id FROM tb_hora_extra WHERE DATE(entrada) = DATE(Ient) AND id_func = Iid_func);
			INSERT INTO tb_hora_extra (id,id_func,entrada,saida,hide) VALUES (@id,Iid_func,Ient,Isai,Ihide)
			ON DUPLICATE KEY UPDATE entrada=Ient, saida=Isai, hide=Ihide;
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
			SET @quer = 'SELECT * FROM ';
            SET @quer =CONCAT('SELECT * FROM vw_compras
								WHERE ',Ifield,' ',Isignal,' ',Ivalue,' 
								AND data_ent >= "',Idt_ini,'" 
								AND data_ent <="',Idt_fin,'"
								ORDER BY data_ent DESC;');
                                
                          
/*
			SET @quer =CONCAT('SELECT ENT.*, EMP.fantasia, EMP.id AS emp_id, EMP.endereco,
								EMP.num, EMP.cidade, EMP.estado, EMP.bairro
								FROM tb_entrada AS ENT
								INNER JOIN tb_empresa AS EMP 
								ON ENT.id_emp = EMP.id
								AND ',Ifield,' ',Isignal,' ',Ivalue,' 
								AND data_ent BETWEEN "',Idt_ini,'" 
								AND "',Idt_fin,'"
								ORDER BY ENT.data_ent DESC;');
*/                                
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

/* EPI */

 DROP PROCEDURE sp_viewEPI;
DELIMITER $$
	CREATE PROCEDURE sp_viewEPI(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_epi WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS id_func, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_setEPI;
DELIMITER $$
	CREATE PROCEDURE sp_setEPI(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(80),
		IN Imarca varchar(50),
		IN Iestq double,
		IN Iestq_min double,
		IN Iund varchar(10),
		IN Icod_bar varchar(15),
		IN Inum_ca varchar(20),
		IN Ilocal varchar(20)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome="")THEN
				DELETE FROM tb_epi WHERE id=Iid ;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_epi (nome,marca,estq,estq_min,und,cod_bar,num_ca,local)
                    VALUES(Inome,Imarca,Iestq,Iestq_min,Iund,Icod_bar,Inum_ca,Ilocal);            
                ELSE
					UPDATE tb_epi 
                    SET nome=Inome,marca=Imarca,estq=Iestq,estq_min=Iestq_min,und=Iund,cod_bar=Icod_bar,num_ca=Inum_ca,local=Ilocal
                    WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_epi_func;
DELIMITER $$
	CREATE PROCEDURE sp_set_epi_func(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_func int(11),
        IN Iid_epi int(11),
        IN Iqtd double,
        IN Idata datetime
    )
BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iqtd = 0)THEN
				DELETE FROM tb_func_epi WHERE id=Iid;
            ELSE
				IF(Iid=0)THEN
                INSERT INTO tb_func_epi (id_func, id_epi, qtd, data)
					VALUES (Iid_func,Iid_epi,Iqtd,Idata);
                ELSE
					UPDATE tb_func_epi
					SET qtd=Iqtd, data=Idata
                    WHERE id=Iid;                
                END IF;
			END IF;
        END IF;	
	END $$
DELIMITER ;

/* PROCESSO */

 DROP PROCEDURE IF EXISTS sp_view_proc;
DELIMITER $$
	CREATE PROCEDURE sp_view_proc(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Inome varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_processo WHERE nome LIKE CONCAT('%',Inome COLLATE utf8_general_ci,'%') ORDER BY nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_proc;
DELIMITER $$
	CREATE PROCEDURE sp_set_proc(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
        IN Inome varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome="")THEN
				DELETE FROM tb_etapa_proc WHERE id_processo=Iid;
                DELETE FROM tb_processo WHERE id=Iid ;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_processo (nome)
                    VALUES(Inome);            
                ELSE
					UPDATE tb_processo SET nome=Inome WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_etapa_proc;
DELIMITER $$
	CREATE PROCEDURE sp_view_etapa_proc(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_proc int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM tb_etapa_proc WHERE id_processo = Iid_proc ORDER BY id;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_etapa_proc;
DELIMITER $$
	CREATE PROCEDURE sp_set_etapa_proc(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
        IN Iid_proc int(11),
        IN Iid_setor int(11),
        IN Idesc varchar(255)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Idesc="")THEN
				DELETE FROM tb_etapa_proc WHERE id=Iid;
                DELETE FROM tb_apontamento WHERE id_etapa=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_etapa_proc (id_processo,id_setor,descricao)
                    VALUES(Iid_proc,Iid_setor,Idesc);            
                ELSE
					UPDATE tb_etapa_proc SET id_setor=Iid_setor, descricao=Idesc WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_up_etapa_proc;
DELIMITER $$
	CREATE PROCEDURE sp_up_etapa_proc(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_processo = (SELECT id_processo FROM tb_etapa_proc WHERE id=Iid);
            SET @id_acima = (SELECT COALESCE(MAX(id),0) FROM tb_etapa_proc WHERE id_processo=@id_processo AND id<Iid);
			IF(@id_acima>0)THEN
				UPDATE tb_etapa_proc SET id=0 WHERE id=@id_acima;
                UPDATE tb_etapa_proc SET id=@id_acima WHERE id=Iid;
                UPDATE tb_etapa_proc SET id=Iid WHERE id=0;
            END IF;
		END IF;
	END $$
DELIMITER ;

SELECT * FROM tb_etapa_proc WHERE id_processo=6;

/* OS */

	DROP PROCEDURE IF EXISTS sp_view_os;
DELIMITER $$
	CREATE PROCEDURE sp_view_os(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iscanner varchar(9)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_os = (SELECT SUBSTRING(Iscanner, 1, 4));
 			SELECT * FROM vw_os WHERE id = @id_os;
        END IF;
	END $$
	DELIMITER ;

	DROP PROCEDURE IF EXISTS sp_view_os_proc;
DELIMITER $$
	CREATE PROCEDURE sp_view_os_proc(
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
			SET @quer =CONCAT('SELECT * FROM vw_os WHERE ',Ifield,' ',Isignal,' ',Ivalue,'
			 AND dt_entrega >= "',Idt_ini, 
            '" AND dt_entrega <= "',Idt_fin,
            '" ORDER BY dt_entrega, id;');   
   			PREPARE stmt1 FROM @quer;
 			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;


 DROP PROCEDURE IF EXISTS sp_set_os;
DELIMITER $$
	CREATE PROCEDURE sp_set_os(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
        IN Iid_proc int(11),
        IN Iid_emp int(11),
        IN Idt_entrega date,
        IN Iobs varchar(255)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_proc=0)THEN
				DELETE FROM tb_apontamento WHERE id_os=Iid;
				DELETE FROM tb_os WHERE id=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_os (id_proc,id_emp,dt_entrega,obs)
                    VALUES(Iid_proc,Iid_emp,Idt_entrega,Iobs);            
                ELSE
					UPDATE tb_os SET id_emp=Iid_emp, dt_entrega=Idt_entrega, obs=Iobs WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_close_os;
DELIMITER $$
	CREATE PROCEDURE sp_close_os(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
		IN Istatus int
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			UPDATE tb_os SET aberta=Istatus WHERE id=Iid;
        END IF;
	END $$
DELIMITER ;

	DROP PROCEDURE IF EXISTS sp_proc_detail;
DELIMITER $$
	CREATE PROCEDURE sp_proc_detail(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_proc int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_etapa_setor 
            WHERE id_processo = Iid_proc
            ORDER BY id;
        END IF;
	END $$
	DELIMITER ;
    
    
 	DROP PROCEDURE IF EXISTS sp_view_apt;
DELIMITER $$
	CREATE PROCEDURE sp_view_apt(
		IN Iscanner varchar(9)
    )
	BEGIN
		SET @id_os = (SELECT SUBSTRING(Iscanner, 1, 4));
		SELECT APT.*, (@row_number := @row_number + 1) AS ordem
		FROM vw_apontamento AS APT,
		(SELECT @row_number := 0) AS r
		WHERE id_os = @id_os
		ORDER BY id_etapa;
	END $$
	DELIMITER ;    
    
 DROP PROCEDURE IF EXISTS sp_set_apt;
DELIMITER $$
	CREATE PROCEDURE sp_set_apt(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iscanner varchar(9),
        IN Iid_func int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_os = (SELECT SUBSTRING(Iscanner, 1, 4));
 			SET @id_etapa = (SELECT SUBSTRING(Iscanner, 6, 12));        
-- 			SET @id_setor_func = (SELECT id_setor FROM tb_func_setor WHERE id_func = Iid_func);
			SET @id_setor_os = (SELECT id_setor FROM vw_apontamento WHERE id_os=@id_os AND id_etapa=@id_etapa);
			IF(@id_setor_os  IN (SELECT id_setor FROM tb_func_setor WHERE id_func = Iid_func))THEN
    			INSERT INTO tb_apontamento (id_os,id_etapa,id_func) VALUES (@id_os,@id_etapa,Iid_func)
                ON DUPLICATE KEY UPDATE id_func=Iid_func;
                IF((SELECT COUNT(*) FROM vw_apontamento WHERE id_os=@id_os AND ok=0)>0)THEN
					UPDATE tb_os SET aberta = 0 WHERE id=@id_os;
                END IF;
            END IF;
            CALL sp_view_apt(Iscanner);
        END IF;
	END $$
	DELIMITER ;   

/* SANFONA DE ONIBUS */

	DROP PROCEDURE IF EXISTS sp_view_sanf_onibus;
DELIMITER $$
	CREATE PROCEDURE sp_view_sanf_onibus(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_sanf_onibus WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');   
   			PREPARE stmt1 FROM @quer;
 			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE sp_sanf_onibus;
DELIMITER $$
	CREATE PROCEDURE sp_sanf_onibus(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(120),
		IN Imarca varchar(60),
		IN Imodelo varchar(60),
        IN Ichassi varchar(30),
		IN Iano varchar(4),
		IN Iqtd_barras int,
		IN Iqtd_dob_teto int,
		IN Iqtd_dob_chao int,
		IN Ialt double,
		IN Ilarg double,
		IN Ialt_teto double,
		IN Ialt_lateral double,
		IN Ilarg_teto  double,
		IN Ialt_sanf double,
        IN Ialt_sanf_cost double,
		IN Ilarg_sanf double,
		IN Itopo_sanf double,
		IN Ibase_sanf double,
        IN Ilarg_corredor double,
		IN Ilarg_chao double,
		IN Idist_carro double,
        IN Iobs varchar(1024)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid = 0)THEN
				INSERT INTO tb_sanf_onibus (nome,marca,modelo,chassi,ano,qtd_barras,qtd_dob_teto,qtd_dob_chao,alt,larg,alt_teto,alt_lateral,larg_teto,alt_sanf,alt_sanf_cost,larg_sanf,topo_sanf,base_sanf,larg_corredor,larg_chao,dist_carro,obs)
				VALUES (Inome,Imarca,Imodelo,Ichassi,Iano,Iqtd_barras,Iqtd_dob_teto,Iqtd_dob_chao,Ialt,Ilarg,Ialt_teto,Ialt_lateral,Ilarg_teto,Ialt_sanf,Ialt_sanf_cost,
                Ilarg_sanf,Itopo_sanf,Ibase_sanf,Ilarg_corredor,Ilarg_chao,Idist_carro,Iobs);
            ELSE
				IF(Inome="")THEN
					DELETE FROM tb_sanf_onibus WHERE id=Iid;  
                ELSE
					UPDATE tb_sanf_onibus SET 
						nome=Inome,marca=Imarca,modelo=Imodelo,chassi=Ichassi,ano=Iano,qtd_barras=Iqtd_barras,qtd_dob_teto=Iqtd_dob_teto,qtd_dob_chao=Iqtd_dob_chao,
                        alt=Ialt,larg=Ilarg,alt_teto=Ialt_teto,alt_lateral=Ialt_lateral,larg_teto=Ilarg_teto,alt_sanf=Ialt_sanf,alt_sanf_cost=Ialt_sanf_cost,larg_sanf=Ilarg_sanf,
                        topo_sanf=Itopo_sanf,base_sanf=Ibase_sanf,larg_corredor=Ilarg_corredor,larg_chao=Ilarg_chao,dist_carro=Idist_carro,obs=Iobs
					WHERE id=Iid;                
                END IF;            
            END IF;
        END IF;
	END $$
DELIMITER ;

/* FINANCEIRO */

	DROP PROCEDURE IF EXISTS sp_view_contas_a_pagar;
DELIMITER $$
	CREATE PROCEDURE sp_view_contas_a_pagar(
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
			SET @quer =CONCAT('SELECT * FROM vw_contas_a_pagar WHERE ',Ifield,' ',Isignal,' ',Ivalue,' AND venc BETWEEN "',Idt_ini,'" AND "',Idt_fin,'" ORDER BY venc;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;
    
     DROP PROCEDURE sp_set_contas_a_pagar;
DELIMITER $$
	CREATE PROCEDURE sp_set_contas_a_pagar(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_cli int(11),
		IN Inome varchar(60),
        IN Ibeneficiario varchar(128),
		IN Ivenc date,
		IN Ivalor double,
		IN Icod_pgto varchar(512),
        IN Itipo varchar(8),
        IN Icentro_custo varchar(20),
        IN Ipgto boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid = 0)THEN
				INSERT INTO tb_contas_a_pagar (id_cli,nome,beneficiario,venc,valor,cod_pgto,tipo,centro_custo,pgto)
				VALUES (Iid_cli,Inome,Ibeneficiario,Ivenc,Ivalor,Icod_pgto,Itipo,Icentro_custo,Ipgto);
            ELSE
				IF(Inome="")THEN
					DELETE FROM tb_contas_a_pagar WHERE id=Iid;  
                ELSE
					UPDATE tb_contas_a_pagar SET 
						id_cli=Iid_cli, nome=Inome, beneficiario=Ibeneficiario, venc=Ivenc, valor=Ivalor, cod_pgto=Icod_pgto, tipo=Itipo, centro_custo=Icentro_custo
					WHERE id=Iid;                
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

	DROP PROCEDURE IF EXISTS sp_view_a_receber;
DELIMITER $$
	CREATE PROCEDURE sp_view_a_receber(
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
			SET @quer =CONCAT('SELECT * FROM vw_a_receber WHERE ',Ifield,' ',Isignal,' ',Ivalue,' AND venc BETWEEN "',Idt_ini,'" AND "',Idt_fin,'" ORDER BY venc;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;

     DROP PROCEDURE sp_set_a_receber;
DELIMITER $$
	CREATE PROCEDURE sp_set_a_receber(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_cli int(11),
		IN Inome varchar(60),
		IN Ivenc date,
		IN Ivalor double,
        IN Itipo varchar(8),
        IN Inf varchar(10),
        IN Iobs varchar(256),
        IN Ipgto bool
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_cli = (SELECT IF(Iid_cli=0,NULL,Iid_cli));
			IF(Iid = 0)THEN
				INSERT INTO tb_a_receber (id_cli,nome,venc,valor,tipo,nf,obs,pgto)
				VALUES (@id_cli,Inome,Ivenc,Ivalor,Itipo,Inf,Iobs,Ipgto);
            ELSE
				IF(Inome="")THEN
					DELETE FROM tb_a_receber WHERE id=Iid;  
                ELSE
					UPDATE tb_a_receber SET 
						id_cli=@id_cli, nome=Inome, venc=Ivenc, valor=Ivalor, tipo=Itipo, nf=Inf, obs=Iobs, pgto=Ipgto
					WHERE id=Iid;                
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

     DROP PROCEDURE sp_check_pagamento;
DELIMITER $$
	CREATE PROCEDURE sp_check_pagamento(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Ipgto bool,
		IN Ipgto_dia date,
        IN Itipo varchar(8),
        IN Iobs varchar(256)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			UPDATE tb_contas_a_pagar SET
				pgto=Ipgto, pgto_dia=Ipgto_dia, tipo=Itipo, obs=Iobs
			WHERE id=Iid;
        END IF;
	END $$
DELIMITER ;

	DROP PROCEDURE IF EXISTS sp_view_pix;
DELIMITER $$
	CREATE PROCEDURE sp_view_pix(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_pix WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');   
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;

     DROP PROCEDURE sp_set_pix;
DELIMITER $$
	CREATE PROCEDURE sp_set_pix(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Inome varchar(50),
        IN Icidade varchar(50),
		IN Ichave varchar(512),
		IN Iorg_ref varchar(40),
		IN Iid_ref int(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid = 0)THEN
				SET @org = (SELECT IF(Iorg_ref=0 OR Iid_ref=0,NULL,Iorg_ref));
				SET @ref = (SELECT IF(Iorg_ref=0 OR Iid_ref=0,NULL,Iid_ref));
				INSERT INTO tb_pix (nome,cidade,chave,org_ref,id_ref)
				VALUES (Inome,Icidade,Ichave,@org,@ref);
            ELSE
				IF(Inome="")THEN
					DELETE FROM tb_pix WHERE id=Iid;
                ELSE
					UPDATE tb_pix SET
						nome=Inome,chave=Ichave,cidade=Icidade
					WHERE id=Iid;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

	DROP PROCEDURE IF EXISTS sp_view_analytics;
DELIMITER $$
	CREATE PROCEDURE sp_view_analytics(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ientrada varchar(7),
		IN Isaida varchar(5),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @saldo = 0;
            SELECT *,@saldo:=@saldo+ROUND(valor,2) saldo  
				FROM vw_analytics 
				WHERE (modalidade =Ientrada OR modalidade=Isaida)
				AND venc>= Idt_ini
				AND venc <=Idt_fin
				ORDER BY venc;
            
            
-- 			SET @quer =CONCAT('SELECT ANA.*,@saldo:=@saldo+ROUND(ANA.valor,2) saldo  FROM vw_analytics AS ANA WHERE (modalidade =',Ientrada,' OR modalidade) AND venc BETWEEN "',Idt_ini,'" AND "',Idt_fin,'" ORDER BY venc;');
-- 			PREPARE stmt1 FROM @quer;
-- 			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;
    
    /* POSTS */

 DROP PROCEDURE IF EXISTS sp_view_post;
DELIMITER $$
	CREATE PROCEDURE sp_view_post(	
		IN Istart int(11) unsigned,
		IN Iend int(11) unsigned
    )
	BEGIN
		UPDATE tb_post SET views=views+1;
		SELECT * FROM vw_posts ORDER BY data_hora ASC LIMIT Istart,Iend;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_post;
DELIMITER $$
	CREATE PROCEDURE sp_set_post(
		IN Ihash varchar(64),
		IN Iid int(11),
		IN Itexto varchar(255),
        IN Ihas_image boolean
    )
	BEGIN    
		SET @id_user =  (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci  ORDER BY id LIMIT 1);
		IF(@id_user>0)THEN
			IF(Itexto="#del")THEN
				DELETE FROM tb_post_message WHERE id_post=Iid;
				DELETE FROM tb_post WHERE id=Iid;
                SELECT 0 AS id;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_post (id_user,texto,has_image)
                    VALUES(@id_user,Itexto,Ihas_image);            
					SELECT * FROM vw_posts WHERE id= (SELECT MAX(id) FROM tb_post);
                ELSE
					UPDATE tb_post SET texto=Itexto WHERE id=Iid;
					SELECT * FROM vw_posts WHERE id=Iid;
                END IF;
            END IF;
		ELSE
			SELECT 0 AS id;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_add_like;
DELIMITER $$
	CREATE PROCEDURE sp_add_like(	
		IN Iid int(11)
    )
	BEGIN
		UPDATE tb_post SET likes=likes+1 WHERE id=Iid;
        SELECT likes FROM tb_post WHERE id=Iid;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_comment;
DELIMITER $$
	CREATE PROCEDURE sp_view_comment(	
		IN Iid_post int(11)
    )
	BEGIN
		SELECT * FROM tb_post_message WHERE id_post=Iid_post ORDER BY data_hora ASC;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_comment;
DELIMITER $$
	CREATE PROCEDURE sp_set_comment(
		IN Iid int(11),
        IN Iid_post int(11),
		IN Inome varchar(50),
		IN Iempresa varchar(50),
		IN Itexto varchar(256)
    )
	BEGIN    
		IF(Itexto="#del")THEN
			DELETE FROM tb_post_message WHERE id=Iid;
			SELECT 0 AS id;
		ELSE			
			IF(Iid=0)THEN
				INSERT INTO tb_post_message (id_post,nome,empresa,texto)
				VALUES(Iid_post,Inome,Iempresa,Itexto);            
				SELECT * FROM tb_post_message WHERE id= (SELECT MAX(id) FROM tb_post_message);
			ELSE
				UPDATE tb_post_message SET texto=Itexto WHERE id=Iid;
				SELECT * FROM tb_post_message WHERE id=Iid;
			END IF;
		END IF;

	END $$
DELIMITER ;

/* FIM POSTS */

/* BOLETOS */

 DROP PROCEDURE IF EXISTS sp_view_boletos;
DELIMITER $$
	CREATE PROCEDURE sp_view_boletos(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Idt_ini date,
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
            SELECT *
				FROM tb_boletos 
				WHERE venc >= Idt_ini
				AND venc <=Idt_fin
				ORDER BY venc DESC;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_boletos;
DELIMITER $$
	CREATE PROCEDURE sp_set_boletos(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Icod_pgto int(11),
        IN Icliente varchar(25),
		IN Ivalor double,
		IN Ivenc date,
		IN Ipgto date,
		IN Inf varchar(10)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @nw = (SELECT COUNT(*) FROM tb_boletos WHERE cod_pgto=Icod_pgto);
			IF(@nw = 0)THEN
				INSERT INTO tb_boletos (cod_pgto,cliente,valor,venc,pgto,nf,quitado)
				VALUES (Icod_pgto,Icliente,Ivalor,Ivenc,Ipgto,Inf,IF(Ipgto>0,1,0));
            ELSE
				IF (Ipgto>0)THEN
					UPDATE tb_boletos SET pgto=Ipgto, quitado=1 WHERE cod_pgto=Icod_pgto;
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* FIM BOLETOS */

