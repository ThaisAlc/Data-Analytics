-- Nivell 1
-- Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
create table credit_card (
	id varchar(15) PRIMARY KEY,
    iban varchar(50),
    pan varchar(20),
    pin varchar(4),
    cvv int,
    expiring_date varchar(10),
    INDEX(id)
);

ALTER TABLE transaction 
ADD CONSTRAINT FK_credit_card FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Exercici 2
-- El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

-- Exercici 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ('b-9999', 'Barcelona Activa', '900 533 175', 'info@barcelonactiva.cat', 'Spain', 'https://www.barcelonactiva.cat/');

INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) 
VALUES ('CcU-9999', 'TR301950312213576817638662', '5424465566813634', '3258', '985', '10/30/23');

INSERT INTO transaction (id,credit_card_id,company_id,user_id,lat,longitude,amount,declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,829.999,-117.999,111.11,0);


-- Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card DROP COLUMN pan;

SELECT *
FROM credit_card;

-- Nivell 2
-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
DELETE FROM transaction WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT *
FROM transaction
WHERE id='02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies 
-- i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra 
-- realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
-- CREATE VIEW 'vistamarketing' AS
SELECT company_name, phone, country, round(AVG(amount),2) AS 'Mitjana'
FROM company AS c
LEFT JOIN transaction AS t ON c.id=t.company_id
GROUP BY company_name, phone, country;

SELECT * 
FROM vistamarketing
ORDER BY Mitjana DESC;

-- Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT * 
FROM vistamarketing
WHERE country = 'Germany';

-- Nivell 3
-- Exercici 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:
CREATE INDEX idx_user_id ON transaction(user_id);
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );

ALTER TABLE user RENAME TO data_user;

ALTER TABLE data_user
CHANGE email personal_email VARCHAR(150);


ALTER TABLE company
DROP COLUMN website;

ALTER TABLE transaction
DROP FOREIGN KEY FK_credit_card;

ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);

ALTER TABLE credit_card
ADD fecha_actual DATE;

-- Exercici 2
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- •	ID de la transacció
-- •	Nom de l'usuari/ària
-- •	Cognom de l'usuari/ària
-- •	IBAN de la targeta de crèdit usada.
-- •	Nom de la companyia de la transacció realitzada.
-- •	Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

-- CREATE VIEW `informe tecnico` AS
SELECT t.id AS "ID de la transacció", u.name AS "Nom de l'usuari/ària", u.surname AS "Cognom de l'usuari/ària", cc.iban AS "IBAN de la targeta de crèdit usada.", c.company_name AS "Nom de la companyia de la transacció realitzada."
FROM transaction AS t
LEFT JOIN data_user AS u ON u.id=t.user_id
LEFT JOIN credit_card AS cc ON cc.id=t.credit_card_id
LEFT JOIN company AS c ON c.id=t.company_id;

SELECT *
FROM informetecnico
ORDER BY 'ID de la transacció' DESC;



