# Plan Za Poboljsanje Oura Parametara (Ramazan + Posle)

## 0) Brzi Rezime (sta da radis)

- Najveca poluga: san (kolicina + stabilnost). U Ramazanu je realno da Readiness/HRV padnu zbog ranog budjenja u 04:30.
- Ti si vec dobar u osnovi: ~10k koraka/dan.
- Dok traje Ramazan: zadrzi korake, treniraj konzervativno (zona 2 + lagana snaga), i "zatvori rupu" sa ranijim spavanjem i/ili dremkom.
- Posle Ramazana: 3-4x zona 2 + 2x snaga nedeljno (postepeno).

Kontekst:
- Dob: 38 godina
- Visina/tezina: 182 cm / 81 kg
- Aktivnost: ~10,000 koraka dnevno, setnja + traka (hodanje/trcanje)
- San: ~7h radnim danom, 8-8.5h vikendom
- Ramazan: ustajanje oko 04:30 (sehur) -> manjak sna zadnjih ~10 dana

Ovo je praktican plan (san/trening/ishrana), nije medicinski savet. Ako imas simptome tipa bol u grudima, preskakanje srca, izrazitu pospanost, hronicni umor ili jako hrkanje, bolje je i pregled.

## 0.1) Snapshot Iz Podataka (InfluxDB / Oura)

Ovo su konkretne vrednosti koje smo videli u InfluxDB za kraj februara 2026. (korisno kao "baseline" i za trend).

### Score trend

| Dan | Readiness | Sleep | Activity |
|---|---:|---:|---:|
| 2026-02-25 | 87 | 82 | 91 |
| 2026-02-26 | 87 | 84 | 86 |
| 2026-02-27 | 83 | 82 | 84 |
| 2026-02-28 | 73 | 76 | (cesto dodje tek kad se dan zatvori) |

### Spavanje (glavni zapis: `type=long_sleep`)

| Dan | Ukupno | Duboki | REM | Efikasnost | Avg HR | Najnizi HR | Avg HRV |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2026-02-25 | 6h 30m | 1h 43m | 1h 05m | 92% | 59 | 54 | 62 |
| 2026-02-26 | 6h 46m | 1h 23m | 1h 22m | 92% | 57 | 52 | 66 |
| 2026-02-27 | 6h 23m | 2h 04m | 1h 18m | 91% | 57 | 49 | 57 |
| 2026-02-28 | 6h 24m | 0h 54m | 1h 08m | 95% | 62 | 54 | 47 |

### Kardiovaskularno (SpO2 / temperatura / vascular age)

| Dan | Vascular age | SpO2 avg | Breathing disturbance | Temp deviation |
|---|---:|---:|---:|---:|
| 2026-02-25 | 37 | 98.85% | 0 | -0.55 |
| 2026-02-26 | 39 | 99.19% | 2 | +0.02 |
| 2026-02-27 | 39 | 99.01% | 1 | -0.12 |
| 2026-02-28 | 37 | 97.97% | 1 | +0.13 |

### Aktivnost (totali)

| Dan | Steps | Active kcal | Total kcal | Walking distance |
|---|---:|---:|---:|---:|
| 2026-02-24 | 2,353 | 140 | 2,159 | 2.34 km |
| 2026-02-25 | 3,440 | 211 | 2,323 | 3.81 km |
| 2026-02-26 | 10,512 | 505 | 2,634 | 9.11 km |
| 2026-02-27 | 7,233 | 352 | 2,446 | 6.35 km |

### Kako da tumacis ovaj snapshot

- 2026-02-28: istovremeno pad Readiness (73) i Sleep (76) uz pad HRV (47), visi Avg HR (62) i blago povisenu temperaturu (+0.13) je tipican signal "slabiji oporavak". U takvim danima trening drzi laganije + fokus na san/hidrataciju.
- U Ramazanu je ovo jos cesce: rano budjenje skracuje san i sece zadnji deo noci (REM), a to se vidi na score-ovima.

## 1) Sta Najvise Dize Brojke (80/20)

1. San (kolicina + stabilnost) -> najveca poluga za Readiness, HRV, nocni puls, temperaturu, Sleep score.
2. Zona 2 kardio (3-4x nedeljno, kad nije Ramazan) -> spusta nocni/mirovni puls i dugorocno dize HRV.
3. Dnevni koraci (ti si vec tu jak) + prekid sedenja -> Activity score i oporavak bez pretreniranosti.
4. Snaga (2x nedeljno) -> misicna masa, metabolizam, zdravlje, dugorocno i san/opravak.
5. Alkohol i kasni obroci -> cesto naglo spuste HRV i pogorsaju puls/REM (kod tebe tokom Ramazana alkohol mozda i nije faktor, ali kasni teski obrok moze biti).

