# ULTRA-DETALJNA ANALIZA: /uomback/suicapture

## SADRŽAJ
1. [Arhitektura sistema](#1-arhitektura-sistema)
2. [Struktura saveSuicapture()](#2-struktura-savesuicapture)
3. [SEKCIJA A: Entry Params](#sekcija-a-entry-params)
4. [SEKCIJA B: Model](#sekcija-b-model)
5. [SEKCIJA C: Structure](#sekcija-c-structure-korisniciraČuni)
6. [Kompletni dijagram izvora podataka](#kompletni-dijagram-izvora-podataka)

---

## 1. ARHITEKTURA SISTEMA

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              SLOJEVI APLIKACIJE                                         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ┌─────────────────────┐                                                                │
│  │   URL / Router      │  /evidencija/residential/1174/162/0?processId=10&basketnum=X  │
│  └──────────┬──────────┘                                                                │
│             ▼                                                                           │
│  ┌─────────────────────┐                                                                │
│  │   FlowComponent     │  Glavni wrapper, učitava workflow.json                         │
│  └──────────┬──────────┘                                                                │
│             ▼                                                                           │
│  ┌─────────────────────┐                                                                │
│  │  FlowTabComponent   │  <z-flow-tabs> - upravlja koracima (tabovima)                  │
│  └──────────┬──────────┘                                                                │
│             ▼                                                                           │
│  ┌─────────────────────┐                                                                │
│  │       LFS           │  <lfs-wrapper> - dinamički učitava komponente po imenu         │
│  └──────────┬──────────┘                                                                │
│             ▼                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐    │
│  │         VpnEvidencijaUslugeComponent (evidencija-usluge.component.ts)           │    │
│  │  ┌───────────────────────────────────────────────────────────────────────────┐  │    │
│  │  │  SERVISI (Injected):                                                      │  │    │
│  │  │  ├── RestApiService (api)     → HTTP pozivi                               │  │    │
│  │  │  ├── Model (db)               → Stanje forme (model, output, params)      │  │    │
│  │  │  ├── SharedDataService        → Globalno stanje korisnika/računa          │  │    │
│  │  │  ├── Actions (action)         → Transformacija za spremanje               │  │    │
│  │  │  ├── UserService (user)       → Info o ulogovanom korisniku               │  │    │
│  │  │  └── Spinner                  → Loading indikator                         │  │    │
│  │  └───────────────────────────────────────────────────────────────────────────┘  │    │
│  │  ┌───────────────────────────────────────────────────────────────────────────┐  │    │
│  │  │  LOKALNO STANJE:                                                          │  │    │
│  │  │  ├── this.ca         → Customer Account (korisnik)                        │  │    │
│  │  │  ├── this.ba         → Billing Account (račun za naplatu)                 │  │    │
│  │  │  ├── this.sa         → Service Account (servisni račun)                   │  │    │
│  │  │  ├── this.contact    → Kontakt osoba                                      │  │    │
│  │  │  ├── this.basket     → Korpa/zahtjev                                      │  │    │
│  │  │  ├── this.structure  → Dinamička forma (JSON sa backenda)                 │  │    │
│  │  │  └── this.hasitems   → Da li ima stavki u korpi                           │  │    │
│  │  └───────────────────────────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────────────────────┘    │
│             ▼                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐    │
│  │                    DINAMIČKA FORMA (z-dynamic modul)                            │    │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                  │    │
│  │  │ ContentLoader   │  │ InputComponent  │  │ SelectComponent │  ...             │    │
│  │  │ (wrapper)       │  │ (text input)    │  │ (dropdown)      │                  │    │
│  │  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘                  │    │
│  │           │                    │                    │                           │    │
│  │           └────────────────────┴────────────────────┘                           │    │
│  │                                │                                                │    │
│  │                    ┌───────────▼───────────┐                                    │    │
│  │                    │   Model Service (db)  │                                    │    │
│  │                    │   ├── db.model        │  ← Vrijednosti polja               │    │
│  │                    │   ├── db.output       │  ← Struktura za spremanje          │    │
│  │                    │   └── db.params       │  ← Parametri forme                 │    │
│  │                    └───────────────────────┘                                    │    │
│  └─────────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. STRUKTURA saveSuicapture()

```typescript
saveSuicapture() {
  let jsonSetup = {
    entryParams: JSON.stringify({
      processId: this.processId,                    // 1️⃣
      offerId: this.offerId,                        // 2️⃣
      specId: this.specId,                          // 3️⃣
      appProcessId: this.appProcessId,              // 4️⃣
      orderEntrySetupRequests: this.orderEntrySetupRequests,  // 5️⃣
      productOfferId: this.productOfferId,          // 6️⃣
      productSpecificationId: this.productSpecificationId     // 7️⃣
    }),
    model: JSON.stringify({
      model: this.db.model,      // 8️⃣
      output: this.setOutput()   // 9️⃣
    }),
    structure: JSON.stringify({
      ca: this.ca,               // 🔟
      ba: this.ba,               // 1️⃣1️⃣
      sa: this.sa,               // 1️⃣2️⃣
      contact: this.contact,     // 1️⃣3️⃣
      ocontact: this.ocontact,   // 1️⃣4️⃣
      basket: this.basket,       // 1️⃣5️⃣
      hasitems: this.hasitems    // 1️⃣6️⃣
    }),
    ordnum: this.basket.basketnum  // 1️⃣7️⃣
  };
  this.api.post('/uomback/suicapture', jsonSetup).subscribe();
}
```

---

# SEKCIJA A: ENTRY PARAMS

## 1️⃣ this.processId

### Izvor: URL Query Parameter

```
URL: /evidencija/residential/1174/162/0?processId=10&...
                                        ↑
                                   Query param
```

### Tok podataka:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: Korisnik bira proces u Sales Catalog                                   │
│                                                                                 │
│ sales-catalog.component.ts:                                                     │
│ ngOnInit() {                                                                    │
│   this.route.queryParams.subscribe((params: Params) => {                        │
│     this.processId = params.processId;  // npr. "10"                            │
│   });                                                                           │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: Korisnik klikne na ponudu → Navigacija                                 │
│                                                                                 │
│ offer.component.ts linija 99-100:                                               │
│ validatechildrens(children, items) {                                            │
│   Object.assign(this.queries, {                                                 │
│     processId: children.processId[0] || children.processId,  // iz ponude       │
│     from: 'VPN',                                                                │
│     code: this.query['code']                                                    │
│   });                                                                           │
│   this.router.navigate(                                                         │
│     ['/evidencija', this.type, children.key, this.specId, 0],                   │
│     { queryParams: this.queries }                                               │
│   );                                                                            │
│ }                                                                               │
│                                                                                 │
│ Rezultat: /evidencija/residential/1174/162/0?processId=10                       │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: VpnEvidencijaUslugeComponent čita iz URL-a                             │
│                                                                                 │
│ evidencija-usluge.component.ts linija 81-82:                                    │
│ ngOnInit() {                                                                    │
│   this.subscribtion = this.route.queryParams.subscribe((params: Params) => {    │
│     Object.assign(this, params);                                                │
│     //                  ↓                                                       │
│     // this.processId = params.processId = "10"                                 │
│   });                                                                           │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Vrijednosti processId-a i njihovo značenje:

| processId | Značenje |
|-----------|----------|
| 10 | Osnovne usluge - Residential Sales |
| 11 | Dodatne usluge na broj |
| 21 | Migracija |
| 22 | Raskid |
| 23 | Promjena paketa |
| 35 | SME usluge |
| 36 | Grupne usluge |

---

## 2️⃣ this.offerId

### Izvor: URL Route Parameter

```
URL: /evidencija/residential/1174/162/0
                             ↑
                        Route param :offerId
```

### Tok podataka:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: Definicija rute                                                        │
│                                                                                 │
│ app.routes.ts linija 12:                                                        │
│ {                                                                               │
│   path: 'evidencija/:type/:offerId/:specId/:activeIndex',                       │
│   component: FlowComponent                                                      │
│ }                                                                               │
│                                                                                 │
│ URL segment: /evidencija/residential/1174/162/0                                 │
│                                      ↑                                          │
│                               :offerId = "1174"                                 │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: Postavljanje od strane OfferComponent                                  │
│                                                                                 │
│ offer.component.ts linija 100:                                                  │
│ this.router.navigate([                                                          │
│   '/evidencija',                                                                │
│   this.type,           // "residential"                                         │
│   children.key,        // "1174" - ID ponude iz kataloga                        │
│   this.specId,         // "162"                                                 │
│   0                    // activeIndex                                           │
│ ], { queryParams: this.queries });                                              │
│                                                                                 │
│ children.key dolazi iz API response-a za ponude kataloga                        │
│ API: /pcrt/order-entry vraca strukturu sa ponudama gdje svaka ima "key"         │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: VpnEvidencijaUslugeComponent čita iz URL-a                             │
│                                                                                 │
│ evidencija-usluge.component.ts linija 85:                                       │
│ ngOnInit() {                                                                    │
│   this.route.params.subscribe((params: Params) => {                             │
│     Object.assign(this, params);                                                │
│     //                  ↓                                                       │
│     // this.offerId = params.offerId = "1174"                                   │
│     // this.specId = params.specId = "162"                                      │
│     // this.type = params.type = "residential"                                  │
│   });                                                                           │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Šta je offerId?

```
offerId = ProductOffer ID u bazi podataka
         Identificira konkretnu ponudu/proizvod koji se naručuje

Primjer: 1174 = "BH Telecom Internet 100 Mbps" ponuda
```

---

## 3️⃣ this.specId

### Izvor: URL Route Parameter

```
URL: /evidencija/residential/1174/162/0
                                  ↑
                           Route param :specId
```

### Tok podataka:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: OfferComponent dohvaća specId                                          │
│                                                                                 │
│ offer.component.ts linija 58:                                                   │
│ ngOnInit() {                                                                    │
│   this.specId = this.query['SPECIFICATION_ID'];  // Iz parent komponente        │
│ }                                                                               │
│                                                                                 │
│ ILI dinamički dohvat:                                                           │
│ offer.component.ts linija 109-113:                                              │
│ getSpecificationIdByOfferId(id, children, items) {                              │
│   this.api.get('/common/dynamic-query/result/GET_SPECIFICATION_ID_BY_OFFER_ID', │
│     { id: id }                                                                  │
│   ).subscribe((r: any) => {                                                     │
│     this.specId = r.payload[0].id;  // npr. "162"                               │
│   });                                                                           │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: Navigacija sa specId                                                   │
│                                                                                 │
│ offer.component.ts linija 100:                                                  │
│ this.router.navigate([                                                          │
│   '/evidencija', this.type, children.key, this.specId, 0                        │
│ ]);                                   ↑                                         │
│                                    "162"                                        │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: VpnEvidencijaUslugeComponent                                           │
│                                                                                 │
│ this.route.params.subscribe((params: Params) => {                               │
│   Object.assign(this, params);                                                  │
│   // this.specId = "162"                                                        │
│ });                                                                             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Šta je specId?

```
specId = ProductSpecification ID
         Specificira koja verzija/varijanta ponude se koristi
         Jedna ponuda može imati više specifikacija

Primjer: Ponuda 1174 može imati:
  - specId 162 = "Internet 100 Mbps - standardna instalacija"
  - specId 163 = "Internet 100 Mbps - poslovna instalacija"
```

---

## 4️⃣ this.appProcessId

### Izvor: URL Query Parameter (opcionalno)

```typescript
// Može doći iz URL-a ili biti undefined
this.appProcessId = params.appProcessId || undefined;
```

### Kada se koristi:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ appProcessId se koristi za:                                                     │
│ - Grupne zahtjeve gdje se process razlikuje od glavnog procesa                  │
│ - Specijalne workflow-ove                                                       │
│                                                                                 │
│ Ako nije definiran u URL-u, ostaje undefined                                    │
│                                                                                 │
│ Primjer korištenja u getDynamic():                                              │
│ this.api.get('/pcrt/order-entry', {                                             │
│   interactionId: 16,                                                            │
│   productOfferId: this.offerId,                                                 │
│   productSpecificationId: this.specId,                                          │
│   appProcessId: this.processId,  // ← Koristi processId ako appProcessId nema   │
│   setupType: this.setupType                                                     │
│ });                                                                             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5️⃣ this.orderEntrySetupRequests

### Izvor: URL Query Parameter (opcionalno)

### Kada postoji:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ orderEntrySetupRequests se koristi za GRUPNE ZAHTJEVE                           │
│                                                                                 │
│ Kada korisnik kreira grupni zahtjev (više ponuda odjednom):                     │
│                                                                                 │
│ sales-catalog.component.ts linija 245-250:                                      │
│ groupedServices() {                                                             │
│   const list = this.sharedData.items.map((item) => ({                           │
│     productOfferId: item.pproductofferId,                                       │
│     productSpecificationId: item.specificationId,                               │
│     appProcessId: this.processId                                                │
│   }));                                                                          │
│   this.queries.orderEntrySetupRequests = JSON.stringify(list);                  │
│ }                                                                               │
│                                                                                 │
│ Rezultat URL:                                                                   │
│ ?orderEntrySetupRequests=[{"productOfferId":1174,"productSpecificationId":162}, │
│                           {"productOfferId":1175,"productSpecificationId":163}] │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ VpnEvidencijaUslugeComponent:                                                   │
│                                                                                 │
│ ngOnInit() {                                                                    │
│   this.route.queryParams.subscribe((params: Params) => {                        │
│     Object.assign(this, params);                                                │
│     // this.orderEntrySetupRequests = "[{...},{...}]" (JSON string)             │
│   });                                                                           │
│ }                                                                               │
│                                                                                 │
│ Koristi se u getGroupDynamic() linija 157-163:                                  │
│ getGroupDynamic() {                                                             │
│   let request = {                                                               │
│     appProcessId: this.processId,                                               │
│     orderEntrySetupRequests: JSON.parse(this.orderEntrySetupRequests),          │
│     productOfferId: this.offerId,                                               │
│     productSpecificationId: this.specId                                         │
│   };                                                                            │
│   this.api.post('/pcrt/order-entry/group', request)...                          │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6️⃣ this.productOfferId i 7️⃣ this.productSpecificationId

### Izvor: URL Query Parameters (opcionalno)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Ovi parametri su DUPLIKATI offerId i specId                                     │
│ Koriste se u nekim edge slučajevima za backward compatibility                   │
│                                                                                 │
│ Tok:                                                                            │
│ 1. Dolaze iz URL query params (ako postoje)                                     │
│ 2. Object.assign(this, params) ih postavlja ako su u URL-u                      │
│ 3. Ako nisu u URL-u, ostaju undefined                                           │
│                                                                                 │
│ Uglavnom su undefined jer se koriste offerId/specId iz route params             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

# SEKCIJA B: MODEL

## 8️⃣ this.db.model

### Izvor: Model Service + Dinamička forma

### Detaljni tok:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: Inicijalizacija praznog modela                                         │
│                                                                                 │
│ evidencija-usluge.component.ts linija 122:                                      │
│ assignObjects() {                                                               │
│   this.db.assign("model", { auto: {} });                                        │
│   //                       ↑                                                    │
│   //              Početno stanje: { auto: {} }                                  │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: Učitavanje strukture forme                                             │
│                                                                                 │
│ getDynamic() → GET /pcrt/order-entry                                            │
│                                                                                 │
│ Response primjer:                                                               │
│ {                                                                               │
│   "structure": [                                                                │
│     {                                                                           │
│       "name": "kontakt_podaci",                                                 │
│       "template": "basic_block",                                                │
│       "elements": [                                                             │
│         { "name": "ime", "template": "input", "elementType": "text" },          │
│         { "name": "telefon", "template": "input", "elementType": "text" },      │
│         { "name": "email", "template": "input", "elementType": "email" }        │
│       ]                                                                         │
│     }                                                                           │
│   ]                                                                             │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: Za svaki element forme → ContentLoaderComponent                        │
│                                                                                 │
│ contentloader.component.ts linija 34:                                           │
│ ngOnInit() {                                                                    │
│   // ValueManager postavlja početnu vrijednost u model                          │
│   this.ValueManager.set(this.items, this.model, this.items.parameters, ...);    │
│ }                                                                               │
│                                                                                 │
│ value.manager.ts linija 25-32:                                                  │
│ set(el, model, parameters, mod) {                                               │
│   if (model[el.name] === undefined) {                                           │
│     // Pokušaj postaviti vrijednost iz:                                         │
│     this.autoincrement(el, model, parameters)     // 1. Auto-increment          │
│       || this.setValueByRefOrCode(el, model, parameters)  // 2. Mapping ref     │
│       || this.setDefaultValue(el, model);         // 3. Default value           │
│   }                                                                             │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 4: Two-way binding - korisnikov unos                                      │
│                                                                                 │
│ input.template.html linija 7:                                                   │
│ <input [(ngModel)]="model[items.name]" ... />                                   │
│              ↑                                                                  │
│              └── Two-way binding: model["ime"] = "Marko"                        │
│                                                                                 │
│ Svaki korisnikov unos automatski ažurira this.db.model                          │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ REZULTAT: this.db.model nakon korisnikovog unosa                                │
│                                                                                 │
│ this.db.model = {                                                               │
│   auto: {                                                                       │
│     // Auto-generirane vrijednosti (npr. iz lookupStatement)                    │
│     generated_id: "12345",                                                      │
│     system_date: "2026-01-30"                                                   │
│   },                                                                            │
│   ime: "Marko Marković",           // Korisnikov unos                           │
│   telefon: "061123456",            // Korisnikov unos                           │
│   email: "marko@email.com",        // Korisnikov unos                           │
│   paket: "PAKET_100",              // Korisnikov odabir iz dropdown-a           │
│   brzina: "100",                   // Auto-popunjeno na osnovu paketa           │
│   datum_aktivacije: "2026-02-01"   // Korisnikov odabir iz datepicker-a         │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Dijagram toka podataka za jedno polje:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                    ŽIVOTNI CIKLUS JEDNOG POLJA U FORMI                           │
│                                                                                  │
│  Backend JSON               Angular Component           Korisnik                 │
│  ┌──────────────┐          ┌──────────────────┐        ┌──────────────┐         │
│  │ {            │          │                  │        │              │         │
│  │  "name":     │ ──────►  │ ContentLoader    │        │   Browser    │         │
│  │   "telefon", │          │ ┌──────────────┐ │        │              │         │
│  │  "template": │          │ │ ValueManager │ │        │ ┌──────────┐ │         │
│  │   "input",   │          │ │ .set()       │─┼───────►│ │ <input>  │ │         │
│  │  "value": {  │          │ └──────────────┘ │        │ │          │ │         │
│  │   "default": │          │                  │        │ └────┬─────┘ │         │
│  │    ""        │          │ db.model =       │        │      │       │         │
│  │  }           │          │ { telefon: "" }  │        │      │ tipka │         │
│  │ }            │          │        ▲         │        │      ▼       │         │
│  └──────────────┘          │        │         │        │ "061123456"  │         │
│                            │        │         │        │      │       │         │
│                            │ [(ngModel)]      │◄───────┼──────┘       │         │
│                            │ binding          │        │              │         │
│                            │                  │        │              │         │
│                            │ db.model =       │        │              │         │
│                            │ {telefon:        │        │              │         │
│                            │  "061123456"}    │        │              │         │
│                            └──────────────────┘        └──────────────┘         │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 9️⃣ this.setOutput()

### Izvor: Transformacija db.output strukture

### Detaljni tok:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: db.output se gradi tokom renderanja forme                              │
│                                                                                 │
│ contentloader.component.ts linija 35:                                           │
│ ngOnInit() {                                                                    │
│   this.db.setoutput(this.items, this.model, this.output, this.index);           │
│ }                                                                               │
│                                                                                 │
│ model.service.ts linija 19-21:                                                  │
│ setoutput(el, model, output, index) {                                           │
│   el.output = output[index] = {                                                 │
│     attr: {},                    // Child atributi                              │
│     items: {},                   // Child ponude                                │
│     spec: {},                    // Child specifikacije                         │
│     name: el.name,               // "telefon"                                   │
│     code: el.code,               // "ATT_TEL"                                   │
│     value: model,                // Referenca na model objekt                   │
│     active: el.initActivity,     // true/false                                  │
│     calss: el.businessClassification,  // "Attribute"/"OFFER"/"SPECIFICATION"  │
│     label: el.label,             // "Broj telefona"                             │
│     elementType: el.elementType, // "text"                                      │
│     ...                                                                         │
│   };                                                                            │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: Struktura db.output nakon renderanja                                   │
│                                                                                 │
│ this.db.output = {                                                              │
│   "kontakt_podaci": {                   // SPECIFICATION                        │
│     name: "kontakt_podaci",                                                     │
│     calss: "SPECIFICATION",                                                     │
│     active: true,                                                               │
│     attr: {                                                                     │
│       "ime": {                          // ATTRIBUTE                            │
│         name: "ime",                                                            │
│         code: "ATT_IME",                                                        │
│         calss: "Attribute",                                                     │
│         active: true,                                                           │
│         elementType: "text",                                                    │
│         value: { ime: "Marko Marković" }  // ← Referenca na model               │
│       },                                                                        │
│       "telefon": {                                                              │
│         name: "telefon",                                                        │
│         code: "ATT_TEL",                                                        │
│         calss: "Attribute",                                                     │
│         value: { telefon: "061123456" }                                         │
│       }                                                                         │
│     },                                                                          │
│     items: {                                                                    │
│       "internet_paket": {               // OFFER                                │
│         name: "internet_paket",                                                 │
│         code: "1234",                                                           │
│         calss: "OFFER",                                                         │
│         active: true,                                                           │
│         attr: {                                                                 │
│           "brzina": {                   // ATTRIBUTE unutar OFFER               │
│             name: "brzina",                                                     │
│             calss: "Attribute",                                                 │
│             value: { brzina: "100" }                                            │
│           }                                                                     │
│         }                                                                       │
│       }                                                                         │
│     }                                                                           │
│   }                                                                             │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: setOutput() - Priprema za slanje                                       │
│                                                                                 │
│ evidencija-usluge.component.ts linija 294:                                      │
│ setOutput() {                                                                   │
│   // Deep copy da ne mutiramo original                                          │
│   let output = JSON.parse(JSON.stringify(this.db.output));                      │
│   this.handleOutput(output);                                                    │
│   return output;                                                                │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 4: handleOutput() - Transformacija                                        │
│                                                                                 │
│ evidencija-usluge.component.ts linija 296-302:                                  │
│ handleOutput(output) {                                                          │
│   for (let item in output) {                                                    │
│     // Rekurzivno procesiraj sve nivoe                                          │
│     this.handleOutput(output[item].attr);                                       │
│     this.handleOutput(output[item].items);                                      │
│     this.handleOutput(output[item].spec);                                       │
│                                                                                 │
│     // Za Attribute: konvertuj value u attvalue                                 │
│     if (output[item].calss === "Attribute" && output[item].value) {             │
│       output[item].attvalue = output[item].value[output[item].name] || null;    │
│       //            ↑                     ↑                                     │
│       //     "061123456"         { telefon: "061123456" }["telefon"]            │
│     }                                                                           │
│     delete output[item].value;  // Obriši value objekt                          │
│   }                                                                             │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ REZULTAT: Output spreman za slanje                                              │
│                                                                                 │
│ {                                                                               │
│   "kontakt_podaci": {                                                           │
│     name: "kontakt_podaci",                                                     │
│     calss: "SPECIFICATION",                                                     │
│     active: true,                                                               │
│     attr: {                                                                     │
│       "ime": {                                                                  │
│         name: "ime",                                                            │
│         code: "ATT_IME",                                                        │
│         calss: "Attribute",                                                     │
│         attvalue: "Marko Marković"   // ← Vrijednost direktno                   │
│         // value je obrisan                                                     │
│       },                                                                        │
│       "telefon": {                                                              │
│         name: "telefon",                                                        │
│         code: "ATT_TEL",                                                        │
│         calss: "Attribute",                                                     │
│         attvalue: "061123456"        // ← Vrijednost direktno                   │
│       }                                                                         │
│     }                                                                           │
│   }                                                                             │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

# SEKCIJA C: STRUCTURE (Korisnici/Računi)

## 🔟 this.ca (Customer Account)

### Izvor: SharedDataService → API poziv

### Kompletan tok:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: Korisnik pretražuje korisnika u Sales komponenti                       │
│                                                                                 │
│ Korisnik upiše JMB/ime u search → Odabere korisnika iz rezultata                │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: SalesComponent.getCa()                                                 │
│                                                                                 │
│ sales.component.ts linija 221-246:                                              │
│ getCa(caId, show = true) {                                                      │
│   this.api.get('/ccm/customer/customerBlock-id', {                              │
│     id: caId,                        // npr. 130025794                          │
│     offerId: this.ss.offerId         // Ponuda za provjeru eligibility          │
│   }).subscribe(results => {                                                     │
│     this.customerGeneralInfo = results['payload'];                              │
│                                                                                 │
│     // Spremi u SharedDataService                                               │
│     Object.assign(                                                              │
│       this.sharedData.customer.customerGeneralInfo,                             │
│       this.customerGeneralInfo                                                  │
│     );                                                                          │
│                                                                                 │
│     this.sharedData.caId = this.customerGeneralInfo.id;                         │
│   });                                                                           │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: API Response - Struktura CA objekta                                    │
│                                                                                 │
│ GET /ccm/customer/customerBlock-id?id=130025794                                 │
│                                                                                 │
│ Response:                                                                       │
│ {                                                                               │
│   "payload": {                                                                  │
│     "id": 130025794,                                                            │
│     "status": "A",                     // Active                                │
│     "activationdate": "2026-01-30T09:12:31.000",                                │
│     "customerstypeCode": "1000",       // Tip korisnika                         │
│     "customertypeCode": "100",         // 100=Fizičko lice, 200=Pravno          │
│     "customertypeName": "Fizičko lice",                                         │
│     "mainlocationId": 2,                                                        │
│     "mainlocationName": "Direkcija Sarajevo",                                   │
│     "saleslocationId": 2,                                                       │
│     "salesslocationId": 24,                                                     │
│     "salesslocationName": "Šalter-Dolac Malta",                                 │
│     "pCaId": 130025794,                // Parent CA ID (self-reference)         │
│     "parentInd": "1",                  // 1=Parent, 0=Not parent                │
│     "parentchildInfo": "1",                                                     │
│                                                                                 │
│     "customerinfo": {                  // Osnovni podaci o osobi                │
│       "birthdate": "2026-01-19",                                                │
│       "firstname": "JNF-8241",                                                  │
│       "lastname": "JNF-8241",                                                   │
│       "surname": "JNF-8241",                                                    │
│       "genderCode": "M",                                                        │
│       "defaultCustomer": "JNF-8241 JNF-8241"                                    │
│     },                                                                          │
│                                                                                 │
│     "ccustomergdpr": {                 // GDPR saglasnost                        │
│       "promNotfcs": "0",                                                        │
│       "providingData": "1",                                                     │
│       "bhtMarketing": "1",                                                      │
│       "profiling": "1",                                                         │
│       "status": "1"                                                             │
│     },                                                                          │
│                                                                                 │
│     "contacts": [...],                 // Lista kontakata                       │
│     "addresses": [...],                // Lista adresa                          │
│     "customeridents": [...],           // Identifikacioni dokumenti             │
│     "groupedByTechnology": [...]       // Billing accounti po tehnologiji       │
│   }                                                                             │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 4: Navigacija na evidenciju                                               │
│                                                                                 │
│ offer.component.ts linija 92:                                                   │
│ validatechildrens(children, items) {                                            │
│   // Dodaj caId u URL parametre                                                 │
│   this.queries[required + 'Id'] = this[required].id;                            │
│   // this.queries.caId = 130025794                                              │
│   // this.queries.baId = 330021716                                              │
│                                                                                 │
│   this.router.navigate(['/evidencija', ...], { queryParams: this.queries });    │
│ }                                                                               │
│                                                                                 │
│ Rezultat URL:                                                                   │
│ /evidencija/residential/1174/162/0?caId=130025794&baId=330021716&...            │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 5: VpnEvidencijaUslugeComponent.setcustomeraccounts()                     │
│                                                                                 │
│ evidencija-usluge.component.ts linija 103-115:                                  │
│ setcustomeraccounts() {                                                         │
│   // Dohvati CA iz SharedDataService                                            │
│   this.ca = !this.ca.id && Object.assign({},                                    │
│     this.sharedData.customer.customerGeneralInfo.id                             │
│       ? this.sharedData.customer.customerGeneralInfo                            │
│       : {}                                                                      │
│   );                                                                            │
│                                                                                 │
│   // Sada this.ca sadrži kompletan objekt sa svim podacima                      │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1️⃣1️⃣ this.ba (Billing Account)

### Izvor: SharedDataService → API poziv

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ TOK PODATAKA ZA BA:                                                             │
│                                                                                 │
│ 1. Korisnik odabere Billing Account u SalesComponent                            │
│    └─→ sales.component.ts: showBa() ili openBaCustomerJump()                    │
│                                                                                 │
│ 2. API poziv:                                                                   │
│    GET /ccm/customer/customerBABlock-id/{baId}                                  │
│                                                                                 │
│ 3. Response se sprema:                                                          │
│    Object.assign(this.sharedData.customer.customerBillInfo, response.payload);  │
│                                                                                 │
│ 4. U VpnEvidencijaUslugeComponent:                                              │
│    setcustomeraccounts() {                                                      │
│      this.ba = Object.assign({},                                                │
│        this.sharedData.customer.customerBillInfo || {}                          │
│      );                                                                         │
│    }                                                                            │
│                                                                                 │
│ BA struktura:                                                                   │
│ {                                                                               │
│   "id": 330021716,                                                              │
│   "status": "A",                                                                │
│   "customerId": 130025794,           // Parent CA                               │
│   "accountclassCode": "BA",                                                     │
│   "customerName": "JNF-8241-B",                                                 │
│   "pCaId": 130025794,                                                           │
│   "pBaId": 330021716,                                                           │
│   "addresses": [...],                 // Billing adrese                         │
│   "billingAddress": "GRAD SARAJEVO, 24 Juni 234"                                │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1️⃣2️⃣ this.sa (Service Account)

### Izvor: SharedDataService → API poziv (opcionalno)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ TOK PODATAKA ZA SA:                                                             │
│                                                                                 │
│ 1. Korisnik odabere Service Account (instalacijska adresa)                      │
│    └─→ sales.component.ts: getServiceAccount(id)                                │
│                                                                                 │
│ 2. API poziv:                                                                   │
│    GET /ccm/customer/sa-general?id={saId}                                       │
│                                                                                 │
│ 3. Response se sprema:                                                          │
│    Object.assign(this.sharedData.customer.saInfo, response.payload);            │
│                                                                                 │
│ 4. U VpnEvidencijaUslugeComponent:                                              │
│    setcustomeraccounts() {                                                      │
│      this.sa = this.sharedData.customer.saInfo || {};                           │
│    }                                                                            │
│                                                                                 │
│ ILI može biti postavljen drag-and-drop:                                         │
│    evidencija-usluge.component.ts linija 197-200:                               │
│    drop(event) {                                                                │
│      if (event.dragData.pSaId) {                                                │
│        this.sa = {                                                              │
│          id: event.dragData.pSaId,                                              │
│          address: event.dragData.address,                                       │
│          addressId: event.dragData.addressId                                    │
│        };                                                                       │
│      }                                                                          │
│    }                                                                            │
│                                                                                 │
│ SA struktura:                                                                   │
│ {                                                                               │
│   "id": 12345,                                                                  │
│   "address": "GRAD SARAJEVO, 24 Juni 234",                                      │
│   "addressId": 21177314                                                         │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1️⃣3️⃣ this.contact i 1️⃣4️⃣ this.ocontact

### Izvor: Drag-and-drop ili inicijalno prazan

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ INICIJALIZACIJA:                                                                │
│                                                                                 │
│ evidencija-usluge.component.ts linija 41-42:                                    │
│ public contact: any = { contact: true };   // Označava da je kontakt            │
│ public ocontact: any = {}                  // Other contact (prazan)            │
│                                                                                 │
│ POSTAVLJANJE PUTEM DRAG-AND-DROP:                                               │
│                                                                                 │
│ evidencija-usluge.component.ts linija 194-201:                                  │
│ drop(event: any) {                                                              │
│   if (this.db.mod != 'preview' && event.dragData.pContactId) {                  │
│     Object.assign(                                                              │
│       this[!this.contact.id ? "contact" : "ocontact"],  // Prvi ili drugi       │
│       {                                                                         │
│         id: event.dragData.id,                                                  │
│         contact: true,                                                          │
│         croletypeName: event.dragData.croletypeName,                            │
│         firstname: event.dragData.firstname                                     │
│       }                                                                         │
│     );                                                                          │
│   }                                                                             │
│ }                                                                               │
│                                                                                 │
│ KORIŠTENJE U setBasket():                                                       │
│                                                                                 │
│ evidencija-usluge.component.ts linija 208-212:                                  │
│ setBasket() {                                                                   │
│   basket.acontactId = this.contact.id;       // Glavni kontakt                  │
│   basket.ocontact1Id = this.ocontact.id      // Drugi kontakt (ako postoji)     │
│     ? this.ocontact.id                                                          │
│     : this.contact.id;                       // Ili glavni ako nema drugi       │
│ }                                                                               │
│                                                                                 │
│ STRUKTURA:                                                                      │
│ this.contact = {                                                                │
│   contact: true,                                                                │
│   id: 45112814,                                                                 │
│   croletypeName: "Korisnik",                                                    │
│   firstname: "Marko Marković"                                                   │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1️⃣5️⃣ this.basket

### Izvor: Kreiran lokalno + ažuriran iz API response-a

### Kompletan tok:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 1: Inicijalizacija praznog basket-a                                       │
│                                                                                 │
│ evidencija-usluge.component.ts linija 80:                                       │
│ ngOnInit() {                                                                    │
│   this.basket = {};  // Prazan objekt                                           │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 2: setBasket() - Priprema za slanje                                       │
│                                                                                 │
│ evidencija-usluge.component.ts linija 204-237:                                  │
│ setBasket() {                                                                   │
│   let basket: any = {};                                                         │
│                                                                                 │
│   // Postojeći ID (null ako novi zahtjev)                                       │
│   basket.id = this.basket.id ? this.basket.id : null;                           │
│                                                                                 │
│   // Head basket (za grupne zahtjeve)                                           │
│   basket.headbasketnum = this.headbasketnum;                                    │
│                                                                                 │
│   // Kontakti                                                                   │
│   basket.acontactId = this.contact.id;                                          │
│   basket.ocontact1Id = this.ocontact.id || this.contact.id;                     │
│                                                                                 │
│   // Računi (iz this.ca, this.ba, this.sa)                                      │
│   basket.cacustomerId = this.ca.id;         // Customer Account ID              │
│   basket.bacustomerId = this.ba.id;         // Billing Account ID               │
│   basket.sacustomerId = this.sa.id;         // Service Account ID               │
│                                                                                 │
│   // Lokacija prodaje (iz UserService)                                          │
│   basket.saleschanneltypeCode = this.user.getChannel();                         │
│   basket.saleslocationId = this.user.getSalesLocationId();                      │
│   basket.salesslocationId = this.user.getSubSalesLocationId();                  │
│                                                                                 │
│   // Tip korpe                                                                  │
│   basket.baskettypeCode = this.basket.baskettypeCode;                           │
│                                                                                 │
│   // Korisnički unos                                                            │
│   basket.description = this.basket.description;                                 │
│   basket.expecteddate = this.basket.expecteddate;                               │
│   basket.comments = this.basket.comments;                                       │
│   basket.refnumber = this.basket.refnumber;                                     │
│   basket.refdate = this.basket.refdate;                                         │
│                                                                                 │
│   // Atributi korpe (metapodaci)                                                │
│   basket.basketatts = [                                                         │
│     { attname: "PRODUCTOFFER_ID", attvalue: this.offerId },                     │
│     { attname: "SPECIFICATION_ID", attvalue: this.specId },                     │
│     { attname: "PROCESS_ID", attvalue: this.processId },                        │
│     { attname: "TYPE", attvalue: this.type },                                   │
│     { attname: 'REQUIRED', attvalue: this.r?.join('&r=') || this.r }            │
│   ];                                                                            │
│                                                                                 │
│   return basket;                                                                │
│ }                                                                               │
└────────────────────────────────────────┬────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│ KORAK 3: saveBasket() - POST na API                                             │
│                                                                                 │
│ evidencija-usluge.component.ts linija 248-256:                                  │
│ saveBasket(callback) {                                                          │
│   this.api.post('/uomback/basket/save', this.setBasket())                       │
│     .subscribe((r: RestPayload) => {                                            │
│       // Ažuriraj this.basket sa response-om                                    │
│       Object.assign(this.basket, r.payload);                                    │
│       //                         ↑                                              │
│       // Response sadrži: id, basketnum, status, created, createdBy, etc.       │
│       //                                                                        │
│       // Sada this.basket ima:                                                  │
│       // - id: 257461 (DB ID)                                                   │
│       // - basketnum: "257459-01/26"                                            │
│       // - headbasketnum: "257459/26"                                           │
│       // - statusName: "U pripremi"                                             │
│       // - ... sve ostale vrijednosti                                           │
│                                                                                 │
│       this.saveSuicapture();  // ← Spremi stanje                                │
│     });                                                                         │
│ }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### REZULTAT: this.basket struktura

```javascript
this.basket = {
  // Od API response-a (nakon POST /uomback/basket/save)
  id: 257461,                          // Database ID
  basketnum: "257459-01/26",           // Broj korpe (human readable)
  headbasketnum: "257459/26",          // Glavni broj (za grupne zahtjeve)
  status: "05",                        // Status kod
  statusName: "U pripremi",            // Status naziv
  created: "2026-01-30T10:15:00.000",  // Datum kreiranja
  createdBy: "JSMITH",                 // Ko je kreirao

  // Od setBasket() (lokalni podaci)
  cacustomerId: 130025794,
  bacustomerId: 330021716,
  sacustomerId: 12345,
  acontactId: 45112814,
  ocontact1Id: 45112814,
  saleschanneltypeCode: "DIRECT",
  saleslocationId: 2,
  salesslocationId: 24,
  baskettypeCode: "NEW",
  description: "Opis zahtjeva",
  expecteddate: "2026-02-15",
  comments: "Komentar",
  refnumber: "REF-123",
  refdate: "2026-01-30",

  basketatts: [
    { attname: "PRODUCTOFFER_ID", attvalue: "1174" },
    { attname: "SPECIFICATION_ID", attvalue: "162" },
    { attname: "PROCESS_ID", attvalue: "10" },
    { attname: "TYPE", attvalue: "residential" },
    { attname: "REQUIRED", attvalue: "ca&r=ba" }
  ],

  // Pomoćni flag
  save: true                           // Označava da je basket spremljen
}
```

---

## 1️⃣6️⃣ this.hasitems

### Izvor: Boolean flag - postavlja se nakon spremanja stavki

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ INICIJALIZACIJA:                                                                │
│                                                                                 │
│ evidencija-usluge.component.ts linija 52:                                       │
│ public hasitems: boolean;  // undefined inicijalno                              │
│                                                                                 │
│ POSTAVLJANJE:                                                                   │
│                                                                                 │
│ handleFlow() linija 304-307:                                                    │
│ handleFlow(saved?: boolean) {                                                   │
│   if (saved || this.ordnum) {                                                   │
│     this.confing.steps[1]['disabled'] = false;  // Omogući sljedeći korak       │
│     this.hasitems = true;                       // ← Postavi na true            │
│   } else {                                                                      │
│     this.confing.steps[1]['disabled'] = true;   // Onemogući sljedeći korak     │
│   }                                                                             │
│ }                                                                               │
│                                                                                 │
│ POZIVA SE IZ:                                                                   │
│                                                                                 │
│ 1. saveItem() - nakon uspješnog spremanja stavki (linija 288)                   │
│    this.handleFlow(true);                                                       │
│                                                                                 │
│ 2. loadDynamicData() - učitano iz sačuvanog stanja (linija 142)                 │
│    Object.assign(this, JSON.parse(r.payload.structure));                        │
│    // this.hasitems = true/false iz prethodno sačuvanog stanja                  │
│                                                                                 │
│ SVRHA:                                                                          │
│ - Označava da li korpa ima stavke (items)                                       │
│ - Kontrolira da li je sljedeći korak (Pregled) omogućen                         │
│ - Sprema se u suicapture da se zna stanje pri povratku                          │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 1️⃣7️⃣ this.basket.basketnum (ordnum)

### Izvor: API Response nakon spremanja basket-a

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ GENERIRANJE:                                                                    │
│                                                                                 │
│ Backend generiše basketnum nakon POST /uomback/basket/save                      │
│                                                                                 │
│ FORMAT: "{sequence}-{sequence_item}/{year}"                                     │
│ Primjer: "257459-01/26"                                                         │
│          ↑       ↑   ↑                                                          │
│          │       │   └── Godina (26 = 2026)                                     │
│          │       └────── Redni broj stavke (01 = prva)                          │
│          └────────────── Glavni sequence broj                                   │
│                                                                                 │
│ POSTAVLJANJE U KOMPONENTI:                                                      │
│                                                                                 │
│ saveBasket() → API response → Object.assign(this.basket, r.payload)             │
│                               ↑                                                 │
│                    Response sadrži: { basketnum: "257459-01/26", ... }          │
│                                                                                 │
│ KORIŠTENJE U saveSuicapture():                                                  │
│                                                                                 │
│ saveSuicapture() {                                                              │
│   let jsonSetup = {                                                             │
│     ...                                                                         │
│     ordnum: this.basket.basketnum  // "257459-01/26"                            │
│   };                                                                            │
│ }                                                                               │
│                                                                                 │
│ ZAŠTO JE VAŽAN:                                                                 │
│ - Služi kao PRIMARY KEY za dohvatanje sačuvanog stanja                          │
│ - GET /uomback/suicapture/ordnum?ordnum=257459-01/26                            │
│ - Omogućava korisniku da se vrati na istu formu kasnije                         │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

# KOMPLETNI DIJAGRAM IZVORA PODATAKA

```
┌───────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────┐
│       PARAMETAR           │                                    IZVOR                                            │
├───────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
│                           │                                                                                     │
│ ┌─ entryParams ───────────┤                                                                                     │
│ │                         │                                                                                     │
│ │  processId              │  URL Query Param → route.queryParams → Object.assign(this, params)                  │
│ │  offerId                │  URL Route Param → route.params → Object.assign(this, params)                       │
│ │  specId                 │  URL Route Param → route.params → Object.assign(this, params)                       │
│ │  appProcessId           │  URL Query Param (opcionalno) → može biti undefined                                 │
│ │  orderEntrySetupRequests│  URL Query Param (opcionalno) → za grupne zahtjeve                                  │
│ │  productOfferId         │  URL Query Param (opcionalno) → duplikat offerId                                    │
│ │  productSpecificationId │  URL Query Param (opcionalno) → duplikat specId                                     │
│ │                         │                                                                                     │
│ └─────────────────────────┤                                                                                     │
│                           │                                                                                     │
│ ┌─ model ─────────────────┤                                                                                     │
│ │                         │                                                                                     │
│ │  db.model               │  Model Service ← Dinamička forma ← API /pcrt/order-entry ← Korisnikov unos          │
│ │  setOutput()            │  db.output transformiran handleOutput() → value → attvalue                          │
│ │                         │                                                                                     │
│ └─────────────────────────┤                                                                                     │
│                           │                                                                                     │
│ ┌─ structure ─────────────┤                                                                                     │
│ │                         │                                                                                     │
│ │  ca                     │  SharedDataService.customer.customerGeneralInfo ← API /ccm/customer/customerBlock-id│
│ │  ba                     │  SharedDataService.customer.customerBillInfo ← API /ccm/customer/customerBABlock-id │
│ │  sa                     │  SharedDataService.customer.saInfo ← API /ccm/customer/sa-general                   │
│ │  contact                │  Drag-and-drop od korisnika ili prazan { contact: true }                            │
│ │  ocontact               │  Drag-and-drop od korisnika ili prazan {}                                           │
│ │  basket                 │  setBasket() lokalno + API response POST /uomback/basket/save                       │
│ │  hasitems               │  Boolean flag, postavlja se u handleFlow() nakon spremanja stavki                   │
│ │                         │                                                                                     │
│ └─────────────────────────┤                                                                                     │
│                           │                                                                                     │
│  ordnum                   │  this.basket.basketnum ← API response POST /uomback/basket/save                     │
│                           │                                                                                     │
└───────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────┘
```

---

# HTTP WRAPPER

## RestApiService.setEntity()

```typescript
// rest.api.service.ts linija 106-108

private setEntity(data: any) {
  return {
    languageId: 0,     // Hardkodirano
    channel: '',       // Hardkodirano prazno
    entity: data       // ← Tvoji podaci idu ovdje
  };
}
```

## Finalna struktura HTTP requesta

```
POST /uomback/suicapture HTTP/1.1
Content-Type: application/json

{
  "languageId": 0,                                    ← Dodao setEntity()
  "channel": "",                                      ← Dodao setEntity()
  "entity": {                                         ← Tvoj jsonSetup
    "entryParams": "{...}",                           ← String
    "model": "{...}",                                 ← String
    "structure": "{...}",                             ← String
    "ordnum": "257459-01/26"                          ← String
  }
}
```

---

# UČITAVANJE SAČUVANOG STANJA

## loadDynamicData()

```typescript
loadDynamicData() {
  this.api.get('/uomback/suicapture/ordnum', { ordnum: this.basketnum })
    .subscribe((r: RestPayload) => {

      if (!r.payload) return this.getDynamic();

      // KORAK 1: Vrati stanje forme (model i output)
      Object.assign(this.db, JSON.parse(r.payload.model));

      // KORAK 2: Vrati entry parametre
      Object.assign(this, JSON.parse(r.payload.entryParams));

      // KORAK 3: Vrati kontekst korisnika/računa
      Object.assign(this, JSON.parse(r.payload.structure));

      // KORAK 4: Sinhronizuj sa SharedDataService
      Object.assign(this.sharedData.customer.customerGeneralInfo, this.ca);
      Object.assign(this.sharedData.customer.customerBillInfo, this.ba);

      // KORAK 5: Učitaj dinamičku strukturu forme
      this.getDynamic();
      this.handleFlow(this.hasitems);
    });
}
```

---

# STVARNI API PRIMJERI

## A. POST /uomback/basket/save

### Request

```json
{
  "languageId": 0,
  "channel": "",
  "entity": {
    "id": null,
    "acontactId": 45112814,
    "bacustomerId": 330021716,
    "cacustomerId": 130025794,
    "sacustomerId": 515653794,
    "ocontact1Id": 45112814,
    "saleschanneltypeCode": "BACK",
    "saleslocationId": 2,
    "salesslocationId": 24,
    "basketatts": [
      { "attname": "PRODUCTOFFER_ID", "attvalue": "1174" },
      { "attname": "SPECIFICATION_ID", "attvalue": "162" },
      { "attname": "PROCESS_ID", "attvalue": "10" },
      { "attname": "TYPE", "attvalue": "residential" },
      { "attname": "REQUIRED", "attvalue": "ca&r=ba" },
      { "attname": "PROCESS_GROUP_CODE", "attvalue": "RESIDENTIAL_SALES" }
    ]
  }
}
```

### Objašnjenje Request parametara

| Parametar | Vrijednost | Izvor | Opis |
|-----------|------------|-------|------|
| `languageId` | `0` | RestApiService.setEntity() | Hardkodirano |
| `channel` | `""` | RestApiService.setEntity() | Hardkodirano prazno |
| `id` | `null` | this.basket.id | Null za novi zahtjev |
| `acontactId` | `45112814` | this.contact.id | ID kontakt osobe (drag-drop) |
| `bacustomerId` | `330021716` | this.ba.id | Billing Account ID |
| `cacustomerId` | `130025794` | this.ca.id | Customer Account ID |
| `sacustomerId` | `515653794` | this.sa.id | Service Account ID |
| `ocontact1Id` | `45112814` | this.ocontact.id \|\| this.contact.id | Drugi kontakt |
| `saleschanneltypeCode` | `"BACK"` | UserService.getChannel() | Kanal prodaje |
| `saleslocationId` | `2` | UserService.getSalesLocationId() | Direkcija Sarajevo |
| `salesslocationId` | `24` | UserService.getSubSalesLocationId() | Šalter-Dolac Malta |

### basketatts - Metapodaci zahtjeva

```
┌────────────────────────┬─────────────────────┬─────────────────────────────────────┐
│ attname                │ attvalue            │ Izvor                               │
├────────────────────────┼─────────────────────┼─────────────────────────────────────┤
│ PRODUCTOFFER_ID        │ "1174"              │ this.offerId (URL route param)      │
│ SPECIFICATION_ID       │ "162"               │ this.specId (URL route param)       │
│ PROCESS_ID             │ "10"                │ this.processId (URL query param)    │
│ TYPE                   │ "residential"       │ this.type (URL route param)         │
│ REQUIRED               │ "ca&r=ba"           │ this.r.join('&r=') (URL query param)│
│ PROCESS_GROUP_CODE     │ "RESIDENTIAL_SALES" │ this.processGroupCode (URL query)   │
└────────────────────────┴─────────────────────┴─────────────────────────────────────┘
```

### Response

```json
{
  "transactionId": "9408a14d-2edd-425c-bb70-3413fcaa32ad",
  "className": "ba.com.zira.commons.message.response.PayloadResponse",
  "responseCode": 0,
  "responseDetail": "OK",
  "payload": {
    "id": 257473,
    "basketnum": "257471-01/26",
    "baskettypeCode": "SALES",
    "created": "2026-01-30T13:53:11.463",
    "createdBy": "kenansa",
    "headbasketnum": "257471/26",
    "orderdate": "2026-01-30T13:53:11.463",
    "status": "0",
    "statusName": "U pripremi",
    "basketTypeName": "SALES"
  },
  "successful": true
}
```

### Objašnjenje Response payload-a

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ RESPONSE PAYLOAD DETALJI                                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ id: 257473                                                                      │
│ └── Database ID (primarni ključ u tabeli BASKET)                                │
│                                                                                 │
│ basketnum: "257471-01/26"                                                       │
│ └── Human-readable broj korpe                                                   │
│     Format: {sequence}-{item_number}/{year}                                     │
│     257471 = glavni sequence                                                    │
│     01 = prva stavka                                                            │
│     26 = godina 2026                                                            │
│                                                                                 │
│ headbasketnum: "257471/26"                                                      │
│ └── Glavni broj (parent) za grupne zahtjeve                                     │
│     Ako je grupni zahtjev: 257471/26 → 257471-01/26, 257471-02/26, etc.         │
│                                                                                 │
│ baskettypeCode: "SALES"                                                         │
│ └── Tip korpe (SALES = prodaja, MIGRATION = migracija, etc.)                    │
│                                                                                 │
│ status: "0"                                                                     │
│ └── Status kod                                                                  │
│                                                                                 │
│ statusName: "U pripremi"                                                        │
│ └── Human-readable status                                                       │
│     Workflow: U pripremi → Validacija → Realizacija → Završeno                  │
│                                                                                 │
│ created: "2026-01-30T13:53:11.463"                                              │
│ └── Timestamp kreiranja                                                         │
│                                                                                 │
│ createdBy: "kenansa"                                                            │
│ └── Username koji je kreirao zahtjev                                            │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## B. GET /uomback/suicapture/ordnum

### Request

```
GET /uomback/suicapture/ordnum?ordnum=257471-01/26
```

### Response

```json
{
  "transactionId": "352e163b-a2b2-40c5-a95c-1a6c08016710",
  "className": "ba.com.zira.commons.message.response.PayloadResponse",
  "responseCode": 0,
  "responseDetail": "OK",
  "payload": {
    "id": 53045,
    "ordnum": "257471-01/26",
    "created": "2026-01-30T13:53:11.000",
    "createdBy": "kenansa",
    "entryParams": "{\"processId\":\"10\",\"offerId\":\"1174\",\"specId\":\"162\"}",
    "model": "{\"model\":{\"auto\":{...}, ...}, \"output\":{...}}",
    "structure": "{\"ca\":{...}, \"ba\":{...}, \"sa\":{...}, \"contact\":{...}, \"basket\":{...}, \"hasitems\":true}"
  },
  "successful": true
}
```

### Dekodirana struktura payload.entryParams

```json
{
  "processId": "10",
  "offerId": "1174",
  "specId": "162"
}
```

### Korištenje u loadDynamicData()

```typescript
// evidencija-usluge.component.ts
loadDynamicData() {
  this.api.get('/uomback/suicapture/ordnum', { ordnum: this.basketnum })
    .subscribe((r: RestPayload) => {

      // 1. Vrati entry parametre
      Object.assign(this, JSON.parse(r.payload.entryParams));
      // Rezultat: this.processId = "10", this.offerId = "1174", this.specId = "162"

      // 2. Vrati model i output
      Object.assign(this.db, JSON.parse(r.payload.model));
      // Rezultat: this.db.model = {...}, this.db.output = {...}

      // 3. Vrati structure (ca, ba, sa, contact, basket, hasitems)
      Object.assign(this, JSON.parse(r.payload.structure));
      // Rezultat: this.ca = {...}, this.ba = {...}, etc.

      // 4. Sinhronizuj SharedDataService
      Object.assign(this.sharedData.customer.customerGeneralInfo, this.ca);
      Object.assign(this.sharedData.customer.customerBillInfo, this.ba);
    });
}
```

---

## C. GET /pcrt/order-entry

### Request

```
GET /pcrt/order-entry?interactionId=16&productOfferId=1174&productSpecificationId=162&appProcessId=10&setupType=SALES
```

### Response (strukturirana)

```json
{
  "transactionId": "22da54a0-0955-4296-8f05-16d623b0f538",
  "className": "ba.com.zira.commons.message.response.PayloadResponse",
  "responseCode": 0,
  "responseDetail": "OK",
  "payload": {
    "structure": [
      {
        "label": "Osnovne usluge",
        "code": "162",
        "name": "Osnovneusluge",
        "dname": "Osnovneusluge1174",
        "template": "default_block",
        "businessClassification": "SPECIFICATION",
        "visible": true,
        "disabled": false,
        "parameters": {
          "P_PARENT_OFFER_ID": "1174",
          "P_OFFER_ID": "1174",
          "P_MAIN_OFFER_ID": "1174",
          "P_SPECIFICATION_ID": "162",
          "P_PARENT_SPECIFICATION_ID": "162",
          "PROCESS_ID": "10",
          "TYPE": "SALES",
          "IMPLEMENTATION_CODE": "CHOOSE_DEFINE"
        },
        "actions": [
          {
            "label": "",
            "code": "loadOffer162",
            "name": "loadOffer162",
            "template": "select",
            "elementType": "loadElements",
            "disabled": true,
            "visible": true,
            "attributes": {
              "class": "z-col-24 nopadding",
              "MANUAL_OFFER_SELECTION": "true"
            },
            "value": {
              "defaultValue": "1174",
              "data": [
                {
                  "id": null,
                  "value": "1174",
                  "name": "Osnovni paket- Fizicka"
                }
              ]
            }
          }
        ],
        "elements": [
          {
            "label": "Osnovni paket- Fizicka",
            "code": "1174",
            "name": "Osnovnipaket-Fizicka",
            "dname": "OsnovnipaketFizicka1174",
            "template": "basic_block",
            "businessClassification": "OFFER",
            "displayName": "Osnovni paket- Fizicka",
            "active": false,
            "visible": true,
            "disabled": false,
            "export": true,
            "icon": "fa fa-wrench wrench",
            "validFrom": "01-01-2007",
            "businessParams": {
              "ACTION_CODE": "NewPOTS"
            },
            "parameters": {
              "P_OFFER_ID": "1174",
              "ACTION_CODE": "NewPOTS",
              "P_MAIN_OFFER_ID": "1174",
              "P_MAIN_OFFER_CODE": "100001",
              "P_OFFER_CODE": "100001",
              "P_PARENT_OFFER_ID": "1174",
              "P_PARENT_OFFER_CODE": "100001",
              "P_SPECIFICATION_ID": "162",
              "P_PARENT_SPECIFICATION_ID": "162",
              "P_CLASS_CODE": "ANALOG",
              "PROCESS_ID": "10",
              "TYPE": "SALES",
              "TEMPLATE_ID": "767",
              "IMPLEMENTATION_CODE": "CHOOSE_DEFINE"
            },
            "dependency": [
              {
                "element": "loadOffer162",
                "effect": "active",
                "elementValue": ["1174"]
              }
            ],
            "inputs": [
              {
                "label": "Ime",
                "code": "FIRSTNAME",
                "name": "FIRSTNAME",
                "dname": "FIRSTNAME_1174"
              },
              {
                "label": "Prezime/Naziv",
                "code": "NAME",
                "name": "NAME",
                "dname": "NAME_1174"
              },
              {
                "label": "Funkcija",
                "code": "JOBTITLE",
                "name": "JOBTITLE",
                "dname": "JOBTITLE_1174"
              },
              {
                "label": "Na lokaciji",
                "code": "PRIKLJUCAK_ADSL",
                "name": "PRIKLJUCAK_ADSL",
                "dname": "PRIKLJUCAK_ADSL_1174"
              },
              {
                "label": "Da li ju u akciji",
                "code": "ACTION_PNK",
                "name": "ACTION_PNK",
                "dname": "ACTION_PNK_1174"
              },
              {
                "label": "Grupa podtipova",
                "code": "FRSEGSCLASS_CODE",
                "name": "FRSEGSCLASS_CODE"
              },
              {
                "label": "Trenutni email",
                "code": "PUSER_EMAIL",
                "name": "PUSER_EMAIL",
                "dname": "PUSER_EMAIL_1174"
              },
              {
                "label": "Kontakt telefon",
                "code": "DEFAULTCONTACTPHONE",
                "name": "DEFAULTCONTACTPHONE"
              },
              {
                "label": "Naziv paketa",
                "code": "OFFER_NAME",
                "name": "OFFER_NAME",
                "dname": "OFFER_NAME_1174"
              },
              {
                "label": "Email",
                "code": "DEFAULTCONTACTEMAIL",
                "name": "DEFAULTCONTACTEMAIL"
              },
              {
                "label": "Kolicina",
                "code": "PQUANTITY_NUM",
                "name": "PQUANTITY_NUM",
                "dname": "PQUANTITY_NUM_1174"
              },
              {
                "label": "Indikator",
                "code": "CCC_IND",
                "name": "CCC_IND",
                "dname": "CCC_IND_1174"
              }
            ],
            "messages": [
              {
                "label": "Info poruka",
                "code": "SERVICE_INFO",
                "name": "SERVICE_INFO",
                "dname": "SERVICE_INFO_1174"
              }
            ],
            "children": [
              {
                "label": "Dodavanje pratioca u nebrojčanu seriju",
                "code": "960"
              },
              {
                "label": "Tarifni paketi",
                "code": "178",
                "name": "Tarifnipaketi",
                "dname": "Tarifnipaketi11741174"
              },
              {
                "label": "Zabrana informacija",
                "code": "742",
                "name": "Zabranainformacija"
              },
              {
                "label": "Detaljni ispis poziva, redovno",
                "code": "165",
                "name": "Detaljniispispoziva,redovno"
              },
              {
                "label": "Preuzimanja",
                "code": "164",
                "name": "Preuzimanja",
                "dname": "Preuzimanja11741174",
                "visible": true
              },
              {
                "label": "Specifikacija za Prodaju van poslovnih prostorija - FIKSNA",
                "code": "1704"
              },
              {
                "label": "Fiksna - ugovorni odnos",
                "code": "2016",
                "name": "Fiksnaugovorniodnos"
              },
              {
                "label": "Specifikacija za Net VAS i zabrane poziva - POTS- Automatska realizacija",
                "code": "3069"
              },
              {
                "label": "Specifikacija za Net VAS i zabrane poziva - POTS - Radni nalog",
                "code": "721"
              }
            ]
          }
        ]
      }
    ],
    "parameters": {
      "type": 100
    },
    "validation": []
  },
  "successful": true
}
```

### Hijerarhija strukture forme

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        HIJERARHIJA DINAMIČKE FORME                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ payload.structure[0] ─── SPECIFICATION (code: "162")                            │
│ │                        "Osnovne usluge"                                       │
│ │                        template: "default_block"                              │
│ │                        businessClassification: "SPECIFICATION"                │
│ │                                                                               │
│ ├── actions[0] ───────── loadOffer162 (dropdown za izbor ponude)                │
│ │                        template: "select"                                     │
│ │                        elementType: "loadElements"                            │
│ │                        value.data: [{ value: "1174", name: "Osnovni paket" }] │
│ │                                                                               │
│ └── elements[0] ──────── OFFER (code: "1174")                                   │
│     │                    "Osnovni paket- Fizicka"                               │
│     │                    template: "basic_block"                                │
│     │                    businessClassification: "OFFER"                        │
│     │                    dependency: aktivira se kad loadOffer162 = "1174"      │
│     │                                                                           │
│     ├── inputs[] ─────── ATTRIBUTES (polja forme)                               │
│     │   ├── FIRSTNAME         (Ime)                                             │
│     │   ├── NAME              (Prezime/Naziv)                                   │
│     │   ├── JOBTITLE          (Funkcija)                                        │
│     │   ├── PRIKLJUCAK_ADSL   (Na lokaciji)                                     │
│     │   ├── ACTION_PNK        (Da li je u akciji)                               │
│     │   ├── FRSEGSCLASS_CODE  (Grupa podtipova)                                 │
│     │   ├── PUSER_EMAIL       (Trenutni email)                                  │
│     │   ├── DEFAULTCONTACTPHONE (Kontakt telefon)                               │
│     │   ├── OFFER_NAME        (Naziv paketa)                                    │
│     │   ├── DEFAULTCONTACTEMAIL (Email)                                         │
│     │   ├── PQUANTITY_NUM     (Količina)                                        │
│     │   └── CCC_IND           (Indikator)                                       │
│     │                                                                           │
│     ├── messages[] ───── Poruke (validacija, info)                              │
│     │   └── SERVICE_INFO      (Info poruka)                                     │
│     │                                                                           │
│     └── children[] ───── CHILD SPECIFICATIONS (dodatne opcije)                  │
│         ├── 960  - Dodavanje pratioca u nebrojčanu seriju                       │
│         ├── 178  - Tarifni paketi                                               │
│         ├── 742  - Zabrana informacija                                          │
│         ├── 165  - Detaljni ispis poziva, redovno                               │
│         ├── 164  - Preuzimanja                                                  │
│         ├── 1704 - Specifikacija za Prodaju van poslovnih prostorija            │
│         ├── 2016 - Fiksna - ugovorni odnos                                      │
│         ├── 3069 - Net VAS - Automatska realizacija                             │
│         └── 721  - Net VAS - Radni nalog                                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Kako se struktura renderira u Angular komponente

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    MAPPING: JSON → ANGULAR COMPONENTS                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ JSON template           →    Angular Component                                  │
│ ─────────────────────────────────────────────────────────                       │
│ "default_block"         →    <z-default-block>                                  │
│ "basic_block"           →    <z-basic-block>                                    │
│ "select"                →    <z-dropdown>                                       │
│ "input"                 →    <z-input>                                          │
│ "checkbox"              →    <z-checkbox>                                       │
│ "datepicker"            →    <z-datepicker>                                     │
│ "autocomplete"          →    <z-autocomplete>                                   │
│ "multiple"              →    <z-multiselect>                                    │
│ "radio"                 →    <z-radio>                                          │
│ "BoxOptions"            →    <z-box-options>                                    │
│                                                                                 │
│ businessClassification  →    Kako se tretira u output strukturi                 │
│ ─────────────────────────────────────────────────────────                       │
│ "SPECIFICATION"         →    output[name] sa .spec child                        │
│ "OFFER"                 →    output[name] sa .items child                       │
│ "Attribute"             →    output[name] sa .value                             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Dependency sistem

```typescript
// Primjer iz response-a:
"dependency": [
  {
    "element": "loadOffer162",    // Prati ovaj element
    "effect": "active",           // Efekt: aktiviraj/deaktiviraj
    "elementValue": ["1174"]      // Kada je vrijednost "1174"
  }
]

// Logika u DependencyService:
// Kada korisnik odabere "1174" u loadOffer162 dropdown-u,
// element "Osnovni paket- Fizicka" postaje active: true
// i prikazuje se u formi
```

---

## D. Kompletan tok jednog zahtjeva

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           SEKVENCIJALNI DIJAGRAM                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│ 1. KORISNIK OTVARA URL:                                                         │
│    /evidencija/residential/1174/162/0?processId=10&caId=130025794&baId=...      │
│                                                                                 │
│ 2. VpnEvidencijaUslugeComponent.ngOnInit()                                      │
│    ├── Čita route params: offerId=1174, specId=162                              │
│    ├── Čita query params: processId=10, caId, baId                              │
│    └── Poziva loadDynamicData()                                                 │
│                                                                                 │
│ 3. loadDynamicData() → GET /uomback/suicapture/ordnum                           │
│    ├── Ako postoji sačuvano stanje → učitaj ga                                  │
│    └── Ako ne postoji → getDynamic()                                            │
│                                                                                 │
│ 4. getDynamic() → GET /pcrt/order-entry                                         │
│    Request: productOfferId=1174, productSpecificationId=162, appProcessId=10    │
│    Response: { structure: [...], parameters: {...} }                            │
│                                                                                 │
│ 5. Angular renderira formu                                                      │
│    ├── Za svaki element → ContentLoaderComponent                                │
│    ├── ValueManager.set() postavlja početne vrijednosti u db.model              │
│    └── db.setoutput() gradi output strukturu                                    │
│                                                                                 │
│ 6. KORISNIK POPUNJAVA FORMU                                                     │
│    ├── [(ngModel)] binding ažurira db.model                                     │
│    └── Svaka promjena → saveSuicapture() (auto-save)                            │
│                                                                                 │
│ 7. KORISNIK KLIKNE "SPREMI"                                                     │
│    ├── saveBasket() → POST /uomback/basket/save                                 │
│    │   Request: { entity: { cacustomerId, bacustomerId, basketatts: [...] } }   │
│    │   Response: { payload: { id: 257473, basketnum: "257471-01/26" } }         │
│    │                                                                            │
│    ├── Object.assign(this.basket, response.payload)                             │
│    │                                                                            │
│    └── saveSuicapture() → POST /uomback/suicapture                              │
│        Request: {                                                               │
│          entryParams: "{processId, offerId, specId}",                           │
│          model: "{model, output}",                                              │
│          structure: "{ca, ba, sa, contact, basket, hasitems}",                  │
│          ordnum: "257471-01/26"                                                 │
│        }                                                                        │
│                                                                                 │
│ 8. KORISNIK SE VRAĆA KASNIJE                                                    │
│    ├── Otvara isti URL ili koristi basketnum                                    │
│    ├── loadDynamicData() → GET /uomback/suicapture/ordnum?ordnum=257471-01/26   │
│    └── Svo stanje se restaurira iz sačuvanih JSON stringova                     │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

---

# DODATAK: Od URL-a do Komponente - Detaljna Analiza

## A1. Pronalaženje Komponente na Osnovu URL-a

### A1.1 Primjer URL-a

```
https://springtest.telecom.ba/uom/evidencija/residential/1174/162/0?processGroupCode=RESIDENTIAL_SALES&r=ca&r=ba&orderTypeName=Osnovne%20usluge&caId=130025794&baId=330021716&processId=10&from=VPN&code=162
```

### A1.2 Korak po Korak

**Korak 1:** Izvuci PATH iz URL-a (ignoriši domenu i query parametre)
```
evidencija/residential/1174/162/0
```

**Korak 2:** Otvori `src/app/app.routes.ts`:

```typescript
const appRoutes: Routes = [
  { path: 'sales/:type', component: SalesComponent },
  { path: 'evidencija/:type/:offerId/:specId/:activeIndex', component: FlowComponent },  // ← OVO
  { path: 'evidencija/:type/:offerId/:specId/:activeIndex/basket/load', component: FlowComponent },
  { path: 'presales/:type/:offerId/:specId/:activeIndex', component: PresalesComponent },
];
```

**Korak 3:** Matchuj URL sa route pattern-om:

| URL dio | Route dio | Vrijednost |
|---------|-----------|------------|
| `evidencija` | `evidencija` | fiksno (mora se poklopiti) |
| `residential` | `:type` | varijabla = "residential" |
| `1174` | `:offerId` | varijabla = "1174" |
| `162` | `:specId` | varijabla = "162" |
| `0` | `:activeIndex` | varijabla = "0" |

**Korak 4:** Pročitaj komponentu iz importa:

```typescript
import { FlowComponent } from './pages/z-workflow/pages/flow/flow.component';
```

**Rezultat:** `src/app/pages/z-workflow/pages/flow/flow.component.ts`

---

## A2. Lanac Komponenti - Detaljna Analiza

```
URL: /uom/evidencija/residential/1174/162/0
                    │
            ┌───────▼───────┐
            │ FlowComponent │
            │ (kontejner)   │  Lokacija: src/app/pages/z-workflow/pages/flow/flow.component.ts
            └───────┬───────┘  Učitava: workflow.json konfiguraciju
                    │
            ┌───────▼───────┐
            │ <z-flow-tabs> │
            │               │  Lokacija: src/app/pages/z-workflow/workflow.component.ts
            └───────┬───────┘  Prikazuje: tabove (Evidencija → Pregled → Provjera → ...)
                    │
            ┌───────▼───────┐
            │ <lfs-wrapper> │
            │ type="..."    │  Lokacija: src/app/pages/z-workflow/load.flow.sub.component.ts
            └───────┬───────┘  Dinamički učitava: komponente po nazivu iz mape
                    │
            ┌───────▼────────┐
            │ <z-pageloader> │
            │                │  Lokacija: src/app/z-dynamic/components/z-dynamicloader/z-pageloader/
            └───────┬────────┘  Iterira: kroz JSON strukturu i renderuje elemente
                    │
            ┌───────▼──────────┐
            │ <z-contentloader>│
            │                  │  Lokacija: src/app/z-dynamic/components/z-dynamicloader/z-contentloader/
            └──────────────────┘  Popunjava: db.model i db.output za svaki element
```

---

## A3. Dinamičko Učitavanje Komponenti (lfs-wrapper)

### A3.1 Mapa Komponenti

Fajl: `src/app/pages/z-workflow/flowtab.module.ts`

```typescript
export const components = {
  VpnEvidencijaUslugeComponent: VpnEvidencijaUslugeComponent,
  PageLoaderComponent: PageLoaderComponent,
  OrderOverviewComponent: OrderOverviewComponent,
  ContractComponent: ContractComponent,
  VpnAnexComponent: AnexComponent,
  AutomaticRealizationComponent: AutomaticRealizationComponent,
  ValidationComponent: ValidationComponent,
  TechnicalPossibilityComponent: TechnicalPossibilityComponent,
  WorkOrderComponent: WorkOrderComponent,
  DispatchNoteComponent: DispatchNoteComponent,
  QuoteComponent: QuoteComponent,
  QuoteComponentAsmbl: QuoteComponentAsmbl,
  // ... ostale komponente
};
```

### A3.2 Kako lfs-wrapper Radi

Fajl: `src/app/pages/z-workflow/load.flow.sub.component.ts`

```typescript
@Component({
  selector: 'lfs-wrapper',
  template: '<div #target></div>'
})
export class LFS {
  @Input() type: string;  // Ime komponente, npr. "VpnEvidencijaUslugeComponent"

  updateComponent() {
    // 1. Pronađi komponentu po imenu u mapi
    let factory = this.componentFactoryResolver.resolveComponentFactory(
        components[this.type]   // components["VpnEvidencijaUslugeComponent"]
    );

    // 2. Kreiraj instancu komponente
    this.cmpRef = this.target.createComponent(factory);

    // 3. Proslijedi podatke
    this.cmpRef.instance['confing'] = this.confing;
    this.cmpRef.instance['output'] = this.output;
    this.cmpRef.instance['items'] = this.items;
  }
}
```

### A3.3 Vizuelni Prikaz

```
workflow.json definira:                    Template proslijedi:
─────────────────────                      ────────────────────
{                                          <lfs-wrapper
  "component": "VpnEvidencijaUslugeComponent"   [type]="confing.selected.component"
}                                          ></lfs-wrapper>
      │                                           │
      │         type = "VpnEvidencijaUslugeComponent"
      │                        │
      └────────────────────────┼────────────────────────────────┐
                               ▼                                │
          ┌─────────────────────────────────────────────────┐   │
          │              components (mapa)                  │   │
          ├─────────────────────────────────────────────────┤   │
          │ "VpnEvidencijaUslugeComponent" → Klasa          │ ◄─┘
          │ "QuoteComponent"               → Klasa          │
          │ "ContractComponent"            → Klasa          │
          └─────────────────────────────────────────────────┘
                               │
                               ▼
              Kreira se VpnEvidencijaUslugeComponent
              i renderuje u <div #target></div>
```

---

## A4. JSON Struktura iz /pcrt/order-entry

### A4.1 Hijerarhija Elemenata

```
payload
├── parameters: { type: 100 }
├── structure: [...]              ← Definicija forme
│   └── [0]: "Osnovne usluge" (default_block, code: "162")
│       └── elements[0]: "Osnovni paket- Fizicka" (basic_block, code: "1174")
│           ├── inputs[]: ← INPUT POLJA (ono što korisnik popunjava)
│           │   ├── [0] FIRSTNAME (Ime) - template: "input", elementType: "text"
│           │   ├── [1] NAME (Prezime/Naziv) - validation: {mandatory: true}
│           │   ├── [2] JOBTITLE (Funkcija)
│           │   ├── [3] PRIKLJUCAK_ADSL (Na lokaciji)
│           │   ├── [4] ACTION_PNK (Da li je u akciji)
│           │   └── ... još polja
│           ├── children[]: ← CHILD SPECIFIKACIJE (dodatne opcije)
│           │   ├── [0] "Dodavanje pratioca u nebrojčanu seriju" (code: 960)
│           │   ├── [1] "Tarifni paketi" (code: 178)
│           │   ├── [2] "Zabrana informacija" (code: 742)
│           │   └── ... još children
│           └── messages[]: ← NOTIFIKACIJE
│               └── [0] SERVICE_INFO
└── validation: []
```

### A4.2 Primjer Input Polja

```javascript
{
  name: "FIRSTNAME",           // Ime u db.model
  label: "Ime",                // Prikaz na ekranu
  code: "FIRSTNAME",
  dname: "FIRSTNAME_1174",     // Jedinstveni identifikator
  template: "input",           // Tip komponente
  elementType: "text",         // Tip podatka
  businessClassification: "Attribute",
  dataReference: "ATTRIBUTE",
  export: true,                // Da li se sprema
  visible: true,               // Da li je vidljivo
  disabled: false,

  attributes: {
    class: "z-col-8"           // CSS klasa (širina 8/24 = 1/3 ekrana)
  },

  value: {
    data: [],
    autoincrement: null,
    // SQL koji dohvata početnu vrijednost iz baze
    generationFormula: "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual"
  },

  validation: {},              // Pravila validacije (prazno = nije obavezno)
  tooltip: "Ime (FIRSTNAME)"
}
```

### A4.3 Polje sa Obaveznom Validacijom

```javascript
{
  name: "NAME",
  label: "Prezime/Naziv",
  template: "input",
  elementType: "text",
  visible: true,

  validation: {
    mandatory: true            // ← OVO POLJE JE OBAVEZNO!
  },

  value: {
    generationFormula: "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'LASTNAME') from dual"
  }
}
```

### A4.4 Ključna Polja u JSON Strukturi

| Polje | Značenje |
|-------|----------|
| `name` | Ime polja (koristi se u db.model) |
| `label` | Prikaz za korisnika |
| `template` | Tip komponente (input, select, radio, AutoComplete, BoxOptions, basic_block, default_block, navigator...) |
| `elementType` | Tip podatka (text, number, date...) |
| `businessClassification` | "Attribute", "Item", "Block", "SPECIFICATION", "OFFER" |
| `elements` | Ugniježđeni elementi (za blokove) |
| `inputs` | Input polja unutar bloka |
| `children` | Child specifikacije |
| `externalAPI` | API za dropdown/autocomplete opcije |
| `mappingRef` | Odakle uzeti početnu vrijednost |
| `value.defaultValue` | Default vrijednost |
| `value.lookupStatement` | SQL za dohvat vrijednosti |
| `value.generationFormula` | Formula za generiranje početne vrijednosti |
| `validation.mandatory` | Da li je polje obavezno |
| `visible` | Da li je element vidljiv |
| `disabled` | Da li je element onemogućen za editovanje |
| `attributes.class` | CSS klasa (z-col-8 = 1/3 širine, z-col-12 = 1/2, z-col-24 = puna širina) |

---

## A5. Kako generationFormula Postavlja Početnu Vrijednost

### A5.1 Primjer

```javascript
value: {
  generationFormula: "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual"
}
```

### A5.2 Tok Izvršavanja

```
1. Forma se učitava
         │
         ▼
2. ContentLoaderComponent poziva ValueManager.set()
         │
         ▼
3. ValueManager prepoznaje generationFormula
         │
         ▼
4. Zamjena parametara:
   #:P_CLASS_CODE# → "ANALOG"
   #:P_CA_ID#      → 130025794
         │
         ▼
5. SQL poziv na backend:
   select uomcommon.fgetFirstLastname('ANALOG', 130025794, 'FIRSTNAME') from dual
         │
         ▼
6. Backend vraća: "JNF-8241"
         │
         ▼
7. Vrijednost se postavlja:
   db.model.FIRSTNAME = "JNF-8241"
         │
         ▼
8. Input polje prikazuje "JNF-8241"
```

---

## A6. Vizuelni Prikaz: JSON → Ekran

```
JSON                                         Ekran
────                                         ─────

structure[0]                                ┌─────────────────────────────────┐
  label: "Osnovne usluge"           ───►    │ ══ OSNOVNE USLUGE ══            │
  template: "default_block"                 │                                 │
                                            │  ┌─────────────────────────┐    │
  elements[0]                               │  │ Osnovni paket- Fizicka │    │
    label: "Osnovni paket- Fizicka" ───►    │  └─────────────────────────┘    │
    template: "basic_block"                 │                                 │
                                            │  ┌────────┐ ┌────────┐ ┌──────┐│
    inputs[0]: FIRSTNAME            ───►    │  │ Ime    │ │Prezime │ │Funkc.││
      class: "z-col-8"                      │  │[_____] │ │[_____]*│ │[___] ││
                                            │  └────────┘ └────────┘ └──────┘│
    inputs[1]: NAME                 ───►    │       ↑          ↑         ↑   │
      class: "z-col-8"                      │    z-col-8    z-col-8   z-col-8│
      validation: {mandatory: true}         │    (1/3)      (1/3)*    (1/3)  │
                                            │              *=obavezno        │
    inputs[2]: JOBTITLE             ───►    │                                 │
      class: "z-col-8"                      │  ┌─────────────────────────────┐│
                                            │  │ □ Tarifni paketi            ││
    children[1]: "Tarifni paketi"   ───►    │  │ □ Zabrana informacija       ││
    children[2]: "Zabrana info..."  ───►    │  │ □ Detaljni ispis poziva     ││
                                            │  └─────────────────────────────┘│
                                            └─────────────────────────────────┘
```

---

## A7. Kako se Mapira na db.model

### A7.1 Kada Korisnik Popuni Formu

```javascript
// JSON definicija                    // db.model rezultat
// ─────────────────                  // ─────────────────

{ name: "FIRSTNAME", ... }     →      db.model.FIRSTNAME = "Kenan"
{ name: "NAME", ... }          →      db.model.NAME = "Salkić"
{ name: "JOBTITLE", ... }      →      db.model.JOBTITLE = "Developer"
{ name: "PRIKLJUCAK_ADSL" }    →      db.model.PRIKLJUCAK_ADSL = "DA"
{ name: "ACTION_PNK" }         →      db.model.ACTION_PNK = "NE"
```

### A7.2 Kompletna db.model Struktura

```javascript
db.model = {
  auto: {},                    // Automatski generirane vrijednosti
  FIRSTNAME: "Kenan",
  NAME: "Salkić",
  JOBTITLE: "Developer",
  PRIKLJUCAK_ADSL: "DA",
  ACTION_PNK: "NE",
  FRSEGSCLASS_CODE: "100",
  PUSER_EMAIL: "kenan@test.com",
  // ... ostala polja iz forme
}
```

---

## A8. Ključni Fajlovi - Referenca

| Fajl | Svrha |
|------|-------|
| `src/app/app.routes.ts` | Routing - mapiranje URL-a na komponente |
| `src/app/pages/z-workflow/pages/flow/flow.component.ts` | Glavni kontejner za workflow |
| `src/app/pages/z-workflow/workflow.component.ts` | z-flow-tabs komponenta (tabovi) |
| `src/app/pages/z-workflow/load.flow.sub.component.ts` | lfs-wrapper - dinamičko učitavanje |
| `src/app/pages/z-workflow/flowtab.module.ts` | Mapa svih dostupnih komponenti |
| `src/app/pages/z-workflow/pages/basic-services/evidencija-usluge.component.ts` | Evidencija komponenta |
| `src/app/z-dynamic/services/model.service.ts` | Model servis (db.model, db.output) |
| `src/app/z-dynamic/services/value.manager.ts` | ValueManager - postavlja početne vrijednosti |
| `src/app/z-dynamic/components/z-dynamicloader/z-pageloader/pageloader.component.ts` | Iterira kroz JSON i renderuje elemente |
| `src/app/z-dynamic/components/z-dynamicloader/z-contentloader/contentloader.component.ts` | Popunjava db.model i db.output |
| `src/assets/workflow/workflow.json` | Konfiguracija workflow koraka (tabova) |

---

## A9. Kako Vidjeti db.model i db.output u Browseru

### Metoda 1: Console

```javascript
// Pronađi Angular element
var el = document.querySelector('z-contentloader');
var component = ng.getComponent(el);

// Pristup db
console.log('db.model:', component.db.model);
console.log('db.output:', component.db.output);
```

### Metoda 2: Breakpoint

1. DevTools (F12) → Sources → Ctrl+P → `contentloader.component.ts`
2. Postavi breakpoint na liniju 35 (`this.db.setoutput(...)`)
3. Refreshaj stranicu
4. U Console upiši `this.db.model` i `this.db.output`

### Metoda 3: Network Tab

Prati `/uomback/suicapture/ordnum` response koji sadrži sačuvane `model` i `output` vrijednosti u JSON formatu.

---

*Ažurirano: 2026-02-01*
*Sekcija: Od URL-a do Komponente - Detaljna Analiza*
