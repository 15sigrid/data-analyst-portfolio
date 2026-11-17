# Nädal 2: SQL andmete puhastamine

## Kontekst
- UrbanStyle'i andmebaasis on kolm kriitilist domeeni, mida tuleb puhastada: müügiandmed, kliendiandmed ja tooteandmed. Iga domeen vajab oma puhastamisplaani.
- UrbanStyle'i IT-juht Toomas Kask (väljamõeldud juhtumi tegelane) on teinud ülevaate andmete puhastamise protsessist:
    - kuidas DELETE ja UPDATE töötavad,
    - miks need on OHTLIKUD.
    - Reegel: TEST KOOPIA KÕIGEPEALT. Siis puhasta. Siis kontrolli. Siis dokumenteeri.

## Minu roll: C – Tooteandmete puhastaja
Uurisin `products` tabelit testkoopial (`products_test`, 362 rida):
1. Lõin testkoopia ja kontrollisin ridade arvu
2. Otsisin duplikaate tootenime järgi (`GROUP BY` + `HAVING`)
3. Kontrollisin NULL-e kriitilistes väljades (`COUNT(*) FILTER`)
4. Kontrollisin hindade loogikat (negatiivsed, äärmuslikud, jaehind < omahind)
5. Kontrollisin kategooriate järjekindlust ja `eco_certified` veergu

## Failid
- `week2_products_cleaning.sql` – kaardi C päringud koos tulemustega
- `week2_learnings.md` – nädala 2 õppemärkmed

## Tulemused

| Kontroll | Leitud | Selgitus |
|---|---|---|
| Duplikaatsed tootenimed | 12 | Sama nimi 2 korda, koopiad ID-dega 1351–1362 |
| NULL nimi / kategooria / hinnad | 0 | Kriitilised väljad on täidetud |
| Negatiivne või äärmuslik jaehind | 0 | Kalleim toode 434.08 € |
| Ebajärjekindlad kategooriad | 0 | 5 kategooriat, igaüks ühes kirjapildis |
| **Lisaleid:** jaehind < omahind | 8 toodet | 10 rida, millest 2 on duplikaadid |
| **Lisaleid:** `eco_certified` = NULL | 18 | NULL ≠ false: sertifikaadi olemasolu teadmata |
| **Kokku** | **38 rida** | 3 probleemitüüpi |

Kõige olulisem on kahjumiga hindade probleem, sest see moonutab marginaalianalüüsi. Duplikaadid on lihtsamini parandatavad.

## Edasijõudnute tase (vabatahtlik)
- Ühtlustasin kategooriad `INITCAP`-iga (aksessuaarid → Aksessuaarid) ja tõlkisin need `CASE WHEN`-iga inglise keelde (Accessories, Footwear, Kidswear, Menswear, Womenswear).
- Iga muudatuse eel tegin eelvaate (`SELECT` sama `WHERE`-ga) ja pärast kontrolli: 5 kategooriat, kokku 362 rida.
- Õppetund: esimesel katsel oli `UPDATE` juba käivitatud, seega eelvaade andis 0. Lähtestasin testkoopia ja kordasin õiges järjekorras.
- Muudetud ainult `products_test`, originaaltabel on muutmata.

## Peamine järeldus
8 toote jaehind on omahinnast madalam. Vajab äripoole kontrolli, kas tegu on andmeveaga või tegeliku kahjumiga müügiga. Kuni selgumiseni on marginaalianalüüs ebatäpne.

## Meeskonna töö
(link meeskonna repole – lisad hiljem)