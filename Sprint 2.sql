-- - Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:

-- Llistat dels països que estan fent compres.	
SELECT DISTINCT country AS 'Llistat paisos'
FROM transaction
INNER JOIN company ON transaction.company_id=company.id;


-- Des de quants països es realitzen les compres.
SELECT count(distinct country) AS 'Numero paisos'
FROM transaction
INNER JOIN company ON transaction.company_id=company.id;


-- Identifica la companyia amb la mitjana més gran de vendes.

SELECT company_name, round(AVG(amount),2) AS 'Mitjana'
FROM company
INNER JOIN transaction ON company.id=transaction.company_id
WHERE declined = 0
GROUP BY company_name
ORDER BY Mitjana DESC
LIMIT 1;


-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE company_id IN (SELECT id FROM company WHERE country='Germany');

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT company_name
FROM company
WHERE id IN (SELECT company_id FROM transaction WHERE amount > (SELECT AVG(amount) FROM transaction));


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT company_name
FROM company
WHERE id NOT IN (SELECT company_id FROM transaction);

-- Nivell 2
-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp), SUM(amount) AS total_sales
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY total_sales DESC
LIMIT 5;

-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT country, round(AVG(amount),2) as mitjana
FROM transaction
INNER JOIN company ON transaction.company_id=company.id
WHERE declined = 0 
GROUP BY country
ORDER BY AVG(amount) DESC;

-- Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT *
FROM transaction
INNER JOIN company ON transaction.company_id=company.id
WHERE country = (select country FROM company WHERE company_name = 'Non Institute');

-- Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction
WHERE company_id IN (select id FROM company WHERE country = (SELECT country FROM company WHERE company_name = 'Non Institute'));

-- Nivell 3
-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i 
-- en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
SELECT company_name, phone, timestamp, amount
FROM transaction
INNER JOIN company ON transaction.company_id=company.id
WHERE (amount BETWEEN 100 AND 200) AND DATE(TIMESTAMP) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY amount DESC;

-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions 
-- que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT company_name, count(transaction.id),
CASE
	WHEN count(transaction.id) > 4 THEN 'Més de 4 transaccions'
	WHEN count(transaction.id) = 4 THEN '4 transaccions'
	WHEN count(transaction.id) < 4 THEN 'Menys de 4 transaccions'
END as clasificació
FROM transaction
LEFT JOIN company ON transaction.company_id=company.id 
GROUP BY company_name
ORDER BY count(transaction.id) DESC;