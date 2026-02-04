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

---

# SEKCIJA B: PRAKTIČNI VODIČ - Kako Komponenta Radi (Sa Stvarnim Podacima)

Ova sekcija objašnjava kako `evidencija-usluge.component.ts` radi korak po korak, koristeći stvarne podatke iz console.log testiranja. Napisana je za junior programere koji žele razumjeti kompletan tok podataka.

---

## B1. Šta je Ova Komponenta?

`VpnEvidencijaUslugeComponent` (file: `evidencija-usluge.component.ts`) je Angular komponenta koja:

1. **Prikazuje dinamičku formu** - Forma se ne "hardkodira" u HTML, već se generiše iz JSON-a koji dolazi sa backend-a
2. **Upravlja "korpom" (basket)** - Korpa je kontejner koji drži sve stavke koje korisnik naručuje
3. **Spašava stanje forme** - Kroz `suicapture` mehanizam, forma se može sačuvati i vratiti kasnije

### Analogija za Razumijevanje

Zamisli da je ova komponenta kao **košarica za kupovinu u online shopu**:
- `basket` = sama košarica (ima svoj ID, status, datum)
- `db.model` = proizvodi koje si stavio u košaricu (vrijednosti forme)
- `db.output` = strukturirani podaci za slanje na kasu (za backend)
- `suicapture` = "sačuvaj košaricu za kasnije" funkcionalnost

---

## B2. Životni Ciklus Komponente - Vizualni Prikaz

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        ŽIVOTNI CIKLUS KOMPONENTE                                    │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  1. UČITAVANJE STRANICE                                                             │
│     │                                                                               │
│     ▼                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  ngOnInit()                                                                 │    │
│  │  ├── Pročitaj URL parametre (offerId, specId, processId)                    │    │
│  │  ├── Pročitaj Query parametre (caId, baId, basketnum)                       │    │
│  │  ├── Učitaj podatke o korisniku (ca, ba, sa, contact)                       │    │
│  │  └── Pozovi getDynamic() za učitavanje forme                                │    │
│  └────────────────────────────────────────────────────────────────────────────┘    │
│     │                                                                               │
│     ▼                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  getDynamic()                                                               │    │
│  │  ├── API poziv: GET /pcrt/order-entry                                       │    │
│  │  ├── Prima JSON strukturu forme                                             │    │
│  │  ├── Sprema u this.structure                                                │    │
│  │  └── db.params se popunjava sa parametrima                                  │    │
│  └────────────────────────────────────────────────────────────────────────────┘    │
│     │                                                                               │
│     ▼                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  FORMA SE RENDERUJE                                                         │    │
│  │  ├── z-pageloader iterira kroz JSON                                         │    │
│  │  ├── z-contentloader renderuje svaki element                                │    │
│  │  └── Korisnik popunjava polja                                               │    │
│  └────────────────────────────────────────────────────────────────────────────┘    │
│     │                                                                               │
│     ▼                                                                               │
│  2. KORISNIK KLIKNE "SNIMI"                                                         │
│     │                                                                               │
│     ▼                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  save()                                                                     │    │
│  │  ├── Provjeri: Da li basket postoji?                                        │    │
│  │  │   ├── NE → saveBasket() bez callback-a (PRVI SAVE)                       │    │
│  │  │   └── DA → saveBasket('saveItem') (DRUGI SAVE)                           │    │
│  └────────────────────────────────────────────────────────────────────────────┘    │
│     │                                                                               │
│     ├── PRVI SAVE ──────────────────────────────────────────────────┐              │
│     │                                                                │              │
│     ▼                                                                ▼              │
│  ┌────────────────────────────────┐    ┌────────────────────────────────────────┐  │
│  │  saveBasket() [PRVI]           │    │  saveBasket() [DRUGI]                  │  │
│  │  ├── firstsave = true          │    │  ├── firstsave = false                 │  │
│  │  ├── Kreira novi basket        │    │  ├── Ažurira postojeći basket          │  │
│  │  ├── assignObjects() - RESET!  │    │  ├── NE poziva assignObjects()         │  │
│  │  │   └── db.model = {auto:{}}  │    │  ├── db.model OSTAJE popunjen          │  │
│  │  └── saveSuicapture()          │    │  └── saveSuicapture()                  │  │
│  │      └── model je PRAZAN       │    │      └── model IMA podatke             │  │
│  └────────────────────────────────┘    └────────────────────────────────────────┘  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## B3. KORAK 1: ngOnInit() - Inicijalizacija

Kada se komponenta učita, `ngOnInit()` se automatski poziva. Ovo je kao "priprema radnog stola" prije nego što počneš raditi.

### Stvarni Console.log Podaci:

```
=== ngOnInit START ===
Query Params: {
  processGroupCode: 'RESIDENTIAL_SALES',
  orderTypeName: 'Osnovne usluge',
  caId: '130025794',
  baId: '330021716'
}
Route Params: {type: 'residential', offerId: '1174', specId: '162', activeIndex: '0'}
basketnum: undefined
ordnum: undefined
=== ngOnInit END ===
```

### Objašnjenje Svakog Podatka:

| Podatak | Vrijednost | Šta Znači |
|---------|------------|-----------|
| `processGroupCode` | `RESIDENTIAL_SALES` | Tip procesa - prodaja za rezidencijalne korisnike |
| `orderTypeName` | `Osnovne usluge` | Naziv tipa narudžbe |
| `caId` | `130025794` | ID Customer Account-a (korisnika) |
| `baId` | `330021716` | ID Billing Account-a (računa za naplatu) |
| `type` | `residential` | Tip ponude iz URL-a |
| `offerId` | `1174` | ID ponude (ProductOffer) |
| `specId` | `162` | ID specifikacije proizvoda |
| `activeIndex` | `0` | Aktivni tab (0 = prvi) |
| `basketnum` | `undefined` | Nema postojeće korpe - ovo je NOVA narudžba |

### Šta Ovo Znači Za Tebe Kao Junior Programera:

```typescript
// ngOnInit() radi ovo:

// 1. Čita parametre iz URL-a
this.route.params.subscribe(params => {
  this.offerId = params['offerId'];     // 1174
  this.specId = params['specId'];       // 162
});

// 2. Čita query parametre
this.route.queryParams.subscribe(query => {
  this.basketnum = query['basketnum'];  // undefined (nova narudžba)
  // Ako postoji basketnum, znači da učitavamo postojeću narudžbu
});

// 3. Učitava podatke o korisniku iz SharedDataService
this.ca = this.sharedData.customer.customerGeneralInfo;
this.ba = this.sharedData.ba;

// 4. Poziva getDynamic() da učita formu
this.getDynamic();
```

---

## B4. KORAK 2: getDynamic() - Učitavanje Strukture Forme

Ova metoda poziva backend API da dobije JSON strukturu forme. Forma se ne piše u HTML-u, već dolazi dinamički!

### Stvarni Console.log Podaci:

```
=== getDynamic START ===
callback: undefined
db.mod: new
API poziv /pcrt/order-entry sa: {
  productOfferId: '1174',
  productSpecificationId: '162',
  appProcessId: '10'
}
=== /pcrt/order-entry RESPONSE ===
structure: {
  structure: Array(1),      // Niz elemenata forme
  parameters: {...},        // Parametri
  validation: Array(0)      // Validaciona pravila
}
db.params NAKON update: {
  type: 100,
  processGroupCode: 'RESIDENTIAL_SALES',
  orderTypeName: 'Osnovne usluge',
  caId: '130025794',
  baId: '330021716',
  ...
}
=== getDynamic END ===
```

### Šta Je `db.mod`?

`db.mod` je "mod" u kojem forma radi:

| Vrijednost | Značenje |
|------------|----------|
| `new` | Nova narudžba - forma je prazna i editabilna |
| `disabled` | Postojeća narudžba - forma je samo za pregled (readonly) |
| `preview` | Preview mode |

### Vizualni Prikaz API Poziva:

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  FRONTEND                           BACKEND                                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  getDynamic()                                                                       │
│       │                                                                             │
│       │  GET /pcrt/order-entry                                                      │
│       │  ?productOfferId=1174                                                       │
│       │  &productSpecificationId=162                                                │
│       │  &appProcessId=10                                                           │
│       │                                                                             │
│       └─────────────────────────────────►  ┌─────────────────────────────────────┐  │
│                                            │  1. Pronađi definiciju forme za     │  │
│                                            │     offer 1174 i spec 162           │  │
│                                            │                                     │  │
│                                            │  2. Generiši JSON sa elementima:    │  │
│                                            │     - Input polja                   │  │
│                                            │     - Dropdown-i                    │  │
│                                            │     - Checkbox-i                    │  │
│                                            │     - Sekcije                       │  │
│                                            └─────────────────────────────────────┘  │
│       ◄─────────────────────────────────────────────────────────────────────────────│
│       │                                                                             │
│  structure = response.structure                                                     │
│  db.params = { ...parametri... }                                                    │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## B5. KORAK 3: save() - Kada Korisnik Klikne "Snimi"

Ovo je najvažnija metoda! Kada korisnik klikne dugme "Snimi", poziva se `save()`.

### SCENARIJO A: Prvi Save (Basket NE Postoji)

```
=== save() START ===
basket.id: undefined                    <-- Basket ne postoji!
db.model: {
  auto: {...},
  Osnovneusluge: {...},                 <-- Forma IMA podatke
  loadOffer162: null,
  parent: f
}
Basket NE postoji -> saveBasket() bez callback-a
```

### SCENARIJO B: Drugi Save (Basket POSTOJI)

```
=== save() START ===
basket.id: 257534                       <-- Basket POSTOJI!
db.model: {
  auto: {...},
  Osnovneusluge: {...},                 <-- Forma IMA podatke
  loadOffer162: null,
  parent: f
}
Basket POSTOJI -> saveBasket() sa callback: saveItem
```

### Logika u Kodu:

```typescript
save() {
  // Provjera: da li basket već postoji?
  if (!this.basket.id) {
    // PRVI SAVE - kreiraj novi basket
    // callback je undefined, što znači firstsave = true
    this.saveBasket();
  } else {
    // DRUGI SAVE - basket već postoji
    // callback je 'saveItem', što znači firstsave = false
    this.saveBasket('saveItem');
  }
}
```

### Zašto Je Ovo Važno?

Razlika između prvog i drugog save-a je KRITIČNA:

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        PRVI SAVE vs DRUGI SAVE                                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  PRVI SAVE (basket.id = undefined)        DRUGI SAVE (basket.id = 257534)          │
│  ─────────────────────────────────────    ─────────────────────────────────────    │
│                                                                                     │
│  1. saveBasket() bez callback-a           1. saveBasket('saveItem')                 │
│  2. firstsave = true                      2. firstsave = false                      │
│  3. Kreira novi basket na backendu        3. Ažurira postojeći basket               │
│  4. assignObjects() SE POZIVA!            4. assignObjects() se NE poziva           │
│     └── db.model = {auto: {}}                └── db.model OSTAJE popunjen           │
│  5. saveSuicapture() sa PRAZNIM modelom   5. saveSuicapture() sa PUNIM modelom      │
│                                                                                     │
│  REZULTAT: Model se gubi!                 REZULTAT: Model se spašava!               │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## B6. KORAK 4: saveBasket() - Kreiranje/Ažuriranje Korpe

### Prvi Save - Kreiranje Nove Korpe:

```
=== saveBasket() START ===
callback: undefined
firstsave: true
setBasket() podaci: {
  id: null,                              <-- null jer je nova korpa
  headbasketnum: undefined,
  acontactId: 45112814,
  bacustomerId: 330021716,
  cacustomerId: 130025794,
  description: 'opis test',              <-- Korisnikov unos!
  comments: 'komentar test'              <-- Korisnikov unos!
}
/uomback/basket/save RESPONSE: {
  responseCode: 0,
  responseDetail: 'OK',
  payload: {...}
}
basket NAKON response: {
  id: 257534,                            <-- Backend je dodijelio ID!
  basketnum: '257532-01/26',             <-- I broj korpe!
  baskettypeCode: 'SALES',
  description: 'opis test',
  comments: 'komentar test'
}
=== saveBasket() END ===
```

### Drugi Save - Ažuriranje Postojeće Korpe:

```
=== saveBasket() START ===
callback: saveItem
firstsave: false
setBasket() podaci: {
  id: 257534,                            <-- Postojeći ID
  ...
}
/uomback/basket/save RESPONSE: {
  responseCode: 0,
  responseDetail: 'OK'
}
basket NAKON response: {
  id: 257534,
  basketnum: '257532-01/26'
}
=== saveBasket() END ===
```

