create database unibg;
use unibg;

-- Criando as tabelas
CREATE TABLE voluntarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(11) NOT NULL,
    endereco TEXT,
    imagem VARCHAR(255),
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ong (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    descricao TEXT,
    endereco TEXT,
    responsavel VARCHAR(100) NOT NULL,
    imagem VARCHAR(255),
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE acao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    imagem VARCHAR(255),
    ong_id INT,
    FOREIGN KEY (ong_id) REFERENCES ong(id) ON DELETE SET NULL
);

-- Criando a tabela de inscrições, que relaciona voluntários e ações
CREATE TABLE inscricoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    voluntario_id INT NOT NULL,
    acao_id INT NOT NULL,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (voluntario_id) REFERENCES voluntarios(id) ON DELETE CASCADE,
    FOREIGN KEY (acao_id) REFERENCES acao(id) ON DELETE CASCADE
);

-- Inserindo dados
INSERT INTO voluntarios (nome, email, senha, cpf, telefone, endereco, imagem) 
VALUES 
('João Silva', 'joao@email.com', 'senha123', '123.456.789-00', '11987654321', 'Rua das Flores, 123 - SP', 'joao.jpg'),
('Maria Oliveira', 'maria@email.com', 'senha456', '987.654.321-00', '11976543210', 'Av. Paulista, 456 - SP', 'maria.jpg');

INSERT INTO ong (nome, email, senha, cnpj, descricao, endereco, responsavel, imagem) 
VALUES 
('Amigos da Natureza', 'contato@amigosnatureza.org', 'ongsenha123', '12.345.678/0001-99', 'ONG focada na preservação ambiental.', 'Rua Verde, 100 - RJ', 'Carlos Mendes', 'amigos_natureza.jpg'),
('Cuidar é Amar', 'contato@cuidareamar.org', 'ongsenha456', '98.765.432/0001-11', 'ONG que ajuda pessoas em situação de rua.', 'Av. Central, 200 - SP', 'Ana Souza', 'cuidar_amar.jpg');

INSERT INTO acao (nome, imagem, ong_id) 
VALUES 
('Mutirão de Reflorestamento', 'reflorestamento.jpg', 1),
('Distribuição de Alimentos', 'alimentos.jpg', 2);

-- Inserindo inscrições de voluntários em ações
INSERT INTO inscricoes (voluntario_id, acao_id) 
VALUES 
(1, 1),  -- João Silva se inscreveu no Mutirão de Reflorestamento
(2, 2);  -- Maria Oliveira se inscreveu na Distribuição de Alimentos

-- Criando funções
-- Função para verificar login de voluntário
DELIMITER //
CREATE FUNCTION verificar_login_voluntario(email_input VARCHAR(100), senha_input VARCHAR(255)) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_id INT;
    SELECT id INTO v_id FROM voluntarios WHERE email = email_input AND senha = senha_input;
    RETURN v_id;
END;
//

-- Função para verificar login de ONG
CREATE FUNCTION verificar_login_ong(email_input VARCHAR(100), senha_input VARCHAR(255)) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_id INT;
    SELECT id INTO v_id FROM ong WHERE email = email_input AND senha = senha_input;
    RETURN v_id;
END;
//

-- Função para contar o número total de voluntários
CREATE FUNCTION contar_voluntarios() 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM voluntarios;
    RETURN total;
END;
//

-- Função para contar o número total de ONGs
CREATE FUNCTION contar_ongs() 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM ong;
    RETURN total;
END;
//

-- Função para contar o número de ações registradas por uma ONG
CREATE FUNCTION contar_acoes_ong(ong_id_input INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM acao WHERE ong_id = ong_id_input;
    RETURN total;
END;
//
DELIMITER ;

-- Criando views
-- View para listar todos os voluntários com informações relevantes
CREATE VIEW view_voluntarios AS
SELECT id, nome, email, cpf, telefone, endereco, data_registro
FROM voluntarios;

-- View para listar todas as ONGs registradas
CREATE VIEW view_ongs AS
SELECT id, nome, email, cnpj, responsavel, descricao, endereco, data_registro
FROM ong;

-- View para listar todas as ações e suas respectivas ONGs
CREATE VIEW view_acoes AS
SELECT acao.id, acao.nome AS nome_acao, acao.imagem, ong.nome AS nome_ong
FROM acao
LEFT JOIN ong ON acao.ong_id = ong.id;

-- View para exibir a quantidade de ações cadastradas por cada ONG
CREATE VIEW view_qtd_acoes_ong AS
SELECT ong.id, ong.nome AS nome_ong, COUNT(acao.id) AS total_acoes
FROM ong
LEFT JOIN acao ON ong.id = acao.ong_id
GROUP BY ong.id, ong.nome;

-- View para listar os voluntários e associar as ONGs com a quantidade de ações
CREATE VIEW view_voluntarios_ongs AS
SELECT voluntarios.nome AS nome_voluntario, voluntarios.email, voluntarios.telefone, 
       (SELECT COUNT(*) FROM acao WHERE acao.ong_id = ong.id) AS total_acoes_ong,
       ong.nome AS nome_ong
FROM voluntarios
CROSS JOIN ong;
