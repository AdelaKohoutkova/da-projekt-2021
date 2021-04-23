---- tranformace pro převod vstupní tabulky s populací (in_populace_okres) do požadovaného tvaru
  -- výsledkem je výstupní tabulka, kde je počet obyvatel dle 
        -- jednotlivých okresů ČR
        -- věkových kategorií odpovídajících COVID datům (tabulka in_ockovani_ockovaci_mista a in_registrace_ockovaci_mista)

-- požadované výsledné kategorie
/*0-17
18-24
25-29
30-34
35-39
40-44
45-49
50-54
55-59
60-64
65-69
70-74
75-79
80+*/

------------------------------------------------
-- dočasná tabulka "vek_okres"
    -- uvádí počty obyvatel dle jednotlivých okresů (bez rozlišení pohlaví)
    -- upraveny jednotlivé datové typy vstupní tabulky
    -- vybráno pouze nejnovější období
    -- kategorie 100+ upravena na 100, abychom mohli převést na číslo

-- celkem 7 777 řádek = 101 hodnot pro "vek" * 77 záznamů pro "okres_kod" 

CREATE OR REPLACE TEMPORARY TABLE "vek_okres" AS
SELECT TO_DATE("obdobi", 'DD.MM.YYYY') AS "obdobi"
        , TO_NUMBER(REPLACE("vek", '+', '')) AS "vek"
        , "kraj_kod"
        , "okres_kod"
        , SUM(TO_NUMBER("pocet_obyvatel")) "pocet_obyvatel"
FROM "in_populace_okres"
WHERE TO_DATE("obdobi", 'DD.MM.YYYY') = (SELECT MAX(TO_DATE("obdobi", 'DD.MM.YYYY'))
                    FROM "in_populace_okres")
GROUP BY "obdobi"
            , "vek"
            , "kraj_kod"
            , "okres_kod"
;

------------------------------------------------
-- dočasná tabulka "vekova_skupina_okres"
    -- uvádí počty obyvatel dle jednotlivých okresů a věkových kategorií jako v COVID datech
    -- vychází z dočasné tabulky "vek_okres"
    
-- celkem 1 078 řádek = 14 kategorií pro "vek" (pokud neexistuje nezařazeno) * 77 záznamů pro "okres_kod"
CREATE OR REPLACE TEMPORARY TABLE "vekova_skupina_okres" AS
SELECT CASE WHEN "vek" BETWEEN 80 AND 100 THEN '80+'
            WHEN "vek" BETWEEN 75 AND 79 THEN '75-79'
            WHEN "vek" BETWEEN 70 AND 74 THEN '70-74'
            WHEN "vek" BETWEEN 65 AND 69 THEN '65-69'
            WHEN "vek" BETWEEN 60 AND 64 THEN '60-64'
            WHEN "vek" BETWEEN 55 AND 59 THEN '55-59'
            WHEN "vek" BETWEEN 50 AND 54 THEN '50-54'
            WHEN "vek" BETWEEN 45 AND 49 THEN '45-49'
            WHEN "vek" BETWEEN 40 AND 44 THEN '40-44'
            WHEN "vek" BETWEEN 35 AND 39 THEN '35-39'
            WHEN "vek" BETWEEN 30 AND 34 THEN '30-34'
            WHEN "vek" BETWEEN 25 AND 29 THEN '25-29'
            WHEN "vek" BETWEEN 18 AND 24 THEN '18-24'
            WHEN "vek" BETWEEN 0 AND 17 THEN '0-17'
            ELSE 'nezařazeno'
        END "vekova_skupina"
       , "kraj_kod"
       , "okres_kod"
       , SUM("pocet_obyvatel") AS "pocet_obyvatel"
FROM "vek_okres"
--WHERE "vekova_skupina" = 'nezařazeno' -- pro možnou kontrolu
GROUP BY "vekova_skupina"
         , "kraj_kod"
         , "okres_kod"
;

------------------------------------------------
-- výsledná tabulka "populace_okres"
    -- uvádí počty obyvatel dle jednotlivých okresů a věkových kategorií jako v COVID datech
    -- vychází z dočasné tabulky "vekova_skupina_okres"

-- celkem 1 078 řádek = 14 kategorií pro "vek" (pokud neexistuje nezařazeno) * 77 záznamů pro "okres_kod"
CREATE OR REPLACE TABLE "populace_okres" AS
SELECT "vekova_skupina"
        , "okres_kod" AS "okres_nuts_kod"
        , SUM("pocet_obyvatel") AS "pocet_obyvatel"
FROM "vekova_skupina_okres"
GROUP BY "vekova_skupina"
            , "okres_kod"
ORDER BY "okres_kod"
         , "vekova_skupina"
;

------------------------------------------------
-- výsledná tabulka "populace_kraj"
    -- uvádí počty obyvatel dle jednotlivých okresů a věkových kategorií jako v COVID datech
    -- vychází z dočasné tabulky "vekova_skupina_okres"

-- celkem 196 řádek = 14 kategorií pro "vek" (pokud neexistuje nezařazeno) * 14 záznamů pro "okres_kod"
CREATE OR REPLACE TABLE "populace_kraj" AS
SELECT "vekova_skupina"
        , "kraj_kod" AS "kraj_nuts_kod"
        , SUM("pocet_obyvatel") AS "pocet_obyvatel"
FROM "vekova_skupina_okres"
GROUP BY "vekova_skupina"
            , "kraj_kod"
ORDER BY "kraj_kod"
        , "vekova_skupina"
;
