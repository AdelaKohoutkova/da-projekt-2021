-- tranformace pro vytvoření tabulek průměrného věku po jednotlivých okresech (vek_okres) a krajích (vek_kraj)
CREATE OR REPLACE TABLE "vek_okres" AS 
SELECT "oblast_kod" AS "okres_nuts_kod"
        , TO_NUMBER("vek_prumer", 38, 2) AS "vek_prumer"
FROM "in_vek_prumer"
WHERE TO_DATE("obdobi", 'DD.MM.YYYY') = (SELECT MAX(TO_DATE("obdobi", 'DD.MM.YYYY'))
                                            FROM "in_vek_prumer")
          AND "oblast_kategorie" = 'okres'
;

CREATE OR REPLACE TABLE "vek_kraj" AS 
SELECT "oblast_kod" AS "kraj_nuts_kod"
        , TO_NUMBER("vek_prumer", 38, 2) AS "vek_prumer"
FROM "in_vek_prumer"
WHERE TO_DATE("obdobi", 'DD.MM.YYYY') = (SELECT MAX(TO_DATE("obdobi", 'DD.MM.YYYY'))
                                            FROM "in_vek_prumer")
          AND "oblast_kategorie" = 'kraj'
;