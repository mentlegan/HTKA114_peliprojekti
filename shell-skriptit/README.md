Skriptit voi suorittaa Linux-ympäristössä, Windowsilla [WSL:n
avulla](https://learn.microsoft.com/en-us/windows/wsl/install)

---

`kayttamattomat-assetit.sh` -- Etsii `grafiikka/` ja `audio/`-kansion
tiedostonimiä projektin `tscn` ja `tres`-tiedostoista ja tulostaa käyttämättömät
assetit. Ei luo, poista, tai muokkaa tiedostoja.

---

`korjaa-uid-virheet.sh` -- Poistaa jokaisesta projektin `tscn` ja
`tres`-tiedostosta UID-arvot:

```
-[gd_scene load_steps=23 format=3 uid="uid://3oa14w4m8khu"]
+[gd_scene load_steps=23 format=3]
```

Korjaa (väliaikaisesti) `invalid UID`-virheet.
**Skripti muokkaa projektitiedostoja! Varmista ennen ajoa että viimeisimmät
muutokset on tallennettu repoon**
