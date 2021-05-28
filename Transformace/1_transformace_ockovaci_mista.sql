-- Transformace vytváří vyčištěnou tabulku se seznamem očkovacích míst - nastaven inkrementální load
  -- Jsou odstraněna místa bez kódu zařízení (nemají záznam v tabulkách s očkováním a spotřebou)
  -- Je doplněno latitude a logitude ručně pro vybraná očkovací místa
CREATE OR REPLACE TABLE "ockovaci_mista" AS
SELECT "ockovaci_misto_id"
      , "ockovaci_misto_nazev"
      , "okres_nuts_kod"
      ,SUBSTR("okres_nuts_kod",1,5) AS "kraj_nuts_kod"
      ,CAST(IFF("operacni_status" = '',0,1)AS INT) AS "operacni_status"
      ,"ockovaci_misto_adresa"
      ,"latitude"
      ,"longitude"
      ,"ockovaci_misto_typ"
      , LPAD("nrpzs_kod",11,0) AS "zarizeni_kod"
      , "minimalni_kapacita"
      , CAST(IFF("bezbarierovy_pristup" = '',0,1)AS INT) AS "bezbarierovy_pristup"
FROM "in_ockovaci_mista"
WHERE "zarizeni_kod" <> '00000000000'
-- odstraňujeme místa, která nemají kód zařízení 
	--(ověřeno, že ve spotřebě zanedbatelné záznamy a v očkování tato zařízení nejsou - viz níže)
;

/*SELECT *
FROM "in_ockovaci_mista"
LEFT JOIN (SELECT "ockovaci_misto_id", SUM("pouzite_davky")
            FROM "in_spotreba_ockovaci_mista"
            GROUP BY "ockovaci_misto_id" ) "spotreba"
    ON "in_ockovaci_mista"."ockovaci_misto_id" = "spotreba"."ockovaci_misto_id"
WHERE "nrpzs_kod" = '0'
;*/

-- pro očkovací místo c4c7db25-dd2d-4182-bd32-0b6ad04f0bb1 chybí latitude a longitude
-- ruční doplnění
UPDATE "ockovaci_mista"
SET "latitude" = 49.674140
WHERE "ockovaci_misto_id" = 'c4c7db25-dd2d-4182-bd32-0b6ad04f0bb1';

UPDATE "ockovaci_mista"
SET "longitude" = 18.665850
WHERE "ockovaci_misto_id" = 'c4c7db25-dd2d-4182-bd32-0b6ad04f0bb1';

UPDATE "ockovaci_mista"
SET "latitude" = 50.1079219
WHERE "ockovaci_misto_id" = 'eb73960f-9644-41ef-8dcc-66d60133d2c6';

UPDATE "ockovaci_mista"
SET "longitude" = 14.2678019
WHERE "ockovaci_misto_id" = 'eb73960f-9644-41ef-8dcc-66d60133d2c6';

UPDATE "ockovaci_mista"
SET "latitude" = 50.1942900
WHERE "ockovaci_misto_id" = '8399fb2d-a203-4194-8b3a-a0d630e13532';

UPDATE "ockovaci_mista"
SET "longitude" = 15.8290436
WHERE "ockovaci_misto_id" = '8399fb2d-a203-4194-8b3a-a0d630e13532';

UPDATE "ockovaci_mista"
SET "latitude" = 50.0901564
WHERE "ockovaci_misto_id" = '1812ba54-08e0-4ee8-b47e-bf93f5e1111f';

UPDATE "ockovaci_mista"
SET "longitude" = 14.363438
WHERE "ockovaci_misto_id" = '1812ba54-08e0-4ee8-b47e-bf93f5e1111f';

UPDATE "ockovaci_mista"
SET "ockovaci_misto_typ" = 'OČM'
WHERE "ockovaci_misto_typ" IS NULL
;