## 2) Ramazan: Minimalno Efektivan Plan (da Oura ide gore)

### 2.1 San (glavni fokus)

Cilj: 7.5-8.5h "u krevetu" kad god je realno.

- Ako ustajes u 04:30, probaj spavanje oko 21:00-21:30 da uhvatis ~7h sna.
- Ako ne mozes ranije u krevet:
  - Dremka 20-30 min (idealno 13:00-16:00), ili
  - Dremka 90 min (jedan puni ciklus), ako mozes.
- Ne juriti jake treninge kad si u deficitu sna.
- Hladnija soba i mrak pomazu kvalitet (efikasnost + manje budjenja).

Napomena:
- Rano budjenje najvise "sece" REM (druga polovina noci). Zato je u Ramazanu cesto kljucno ili ranije zaspati ili ubaciti dremku.

### 2.2 Trening tokom Ramazana (bez preopterecenja)

Osnovno:
- Nastavi 10k koraka dnevno.
- Dodaj lagani strukturirani trening ali ostani konzervativan da ne rusis Readiness.

Zona 2 kardio:
- 2-3x sedmicno, 30-45 min
- Intenzitet: mozes pricati (ne "ubijas" se)
- Vreme:
  - Najbolje 60-120 min posle iftara, ili
  - Pred iftar ali bas lagano (zbog dehidracije)

Snaga:
- 2x sedmicno, 25-35 min, posle iftara
- Princip: ne do otkaza, ostavi 2-3 ponavljanja "u rezervi"
- Primer full-body (2-3 serije po vezbi):
  - Noge: cucanj ili iskorak
  - Hinge: rumunsko mrtvo dizanje / hip hinge
  - Guranje: sklekovi ili potisak
  - Povlacenje: veslanje (traka/bucice/kabl)
  - Core: plank / dead bug

### 2.3 Hidratacija i ishrana (za HRV/puls/temperaturu)

- Izmedju iftara i sehura: 2-2.5L tecnosti (vise ako se znojis).
- Elektroliti (so/kalijum/magnezijum) pomazu ako imas glavobolju ili umor od dehidracije.
- Protein: okvirno 120-140 g/dan (raspodeli: iftar + kasniji obrok + sehur).
- Vecera sto ranije nakon iftara; izbegavaj tesku masnu hranu kasno (dize nocni puls, rusi HRV).

## 3) Posle Ramazana: Plan Da Dugorocno Dizes HRV i Spustas Nocni Puls

Nakon stabilizacije sna:
- Zona 2: 3-4x nedeljno, 30-45 min
- Snaga: 2x nedeljno, 30-45 min
- Koraci: 8-12k dnevno (ti si vec tu)

Napomena o progresiji:
- Povecavaj volumen postepeno (npr. +10-15% nedeljno), da Activity score ne padne zbog preopterecenja.

## 4) Objasnjenje Oura Parametara + Kako Da Ih Popravis

### Readiness (Spremnost)

Sta znaci:
- Ukupna spremnost tela danas; mix sna, oporavka (HRV/puls), temperature i opterecenja.

Kako da poboljsas:
- Vise sna i stabilan ritam.
- Kad je HRV nizak i/ili temperatura povisena: laksi trening i vise odmora.
- Hidratacija i raniji obroci.

Kako da gledas:
- Trend 7-14 dana je bitniji od jedne noci.

### Sleep score

Sta znaci:
- Kolicina + kvalitet sna (trajanje, budjenja, faze, efikasnost, tajming).

