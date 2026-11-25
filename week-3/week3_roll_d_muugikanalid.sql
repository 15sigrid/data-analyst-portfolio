-- =============================================
-- GT_Roll D: Müügikanalite efektiivsuse analüüs
-- =============================================

-- ÜLESANNE: Mitme tabeli JOIN: 
  -- Millised müügikanalid toovad enim müüke?
  -- Millised kliendid kasutavad milliseid kanaleid? 
  -- Koosta müügikanalite analüüs Annale.

-- Vaatan tabeli sales struktuuri
SELECT * FROM sales LIMIT 5;   -- näitab 5 rida koos kõigi veergude nimedega
-- Tulemus: 12 veergu
-- id, sale_id, invoice_id, sale_date, customer_id, product_id, quantity, unit_price, total_price, channel, store_location, payment_method

-- Vaatan, millised müügikanalid on olemas. Mitu erinevat kanalit on?
SELECT DISTINCT channel FROM sales ORDER BY channel;     -- DISTINCT näitab iga väärtust ainult üks kord
-- Tulemus: 2 erinevat müügikanalit - online ja pood

-- Milline kanal toob enim müüke?
SELECT
    s.channel AS müügikanal,
    COUNT(DISTINCT s.customer_id) AS kliente,   -- erinevad kliendid
    COUNT(s.sale_id) AS oste,                   -- müükide arv
    SUM(s.total_price) AS kogumüük              -- müügisumma kokku
FROM sales s                                    -- sales s tähendab: tabel sales, hüüdnimi s (tühik vahel on õige)
GROUP BY s.channel                              -- üks rida iga kanali kohta
ORDER BY kogumüük DESC;                         -- suurim müük ülal
-- Tulemus:   -- 1. POOD: kliente 2278, oste 6656, kogumüük 1902430.30
              -- 2. ONLINE: kliente 1706, oste 3462, kogumüük 1006747.68
              -- Oste kokku 10118, (kanalite kliente ära kokku liida. Sama kl võib osta nii poest kui online)

-- JOIN
-- Millistest linnadest kliendid milliseid kanaleid kasutavad?
SELECT
    s.channel AS müügikanal,
    c.city AS linn,                              -- linn tuleb customers tabelist
    COUNT(DISTINCT c.customer_id) AS kliente,
    SUM(s.total_price) AS kogumüük
FROM sales s
INNER JOIN customers c                           -- ühenda customers tabeliga (hüüdnimi c)
    ON s.customer_id = c.customer_id             -- ühendamise tingimus: sama kliendi number
GROUP BY s.channel, c.city                       -- grupp iga kanali + linna kohta
ORDER BY müügikanal, kogumüük DESC;
-- Tulemus: Vastavalt kanalile erinevast linnast klientide koguarv ja müügisumma (2x12=24 rida - 12 linna 2 kanalit). Kanalid ühes veerus

-- Millistest linnadest kliendid milliseid kanaleid kasutavad?
SELECT
    c.city AS linn,                              -- linn tuleb customers tabelist
    COUNT(DISTINCT c.customer_id) AS kliente,
    SUM(s.total_price) FILTER (WHERE s.channel = 'online') AS online_muuk,
    SUM(s.total_price) FILTER (WHERE s.channel = 'pood') AS pood_muuk
FROM sales s
INNER JOIN customers c                           -- ühenda customers tabeliga (hüüdnimi c)
    ON s.customer_id = c.customer_id             -- ühendamise tingimus: sama kliendi number
GROUP BY c.city                                  -- grupp iga linna kohta
ORDER BY pood_muuk DESC;
-- Tulemus: 12 (rida) erinevat linna, 4 veergu: linn, kliente, online_muuk, pood_muuk. 
-- Veerg "kliente" unikaalsete klientide arv vastavas linnas. 
-- Kanalite veerud: müükide kogusumma.

-- Uurin, kui palju on külalisoste
SELECT
    s.channel AS müügikanal,
    COUNT(DISTINCT c.customer_id) AS kliente,
    COUNT(s.sale_id) AS oste,
    SUM(s.total_price) AS kogumüük,
    SUM(s.total_price) FILTER (WHERE c.customer_id IS NULL) AS id_puudub
FROM sales s
INNER JOIN customers c                           -- ühenda customers tabeliga (hüüdnimi c)
    ON s.customer_id = c.customer_id             -- ühendamise tingimus: sama kliendi number
GROUP BY müügikanal                              -- grupp iga kanali kohta
ORDER BY müügikanal, kogumüük DESC;
-- Tulemus: 2 (rida) online, pood, 5 veergu: müügikanal, kliente, oste, kogumüük, id_puudub
-- Veerg "kliente" unikaalsete klientide arv vastavas kanalis.
-- See päring tõestas, et INNER JOIN külalisoste välja ei too.
-- Kokkuvõte:
    -- kanal    ilma JOIN-ita   JOIN-iga    vahe
    -- online   3 462	        3 128       334
    -- pood     6 656	        6 002       654
    -- 334 + 654 = 988. Täpselt Nädal 2 külalisostude arv.

