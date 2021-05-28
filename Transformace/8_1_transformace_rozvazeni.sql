-- rozvážení dle záznamů ve spotřebě přes celé období
  
 -- nejprve očistíme tabulku spotřeby, abychom mohli zjišťovat dál
 		-- ponecháme pouze záznamy, které datumově pasují na záznamy v očkování
    -- odstraníme záznamy, které mají vykázány pouzite_davky = 0
CREATE OR REPLACE TEMPORARY TABLE "cista_spotreba" AS
SELECT "spotreba_ockovaci_mista"."ockovaci_misto_id"
        , "ockovaci_mista"."ockovaci_misto_nazev"
        , "spotreba_ockovaci_mista"."kraj_nuts_kod"
        , "ockovaci_mista"."okres_nuts_kod"
        , "ockovaci_mista"."operacni_status"
        , "ockovaci_mista"."ockovaci_misto_adresa"
        , "ockovaci_mista"."latitude"
        , "ockovaci_mista"."longitude"
        , "ockovaci_mista"."ockovaci_misto_typ"
        , "ockovaci_mista"."minimalni_kapacita"
        , "ockovaci_mista"."bezbarierovy_pristup"
        , "ockovaci_mista"."zarizeni_kod"
        , SUM("spotreba_ockovaci_mista"."pouzite_davky") AS "pouzite_davky_misto_celkem"
                -- počet spotřebovaných dávek vakcíny daného očkovacího místa
        --, SUM("spotreba_ockovaci_mista"."znehodnocene_davky") AS "znehodnocene_davky_misto_celkem"
                -- počet znehodnocených dávek vakcíny daného očkovacího místa
FROM "spotreba_ockovaci_mista"
JOIN "ockovaci_mista"
    ON "spotreba_ockovaci_mista"."ockovaci_misto_id" = "ockovaci_mista"."ockovaci_misto_id" 
WHERE ("datum" <=  (SELECT MAX("datum")
                    FROM "ockovani_zarizeni")
          AND "datum" >= (SELECT MIN("datum")
                            FROM "ockovani_zarizeni"))
        AND "spotreba_ockovaci_mista"."pouzite_davky" > 0
GROUP BY "spotreba_ockovaci_mista"."ockovaci_misto_id"
        , "ockovaci_mista"."ockovaci_misto_nazev"
        , "spotreba_ockovaci_mista"."kraj_nuts_kod"
        , "ockovaci_mista"."okres_nuts_kod"
        , "ockovaci_mista"."operacni_status"
        , "ockovaci_mista"."ockovaci_misto_adresa"
        , "ockovaci_mista"."latitude"
        , "ockovaci_mista"."longitude"
        , "ockovaci_mista"."ockovaci_misto_typ"
        , "ockovaci_mista"."minimalni_kapacita"
        , "ockovaci_mista"."bezbarierovy_pristup"
        , "ockovaci_mista"."zarizeni_kod"
        ;

-- výpočet rozvážecího poměru pro jednotlivá očkovací místa z tabulky spotřeby
	-- sloupec "rozvazeci_pomer" dále použit v transformaci
CREATE OR REPLACE TEMPORARY TABLE "spotreba_rozvazeni" AS
SELECT "ockovaci_misto_id"
        , "ockovaci_misto_nazev"
        , "kraj_nuts_kod"
        , "okres_nuts_kod"
        , "zarizeni_kod"
        , "pouzite_davky_misto_celkem"
        , SUM("pouzite_davky_misto_celkem")
                OVER (PARTITION BY "zarizeni_kod") AS "pouzite_davky_zarizeni_celkem"
               -- počet spotřebovaných dávek konkrétní vakcíny k danému dni za dané zařízení
        , "pouzite_davky_misto_celkem" / "pouzite_davky_zarizeni_celkem" AS "rozvazeci_pomer"
FROM "cista_spotreba"
;

-- zjištění, která zařízení mají více očkovacích míst
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_vice_mist" AS
SELECT "zarizeni_kod", COUNT("ockovaci_misto_id") AS "pocet_ockovacich_mist"
FROM "ockovaci_mista"
GROUP BY "zarizeni_kod"
HAVING "pocet_ockovacich_mist" > 1
;

-- vycházíme z předpokladu, že všechna místa v tabulce se seznamem očkovacích míst ("ockovaci_mista") očkují
-- protože tabulka spotřeby nemusí být dokonalá a některá zařízení mohou chybět, budeme postupovat tak, že pokud jsou všechna místa ve spotřebě pro dané zařízení, použijeme poměr ze spotřeby, pokud ne, použijeme kritérium rozpočítání podle počtu míst na dané zařízení -> proto "row_number"
CREATE OR REPLACE TEMPORARY TABLE "mista_rozvazeci_pomer" AS 
SELECT "ockovaci_mista"."ockovaci_misto_id"
        , "ockovaci_mista"."ockovaci_misto_nazev"
        , "ockovaci_mista"."okres_nuts_kod"
        , "ockovaci_mista"."kraj_nuts_kod"
        , "ockovaci_mista"."operacni_status"
        , "ockovaci_mista"."ockovaci_misto_adresa"
        , "ockovaci_mista"."latitude"
        , "ockovaci_mista"."longitude"
        , "ockovaci_mista"."ockovaci_misto_typ"
        , "ockovaci_mista"."zarizeni_kod"
        , "ockovaci_mista"."minimalni_kapacita"
        , "ockovaci_mista"."bezbarierovy_pristup"
        , "zarizeni_vice_mist"."pocet_ockovacich_mist"
        , "spotreba_rozvazeni"."rozvazeci_pomer"
        , SUM("spotreba_rozvazeni"."rozvazeci_pomer") OVER (PARTITION BY "ockovaci_mista"."zarizeni_kod") AS "kontrola_pomeru"
        , ROW_NUMBER() OVER (PARTITION BY "ockovaci_mista"."zarizeni_kod" ORDER BY "spotreba_rozvazeni"."rozvazeci_pomer" NULLS FIRST) as "row_number"
