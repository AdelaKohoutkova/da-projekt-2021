-- Na základě tabulky s vypočteným poměrem z předchozí transformace je vypočítáno očkování rozvážené na jednotlivá očkovací místa (pozn. pro zařízení a místa bez problémů, ponechány původní hodnoty, pro zařízení s více očkovacími místy je aplikován vypočtený poměr)

CREATE OR REPLACE TABLE "out_ockovani" AS 
SELECT "ockovani_zarizeni"."datum"
        , "ockovani_zarizeni"."zarizeni_kod"
        , "ockovaci_mista_zarizeni_rozvazeni"."ockovaci_misto_id"
        , "ockovaci_mista_zarizeni_rozvazeni"."kraj_nuts_kod"
        , "kraje"."kraj_nuts_nazev"
        , "ockovaci_mista_zarizeni_rozvazeni"."okres_nuts_kod"
        , "okresy"."okres_nuts_nazev"
        , "ockovani_zarizeni"."vakcina"
        , "ockovani_zarizeni"."poradi_davky"
        , "ockovani_zarizeni"."vekova_skupina"
        , CASE  WHEN "ockovaci_mista_zarizeni_rozvazeni"."zarizeni_kod" IS NULL THEN ROUND("ockovani_zarizeni"."pocet_ockovanych")
                ELSE ROUND("ockovani_zarizeni"."pocet_ockovanych" * "ockovaci_mista_zarizeni_rozvazeni"."rozvazeci_pomer")
          END "pocet_ockovanych_misto"
FROM "ockovani_zarizeni"
LEFT JOIN "ockovaci_mista_zarizeni_rozvazeni"
    ON "ockovani_zarizeni"."zarizeni_kod" = "ockovaci_mista_zarizeni_rozvazeni"."zarizeni_kod"
LEFT JOIN "kraje"
    ON "ockovaci_mista_zarizeni_rozvazeni"."kraj_nuts_kod" = "kraje"."kraj_nuts_kod"
LEFT JOIN "okresy"
    ON "ockovaci_mista_zarizeni_rozvazeni"."okres_nuts_kod" = "okresy"."okres_nuts_kod"
;

-- protože ne každý den se očkuje v každé věkové skupině oběma dávkami je potřeba pro správnou práci Tableau s populací vložit chybějící řádky do tabulky

-- nejprve pro druhou dávku
INSERT INTO "out_ockovani"
("datum"
 , "zarizeni_kod"
 , "ockovaci_misto_id"
 , "kraj_nuts_kod"
 , "kraj_nuts_nazev"
 , "okres_nuts_kod"
 , "okres_nuts_nazev"
 , "vakcina"
 , "poradi_davky"
 , "vekova_skupina"
 , "pocet_ockovanych_misto")

WITH "ockovani_okres" AS
    (SELECT "okres_nuts_kod"
            , "vekova_skupina"
            , SUM("pocet_ockovanych_misto") "pocet_ockovanych"
        FROM "out_ockovani"
        WHERE "poradi_davky" = 2
        GROUP BY "okres_nuts_kod"
            , "vekova_skupina"
    ),
 "populace_okres" AS
    (SELECT "kraj_nuts_kod"
            , "kraj_nuts_nazev"
            , "okres_nuts_kod"
            , "okres_nuts_nazev"
            , "vekova_skupina"
            , SUM("pocet_obyvatel") "pocet_obyvatel"
        FROM "out_populace"
        GROUP BY "kraj_nuts_kod"
            , "kraj_nuts_nazev"
            , "okres_nuts_kod"
            , "okres_nuts_nazev"
            , "vekova_skupina")

SELECT NULL AS "datum"
        , NULL AS "zarizeni_kod"
        , NULL AS "ockovaci_misto_id"
        , "populace_okres"."kraj_nuts_kod"
        , "populace_okres"."kraj_nuts_nazev"
        , "populace_okres"."okres_nuts_kod"
        , "populace_okres"."okres_nuts_nazev"
        , NULL AS "vakcina"
        , 2 AS "poradi_davky"
        , "populace_okres"."vekova_skupina"
        , 0 AS "pocet_ockovanych_misto"
FROM "populace_okres"
LEFT JOIN "ockovani_okres"
    ON "populace_okres"."okres_nuts_kod" = "ockovani_okres"."okres_nuts_kod"
         AND "populace_okres"."vekova_skupina" = "ockovani_okres"."vekova_skupina"
