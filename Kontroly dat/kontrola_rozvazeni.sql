-- byl identifikován problém s rozvážením (O2 universum) - toto OK, ale pro vysvětlení a ověření hypotézy kontrola na příkladu
  -- výpočet na základě záznamů ze spotřeby po dnech 

-- Národní očkovací centrum - 5affc4c2-414a-4cd4-9a04-56647fa66eef
-- zarizeni_kod = 61383082000
SELECT *
FROM "out_ockovaci_mista_zarizeni"
WHERE "ockovaci_misto_nazev" ILIKE '%národní%';

--Národní očkovací centrum (5affc4c2-414a-4cd4-9a04-56647fa66eef) je společně s ÚVN Praha - Vakcinační centrum COVID-19 (4ea9c79c-ebac-4505-8176-7d22ca45c0d2)
SELECT "ockovaci_misto_id"
FROM "out_ockovaci_mista_zarizeni"
WHERE "zarizeni_kod" = '61383082000'
;

------------------------------------------------
-- 1. záznam O2 - 3.5.2021
    -- ÚVN Praha k tomuto dni vyočkováno 52 020 dávek
    -- O2 vyočkovala 2 088
-- poslední záznam - 24.5.2021
    -- ÚVN Praha k tomuto dni vyočkováno 64 770 dávek
    -- O2 vyočkovala 73 776
------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE "spotreba_vyber_pomer" AS 
SELECT  "spotreba_ockovaci_mista"."datum"
        , "ockovaci_misto_nazev"
        , "spotreba_ockovaci_mista"."ockovaci_misto_id"
        , "mista_vyber"."zarizeni_kod"
        , "spotreba_ockovaci_mista"."pouzite_davky"
        , SUM("spotreba_ockovaci_mista"."pouzite_davky") OVER (PARTITION BY "spotreba_ockovaci_mista"."ockovaci_misto_id" ORDER BY "datum") AS "pouzite_davky_misto_kumulativne"
        , SUM("spotreba_ockovaci_mista"."pouzite_davky") OVER (PARTITION BY "mista_vyber"."zarizeni_kod", "datum") AS "pouzite_davky_zarizeni"
        , "denni_prumer"
        , "denni_prumer_ockujici_dny"
        , "spotreba_ockovaci_mista"."pouzite_davky" / "pouzite_davky_zarizeni" AS "rozvazeci_pomer_datum"
        , "rozvazeci_pomer"
        , "rozvazeci_pomer_typ"
        , "ockovaci_latka"
        , "vyrobce"
FROM "spotreba_ockovaci_mista"
JOIN (SELECT *
      FROM "out_ockovaci_mista_zarizeni"
      WHERE "zarizeni_kod" = '61383082000') AS "mista_vyber"
   ON "spotreba_ockovaci_mista"."ockovaci_misto_id" = "mista_vyber"."ockovaci_misto_id"
JOIN "ockovaci_mista_zarizeni_rozvazeni"
    ON "ockovaci_mista_zarizeni_rozvazeni"."ockovaci_misto_id" = "spotreba_ockovaci_mista"."ockovaci_misto_id"
JOIN "out_ockovaci_mista_zarizeni_dalsi_info" ON "out_ockovaci_mista_zarizeni_dalsi_info"."ockovaci_misto_id" = "spotreba_ockovaci_mista"."ockovaci_misto_id"
--WHERE "datum" BETWEEN '2021-05-17' AND '2021-05-24'
ORDER BY  "datum", "spotreba_ockovaci_mista"."ockovaci_misto_id"
;

-- ze spotřeby 138 546
SELECT SUM("pouzite_davky")
FROM "spotreba_vyber_pomer"
WHERE "zarizeni_kod" = '61383082000'
;

-- z rozvážení: celkem 154 241
SELECT SUM("pocet_ockovanych_misto")
FROM "out_ockovani"
WHERE "zarizeni_kod" = '61383082000'
;

-- ze vstupních dat: celkem 154 241
SELECT COUNT(1)
FROM "in_ockovani_ockovaci_mista"
WHERE "zarizeni_kod" = '61383082000'
;

------------------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_vice_mist" AS
SELECT "zarizeni_kod", COUNT("ockovaci_misto_id") AS "pocet_ockovacich_mist"
FROM "ockovaci_mista"
GROUP BY "zarizeni_kod"
HAVING "pocet_ockovacich_mist" > 1
;

CREATE OR REPLACE TEMPORARY TABLE "cista_spotreba" AS
SELECT "spotreba_ockovaci_mista"."datum"
        , "spotreba_ockovaci_mista"."ockovaci_misto_id"
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
FROM "spotreba_ockovaci_mista"
JOIN "ockovaci_mista"
    ON "spotreba_ockovaci_mista"."ockovaci_misto_id" = "ockovaci_mista"."ockovaci_misto_id" 
