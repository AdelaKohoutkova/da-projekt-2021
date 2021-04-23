# Popis vstupních dat


## **Počet obyvatel v okresech a krajích dle věkové struktury**

**Zdroj:**
* Český statistický úřad
* url ke stažení: https://www.czso.cz/csu/czso/vekove-slozeni-obyvatelstva-2019

**Popis dat:**
* Použity excelovské tabulky k 31.12.2019 - věkové složení mužů, věkové složení žen.
* V původních datech jsou informace o populaci dle pohlaví a jednotlivých let věku (po roce) v jednotlivých oblastech ČR, krajích a okresech
* Excely upraveny do zpracovatelné podoby (ponechány kraje a okresy, odstraněny hodnoty za jednotlivé regiony) a transformovány prostřednictvím skriptu populace.py (ve skriptu popsány i kroky úpravy stažených excelů.) do souboru obyvatelstvo_prevedene.csv

**Uložení dat:**
* Google Disk - .csv soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: obyvatelstvo_prevedene

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in-populace-okres


## **Průměrný věk obyvatel v okresech a krajích **

**Zdroj:**
* Český statistický úřad
* url ke stažení: https://www.czso.cz/csu/czso/vekove-slozeni-obyvatelstva-2019

**Popis dat:**
* Použity excelovské tabulky k 31.12.2019 - věkové složení obyvatel.
* V původních datech jsou informace o populaci dle jednotlivých let (po roce) v jednotlivých oblastech ČR, krajích a okresech. Pod touto tabulkou je vypočítaný i průměrný věk.
* Excel upraven ručně do zpracovatelné podoby (ponechány kraje a okresy, odstraněny hodnoty za jednotlivé regiony).

**Uložení dat:**
* Google Disk - .xlsx soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: vek_prumer

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in-vek-prumer


## **Hustota obyvatel v krajích a okresech**

**Zdroj:**
* Český statistický úřad
* url ke stažení: !DOPLNIT!

**Popis dat:**
* Použity excelovské tabulky k 31.12.2019 - věkové složení obyvatel.
* V původních datech jsou informace o populaci a rozloze v jednotlivých obcích.
* Excel upraven ručně do zpracovatelné podoby - ponechán stupeň agregace po obcích.

**Uložení dat:**
* Google Disk - .xlsx soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: zaklad_vypocet_hustota

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in-zaklad-vypocet-hustota


## **Struktura území ČR**

**Zdroj:**
* Český statistický úřad
* url ke stažení: https://www.czso.cz/csu/czso/i_zakladni_uzemni_ciselniky_na_uzemi_cr_a_klasifikace_cz_nuts

**Popis dat:**
* Použita excelovská tabulka "Struktura území ČR k 1. 1. 2016 až 1. 1. 2021".
* V původních datech je kompletní číselník struktury ČR - informace o jednotlivých obcích - do kterého patří okresu a kraje.
* Excel upraven ručně do zpracovatelné podoby - ponechán stupeň agregace původní, přejmenovány sloupce a nahrána data 1.1.2021

**Uložení dat:**
* Google Disk - .xlsx soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: struktura_uzemi_cr_adj

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in-struktura-uzemi-cr

