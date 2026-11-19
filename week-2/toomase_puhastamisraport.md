# Toomase puhastamisraport – nädal 2

**Andmed:** UrbanStyle (`sales`, `customers`, `products`), Supabase
**Päringud:** [week2_kvaliteet.sql](week2_kvaliteet.sql)

Raport ainult kirjeldab probleeme. Andmetest ei kustutatud midagi.

## Kokkuvõte

| Probleem | Arv |
|---|---|
| Koopiad müügitabelis | 5116 |
| E-postita kliendid | 380 |
| Vigased kuupäevad | 50 |

## Koopiad

Müügitabelis on 15234 rida, aga päris arveid on 10118, seega 5116 rida on koopiad. Koopiad ei ole alati täpselt samasugused, originaaliks loetakse väikseima `id`-ga rida. Duplikaatide tõttu näitab müügiaruanne umbes 1,47 miljonit eurot rohkem tulu, kui tegelikult oli.

## Puuduvad väärtused

380 kliendil puudub e-post. Anna ei saa neile kirju saata, nii et see osa kliente jääb turunduskampaaniatest välja.

## Kirjaviis ja kuupäevad

Kliendiregistris on 54 linnanime kirjaviisi, kuid päris linnu on 12. 50 müügi kuupäev on hilisem kui andmete lõpp (28.02.2025), seega need kuupäevad on vigased. Need read jäävad tabelisse, aga analüüsist jäetakse välja.

Avatud küsimus ärile: kas andmed lõpevad tõesti 28.02.2025?

## Soovitus

Esimesena tuleks eemaldada müügi duplikaadid, kuna need moonutavad kõiki müüginumbreid ja ettevõte otsustab vale tulu põhjal.