WHERE "ockovani_okres"."okres_nuts_kod" IS NULL
ORDER BY "ockovani_okres"."okres_nuts_kod"
;

-- poté i pro druhou dávku
INSERT INTO "out_ockovani"
("datum"
 , "zarizeni_kod"
 , "ockovaci_misto_id"
 , "kraj_nuts_kod"
 , "kraj_nuts_nazev"
 , "okres_nuts_kod"
 , "okres_nuts_nazev"
 , "vakcina"
 , "poradi_davky"
 , "vekova_skupina"
 , "pocet_ockovanych_misto")

WITH "ockovani_okres" AS
    (SELECT "okres_nuts_kod"
            , "vekova_skupina"
            , SUM("pocet_ockovanych_misto") "pocet_ockovanych"
        FROM "out_ockovani"
        WHERE "poradi_davky" = 1
        GROUP BY "okres_nuts_kod"
            , "vekova_skupina"
    ),
 "populace_okres" AS
    (SELECT "kraj_nuts_kod"
            , "kraj_nuts_nazev"
            , "okres_nuts_kod"
            , "okres_nuts_nazev"
            , "vekova_skupina"
            , SUM("pocet_obyvatel") "pocet_obyvatel"
        FROM "out_populace"
        GROUP BY "kraj_nuts_kod"
            , "kraj_nuts_nazev"
            , "okres_nuts_kod"
            , "okres_nuts_nazev"
            , "vekova_skupina")

SELECT NULL AS "datum"
        , NULL AS "zarizeni_kod"
        , NULL AS "ockovaci_misto_id"
        , "populace_okres"."kraj_nuts_kod"
        , "populace_okres"."kraj_nuts_nazev"
        , "populace_okres"."okres_nuts_kod"
        , "populace_okres"."okres_nuts_nazev"
        , NULL AS "vakcina"
        , 1 AS "poradi_davky"
        , "populace_okres"."vekova_skupina"
        , 0 AS "pocet_ockovanych_misto"
FROM "populace_okres"
LEFT JOIN "ockovani_okres"
    ON "populace_okres"."okres_nuts_kod" = "ockovani_okres"."okres_nuts_kod"
         AND "populace_okres"."vekova_skupina" = "ockovani_okres"."vekova_skupina"
WHERE "ockovani_okres"."okres_nuts_kod" IS NULL
ORDER BY "ockovani_okres"."okres_nuts_kod"
;

------------------------------------------------------
-- KONTROLA ROZVÁŽENÍ

