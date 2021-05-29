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
* url ke stažení: https://www.czso.cz/csu/czso/csu_a_uzemne_analyticke_podklady

**Popis dat:**
* Použity excelovská tabulka "[Územně analytické podklady ČSÚ](https://www.czso.cz/documents/10180/23192368/uap_obce_2019.xlsx/324a33c5-c073-445b-9f3f-49d1b259974f?version=1.5)".
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
* Použita excelovská tabulka "[Struktura území ČR k 1. 1. 2016 až 1. 1. 2021](https://www.czso.cz/documents/10180/23208674/struktura_uzemi_cr_1_1_2016_az_1_1_2021.xlsx/56b257cc-d829-4577-b94f-106912fc0392?version=1.3)".
* V původních datech je kompletní číselník struktury ČR - informace o jednotlivých obcích - do kterého patří okresu a kraje.
* Excel upraven ručně do zpracovatelné podoby - ponechán stupeň agregace původní, přejmenovány sloupce a nahrána data 1.1.2021

**Uložení dat:**
* Google Disk - .xlsx soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: struktura_uzemi_cr_adj

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_struktura_uzemi_cr

### **Číselník základních územních jednotek ČR a klasifikace NUTS**

**Zdroj:**
* Český statistický úřad
* url ke stažení: https://www.czso.cz/csu/czso/csu_a_uzemne_analyticke_podklady

**Popis dat:**
* Použita excelovská tabulka "[Územně analytické podklady ČSÚ](https://www.czso.cz/documents/10180/23192368/uap_obce_2019.xlsx/324a33c5-c073-445b-9f3f-49d1b259974f?version=1.5)".
* V původních datech jsou informace o populaci a rozloze v jednotlivých obcích.
* Excel upraven ručně do zpracovatelné podoby - ponechán stupeň agregace po obcích.

**Uložení dat:**
* Google Disk - .xlsx soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: zujedn_nuts_prevodnik

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_zujedn_nuts


### **Číselník základních územních jednotek Hl. města Prahy**

**Zdroj:**
* Český statistický úřad
* url ke stažení: https://www.czso.cz/csu/xa/uzemni_ciselniky

**Popis dat:**
* Použita excelovská tabulka "[Územní číselník 57 městských částí (kodZUJ) a 22 obvodů (kodSO) hl. m. Prahy k 31. 12. 2019](https://www.czso.cz/documents/11236/17900404/ciselnik_MC_SO.xlsx/4c5ecee0-9303-40f6-bc38-9d97229a98a1?version=1.1)".
* V původních datech je kompletní číselník městských obvodů hl. města Prahy - informace o jednotlivých obcích - do kterého patří okresu a kraje.
* Excel upraven ručně do zpracovatelné podoby - ponechán stupeň agregace původní, přejmenovány sloupce a data nahrána.

**Uložení dat:**
* Google Disk - .xlsx soubor převeden na Google Sheets pro nahrání do Kebooly -> název souboru: mc_praha_ciselnik

**Název vstupní tabulky v Keboola:**
* Extraktor "non-covid data", bucket "google_drive_extraktor_non_covid_data" -> název tabulky: in_zuj_praha


### **Latitude a lognitude pro jednotlivé obce v ČR**

**Zdroj:**
* jedná se o soubor poskytnutý v rámci skupiny Czechitas, který obsahuje latitude a longitude jednotlivých obcí v ČR

**Název vstupní tabulky v Keboola:**
* CSV Import extraktor "obce_geolokace", bucket "csv-import" -> název tabulky: in_obce_geolokace


## COVIDová data

**Zdroj:**
* https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19
* verze API: v2 

### COVID-19: Přehled vykázaných očkování podle očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovaci-mista.csv

**Popis dat:**
* dostupné v souboru **ockovaci-mista.csv-metadata.json**
* Datová sada poskytuje agregovaná data o vykázaných očkováních na úrovni krajů ČR. Každý řádek přehledu popisuje počet vykázaných očkování v daném dni, za věkovou skupinu, s použitím vybrané očkovací látky a ve vybraném kraji. Za jeden den tedy přehled obsahuje maximálně X řádků, kde X = počet krajů (14) x počet věkových skupin (15) x počet druhů očkovacích látek (v okamžik publikace 2) = 630. Data jsou aktualizována k času 20.00 h předchozího dne a mohou se zpětně mírně měnit z důvodu průběžného doplňování.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_ockovani_ockovaci_mista


### COVID-19: Přehled očkovacích míst ČR

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/prehled-ockovacich-mist.csv

**Popis dat:**
* dostupné v souboru **prehled-ockovacich-mist.csv-metadata.json**
* Datová sada poskytuje seznam očkovaích míst v ČR, kde jsou podávány očkovací látky proti onemocnění COVID-19.
* Zdrojem jsou Krajské hygienické stanice v ČR
* denní aktualizace

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

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_spotreba_ockovaci_mista

### COVID-19: Očkovací zařízení

**Zdroj:**
* MZČR
* url ke stažení: https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/ockovaci-zarizeni.csv

**Popis dat:**
* dostupné v souboru **ockovaci-zarizeni.csv-metadata.json**
* Datová sada poskytuje seznam očkovacích zařízení v ČR jako doplnění seznamu očkovacích míst, kde jsou podávány očkovací látky proti onemocnění COVID-19. Jedná se především o praktické lékaře, ale i další, kde se očkování provádí.
* Zdrojem je Informační systém infekčních nemocí (ISIN) - https://www.uzis.cz/index.php?pg=registry-sber-dat--ochrana-verejneho-zdravi--informacni-system-infekcni-nemoci, kontakt: helpdesk.registry@uzis.cz
* denní aktualizace

**Název vstupní tabulky v Keboola:**
* http extraktor "COVID data - MZd", bucket "http_extractor_covid_mzd" -> název tabulky: in_ockovaci_zarizeni


## Další číselníky spojené s COVIDovými daty

### Číselník poskytovatelů zdravotnických služeb

**Zdroj:**
* NRPZS (Národní registr poskytovatelů zdravotních služeb)
* url ke stažení: https://opendata.mzcr.cz/data/nrpzs/narodni-registr-poskytovatelu-zdravotnich-sluzeb.csv

**Popis dat:**
* dostupný v souboru **narodni-registr-poskytovatelu-zdravotnich-sluzeb.csv-metadata.json**
* Data obsahují poskytovatele z Národního registru poskytovatelů zdravotních služeb
* měsíční aktualizace

**Název vstupní tabulky v Keboola:**
* http extraktor "narodni registr poskytovatelů služeb", bucket "http_extractor_zdravotnicka_zarizeni" -> název tabulky: in_nrpzs_zarizeni


### Číselník zdravotnických zařízení

**Zdroj:**
* dasta ČR (https://www.dastacr.cz/)
* url ke stažení: http://ciselniky.dasta.stapro.cz/hypertext/202121/hypertext/UZIScis_ZdravotnickeZarizeni.htm

**Popis dat:**
* dostupný na http://ciselniky.dasta.stapro.cz/hypertext/202121/hypertext/UZIScis_strukt_ciselnikZdravotnickeZarizeniVetaType.htm
* Data obsahují přehled zdravotnických zařízení s podrobnějšími informacemi o jednotlivých zařízeních (včetně kódů obcí)
* jednorázové stažení - bez aktualizace

**Název vstupní tabulky v Keboola:**
* CSV Import extraktor "zarizeni", bucket "csv-import" -> název tabulky: in_zarizeni
