-- Criando o banco de dados
CREATE DATABASE unibg;
USE unibg;

-- Criando a tabela de usuários
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criando a tabela de voluntários (agora referenciando usuários)
CREATE TABLE voluntarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(11),
    endereco TEXT,
    imagem VARCHAR(255),
    usuario_id INT UNIQUE NOT NULL,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Criando a tabela de ONGs (agora referenciando usuários)
CREATE TABLE ong (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_ong VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    descricao TEXT,
    endereco TEXT,
    responsavel VARCHAR(100),
    imagem VARCHAR(255),
    usuario_id INT UNIQUE NOT NULL,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Criando a tabela de ações
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
-- Criando usuários
INSERT INTO usuarios (nome, email, senha) 
VALUES 
('João Silva', 'joao@email.com', 'senha123'),
('Maria Oliveira', 'maria@email.com', 'senha456'),
('Amigos da Natureza', 'contato@amigosnatureza.org', 'ongsenha123'),
('Cuidar é Amar', 'contato@cuidareamar.org', 'ongsenha456');

-- Criando voluntários vinculados aos usuários
INSERT INTO voluntarios (cpf, telefone, endereco, imagem, usuario_id) 
VALUES 
('123.456.789-00', '11987654321', 'Rua das Flores, 123 - SP', 'joao.jpg', 1),
('987.654.321-00', '11976543210', 'Av. Paulista, 456 - SP', 'maria.jpg', 2);

-- Criando ONGs vinculadas aos usuários
INSERT INTO ong (nome_ong, cnpj, descricao, endereco, responsavel, imagem, usuario_id) 
VALUES 
('Amigos da Natureza', '12.345.678/0001-99', 'ONG focada na preservação ambiental.', 'Rua Verde, 100 - RJ', 'Carlos Mendes', 'amigos_natureza.jpg', 3),
('Cuidar é Amar', '98.765.432/0001-11', 'ONG que ajuda pessoas em situação de rua.', 'Av. Central, 200 - SP', 'Ana Souza', 'cuidar_amar.jpg', 4);

-- Criando ações
INSERT INTO acao (nome, imagem, ong_id) 
VALUES 
('Mutirão de Reflorestamento', 'reflorestamento.jpg', 1),
('Distribuição de Alimentos', 'alimentos.jpg', 2);

-- Inserindo inscrições de voluntários em ações
INSERT INTO inscricoes (voluntario_id, acao_id) 
VALUES 
(1, 1),  -- João Silva se inscreveu no Mutirão de Reflorestamento
(2, 2);  -- Maria Oliveira se inscreveu na Distribuição de Alimentos

-- Criando funções para os usuários

-- Função para verificar login de usuário
DELIMITER //
CREATE FUNCTION verificar_login_usuario(email_input VARCHAR(100), senha_input VARCHAR(255)) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_id INT;
    SELECT id INTO v_id FROM usuarios WHERE email = email_input AND senha = senha_input;
    RETURN v_id;
END;
//

-- Função para contar o número total de usuários
CREATE FUNCTION contar_usuarios() 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM usuarios;
    RETURN total;
END;
//

-- Função para obter os dados do usuário (usado para login ou consulta)
CREATE FUNCTION obter_dados_usuario(usuario_id_input INT) 
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE usuario_dados VARCHAR(255);
    SELECT CONCAT(nome, ' | ', email) INTO usuario_dados FROM usuarios WHERE id = usuario_id_input;
    RETURN usuario_dados;
END;
//

-- Função para verificar se o email já está registrado
CREATE FUNCTION verificar_email_existe(email_input VARCHAR(100)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe INT;
    SELECT COUNT(*) INTO existe FROM usuarios WHERE email = email_input;
    RETURN existe > 0;
END;
//
DELIMITER ;

-- Criando views para usuários

-- View para listar todos os usuários com informações relevantes
CREATE VIEW view_usuarios AS
SELECT id, nome, email, data_registro
FROM usuarios;

-- View para listar todos os voluntários com informações relevantes
CREATE VIEW view_voluntarios AS
SELECT v.id, u.nome, u.email, v.cpf, v.telefone, v.endereco, v.data_registro
FROM voluntarios v
JOIN usuarios u ON v.usuario_id = u.id;

-- View para listar todas as ONGs registradas
CREATE VIEW view_ongs AS
SELECT o.id, u.nome AS nome_responsavel, o.nome_ong, o.cnpj, o.responsavel, o.descricao, o.endereco, o.data_registro
FROM ong o
JOIN usuarios u ON o.usuario_id = u.id;

-- View para listar todas as ações e suas respectivas ONGs
CREATE VIEW view_acoes AS
SELECT acao.id, acao.nome AS nome_acao, acao.imagem, ong.nome_ong AS nome_ong
FROM acao
LEFT JOIN ong ON acao.ong_id = ong.id;

-- View para exibir a quantidade de ações cadastradas por cada ONG
CREATE VIEW view_qtd_acoes_ong AS
SELECT ong.id, ong.nome_ong, COUNT(acao.id) AS total_acoes
FROM ong
LEFT JOIN acao ON ong.id = acao.ong_id
GROUP BY ong.id, ong.nome_ong;

-- View para listar os voluntários e associar as ONGs com a quantidade de ações
CREATE VIEW view_voluntarios_ongs AS
SELECT v.id, u.nome AS nome_voluntario, u.email, v.telefone, 
       (SELECT COUNT(*) FROM acao WHERE acao.ong_id = o.id) AS total_acoes_ong,
       o.nome_ong
FROM voluntarios v
JOIN usuarios u ON v.usuario_id = u.id
CROSS JOIN ong o;
