-- KONTROLA in_populace_okres
SELECT *
FROM "in_populace_okres" stara
JOIN (SELECT *
        FROM "populace-okres") nova
  ON stara."obdobi" = nova."obdobi"
    AND stara."vek" = nova."vek"
    AND stara."pohlavi" = nova."pohlavi"
    AND stara."kraj_kod" = nova."kraj_kod"
    AND stara."okres_kod" = nova."okres_kod"
    AND stara."pocet_obyvatel" = nova."pocet_obyvatel"   
;

-- KONTROLA in_vek_prumer
SELECT *
FROM "in_vek_prumer" nova
JOIN (SELECT *
        FROM "vek-prumer") stara
    ON stara."obdobi" = nova."obdobi"
        AND    stara."oblast_kod" = nova."oblast_kod"
        AND    stara."oblast_kategorie" = nova."oblast_kategorie"
        AND     stara."vek_prumer" = nova."vek_prumer"  
;

-- KONTROLA in_struktura_uzemi_cr
SELECT *
FROM "in_struktura_uzemi_cr" nova
JOIN (SELECT *
        FROM "struktura-uzemi-cr") stara 
    ON stara."obec_kod" = nova."obec_kod"
        AND    stara."obec_nazev" = nova."obec_nazev"
        AND    stara."obec_status" = nova."obec_status"   
        AND    stara."obec_pou_kod" = nova."obec_pou_kod"   
        AND    stara."obec_pou_nazev" = nova."obec_pou_nazev"   
        AND    stara."obec_rp_kod" = nova."obec_rp_kod"   
        AND    stara."obec_rp_nazev" = nova."obec_rp_nazev"   
        AND    stara."okres_kod" = nova."okres_kod"   
        AND    stara."okres_nazev" = nova."okres_nazev"   
        AND    stara."kraj_kod" = nova."kraj_kod"   
        AND    stara."kraj_nazev" = nova."kraj_nazev"   
        AND    stara."region_kod" = nova."region_kod"   
        AND    stara."region_nazev" = nova."region_nazev"   ;


-- KONTROLA in_zaklad_vypocet_hustota
SELECT *
FROM "in_zaklad_vypocet_hustota" nova
JOIN (SELECT *
        FROM "zaklad-vypocet-hustota") stara 
    ON stara."obec_kod" = nova."obec_kod"
        AND    stara."okres_nuts_kod" = nova."okres_nuts_kod"   
        AND    stara."kraj_nuts_kod" = nova."kraj_nuts_kod"   
        AND    stara."pocet_obyvatel" = nova."pocet_obyvatel"   
        AND    stara."vymera_ha" = nova."vymera_ha"   
;    

-- kontrola počtu obyvatel z hustoty a počtu obyvatel dle věku
SELECT *
FROM (SELECT "kraj_nuts_kod", SUM(TO_NUMBER("pocet_obyvatel")) pocet_hustota
      FROM "in_zaklad_vypocet_hustota"
        GROUP BY "kraj_nuts_kod") hustota
JOIN (SELECT "kraj_kod", SUM(TO_NUMBER("pocet_obyvatel")) pocet_obyvatele
        FROM "in_populace_okres" 
        GROUP BY "kraj_kod") obyvatele
    ON hustota."kraj_nuts_kod" = obyvatele."kraj_kod"
            AND hustota.pocet_hustota = obyvatele.pocet_obyvatele
ORDER BY "kraj_nuts_kod"
; 