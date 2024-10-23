-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis 
-- realitzar les següents consultes:
    
CREATE DATABASE IF NOT EXISTS sprint4;
USE sprint4;

SHOW VARIABLES LIKE 'secure_file_priv';
show variables like "local_infile";
set global local_infile = 1;

CREATE TABLE users_ca (
	id int PRIMARY KEY,
	name VARCHAR(20),
	surname VARCHAR(20),
	phone VARCHAR(30),
	email VARCHAR(50),
	birth_date VARCHAR(20),
	country VARCHAR(20),
	city VARCHAR(30),
	postal_code VARCHAR(15),
	address VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\users_ca.csv' INTO TABLE users_ca
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE users_uk (
	id int PRIMARY KEY,
	name VARCHAR(20),
	surname VARCHAR(20),
	phone VARCHAR(30),
	email VARCHAR(50),
	birth_date VARCHAR(20),
	country VARCHAR(20),
	city VARCHAR(30),
	postal_code VARCHAR(15),
	address VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\users_uk.csv' INTO TABLE users_uk
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE users_usa (
	id int PRIMARY KEY,
	name VARCHAR(20),
	surname VARCHAR(20),
	phone VARCHAR(30),
	email VARCHAR(50),
	birth_date VARCHAR(20),
	country VARCHAR(20),
	city VARCHAR(30),
	postal_code VARCHAR(15),
	address VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\users_usa.csv' INTO TABLE users_usa
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

CREATE TABLE users AS 
SELECT * FROM users_usa
UNION ALL
SELECT * FROM users_uk
UNION ALL
SELECT * FROM users_ca;

ALTER TABLE users
ADD PRIMARY KEY (id);

ALTER TABLE users
MODIFY birth_date DATE;

UPDATE users
SET birth_date = DATE_FORMAT(birth_date, '%b %e, %Y');

select *
from users;

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE credit_cards (
	id VARCHAR(20) PRIMARY KEY,
	user_id int, 
	iban VARCHAR(50),
	pan VARCHAR(20),
	pin VARCHAR(4),
	cvv VARCHAR(4),
	track1 VARCHAR(100),
	track2 VARCHAR(100),
	expiring_date VARCHAR(10)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\credit_cards.csv' INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

CREATE TABLE companies (
	company_id VARCHAR(20) PRIMARY KEY,
	company_name VARCHAR(50),
	phone VARCHAR(20),
	email VARCHAR(100),
	country VARCHAR(20),
	website VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\companies.csv' INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

CREATE TABLE transactions (
	id VARCHAR(100) PRIMARY KEY,
	card_id VARCHAR(20),
	business_id VARCHAR(20),
	timestamp TIMESTAMP,
	amount decimal(10,2),
	declined tinyint,
    product_ids VARCHAR(20),
    user_id int, 
    lat FLOAT,
    longitude FLOAT,
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\transactions.csv' INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- - Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT u.id, u.name, u.surname, count(t.id) AS 'Num.transaccions'
FROM transactions AS t
LEFT JOIN users AS u ON t.user_id = u.id
GROUP BY u.id
HAVING count('Num.transaccions') > 30;

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT c.company_name, cc.iban, round(avg(t.amount),2) AS 'Mitjana.import'
FROM transactions AS t
LEFT JOIN companies AS c ON t.business_id = c.company_id
LEFT JOIN credit_cards AS cc ON t.card_id = cc.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;


-- Nivell 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
SELECT card_id, timestamp, declined
FROM  (
   SELECT row_number() OVER (PARTITION BY card_id ORDER BY timestamp desc
                             ROWS UNBOUNDED PRECEDING) AS num_compres
        , card_id, timestamp, declined
   FROM   transactions
   ) sub
WHERE  num_compres <= 3;

-- Exercici 1
-- Quantes targetes estan actives?
SELECT count(card_id) AS 'total targetes', estat
FROM (
    SELECT card_id,
        CASE
            WHEN SUM(declined = 1) < 3 THEN 'Activada'
            WHEN SUM(declined = 1) = 3 THEN 'Desactivada'
        END as estat
    FROM (
        SELECT row_number() OVER (PARTITION BY card_id ORDER BY timestamp desc) AS num_compres,
               card_id, timestamp, declined
        FROM transactions
    ) sub
    WHERE num_compres <= 3
    GROUP BY card_id
) sub2
LEFT JOIN credit_cards AS cc ON sub2.card_id = cc.id
WHERE estat = 'Activada';


-- Nivell 3
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. 
-- Genera la següent consulta:
CREATE TABLE products (
	id VARCHAR(20) PRIMARY KEY,
	product_name VARCHAR(100),
	price VARCHAR(10),
	colour VARCHAR(15),
	weight DECIMAL(3,2),
	warehouse_id VARCHAR(10)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\thais\\OneDrive\\Documentos\\MYSQL\\products.csv' INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

UPDATE products
SET price = REPLACE(price, '$','');

ALTER TABLE products
MODIFY price DECIMAL(10,2);

SELECT
  *,
  SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', Num_productes.r), ',', -1) product_id_indiv
FROM
  (SELECT 1 r UNION ALL SELECT 2
   UNION ALL SELECT 3 UNION ALL SELECT 4) Num_productes INNER JOIN transactions
  ON CHAR_LENGTH(product_ids)
     -CHAR_LENGTH(REPLACE(product_ids, ',', ''))>=Num_productes.r-1;
     
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT
  sub.product_id_indiv, p.product_name,
  COUNT(sub.product_ids) as total_vendes
FROM (
  SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', Num_productes.r), ',', -1) as product_id_indiv,
    transactions.product_ids, declined
  FROM
    (SELECT 1 r UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) Num_productes
  INNER JOIN transactions
    ON CHAR_LENGTH(product_ids) - CHAR_LENGTH(REPLACE(product_ids, ',', '')) >= Num_productes.r - 1
) sub
JOIN products p ON p.id = sub.product_id_indiv
WHERE declined=0
GROUP BY sub.product_id_indiv
ORDER BY sub.product_id_indiv;
