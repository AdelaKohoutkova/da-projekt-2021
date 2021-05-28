CREATE OR REPLACE TEMPORARY TABLE "ockovaci_zarizeni_mezistav_2" AS
SELECT "ockovaci_zarizeni_mezistav".*
       ,"lat_long"."latitude" AS "latitude_geo"
       ,"lat_long"."longitude" AS "longitude_geo"
       ,"in_obce_geolokace"."Latitude" AS "latitude_obec"
       ,"in_obce_geolokace"."Longitude"AS "longitude_obec"
       , CASE  WHEN "nrpzs_latitude" IS NOT NULL
                      THEN "nrpzs_latitude"
              WHEN "nrpzs_latitude" IS NULL AND "latitude_geo" IS NOT NULL
                      THEN "latitude_geo"
              WHEN "latitude_geo" IS NULL AND "latitude_obec" IS NOT NULL
                      THEN "latitude_obec"
              WHEN "latitude_obec" IS NULL AND "ockovaci_zarizeni_mezistav"."adresa" ILIKE '%praha%'
                      THEN '50.075638' --14.437900
              ELSE NULL
          END AS "latitude_f"
       , CASE  WHEN "nrpzs_longitude" IS NOT NULL
                      THEN "nrpzs_longitude"
              WHEN "nrpzs_longitude" IS NULL AND "longitude_geo" IS NOT NULL
                      THEN "longitude_geo"
              WHEN "longitude_geo" IS NULL AND "longitude_obec" IS NOT NULL
                      THEN "longitude_obec"
              WHEN "longitude_obec" IS NULL AND "ockovaci_zarizeni_mezistav"."adresa" ILIKE '%praha%'
                      THEN '14.437900'
              ELSE NULL
          END AS "longitude_f"
       , CASE  WHEN "nrpzs_latitude" IS NOT NULL
                      THEN 'nrpzs'
              WHEN "nrpzs_latitude" IS NULL AND "latitude_geo" IS NOT NULL
                      THEN 'geo exraktor'
              WHEN "latitude_geo" IS NULL AND "latitude_obec" IS NOT NULL
                      THEN 'geolokace obec'
              WHEN "latitude_obec" IS NULL AND "ockovaci_zarizeni_mezistav"."adresa" ILIKE '%praha%'
                      THEN 'Praha manual'
              ELSE NULL
          END AS "zdroj_lat_long"   
FROM "ockovaci_zarizeni_mezistav"
LEFT JOIN (SELECT DISTINCT "query", "latitude", "longitude"
           FROM "ockovaci_zarizeni_lat_long") AS "lat_long"
ON "ockovaci_zarizeni_mezistav"."adresa" = "lat_long"."query"
LEFT JOIN "in_obce_geolokace"
ON "ockovaci_zarizeni_mezistav"."kod_obce" = "in_obce_geolokace"."Kod_obce"
;

ALTER TABLE "ockovaci_zarizeni_mezistav_2" ADD COLUMN "operacni_status" INT;

ALTER TABLE "ockovaci_zarizeni_mezistav_2" ADD COLUMN "ockovaci_misto_typ" VARCHAR;

ALTER TABLE "ockovaci_zarizeni_mezistav_2" ADD COLUMN "minimalni_kapacita" VARCHAR;

ALTER TABLE "ockovaci_zarizeni_mezistav_2" ADD COLUMN "bezbarierovy_pristup" VARCHAR;

CREATE OR REPLACE TABLE "ockovaci_zarizeni" AS
SELECT "zarizeni_kod" AS "ockovaci_misto_id"
       , "zarizeni_nazev" AS "ockovaci_misto_nazev"
       , "okres_nuts_kod"
       , "kraj_nuts_kod"
       , 0 AS "operacni_status"
       , "adresa"
       ,"latitude_f" AS "latitude"
       ,"longitude_f" AS "longitude"
       ,'ostatni' AS "ockovaci_misto_typ"
       ,"zarizeni_kod"
       ,"minimalni_kapacita"
       ,"bezbarierovy_pristup"
FROM "ockovaci_zarizeni_mezistav_2"
;