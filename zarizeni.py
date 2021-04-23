import xml.etree.ElementTree as ET
import csv

tree = ET.parse("zarizeni.xml")
root = tree.getroot()
with open("zarizeni.csv", "w", encoding="utf-8", newline='') as ff:
  cols = ["kod", "icopcz", "ico", "pcz", "krajn", "okresn", "drzar", "rezort", "zujedn", "naz", "zknaz", "ulice", "psc", "nazob", "zriz", "typorg", "orp", "pou", "plati_od", "plati_do"]
  writer = csv.writer(ff)
  writer.writerow(cols)
  for line in root:
    values = []
    for kk in cols:
      if kk in line.attrib: values.append(line.attrib[kk])
      else: values.append('')
    writer.writerow(values)
