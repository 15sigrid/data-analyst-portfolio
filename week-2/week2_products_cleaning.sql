-- Tooteandmete Puhastamine
-- Tooteandmete puhastaja (roll C) (Product Data Cleaner)
-- Samm 1. Loo test koopia:
DROP TABLE IF EXISTS products_test;              -- viska vana koopia ära, kui see on olemas
CREATE TABLE products_test AS SELECT * FROM products;  -- tee värske koopia
SELECT COUNT(*) AS ridade_arv FROM products_test;      -- kontroll: mitu rida?
-- Tulemus: 362 rida (sama mis products). RLS lubatud.

--Samm 2. Leia duplikaadid — kas on korduvaid tootenimesid?
SELECT product_name, COUNT(*) AS koopiate_arv
FROM products_test
GROUP BY product_name
HAVING COUNT(*) > 1
ORDER BY koopiate_arv DESC;
-- Tulemus: 12 tootenime esineb 2 korda = 12 liigset rida. Koopiad on ID-dega 1351–1362.

-- Samm 3. Leia NULL väärtused kriitilistes väljades:
SELECT
    COUNT(*) FILTER (WHERE product_name IS NULL OR product_name = '') AS null_nimi,
    COUNT(*) FILTER (WHERE category IS NULL OR category = '') AS null_kategooria,
    COUNT(*) FILTER (WHERE retail_price IS NULL) AS null_jaehind,
    COUNT(*) FILTER (WHERE cost_price IS NULL) AS null_omahind
FROM products_test;
-- Tulemus: null_nimi: 0, null_kategooria: 0, null_jaehind: 0, null_omahind: 0
-- FILTER (WHERE ...) loeb ainult need read, mis tingimusele vastavad. 
-- OR product_name = '' kontrollib ka tühja teksti, mitte ainult NULL-i.

-- Samm 4. Kontrolli loogilisi vigu — kas on ebareaalseid hindu?
-- a) Kas on negatiivseid hindu? 
SELECT COUNT(*) AS negatiivne_hind
FROM products_test
WHERE retail_price < 0;

-- b) Kas on äärmuslikke hindu (> 1000€)?
SELECT product_name, retail_price
FROM products_test
WHERE retail_price > 1000
ORDER BY retail_price DESC;
-- Tulemus: 0 negatiivset ja 0 äärmuslikku jaehinda (a,b).

-- Kontroll_1
SELECT MAX(retail_price) AS kalleim FROM products_test;
-- Tulemus: kalleim hind 434.08 < 1000, seega 0 äärmuslikku hinda on õige (päring töötab, andmed puhtad).

-- Kontroll_2
SELECT product_name, cost_price, retail_price
FROM products_test
WHERE retail_price < cost_price
ORDER BY retail_price DESC;
-- Tulemus: 10 rida, kus jaehind < omahind (müük kahjumiga). Neist 2 on duplikaadid,
-- Lisaleid: Seega 8 erinevat toodet. Kaardil seda kontrolli ei ole. Vajab ärilist kontrolli.

-- Samm 5. Kontrolli kategooriate järjekindlust:
SELECT category, COUNT(*) AS arv
FROM products_test
GROUP BY category
ORDER BY category;
-- Tulemus: aksessuaarid - 67, jalanõusid - 73, laste_riided - 70, meeste_riided - 82, naiste_riided - 70. Kokku: 67+73+70+82+70=362.
-- Kõik 5 kategooriat on välja toodud, erinevaid kirjaviise ega muud erinevat kategooria väärtust ei esine.

-- Kontroll: veerg - eco_certified
SELECT eco_certified, COUNT(*) AS arv
FROM products_test
GROUP BY eco_certified
ORDER BY eco_certified;
-- Tulemus: false (sertifikaat puudub) 242, true (olemas) 102, NULL (teadmata) 18. Kokku: 242+102+18=362.
-- NULL ≠ false: 18 toote puhul pole teada, kas sertifikaat on. Lisaleid, kaardil seda pole.
-- Äriliselt on see oluline: kui UrbanStyle teeb reklaami „X% toodetest on öko“, siis need 18 jäävad arvestusest välja ja number võib olla vale.