### Struktura Basket Objekta:

```typescript
basket = {
  // Identifikacija
  id: 257534,                    // Jedinstveni ID korpe
  basketnum: '257532-01/26',     // Čitljiv broj korpe (godina/redni broj)

  // Veze sa korisnicima
  cacustomerId: 130025794,       // Customer Account ID
  bacustomerId: 330021716,       // Billing Account ID
  acontactId: 45112814,          // Contact ID

  // Tip i status
  baskettypeCode: 'SALES',       // Tip: SALES, CHANGE, CANCEL...
  basketstatusCode: 'IN_CREATION', // Status: IN_CREATION, SUBMITTED...

  // Korisnikov unos
  description: 'opis test',      // Opis narudžbe
  comments: 'komentar test',     // Komentari

  // Meta podaci
  expecteddate: undefined,       // Očekivani datum realizacije
  save: true                     // Flag za spremanje
}
```

---

## B7. KORAK 5: saveSuicapture() - Spašavanje Stanja Forme

Ovo je mehanizam koji omogućava da se forma sačuva i kasnije vrati u istom stanju.

### Prvi Save - Model Je PRAZAN:

```
=== saveSuicapture() START ===
db.model: {auto: {}}                     <-- PRAZAN! Reset-ovan kroz assignObjects()
db.output: {}                            <-- PRAZAN!
ca: {id: 130025794, status: 'A', ...}
ba: {id: 330021716, status: 'A', ...}
basket: {id: 257534, basketnum: '257532-01/26', ...}
basketnum: 257532-01/26

jsonSetup za slanje: {
  entryParams: '{"processId":"10","offerId":"1174","specId":"162"}',
  model: '{"model":{"auto":{}},"output":{}}',    <-- PRAZAN MODEL!
  structure: '{"ca":{...},"ba":{...},"basket":{...}}',
  ordnum: '257532-01/26'
}
=== saveSuicapture() END ===
```

### Drugi Save - Model IMA PODATKE:

```
=== saveSuicapture() START ===
db.model: {                              <-- IMA PODATKE!
  auto: {...},
  Osnovneusluge: {...},
  loadOffer162: null,
  parent: f
}
db.output: {Osnovneusluge: {...}}        <-- IMA PODATKE!
ca: {id: 130025794, status: 'A', ...}
ba: {id: 330021716, status: 'A', ...}
basket: {
  id: 257534,
  basketnum: '257532-01/26',
  description: 'opis',
  comments: 'komentar'
}
basketnum: 257532-01/26

jsonSetup za slanje: {
  entryParams: '{"processId":"10","offerId":"1174","specId":"162"}',
  model: '{"model":{"auto":{},"Osnovneusluge":{...}},"output":{...}}',  <-- PUN MODEL!
  structure: '{"ca":{...},"ba":{...},"basket":{...,"comments":"komentar","description":"opis"}}',
  ordnum: '257532-01/26'
}
=== saveSuicapture() END ===
```

### Šta Se Spašava u Suicapture:

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        STRUKTURA SUICAPTURE PODATAKA                                │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  jsonSetup = {                                                                      │
│                                                                                     │
│    entryParams: JSON.stringify({                                                    │
│      processId: "10",              // ID procesa                                    │
│      offerId: "1174",              // ID ponude                                     │
│      specId: "162"                 // ID specifikacije                              │
│    }),                                                                              │
│                                                                                     │
│    model: JSON.stringify({                                                          │
│      model: {                      // Vrijednosti iz forme                          │
│        auto: {...},                // Auto-generisane vrijednosti                   │
│        Osnovneusluge: {            // Sekcija "Osnovne usluge"                      │
│          polje1: "vrijednost1",    // Pojedinačna polja                             │
│          polje2: "vrijednost2"                                                      │
│        }                                                                            │
│      },                                                                             │
│      output: {                     // Strukturirani output za backend               │
│        Osnovneusluge: {...}                                                         │
│      }                                                                              │
│    }),                                                                              │
│                                                                                     │
│    structure: JSON.stringify({                                                      │
│      ca: {...},                    // Customer Account podaci                       │
│      ba: {...},                    // Billing Account podaci                        │
│      sa: {...},                    // Service Agreement podaci                      │
│      contact: {...},               // Kontakt podaci                                │
│      basket: {                     // Korpa sa korisnikovim unosom                  │
│        id: 257534,                                                                  │
│        basketnum: "257532-01/26",                                                   │
│        comments: "komentar",                                                        │
│        description: "opis"                                                          │
│      }                                                                              │
│    }),                                                                              │
│                                                                                     │
│    ordnum: "257532-01/26"          // Broj narudžbe (ključ za pronalaženje)         │
│  }                                                                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## B8. Ključni Problem: Zašto Je Model Prazan Na Prvom Save?

Ovo je najvažniji insight iz testiranja!

### Uzrok Problema:

U `saveBasket()` metodi, kada je `firstsave = true`, poziva se `assignObjects()`:

```typescript
saveBasket(callback?: string) {
  let firstsave = callback ? false : true;

  // ... API poziv za kreiranje basket-a ...

  this.api.post('/uomback/basket/save', this.setBasket()).subscribe(response => {
    this.basket = response.payload;

    if (firstsave) {
      // OVO JE PROBLEM!
      this.assignObjects();  // <-- Resetuje db.model na {auto: {}}
    }

    this.saveSuicapture();   // <-- Poziva se sa praznim modelom!
  });
}
```

### Šta Radi `assignObjects()`?

```typescript
assignObjects() {
  // Ova metoda "čisti" model i priprema ga za novu sesiju
  this.db.model = { auto: {} };  // RESET!
  // ... ostala logika ...
}
```

### Vizualni Prikaz Problema:

```
PRVI SAVE:
──────────
save()
  │
  │  db.model = {auto:{}, Osnovneusluge:{...}}  // IMA PODATKE
  │
  └──► saveBasket() [firstsave = true]
          │
          │  API: POST /uomback/basket/save  ──► USPJEŠNO, basket.id = 257534
          │
          └──► assignObjects()
                  │
                  │  db.model = {auto: {}}  // RESET! Podaci forme IZGUBLJENI!
                  │
                  └──► saveSuicapture()
                          │
                          │  model = {auto: {}}  // PRAZAN model se spašava
                          │
                          └──► API: POST /uomback/suicapture


DRUGI SAVE:
───────────
save()
  │
  │  db.model = {auto:{}, Osnovneusluge:{...}}  // IMA PODATKE
  │
  └──► saveBasket('saveItem') [firstsave = false]
          │
          │  API: POST /uomback/basket/save  ──► USPJEŠNO
          │
          │  assignObjects() se NE POZIVA!
          │
          └──► saveSuicapture()
                  │
                  │  model = {auto:{}, Osnovneusluge:{...}}  // PUN model!
                  │
                  └──► API: POST /uomback/suicapture
```

---

## B9. Razumijevanje `db.model` i `db.output`

### Šta Je `db.model`?

`db.model` je objekat koji drži **sve vrijednosti** koje korisnik unese u formu.

```typescript
db.model = {
  auto: {
    // Auto-generisane vrijednosti (sekvence, datumi, itd.)
  },
  Osnovneusluge: {
    // Vrijednosti iz sekcije "Osnovne usluge"
    nekoPolje: "vrijednost",
    drugoPolje: 123
  },
  loadOffer162: null,    // Specijalno polje za učitavanje ponude
  parent: function(){}   // Referenca na parent
}
```

### Šta Je `db.output`?

`db.output` je **strukturirani** objekat koji se koristi za slanje na backend. Razlika od `db.model`:

| `db.model` | `db.output` |
|------------|-------------|
| "Sirovi" podaci forme | Strukturirani za API |
| Uključuje pomoćna polja | Samo bitna polja |
| Flat struktura | Hijerarhijska struktura |

```typescript
db.output = {
  Osnovneusluge: {
    serviceAgreement: {
      // Podaci za kreiranje Service Agreement-a
    },
    productOrder: {
      // Podaci za kreiranje narudžbe
    }
  }
}
```

### Kako Se Popunjavaju?

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  FORMA (UI)                                                                         │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │  [Input polje: Ime]  ──────────────────────────────────────────────────────┐  │  │
│  │                                                                            │  │  │
│  │  [Dropdown: Tip]  ────────────────────────────────────────────────────────┐│  │  │
│  │                                                                           ││  │  │
│  │  [Checkbox: Aktivan]  ───────────────────────────────────────────────────┐││  │  │
│  └───────────────────────────────────────────────────────────────────────────┘││  │  │
│                                                                              │││  │  │
└──────────────────────────────────────────────────────────────────────────────┘││──┘  │
                                                                               │││
    z-contentloader.component.ts                                               │││
    ─────────────────────────────                                              │││
    ngOnInit() {                                                               │││
      // Kada korisnik promijeni vrijednost                                    │││
      this.db.model[this.el.name] = newValue;  ◄───────────────────────────────┘││
                                                                                ││
      // Strukturira za output                                                  ││
      this.db.setoutput(this.el, value);  ◄─────────────────────────────────────┘│
    }                                                                            │
                                                                                 │
    ┌───────────────────────────────────────────────────────────────────────────┐│
    │  db.model = {                                                             ││
    │    Ime: "Marko",            ◄─────────────────────────────────────────────┘│
    │    Tip: "residential",       ◄──────────────────────────────────────────────┘
    │    Aktivan: true             ◄───────────────────────────────────────────────
    │  }                                                                         │
    └───────────────────────────────────────────────────────────────────────────┘│

