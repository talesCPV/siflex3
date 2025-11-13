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
    nome VARCHAR(80) NOT NULL DEFAULT "",
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
    reg VARCHAR(5) DEFAULT "0",
    nick VARCHAR(20) DEFAULT "",
    PRIMARY KEY (id),
    FOREIGN KEY (id_setor) REFERENCES tb_setores(id),
    FOREIGN KEY (id_cargo) REFERENCES tb_cargos(id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8; 
 
  DROP TABLE tb_func_setor;
CREATE TABLE tb_func_setor (
    id_func int(11) NOT NULL,
    id_setor int(11) NOT NULL,
    PRIMARY KEY (id_func,id_setor),
    FOREIGN KEY (id_setor) REFERENCES tb_setores(id),
    FOREIGN KEY (id_func) REFERENCES tb_funcionario(id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8; 
 
 -- ALTER TABLE tb_funcionario ADD COLUMN nick VARCHAR(20) DEFAULT "";
 ALTER TABLE tb_funcionario MODIFY COLUMN nome VARCHAR(80) NOT NULL DEFAULT "";
 
--  DROP TABLE tb_relogio_ponto;
CREATE TABLE tb_relogio_ponto (
	id int(11) NOT NULL AUTO_INCREMENT,
    id_func int(11) NOT NULL,
    entrada datetime NOT NULL,
    saida datetime NOT NULL,
    FOREIGN KEY (id_func) REFERENCES tb_funcionario(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
 
 
--  DROP TABLE tb_ferias;
CREATE TABLE tb_ferias (
	id int(11) NOT NULL AUTO_INCREMENT,
    id_func int(11) NOT NULL,
    saida date NOT NULL,
    volta date NOT NULL,
    obs varchar(255) DEFAULT NULL,
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

 DROP TABLE IF EXISTS tb_mail;
CREATE TABLE tb_mail (
	data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_from int(11) NOT NULL,
    id_to int(11) NOT NULL,
    message varchar(1000),
    looked boolean DEFAULT 0,
    FOREIGN KEY (id_from) REFERENCES tb_usuario(id),
    FOREIGN KEY (id_to) REFERENCES tb_usuario(id),
    PRIMARY KEY (data,id_from,id_to)
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

DROP TABLE tb_epi;
CREATE TABLE tb_epi(
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(80) NOT NULL,
    marca varchar(50) NOT NULL,
    estq double DEFAULT 0,
    estq_min double DEFAULT 0,
    und varchar(10) DEFAULT "UND",
    cod_bar varchar(15) DEFAULT NULL,
    num_ca varchar(20) DEFAULT "",
    local varchar(20) DEFAULT NULL,
    UNIQUE KEY (nome),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE tb_func_epi;
CREATE TABLE tb_func_epi(
    id_func int(11) NOT NULL,
    id_epi int(11) NOT NULL,
    qtd int DEFAULT 1,
    data datetime DEFAULT current_timestamp,
    FOREIGN KEY (id_func) REFERENCES tb_funcionario(id),
    FOREIGN KEY (id_epi) REFERENCES tb_epi(id),
    PRIMARY KEY (id_func,id_epi,data)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* Processo */

-- DROP TABLE tb_processo;
CREATE TABLE tb_processo (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    UNIQUE (nome),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_etapa_proc;
CREATE TABLE tb_etapa_proc (
    id int(11) NOT NULL AUTO_INCREMENT,
    id_processo int(11) NOT NULL,
    id_setor int(11),
    descricao varchar(255) NOT NULL,
    FOREIGN KEY (id_processo) REFERENCES tb_processo(id),
    FOREIGN KEY (id_setor) REFERENCES tb_setor(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_os;
CREATE TABLE tb_os (
    id int(11) NOT NULL AUTO_INCREMENT,
    id_proc int(11) NOT NULL,
    id_emp int(11) NOT NULL,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_entrega date DEFAULT NULL,
    obs varchar(255) DEFAULT NULL,
    aberta BOOLEAN DEFAULT 1,
    FOREIGN KEY (id_proc) REFERENCES tb_processo(id),
    FOREIGN KEY (id_emp) REFERENCES tb_empresa(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- ALTER TABLE tb_os ADD COLUMN aberta BOOLEAN DEFAULT 1;

 DROP TABLE tb_apontamento;
CREATE TABLE tb_apontamento (
    id_os int(11) NOT NULL,
    id_etapa int(11) NOT NULL,
    id_func int(11) NOT NULL,
    exec BOOLEAN DEFAULT 1,
    obs varchar(255) DEFAULT NULL,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_os) REFERENCES tb_os(id),
    FOREIGN KEY (id_etapa) REFERENCES tb_etapa_proc(id),
    FOREIGN KEY (id_func) REFERENCES tb_funcionario(id),
    PRIMARY KEY (id_os,id_etapa)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

INSERT INTO tb_apontamento (id_os,id_etapa,id_func) VALUES (2,9,1);

 DROP TABLE tb_sanf_onibus;
CREATE TABLE tb_sanf_onibus (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(120) NOT NULL,
    marca varchar(60) NOT NULL,
    modelo varchar(60) NOT NULL,
    chassi varchar(30) NOT NULL,
    ano varchar(4) NOT NULL,
    qtd_barras int NOT NULL DEFAULT 0,
    qtd_dob_teto int NOT NULL DEFAULT 0,
    qtd_dob_chao int NOT NULL DEFAULT 0,
    alt double NOT NULL DEFAULT 0,
    larg double NOT NULL DEFAULT 0,
    alt_teto double NOT NULL DEFAULT 0,
    alt_lateral double NOT NULL DEFAULT 0,
    larg_teto  double NOT NULL DEFAULT 0,
    alt_sanf double NOT NULL DEFAULT 0,
    alt_sanf_cost double NOT NULL DEFAULT 0,
    larg_sanf double NOT NULL DEFAULT 0,
    topo_sanf double NOT NULL DEFAULT 0,
    base_sanf double NOT NULL DEFAULT 0,
    larg_corredor double NOT NULL DEFAULT 0,
    larg_chao double NOT NULL DEFAULT 0,
    dist_carro double NOT NULL DEFAULT 0,
    obs varchar(1024) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* FINANCEIRO */

 DROP TABLE tb_contas_a_pagar;
CREATE TABLE tb_contas_a_pagar (
    id int(11) NOT NULL AUTO_INCREMENT,
    id_cli int(11) DEFAULT NULL,
    nome varchar(60) NOT NULL,
    beneficiario varchar(128) DEFAULT NULL,
    venc date NOT NULL,
    valor double NOT NULL,
    cod_pgto varchar(512) NOT NULL,
    pgto bool NOT NULL DEFAULT 0,
    pgto_dia date DEFAULT NULL,
    tipo varchar(8) DEFAULT "BOLETO",
    obs varchar(256) DEFAULT NULL,
    centro_custo varchar(20) DEFAULT "INSUMOS",
    FOREIGN KEY (id_cli) REFERENCES tb_empresa(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

ALTER TABLE tb_contas_a_pagar ADD COLUMN centro_custo varchar(20) DEFAULT "INSUMOS";

 DROP TABLE tb_receber;
CREATE TABLE tb_a_receber (
    id int(11) NOT NULL AUTO_INCREMENT,
    id_cli int(11) DEFAULT NULL,
    nome varchar(60) NOT NULL,
    beneficiario varchar(128) DEFAULT "FLEXIBUS SANFONADOS",
    venc date NOT NULL,
    valor double NOT NULL,
    cod_pgto varchar(512) DEFAULT NULL,
    pgto bool NOT NULL DEFAULT 0,
    pgto_dia date DEFAULT NULL,
    tipo varchar(8) DEFAULT "BOLETO",
    nf varchar(10) DEFAULT NULL,
    obs varchar(256) DEFAULT NULL,
    FOREIGN KEY (id_cli) REFERENCES tb_empresa(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_pix;
CREATE TABLE tb_pix (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(50) NOT NULL,
    cidade varchar(50) NOT NULL,
    chave varchar(512) NOT NULL,
    org_ref varchar(40) DEFAULT NULL,
    id_ref int(11) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* POSTS */

 DROP TABLE IF EXISTS tb_post;
CREATE TABLE tb_post(
	id int(11) unsigned NOT NULL AUTO_INCREMENT,
    id_user int(11) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    texto varchar(255),
    has_image boolean DEFAULT 0,
    likes int DEFAULT 0,
    views int DEFAULT 0,
    FOREIGN KEY (id) REFERENCES tb_usuario(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE IF EXISTS tb_post_message;
CREATE TABLE tb_post_message(
	id int(11) unsigned NOT NULL AUTO_INCREMENT,
    id_post int(11) NOT NULL,
	nome varchar(50) NOT NULL,
	empresa varchar(50) NOT NULL,    
	texto varchar(256) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (id_post) REFERENCES tb_post(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* FIM POSTS */

 DROP TABLE tb_boletos;
CREATE TABLE tb_boletos (
    cod_pgto int(11) NOT NULL,
    cliente varchar(25) NOT NULL,
    valor double NOT NULL,
    venc date NOT NULL,
    pgto date DEFAULT NULL,
    nf varchar(10) DEFAULT NULL,
    quitado boolean DEFAULT 0,
    PRIMARY KEY (cod_pgto)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;