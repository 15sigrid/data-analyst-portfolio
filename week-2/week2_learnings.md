# Nädal 2: SQL andmete puhastamine (õppemärkmed)

UrbanStyle `sales` ja `customers` tabelid, Supabase (PostgreSQL).
Põhireegel: **tuvasta → dokumenteeri → testi → alles siis paranda.** Muudatusi teen ainult testkoopias.

---

## 1. Testkoopia: loomine, tühjendamine, taastamine

```sql
-- Viska vana koopia ära (kui on olemas) ja tee uus
DROP TABLE IF EXISTS sales_test;
CREATE TABLE sales_test AS
SELECT * FROM sales;

-- Kontroll
SELECT COUNT(*) FROM sales;        -- 15234
SELECT COUNT(*) FROM sales_test;   -- 15234
```

- `CREATE TABLE ... AS SELECT` tähendab „loo uus tabel, **mis on** selle päringu tulemus“. Ilma `AS`-ita tuleb viga.
- Mustrit `DROP TABLE IF EXISTS` + `CREATE TABLE ... AS` võib käivitada mitu korda ja iga kord saab värske koopia.

**Kasti näide:**

| Käsk | Mis juhtub |
|---|---|
| `DELETE FROM sales_test;` | **tühjendab kasti**, tabel jääb alles, 0 rida |
| `DROP TABLE sales_test;` | **viskab kasti ära**, tabelit enam ei ole |
| `INSERT INTO sales_test SELECT * FROM sales;` | **valab kasti juurde**, ei asenda |

```sql
-- Andmed ühest tabelist teise
INSERT INTO sales_test
SELECT * FROM sales;
```

⚠️ Kui tabelis oli juba 15 234 rida, oli pärast `INSERT`-i **30 468 rida** (iga rida kaks korda). Nii tekivad ka päris duplikaadid: sama andmestik imporditakse mitu korda ja kontrolli ei ole.

Veateated:
- `already exists`: proovisin luua tabelit, mis on juba olemas (`DELETE` jättis tühja kasti alles)
- `does not exist`: proovisin kasutada tabelit, mis on `DROP`-iga ära visatud

---

## 2. Ohutu kustutamine: `-- SELECT *` lüliti

```sql
DELETE
-- SELECT *
FROM sales_test
WHERE channel = 'online';
```

1. Märgin read `SELECT *` kuni `WHERE` ja käivitan **SELECT-ina**. Näen, mis kustuks ja mitu rida.
2. Kui tulemus on õige, märgin `DELETE` + `FROM` + `WHERE` ja käivitan.

- `DELETE` ilma `WHERE`-ita kustutab **kõik** read.
- Supabase'i hoiatusaken „Potential issue detected“ on viimane võimalus peatuda.
- „Success. No rows returned“ on `DELETE`-i ja `UPDATE`-i puhul normaalne vastus.
- „Success“ ei tähenda „õige“. SQL teeb täpselt seda, mida kästakse.

---

## 3. Duplikaatide leidmine: `GROUP BY` + `HAVING`

**Kuhjade näide:** panen sama numbriga arved ühte kuhja ja loen iga kuhja üle. Kui kuhjas on rohkem kui 1 arve, on see duplikaat.
- kuhjadesse panemine on `GROUP BY`
- kuhja lugemine on `COUNT(*)`
- ainult üle ühe arvega kuhjad on `HAVING COUNT(*) > 1`

```sql
SELECT invoice_id, COUNT(*) AS koopiate_arv
FROM sales_test
GROUP BY invoice_id                -- kuhjad arve järgi
HAVING COUNT(*) > 1                -- ainult korduvad arved
ORDER BY koopiate_arv DESC         -- suurimad kuhjad ette
LIMIT 10;
-- Kokku (ilma LIMIT-ita): 4013 arvet esineb rohkem kui 1 korra.
-- Suurimad: 6 rida (1 originaal + 5 koopiat).
-- Ilma HAVING-ita: 10 118 rida = unikaalsete arvete arv.
```

- `WHERE` filtreerib **ridu enne** kuhjadesse panemist.
- `HAVING` filtreerib **kuhje pärast** kuhjadesse panemist.
- Kui andmed on puhtad, tagastab päring **0 rida**. Ka 0 on vastus.

**`LIMIT` sobib vaatamiseks, aga mitte lugemiseks.** Kui küsimus algab sõnaga „mitu“, kontrollin, kas päringus on `LIMIT`.

---

## 4. Päringu täitmisjärjekord

SQL loeb päringut teises järjekorras, kui see on kirjutatud:

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

