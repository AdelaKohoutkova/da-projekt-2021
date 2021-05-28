CREATE OR REPLACE TABLE "out_ockovaci_mista_zarizeni" AS
SELECT *
FROM "ockovaci_zarizeni"
UNION
SELECT *
FROM "ockovaci_mista";