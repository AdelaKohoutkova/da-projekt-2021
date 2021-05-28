-- Transformace vypočítává základní metriky pro jednotlivá očkovací místa - výstupem je tabulka pro Tableau
  -- datum s prvním záznamem v očkování (zacatek_ockovani)
  -- datum s posledním záznamem v očkování (posledni_ockovani)
  -- na základě toho je vypočten denní průměr za očkující dny (denni_prumer_ockujici_dny)
  -- informace o tom, zda za poslední týden očkovací místo očkovalo (ockuje_poslednich_7_dni)
  -- informace o tom, zda vůbec někdy očkoval, protože jsou v číselníku zařízení, která nemají žádný záznam v očkování (ockoval_nekdy)
  
CREATE OR REPLACE TEMPORARY TABLE "prumer_vsechny_dny" AS 
SELECT DISTINCT "out_ockovani"."ockovaci_misto_id"
        , MIN("datum") OVER (PARTITION BY "ockovaci_misto_id") AS "zacatek_ockovani"
        , MAX("datum") OVER (PARTITION BY "ockovaci_misto_id") AS "posledni_ockovani"
        , DATEDIFF(day, "zacatek_ockovani", "posledni_ockovani") AS "pocet_dni"
        , SUM("pocet_ockovanych_misto") OVER (PARTITION BY "ockovaci_misto_id") AS "pocet_ockovanych_celkem"
        , CASE  WHEN "pocet_dni" = 0 THEN "pocet_ockovanych_celkem"
                ELSE ROUND("pocet_ockovanych_celkem" / "pocet_dni", 0)
          END AS "denni_prumer"
        , COUNT(DISTINCT "datum") OVER (PARTITION BY "ockovaci_misto_id") AS "pocet_dni_ockujici_dny"
        , ROUND("pocet_ockovanych_celkem" / "pocet_dni_ockujici_dny", 0) AS "denni_prumer_ockujici_dny"
        , CASE  WHEN "posledni_ockovani" >= CURRENT_DATE() - 7 THEN 1
                ELSE 0
          END AS "ockuje_poslednich_7_dni"
        , CASE  WHEN "pocet_ockovanych_celkem" > 0 THEN 1
                ELSE 0
          END AS "ockoval_nekdy"
FROM "out_ockovani"
WHERE "ockovaci_misto_id" IS NOT NULL -- odstraníme očkovací místa, která nejsou v číselníku se zařízeními a místy
;

/*
-- kontrola nějakého záznamu
select *
from "prumer_vsechny_dny"
WHERE "ockovaci_misto_id" = '64965996000'
;

-- 931fb801-8158-4fc2-ac92-2c68d76907d7
    -- nejmenší datum 2021-01-27
    -- největší datum 2021-05-20
    -- počet dní: 113
    -- počet očkujících dní: 72
    -- počet očkovaných 9 983
SELECT count(distinct "datum")--* --SUM("pocet_ockovanych_misto")
FROM "out_ockovani"
WHERE "ockovaci_misto_id" = '931fb801-8158-4fc2-ac92-2c68d76907d7'
ORDER BY "datum" desc;
*/

CREATE OR REPLACE TABLE "out_ockovaci_mista_zarizeni_dalsi_info" AS 
SELECT "out_ockovaci_mista_zarizeni"."ockovaci_misto_id"
        , "prumer_vsechny_dny"."zacatek_ockovani"
        , "prumer_vsechny_dny"."posledni_ockovani"
        , CASE  WHEN "prumer_vsechny_dny"."pocet_ockovanych_celkem" IS NOT NULL THEN "prumer_vsechny_dny"."pocet_ockovanych_celkem"
                ELSE 0
          END AS "pocet_ockovanych_celkem"
        , CASE  WHEN "prumer_vsechny_dny"."denni_prumer" IS NOT NULL THEN "prumer_vsechny_dny"."denni_prumer"
                ELSE 0
          END AS "denni_prumer"
        , CASE  WHEN "prumer_vsechny_dny"."pocet_dni_ockujici_dny" IS NOT NULL THEN "prumer_vsechny_dny"."pocet_dni_ockujici_dny"
                ELSE 0
          END AS "pocet_dni_ockujici_dny"
        , CASE  WHEN "prumer_vsechny_dny"."denni_prumer_ockujici_dny" IS NOT NULL THEN "prumer_vsechny_dny"."denni_prumer_ockujici_dny"
                ELSE 0
          END AS "denni_prumer_ockujici_dny"
        , CASE  WHEN "prumer_vsechny_dny"."ockuje_poslednich_7_dni" IS NOT NULL THEN "prumer_vsechny_dny"."ockuje_poslednich_7_dni"
                ELSE 0
          END AS "ockuje_poslednich_7_dni"
        , CASE  WHEN "prumer_vsechny_dny"."ockoval_nekdy" IS NOT NULL THEN "prumer_vsechny_dny"."ockoval_nekdy"
                ELSE 0
          END AS "ockoval_nekdy"
FROM "out_ockovaci_mista_zarizeni"
LEFT JOIN "prumer_vsechny_dny"
        ON "prumer_vsechny_dny"."ockovaci_misto_id" = "out_ockovaci_mista_zarizeni"."ockovaci_misto_id"
;

/*
-- kontrola kolik ockovacich zarizeni je v číselníku out_ockovaci_mista_zarizeni a nemá záznam v očkování
SELECT *
FROM "out_ockovani"
LEFT JOIN "out_ockovaci_mista_zarizeni"
    ON "out_ockovani"."zarizeni_kod" = "out_ockovaci_mista_zarizeni"."zarizeni_kod"
WHERE "out_ockovaci_mista_zarizeni"."zarizeni_kod" IS NULL
        AND "datum" IS NOT NULL
        AND "out_ockovani"."ockovaci_misto_id" IS NULL
;

SELECT *
FROM "out_ockovani"
LEFT JOIN "out_ockovaci_mista_zarizeni"
    ON "out_ockovani"."ockovaci_misto_id" = "out_ockovaci_mista_zarizeni"."ockovaci_misto_id"
WHERE "out_ockovaci_mista_zarizeni"."ockovaci_misto_id" IS NULL
        AND "datum" IS NOT NULL
;

SELECT *
FROM "out_ockovaci_mista_zarizeni"
;

SELECT *
FROM "out_ockovaci_mista_zarizeni_dalsi_info"
;
*/