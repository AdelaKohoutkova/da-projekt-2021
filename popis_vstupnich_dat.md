# Popis vstupních dat

## NeCOVIDová data

### **Počet obyvatel v okresech a krajích dle věkové struktury**

**Zdroj:**
* Český statistický úřad
* url ke stažení: https://www.czso.cz/csu/czso/vekove-slozeni-obyvatelstva-2019

**Popis dat:**
* Použity excelovské tabulky k 31.12.2019 - věkové složení mužů, věkové složení žen.
* V původních datech jsou informace o populaci dle pohlaví a jednotlivých let věku (po roce) v jednotlivých oblastech ČR, krajích a okresech
* Excely upraveny do zpracovatelné podoby (ponechány kraje a okresy, odstraněny hodnoty za jednotlivé regiony) a transformovány prostřednictvím skriptu **populace.py** (ve skriptu popsány i kroky úpravy stažených excelů.) do souboru obyvatelstvo_prevedene.csv

**Uložení dat:**
* Google Disk - .csv soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: obyvatelstvo_prevedene

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_populace_okres


### **Průměrný věk obyvatel v okresech a krajích **

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
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_vek_prumer


### **Hustota obyvatel v krajích a okresech**

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
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_zaklad_vypocet_hustota


### **Struktura území ČR**

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
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_struktura_uzemi_cr


## COVIDová data

**Zdroj:**
* https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19
* verze API: v2 

### COVID-19: Přehled vykázaných očkování podle krajů ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani.csv

**Popis dat:**
* dostupné v souboru **ockovani.csv-metadata.json**
* Datová sada poskytuje řádková data o vykázaných očkováních na jednotlivých očkovacích místech ČR. Každý řádek přehledu popisuje jedno vykázané očkování v daném dni a věkové skupině, s použitím vybrané očkovací látky, na konkrétním očkovacím místu a ve vybraném kraji.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 2-ockovani.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_ockovani_kraje


### COVID-19: Přehled vykázaných očkování podle očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovaci-mista.csv

**Popis dat:**
* dostupné v souboru **ockovaci-mista.csv-metadata.json**
* Datová sada poskytuje agregovaná data o vykázaných očkováních na úrovni krajů ČR. Každý řádek přehledu popisuje počet vykázaných očkování v daném dni, za věkovou skupinu, s použitím vybrané očkovací látky a ve vybraném kraji. Za jeden den tedy přehled obsahuje maximálně X řádků, kde X = počet krajů (14) x počet věkových skupin (15) x počet druhů očkovacích látek (v okamžik publikace 2) = 630. Data jsou aktualizována k času 20.00 h předchozího dne a mohou se zpětně mírně měnit z důvodu průběžného doplňování.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 2-ockovaci-mista.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_ockovani_ockovaci_mista


### COVID-19: Přehled vykázaných očkování podle očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/prehled-ockovacich-mist.csv

**Popis dat:**
* dostupné v souboru **prehled-ockovacich-mist.csv-metadata.json**
* Datová sada poskytuje seznam očkovaích míst v ČR, kde jsou podávány očkovací látky proti onemocnění COVID-19.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 3-prehled-ockovacich-mist.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_ockovaci_mista


### COVID-19: Přehled spotřeby podle očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani-spotreba.csv

**Popis dat:**
* dostupné v souboru **prehled-ockovacich-mist.csv-metadata.json**
* Datová sada obsahuje přehled spotřeby očkovacích látek (použité a znehodnocené ampulky) proti onemocnění COVID-19 v očkovacích místech v ČR. Každý záznam (řádek) datové sady udává počet použitých a znehodnocených ampulek dané očkovací látky na daném očkovacím místě v daný den.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 4-ockovani-spotreba.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_spotreba_ockovaci_mista


### COVID-19: Přehled distribuce očkovacích látek v ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani-distribuce.csv

**Popis dat:**
* dostupné v souboru **ockovani-distribuce.csv-metadata.json**
* Datová sada obsahuje přehled distribuce očkovacích látek proti onemocnění COVID-19 do očkovacích míst v ČR. Každý záznam (řádek) datové sady udává počet ampulek dané očkovací látky, která byla daným očkovacím místem v daný den přijata nebo vydána.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 5-ockovani-distribuce.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_distribuce_ockovaci_mista


### COVID-19: Přehled registrací podle očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani-registrace.csv

**Popis dat:**
* dostupné v souboru **ockovani-registrace.csv-metadata.json**
* Datová sada poskytuje přehled vytvořených registrací v centrálním rezervačním systému na očkování proti onemocnění COVID-19 (https://registrace.mzcr.cz/). Záznamy (řádky) datové sady popisují jednotlivé anonymizované registrace, které byly vytvořeny na dané očkovací místo v daný den.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 6-ockovani-registrace.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_registrace_ockovaci_mista


### COVID-19: Přehled rezervací podle očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani-rezervace.csv

**Popis dat:**
* dostupné v souboru **ockovani-rezervace.csv-metadata.json**
* Datová sada poskytuje přehled volné a maximální kapacity očkovacích míst v jednotlivých dnech podle informací z centrálního rezervačního systému na očkování proti onemocnění COVID-19 (https://reservatic.com/ockovani). Každý záznam (řádek) datové sady udává volnou a maximální kapacitu daného očkovacího místa v daný den.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 7-ockovani-rezervace.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_rezervace_ockovaci_mista


### COVID-19: COVID-19: Přehled vykázaných očkování podle profesí

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovani-profese.csv

**Popis dat:**
* dostupné v souboru **ockovani-rezervace.csv-metadata.json**
* Datová sada poskytuje řádková data o vykázaných očkováních na jednotlivých očkovacích místech ČR. Každý řádek přehledu popisuje jedno vykázané očkování v daném dni a indikační skupině profese, s použitím dané dávky očkovací látky, na konkrétním očkovacím místu a ve vybraném kraji.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Uložení dat:**
* Google Disk - k dispozici soubor stažený ke 14.4.2021 -> 8-ockovani-profese.csv

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_ockovani_profese