```

---

## B10. Kompletni Tok Podataka - Od Otvaranja Do Spašavanja

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  1. KORISNIK OTVARA URL                                                             │
│     /evidencija/residential/1174/162/0?processId=10&caId=130025794&baId=330021716   │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  2. ngOnInit() SE IZVRŠAVA                                                          │
│     ├── Parsira URL: offerId=1174, specId=162                                       │
│     ├── Parsira Query: caId=130025794, baId=330021716                               │
│     ├── Učitava: ca, ba, sa, contact iz SharedDataService                           │
│     └── Poziva: getDynamic()                                                        │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  3. getDynamic() - API POZIV                                                        │
│     GET /pcrt/order-entry?productOfferId=1174&productSpecificationId=162            │
│                                                                                     │
│     RESPONSE:                                                                       │
│     {                                                                               │
│       structure: [                                                                  │
│         {                                                                           │
│           name: "Osnovneusluge",                                                    │
│           label: "Osnovne usluge",                                                  │
│           elements: [                                                               │
│             { name: "polje1", template: "input", ... },                             │
│             { name: "polje2", template: "select", ... }                             │
│           ]                                                                         │
│         }                                                                           │
│       ]                                                                             │
│     }                                                                               │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  4. FORMA SE RENDERUJE                                                              │
│                                                                                     │
│     z-pageloader iterira kroz structure                                             │
│         │                                                                           │
│         └──► z-contentloader renderuje svaki element                                │
│                 │                                                                   │
│                 ├── Input polje → <input type="text">                               │
│                 ├── Select → <select><option>...</select>                           │
│                 └── Checkbox → <input type="checkbox">                              │
│                                                                                     │
│     db.model se inicijalizira sa defaultnim vrijednostima                           │
│     db.mod = "new" (editabilno)                                                     │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  5. KORISNIK POPUNJAVA FORMU                                                        │
│                                                                                     │
│     [Ime: "Test"]  ──► db.model.Osnovneusluge.Ime = "Test"                          │
│     [Tip: "A"]     ──► db.model.Osnovneusluge.Tip = "A"                             │
│     [Opis: "..."]  ──► basket.description = "..."                                   │
│                                                                                     │
│     db.model = {                                                                    │
│       auto: {...},                                                                  │
│       Osnovneusluge: { Ime: "Test", Tip: "A", ... }                                 │
│     }                                                                               │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  6. KORISNIK KLIKNE "SNIMI" - PRVI PUT                                              │
│                                                                                     │
│     save()                                                                          │
│       │                                                                             │
│       │  basket.id = undefined  ──► PRVI SAVE                                       │
│       │                                                                             │
│       └──► saveBasket() [bez callback-a]                                            │
│               │                                                                     │
│               │  POST /uomback/basket/save                                          │
│               │  RESPONSE: { payload: { id: 257534, basketnum: "257532-01/26" } }   │
│               │                                                                     │
│               └──► assignObjects()  ──► db.model = {auto: {}}  // RESET!            │
│                       │                                                             │
│                       └──► saveSuicapture()                                         │
│                               │                                                     │
│                               │  POST /uomback/suicapture                           │
│                               │  { model: "{\"model\":{\"auto\":{}}}", ... }        │
│                               │                                                     │
│                               │  MODEL JE PRAZAN!                                   │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  7. getDynamic() SE PONOVO POZIVA (nakon prvog save-a)                              │
│                                                                                     │
│     db.mod = "new" (još uvijek editabilno)                                          │
│     Forma se ponovo renderuje sa praznim db.model                                   │
│     Korisnik PONOVO popunjava formu                                                 │
└────────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  8. KORISNIK KLIKNE "SNIMI" - DRUGI PUT                                             │
│                                                                                     │
│     save()                                                                          │
│       │                                                                             │
│       │  basket.id = 257534  ──► DRUGI SAVE                                         │
│       │                                                                             │
│       └──► saveBasket('saveItem')                                                   │
│               │                                                                     │
│               │  POST /uomback/basket/save                                          │
│               │                                                                     │
│               │  assignObjects() SE NE POZIVA!                                      │
│               │                                                                     │
│               └──► saveSuicapture()                                                 │
│                       │                                                             │
│                       │  POST /uomback/suicapture                                   │
│                       │  {                                                          │
│                       │    model: "{\"model\":{\"auto\":{},\"Osnovneusluge\":       │
│                       │            {\"Ime\":\"Test\",...}}}",                       │
│                       │    ...                                                      │
│                       │  }                                                          │
│                       │                                                             │
│                       │  MODEL IMA PODATKE!                                         │
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

## B11. Rječnik Pojmova Za Junior Programere

| Pojam | Objašnjenje |
|-------|-------------|
| `basket` | "Korpa" - kontejner za narudžbu, sličan košarici u web shopu |
| `ca` (Customer Account) | Glavni račun korisnika - sadrži lične podatke |
| `ba` (Billing Account) | Račun za naplatu - vezan za ca, koristi se za fakturisanje |
| `sa` (Service Agreement) | Ugovor o usluzi - nastaje kada se aktivira usluga |
| `db.model` | Objekat koji drži sve vrijednosti forme |
| `db.output` | Strukturirani podaci za slanje na backend |
| `db.params` | Parametri koji se koriste za generisanje forme |
| `db.mod` | Mod forme: "new" (editabilno), "disabled" (readonly) |
| `suicapture` | Mehanizam za spašavanje i vraćanje stanja forme |
| `structure` | JSON definicija forme koja dolazi sa backend-a |
| `offerId` | ID ponude (ProductOffer) |
| `specId` | ID specifikacije proizvoda (ProductSpecification) |
| `processId` | ID procesa (workflow koraka) |
| `firstsave` | Flag koji označava da li je ovo prvi put da se spašava |

---

## B12. Najčešće Greške i Kako Ih Izbjeći

### Greška 1: Zašto je model prazan nakon prvog save-a?

**Uzrok:** `assignObjects()` resetuje `db.model` na `{auto: {}}`

**Rješenje:** Model se ispravno spašava tek na DRUGI save

### Greška 2: Backend vraća 500 error na `/uomback/basketitem/save/new`

**Uzrok:** Backend greška - frontend ispravno šalje podatke

**Rješenje:** Provjeri backend logove

### Greška 3: Forma je readonly (disabled) iako je nova narudžba

**Uzrok:** `db.mod` je postavljen na "disabled"

**Provjera:** U console.log-u, provjeriti vrijednost `db.mod` u `getDynamic()`

---

## B13. Kako Debugirati Ovu Komponentu

### Korak 1: Dodaj console.log u ključne metode

```typescript
// ngOnInit
console.log('=== ngOnInit ===');
console.log('Query Params:', this.route.snapshot.queryParams);
console.log('Route Params:', this.route.snapshot.params);
console.log('basketnum:', this.basketnum);

// getDynamic
console.log('=== getDynamic ===');
console.log('db.mod:', this.db.mod);
console.log('API params:', { productOfferId, productSpecificationId, appProcessId });

// save
console.log('=== save ===');
console.log('basket.id:', this.basket.id);
console.log('db.model:', this.db.model);

// saveBasket
console.log('=== saveBasket ===');
console.log('firstsave:', firstsave);
console.log('setBasket():', this.setBasket());

// saveSuicapture
console.log('=== saveSuicapture ===');
console.log('db.model:', this.db.model);
console.log('db.output:', this.db.output);
console.log('jsonSetup:', jsonSetup);
```

### Korak 2: Provjeri Network tab u DevTools

Prati ove API pozive:
1. `GET /pcrt/order-entry` - Struktura forme
2. `POST /uomback/basket/save` - Kreiranje/ažuriranje korpe
3. `POST /uomback/suicapture` - Spašavanje stanja
4. `POST /uomback/basketitem/save/new` - Dodavanje stavke

### Korak 3: Provjeri Response Status

- `200 OK` - Uspješno
- `400 Bad Request` - Pogrešni podaci
- `500 Internal Server Error` - Backend greška

---

---

# SEKCIJA C: SUICAPTURE REQUEST - Detaljna Analiza Sa Stvarnim Podacima

Ovo je kompletan suicapture request koji se šalje na drugi save. Razložen je svaki dio sa objašnjenjima.

---

## C1. Struktura Suicapture Requesta

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  SUICAPTURE REQUEST STRUKTURA                                                       │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  {                                                                                  │
│    "languageId": 0,              // Jezik (0 = default)                             │
│    "channel": "",                // Kanal prodaje                                   │
│    "entity": {                   // GLAVNI PODACI                                   │
│      "entryParams": "...",       // Parametri za učitavanje forme                   │
│      "model": "...",             // Vrijednosti forme (db.model + db.output)        │
│      "structure": "...",         // Korisnik/računi/basket podaci                   │
│      "ordnum": "..."             // Broj narudžbe (ključ)                           │
│    }                                                                                │
│  }                                                                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## C2. `entryParams` - Parametri Za Učitavanje Forme

```json
{
  "processId": "10",      // ID procesa (workflow)
  "offerId": "1174",      // ID ponude (ProductOffer)
  "specId": "162"         // ID specifikacije (ProductSpecification)
}
```

**Svrha:** Kada se forma ponovo otvori, ovi parametri se koriste za poziv:
```
GET /pcrt/order-entry?productOfferId=1174&productSpecificationId=162&appProcessId=10
```

---

## C3. `model` - Vrijednosti Forme

```json
{
  "model": {
    "auto": {},                    // Auto-generisane vrijednosti (prazno)
    "Osnovneusluge": {},           // Sekcija forme (PRAZNO - nisi popunio polja)
    "loadOffer162": null           // Referenca na ponudu
  },
  "output": {
    "Osnovneusluge": {
      "attr": {},                  // Atributi
      "items": {},                 // Stavke
      "spec": {},                  // Specifikacije
      "name": "Osnovneusluge",     // Ime sekcije
      "code": "162",               // Kod specifikacije
      "active": true,              // Da li je aktivna
      "calss": "SPECIFICATION",    // Tip (class, typo u kodu)
      "businessParams": null,
      "label": "Osnovne usluge",   // Labela za prikaz
      "elementType": null
    }
  }
}
```

**Napomena:** `Osnovneusluge: {}` je prazan jer nisi popunio polja forme. Kada popuniš polja, ovdje bi bili podaci poput:
```json
"Osnovneusluge": {
  "brojTelefona": "033/123-456",
  "tipUsluge": "ISDN",
  "ugovornoVezivanje": "24"
}
```

---

## C4. `structure` - Podaci O Korisniku, Računima i Košarici

Ovo je najveći dio. Razložen je po sekcijama:

### C4.1 `ca` - Customer Account (Korisnik)

```json
{
  "id": 130025794,                           // Jedinstveni ID korisnika
  "status": "A",                             // A = Aktivan
  "activationdate": "2026-01-30T09:12:31",   // Datum aktivacije
  "contractpointInd": "0",                   // Nije contract point
  "customerstypeCode": "1000",               // Tip korisnika (šifra)
  "customertypeCode": "100",                 // 100 = Fizičko lice
  "customertypeName": "Fizičko lice",
  "mainlocationId": 2,                       // Glavna lokacija
  "mainlocationName": "Direkcija Sarajevo",
  "saleslocationId": 2,                      // Prodajna lokacija
  "salesslocationId": 24,                    // Pod-lokacija
  "salesslocationName": "Šalter-Dolac Malta",
  "parentInd": "1",                          // 1 = Ovo je parent (Head CA)
  "pCaId": 130025794,                        // Parent CA ID (sam sebi parent)

  // Lični podaci
  "customerinfo": {
    "birthdate": "2026-01-19",
    "firstname": "JNF-8241",
    "lastname": "130025794 - JNF-8241 JNF-8241",
    "surname": "JNF-8241",
    "genderCode": "M",                       // Muško
    "defaultCustomer": "JNF-8241 JNF-8241"
  },

  // GDPR saglasnost
  "ccustomergdpr": {
    "promNotfcs": "0",       // Promotivne notifikacije: NE
    "providingData": "1",    // Dostavljanje podataka: DA
    "bhtMarketing": "1",     // BHT marketing: DA
    "profiling": "1",        // Profiliranje: DA
    "status": "1"            // Aktivan
  },

  // Kontakti
  "contacts": [{
    "id": 45112814,
    "firstname": "JNF-8241 JNF-8241",
    "cmethodCode": "EMAIL",
    "mobilephone": "061/677889",
    "email": "omar.bilalovic@gmail.com",
    "croletypeCode": "100",           // 100 = Korisnik
    "croletypeName": "Korisnik"
  }],

  // Adrese
  "addresses": [{
    "id": 21177314,
    "addressCode": "54307",
    "addressname": "24 Juni",
    "houseno": "234",
    "townName": "GRAD SARAJEVO",
    "zipCode": "71000",
    "aroletypeCode": "100",           // 100 = Adresa sjedišta
    "aroletypeName": "Adresa sjedišta",
    "addressCodeName": "GRAD SARAJEVO, 24 Juni 234"
  }],

  // Identifikacioni dokumenti
  "customeridents": [{
    "identtypeCode": "SCHOOL",
    "identno": "119955",
    "identtypeName": "Đačka knjižica"
  }],

  // Billing accounti grupirani po tehnologiji
  "groupedByTechnology": [{
    "ptechnologyCode": "100",
    "ptechnologyName": "Fiksna",
    "billingAccounts": [...]
  }]
}
```

### C4.2 `ba` - Billing Account (Primaoc Računa)

```json
{
  "id": 330021716,                           // BA ID
  "status": "A",                             // Aktivan
  "customerId": 130025794,                   // Pripada CA-u
  "activationdate": "2026-01-26T15:05:38",
  "billpointInd": "0",                       // Nije bill point
  "headId": 130025794,                       // Head CA
  "ptechnologyCode": "100",                  // Fiksna tehnologija
  "ptechnologyName": "Fiksna",
  "customerName": "330021716 - JNF-8241-B",
  "pCaId": 130025794,                        // Parent CA
  "pBaId": 330021716,                        // Parent BA (sam sebi)

  // Kontakti BA
  "contacts": [{
    "id": 45112815,
    "firstname": " JNF-8241-B",
    "croletypeCode": "200",                  // 200 = Primaoc računa
    "croletypeName": "Primaoc računa"
  }],

  // Adrese BA
  "addresses": [{
    "id": 21177315,
    "addressname": "Abdića",
    "houseno": "123",
    "townName": "GRAD SARAJEVO",
    "aroletypeCode": "200",                  // 200 = Adresa za dostavu računa
    "aroletypeName": "Adresa za dostavu računa",
    "addressCodeName": "GRAD SARAJEVO, Abdića 123"
  }],

  "billingAddress": "GRAD SARAJEVO, Abdića 123"
}
```

### C4.3 `sa` - Service Agreement (Servisni Ugovor)

```json
{
  "id": 515653794,
  "address": "GRAD SARAJEVO, Abdulaha Bošnjaka 234",
  "addressId": 21177285
}
```

### C4.4 `contact` - Odabrani Kontakt

```json
{
  "contact": true,
  "id": 45112814,
  "croletypeName": "Korisnik",
  "firstname": "JNF-8241 JNF-8241"
}
```

### C4.5 `basket` - Korpa/Narudžba

```json
{
  "save": true,                              // Označava da je spašen
  "id": 257552,                              // Basket ID
  "basketnum": "257550-01/26",               // Broj narudžbe (čitljiv)
  "baskettypeCode": "SALES",                 // Tip: Prodaja
  "created": "2026-02-03T14:58:31.062",      // Datum kreiranja
  "createdBy": "aa",                         // Ko je kreirao
  "headbasketnum": "257550/26",              // Glavni broj narudžbe
  "orderdate": "2026-02-03T14:58:31.062",    // Datum narudžbe
  "status": "0",                             // Status kod
  "statusName": "U pripremi",                // Status ime
  "basketTypeName": "SALES",
  "comments": "test",                        // Tvoj komentar!
  "description": "test"                      // Tvoj opis!
}
```

---

## C5. `ordnum` - Ključ Za Pronalaženje

```json
"ordnum": "257550-01/26"
```

Ovo je ključ po kojem se suicapture pronalazi kada se forma ponovo otvori.

---

## C6. Vizualni Pregled Cijele Strukture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  SUICAPTURE - KOMPLETNA SLIKA                                                       │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ordnum: "257550-01/26"  ← KLJUČ za pronalaženje                                    │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  entryParams                                                                │    │
│  │  ├── processId: "10"                                                        │    │
│  │  ├── offerId: "1174"        Za učitavanje iste forme                        │    │
│  │  └── specId: "162"                                                          │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  model                                                                      │    │
│  │  ├── model.auto: {}                                                         │    │
│  │  ├── model.Osnovneusluge: {}    Vrijednosti polja (prazno)                  │    │
│  │  └── output.Osnovneusluge: {}   Struktura za backend                        │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │  structure                                                                  │    │
│  │  │                                                                          │    │
│  │  ├── ca (Customer Account)                                                  │    │
│  │  │   ├── id: 130025794                                                      │    │
│  │  │   ├── customerinfo: {ime, prezime, datum rođenja}                        │    │
│  │  │   ├── contacts: [{email, telefon}]                                       │    │
│  │  │   ├── addresses: [{adresa sjedišta}]                                     │    │
│  │  │   └── ccustomergdpr: {GDPR saglasnosti}                                  │    │
│  │  │                                                                          │    │
│  │  ├── ba (Billing Account)                                                   │    │
│  │  │   ├── id: 330021716                                                      │    │
│  │  │   ├── ptechnologyName: "Fiksna"                                          │    │
│  │  │   ├── contacts: [{primaoc računa}]                                       │    │
│  │  │   └── addresses: [{adresa za račun}]                                     │    │
│  │  │                                                                          │    │
│  │  ├── sa (Service Agreement)                                                 │    │
│  │  │   ├── id: 515653794                                                      │    │
│  │  │   └── address: "instalacijska adresa"                                    │    │
│  │  │                                                                          │    │
│  │  ├── contact                                                                │    │
│  │  │   └── id: 45112814 (odabrani kontakt)                                    │    │
│  │  │                                                                          │    │
│  │  └── basket                                                                 │    │
│  │      ├── id: 257552                                                         │    │
│  │      ├── basketnum: "257550-01/26"                                          │    │
│  │      ├── status: "U pripremi"                                               │    │
│  │      ├── comments: "test"        ← TVOJ UNOS                                │    │
│  │      └── description: "test"     ← TVOJ UNOS                                │    │
│  │                                                                             │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## C7. Šta Se Dešava Kada Ponovo Otvoriš Formu?

```
1. Otvori URL sa basketnum=257550-01/26