FROM "ockovaci_mista"
JOIN "zarizeni_vice_mist" ON "ockovaci_mista"."zarizeni_kod" = "zarizeni_vice_mist"."zarizeni_kod"
-- výběr pouze relevantních zařízení (těch, co mají více očkovacích míst)
LEFT JOIN "spotreba_rozvazeni" ON "spotreba_rozvazeni"."ockovaci_misto_id" = "ockovaci_mista"."ockovaci_misto_id"
-- získání rozvážecího poměru získaného ze spotřeby
ORDER BY "ockovaci_mista"."zarizeni_kod", "row_number"
;

--------------------------------------
-- finální získání rozvážecího poměru
	-- použijeme kritérium zmíněné výše, pokud mají všechna očkovací místa pro dané zařízení záznam v tabulce spotřeby, použijeme vypočítaný poměr ze spotřeby, jinak použijeme prostý poměr počtu očkovacích míst na dané zařízení
CREATE OR REPLACE TEMPORARY TABLE "vice_mist_rozvazeci_pomer_final" AS 
SELECT "mista_rozvazeci_pomer".*
        , CASE  WHEN "nelze_rozvazit"."zarizeni_kod" IS NOT NULL THEN 'rozvazeni_pocet_mist'
                ELSE 'rozvazeni_spotreba'
           END AS "typ_rozvazeni"
        , CASE  WHEN "nelze_rozvazit"."zarizeni_kod" IS NOT NULL THEN 1/"mista_rozvazeci_pomer"."pocet_ockovacich_mist"
                ELSE "mista_rozvazeci_pomer"."rozvazeci_pomer"
          END AS "rozvazeci_pomer_final"
        , SUM("rozvazeci_pomer_final") OVER (PARTITION BY "mista_rozvazeci_pomer"."zarizeni_kod") AS "kontrola_rozvazeci_pomer_final"
FROM "mista_rozvazeci_pomer"
LEFT JOIN (SELECT "zarizeni_kod"
            FROM "mista_rozvazeci_pomer"
            WHERE "row_number" = 1
                    AND "rozvazeci_pomer" IS NULL) AS "nelze_rozvazit"
-- když je k dispozici zarizeni_kod v tabulce nelze rozvážit, znamená to, že ze zařízení bylo alespoň 1 místo, které nebylo ve spotřebě
    -- a rozvážíme to podle počtu očkovacích míst pro dané zařízení
      ON "nelze_rozvazit"."zarizeni_kod" = "mista_rozvazeci_pomer"."zarizeni_kod"
ORDER BY "zarizeni_kod"
;

/*
----------------------------------------------------------------------
-- kontrola, kolik to je zařízení
SELECT DISTINCT "ockovani_zarizeni"."zarizeni_kod"
FROM "ockovani_zarizeni"
JOIN "zarizeni_vice_mist" ON "zarizeni_vice_mist"."zarizeni_kod" = "ockovani_zarizeni"."zarizeni_kod"
;

-- kontrola kolik je to míst
SELECT DISTINCT "ockovani_zarizeni"."zarizeni_kod", "vice_mist_rozvazeci_pomer_final"."ockovaci_misto_id"
FROM "ockovani_zarizeni"
JOIN "vice_mist_rozvazeci_pomer_final" ON "vice_mist_rozvazeci_pomer_final"."zarizeni_kod" = "ockovani_zarizeni"."zarizeni_kod"
;
*/

CREATE OR REPLACE TABLE "ockovaci_mista_zarizeni_rozvazeni" AS
SELECT "out_ockovaci_mista_zarizeni"."ockovaci_misto_id"
        , "out_ockovaci_mista_zarizeni"."zarizeni_kod"
        , "out_ockovaci_mista_zarizeni"."kraj_nuts_kod"
        , "out_ockovaci_mista_zarizeni"."okres_nuts_kod"
        , "out_ockovaci_mista_zarizeni"."ockovaci_misto_typ"
        , CASE WHEN "rozvazeci_pomer_final" IS NOT NULL THEN "rozvazeci_pomer_final"
                ELSE 1
          END "rozvazeci_pomer"
        , CASE WHEN "typ_rozvazeni" IS NOT NULL THEN "typ_rozvazeni"
                ELSE 'nerozvazeno'
          END "rozvazeci_pomer_typ"
FROM "out_ockovaci_mista_zarizeni"
LEFT JOIN "vice_mist_rozvazeci_pomer_final"
        ON "out_ockovaci_mista_zarizeni"."ockovaci_misto_id" = "vice_mist_rozvazeci_pomer_final"."ockovaci_misto_id"
;