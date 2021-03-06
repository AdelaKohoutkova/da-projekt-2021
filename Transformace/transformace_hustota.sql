// transformace z tabulky "in_zaklad_vypocet_hustota" na dve dilci tabulky pro okresy a kraje: "hustota_okres", "hustota_kraj"
zakladni tabulka obsahuje udaje o poctu obyvatel a rozloze v ha pro jednotlive obce
transformaci docilime prevodu ha na km2 a vypocitani hustoty obyvatel na urovni okresu a kraju 


CREATE OR REPLACE TEMPORARY TABLE "zaklad_vypocet_hustota_temp" AS
SELECT *
FROM "in_zaklad_vypocet_hustota";

CREATE OR REPLACE TABLE "hustota_okres" AS
SELECT "kraj_nuts_kod"
       , "okres_nuts_kod"
       , round("vymera_ha"/100) AS "vymera_km2"
       , round("pocet_obyvatel"/"vymera_km2") AS "hustota_obyvatel"
FROM (
        SELECT "kraj_nuts_kod"
                ,"okres_nuts_kod"
                , SUM("pocet_obyvatel") AS "pocet_obyvatel"
                , SUM("vymera_ha") AS "vymera_ha"
        FROM "zaklad_vypocet_hustota_temp"
        GROUP BY "kraj_nuts_kod","okres_nuts_kod"
);

CREATE OR REPLACE TABLE "hustota_kraj" AS
SELECT "kraj_nuts_kod"
       , round("vymera_ha"/100) AS "vymera_km2"
       , round("pocet_obyvatel"/"vymera_km2") AS "hustota_obyvatel"
FROM (
        SELECT "kraj_nuts_kod"
                , SUM("pocet_obyvatel") AS "pocet_obyvatel"
                , SUM("vymera_ha") AS "vymera_ha"
        FROM "zaklad_vypocet_hustota_temp"
        GROUP BY "kraj_nuts_kod"
);

//vysledne tabulky obsahuji okres nebo kraj_nuts_kod, vymera_km2 a hustota_obyvatel
pro 77 jednotek = okresu, je tam i zahrnuta Praha (ale oficialne se nepocita do okresu)
pro 14 kraju vcetne Hlavniho mesta Prahy
Praha v tabulce hustota_okres = Praha v tabulce hustota_kraj
vysledek je zaokrohlen na cela cisla, v pripade potreby lze rozsirit