2. ngOnInit() → loadDynamicData()
   │
   └── GET /uomback/suicapture/ordnum?ordnum=257550-01/26
       │
       └── RESPONSE: Cijeli ovaj JSON koji si pokazao

3. Parsiraj podatke:
   │
   ├── Object.assign(this.db, JSON.parse(r.payload.model))
   │   └── Vrati db.model i db.output
   │
   ├── Object.assign(this, JSON.parse(r.payload.entryParams))
   │   └── Postavi processId, offerId, specId
   │
   └── Object.assign(this, JSON.parse(r.payload.structure))
       └── Vrati ca, ba, sa, contact, basket

4. getDynamic() → Učitaj strukturu forme

5. Forma se renderuje sa sačuvanim podacima
```

---

---

# SEKCIJA D: SUICAPTURE - Jednostavno Objašnjenje Sa Analogijom

Ova sekcija objašnjava suicapture mehanizam na najjednostavniji mogući način, koristeći analogije iz svakodnevnog života.

---

## D1. Suicapture = "Save Game" u Video Igri

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│  VIDEO IGRA                              JPP APLIKACIJA                             │
│  ──────────                              ───────────────                            │
│                                                                                     │
│  Igraš igru...                           Popunjavaš formu...                        │
│       │                                        │                                    │
│       ▼                                        ▼                                    │
│  Klikneš "SAVE GAME"                     Klikneš "SNIMI"                            │
│       │                                        │                                    │
│       ▼                                        ▼                                    │
│  Igra sačuva:                            Suicapture sačuva:                         │
│  - Tvoju poziciju                        - Vrijednosti forme (model)                │
│  - Tvoje oružje                          - Podatke o korisniku (ca, ba)             │
│  - Tvoj level                            - Broj narudžbe (basketnum)                │
│  - Tvoj inventar                         - Parametre (offerId, specId)              │
│       │                                        │                                    │
│       ▼                                        ▼                                    │
│  Sutra otvoriš igru                      Sutra otvoriš formu                        │
│  Klikneš "LOAD GAME"                     URL ima basketnum=257550-01/26             │
│       │                                        │                                    │
│       ▼                                        ▼                                    │
│  Igra učita sve nazad                    Forma učita sve nazad                      │
│  Nastavljaš gdje si stao                 Nastavljaš gdje si stao                    │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## D2. Problem Koji Suicapture Rješava

**Problem:** Korisnik popunjava formu, ali ne završi. Zatvori browser. Sutra želi nastaviti.

**Rješenje:** Suicapture spašava SVE podatke u bazu, i vraća ih kada korisnik ponovo otvori formu.

```
SPAŠAVANJE (SAVE):
──────────────────
Korisnik klikne "Snimi"
       │
       ▼
┌──────────────────────────────────────┐
│  Uzmi sve podatke:                   │
│  - Šta je korisnik upisao u formu    │
│  - Ko je korisnik (CA)               │
│  - Ko plaća račun (BA)               │
│  - Broj narudžbe                     │
└──────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Spakuj u JSON                       │
└──────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  POST /uomback/suicapture            │
│  Pošalji na server                   │
│  Server spremi u bazu                │
└──────────────────────────────────────┘


UČITAVANJE (LOAD):
──────────────────
Korisnik otvori URL sa ?basketnum=257550-01/26
       │
       ▼
┌──────────────────────────────────────┐
│  GET /uomback/suicapture/ordnum      │
│  ?ordnum=257550-01/26                │
│  Traži sačuvane podatke              │
└──────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Server vrati JSON                   │
└──────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Raspakovaj JSON                     │
│  Vrati podatke u formu               │
│  Korisnik vidi sve kao prije         │
└──────────────────────────────────────┘
```

---

## D3. Četiri Kutije U Suicapture

Zamisli da imaš 4 kutije u koje pakuješ stvari prije selidbe:

### Kutija 1: `entryParams` - "Koju Formu Da Učitam?"

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KUTIJA 1: entryParams                                                              │
│  ─────────────────────                                                              │
│                                                                                     │
│  ┌─────────────────────────────────┐                                                │
│  │  processId: "10"                │  ← Koji proces (workflow)                      │
│  │  offerId: "1174"                │  ← Koja ponuda                                 │
│  │  specId: "162"                  │  ← Koja specifikacija proizvoda                │
│  └─────────────────────────────────┘                                                │
│                                                                                     │
│  ANALOGIJA: Kao da kažeš "Otvori Word dokument sa lokacije C:\Dokumenti\ugovor.docx"│
│                                                                                     │
│  Primjer: "Učitaj formu za Fiksnu telefoniju, ponuda 1174, specifikacija 162"       │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Kutija 2: `model` - "Šta Je Korisnik Upisao?"

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KUTIJA 2: model                                                                    │
│  ───────────────                                                                    │
│                                                                                     │
│  ┌─────────────────────────────────┐                                                │
│  │  model: {                       │                                                │
│  │    Osnovneusluge: {             │                                                │
│  │      brojTelefona: "033/123456" │  ← Vrijednosti polja                           │
│  │      tipUsluge: "ISDN"          │                                                │
│  │      ugovor: "24 mjeseca"       │                                                │
│  │    }                            │                                                │
│  │  },                             │                                                │
│  │  output: {                      │                                                │
│  │    ...strukturirani podaci...   │  ← Za slanje na backend                        │
│  │  }                              │                                                │
│  └─────────────────────────────────┘                                                │
│                                                                                     │
│  ANALOGIJA: Kao sadržaj Word dokumenta - tekst koji si upisao                       │
│                                                                                     │
│  Ako je prazno: Korisnik nije popunio polja forme                                   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Kutija 3: `structure` - "Za Koga Je Ova Narudžba?"

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KUTIJA 3: structure                                                                │
│  ──────────────────                                                                 │
│                                                                                     │
│  ┌─────────────────────────────────┐                                                │
│  │  ca: {                          │  ← KORISNIK (Customer Account)                 │
│  │    id: 130025794,               │     - Ime, prezime                             │
│  │    customerinfo: {...},         │     - Adresa sjedišta                          │
│  │    contacts: [...],             │     - Kontakt podaci                           │
│  │    addresses: [...]             │     - GDPR saglasnost                          │
│  │  }                              │                                                │
│  │                                 │                                                │
│  │  ba: {                          │  ← PRIMAOC RAČUNA (Billing Account)            │
│  │    id: 330021716,               │     - Ko plaća                                 │
│  │    billingAddress: "...",       │     - Adresa za račun                          │
│  │    ptechnologyName: "Fiksna"    │     - Tehnologija                              │
│  │  }                              │                                                │
│  │                                 │                                                │
│  │  sa: {                          │  ← SERVISNI UGOVOR (Service Agreement)         │
│  │    id: 515653794,               │     - Instalacijska adresa                     │
│  │    address: "..."               │                                                │
│  │  }                              │                                                │
│  │                                 │                                                │
│  │  contact: {                     │  ← KONTAKT OSOBA                               │
│  │    id: 45112814,                │     - Koga zvati                               │
│  │    firstname: "Marko"           │                                                │
│  │  }                              │                                                │
│  │                                 │                                                │
│  │  basket: {                      │  ← KOŠARICA/NARUDŽBA                           │
│  │    id: 257552,                  │     - Broj narudžbe                            │
│  │    basketnum: "257550-01/26",   │     - Status                                   │
│  │    status: "U pripremi",        │     - Komentari                                │
│  │    comments: "test",            │     - Opis                                     │
│  │    description: "test"          │                                                │
│  │  }                              │                                                │
│  └─────────────────────────────────┘                                                │
│                                                                                     │
│  ANALOGIJA: Kao zaglavlje fakture - ko naručuje, ko plaća, adresa dostave           │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Kutija 4: `ordnum` - "Broj Police U Skladištu"

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KUTIJA 4: ordnum                                                                   │
│  ────────────────                                                                   │
│                                                                                     │
│  ┌─────────────────────────────────┐                                                │
│  │  ordnum: "257550-01/26"         │  ← JEDINSTVENI KLJUČ                           │
│  └─────────────────────────────────┘                                                │
│                                                                                     │
│  ANALOGIJA: Kao broj police u skladištu                                             │
│                                                                                     │
│  Kada želiš pronaći kutije, kažeš "Daj mi sve sa police 257550-01/26"               │
│  Skladištar (baza) pronađe i vrati ti sve 4 kutije                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## D4. Životni Primjer - Referent Na Šalteru

```
SCENARIO: Referent na šalteru BH Telecoma
─────────────────────────────────────────

PONEDJELJAK 09:00
─────────────────
- Dolazi korisnik Marko Marković
- Referent otvori JPP aplikaciju
- Pretraži Marka po JMB-u
- Počne popunjavati zahtjev za fiksni telefon
- Unese:
  - Tip usluge: ISDN
  - Broj telefona: 033/123-456
  - Ugovor: 24 mjeseca
- Klikne "SNIMI"

       │
       ▼

SUICAPTURE SPASI SVE:
┌────────────────────────────────────┐
│  entryParams: processId=10...      │
│  model: {brojTelefona: "033/..."}  │
│  structure: {ca: Marko, ba: ...}   │
│  ordnum: "257550-01/26"            │
└────────────────────────────────────┘
       │
       ▼
    BAZA PODATAKA