Kako da poboljsas:
- Produzi san (najcesce #1), rutina pred spavanje, hladna soba, manje ekrana pred san.

### Activity score

Sta znaci:
- Balans kretanja i oporavka (nije samo "sto jaci trening, to bolje").

Kako da poboljsas:
- Stabilni koraci svaki dan + pametan trening (zona2 + snaga) bez naglih skokova.

### Total sleep duration (Ukupno spavanje)

Sta znaci:
- Ukupno vreme spavanja.

Kako da poboljsas:
- Ranije u krevet, "alarm" za odlazak u krevet, dremka kad fali.

### Deep sleep (Duboki san)

Sta znaci:
- Fizicki oporavak; prirodno varira.

Kako da poboljsas:
- Stabilan san, fizicka aktivnost (ranije u danu), hladna soba, bez kasne teske hrane i alkohola.

### REM

Sta znaci:
- Mentalni oporavak/pamcenje; cesto dolazi vise u drugoj polovini noci.

Kako da poboljsas:
- Produzi san (posebno ako se budis rano); izbegni alkohol.

### Awake time / restlessness (Budnost / nemir)

Sta znaci:
- Prekidi sna i nemir.

Kako da poboljsas:
- Mrak/tisina, hladnija soba, manje tecnosti kasno, smanjenje stresa pre spavanja.

### Sleep efficiency (Efikasnost sna)

Sta znaci:
- Koliki deo vremena u krevetu stvarno spavas.

Kako da poboljsas:
- Dosledan raspored, ne ostajati budan dugo u krevetu, rutina smirivanja.

### Latency (Uspavljivanje)

Sta znaci:
- Koliko ti treba da zaspis.

Kako da poboljsas:
- Kofein ranije, manje ekrana, 30 min "wind-down", disanje 5-10 min.

### Average HR / Lowest HR u snu (prosecni/najnizi puls)

Sta znaci:
- Koliko je telo "mirno" nocu; visi puls cesto znaci stres, kasan obrok, alkohol, dehidraciju ili preopterecenje.

Kako da poboljsas:
- Zona 2 (dugorocno), ranija vecera, dobra hidratacija, stres dole.

### HRV (Average HRV)

Sta znaci:
- Signal autonomnog nervnog sistema i oporavka; bitniji je licni trend nego "poredjenje sa drugima".

Kako da poboljsas:
- San, zona 2, pametna snaga (ne do otkaza), setnje, manje alkohola/kasne hrane, stres menadzment.
- Tokom Ramazana je normalno da padne zbog deficita sna i rutine.

### Temperature deviation (Odstupanje temperature)

Sta znaci:
- Odstupanje od tvog baznog nivoa; moze porasti kod infekcije, upale, stresa, alkohola, preopterecenja ili dehidracije.

Kako da koristis:
- Ako je povisena par dana i HRV/Readiness padaju: to je signal za laksi dan i vise sna/hidratacije.

### SpO2 average

Sta znaci:
- Prosecna nocna saturacija kiseonikom.

Kako da poboljsas:
- Ako je stabilno 97-99%: odlicno.
- Ako cesto pada nisko: spavanje na boku, prohodan nos; ako postoje simptomi (hrkanje + pospanost) vredi proveriti apneju.

### Breathing disturbance index

Sta znaci:
- Indikator poremecaja disanja tokom sna.

Kako da poboljsas:
- Slicno kao SpO2: polozaj, nos, manji stres/kasan obrok; uporno povisen + simptomi -> proveriti.

### Cardiovascular / vascular age

Sta znaci:
- Oura procena (indikativno, nije dijagnoza).

Kako da poboljsas:
- Zona 2 kao glavni alat, snaga 2x nedeljno, san/hidratacija, kontrola stresa; ako imas visak masnoce, i mali pad moze pomoci.

## 5) Kako Da Pratis U Grafani

Dashboardi:
- `grafana/dashboards/oura-overview.json` (scores + osnovni trendovi)
- `grafana/dashboards/oura-sleep-detail.json` (faze sna + HR/HRV tokom sna)
- `grafana/dashboards/oura-activity-detail.json` (koraci/kalorije/aktivnost)

Praktican nacin pracenja:
- Gledaj trendove 7-14 dana.
- Kad padnu Readiness + HRV, a temperatura poraste: smanji intenzitet treninga 24-48h i fokus na san/hidrataciju.

## 6) Sta Je Realno Ocekivati Tokom Ramazana

- Moguce je da:
  - Sleep score i Readiness budu nizi nego van Ramazana (zbog manjka sna i promene ritma).
  - HRV padne, a nocni puls poraste, posebno ako je iftar/sehur tezak ili hidratacija losija.
- Cilj tokom Ramazana nije "maksimum performansi", nego:
  - odrzati korake i bazu,
  - odrzati 2x snagu nedeljno (kratko),
  - odrzati 2-3x zona 2 (lagano),
  - i cuvati san/hidrataciju da se brojke ne srozaju.

