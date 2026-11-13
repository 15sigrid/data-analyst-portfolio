# Week 1 – SQL Basics: UrbanStyle customer data

## What I did
- Uurisin `customers` tabelit SQL päringutega (roll B: kliendiandmed)
- Leidsin:
  - 3150 rida, registreerimised vahemikus 2020-01-02 – 2025-02-27
  - 54 erineva kirjaviisiga linnanime; Tallinn: 1135 rida korrektse kirjaviisiga, 1184 kõigi kirjaviisidega (49 rida jääks muidu välja)
  - e-post puudub 380 real, 130 rida on korduva e-postiga
  - eesnimi on kõigil olemas
- Osalesin meeskonna andmemaastiku slaidi koostamisel

## What I learned
- Korduvad e-postid: `COUNT(email) - COUNT(DISTINCT email)`. Töövihiku valem `COUNT(*) - COUNT(DISTINCT email)` loeks sisse ka 380 puuduvat e-posti ja annaks vale tulemuse.
- Puuduv koma veergude vahel annab süntaksivea. Viga on sõna ees, mida veateade näitab.

## Files
- `week1_customers_exploration.sql` – minu rolli B päringud koos kommentaaride ja tulemustega
- `week1_results_screenshot.png` – e-posti koondpäringu tulemus
- `n01_harjutused.sql` – töövihiku harjutused

## Team work (Sales Analytics team)
- [Data Landscape slaid](https://docs.google.com/presentation/d/1OSvAZDeuVsxKY09hgog5AWu8bpQH22dgcPJkZZhqlKk/edit?usp=sharing)