-- =============================================
-- EDASIJÕUDNUTE TASE (vabatahtlik)
-- =============================================

-- A. Kategooriate ühtlustamine INITCAP-iga

-- Katse 1:
UPDATE products_test
SET category = INITCAP(TRIM(category))
WHERE category != INITCAP(TRIM(category));
-- Tulemus: 0 rida. UPDATE oli juba varem käivitatud, seega polnud midagi muuta.
-- Lähtestasin testkoopia ja kordasin õiges järjekorras (eelvaade -> UPDATE -> kontroll).

-- Lähtestan testkoopia
DROP TABLE IF EXISTS products_test;                     -- viska vana koopia ära
CREATE TABLE products_test AS SELECT * FROM products;   -- tee värske koopia
SELECT COUNT(*) AS ridade_arv FROM products_test;       -- kontroll
-- Tulemus: 362 rida. Lähtestamine õnnestus.

-- Katse 2, eelvaade 1: mitu rida UPDATE muudaks?
SELECT COUNT(*) AS muutuks
FROM products_test
WHERE category != INITCAP(TRIM(category));
-- Tulemus: 362 rida muutuks (kõik kategooriad on väiketähtedega).

-- Katse 2, eelvaade 2: milliseks kategooriad muutuksid?
SELECT DISTINCT category, INITCAP(TRIM(category)) AS uus_kuju
FROM products_test;
-- Tulemus: 5 kategooriat, nt aksessuaarid -> Aksessuaarid. Tabel veel muutmata.

-- Katse 2: UPDATE
UPDATE products_test
SET category = INITCAP(TRIM(category))
WHERE category != INITCAP(TRIM(category));
-- Tulemus: UPDATE käivitatud ("No rows returned" on UPDATE-i puhul normaalne).

-- Katse 2: kontroll
SELECT category, COUNT(*) AS arv
FROM products_test
GROUP BY category
ORDER BY category;
-- Tulemus: 5 kategooriat suure algustähega, arvud samad (kokku 362). UPDATE õnnestus.

-- B. Kategooriate tõlkimine inglise keelde (CASE WHEN)

-- Eelvaade: milliseks kategooriad muutuksid?
SELECT DISTINCT category,
    CASE
        WHEN LOWER(TRIM(category)) IN ('meeste_riided') THEN 'Menswear'
        WHEN LOWER(TRIM(category)) IN ('naiste_riided') THEN 'Womenswear'
        WHEN LOWER(TRIM(category)) IN ('laste_riided') THEN 'Kidswear'
        WHEN LOWER(TRIM(category)) IN ('jalanõusid') THEN 'Footwear'
        WHEN LOWER(TRIM(category)) IN ('aksessuaarid') THEN 'Accessories'
        ELSE INITCAP(TRIM(category))
    END AS uus_kategooria
FROM products_test;
-- Tulemus: kõik 5 said ingliskeelse vaste. Tabel veel muutmata.
-- LOWER teeb võrdluse ajaks tähed väikeseks (Meeste_riided -> meeste_riided), seega vaste leitakse kirjaviisist sõltumata.
-- LOWER = kõik väikeseks, UPPER = kõik suureks, INITCAP = esimene täht suureks.

-- UPDATE
UPDATE products_test
SET category = CASE
    WHEN LOWER(TRIM(category)) IN ('meeste_riided') THEN 'Menswear'
    WHEN LOWER(TRIM(category)) IN ('naiste_riided') THEN 'Womenswear'
    WHEN LOWER(TRIM(category)) IN ('laste_riided') THEN 'Kidswear'
    WHEN LOWER(TRIM(category)) IN ('jalanõusid') THEN 'Footwear'
    WHEN LOWER(TRIM(category)) IN ('aksessuaarid') THEN 'Accessories'
    ELSE INITCAP(TRIM(category))
END;
-- Tulemus: UPDATE käivitatud, kõik 362 rida muudetud (WHERE puudub).

-- Kontroll
SELECT category, COUNT(*) AS arv
FROM products_test
GROUP BY category
ORDER BY category;
-- Tulemus: 5 ingliskeelset kategooriat, arvud samad (kokku 362). UPDATE õnnestus.
-- NB: muudetud ainult products_test. Originaaltabel products on muutmata.