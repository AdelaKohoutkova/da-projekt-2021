-- transformace vytváří tabulky pro použití v Tableau - zejména demografické údaje
  -- jedná se o statické údaje - tj. jednorázová transformace
  
CREATE OR REPLACE TABLE "out_populace" AS
SELECT "populace_okres"."vekova_skupina"
        , "populace_okres"."kraj_nuts_kod"
        , "kraje"."kraj_nuts_nazev"
        , "populace_okres"."okres_nuts_kod"
        , "okresy"."okres_nuts_nazev"
        , "populace_okres"."pocet_obyvatel"
FROM "populace_okres"
LEFT JOIN "kraje" 
    ON "kraje"."kraj_nuts_kod" = "populace_okres"."kraj_nuts_kod"
LEFT JOIN "okresy"
    ON "okresy"."okres_nuts_kod" = "populace_okres"."okres_nuts_kod"
;

INSERT INTO "out_populace"
    ("vekova_skupina"
     , "kraj_nuts_kod"
     , "kraj_nuts_nazev"
     , "okres_nuts_kod"
     , "okres_nuts_nazev"
     , "pocet_obyvatel"
        )

SELECT 'nezařazeno'
        , "kraj_nuts_kod"
        , "kraj_nuts_nazev"
        , "okres_nuts_kod"
        , "okres_nuts_nazev"
        , 0
FROM 
    (SELECT DISTINCT 
            "kraj_nuts_kod"
            , "kraj_nuts_nazev"
            , "okres_nuts_kod"
            , "okres_nuts_nazev"
    FROM "out_populace");

----------------------------------------
CREATE OR REPLACE TABLE "out_kraj" AS
SELECT "hustota_kraj"."kraj_nuts_kod"
       , "hustota_kraj"."vymera_km2"
       , "hustota_kraj"."hustota_obyvatel"
       , "vek_kraj"."vek_prumer"
FROM "hustota_kraj"
LEFT JOIN "vek_kraj"
ON "hustota_kraj"."kraj_nuts_kod" = "vek_kraj"."kraj_nuts_kod"
;

-----------------------------------------
CREATE OR REPLACE TABLE "out_okres" AS
SELECT "hustota_okres"."okres_nuts_kod"
       , "hustota_okres"."kraj_nuts_kod"
       , "hustota_okres"."vymera_km2"
       , "hustota_okres"."hustota_obyvatel"
       , "vek_okres"."vek_prumer"
FROM "hustota_okres"
LEFT JOIN "vek_okres"
ON "hustota_okres"."okres_nuts_kod" = "vek_okres"."okres_nuts_kod";