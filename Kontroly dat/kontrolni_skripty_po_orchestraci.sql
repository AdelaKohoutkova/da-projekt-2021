-- kontrolní skripty po orchestraci

------------------------------------------------------------------
-- OČKOVÁNÍ
------------------------------------------------------------------
-- očkování - jaký je poslední a první datum v datech?
SELECT MAX("datum")
FROM "out_ockovani"
;

SELECT MAX(TO_DATE("datum"))
FROM "in_ockovani_ockovaci_mista"
;

SELECT MIN("datum")
FROM "out_ockovani"
;

SELECT MIN(TO_DATE("datum"))
FROM "in_ockovani_ockovaci_mista"
;

------------------------------------------------------------------
-- OČKOVACÍ MÍSTA
------------------------------------------------------------------
-- kontrola "nrpzs_kod" = '0' - nebyly přidány do ockovaci_mista?
SELECT *
FROM "ockovaci_mista"
JOIN (SELECT *
            FROM "in_ockovaci_mista"
            WHERE "nrpzs_kod" = '0') AS "vstup"
   ON "ockovaci_mista"."ockovaci_misto_id" = "vstup"."ockovaci_misto_id"
;

-- ockovaci_mista, která máme navíc -- oproti tabulce "ockovaci_mista", kde je nastaven incrementální load
SELECT "ockovaci_mista".*
FROM (SELECT *
       FROM "in_ockovaci_mista"
       WHERE "nrpzs_kod" <> '0') AS "vstup"
FULL JOIN "ockovaci_mista"
    ON "vstup"."ockovaci_misto_id" = "ockovaci_mista"."ockovaci_misto_id"
WHERE "vstup"."ockovaci_misto_id" IS NULL
;

-- jaká očkovací místa máme historicky navíc oproti zdroji? tabulka out_ockovaci_mista_zarizeni
SELECT *
FROM "out_ockovaci_mista_zarizeni"
        -- očkovací místa all - díky inkrementu
FULL JOIN (SELECT *
            FROM "in_ockovaci_mista"
            WHERE "nrpzs_kod" <> '0') "vstup"
            -- očkovací místa dostupná ve zdroji
   ON "out_ockovaci_mista_zarizeni"."ockovaci_misto_id" = "vstup"."ockovaci_misto_id"
WHERE "out_ockovaci_mista_zarizeni"."ockovaci_misto_typ" <> 'ostatni'
        AND "vstup"."nrpzs_kod" IS NULL
;

-- je shoda mezi subjekty v ockovaci_mista vs. out_ockovaci_mista_zarizeni?
    -- neměly by být žádné řádky NULL
SELECT *
FROM (SELECT *
      FROM "out_ockovaci_mista_zarizeni"
      WHERE "out_ockovaci_mista_zarizeni"."ockovaci_misto_typ" <> 'ostatni') AS "tableau"
        -- očkovací místa all - díky inkrementu
FULL JOIN (SELECT *
            FROM "ockovaci_mista") "vstup"
            -- očkovací místa dostupná ve zdroji
   ON "tableau"."ockovaci_misto_id" = "vstup"."ockovaci_misto_id"
        --AND "out_ockovaci_mista_zarizeni"."zarizeni_kod" IS NULL
;

-- není shoda s in_tabulkou (vstupem)
    --- ale tato místa mají nrpzs_kod = 0, tak proto odstraněna a je to správně
SELECT "vstup".*
FROM (SELECT *
      FROM "out_ockovaci_mista_zarizeni"
      WHERE "out_ockovaci_mista_zarizeni"."ockovaci_misto_typ" <> 'ostatni') AS "tableau"
        -- očkovací místa all - díky inkrementu
FULL JOIN (SELECT *
            FROM "in_ockovaci_mista") "vstup"
            -- očkovací místa dostupná ve zdroji
   ON "tableau"."ockovaci_misto_id" = "vstup"."ockovaci_misto_id"
WHERE "tableau"."ockovaci_misto_id" IS NULL
;

------------------------------------------------------------------
-- OČKOVACÍ ZAŘÍZENÍ
------------------------------------------------------------------
-- je shoda mezi zařízením na vstupu (in_ockovaci_zarizeni) a zařízeními v Tableau (out_ockovaci_mista_zarizeni)?
    -- měla by být shoda, protože by nemělo docházet k odstraňování (nevybere žádný záznam správně)
    -- zároveň některá zařízení se mohou stát očkovacími místy, a tak jsou odstraněna z tabulky "ockovaci_zarizeni_mezistav"
SELECT *
FROM (SELECT *
      FROM "out_ockovaci_mista_zarizeni"
      WHERE "out_ockovaci_mista_zarizeni"."ockovaci_misto_typ" = 'ostatni') AS "tableau"
        -- ockovaci zarizeni - po odstranění potenciálních duplicit
