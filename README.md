# Analýza očkování v jednotlivých okresech ČR
## Datový projekt zpracovávaný v rámci Digitální akademie Czechitas - Data v Praze, jaro 2021

### Základní popis projektu

Datový projekt si klade za cíl analyzovat očkování v ČR v rozpadu na jednotlivé okresy. Dostupné analýzy pracují většinou s informacemi na úrovni ČR či jednotlivých krajů, protože otevřené datové sady o očkování nemají informaci o okresu přímo k dispozici. Proto jsme se rozhodly najít způsob, jak přiblížit aktuální situaci a vývoj v čase na podrobnější úrovni - okresů a také blíže zmapovat očkovací infrastrukturu (rozdělení očkování mezi oficiální očkovací místa a ostatní očkující zařízení). 

Projekt byl zpracováván v nástroji [Keboola](https://www.keboola.com/), kde se nachází také kompletní technická infrastruktura a probíhají veškeré transformace, vyjma Python transformací použitých separátně pro přípravu statických dat do formy vhodné k nahrání do Kebooly pomocí extraktoru. Data jsou denně aktualizována přibližně v 10:30 ráno.

Výstupem je interaktivní dashboard zpracovaný v Tableau desktop, který může posloužit pro krajské koordinátory ale i běžnému občanovi ČR k získání přehledu o postupu očkování na úrovni okresů.
Vizualizace je k dispozici na [Tableau Public](https://public.tableau.com/app/profile/radka.stekla/viz/AnalzaokovnvokresechR/Dashboardmapakraje) Bohužel ve veřejné vizualizaci prozatím nedochází k pravidelné aktualizaci.

Popis zpracování dat a informace o datovém projektu jsou k dispozici také v článku na blogu [zde](http://bit.ly/dadpj2021projekt13).
### Podrobnější popis projektu a struktura repository