WHERE ("datum" <=  (SELECT MAX("datum")
                    FROM "ockovani_zarizeni")
          AND "datum" >= (SELECT MIN("datum")
                            FROM "ockovani_zarizeni"))
GROUP BY "spotreba_ockovaci_mista"."datum"
        , "spotreba_ockovaci_mista"."ockovaci_misto_id"
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
HAVING "pouzite_davky_misto_celkem" > 0;

-- jsou očkovací zařízení, která mají více míst - mají vykázáno očkování, ale nemají k tomu dni záznam ve spotřebě
    -- celkem naočkovaly 87 310
    -- zařízení s více místy naočkovala celkem: 845 711
SELECT SUM("pocet_ockovanych")
FROM "zarizeni_vice_mist"
JOIN "ockovani_zarizeni"
    ON "ockovani_zarizeni"."zarizeni_kod" = "zarizeni_vice_mist"."zarizeni_kod"
WHERE NOT EXISTS (select 1
                  from "cista_spotreba"
                  where "cista_spotreba"."zarizeni_kod" =  "ockovani_zarizeni"."zarizeni_kod" 
                        and "cista_spotreba"."datum" =  "ockovani_zarizeni"."datum")
       AND "ockovani_zarizeni"."pocet_ockovanych" > 0
;
--------------------------------------------------------------
-- bylo potřeba ověřit rozvážení a záznamy v Břeclavy (CZ0644)
SELECT *
FROM "out_ockovaci_mista_zarizeni"
WHERE "zarizeni_kod" IN (SELECT "zarizeni_kod"
                          FROM "out_ockovaci_mista_zarizeni"
                          WHERE "okres_nuts_kod" = 'CZ0644'
                                  AND "ockovaci_misto_typ" <> 'ostatni')
ORDER BY "zarizeni_kod";

SELECT  "spotreba_ockovaci_mista"."datum"
        , "ockovaci_misto_nazev"
        , "spotreba_ockovaci_mista"."ockovaci_misto_id"
        , "mista_vyber"."zarizeni_kod"
        , "spotreba_ockovaci_mista"."pouzite_davky"
        , SUM("spotreba_ockovaci_mista"."pouzite_davky") OVER (PARTITION BY "spotreba_ockovaci_mista"."ockovaci_misto_id" ORDER BY "datum") AS "pouzite_davky_misto_kumulativne"
        , SUM("spotreba_ockovaci_mista"."pouzite_davky") OVER (PARTITION BY "mista_vyber"."zarizeni_kod", "datum") AS "pouzite_davky_zarizeni"
        , "denni_prumer"
        , "denni_prumer_ockujici_dny"
        , "spotreba_ockovaci_mista"."pouzite_davky" / "pouzite_davky_zarizeni" AS "rozvazeci_pomer_datum"
        , "rozvazeci_pomer"
        , "rozvazeci_pomer_typ"
        , "ockovaci_latka"
        , "vyrobce"
FROM "spotreba_ockovaci_mista"
JOIN (SELECT *
      FROM "out_ockovaci_mista_zarizeni"
      WHERE "zarizeni_kod" = '00159816000') AS "mista_vyber"
   ON "spotreba_ockovaci_mista"."ockovaci_misto_id" = "mista_vyber"."ockovaci_misto_id"
JOIN "ockovaci_mista_zarizeni_rozvazeni"
    ON "ockovaci_mista_zarizeni_rozvazeni"."ockovaci_misto_id" = "spotreba_ockovaci_mista"."ockovaci_misto_id"
JOIN "out_ockovaci_mista_zarizeni_dalsi_info" ON "out_ockovaci_mista_zarizeni_dalsi_info"."ockovaci_misto_id" = "spotreba_ockovaci_mista"."ockovaci_misto_id"
--WHERE "datum" BETWEEN '2021-05-17' AND '2021-05-24'
ORDER BY  "datum", "spotreba_ockovaci_mista"."ockovaci_misto_id"
;

-- porovnání vstupní tabulky s očkováním a výstupní (po rozvážení)
CREATE TEMPORARY TABLE "breclav_zarizeni" AS
SELECT "zarizeni_kod"
FROM "out_ockovaci_mista_zarizeni"
WHERE "okres_nuts_kod" = 'CZ0644';

SELECT *
FROM (SELECT "zarizeni_kod"
              , SUM("pocet_ockovanych_misto")
      FROM "out_ockovani"
      WHERE "zarizeni_kod" IN (SELECT "zarizeni_kod"
                              FROM "breclav_zarizeni")
      GROUP BY "zarizeni_kod") "vystup"
LEFT JOIN (SELECT "zarizeni_kod", COUNT(1)
            FROM "in_ockovani_ockovaci_mista"
            WHERE "zarizeni_kod" IN (SELECT "zarizeni_kod"
                                    FROM "breclav_zarizeni")
            GROUP BY "zarizeni_kod") "vstup"
ON "vystup"."zarizeni_kod" = "vstup"."zarizeni_kod";