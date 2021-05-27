-- tranformace pro vytvoření tabulky se zdravotnickými zařízeními

-- vytvořena tabulka s aktuálními zařízeními pro další práci
CREATE OR REPLACE TEMPORARY TABLE "aktualni_zarizeni" AS 
SELECT "kod"
        , "naz"
        , "drzar"
        , "ulice"
        , "psc"
        , "zujedn"
        , "nazob"
FROM "in_zarizeni"
WHERE "plati_do" IS NULL
;

-- manuální doplnění informací do tabulky s aktuálními zařízeními
UPDATE "aktualni_zarizeni"
SET "zujedn" = '535451' WHERE "zujedn" IS NULL AND "nazob" = 'Benátky nad Jizerou'
;

UPDATE "aktualni_zarizeni"
SET "zujedn" = '593583'
WHERE "zujedn" IS NULL AND "nazob" = 'Slavkov u Brna'
;

UPDATE "aktualni_zarizeni"
SET "zujedn" = '500089'
WHERE "zujedn" IS NULL 
        AND "nazob" = 'Praha'
        AND "kod" = '63109298000';

UPDATE "aktualni_zarizeni"
SET "zujedn" = '500119'
WHERE "zujedn" IS NULL 
        AND "nazob" = 'Praha'
        AND "kod" = '49276344000';

UPDATE "aktualni_zarizeni"
SET "zujedn" = '500178'
WHERE "zujedn" IS NULL 
        AND "nazob" = 'Praha'
        AND "kod" = '60163275000';

-- vytvoření finální tabulky s přehledem zdravotnických zařízení
CREATE OR REPLACE TABLE "zarizeni" AS 
SELECT "kod" AS "zarizeni_kod"
        , "naz" AS "zarizeni_nazev"
        , "drzar" AS "druh_zarizeni"
        , "zujedn" AS "kod_obce"
        , CASE WHEN "ulice" IS NULL 
                    AND "psc" IS NULL 
                    AND "aktualni_zarizeni"."zujedn" IS NULL 
                 THEN NULL
               WHEN "ulice" IS NULL 
                    AND "psc" IS NULL 
                 THEN COALESCE("in_zujedn_nuts"."zujedn_nazev", "in_zuj_praha"."zujedn_nazev")
               WHEN "ulice" IS NULL 
                 THEN CONCAT(COALESCE("in_zujedn_nuts"."zujedn_nazev", "in_zuj_praha"."zujedn_nazev"), ', ', "psc")
               ELSE CONCAT("ulice",', ', COALESCE("in_zujedn_nuts"."zujedn_nazev", "in_zuj_praha"."zujedn_nazev"), ', ', "psc")
            END "adresa"
        , COALESCE("in_zujedn_nuts"."okres_nuts_kod", "in_zuj_praha"."okres_nuts_kod") AS "okres_nuts_kod"
        , COALESCE("in_zujedn_nuts"."kraj_nuts_kod", "in_zuj_praha"."kraj_nuts_kod") AS "kraj_nuts_kod"
FROM "aktualni_zarizeni"
LEFT JOIN "in_zujedn_nuts"
    ON "in_zujedn_nuts"."zujedn_kod" = "aktualni_zarizeni"."zujedn"
LEFT JOIN "in_zuj_praha" 
		ON "in_zuj_praha"."zujedn_kod" = "aktualni_zarizeni"."zujedn"
;