PONEDJELJAK 09:15
─────────────────
- Marko kaže: "Moram ići, vratiću se sutra"
- Referent zatvori browser
- Svi podaci su SAČUVANI u bazi


UTORAK 09:00
────────────
- Marko se vrati
- Referent otvori link:
  /evidencija/residential/1174/162/0?basketnum=257550-01/26
       │
       ▼

SUICAPTURE UČITA SVE:
┌────────────────────────────────────┐
│  GET /uomback/suicapture/ordnum    │
│  ?ordnum=257550-01/26              │
└────────────────────────────────────┘
       │
       ▼
┌────────────────────────────────────┐
│  Vrati sve 4 kutije iz baze        │
│  Raspakovaj u formu                │
└────────────────────────────────────┘
       │
       ▼

- Forma izgleda IDENTIČNO kao jučer!
- Sva polja su popunjena
- Referent nastavi gdje je stao
- Završi zahtjev
- Marko dobije telefon
```

---

## D5. Dijagram Toka - Najjednostavniji Prikaz

```
         SNIMI                                    OTVORI
           │                                        │
           ▼                                        ▼
    ┌─────────────┐                         ┌─────────────┐
    │   FORMA     │                         │    URL      │
    │  (podaci)   │                         │ ?basketnum= │
    └──────┬──────┘                         └──────┬──────┘
           │                                        │
           ▼                                        ▼
    ┌─────────────┐                         ┌─────────────┐
    │  SUICAPTURE │ ══════► BAZA ═══════►   │  SUICAPTURE │
    │    SAVE     │        PODATAKA         │    LOAD     │
    └─────────────┘                         └──────┬──────┘
                                                   │
                                                   ▼
                                            ┌─────────────┐
                                            │   FORMA     │
                                            │  (vraćena)  │
                                            └─────────────┘
```

---

## D6. Zašto Se Zove "Suicapture"?

**SUI** = Screen/State User Interface
**CAPTURE** = Snimanje/Hvatanje

Doslovno: "Snimanje stanja korisničkog interfejsa"

Snima kompletno stanje forme da bi se moglo vratiti kasnije.

---

## D7. Kada Se Suicapture Poziva?

| Akcija | Metoda | Šta Se Dešava |
|--------|--------|---------------|
| Prvi "Snimi" | `saveBasket()` → `saveSuicapture()` | Kreira basket, spašava (prazan model) |
| Drugi "Snimi" | `saveBasket('saveItem')` → `saveSuicapture()` | Ažurira basket, spašava (pun model) |
| Otvaranje postojećeg | `loadDynamicData()` | Učitava iz suicapture |

---

## D8. API Endpoints

| Endpoint | Metoda | Svrha |
|----------|--------|-------|
| `/uomback/suicapture` | POST | Spasi stanje forme |
| `/uomback/suicapture/ordnum?ordnum=XXX` | GET | Učitaj stanje forme |

---

## D9. Struktura JSON Requesta

```json
{
  "languageId": 0,
  "channel": "",
  "entity": {
    "entryParams": "{...}",    // Parametri za učitavanje forme (JSON string)
    "model": "{...}",          // Vrijednosti forme (JSON string)
    "structure": "{...}",      // Korisnik/računi/basket (JSON string)
    "ordnum": "257550-01/26"   // Ključ za pronalaženje
  }
}
```

**Napomena:** `entryParams`, `model` i `structure` su JSON stringovi unutar JSON-a (dvostruka serijalizacija).

---

---

---

# SEKCIJA E: Od getDynamic() Do Korisničkog Unosa - Detaljni Tok

Ovo je detaljno objašnjenje koraka 4-6 u toku forme: API poziv, renderiranje forme, i korisničke interakcije.

---

## E1. Korak 4: getDynamic() → GET /pcrt/order-entry

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KORAK 4: getDynamic() - Učitavanje Strukture Forme                                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  evidencija-usluge.component.ts linija 155-170:                                     │
│                                                                                     │
│  getDynamic(callback?: any) {                                                       │
│    // 1. POSTAVI MOD (preview/new/edit/disabled)                                    │
│    this.db.setmod(                                                                  │
│      this.ordnum,                    // Ako postoji ordnum → preview                │
│      this.basketnum,                 // Ako postoji basketnum → edit                │
│      this.ca.id,                     // Ako postoji CA → new                        │
│      this.ba.id,                     // Ako postoji BA → new                        │
│      force?,                         // Forsiran mod                                │
│      this.patch                      // Patch mod                                   │
│    );                                                                               │
│                                                                                     │
│    // 2. POZOVI API                                                                 │
│    this.api.get('/pcrt/order-entry', {                                              │
│      interactionId: 16,                                                             │
│      productOfferId: this.offerId,           // 1174                                │
│      productSpecificationId: this.specId,    // 162                                 │
│      appProcessId: this.processId,           // 10                                  │
│      setupType: this.setupType                                                      │
│    }).subscribe((r: RestPayload) => {                                               │
│                                                                                     │
│      // 3. SAČUVAJ STRUKTURU                                                        │
│      this.structure = r.payload;                                                    │
│                                                                                     │
│      // 4. AŽURIRAJ PARAMETRE                                                       │
│      this.db.update(this.db.params, Object.assign(                                  │
│        this.structure.parameters,            // {type: 100} od backenda             │
│        this.params,                          // Lokalni parametri                   │
│        this.setparms()                       // CA_ID, BA_ID, SA_ID...              │
│      ));                                                                            │
│                                                                                     │
│      // 5. POZOVI CALLBACK AKO POSTOJI                                              │
│      !callback || this[callback]();                                                 │
│    });                                                                              │
│  }                                                                                  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### setparms() - Parametri Koji Se Dodaju

```typescript
// evidencija-usluge.component.ts linija 189-207
setparms() {
  return Object.assign({
    P_MAIN_OFFER_ID: this.offerId,                          // 1174
    P_CA_ID: this.ca.id,                                    // 130025794
    P_BA_ID: this.ba.id,                                    // 330021716
    P_SA_ID: !this.ia ? this.sa.id : null,                  // 515653794
    P_SALES_SUB_LOCATION_ID: this.user.getSubSalesLocationId(),
    P_SALES_LOCATION_ID: this.user.getSalesLocationId(),
    P_LOGGED_USER: this.user.getName(),
    P_SALES_CHANNEL: this.user.getChannel(),
    P_APP_USER: this.user.getUserCode()
  }, this.basket);                                          // Dodaje i sve iz basket-a
}
```

### db.setmod() - Određivanje Moda

```typescript
// model.service.ts linija 23
// ['disabled', 'new', 'edit', 'preview'][index]
public setmod(order?, basket?, ca?, ids?, force?, patch?) {
  this.patch = patch;
  this.mod = force || ['disabled', 'new', 'edit', 'preview'][
    order && basket ? 3 :    // ordnum + basketnum → preview
    basket ? 2 :             // samo basketnum   → edit
    ca && ids ? 1 :          // CA + BA          → new
    0                        // ništa            → disabled
  ];
}
```

### API Response Struktura

```
{
  "payload": {
    "parameters": { "type": 100 },
    "structure": [                          ← OVO JE NIZ ELEMENATA FORME
      {
        "label": "Osnovne usluge",
        "code": "162",
        "name": "Osnovneusluge",
        "dname": "Osnovneusluge1174",
        "template": "default_block",        ← TIP KOMPONENTE
        "visible": true,
        "active": null,
        "elements": [                       ← CHILD ELEMENTI
          {
            "label": "Osnovni paket- Fizicka",
            "code": "1174",
            "name": "Osnovnipaket-Fizicka",
            "template": "basic_block",
            "inputs": [                     ← INPUT POLJA
              {
                "label": "Ime",
                "code": "FIRSTNAME",
                "name": "FIRSTNAME",
                "dname": "FIRSTNAME_1174",
                "template": "input",
                "elementType": "text",
                "visible": true,
                "disabled": false,
                "validation": {},
                "value": {
                  "data": [],
                  "generationFormula": "select uomcommon.fgetFirstLastname(#:P_CA_ID#,'FIRSTNAME') from dual"
                }
              }
              // ... više input polja
            ]
          }
        ]
      }
    ]
  }
}
```

---

## E2. Korak 5: Angular Renderira Formu

### Template Entry Point

```html
<!-- evidencija-usluge.template.html linija 265-267 -->
<z-pageloader
    *ngIf="structure"                    <!-- Renderaj samo ako postoji struktura -->
    [model]="db.model"                   <!-- Objekt sa vrijednostima forme -->
    [items]="structure.structure"        <!-- Niz elemenata iz API-ja -->
    [output]="db.output"                 <!-- Output za backend -->
    [parameters]="db.params">            <!-- Parametri (CA_ID, BA_ID...) -->
</z-pageloader>
```

### Hijerarhija Komponenti

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│  <z-pageloader>                                                                     │
│  pageloader.template.html:                                                          │
│  ─────────────────────────                                                          │
│  <z-contentloader *ngFor="let item of items" ...></z-contentloader>                 │
│        │                                                                            │
│        │  Za svaki element u structure.structure kreira ContentLoader               │
│        │                                                                            │
│        ▼                                                                            │
│  <z-contentloader>                                                                  │
│  contentloader.template.html:                                                       │
│  ────────────────────────────                                                       │
│  <span *ngIf="items.active">                                                        │
│    <z-dlcontent                                                                     │
│        [template]="items.template"        <!-- "default_block", "input"... -->      │
│        [inputs]="{                                                                  │
│          items: items,                    <!-- Element konfiguracija -->            │
│          model: model,                    <!-- db.model referenca -->               │
│          parameters: items.parameters,    <!-- Parametri -->                        │
│          output: output[index]            <!-- Output referenca -->                 │
│        }">                                                                          │
│    </z-dlcontent>                                                                   │
│  </span>                                                                            │
│        │                                                                            │
│        ▼                                                                            │
│  <z-dlcontent>                                                                      │
│  Dinamički učitava komponentu na osnovu template-a:                                 │
│  ────────────────────────────────────────────────────                               │
│  template: "input"         →  InputComponent                                        │
│  template: "select"        →  SelectComponent                                       │
│  template: "checkbox"      →  CheckboxComponent                                     │
│  template: "date"          →  DateComponent                                         │
│  template: "basic_block"   →  BasicBlockComponent                                   │
│  template: "default_block" →  DefaultBlockComponent                                 │
│  template: "textarea"      →  TextareaComponent                                     │
│  template: "radio"         →  RadioComponent                                        │
│  template: "AutoComplete"  →  AutoCompleteComponent                                 │
│  template: "BoxOptions"    →  BoxOptionsComponent                                   │
│  ...                                                                                │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### ContentLoader ngOnInit() - Ključna Metoda

```typescript
// contentloader.component.ts linija 26-39
ngOnInit() {
  if (this.db.mod != 'preview' && !this.isValid()) return;

  // ★ REDOSLIJED JE KRITIČAN - Ne diraj redoslijed izvršavanja! ★

  // 1. Postavi active flag
  this.items.active = this.items.active != undefined ? this.items.active : true;

  // 2. Postavi model referencu (povezuje item sa parent modelom)
  this.db.set(this.model, this.parent, this.pname);

  // 3. Sačuvaj inicijalnu aktivnost
  if (this.items.initActivity == undefined) {
    this.items.initActivity = this.items.active ? true : false;
  }

  // 4. Postavi parametre
  this.items.set || this.setParametars();

  // 5. Postavi zavisnosti između polja
  this.Depedency.set(this.items, this.model);
  this.ValueManager.setDP(this.Depedency);

  // 6. ★★★ POSTAVI POČETNE VRIJEDNOSTI ★★★
  this.items.template == 'Inputoutput' ||
    this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);

  // 7. Dobij index ime za output
  this.getIndexName();

  // 8. Postavi output strukturu (db.output)
  this.db.setoutput(this.items, this.model, this.output, this.index);

  // 9. Postavi validaciju
  this.Validation.set(this.items, this.valid, this.vparent, this.index, this.db.mod);
}
```

---

## E3. ValueManager.set() - Postavljanje Početnih Vrijednosti

```typescript
// value.manager.ts linija 25-33
public set(el: InputObject, model: any, parameters?: any, mod: string = 'new') {

  // 1. Pozovi external API ako postoji (npr. za tableview)
  !el.externalAPI || ['disabled', 'preview'].indexOf(mod) >= 0 ||
    this.setChildren(el, model, parameters);

  // 2. Učitaj poruke ako postoje (notifications)
  !el.externalMessages || ['disabled', 'preview'].indexOf(mod) >= 0 ||
    this.setmessages(el, model, parameters);

  // 3. Za select/radio ILI ako model[el.name] nije definisan
  if (['radio', 'select'].indexOf(el.template) >= 0 || model[el.name] === undefined) {

    // 3a. Ako vrijednost ne postoji, probaj je dobiti:
    if (model[el.name] === undefined) {
      this.autoincrement(el, model, parameters) ||          // Auto increment
      this.setValueByRefOrCode(el, model, parameters) ||    // Iz mappingRef
      this.setDefaultValue(el, model);                      // defaultValue
    }

    // 3b. Izvrši generationFormula (SQL upit za vrijednost)
    this[this.declare(el.value.generationFormula)](
      el, el.value.generationFormula, model, parameters, model[el.name] ? true : false
    );

    // 3c. Izvrši lookupStatement (SQL upit za dropdown opcije)
    this[this.declare(el.value.lookupStatement)](
      el, el.value.lookupStatement, model, parameters, model[el.name] ? true : false, true
    );
  }
}
```

### Dijagram: Redoslijed Postavljanja Vrijednosti

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  ValueManager.set() - TOK POSTAVLJANJA VRIJEDNOSTI                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Element: { name: "FIRSTNAME", value: { generationFormula: "select...P_CA_ID..." }} │
│                                                                                     │
│  1. Da li je model["FIRSTNAME"] definisan?                                          │
│     ├── DA → Preskoči postavljanje                                                  │
│     └── NE → Nastavi                                                                │
│                                                                                     │
│  2. Probaj autoincrement?                                                           │
│     └── NE (nema autoincrement konfiguracije)                                       │
│                                                                                     │
│  3. Probaj mappingRef?                                                              │
│     └── NE (nema mappingRef)                                                        │
│                                                                                     │
│  4. Probaj defaultValue?                                                            │
│     └── NE (nema defaultValue)                                                      │
│                                                                                     │
│  5. Izvrši generationFormula:                                                       │
│     ┌─────────────────────────────────────────────────────────────────────────┐     │
│     │  SQL: "select uomcommon.fgetFirstLastname(#:P_CA_ID#,'FIRSTNAME')       │     │
│     │        from dual"                                                       │     │
│     │                                                                         │     │
│     │  Parsira parametre:                                                     │     │
│     │  #:P_CA_ID# → parameters.P_CA_ID → 130025794                            │     │
│     │                                                                         │     │
│     │  API poziv:                                                             │     │
│     │  POST /uomback/common/lookupStatement                                   │     │
│     │  { method: "select uomcommon.fgetFirstLastname(130025794,'FIRSTNAME')   │     │
│     │            from dual" }                                                 │     │
│     │                                                                         │     │
│     │  Response: "Marko"                                                      │     │
│     │                                                                         │     │
│     │  Rezultat: model["FIRSTNAME"] = "Marko"                                 │     │
│     └─────────────────────────────────────────────────────────────────────────┘     │
│                                                                                     │
│  6. Izvrši lookupStatement (za dropdown opcije)?                                    │
│     └── NE (input polje nema lookupStatement)                                       │
│                                                                                     │
│  REZULTAT: db.model = { auto: {}, Osnovneusluge: { FIRSTNAME: "Marko" } }           │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### declare() - Odrediti Tip SQL Upita

```typescript
// value.manager.ts linija 67
private declare(formula: string) {
  return formula && formula.trim().match(/^select/i) ? 'dblookup' : 'generate';
}

