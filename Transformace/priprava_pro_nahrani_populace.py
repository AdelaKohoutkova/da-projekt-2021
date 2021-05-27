# Excely stažené ze stránek ČSÚ musí být upraveny
  # buňky v záhlaví rozděleny (cells merged)
  # z původního záhlaví odvozen kód okresu
  # odmazáno původní záhlaví a nadbytečné prázdné řádky (vzniklé po rozdělení merged cells)
  # odstraněny sloupce odpovídající kraji - ponechány pouze okresy
  # odstraněn poslední řádek obsahující průměrný věk za danou oblast
  # formát hodnot je bez oddělování tisíců
  # převod na csv (utf-8) - oddělovač ";"
  # ve výsledném .csv odstranit poslední řádek s prázdnými hodnotami

# skript transformuje data do databázové podoby

import pandas as pd

obdobi = '31.12.2019'

# načtení mužů do DataFrame - nastaven index sloupce "vek"
df_men = pd.read_csv('20191231_vekove_slozeni_muzi_adj.csv', index_col = 0, sep=';', encoding='utf-8')

# načtení žen do DataFrame - nastaven index sloupce "vek"
df_women = pd.read_csv('20191231_vekove_slozeni_zeny_adj.csv', index_col = 0, sep=';', encoding='utf-8')


# do seznamu načteny kódy okresů - muži
header_men = list(df_men.columns)

# do seznamu načteny kódy okresů - ženy
header_women = list(df_women.columns)


# kontrola, zda ženy i muži mají stejný počet sloupců s hodnotami za okres
if len(header_men) == len(header_women):
  print('počet sloupců v souborech je shodný')

  # kontrola, zda se kódy okresů a jejich pořadí shodují u mužů i žen  
  i = 0
  for column_men in header_men:
      if header_men[i] != header_women[i]:
        print(f'Sloupec {i} se nerovná: ženy - {header_women[i]}, muži - {column_men}')
      else:
        print(f'Sloupec {i} je v obou souborech shodný.')
      i = i + 1

else:
  print('pozor počet sloupců v souborech se liší')

# do seznamu načteny hodnoty jednotlivých sloupců (věk) - muži i ženy
# !!! doplnit obdobnou kontrolu jako u sloupců !!!
row_index_men = list(df_men.index)
row_index_women = list(df_women.index)


# zápis do souboru .csv
soubor = open('obyvatelstvo_prevedene.csv','w', encoding='utf-8')

# záhlaví soubor
soubor.write('obdobi,vek,pohlavi,kraj_kod,okres_kod,pocet_obyvatel')
soubor.write('\n')

# data pro muže
for column in header_men:
    for row in row_index_men:
        soubor.write(f'{obdobi},{row},m,{column[:5]},{column},{round(df_men.loc[row, column])}\n')

# data pro ženy
for column in header_women:
    for row in row_index_women:
        soubor.write(f'{obdobi},{row},f,{column[:5]},{column},{round(df_women.loc[row, column])}\n')

soubor.close()