/* --KONTROLA - celkový počet rozvážení vs. původní
-- počet očkovaných po rozvážení
SELECT DISTINCT SUM("pocet_ockovanych_misto")
FROM 
(SELECT "ockovani_zarizeni"."datum"
        , "ockovani_zarizeni"."zarizeni_kod"
        , "ockovaci_mista_zarizeni_rozvazeni"."ockovaci_misto_id"
        , "ockovani_zarizeni"."vakcina"
        , "ockovani_zarizeni"."poradi_davky"
        , "ockovani_zarizeni"."vekova_skupina"
        , CASE  WHEN "ockovaci_mista_zarizeni_rozvazeni"."zarizeni_kod" IS NULL THEN ROUND("ockovani_zarizeni"."pocet_ockovanych")
                ELSE ROUND("ockovani_zarizeni"."pocet_ockovanych" * "ockovaci_mista_zarizeni_rozvazeni"."rozvazeci_pomer")
          END "pocet_ockovanych_misto"
FROM "ockovani_zarizeni"
LEFT JOIN "ockovaci_mista_zarizeni_rozvazeni"
    ON "ockovani_zarizeni"."zarizeni_kod" = "ockovaci_mista_zarizeni_rozvazeni"."zarizeni_kod")
;

--počet očkovaných v původní tabulce
SELECT SUM("pocet_ockovanych")
FROM "ockovani_zarizeni"
;

-- kontrola za jednotlivé dny - při zaokrouhlení na celé lidi
WITH 
    "ockovani_vypocet" AS 
        (SELECT "datum", "zarizeni_kod", "vakcina", "poradi_davky", "vekova_skupina", SUM("pocet_ockovanych_misto") AS "pocet_ockovanych_vypocet"
        FROM "out_ockovani"
        GROUP BY "datum", "zarizeni_kod", "vakcina", "poradi_davky", "vekova_skupina")

  ,"ockovani_puvodni" AS
    (SELECT *
        FROM "ockovani_zarizeni")

SELECT "zarizeni_kod", SUM("kontrola_vypoctu")
FROM

(SELECT "ockovani_vypocet".*
          ,"ockovani_puvodni"."pocet_ockovanych" AS "pocet_ockovanych_puvodni"
          , "ockovani_vypocet"."pocet_ockovanych_vypocet" - "pocet_ockovanych_puvodni" AS "kontrola_vypoctu"
  FROM "ockovani_vypocet"
  JOIN "ockovani_puvodni"
          ON "ockovani_vypocet"."datum" = "ockovani_puvodni"."datum"
              AND "ockovani_vypocet"."zarizeni_kod" = "ockovani_puvodni"."zarizeni_kod"
              AND "ockovani_vypocet"."vakcina" = "ockovani_puvodni"."vakcina"
              AND "ockovani_vypocet"."poradi_davky" = "ockovani_puvodni"."poradi_davky"
              AND "ockovani_vypocet"."vekova_skupina" = "ockovani_puvodni"."vekova_skupina"
 --WHERE "kontrola_vypoctu" <> 0
)

GROUP BY "zarizeni_kod"
HAVING SUM("kontrola_vypoctu") <> 0
;

-- důkaz chyby zaokrouhlení
-- bez round
CREATE OR REPLACE TABLE "out_ockovani" AS 
SELECT "ockovani_zarizeni"."datum"
        , "ockovani_zarizeni"."zarizeni_kod"
        , "ockovaci_mista_zarizeni_rozvazeni"."ockovaci_misto_id"
        , "ockovani_zarizeni"."vakcina"
        , "ockovani_zarizeni"."poradi_davky"
        , "ockovani_zarizeni"."vekova_skupina"
        , CASE  WHEN "ockovaci_mista_zarizeni_rozvazeni"."zarizeni_kod" IS NULL THEN "ockovani_zarizeni"."pocet_ockovanych"
                ELSE "ockovani_zarizeni"."pocet_ockovanych" * "ockovaci_mista_zarizeni_rozvazeni"."rozvazeci_pomer"
          END "pocet_ockovanych_misto"
FROM "ockovani_zarizeni"
LEFT JOIN "ockovaci_mista_zarizeni_rozvazeni"
    ON "ockovani_zarizeni"."zarizeni_kod" = "ockovaci_mista_zarizeni_rozvazeni"."zarizeni_kod"
;

-- kontrola za jednotlivé dny - bez zaokrouhlení na celé lidi
WITH 
    "ockovani_vypocet" AS 
        (SELECT "datum", "zarizeni_kod", "vakcina", "poradi_davky", "vekova_skupina", SUM("pocet_ockovanych_misto") AS "pocet_ockovanych_vypocet"
        FROM "out_ockovani"
        GROUP BY "datum", "zarizeni_kod", "vakcina", "poradi_davky", "vekova_skupina")

  ,"ockovani_puvodni" AS
    (SELECT *
        FROM "ockovani_zarizeni")

SELECT "zarizeni_kod", SUM("kontrola_vypoctu")
FROM

(SELECT "ockovani_vypocet".*
          ,"ockovani_puvodni"."pocet_ockovanych" AS "pocet_ockovanych_puvodni"
          , "ockovani_vypocet"."pocet_ockovanych_vypocet" - "pocet_ockovanych_puvodni" AS "kontrola_vypoctu"
  FROM "ockovani_vypocet"
  JOIN "ockovani_puvodni"
          ON "ockovani_vypocet"."datum" = "ockovani_puvodni"."datum"
              AND "ockovani_vypocet"."zarizeni_kod" = "ockovani_puvodni"."zarizeni_kod"
              AND "ockovani_vypocet"."vakcina" = "ockovani_puvodni"."vakcina"
              AND "ockovani_vypocet"."poradi_davky" = "ockovani_puvodni"."poradi_davky"
              AND "ockovani_vypocet"."vekova_skupina" = "ockovani_puvodni"."vekova_skupina"
 --WHERE "kontrola_vypoctu" <> 0
)

GROUP BY "zarizeni_kod"
HAVING SUM("kontrola_vypoctu") <> 0
;*/

-- zařízení 29090300000 - očekávaná chyba, protože po rozvážení není součet 1.000000, ale 1.000002