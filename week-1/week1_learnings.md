# Mida õppisin grupi demodest (nädal 1)

## Lisapäringud demo põhjal

Päringud on failis `week1_customers_exploration.sql`, osas „Lisapäringud grupi demo põhjal”.

| Kontroll | Minu tulemus | Järeldus |
|---|---|---|
| Korduvad telefonid | 150 rida | Klapib dokumentatsiooniga (~150 duplikaati). Telefon on parem duplikaatide tunnus kui e-post. |
| Telefoni vs e-posti korduvate vahe | 20 rida | Tõenäoliselt e-postita duplikaadid (nt Sirje Kuusk). E-posti järgi neid ei leia. |
| Linnanimed: algne / `lower()` / `trim()` / `lower(trim())` | 54 / 32 / 34 / **12** | Andmetes on nii suur- ja väiketähtede kui ka tühikute vead. Päris linnu on 12. |
| Tallinn `lower(trim(city))` | 1238 rida | Lihtsast päringust jääb välja **103** rida, mitte 49, nagu arvasin ainult `lower()` põhjal. |
| Puuduv lojaalsustase | 1260 rida (40%) | NULL võib tähendada, et klient pole programmiga liitunud, mitte puuduvat andmet. |

*Hiljem:* registreerimised aastate kaupa (`EXTRACT(YEAR ...)` + `GROUP BY`).

## Head ideed esitluse jaoks

- **Pealkiri on järeldus, mitte teema** – nt „Kliendiandmetes on lüngad ja kordused”, mitte „Customers”.
- **Iga probleemi juurde ärimõju** („Äririskid”) – andmeprobleem → mis juhtub, kui seda ei paranda.
- **Eraldi kast „Mida see Toomasele tähendab”.**
- **Kolm suurt numbrit** slaidi ülaosas.
- **Protsendid annavad mastaabi** – nt 380 rida = 12%, 1260 rida = 40%.

## Teadmised

- **Funktsioone saab panna üksteise sisse:** `lower(trim(city))` – kõigepealt eemaldab tühikud, siis muudab väiketähtedeks.
- **`WHERE lower(city) = 'tallinn'` ei muuda andmeid** – muudab nime ajutiselt ainult võrdluse ajaks. Seepärast peab parem pool olema samas kujus (väiketähtedega).
- **NULL ei tähenda alati puuduvat andmet.** Enne järeldust tuleb küsida, mida NULL selles veerus tähendab.
- **Korduvate valem:** `COUNT(*) - COUNT(DISTINCT email)` annab 510, sest loeb sisse ka NULL-id (380 + 130). Õige on `COUNT(email) - COUNT(DISTINCT email)` = 130.
- **Rida vs klient:** tabeli read ei ole sama mis kliendid, kui andmetes on duplikaate.
- **Tulevikukuupäevad (2026) on vead, mitte periood.**
- **Mitu kontrolli kinnitavad üksteist:** dokumentatsioon ~150, telefoni järgi 150, e-posti järgi 130. Üks kontroll ei näita kogu pilti.
- **Teiste tulemuste kontrollimine täpsustas minu oma:** Tallinna puhul 49 → 103.

## Järgmiseks nädalaks endale

Ühendada täpsed numbrid, järeldus pealkirjas ja ärimõju iga leiu juures.
