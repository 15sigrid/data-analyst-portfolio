-- UrbanStyle, nädal 1, roll B: kliendiandmete uurimine

-- Samm 2: Mitu klienti on kokku?
SELECT COUNT(*) AS klientide_arv FROM customers;
-- Tulemus: 3150 rida

-- Samm 3: Millised veerud ja andmed tabelis on?
SELECT * FROM customers LIMIT 10;
-- Tulemus: 9 veergu. customer_id, first_name,  last_name, email, phone, city, registration_date, loyalty_tier, birth_year

-- Samm 4: Millised linnad on esindatud?
SELECT DISTINCT city FROM customers;
-- Tulemus: 54 rida. Sama linn on kirjas eri kujul (nt TALLINN, PAIDE, jõhvi), seega päris linnu on vähem.

-- Samm 5: Tallinna kliendid, sorteeritud perekonnanime järgi, 15 rida
SELECT customer_id, first_name, last_name, city, registration_date
FROM customers
WHERE city = 'Tallinn'
ORDER BY last_name ASC
LIMIT 15;
-- Tulemus: 15 esimest Tallinna klienti perekonnanime järgi.

-- Mitu Tallinna klienti (täpne kirjaviis 'Tallinn')?
SELECT COUNT(*) AS tallinna_kliente
FROM customers
WHERE city = 'Tallinn';
-- Tulemus: 1135 rida.

-- Mitu Tallinna klienti kõigi kirjaviisidega (lower teeb kõik väiketäheks)?
SELECT COUNT(*) AS tallinna_kliente
FROM customers
WHERE lower(city) = 'tallinn';
-- Tulemus: 1184 rida. 49 rida on muu kirjaviisiga (nt TALLINN, tallinn), seega city = 'Tallinn' jätab need välja.

-- Samm 6: Vanim ja uusim registreerimise kuupäev.
SELECT MIN(registration_date) AS vanim,
       MAX(registration_date) AS uusim
FROM customers;
-- Tulemus: vanim 2020-01-02, uusim 2025-02-27.

-- Samm 7: Mitmel kliendil puudub eesnimi?
SELECT COUNT(*) - COUNT(first_name) AS puuduvad_eesnimed
FROM customers;
-- Tulemus: 0. Eesnimi on kõigil olemas (skeem nõuab seda).

-- Mitmel kliendil puudub eesnimi (oma lisapäring: IS NULL näitab read, COUNT ainult arvu)
SELECT * FROM customers
WHERE first_name IS NULL;
-- Tulemus: 0. Eesnimi on kõigil olemas (skeem nõuab seda).

-- Mitmel real puudub e-post
SELECT COUNT(*) - COUNT(email) AS puuduvad_emailid
FROM customers;
-- Tulemus: e-post puudub 380 real

-- Read, kus e-post puudub (oma lisapäring: IS NULL näitab read, COUNT ainult arvu)
SELECT * FROM customers
WHERE email IS NULL;
-- Tulemus: e-post puudub 380 real

-- Edasijõudnud: Leia duplikaatsed e-mailid. Kontrolli, kas sama e-mail esineb mitu korda
SELECT COUNT(DISTINCT email) AS unikaalseid_e_poste
FROM customers;
-- Tulemus: 2640 erinevat emaili. Loeb iga emaili ühe korra, NULL-id ja kordused jäävad välja.

-- Edasijõudnud: Loe kliendid linnade kaupa kokku
SELECT city, COUNT(*) AS klientide_arv
FROM customers
GROUP BY city
ORDER BY klientide_arv DESC;
-- Tulemus: 54 rida, sest iga kirjaviis on eraldi grupp. Tallinn 1135, Tartu 607, Pärnu 310 (täpse kirjaviisiga).

-- Edasijõudnud: Kliendid, kes registreerusid alates 2024-07-01.
SELECT * FROM customers
WHERE registration_date >= '2024-07-01'
ORDER BY registration_date DESC;
-- Tulemus: 425 rida

-- Lisaks uurisin.

-- E-posti andmekvaliteet: puuduvad ja korduvad (3B lisaülesanne)
SELECT
    COUNT(*) AS ridu_kokku,
    COUNT(email) AS e_postiga,
    COUNT(DISTINCT email) AS unikaalseid_e_poste,
    COUNT(*) - COUNT(email) AS puudub_e_post,
    COUNT(email) - COUNT(DISTINCT email) AS korduvaid_ridu
FROM customers;
-- Tulemus: 3150 rida, 2770 e-postiga, 2640 unikaalset e-posti, 380 rida ilma e-postita, 130 rida korduva e-postiga.
-- Korduvad: COUNT(email) - COUNT(DISTINCT email). Töövihiku valem COUNT(*) - COUNT(DISTINCT email) loeks sisse ka 380 puuduvat e-posti ja annaks vale tulemuse.
-- Õppetund: puuduv koma veergude vahel annab süntaksivea. Viga on sõna ees, mida veateade näitab.