// Ako formula počinje sa "select" → dblookup (SQL upit)
// Ako formula počinje sa nečim drugim → generate (API poziv)
```

### generationFormula vs lookupStatement

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│  generationFormula                        lookupStatement                           │
│  ─────────────────                        ─────────────────                         │
│  Vraća JEDNU vrijednost                   Vraća NIZ vrijednosti                     │
│  (za text input)                          (za select/dropdown)                      │
│                                                                                     │
│  Primjer:                                 Primjer:                                  │
│  "select uomcommon.fgetFirstLastname      "SELECT '0','IMA ADSL/MOJA TV'            │
│    (#:P_CA_ID#,'FIRSTNAME')                FROM DUAL                                │
│    from dual"                              UNION                                     │
│                                            SELECT '1','NEMA ADSL/MOJA TV'           │
│  Rezultat:                                  FROM DUAL"                              │
│  model["FIRSTNAME"] = "Marko"                                                       │
│                                           Rezultat:                                 │
│                                           el.value.data = [                         │
│                                             {value: "0", name: "IMA ADSL"},         │
│                                             {value: "1", name: "NEMA ADSL"}         │
│                                           ]                                         │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## E4. db.setoutput() - Gradnja Output Strukture

```typescript
// model.service.ts linija 19-21
public setoutput(el: InputObject, model: any, output: any, index: string) {
  el.output = output[index] = output[index]
    ? Object.assign(output[index], {
        name: el.name,
        code: el.code,
        value: !el.export || model         // Referenca na model
      })
    : {                                    // Novi output objekat
        attr: {},                          // Atributi
        items: {},                         // Stavke
        spec: {},                          // Specifikacije
        name: el.name,
        code: el.code,
        value: !el.export || model,        // Referenca na model (ISTI OBJEKAT)
        active: el.initActivity,
        calss: el.businessClassification,  // "SPECIFICATION", "OFFER", "Attribute"
        businessParams: el.businessParams,
        label: el.label,
        elementType: el.elementType,
        dataReference: el.dataReference
      };
}
```

---

## E5. Korak 6: Korisnik Popunjava Formu - ngModel Binding

### Input Template

```html
<!-- input.template.html -->
<input
    [id]="items.dname"                                        <!-- FIRSTNAME_1174 -->
    [name]="items.dname"                                      <!-- FIRSTNAME_1174 -->
    [(ngModel)]="model[items.name]"                           <!-- ★ DVOSMJERNO POVEZIVANJE ★ -->
    [disabled]="items.disabled?'disabled':'false'"
    [readonly]="items.disabled?'readonly':false"
    [required]="items.validation.mandatory ? model[items.name] ? false:true:false"
    [pattern]="items.validation.formatPattern ? items.validation.formatPattern:''"
    [type]="items.elementType || 'text'"
    (focusout)="Validation.validate(items, parameters);"      <!-- Validacija na izlazu -->
    (change)="Depedency.depend(items.dname);"                 <!-- Zavisnosti na promjeni -->
/>
```

### Tok Kada Korisnik Unese Vrijednost

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KORISNIK UPISUJE "033/123-456" U POLJE TELEFON                                     │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  1. Browser detektira promjenu u <input>                                            │
│     │                                                                               │
│     ▼                                                                               │
│  2. Angular [(ngModel)] binding:                                                    │
│     model["TELEFON"] = "033/123-456"                                                │
│     │                                                                               │
│     │  Pošto je model referenca na db.model.Osnovneusluge:                          │
│     │  db.model.Osnovneusluge.TELEFON = "033/123-456"                               │
│     │                                                                               │
│     ▼                                                                               │
│  3. (change) event:                                                                 │
│     Depedency.depend("TELEFON_1174")                                                │
│     │                                                                               │
│     │  Provjeri da li neko polje zavisi od TELEFON                                  │
│     │  Ako da, ažuriraj ta polja                                                    │
│     │                                                                               │
│     ▼                                                                               │
│  4. (focusout) event:                                                               │
│     Validation.validate(items, parameters)                                          │
│     │                                                                               │
│     │  Validiraj:                                                                   │
│     │  - mandatory: Da li je popunjeno?                                             │
│     │  - formatPattern: Da li format odgovara?                                      │
│     │  - minValue/maxValue: Da li je u opsegu?                                      │
│     │                                                                               │
│     ▼                                                                               │
│  5. Stanje nakon unosa:                                                             │
│                                                                                     │
│     db.model = {                                                                    │
│       auto: {},                                                                     │
│       Osnovneusluge: {                                                              │
│         FIRSTNAME: "Marko",         // Učitano iz baze (generationFormula)          │
│         NAME: "Marković",           // Učitano iz baze (generationFormula)          │
│         TELEFON: "033/123-456"      // ★ UPRAVO UNESENO OD KORISNIKA ★             │
│       }                                                                             │
│     }                                                                               │
│                                                                                     │
│     db.output = {                                                                   │
│       Osnovneusluge: {                                                              │
│         attr: {},                                                                   │
│         items: {},                                                                  │
│         spec: {},                                                                   │
│         name: "Osnovneusluge",                                                      │
│         code: "162",                                                                │
│         value: db.model.Osnovneusluge,  // ← REFERENCA NA ISTI OBJEKAT              │
│         active: true,                                                               │
│         calss: "SPECIFICATION"                                                      │
│       }                                                                             │
│     }                                                                               │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## E6. Reference - Zašto Output Automatski "Vidi" Korisničke Promjene

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  KAKO REFERENCE RADE                                                                │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  MEMORIJA:                                                                          │
│                                                                                     │
│  ┌──────────────────────────────────────────────────────────┐                       │
│  │  OBJEKAT @ 0x12345 (db.model.Osnovneusluge)              │                       │
│  │  {                                                       │                       │
│  │    FIRSTNAME: "Marko",                                   │                       │
│  │    NAME: "Marković",                                     │                       │
│  │    TELEFON: "033/123-456"                                │                       │
│  │  }                                                       │                       │
│  └──────────────────────────────────────────────────────────┘                       │
│         ▲                    ▲                    ▲                                 │
│         │                    │                    │                                 │
│    ┌────┴────┐          ┌────┴────┐          ┌────┴────┐                            │
│    │  model  │          │ output  │          │ input   │                            │
│    │ (param) │          │ .value  │          │ ngModel │                            │
│    └─────────┘          └─────────┘          └─────────┘                            │
│                                                                                     │
│  SVE TRI REFERENCE POKAZUJU NA ISTI OBJEKAT!                                        │
│                                                                                     │
│  Kada korisnik promijeni input:                                                     │
│  ngModel → model["TELEFON"] = "novi" → OBJEKAT @ 0x12345 se mijenja                 │
│                                                                                     │
│  Kada čitamo output.value.TELEFON:                                                  │
│  → čitamo iz ISTOG OBJEKTA @ 0x12345                                                │
│  → vraća "novi"                                                                     │
│                                                                                     │
│  Ovo je zašto saveSuicapture() može da čita db.output                               │
│  i automatski dobije najnovije korisničke unose!                                     │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## E7. Kompletan Dijagram: Od API Response Do Korisničkog Unosa

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│  API RESPONSE                    ANGULAR RENDERIRANJE              KORISNIK         │
│  ────────────                    ────────────────────              ────────         │
│                                                                                     │
│  structure: [                                                                       │
│    {                                                                                │
│      name: "Osnovneusluge",      ──────►  <z-contentloader>                         │
│      template: "default_block",                  │                                  │
│      elements: [                                 │                                  │
│        {                                         ▼                                  │
│          name: "OsnovniPaket",   ──────►  <z-contentloader>                         │
│          template: "basic_block",                │                                  │
│          inputs: [                               │                                  │
│            {                                     ▼                                  │
│              name: "FIRSTNAME",  ──────►  <z-contentloader>                         │
│              template: "input",                  │                                  │
│              value: {                            │                                  │
│                generationFormula:                ▼                                  │
│                "select...P_CA_ID"    ─────►  ValueManager.set()                     │
│              }                                   │                                  │
│            }                                     │  API: lookupStatement            │
│          ]                                       ▼                                  │
│        }                                    model["FIRSTNAME"] = "Marko"            │
│      ]                                           │                                  │
│    }                                             ▼                                  │
│  ]                                      <input [(ngModel)]="model['FIRSTNAME']">    │
│                                                  │                                  │
│                                                  │  Prikaz: "Marko"                 │
│                                                  │                                  │
│                                                  ▼                                  │
│                                         [Korisnik upisuje "Ivan"]                   │
│                                                  │                                  │
│                                                  ▼                                  │
│                                         model["FIRSTNAME"] = "Ivan"                 │
│                                                  │                                  │
│                                                  ▼                                  │
│                                         db.model.Osnovneusluge.FIRSTNAME = "Ivan"   │
│                                                  │                                  │
│                                                  ▼                                  │
│                                         output.Osnovneusluge.value = isti objekat    │
│                                         → FIRSTNAME automatski "Ivan"               │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## E8. Dependency Sistem

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  DEPENDENCY - Zavisnosti Između Polja                                                │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Iz API response-a (element ima dependency polje):                                  │
│                                                                                     │
│  {                                                                                  │
│    "name": "Osnovnipaket-Fizicka",                                                  │
│    "dependency": [{                                                                 │
│      "element": "loadOffer162",           // Zavisi od ovog elementa                │
│      "effect": "active",                  // Efekt: aktivira/deaktivira             │
│      "elementValue": ["1174"],            // Kada element ima vrijednost 1174       │
│      "effectData": {}                                                               │
│    }]                                                                               │
│  }                                                                                  │
│                                                                                     │
│  Tok:                                                                               │
│  Korisnik odaberi "1174" u loadOffer162 dropdown                                    │
│       │                                                                             │
│       ▼                                                                             │
│  (change) event → Depedency.depend("loadOffer162")                                  │
│       │                                                                             │
│       ▼                                                                             │
│  Provjeri sve elemente koji zavise od "loadOffer162"                                │
│       │                                                                             │
│       ▼                                                                             │
│  "Osnovnipaket-Fizicka" zavisi od "loadOffer162"                                    │
│  elementValue odgovara ["1174"]                                                     │
│       │                                                                             │
│       ▼                                                                             │
│  Izvrši efekt "active" → Osnovnipaket-Fizicka postaje AKTIVAN                       │
│  Forma renderuje input polja za taj paket                                           │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## E9. DLContent - Dinamičko Renderiranje Komponenti

```typescript
// dlcontent.ts linija 55-81
// Mapa template ime → index u Components nizu:
export const key = {
  basic_block: 0,         // Osnovni blok (sa inputs)
  default_block: 1,       // Default blok (container)
  checkblock: 2,          // Check blok
  standard_popup: 3,      // Popup
  switchtab: 4,           // Switch tab
  form: 5,                // Form
  button: 6,              // Button
  checkbox: 7,            // Checkbox
  input: 8,               // Text input ★
  number: 8,              // Number input (isti kao input)
  readonly: 8,            // Readonly input (isti kao input)
  popbutton: 9,           // Pop button
  radio: 10,              // Radio button
  select: 11,             // Select dropdown ★
  textarea: 12,           // Textarea
  date: 13,               // Date picker
  tableview: 14,          // Table
  grid: 15,               // Grid
  PriceBlock: 17,         // Price block
  navigator: 18,          // Navigator
  Notification: 20,       // Notification poruka
  CheckboxAD: 22,         // Checkbox aktivan/deaktivan
  AutoComplete: 25,       // Autocomplete
  BoxOptions: 26          // Box options
};