- Hüüdnimi (`AS ...`) tekib `SELECT`-is. Sellele eelnevad sammud (`WHERE`, `HAVING`) seda ei näe.
- `HAVING koopiate_arv > 1` annab vea `column "koopiate_arv" does not exist`, õige on `HAVING COUNT(*) > 1`.
- `ORDER BY koopiate_arv` töötab, kuna `ORDER BY` tuleb pärast `SELECT`-i.
- `TOP n` on SQL Serveri süntaks, PostgreSQL-is (Supabase) kasutan `LIMIT n`.

---

## 5. `ROW_NUMBER()`: igale reale järjekorranumber kuhja sees

```sql
SELECT
    sale_id,
    total_price,
    ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY id) AS rn
FROM sales;
```

- `PARTITION BY` määrab, mille järgi kuhjad tehakse. Nummerdamine algab igas kuhjas uuesti ühest.
- `ORDER BY` sulgude sees määrab, kes kuhjas saab numbri 1.
- `rn` = *row number*, see on lihtsalt veeru nimi.
- `rn = 1` on originaal ja jääb alles, `rn > 1` on koopia.

Näide: müük nr 3 on tabelis 4 korda (rn 1–4). Aruanne loeb selle kokku kui 4 × 221.19 = 884.76, aga tegelik müük oli 221.19.

### Ainult duplikaadid: alampäring

`WHERE rn > 1` otse ei tööta, kuna `WHERE` käib enne `SELECT`-i ja `rn`-i pole siis veel olemas. Lahendus on panna päring sulgudesse:

```sql
SELECT *
FROM (
    SELECT
        customer_id, email, first_name, last_name, city,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
) nummerdatud                      -- alampäring vajab nime
WHERE rn > 1
  AND email IS NOT NULL;           -- NULL-id kõik ühes kuhjas, need ei ole duplikaadid
-- Tulemus: 130 kliendirida on e-posti järgi duplikaadid.
```

- Kuhjad tehakse **selle veeru järgi, mille järgi duplikaati otsin** (`email`), mitte ID järgi.
- Kõik NULL e-postid lähevad ühte kuhja ja saavad rn 1…380. Need tuleb välja jätta.
- `ORDER BY` lõpus muudab ainult järjekorda, ridu ei eemalda.

**NULL-iga ei saa kasutada `=` märki:**
- `email IS NOT NULL` ✓
- `email = NULL` ❌ (ei anna viga, aga tagastab alati 0 rida)
- `email = IS NOT NULL` ❌

**Leid:** e-posti duplikaatidel on sama inimene, aga kirjaviis erineb (nt 3838 *Ago* Kivi ja 5128 *AGO* Kivi). Duplikaadi definitsioon mõjutab tulemust: NULL e-postiga duplikaadid (nt Sirje Kuusk, 3 ID-d) siia ei jõua, seega on tegelik arv suurem kui 130. Nime järgi otsimine üksi ei sobi, kuna Eesti nimed korduvad (Eha Aas on kolm eri inimest).

---

## 6. Duplikaatide eemaldamine: `MIN(id)`

**Mis on `id`?** See on skeemis `id SERIAL PRIMARY KEY`, automaatne järjekorranumber, mis pandi igale reale laadimisel. Nagu postkontori tempel: kolm ühesugust paberit saavad eri numbri.

| id | sale_id | |
|---|---|---|
| 1660 | 1660 | originaal (väikseim id) |
| 10149 | 1660 | koopia |
| 14134 | 1660 | koopia |

`sale_id` ütleb, **mis müük** see on, ja see kordub. `id` ütleb, **mis rida** see on, ja see on alati unikaalne.

```sql
-- Samm 1: loe duplikaatread kokku
SELECT COUNT(*) AS duplikaat_read
FROM sales_test
WHERE id NOT IN (
    SELECT MIN(id)               -- igast kuhjast väikseim id = originaal
    FROM sales_test
    GROUP BY invoice_id
);
-- Tulemus: 5116

-- SQL kalkulaatorina
SELECT 15234 - 5116;             -- 10118

-- Samm 2: kustuta (enne kontrolli SELECT *-ga: 5116 rida)
DELETE
-- SELECT *
FROM sales_test
WHERE id NOT IN (
    SELECT MIN(id)
    FROM sales_test
    GROUP BY invoice_id
);

-- Samm 3: kontroll
SELECT COUNT(*) FROM sales_test;               -- 10118 ✓

SELECT invoice_id, COUNT(*)
FROM sales_test
GROUP BY invoice_id
HAVING COUNT(*) > 1;                           -- 0 rida ✓
```

