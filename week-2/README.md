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
- `toomase_puhastamisraport.md` – andmekvaliteedi raport Toomasele
- `week2_kvaliteet.sql` – raporti päringud

## Tulemused

| Kontroll | Leitud | Selgitus |
|---|---|---|
| Duplikaatsed tootenimed | 12 | Sama nimi 2 korda, koopiad ID-dega 1351–1362; kustutatud products_test-ist, alles 350 |
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

## Duplikaatide eemaldamine (products_test)
Eemaldasin testkoopiast 12 duplikaattoodet ja kontrollisin tulemust:
1. **Orbude kontroll:** enne kustutamist kontrollisin, kas mõni müük viitab duplikaatidele (ID-d 1351–1362). Tulemus 0, seega orbe ei teki.
2. **Eelvaade:** sama `WHERE`-ga `SELECT` näitas 12 kustutatavat rida.
3. **Kustutamine:** `DELETE`, jäeti alles iga tootenime väikseim `product_id`.
4. **Kontroll:** alles 350 rida (362 − 12), korduvaid tootenimesid 0.

**Õppetund:** esimesel eelvaate katsel panin kaks `NOT IN`-i üksteise sisse ja sain 350 (originaalid, mitte koopiad). Kaks eitust annavad jaatuse. Eelvaade päästis, sest `DELETE` oleks kustutanud originaalid.

## Peamine järeldus
Duplikaadid (12) on testkoopiast eemaldatud ja kontrollitud: tooteid on 350, mitte 362. Originaaltabelisse tuleb see muudatus viia alles pärast meeskonna ja ärikliendi kinnitust.

Lahtiseks jääb kaks asja, mis vajavad äripoole otsust:
- **8 toote jaehind on omahinnast madalam.** Kas see on andmeviga või päris kahjumiga müük? Kuni selgumiseni on marginaalianalüüs ebatäpne.
- **18 tootel puudub eco-sertifikaadi info** (NULL). Eco-toodete osakaalu ei saa täpselt arvutada.

## Toomase puhastamisraport
Leidsin müügitabelist 5116 koopiat, 380 e-postita klienti ja 50 vigast kuupäeva; tehisaru aitas päringuid struktureerida ja kontrollida, päringud käivitasin ja tulemused kontrollisin ise Supabase'is.

Lõpuesitluseks valin duplikaadid, kuna need suurendavad müügitulu umbes 1,47 miljoni euro võrra ja muudavad iga müügiotsuse ebausaldusväärseks.

- [Raport](toomase_puhastamisraport.md)
- [Päringud](week2_kvaliteet.sql)


## Meeskonna töö
[Meeskonna nädal 2 README](https://github.com/15sigrid/urbanstyle-sales-analytics/blob/main/week-2/README.md)