// Renderiranje:
updateComponent() {
  let component = Components[key[this.template]];    // Pronađi komponentu
  let factory = this.cfResolver.resolveComponentFactory(component);
  this.cmpRef = this.target.createComponent(factory); // Dinamički kreiraj
  Object.assign(this.cmpRef.instance, this.inputs);   // Predaj inputs
  this.cdRef.detectChanges();                         // Trigeri change detection
}
```

---

---

# SEKCIJA F: Pojednostavljeno Objašnjenje Za Junior Programere

## Uvod: Šta Ćemo Naučiti?

Zamislite da pravite video igru gdje igrač može:
1. **Učitati praznu igru** (nova forma)
2. **Igrati** (popunjavati formu)
3. **Save Game** (saveSuicapture - spasiti stanje)
4. **Load Game** (loadSuicapture - učitati stanje)

Ova sekcija objašnjava **kako igra zna šta da spasi i kako da to vrati**.

---

## F1. TRI KUTIJE - Osnova Svega

Zamislite da imate **tri kutije** na stolu:

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   KUTIJA 1: db.model                KUTIJA 2: db.output             │
│   ═══════════════════               ═══════════════════             │
│   "RADNI PROSTOR"                   "KUTIJA ZA SLANJE"              │
│                                                                     │
│   Ovdje korisnik piše.              Ovdje spakujemo sve             │
│   Svako polje forme ima             za backend.                     │
│   svoje mjesto ovdje.                                               │
│                                                                     │
│   {                                 {                               │
│     FIRSTNAME: "Marko",               Osnovneusluge: {              │
│     LASTNAME: "Marković",               value: → pokazuje na        │
│     TELEFON: "033-123"                          KUTIJU 1!           │
│   }                                   }                             │
│                                     }                               │
│                                                                     │
│                                                                     │
│   KUTIJA 3: db.params                                               │
│   ═══════════════════                                               │
│   "KONSTANTE / PARAMETRI"                                           │
│                                                                     │
│   Stvari koje se NE MIJENJAJU tokom popunjavanja forme:             │
│   {                                                                 │
│     P_CA_ID: 130025794,     ← ID kupca                              │
│     P_BA_ID: 330021716,     ← ID računa                             │
│     type: 100               ← Tip kupca (100 = fizičko lice)        │
│   }                                                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### KLJUČNA STVAR: Kutija 2 POKAZUJE na Kutiju 1!

To znači:
- Kada korisnik upiše nešto u formu → ide u Kutiju 1
- Kutija 2 automatski "vidi" promjenu jer gleda u Kutiju 1
- Ne trebamo ništa kopirati!

---

## F2. KORAK PO KORAK: Šta Se Dešava?

### KORAK 1: Korisnik Otvori Formu

```
┌─────────────────────────────────────────────────────────────────────┐
│  KORISNIK KLIKNE "NOVA USLUGA"                                      │
│                                                                     │
│  Angular zove: getDynamic()                                         │
│       │                                                             │
│       ▼                                                             │
│  Šalje upit na backend:                                             │
│  "Daj mi strukturu forme za ponudu 1174"                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### KORAK 2: Backend Vraća "Recept Za Formu"

```
┌─────────────────────────────────────────────────────────────────────┐
│  BACKEND VRAĆA:                                                     │
│                                                                     │
│  "Trebaš ova polja:"                                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Polje: IME                                                 │    │
│  │  Tip: input (tekstualno polje)                              │    │
│  │  Početna vrijednost: izvuci iz baze pomoću SQL-a            │    │
│  │    → "select ime from kupci where id = 130025794"           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Polje: PREZIME                                             │    │
│  │  Tip: input                                                 │    │
│  │  Početna vrijednost: isto iz baze                           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Polje: TARIFNI_PAKET                                       │    │
│  │  Tip: select (dropdown)                                     │    │
│  │  Opcije: izvuci iz baze                                     │    │
│  │    → "select id, naziv from tarifni_paketi"                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### KORAK 3: Angular Crta Formu

```
┌─────────────────────────────────────────────────────────────────────┐
│  Angular prolazi kroz svako polje i:                                │
│                                                                     │
│  ZA SVAKO POLJE:                                                    │
│  ═══════════════                                                    │
│                                                                     │
│  1. Napravi mjesto u db.model za to polje                           │
│     db.model.IME = ""                                               │
│                                                                     │
│  2. Izvrši SQL za početnu vrijednost                                │
│     SQL vraća "Marko" → db.model.IME = "Marko"                      │
│                                                                     │
│  3. Poveži input polje sa db.model                                  │
│     <input [(ngModel)]="db.model.IME">                              │
│                                                                     │
│  4. Napravi referencu u db.output                                   │
│     db.output.Osnovneusluge.value = db.model  ← ISTA KUTIJA!        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### KORAK 4: Korisnik Popunjava Formu

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    FORMA NA EKRANU                          │    │
│  │  ┌────────────────────────────────────────────────────┐     │    │
│  │  │  Ime:     [  Marko  ]  ← već popunjeno iz baze     │     │    │
│  │  │  Prezime: [ Marković]  ← već popunjeno iz baze     │     │    │
│  │  │  Telefon: [033-123-456] ← KORISNIK UPISAO          │     │    │
│  │  │  Paket:   [ Premium ▼ ] ← KORISNIK ODABRAO         │     │    │
│  │  └────────────────────────────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  Šta se dešava kada korisnik upiše "033-123-456"?                   │
│                                                                     │
│     Korisnik tipka ─────────►  <input>                              │
│                                    │                                │
│                                    │  [(ngModel)]                   │
│                                    ▼                                │
│                              db.model.TELEFON = "033-123-456"       │
│                                    │                                │
│                                    │  (ista memorija)               │
│                                    ▼                                │
│                              db.output.value.TELEFON = "033-123-456"│
│                              (automatski, jer pokazuje na isto!)    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## F3. SAVE GAME - saveSuicapture()

Sada dolazi ključni dio - **kako suicapture SPAŠAVA stanje**.

```
┌─────────────────────────────────────────────────────────────────────┐
│  KORISNIK KLIKNE "SPASI"                                            │
│                                                                     │
│  saveSuicapture() radi sljedeće:                                    │
│                                                                     │
│  1. UZMI SVE IZ db.output                                           │
│     ─────────────────────                                           │
│     db.output sadrži:                                               │
│     - value → pokazuje na db.model (sve korisničke vrijednosti)     │
│     - struktura (koja polja postoje)                                │
│     - aktivnost (šta je uključeno/isključeno)                       │
│                                                                     │
│  2. PRETVORI U JSON STRING                                          │
│     ─────────────────────                                           │
│     JSON.stringify(db.output) →                                     │
│     '{"Osnovneusluge":{"value":{"IME":"Marko","TELEFON":"033"}}}'   │
│                                                                     │
│  3. POŠALJI NA BACKEND                                              │
│     ─────────────────────                                           │
│     POST /uomback/sui-capture                                       │
│     {                                                               │
│       "ticketId": 12345,        ← ID tiketa                         │
│       "eventData": "...JSON..." ← Spakovani db.output               │
│     }                                                               │
│                                                                     │
│  4. BACKEND SPASI U BAZU                                            │
│     ─────────────────────                                           │
│     Tabela SUI_CAPTURE:                                             │
│     ┌──────────┬─────────────────────────────────────────┐          │
│     │ ticketId │ eventData                               │          │
│     ├──────────┼─────────────────────────────────────────┤          │
│     │ 12345    │ {"Osnovneusluge":{"value":{...}}}       │          │
│     └──────────┴─────────────────────────────────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Zašto Ovo Radi?

```
ZATO ŠTO output.value POKAZUJE NA ISTI OBJEKAT KAO model!

Kada zovemo JSON.stringify(db.output):
  → Ulazi u db.output
  → Nalazi output.value
  → output.value pokazuje na db.model
  → Čita SVE IZ db.model (uključujući korisničke unose)
  → Pretvara u string

REZULTAT: Sve što je korisnik upisao je spakovano!
```

---

## F4. LOAD GAME - loadSuicapture()

Sada učitavamo spašeno stanje.

```
┌─────────────────────────────────────────────────────────────────────┐
│  KORISNIK PONOVO OTVORI ISTI TIKET                                  │
│                                                                     │
│  loadSuicapture() radi sljedeće:                                    │
│                                                                     │
│  1. DOHVATI IZ BAZE                                                 │
│     ─────────────────────                                           │
│     GET /uomback/sui-capture?ticketId=12345                         │
│     → Vraća: '{"Osnovneusluge":{"value":{"IME":"Marko",...}}}'      │
│                                                                     │
│  2. PRETVORI NAZAD U OBJEKAT                                        │
│     ─────────────────────                                           │
│     JSON.parse(eventData) →                                         │
│     { Osnovneusluge: { value: { IME: "Marko", TELEFON: "033" } } }  │
│                                                                     │
│  3. POSTAVI U db.output                                             │
│     ─────────────────────                                           │
│     db.output = parsiraniObjekat                                    │
│                                                                     │
│  4. KOPIRAJ VRIJEDNOSTI U db.model                                  │
│     ─────────────────────                                           │
│     Za svako polje u output.value:                                  │
│       db.model.IME = output.Osnovneusluge.value.IME                 │
│       db.model.TELEFON = output.Osnovneusluge.value.TELEFON         │
│       ...                                                           │
│                                                                     │
│  5. ANGULAR AUTOMATSKI AŽURIRA FORMU                                │
│     ─────────────────────                                           │
│     Pošto je <input [(ngModel)]="db.model.IME">                     │
│     i db.model.IME sada ima vrijednost "Marko"                      │
│     → Input polje prikazuje "Marko"                                 │
│                                                                     │
│  REZULTAT: Forma izgleda IDENTIČNO kao kad je korisnik spasio!      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## F5. JEDNOSTAVNA ANALOGIJA: Knjiga Gostiju