- Sisemine päring (sulgudes) annab originaalide nimekirja: 10 118 id-d.
- `NOT IN` tähendab „kõik, mida selles nimekirjas ei ole“, ehk koopiad.
- 5116 tuli kolme eri meetodiga: `COUNT − COUNT DISTINCT`, `ROW_NUMBER` ja `MIN(id)`.

⚠️ **Koopiad ei ole alati identsed.** Arvel `INV-202308-00283` on ühes reas `unit_price` 226.72 (4 × 226.72 = 906.88 ≠ 1013.04) ja ühes reas NULL `customer_id`. `MIN(id)` jättis alles õige rea, aga see ei olnud kontrollitud. Ridade täielikuks võrdlemiseks peab `GROUP BY` sisaldama kõiki veerge peale `id`. Selle nädala ülesande tulemus on 10 118 rida, hinnaerinevust ei uurinud.

---

## 7. NULL ja `UPDATE`

```sql
SELECT * FROM sales_test
WHERE customer_id IS NULL;       -- 988 rida pärast duplikaatide eemaldamist
```

**NULL `customer_id` = külalisost**, see on kehtiv äriloogika, mitte viga. Neid ei kustutata ega muudeta, vaid dokumenteeritakse.

`UPDATE` muudab olemasolevat väärtust. Kasti näitel: `DELETE` viskab paberi välja, `UPDATE` kirjutab paberil ühe lahtri üle.

```sql
-- Variant 1
UPDATE sales_test
SET customer_id = 0
WHERE customer_id IS NULL
  AND id IN (21, 34);            -- katsetus ainult kahe reaga

-- Variant 2
UPDATE sales_test
SET customer_id = COALESCE(customer_id, 0)
WHERE id IN (42, 55);

-- Kontroll
SELECT * FROM sales_test WHERE customer_id = 0;   -- muudetud read
```

⚠️ Mentori demo: 0 ei ole hea asendus, kuna kliendinumbrit 0 ei ole olemas. NULL ütleb ausalt „klienti pole“, 0 näeb välja nagu päris klient.

### `COALESCE`

Võtab **vasakult paremale esimese väärtuse, mis ei ole NULL**.

```sql
COALESCE(customer_id, 0)            -- kui on number, jääb see; kui NULL, tuleb 0
COALESCE(imf, world_bank, uro)      -- kõige värskem olemasolev SKT
```

| Riik | IMF | World Bank | ÜRO | Tulemus |
|---|---|---|---|---|
| Liechtenstein | 9 442 | 8 906 | 8 628 | 9 442 |
| Kuuba | — | 107 352 | 252 063 | 107 352 |
| Põhja-Korea | — | — | 17 199 | 17 199 |

Aruandes saab NULL-i asemel sildi näidata ilma andmeid muutmata:

```sql
SELECT COALESCE(customer_id::TEXT, 'külaline') AS klient
FROM sales_test;
```

---

## 8. `CASE WHEN`: tingimuslik märgistamine

Nagu Exceli `IF`, aga mitme tingimusega. SQL vaatab tingimusi ülevalt alla ja **peatub esimese tõese juures**.

```sql
SELECT sale_id, sale_date,
    CASE
        WHEN sale_date > CURRENT_DATE  THEN 'TULEVIKUS!'
        WHEN sale_date < '2020-01-01'  THEN 'LIIGA VANA'
        ELSE 'OK'
    END AS kuupaeva_staatus
FROM sales_test;
```

- `CASE WHEN` **ei muuda andmeid**, vaid lisab tulemusse uue veeru. Põhimõte on „märgi, ära muuda“.
- Näiteks kliendi saldo: `> 0` on võlg, `< 0` on ettemaks, muidu tasutud.

---

## 9. Logi

```sql
-- LOGI: sales_test, DELETE duplikaadid invoice_id alusel, alles väikseima id-ga rida.
-- Enne 15 234 rida, kustutati 5116, pärast 10 118. Kontroll: duplikaate 0.
-- Koopiates oli hinnaerinevusi (nt INV-202308-00283), ei uuritud edasi.
-- 988 rida customer_id = NULL (külalisost), ei muudetud.
```

Kommentaarid SQL-failis on logi: mida tegin, mitu rida muutus, mida see tähendab.

---

## Lahtised küsimused

- 1B küsimus 3: miks e-posti duplikaadid tekivad? (koopiatel on ID üle 5000 ja teine kirjaviis)
- Mille järgi defineerida kliendi duplikaati, kui e-post on NULL? (Sirje Kuusk: sama telefon, linn ja kuupäev)