FULL JOIN (SELECT *
            FROM "in_ockovaci_zarizeni") "vstup"
            -- očkovací zarizeni dostupna ve zdroji k poslednimu dni
   ON "tableau"."zarizeni_kod" = "vstup"."zarizeni_kod"
WHERE "tableau"."zarizeni_kod" IS NULL
        OR "vstup"."zarizeni_kod" IS NULL
;

-- jaká očkovací zarizeni máme historicky navíc oproti zdroji?
  -- neměl by být žádný výsledek - protože pokud se přesunou, tak jsou smazány pomocí transformace a zaevidovány do tabulek odstraneno_
-- takto identifikován problém a přidána transformace
  -- 25296094000 - bylo smazáno
  -- 62525107000 - bylo smazáno
SELECT *
FROM "out_ockovaci_mista_zarizeni"
        -- očkovací místa all - díky inkrementu
FULL JOIN (SELECT *
            FROM "in_ockovaci_zarizeni") "vstup"
            -- očkovací místa dostupná ve zdroji
   ON "out_ockovaci_mista_zarizeni"."ockovaci_misto_id" = "vstup"."zarizeni_kod"
WHERE "out_ockovaci_mista_zarizeni"."ockovaci_misto_typ" = 'ostatni'
        AND "out_ockovaci_mista_zarizeni"."zarizeni_kod" IS NULL
;

-- která zařízení byla odstraněna?
    -- a jsou v očkovacích místech? - měly by být (odstraněna pouze při přesunu)
SELECT *
FROM "odstraneno_ockovaci_zarizeni_mezistav"
LEFT JOIN "ockovaci_mista"
        ON "odstraneno_ockovaci_zarizeni_mezistav"."zarizeni_kod" = "ockovaci_mista"."zarizeni_kod"
ORDER BY "datum_odstraneni" desc, "odstraneno_ockovaci_zarizeni_mezistav"."zarizeni_kod";

-- mají tahle zařízení záznamy v očkování?
SELECT "odstraneno_ockovaci_zarizeni_mezistav".*
        , ROW_NUMBER () OVER (PARTITION BY "ockovaci_misto_id" ORDER BY "datum" DESC) AS "row_num"
        , "out_ockovani"."datum"
FROM "odstraneno_ockovaci_zarizeni_mezistav"
LEFT JOIN "out_ockovani" ON "out_ockovani"."zarizeni_kod" = "odstraneno_ockovaci_zarizeni_mezistav"."zarizeni_kod"
QUALIFY "row_num" IS NULL OR "row_num" = 1
ORDER BY "ockovaci_misto_id", "datum" DESC
;


----------------------------------------------------
-- OVĚŘENÍ, ŽE NIC NECHYBÍ
----------------------------------------------------
-- nechybí nám nějaká očkovací místa?
SELECT *
FROM "out_ockovaci_mista_zarizeni"
        -- očkovací místa all - díky inkrementu
RIGHT JOIN (SELECT *
            FROM "in_ockovaci_mista"
            WHERE "nrpzs_kod" <> '0') "vstup"
            -- očkovací místa dostupná ve zdroji
   ON "out_ockovaci_mista_zarizeni"."ockovaci_misto_id" = "vstup"."ockovaci_misto_id"
WHERE "vstup"."nrpzs_kod" IS NULL
;

-- nechybí nám nějaká očkovací zařízení?
SELECT *
FROM "out_ockovaci_mista_zarizeni"
        -- očkovací místa all - díky inkrementu
RIGHT JOIN (SELECT *
            FROM "in_ockovaci_zarizeni") "vstup"
            -- očkovací místa dostupná ve zdroji
   ON "out_ockovaci_mista_zarizeni"."ockovaci_misto_id" = "vstup"."zarizeni_kod"
WHERE "vstup"."zarizeni_kod" IS NULL
;

------------------------------------------------------------------
-- NEEXISTUJÍ DUPLICTY? (ZAŘÍZENÍ VS. MÍSTA)
------------------------------------------------------------------
-- nejsou některé zarizeni_kod jak v datové sadě s očkovacími místy, tak se zařízeními?
    -- problém pro rozvážení
SELECT "zarizeni_kod"
        , COUNT(DISTINCT "skupina_zarizeni") AS "je_duplicita"
FROM 
    (SELECT DISTINCT "zarizeni_kod"
           , CASE   WHEN "ockovaci_misto_typ" = 'ostatni' THEN 'ostatni'
                    ELSE 'ockovaci_misto'
             END AS "skupina_zarizeni"
    FROM "out_ockovaci_mista_zarizeni"
    )
GROUP BY "zarizeni_kod"
HAVING "je_duplicita" > 1;

------------------------------------------------------------------
-- NECHYBÍ LATITUDE A LONGITUDE
------------------------------------------------------------------
-- nechybí u nějakých míst a zařízení latitude a longitude?
SELECT *
FROM "out_ockovaci_mista_zarizeni"
WHERE "latitude" IS NULL
    OR "longitude" IS NULL;