```
┌─────────────────────────────────────────────────────────────────────┐
│  ZAMISLITE HOTEL SA KNJIGOM GOSTIJU                                 │
│                                                                     │
│  1. NOVA REZERVACIJA (getDynamic)                                   │
│     ────────────────────────────                                    │
│     Recepcioner otvara prazan formular:                             │
│     "Ime: _____, Prezime: _____, Soba: _____"                       │
│                                                                     │
│     Ali već zna neke podatke o gostu (iz baze):                     │
│     "Ime: Marko, Prezime: Marković, Soba: _____"                    │
│                                                                     │
│  2. GOST POPUNJAVA (korisnik unosi)                                 │
│     ────────────────────────────                                    │
│     Gost odabere sobu 305.                                          │
│     Formular sada: "Ime: Marko, Prezime: Marković, Soba: 305"       │
│                                                                     │
│  3. KNJIGA GOSTIJU - SAVE (saveSuicapture)                          │
│     ────────────────────────────                                    │
│     Recepcioner prepiše formular u Knjigu Gostiju:                  │
│     Strana 12345: "Marko Marković, Soba 305"                        │
│                                                                     │
│  4. GOST SE VRATI - LOAD (loadSuicapture)                           │
│     ────────────────────────────                                    │
│     Gost se vrati za godinu dana.                                   │
│     Recepcioner otvori Knjigu Gostiju, strana 12345.                │
│     Prepopuni formular: "Ime: Marko, Prezime: Marković, Soba: 305"  │
│                                                                     │
│     Gost vidi: "Opa, sjećaju se moje omiljene sobe!"                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## F6. ZAŠTO "REFERENCE" A NE KOPIRANJE?

Ovo je najvažniji dio za razumjeti.

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRIMJER SA SVAKODNEVNOG ŽIVOTA                                     │
│                                                                     │
│  KOPIRANJE (loše):                                                  │
│  ═════════════════                                                  │
│  Imaš bilješku na frižideru: "Kupi mlijeko"                         │
│  Napraviš FOTOKOPIJU i staviš u torbu.                              │
│  Ako neko promijeni bilješku na frižideru na "Kupi hljeb",          │
│  tvoja kopija u torbi DALJE PIŠE "Kupi mlijeko"!                    │
│                                                                     │
│  Problem: Informacije nisu sinhronizovane.                          │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  REFERENCA (kako mi radimo):                                        │
│  ════════════════════════════                                       │
│  Imaš bilješku na frižideru: "Kupi mlijeko"                         │
│  Staviš papirić u torbu: "Pogledaj frižider"                        │
│  Ako neko promijeni bilješku na frižideru na "Kupi hljeb",          │
│  ti pogledaš frižider i vidiš "Kupi hljeb"!                         │
│                                                                     │
│  Prednost: Uvijek imaš najnoviju informaciju.                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

U KODU:

  // KOPIRANJE (loše):
  db.output.value = { IME: db.model.IME };  // Kopira vrijednost
  // Ako se db.model.IME promijeni, db.output.value.IME OSTAJE STARO

  // REFERENCA (kako mi radimo):
  db.output.value = db.model;  // POKAZUJE na isti objekat
  // Ako se db.model.IME promijeni, db.output.value.IME SE AUTOMATSKI PROMIJENI
  // Jer je TO ISTI OBJEKAT!
```

---

## F7. DIJAGRAM: KOMPLETAN TOK (Jednostavno)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  1. OTVORI FORMU                                                            │
│     ════════════                                                            │
│     [Korisnik klikne] → getDynamic() → Backend vraća strukturu              │
│                                              │                              │
│                                              ▼                              │
│                              ┌───────────────────────────────┐              │
│                              │  "Trebaš polja: IME, PREZIME" │              │
│                              └───────────────────────────────┘              │
│                                              │                              │
│                                              ▼                              │
│  2. NACRTAJ FORMU                                                           │
│     ═════════════                                                           │
│     Za svako polje:                                                         │
│       - Izvrši SQL za početnu vrijednost                                    │
│       - Napravi <input> povezan sa db.model                                 │
│       - Napravi referencu u db.output → db.model                            │
│                                              │                              │
│                                              ▼                              │
│  3. KORISNIK POPUNJAVA                                                      │
│     ═════════════════════                                                   │
│     Korisnik tipka → db.model se mijenja → db.output automatski vidi        │
│                                              │                              │
│                                              ▼                              │
│  4. SAVE (saveSuicapture)                                                   │
│     ═════════════════════                                                   │
│     Uzmi db.output → JSON.stringify → Pošalji na backend → Spasi u bazu     │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════    │
│                                                                             │
│  5. LOAD (loadSuicapture) - Kasnije                                         │
│     ══════════════════════════════════                                      │
│     Dohvati iz baze → JSON.parse → Postavi u db.output i db.model           │
│                                              │                              │
│                                              ▼                              │
│     Angular vidi promjenu db.model → Automatski ažurira input polja         │
│                                              │                              │
│                                              ▼                              │
│     Forma izgleda isto kao kada je spašena!                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## F8. CHECKLIST: Šta Junior Treba Zapamtiti

```
┌─────────────────────────────────────────────────────────────────────┐
│  ✅ KLJUČNE STVARI ZA ZAPAMTITI                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. TRI KUTIJE:                                                     │
│     □ db.model  → Ovdje su vrijednosti koje korisnik unosi          │
│     □ db.output → Ovdje je struktura za slanje na backend           │
│     □ db.params → Ovdje su konstante (CA_ID, BA_ID...)              │
│                                                                     │
│  2. REFERENCA, NE KOPIJA:                                           │
│     □ db.output.value POKAZUJE na db.model                          │
│     □ Promjena u db.model automatski vidljiva u db.output           │
│                                                                     │
│  3. getDynamic():                                                   │
│     □ Dohvata strukturu forme sa backenda                           │
│     □ Backend kaže koja polja postoje i kako popuniti početne       │
│                                                                     │
│  4. saveSuicapture():                                               │
│     □ Uzima db.output (koji pokazuje na db.model)                   │
│     □ Pretvara u JSON string                                        │
│     □ Šalje na backend za čuvanje                                   │
│                                                                     │
│  5. loadSuicapture():                                               │
│     □ Dohvata JSON string iz baze                                   │
│     □ Pretvara nazad u objekat                                      │
│     □ Postavlja vrijednosti u db.model                              │
│     □ Angular automatski ažurira formu                              │
│                                                                     │
│  6. ngModel BINDING:                                                │
│     □ [(ngModel)]="db.model.IME" znači:                             │
│       - Prikaži vrijednost db.model.IME u inputu                    │
│       - Kada korisnik tipka, ažuriraj db.model.IME                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## F9. NAJČEŠĆE GREŠKE I KAKO IH IZBJEĆI

```
┌─────────────────────────────────────────────────────────────────────┐
│  ❌ GREŠKA 1: Misliti da se vrijednosti kopiraju                     │
│  ─────────────────────────────────────────────────────────────────  │
│  POGREŠNO: "db.output ima kopiju vrijednosti"                       │
│  ISPRAVNO: "db.output.value POKAZUJE na db.model, isti objekat"     │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  ❌ GREŠKA 2: Ne razumjeti redoslijed                                │
│  ─────────────────────────────────────────────────────────────────  │
│  POGREŠNO: "Prvo nacrtaj formu, pa dohvati strukturu"               │
│  ISPRAVNO: "Prvo dohvati strukturu, pa nacrtaj formu na osnovu nje" │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  ❌ GREŠKA 3: Miješati model i params                                │
│  ─────────────────────────────────────────────────────────────────  │
│  POGREŠNO: "P_CA_ID je u db.model"                                  │
│  ISPRAVNO: "P_CA_ID je u db.params - to su PARAMETRI, ne unos"      │
│            "FIRSTNAME je u db.model - to KORISNIK POPUNJAVA"        │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  ❌ GREŠKA 4: Ne razumjeti JSON.stringify                            │
│  ─────────────────────────────────────────────────────────────────  │
│  JSON.stringify PRATI REFERENCE!                                    │
│  Kada stringify-uješ db.output, on ulazi u output.value,            │
│  vidi da pokazuje na db.model, i stringify-uje TAJ objekat.         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## F10. PRAKTIČNI PRIMJER: Korak Po Korak

```
┌─────────────────────────────────────────────────────────────────────┐
│  SCENARIO: Marko otvara tiket, popunjava formu, spašava,            │
│            sutradan nastavlja                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  DAN 1 - 10:00 - OTVARANJE                                          │
│  ═════════════════════════════                                      │
│  Marko klikne "Novi tiket" za kupca Ivana (CA_ID: 12345)            │
│                                                                     │
│  → getDynamic() pozvan                                              │
│  → Backend vraća: "Trebaš polja: IME, PREZIME, TELEFON"             │
│  → Angular crta formu                                               │
│  → SQL upiti popune: IME="Ivan", PREZIME="Horvat"                   │
│  → Forma prikazuje:                                                 │
│    ┌──────────────────────────────────────┐                         │
│    │  Ime:     [ Ivan    ]                │                         │
│    │  Prezime: [ Horvat  ]                │                         │
│    │  Telefon: [         ]   ← PRAZNO     │                         │
│    └──────────────────────────────────────┘                         │
│                                                                     │
│  DAN 1 - 10:05 - POPUNJAVANJE                                       │
│  ═══════════════════════════════                                    │
│  Marko upiše telefon: "091-234-5678"                                │
│                                                                     │
│  → Korisnik tipka u <input>                                         │
│  → ngModel ažurira: db.model.TELEFON = "091-234-5678"               │
│  → db.output.value automatski ima istu vrijednost                   │
│    (jer pokazuje na db.model)                                       │
│                                                                     │
│  DAN 1 - 10:10 - SAVE                                               │
│  ═══════════════════════                                            │
│  Marko klikne "Spasi" jer mora ići na pauzu                         │
│                                                                     │
│  → saveSuicapture() pozvan                                          │
│  → Uzima db.output                                                  │
│  → JSON.stringify pretvori u:                                       │
│    '{"Osnovneusluge":{"value":{"IME":"Ivan","PREZIME":"Horvat",     │
│      "TELEFON":"091-234-5678"}}}'                                   │
│  → Pošalje na backend                                               │
│  → Backend spasi u tabelu SUI_CAPTURE                               │
│                                                                     │
│  DAN 2 - 09:00 - LOAD                                               │
│  ════════════════════════                                           │
│  Marko ponovo otvori isti tiket                                     │
│                                                                     │
│  → loadSuicapture() pozvan                                          │
│  → Dohvati iz baze: '{"Osnovneusluge":{"value":{...}}}'             │
│  → JSON.parse pretvori nazad u objekat                              │
│  → Postavi u db.model:                                              │
│    db.model.IME = "Ivan"                                            │
│    db.model.PREZIME = "Horvat"                                      │
│    db.model.TELEFON = "091-234-5678"                                │
│  → Angular detektuje promjenu                                       │
│  → Forma automatski prikaže:                                        │
│    ┌──────────────────────────────────────┐                         │
│    │  Ime:     [ Ivan        ]            │                         │
│    │  Prezime: [ Horvat      ]            │                         │
│    │  Telefon: [ 091-234-5678]   ← SAČUVANO!                        │
│    └──────────────────────────────────────┘                         │
│                                                                     │
│  Marko: "Super, sve je tu! Mogu nastaviti gdje sam stao."           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## F11. ZAKLJUČAK

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  SUICAPTURE U JEDNOJ REČENICI:                                      │
│  ═════════════════════════════                                      │
│  "Spašava kompletno stanje forme (db.output koji pokazuje na        │
│   db.model) u bazu kao JSON string, i vraća ga nazad kad treba."    │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  ZAŠTO RADI EFIKASNO:                                               │
│  ════════════════════                                               │
│  - Reference umjesto kopiranja = manje memorije, uvijek ažurno      │
│  - JSON stringify/parse = jednostavno spašavanje/učitavanje         │
│  - Angular ngModel = automatsko ažuriranje UI-a                     │
│                                                                     │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                     │
│  KADA BI NEŠTO POŠLO PO ZLU:                                        │
│  ═══════════════════════════                                        │
│  - Ako bi referenca bila prekinuta → save bi spasio stare podatke   │
│  - Ako bi JSON bio korumpiran → load bi pukao                       │
│  - Ako bi db.model bio prazan pri save → spasili bismo praznu formu │
│                                                                     │
│  Ali pošto je sve ispravno povezano - RADI!                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

*Ažurirano: 2026-02-04*
*Sekcija C: Detaljna Analiza Suicapture Requesta Sa Stvarnim Podacima*
*Sekcija D: Jednostavno Objašnjenje Sa Analogijom*
*Sekcija E: Od getDynamic() Do Korisničkog Unosa - Detaljni Tok*
*Sekcija F: Pojednostavljeno Objašnjenje Za Junior Programere*
