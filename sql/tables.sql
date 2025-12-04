 DROP TABLE tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) NOT NULL,
    hash varchar(64) NOT NULL,
    id_func int(11) DEFAULT 0,
    access int(11) DEFAULT -1,
	UNIQUE KEY (hash),
	UNIQUE KEY (email),
    FOREIGN KEY (id_func) REFERENCES tb_funcionario(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

INSERT INTO tb_usuario (email,hash,access)VALUES("admin@fwtecnologia.com.br","e9a5438692c002bf4e761e95350284a15d740c71bd65edfa8a1217a2be312730",0);

 DROP TABLE tb_usr_perm_perfil;
CREATE TABLE tb_usr_perm_perfil (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    perm varchar(50) NOT NULL DEFAULT "0",
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;


 DROP TABLE tb_funcionario;
CREATE TABLE tb_funcionario (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) DEFAULT NULL,
    nasc date DEFAULT NULL,
    rg varchar(15) DEFAULT NULL,
    cpf varchar(15) DEFAULT NULL,
    pis varchar(15) DEFAULT NULL,
    end varchar(60) DEFAULT NULL,
    num varchar(6) DEFAULT NULL,
    cidade varchar(30) DEFAULT NULL,
    bairro varchar(40) DEFAULT NULL,
    uf varchar(2) DEFAULT NULL,
    cep varchar(10) DEFAULT NULL,    
    data_adm date DEFAULT NULL,
	data_dem date DEFAULT NULL,
    id_cargo int(11) DEFAULT 0,
	id_setor int(11) DEFAULT 0,
    tel varchar(15) DEFAULT NULL,
    cel varchar(15) DEFAULT NULL,
    ativo boolean DEFAULT 1,
	obs varchar(200) DEFAULT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_setor) REFERENCES tb_setores(id),
    FOREIGN KEY (id_cargo) REFERENCES tb_cargos(id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8; 
 
--  DROP TABLE tb_relogio_ponto;
CREATE TABLE tb_relogio_ponto (
	id int(11) NOT NULL AUTO_INCREMENT,
    id_func int(11) NOT NULL,
    entrada datetime NOT NULL,
    saida datetime NOT NULL,
    FOREIGN KEY (id_func) REFERENCES tb_funcionario(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
 
-- DROP TABLE tb_setores;
CREATE TABLE tb_setores (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- DROP TABLE tb_cargos;
CREATE TABLE tb_cargos (
    id int(11) NOT NULL AUTO_INCREMENT,
    cargo varchar(30) NOT NULL,
    salario double NOT NULL DEFAULT 0,
    mensal boolean NOT NULL DEFAULT 0,
    cbo varchar(8) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- DROP TABLE tb_und;
CREATE TABLE tb_und (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    sigla varchar(8) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_calendario;
CREATE TABLE tb_calendario (
    id_user int(11) NOT NULL,
    data_agd date NOT NULL,
    obs varchar(255),
    PRIMARY KEY (id_user,data_agd)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_mail;
CREATE TABLE tb_mail (
	data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    id_from int(11) NOT NULL,
    id_to int(11) NOT NULL,
    message varchar(512),
    looked boolean DEFAULT 0,
    FOREIGN KEY (id_from) REFERENCES tb_usuario(id),
    FOREIGN KEY (id_to) REFERENCES tb_usuario(id),
    PRIMARY KEY (data,id_from)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE tb_empresa;
CREATE TABLE tb_empresa(
    id int(11) NOT NULL AUTO_INCREMENT,
    razao_social varchar(80) NOT NULL,
    fantasia varchar(40) DEFAULT null,
    cnpj varchar(14) DEFAULT NULL,
    ie varchar(14) DEFAULT NULL,
    im varchar(14) DEFAULT NULL,
    end varchar(60) DEFAULT NULL,
	num varchar(6) DEFAULT NULL,
    comp varchar(50) DEFAULT NULL,
    bairro varchar(60) DEFAULT NULL,
    cidade varchar(30) DEFAULT NULL,
    uf varchar(2) DEFAULT NULL,
    cep varchar(10) DEFAULT NULL,
    cliente BOOLEAN DEFAULT 1,
    ramo varchar(80) DEFAULT NULL,
    tel varchar(15) DEFAULT NULL,
    email varchar(80) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE tb_produto;
CREATE TABLE tb_produto(
    id int(11) NOT NULL AUTO_INCREMENT,
    id_emp int(11) DEFAULT NULL,
    descricao varchar(80) NOT NULL,
    estoque double DEFAULT 0,
    estq_min double DEFAULT 0,
    und varchar(10) DEFAULT "UND",
    ncm varchar(8) DEFAULT NULL,
	cod_int int(11) DEFAULT NULL,
    cod_bar varchar(15) DEFAULT NULL,
    cod_forn varchar(20) DEFAULT NULL,
    consumo BOOLEAN DEFAULT 0,
    custo double DEFAULT 0,
    markup double DEFAULT 0,
    local varchar(20),
    UNIQUE KEY (descricao),
    FOREIGN KEY (id_emp) REFERENCES tb_empresa(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE tb_prod_reserva;
CREATE TABLE tb_prod_reserva(
    id_prod int(11) NOT NULL AUTO_INCREMENT,
    id_proj int(11) NOT NULL,
    id_user int(11) NOT NULL,
    qtd double DEFAULT 0,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pago BOOLEAN DEFAULT 0,
    FOREIGN KEY (id_prod) REFERENCES tb_produto(id),
    FOREIGN KEY (id_proj) REFERENCES tb_projeto(id),
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id),
    PRIMARY KEY (id_prod,id_proj)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tb_pcp_2;
CREATE TABLE tb_pcp_2 (
  data_serv date NOT NULL,
  id_setor int(11) NOT NULL,
  valor varchar(300) DEFAULT NULL,
  FOREIGN KEY (id_setor) REFERENCES tb_setor(id),
  PRIMARY KEY (data_serv,id_setor)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;