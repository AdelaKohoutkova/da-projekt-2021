-- dochází k přesunu z datové sady s očkovacími zařízeními do sady s očkovacími místy (ostatní zařízení se transformují do oficiálních očkovacích míst). Je potřeba odstranit tato očkovací zařízení z tabulky ockovaci_zarizeni_mezistav, protože jinak by vznikaly duplicity v tabulce out_ockovaci_zarizeni_mista a zároveň v tabulce s očkováním

-- vytvoření tabulky odstraneno_ockovaci_zarizeni_mezistav pro evidenci odstraněných očkovacích zařízení - aby se zabránilo duplicitám při rozvážení (pokud by bylo zařízení v zařízeních i očkovacích místech)
CREATE OR REPLACE TABLE "odstraneno_ockovaci_zarizeni_mezistav" AS 
(   SELECT "zarizeni_kod"
           , "zarizeni_nazev"
           , "kraj_nuts_kod"
           , "okres_nuts_kod"
           , "kod_obce"
           , "uzis_adresa"
           , "nrpzs_adresa"
           , "adresa_okres"
           , "adresa"
           , "nrpzs_latitude"
           , "nrpzs_longitude"
 					 , CURRENT_DATE() AS "datum_odstraneni"
    FROM "ockovaci_zarizeni_mezistav"
    WHERE "zarizeni_kod" IS NULL)
    ;

-- pro zjednodušení výběrů dále - zařízení, které bylo nalezeno že je duplicitní v zařízeních a místech uložíme do temporary tabulky zarizeni_to_delete
CREATE OR REPLACE TEMPORARY TABLE "zarizeni_to_delete" AS 
SELECT "zarizeni_kod"
FROM (
      SELECT "puvodni_zarizeni".*
                    , "nova_zarizeni"."zarizeni_kod" AS "existuje_zarizeni"
                    , LPAD("nova_mista"."nrpzs_kod",11,0) AS "existuje_mista"
                    , "nova_mista"."ockovaci_misto_nazev" AS "existuje_mista_nazev"
                    , "nova_mista"."okres_nuts_kod" AS "existuje_mista_okres"
                    , "puvodni_mista"."zarizeni_kod" AS "existovalo_mista"
                    , "puvodni_mista"."ockovaci_misto_id" AS "existovalo_mista_id"
                    , "puvodni_mista"."ockovaci_misto_nazev" AS "existovalo_mista_nazev"
                    , "puvodni_mista"."okres_nuts_kod" AS "existovalo_mista_okres"
      FROM (SELECT *
            FROM "out_ockovaci_mista_zarizeni"
            WHERE "ockovaci_misto_typ" = 'ostatni') AS "puvodni_zarizeni" 
      LEFT JOIN "in_ockovaci_zarizeni" AS "nova_zarizeni"
                ON "puvodni_zarizeni"."zarizeni_kod" = "nova_zarizeni"."zarizeni_kod"
      LEFT JOIN "in_ockovaci_mista" AS "nova_mista"
                ON LPAD("nova_mista"."nrpzs_kod",11,0) = "puvodni_zarizeni"."zarizeni_kod"
      LEFT JOIN (SELECT *
                 FROM "out_ockovaci_mista_zarizeni"
                 WHERE "ockovaci_misto_typ" <> 'ostatni') AS "puvodni_mista"
                ON "puvodni_mista"."zarizeni_kod" = LPAD("nova_mista"."nrpzs_kod",11,0)
      WHERE "existuje_zarizeni" IS NULL
                    -- zarizeni, ktera v puvodnich byla ale v novem ciselniku zarizeni (ostatnich) uz neni
                   AND "existovalo_mista" IS NULL
                    -- zarizeni nebylo v původních očkovacích místech, ale v novém číselníku míst je (vzniklo nově)
                   AND "existuje_mista" IS NOT NULL
                   AND "existuje_mista_okres" = "puvodni_zarizeni"."okres_nuts_kod"
        )
;

/*SELECT *
FROM "zarizeni_to_delete"
;*/

-- před odstraněním z tabulky ockovaci_zarizeni_mezistav to zařízení zaevidujeme, tak jak bylo v tabulce ockovaci_zarizeni_mezistav
INSERT INTO "odstraneno_ockovaci_zarizeni_mezistav"
    (SELECT "zarizeni_kod"
           , "zarizeni_nazev"
           , "kraj_nuts_kod"
           , "okres_nuts_kod"
           , "kod_obce"
           , "uzis_adresa"
           , "nrpzs_adresa"
           , "adresa_okres"
           , "adresa"
           , "nrpzs_latitude"
           , "nrpzs_longitude"
 		   , CURRENT_DATE() AS "datum_odstraneni"
        FROM "ockovaci_zarizeni_mezistav"
        WHERE "zarizeni_kod" IN (SELECT "zarizeni_kod"
                                    FROM "zarizeni_to_delete"));

/*SELECT *
FROM "odstraneno_ockovaci_zarizeni_mezistav";*/

-- odstranění duplicitního zařízení
DELETE
FROM "ockovaci_zarizeni_mezistav"
USING 
      (SELECT "zarizeni_kod"
        FROM "zarizeni_to_delete") AS "zarizeni_k_odstraneni"        
WHERE "zarizeni_k_odstraneni" ."zarizeni_kod" = "ockovaci_zarizeni_mezistav"."zarizeni_kod"
;

/*SELECT *
FROM "ockovaci_zarizeni_mezistav"
;*/

-- vytvoření tabulky odstraneno_out_ockovaci_mista_zarizeni pro evidenci odstraněných očkovacích zařízení - aby se zabránilo duplicitám při rozvážení (pokud by bylo zařízení v zařízeních i očkovacích místech) - tato tabulka pouze jako backup
CREATE OR REPLACE TABLE "odstraneno_out_ockovaci_mista_zarizeni" AS 
(SELECT "ockovaci_misto_id"
        , "ockovaci_misto_nazev"
        , "okres_nuts_kod"
        , "kraj_nuts_kod"
        , "operacni_status"
        , "adresa"
        , "latitude"
        , "longitude"
        , "ockovaci_misto_typ"
        , "zarizeni_kod"
        , "minimalni_kapacita"
        , "bezbarierovy_pristup"
        , CURRENT_DATE() AS "datum_odstraneni"
FROM "out_ockovaci_mista_zarizeni"
WHERE "ockovaci_misto_id" IS NULL);

-- zařízení zaevidujeme, tak jak bylo v tabulce out_ockovaci_mista_zarizeni
INSERT INTO "odstraneno_out_ockovaci_mista_zarizeni"
    (SELECT "ockovaci_misto_id"
            , "ockovaci_misto_nazev"
            , "okres_nuts_kod"
            , "kraj_nuts_kod"
            , "operacni_status"
            , "adresa"
            , "latitude"
            , "longitude"
            , "ockovaci_misto_typ"
            , "zarizeni_kod"
            , "minimalni_kapacita"
            , "bezbarierovy_pristup"
            , CURRENT_DATE() AS "datum_odstraneni"
        FROM "out_ockovaci_mista_zarizeni"
        WHERE "zarizeni_kod" IN (SELECT "zarizeni_kod"
                                    FROM "zarizeni_to_delete"))
;

/*SELECT *
FROM "odstraneno_out_ockovaci_mista_zarizeni";*/