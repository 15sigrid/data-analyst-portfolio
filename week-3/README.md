# Nädal 3 – SQL JOINid · Roll D: müügikanalid

## Kontekst
- UrbanStyle.ltd andmed on erinevates tabelites (sales, customers, products, inventory).
- Anna Mets, Marketing Lead, ootab meeskondadelt tulemusi, mis nõuavad mitme tabeli ühendamist saamaks vastused tema küsimustele:
1. Millised kliendid pole kunagi midagi ostnud?
2. Millised tooted pole kunagi müüdud?
3. Kes on parimad kliendid?
4. Millised tooted müüvad?
5. Millised müügikanalid ja linnad töötavad? 

- Anna ei taha vastuseid SQL-i keeles vaid korrektselt välja kirjutatuna. 

- Meeskond SalesAnalytics jagas tööd rollideks A–D.
- Minu roll oli D: Müügikanalite efektiivsuse analüüs

Tiimi ühine slaid: [SalesAnalytics – Nädal 3](https://docs.google.com/presentation/d/1V4vecJNvkw2XtjDkeAVUFLFo_mmHsj9XPD9e25hJWoQ/edit)

## Minu ülesanne
- Roll D ülesanne oli mitme tabeli (sales, customers, products) ühendamine, et saada vastused küsimustele: millised müügikanalid toovad enim müüke ja millised kliendid kasutavad milliseid kanaleid? 
- Koostasin müügikanalite analüüsi.

## Failid
| Fail | Sisu |
|---|---|
| `week3_roll_d_muugikanalid.sql` | Kaardi D päringud koos tulemustega |
| `rollD_1_kanalid.png` | Uurisin: milline kanal toob enim müüke? |
| `rollD_2_linnad.png` | Uurisin: millistest linnadest kliendid milliseid kanaleid kasutavad? |
| `rollD_3_kategooriad.png` | Kolme (3) tabeli JOIN: millised tooted müüvad millises kanalis? |
| `rollD_4_muuk_per_klient.png` | Uurisin: kõige efektiivsem kanal - müük ühe (1) kliendi kohta |
| `rollD_5_kauplused.png` | Uurisin: kaupluste ja kanalite võrdlus |

## Peamised leiud
- poekanal toob 65% müügist (1,90 vs 1,01 milj €)
- kõigi linnade kliendid ostavad poest ~1,5–2× rohkem kui veebist
- jalanõudel on mõlemas kanalis kõige kallim keskmine ost (394 / 372 €)
- keskmine ost on kõikjal ~273–291 €, erinevus tuleb ostude arvust

## Kokkuvõte Annale
Enim müüke toov kanal on Pood, mis on klientide ja ostude arvu ning kogumüügi osas edukam kui online. 

POOD: kliente 2278, oste 6656, kogumüük 1 902 430.30 €

ONLINE: kliente 1706, oste 3462, kogumüük 1 006 747.68 €

Oste kokku: 10118

Efektiivseim müük kliendi kohta on taaskord poekanalis suurem, kui onlines: müük kliendi kohta  (752 vs 533 €). Samas keskmise ostu võrdluses on mõlemas kanalis summa suhteliselt ühtlane u 273–291€.

Kolme (3) Kaupluse (Tallinn, Tartu, Pärnu) võrdluses on näha mastaapsuse mõju st Tallinna kaupluse ostude arv on 3,6× suurem kui Pärnus.

Anna võiks suunata turunduse raha klientide tagasivõitmise ja online-müügikanali osakaalu suurendamise eesmärgiks - online-müük on poemüügist peaaegu poole väiksem (1,01 vs 1,90 milj €).

## Edasijõudnute tase
Uurisin: Kaupluste ja online müügikanali võrdlust 
- 4 rida: 3 poodi + NULL = online.
- Suurim kauplus: Tallinn (kogumüük 1 092 083.15 €).
- Keskmine ost on kõigis kanalites ja poodides umbes 273–291€.
- Järeldus: pood ei müü rohkem seepärast, et ost oleks suurem, vaid seepärast, et oste on rohkem.
- Äriline järeldus:
    1. Kas Tallinna, Tartu ja Pärnu kauplused on erinevad? Vaata oste ja keskmist ostu
        -  V: Keskmine ost on kõigis kanalites ja poodides sarnane so 273–291€. Suurim erinevus ostude arvus: Tallinnas 3,6× rohkem kui Pärnus.
    2. Kas mõni kauplus peaks rohkem online-müügile panustama?
        - V: Pärnu klientidele suunatud online-kampaania, et näha, kas Pärnu klientide ostude arv kasvab.
    3. Kuhu peaks Anna turunduse raha suunama?
        - V: Anna võiks suunata turunduse raha klientide tagasivõitmise ja online-müügikanali osakaalu suurendamise eesmärgil. 
        - Online-müük on poemüügist peaaegu poole väiksem (1,01 vs 1,90 milj €).

## Andmete piirangud
- külalisostud, ~10% ostudest, jäävad INNER JOIN-is välja
- online-ostul pole poodi, store_location = NULL
- mida ei saanud hinnata: nt marginaal, kampaaniad.

## Mida õppisin
- INNER JOIN jätab välja read, millel pole vastet (külalisostud kadusid)
- GROUP BY teeb grupid ainult nendest väärtustest, mis andmetes on olemas (3 poodi + NULL)
- FILTER (WHERE …) teeb pikast tabelist laia, loetavama tabeli
- ORDER BY sorteerib ainult nimetatud veeru järgi