-- =====================================================================
-- DACA Nädal 2 · Toomase puhastamisraport (süntees)
-- Autor: Sigrid Nieländer
-- Andmed: UrbanStyle (sales, customers, products), Supabase
-- NB: raport ainult kirjeldab, midagi ei kustutata ega muudeta
-- =====================================================================


-- =====================================================================
-- OSA A · LEARNI RAPORT: kolm probleemi ühel real
-- =====================================================================
-- Iga arv on oma väike päring sulgudes, suur SELECT paneb need kõrvuti
SELECT
    (SELECT COUNT(*) - COUNT(DISTINCT invoice_id) FROM sales)      AS koopiad,            -- read miinus päris arved
    (SELECT COUNT(*) FROM customers WHERE email IS NULL)          AS email_puudub,       -- IS NULL, mitte = NULL
    (SELECT COUNT(*) FROM sales WHERE sale_date > '2025-02-28')   AS vigased_kuupaevad;  -- hilisem kui andmete lõpp
-- Tulemus: 5116 koopiat | 380 e-postita klienti | 50 vigast kuupäeva

-- Vigaste kuupäevade märkus:
-- Allikas: kursuse materjal (N02 slaid, N02_050) – 2025-02-28 = müügiandmete lõpp
-- Loogika: andmed võeti välja 28.02.2025, seega hilisemat müüki ei saa olla
-- Vigaseid ridu ei kustuta ega paranda: jäävad tabelisse, analüüsist välja filtriga
-- Avatud küsimus ärile: kas andmed lõpevad tõesti 28.02.2025?


-- =====================================================================
-- OSA B · TÖÖVIHIKU SÜNTEES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Päring 1 · Duplikaatide kokkuvõte kõigis tabelites (töövihiku mall)
-- ---------------------------------------------------------------------
-- UNION ALL paneb kolme tabeli tulemused üksteise alla ühte tabelisse
SELECT 'sales' AS tabel,
    COUNT(*) AS ridu_kokku,
    COUNT(DISTINCT sale_id) AS unikaalseid,
    COUNT(*) - COUNT(DISTINCT sale_id) AS duplikaate
FROM sales
UNION ALL
SELECT 'customers',
    COUNT(*),
    COUNT(DISTINCT email),
    -- COUNT(DISTINCT) jätab NULL-id vahele, seega loetaks e-postita klient
    -- duplikaadiks. Lahutame need maha: õige arv on 130, mitte 510.
    COUNT(*) - COUNT(DISTINCT email) - COUNT(*) FILTER (WHERE email IS NULL)
FROM customers
UNION ALL
SELECT 'products',
    COUNT(*),
    COUNT(DISTINCT product_name),
    -- koopiatel on uus product_id, aga sama nimi: loeme nime järgi
    COUNT(*) - COUNT(DISTINCT product_name)
FROM products;
-- Tulemus:
--   sales      15234 | 10118 | 5116
--   customers   3150 |  2640 |  130
--   products     362 |   350 |   12
-- Toomase jaoks: "Kokku leidsime 5258 duplikaati kolmes tabelis."
-- (5116 + 130 + 12 = 5258)


-- ---------------------------------------------------------------------
-- Päring 2 · NULL väärtuste raport
-- ---------------------------------------------------------------------
-- COUNT(*) loeb kõik read, COUNT(veerg) ainult täidetud read
-- Vahe = mitu väärtust puudub (NULL)
SELECT 'sales' AS tabel,
    COUNT(*)                        AS ridu,
    COUNT(*) - COUNT(customer_id)   AS puudub_1,   -- klient puudub (külalisost)
    COUNT(*) - COUNT(total_price)   AS puudub_2    -- summa puudub
FROM sales
UNION ALL
SELECT 'customers',
    COUNT(*),
    COUNT(*) - COUNT(email),                       -- e-post puudub
    COUNT(*) - COUNT(phone)                        -- telefon puudub
FROM customers
UNION ALL
SELECT 'products',
    COUNT(*),
    COUNT(*) - COUNT(cost_price),                  -- omahind puudub
    COUNT(*) - COUNT(retail_price)                 -- müügihind puudub
FROM products;
-- Tulemus:
--   sales      15234 | 1487 | 0
--   customers   3150 |  380 | 0
--   products     362 |    0 | 0
-- Veerud puudub_1 ja puudub_2 tähendavad igas tabelis eri veergu (vt kommentaare)
-- Toomase jaoks: "Kõige rohkem puuduvaid väärtusi on sales tabelis,
--                 kus 1487 kirjel puudub customer_id."
-- NB: need on külalisostud – kehtiv äriloogika, mitte viga.
--     Päris kvaliteediprobleem on customers tabelis: 380 kliendil puudub e-post.


-- ---------------------------------------------------------------------
-- Päring 3 · Formaatide diagnostika: linnade kirjaviisid
-- ---------------------------------------------------------------------
-- TRIM eemaldab tühikud, INITCAP teeb esitähe suureks
SELECT DISTINCT
    city AS originaal,
    INITCAP(TRIM(city)) AS puhastatud
FROM customers
WHERE city IS NOT NULL
ORDER BY puhastatud, originaal;
-- Tulemus: 54 rida (54 kirjaviisi), puhastatud veerus 12 erinevat linna

-- Kontroll: mitu kirjaviisi ja mitu päris linna
SELECT
    COUNT(DISTINCT city)                AS kirjaviise,
    COUNT(DISTINCT INITCAP(TRIM(city))) AS parisi_linnu
FROM customers
WHERE city IS NOT NULL;
-- Tulemus: 54 | 12
-- Toomase jaoks: "Leidsime 54 linnanimede kirjaviisi, mis koonduvad 12 linnaks;
--                 42 kirjaviisi tuleb ühtlustada." (54 - 12 = 42)
