-- agregace a přetypování vstupní tabulky se spotřebou
CREATE OR REPLACE TABLE "spotreba_ockovaci_mista" AS 
SELECT TO_DATE("datum", 'YYYY-MM-DD') AS "datum"
        , "ockovaci_misto_id"
        , "kraj_nuts_kod"
        , "ockovaci_latka"
        , "vyrobce"
        , SUM(TO_NUMBER("pouzite_ampulky")) AS "pouzite_ampulky"
        , SUM(TO_NUMBER("pouzite_davky")) AS "pouzite_davky"
        , SUM(TO_NUMBER("znehodnocene_ampulky")) AS "znehodnocene_ampulky"
        , SUM(TO_NUMBER("znehodnocene_davky")) AS "znehodnocene_davky"
FROM "in_spotreba_ockovaci_mista"
GROUP BY "datum"
            , "ockovaci_misto_id"
            , "kraj_nuts_kod"
            , "ockovaci_latka"
            , "vyrobce"
;