-- 3 tabeli JOIN: millised tooted müüvad millises kanalis?
SELECT
    s.channel AS müügikanal,
    p.category AS tootekategooria,               -- kategooria tuleb products tabelist
    COUNT(DISTINCT c.customer_id) AS kliente,
    COUNT(s.sale_id) AS oste,
    SUM(s.total_price) AS kogumüük,
    ROUND(AVG(s.total_price), 2) AS keskmine_ost -- keskmine ostusumma, 2 komakohta
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id   -- 1. JOIN: + klient
INNER JOIN products p ON s.product_id = p.product_id      -- 2. JOIN: + toode
GROUP BY s.channel, p.category
ORDER BY müügikanal, kogumüük DESC;
-- Tulemus: 10 rida (2 kanalit × 5 kategooriat).
-- Iga rida näitab ühe kanali ja ühe kategooria klientide arvu, ostude arvu, kogumüüki ja keskmist ostu.
-- Online-is müüb enim: jalanõusid (kogumüük 248820.61 €).
-- Poes müüb enim: meeste_riided (kogumüük 447173.58 €).
-- Kõige kallim keskmine ost: mõlemas kanalis jalanõud (online 393.70 €, pood 371.67 €).

-- Kõige efektiivsem kanal: müük ühe kliendi kohta
SELECT
    s.channel AS müügikanal,
    COUNT(DISTINCT s.customer_id) AS kliente,
    SUM(s.total_price) AS kogumüük,                                                 -- SUM liidab ka külalisostude raha
    ROUND(SUM(s.total_price) / COUNT(DISTINCT s.customer_id), 2) AS müük_per_klient -- müük jagatud klientidega. 
                                                                                    -- COUNT(DISTINCT customer_id) ei loe külalisi klientide hulka.
FROM sales s
GROUP BY s.channel
ORDER BY müük_per_klient DESC;
-- Tulemus: Pood on kanalitest efektiivseim - müük_per_klient 835.13. Online - müük_per_klient 590.12

-- Sama päring, aga ilma külalisostudeta
SELECT
    s.channel AS müügikanal,
    COUNT(DISTINCT s.customer_id) AS kliente,
    SUM(s.total_price) AS kogumüük,                                                 -- liidab ainult klientide ostud
    ROUND(SUM(s.total_price) / COUNT(DISTINCT s.customer_id), 2) AS müük_per_klient
FROM sales s
WHERE customer_id IS NOT NULL
GROUP BY s.channel
ORDER BY müük_per_klient DESC;
-- Tulemus: ilma külalisostudeta -  Pood - müük_per_klient 752.41. Online - müük_per_klient 532.67
-- Vahe eelmise päringuga: Pood: müük_per_klient 82,72 (835.13-752.41). Online: müük_per_klient 57,45 (590.12-532.67)
-- Pood efektiivseim ka ilma külalisoste arvestamata.

-- =============================================
-- EDASIJÕUDNUTE TASE (vabatahtlik)
-- =============================================

-- Edasijõudnud: kaupluste ja kanalite võrdlus
SELECT
    s.store_location AS kauplus,                                      -- Tallinn / Tartu / Pärnu
    s.channel AS müügikanal,
    COUNT(s.sale_id) AS oste,
    SUM(s.total_price) AS kogumüük,
    ROUND(SUM(s.total_price) / COUNT(s.sale_id), 2) AS keskmine_ost   -- müük jagatud ostude arvuga
FROM sales s
GROUP BY s.store_location, s.channel
ORDER BY kauplus, kogumüük DESC;
-- Tulemus: 4 rida: 3 poodi + NULL = online.
-- Suurim kauplus: Tallinn (kogumüük 1092083.15 €).
-- Keskmine ost kolmes (3) kaupluses ja online-kanalis on ca 273–291€.
-- Järeldus: pood ei müü rohkem seepärast, et ost oleks suurem, vaid seepärast, et oste on rohkem.
-- Kontroll: 1 058 + 3 801 + 1 797 = 6 656 poeostu (sama arv, mis eelmises päringus)

-- =============================================
-- GT_Roll D: Äriline järeldus:
-- =============================================
-- 1. Kas Tallinna, Tartu ja Pärnu kauplused on erinevad? Vaata oste ja keskmist ostu
        -- V: Keskmine ost kolmes (3) kaupluses ja online-kanalis on sarnane so 273–291€.
        -- Suurim erinevus ostude arvus: Tallinnas 3,6× rohkem kui Pärnus.
-- 2. Kas mõni kauplus peaks rohkem online-müügile panustama?
        -- V: Pärnu klientidele suunatud online-kampaania, et näha, kas Pärnu klientide ostude arv kasvab.
        -- Online-ost ei ole kauplusega seotud (store_location = NULL).
-- 3. Kuhu peaks Anna turunduse raha suunama?
        -- V: Anna võiks suunata turunduse raha klientide tagasivõitmise ja online-müügikanali osakaalu suurendamise eesmärgil. 
        -- Online-müük on poemüügist peaaegu poole väiksem (1,01 vs 1,90 milj €).