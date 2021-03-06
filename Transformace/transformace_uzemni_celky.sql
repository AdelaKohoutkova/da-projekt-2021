---- tranformace pro převod vstupní tabulky s kompletní strukturou území ČR (in_struktura_uzemi_cr)
  -- výsledkem jsou výstupní tabulky, kde je:
        -- číselník krajů (kraje) - kódy a názvy
        -- číselník okresů (okresy) - kódy a názvy

-- celkem 14 řádek k 1.1.2021 
CREATE OR REPLACE TABLE "kraje" AS 
SELECT DISTINCT "kraj_kod" AS "kraj_nuts_kod"
                , "kraj_nazev" AS "kraj_nuts_nazev"
FROM "in_struktura_uzemi_cr"
ORDER BY "kraj_nuts_kod"
;

-- celkem 77 řádek k 1.1.2021 
CREATE OR REPLACE TABLE "okresy" AS 
SELECT DISTINCT "okres_kod" AS "okres_nuts_kod"
                , "okres_nazev" AS "okres_nuts_nazev"
FROM "in_struktura_uzemi_cr"
ORDER BY "okres_nuts_kod"
;

-- celkem 77 řádek k 1.1.2021
CREATE OR REPLACE TABLE "kraje_okresy" AS 
SELECT DISTINCT "okres_kod" AS "okres_nuts_kod"
                , "okres_nazev" AS "okres_nuts_nazev"
                , "kraj_kod" AS "kraj_nuts_kod"
                , "kraj_nazev" AS "kraj_nuts_nazev"
FROM "in_struktura_uzemi_cr"
ORDER BY "okres_nuts_kod"
;