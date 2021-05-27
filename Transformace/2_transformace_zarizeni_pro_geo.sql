// transformace tabulky in_ockovaci_zarizeni
CREATE OR REPLACE TEMPORARY TABLE "ockovaci_zarizeni" AS 
SELECT "zarizeni_kod"
         ,"zarizeni_nazev"
         , "kraj_nuts_kod"
         , "okres_lau_kod" AS "okres_nuts_kod"
         , CAST(IFF("provoz_zahajen" = '',0,1)AS INT) AS "provoz_zahajen"
         , CAST(IFF("provoz_ukoncen" = '',0,1)AS INT) AS "provoz_ukoncen"
FROM "in_ockovaci_zarizeni"
;

// napojujeme na seznam nrpzs kvuli doplneni adres pro zjisteni lokace, 3916 se napojilo 
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_uzis_ciselnik" AS
SELECT "ockovaci_zarizeni"."zarizeni_kod"
       , "ockovaci_zarizeni"."zarizeni_nazev"
       , "ockovaci_zarizeni"."kraj_nuts_kod"
       , "ockovaci_zarizeni"."okres_nuts_kod"
       , "zar"."kod_obce"
       , "zar"."adresa"
//       , "ockovaci_zarizeni"."provoz_zahajen"
//       , "ockovaci_zarizeni"."provoz_ukoncen"
FROM "ockovaci_zarizeni"
JOIN (SELECT TRIM("zarizeni_kod") AS "zarizeni_kod", "kod_obce", "adresa", "okres_nuts_kod"
            FROM "zarizeni") AS "zar"
ON "ockovaci_zarizeni"."zarizeni_kod" = "zar"."zarizeni_kod" AND "ockovaci_zarizeni"."okres_nuts_kod" = "zar"."okres_nuts_kod"
;

//a 52 nenapojilo
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_nenapojeno" AS
SELECT "ockovaci_zarizeni"."zarizeni_kod"
       , "ockovaci_zarizeni"."zarizeni_nazev"
       , "ockovaci_zarizeni"."kraj_nuts_kod"
       , "ockovaci_zarizeni"."okres_nuts_kod"
//       ,"ockovaci_zarizeni"."provoz_zahajen"
//       , "ockovaci_zarizeni"."provoz_ukoncen"
FROM "ockovaci_zarizeni"
LEFT JOIN (SELECT TRIM("zarizeni_kod") AS "zarizeni_kod", "okres_nuts_kod"
            FROM "zarizeni") AS "zar"
ON "ockovaci_zarizeni"."zarizeni_kod" = "zar"."zarizeni_kod" AND "ockovaci_zarizeni"."okres_nuts_kod" = "zar"."okres_nuts_kod"
WHERE "zar"."zarizeni_kod" IS NULL
;

// zkousim tech 52 napojit dodatecne na jiny ciselnik nrpsz (pro doplneni zbytku), 38 se dodatecne napojilo
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_nrpzs_ciselnik" AS
SELECT "zarizeni_nenapojeno".*
             , "nrpzs"."Obec"
             , "nrpzs"."Ulice"||' '|| "nrpzs"."CisloDomovniOrientacni" || ', '|| "nrpzs"."Psc" || ', '|| "nrpzs"."Obec" AS "adresa"
             , "nrpzs"."Lat" AS "latitude"
             , "nrpzs"."Lng" AS "longitude"
             ,ROW_NUMBER () OVER (PARTITION BY "zarizeni_nenapojeno"."zarizeni_kod" ORDER BY "zarizeni_nenapojeno"."zarizeni_kod") AS "row_number"
FROM "zarizeni_nenapojeno"
JOIN (SELECT *
          , SUBSTR("Kod",1,11) AS "zarizeni_kod"
           FROM "in_nrpzs_zarizeni") AS "nrpzs"
ON "zarizeni_nenapojeno"."zarizeni_kod" = "nrpzs"."zarizeni_kod" AND "zarizeni_nenapojeno"."okres_nuts_kod" = "nrpzs"."OkresCode"
QUALIFY "row_number" = '1'
;

DELETE FROM "zarizeni_nenapojeno"
WHERE "zarizeni_kod" IN (SELECT "zarizeni_kod"
                         FROM "zarizeni_nrpzs_ciselnik" )
               
;

//zbyva nam jeste 14 nenapojenych zarizeni, ty propojime s ciselnikem okresu, abychom, zjistily jmeno okresu a mohly podle toho urcite alespon pribliznou lokaci 
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_okres_ciselnik" AS
SELECT "zarizeni_nenapojeno".*
       ,"okresy"."okres_nuts_nazev" AS "okres_nuts_nazev"
FROM "zarizeni_nenapojeno"
LEFT JOIN "okresy"
ON "zarizeni_nenapojeno"."okres_nuts_kod" =  "okresy"."okres_nuts_kod"
;

//napojeni vsech dilcich ciselniku na ockovaci zarizeni, abychom mohly poslat do geo extraktoru pro ziskani lokaci (dle adresy - uzis, nrpzs nebo pouze okresu)
CREATE OR REPLACE TABLE "ockovaci_zarizeni_mezistav" AS
SELECT "ockovaci_zarizeni"."zarizeni_kod"
      ,"ockovaci_zarizeni"."zarizeni_nazev"
      ,"ockovaci_zarizeni"."kraj_nuts_kod"
      ,"ockovaci_zarizeni"."okres_nuts_kod"
      ,"zarizeni_uzis_ciselnik"."kod_obce"
      ,"zarizeni_uzis_ciselnik"."adresa" AS "uzis_adresa"
      ,"zarizeni_nrpzs_ciselnik"."adresa" AS "nrpzs_adresa"
      ,"zarizeni_okres_ciselnik"."okres_nuts_nazev" AS "adresa_okres"
      ,COALESCE("uzis_adresa","nrpzs_adresa","adresa_okres") AS "adresa"
      ,"zarizeni_nrpzs_ciselnik"."latitude" AS "nrpzs_latitude"
      ,"zarizeni_nrpzs_ciselnik"."longitude" AS "nrpzs_longitude"
FROM "ockovaci_zarizeni"
LEFT JOIN "zarizeni_uzis_ciselnik"
ON "ockovaci_zarizeni"."zarizeni_kod" = "zarizeni_uzis_ciselnik"."zarizeni_kod" AND "ockovaci_zarizeni"."okres_nuts_kod" =  "zarizeni_uzis_ciselnik"."okres_nuts_kod"
LEFT JOIN "zarizeni_nrpzs_ciselnik"
ON "ockovaci_zarizeni"."zarizeni_kod" = "zarizeni_nrpzs_ciselnik"."zarizeni_kod" AND "ockovaci_zarizeni"."okres_nuts_kod" =  "zarizeni_nrpzs_ciselnik"."okres_nuts_kod"
LEFT JOIN "zarizeni_okres_ciselnik"
ON "ockovaci_zarizeni"."zarizeni_kod" = "zarizeni_okres_ciselnik"."zarizeni_kod" AND "ockovaci_zarizeni"."okres_nuts_kod" =  "zarizeni_okres_ciselnik"."okres_nuts_kod"
;