# Sales Catalog — How It Works

Detaljno objašnjenje toka podataka od klika na "Osnovne usluge" do prikazivanja kataloga ponuda.

---

## Korak 1 — Backend vraća meni stablo

```typescript
// jpp.layout.component.ts:37
this.api.get('/uaa/user/menu/UOM').subscribe((r: RestPayload) => {
  this.menus = r.payload.children;
  this.crateBreadcrumb(this.menus);
});
```

Svaki put kad se aplikacija učita, `JppLayout` poziva backend:
```
GET /uaa/user/menu/UOM
```

Backend vraća JSON stablo od 13 stavki. Jedna stavka u meniju izgleda ovako (sirovi JSON iz backenda):

```json
{
  "label": "Osnovne usluge",
  "url": "sales/residential",
  "code": "UOM_RESIDENTIAL_SALES",
  "attributes": {
    "clazz": "some-css-class"
  },
  "refParameter3": "{\"processGroupCode\":\"RESIDENTIAL_SALES\",\"r\":[\"ca\",\"ba\"]}",
  "children": null
}
```

**Primjeti:** `refParameter3` je **string** koji izgleda kao JSON — nije objekat, nego tekst u navodnicima.

---

## Korak 2 — `crateBreadcrumb()` parsira `refParameter3`

```typescript
// jpp.layout.component.ts:68
crateBreadcrumb(menu: any[], strings: string[] = []) {
  menu.map((m: any) => {
    m.refParameter3 = m.refParameter3 ? JSON.parse(m.refParameter3) : {};
    //                                   ↑ string → JavaScript objekat
    this.breadcrumbs[m.url] = Object.assign([], strings);
    this.breadcrumbs[m.url].push(m.label);
    return !m.children || this.crateBreadcrumb(m.children, this.breadcrumbs[m.url]);
  });
}
```

`crateBreadcrumb()` radi dvije stvari:

### Parsira `refParameter3`

```javascript
// Prije:
m.refParameter3 = "{\"processGroupCode\":\"RESIDENTIAL_SALES\",\"r\":[\"ca\",\"ba\"]}"

// Nakon JSON.parse():
m.refParameter3 = {
  processGroupCode: "RESIDENTIAL_SALES",
  r: ["ca", "ba"]
}
```

Sada je pravi JavaScript objekat, ne string.

### Gradi `breadcrumbs` mapu

```typescript
this.breadcrumbs[m.url] = Object.assign([], strings);
this.breadcrumbs[m.url].push(m.label);
```

Za svaki URL, pravi niz labela koji čini putanju u meniju:
```javascript
this.breadcrumbs["sales/residential"] = ["Rezidentalne usluge", "Osnovne usluge"]
```

> **Trap za juniora:** Ako više stavki menija ima isti `url`, posljednja `breadcrumb` prepiše prethodnu. Zato breadcrumb za ovaj URL može biti netačan.

Nakon ovoga, objekat iz memorije izgleda:
```javascript
{
  label: "Osnovne usluge",
  url: "sales/residential",
  code: "UOM_RESIDENTIAL_SALES",
  attributes: { clazz: "some-css-class" },
  refParameter3: {                        // ← sad je objekat
    processGroupCode: "RESIDENTIAL_SALES",
    r: ["ca", "ba"]
  },
  children: null
}
```

---

## Korak 3 — Korisnik klikne na "Osnovne usluge"

Korisnik vidi stavku u meniju i klikne. Angular pozove `selectMenu(item)` gdje je `item` taj objekat gore.

```typescript
// menu.component.ts:25
selectMenu(item) {
```

**Šta je `item` u ovom trenutku:**
```javascript
item = {
  label: "Osnovne usluge",
  url: "sales/residential",
  code: "UOM_RESIDENTIAL_SALES",
  attributes: { clazz: "some-css-class" },
  refParameter3: { processGroupCode: "RESIDENTIAL_SALES", r: ["ca","ba"] }
}
```

### A) Brisanje starih podataka

```typescript
this.sharedData.customer = {
  show: 1,
  customerBlock: {},
  contactInfo: {},
  addressInfo: {},
  customerGeneralInfo: { billingAccounts: [] },
  customerBillInfo: {},
  saInfo: {},
  eventSourceInfo: {},
  customerNames: {},
  saggInfo: {},
  baggInfo: {},
  saList: []
};

this.sharedData.clearBasket();   // briše korpu s narudžbama
this.sharedData.clearItems();    // briše odabrane stavke
this.search.clearAllData();      // resetuje search bar
this.sharedData.clearAllData();  // briše ostale podatke
this.sharedData.block = '';      // blok = koji nivo hijerarhije je aktivan
this.sharedData.statusCode = null;
this.scc.clear();                // poziva SalesCatalogComponent.clear()
```

`SharedDataService` je **singleton servis** — postoji samo jedna instanca, svi je koriste. Kada se resetuje, svi koji je čitaju vide prazan whiteboard.

### B) Pakovanje `queryParams`

```typescript
let queryParams: any = {};
queryParams = Object.assign(queryParams, item.refParameter3, { 'orderTypeName': item.label });
```

`Object.assign(target, source1, source2)` kopira sve propertije iz sources u target.

```javascript
// Počinjemo prazno:
queryParams = {}

// Copy item.refParameter3:
queryParams = { processGroupCode: "RESIDENTIAL_SALES", r: ["ca", "ba"] }

// Dodaj { orderTypeName: item.label }:
queryParams = {
  processGroupCode: "RESIDENTIAL_SALES",
  r: ["ca", "ba"],
  orderTypeName: "Osnovne usluge"   // ← frontend ga dodaje sam, nije iz backenda!
}
```

> **Bitna napomena:** `orderTypeName` **ne postoji u bazi**. Frontend ga lijepi iz `item.label`. Ako bugiraš i ne vidiš ga na backendu — to je zato što on samo ide kroz URL na frontendu.

### C) Čuvanje dodatnih podataka

```typescript
if (item.url) { this.sharedData.menuCode = item.code; }
// → this.sharedData.menuCode = "UOM_RESIDENTIAL_SALES"

if (item.url) { this.sharedData.menuClass.emit(item.attributes.clazz); }
// → emituje CSS klasu za promjene u layout-u
```

### D) Navigacija

```typescript
this.router.navigate([item.url || '/'], { queryParams: queryParams });
```

`item.url` je `"sales/residential"`. Angular pretvara ovo u URL:

```
/sales/residential?processGroupCode=RESIDENTIAL_SALES&r=ca&r=ba&orderTypeName=Osnovne%20usluge
```

Primjeti: niz `r=["ca","ba"]` postaje `&r=ca&r=ba` — Angular nizove pretvara u ponavljajuće parametre.

---

## Korak 4 — Angular Router matchuje rutu

```typescript
// app.routes.ts:11
const appRoutes: Routes = [
  { path: 'sales/:type', component: SalesComponent },
  // ...
];
```

Angular čita rutu i traži prvu koja matchuje URL. Path je `/sales/residential`:

```
'sales/:type'  ←→  '/sales/residential'
  'sales'      ←→  'sales'        ✓ literal, mora biti tačno
  ':type'      ←→  'residential'  ✓ wildcard, prihvata bilo šta
```

Angular izvuče route param:
```javascript
params = { type: 'residential' }
```

> **Važno:** `type = 'residential'` se **nigdje aktivno ne koristi** u `SalesComponent`. Router ga pokupi jer ruta to zahtijeva, ali komponenta gleda samo query params. Mogao bi biti bilo koji string.

Angular sada:
1. Uništi prethodnu komponentu u `<router-outlet>`
2. Kreira novu instancu `SalesComponent`
3. Renderuje je u `<router-outlet>` (koji je u `jpp.layout.template.html`)

---

## Korak 5 — `SalesComponent.ngOnInit()` — inicijalizacija

### Šta je SalesComponent?

Pogledaj `sales.template.html`. Stranica je podijeljena na **dva dijela**:

```
┌────────────────────────────────────────────┐
│  [z-col-5] Lijevi panel  [z-col-19] Desni  │
│  Info o korisniku       <sales-catalog>    │
└────────────────────────────────────────────┘
```

Lijevi panel čita iz `sharedData.customer` i prikazuje podatke. Desni panel je `<sales-catalog #child>` — child komponenta.

`#child` je **template reference variable** — omogućava parent-u da direktno poziva metode:

```typescript
@ViewChild('child') public child: SalesCatalogComponent;
// kasnije: this.child.callServiceFromParent('CA');
```

### `ngOnInit()` kod

```typescript
ngOnInit() {
  this.sharedData.clearAllData(); // još jedno čišćenje
```

```typescript
  this.route.queryParams.subscribe((params: Params) => {
```

`this.route` je `ActivatedRoute` servis — daje informacije o trenutnoj ruti. `.queryParams` je Observable koji emituje svaki put kad se query params promijene.

U ovom trenutku, `params` je:
```javascript
params = {
  processGroupCode: "RESIDENTIAL_SALES",
  r: ["ca", "ba"],
  orderTypeName: "Osnovne usluge"
}
```

```typescript
    this.processId = undefined;
    this.processGroupCode = undefined;
```

Resetovanje prije `Object.assign` — ako korisnik klikne na drugi meni (koji nema `processGroupCode`), star `processGroupCode` bi ostao. Eksplicitno brišemo da to ne bi dogođeno.

```typescript
    Object.assign(this, params);
```

Kopira sve query params direktno na komponentu:
```javascript
// Prije: this.processGroupCode = undefined, this.r = undefined, ...
// Nakon: this.processGroupCode = "RESIDENTIAL_SALES", this.r = ["ca","ba"], ...
```

Ovo radi jer komponenta ima `[x: string]: any` — index signature na liniji 69.

```typescript
    Object.assign(this.urlParams, params);
    // Čuva kopiju za kasniju upotrebu (npr. navigacija "Novi zahtjev")
```

```typescript
    ['21','22','23','35','36'].indexOf(this.processId) >= 0
    || ['SME_SERVICES'].indexOf(this.processGroupCode) >= 0
      ? this.isCreatedVisible = false
      : this.isCreatedVisible = true;
```

`this.processId` je `undefined` (nije u params). `this.processGroupCode` je `"RESIDENTIAL_SALES"` (nije `"SME_SERVICES"`).

```javascript
false || false → false → isCreatedVisible = true
```

`isCreatedVisible` kontroliše dugme "Novi zahtjev" — vidljivo je za RESIDENTIAL_SALES.

```typescript
    this.subscribers = this.ms.listen().subscribe((m: any) => { ... });
    // Sluša event bus za komunikaciju s drugim komponentama
  });
}
```

---

## Korak 6 — `SalesCatalogComponent.ngOnInit()` — inicijalizacija child-a

Angular kreira `SalesCatalogComponent` jer je `<sales-catalog>` u template-u. Ovo se dešava **prije** nego što `SalesComponent.ngOnInit()` završi.

### Inicijalizacija

```typescript
ngOnInit() {
  this.activatedRoute.params.subscribe((params: Params) => Object.assign(this, params));
  // Pokupi route params (type="residential") — ali se ne koristi korisno

  this.serviceLevel = 'CA';
  // Default: počinjemo od CA nivoa

  this.childtypeCode = false;
  this.setcustomeraccounts();
  // setcustomeraccounts() pokupi podatke iz sharedData
```

`setcustomeraccounts()`:
```typescript
setcustomeraccounts() {
  this.clearcustomeraccounts(); // ca={}, ba={}, sa={}, es={}, sagg={}, bagg={}

  this.ca = this.sharedData.customer.customerGeneralInfo.id
    ? this.sharedData.customer.customerGeneralInfo
    : {};
  // customerGeneralInfo = { billingAccounts:[] } (resetovano u selectMenu)
  // .id ne postoji → this.ca = {}

  this.ba = this.sharedData.customer.customerBillInfo || {}; // = {}
  // esto su svi {}
}
```

### Subscribe na query params

```typescript
  if (this.sharedData.block) { ... } // sharedData.block = '' → preskočeno

  this.activatedRoute.queryParams.subscribe((params: Params) => {
```

I `SalesComponent` i `SalesCatalogComponent` koriste isti `ActivatedRoute` — oba čuju iste query params!

```typescript
    // Resetovanje
    this.r = [];
    this.messageValid = '';
    this.showService = false;  // ← katalog sakriven
    this.response = [];
    this.tabs = [];
    this.tab = [];
    this.clearcustomeraccounts(); // ca={}, ba={}, ...
    this.processGroupCode = undefined;
    this.processId = undefined;
    this.queryParams = {};       // objekat za backend

    Object.assign(this, params);
    // this.processGroupCode = "RESIDENTIAL_SALES"
    // this.r               = ["ca", "ba"]
    // this.orderTypeName   = "Osnovne usluge"

    this.passParams();
    // passParams() popunjava queryParams s tehnološkim parametrima
    // trenutno svi su prazni jer nema odabranog kupca
```

`passParams()` primjer:
```typescript
passParams() {
  this.queryParams['TECHNOLOGY_CODE'] = ...;
  // Za CA nivo: TECHNOLOGY_CODE = '' (CA nema tehnologiju)
  // Za BA nivo: TECHNOLOGY_CODE = "GSM" ili "FIX"

  this.queryParams['SALESLOCATION_ID'] = ...;
  // Za BA: SALESLOCATION_ID = 5
  // Ostalo: delete
}
```

U ovom trenutku (CA nivo, ništa odabrano): `queryParams = {}`.

```typescript
    Object.assign(this.queryParams,
      this.processGroupCode
        ? { processGroupCode: this.processGroupCode }
        : { processId: this.processId }
    );
    // processGroupCode postoji → queryParams = { processGroupCode: "RESIDENTIAL_SALES" }

    this.queryParams['serviceLevel'] = this.serviceLevel; // = 'CA'
    this.queryParams['groupServicesInd'] = 0;
    // queryParams = {
    //   processGroupCode: "RESIDENTIAL_SALES",
    //   serviceLevel: "CA",
    //   groupServicesInd: 0
    // }

    this.validateinformations();
  });
}
```

---

## Korak 7 — `validateinformations()` — sekvencijalni decision tree

Ovo nije prosta validacija — prolazi kroz šest različitih `else if` grana. Svaka je odvojen poslovni slučaj.

```typescript
validateinformations() {
  this.valid = [];
  this.childtypeCode = false;
  this.wrngMssg = false;

  const basicServiceProcessIds = ['1261', '11', '12', '37', '13'];
```

### Grana 1 — Provjera odabranih nivoa (`r`)

```typescript
  if (this.headCa) { ... } // headCa nije postavljeno → preskačemo

  this.valid = this.r && this.r instanceof Array
    ? this.r.filter((required: string) =>
        !this[required] || !Object.keys(this[required]).length
      )
    : [];
```

`this.r = ["ca", "ba"]` — niz je neprazan → ulazimo u `.filter()`.

Filter prolazi kroz svaki element i **ostavlja** one za koje je uvjet `true` (tj. nisu ispunjeni):

```javascript
// Element: "ca"
required = "ca"
this["ca"]               // → this.ca = {} (prazna postavka)
!this["ca"]              // → !{} → false (objekat je truthy)
Object.keys(this["ca"])  // → [] (nema propertija)
[].length                // → 0
!0                       // → true
// Uvjet: false || true → true → "ca" OSTAJE u nizu (ide u valid)

// Element: "ba"
required = "ba"
this["ba"] = {}          // isto kao gore
// Uvjet: true → "ba" OSTAJE u nizu

this.valid = ["ca", "ba"]  // oboje nedostaje
```

```typescript
  if (this.valid.length || ...) {
    // valid.length = 2 → true
    if (...childtypeCode === 'EMAIL') { ... } // false → preskočeno

    this.messageValid = 'Evidencija nije dozvoljena za ovaj nivo korisnika!';
    // Funkcija završava — ostale grane su else if
  }
  // return (implicitno)
```

Template prikazuje poruku:
```html
<div [ngClass]="wrngMssg ? 'isa_warning' : 'isa_error'"
     *ngIf="valid?.length || !response?.length">
  {{ messageValid }}
  <!-- "Evidencija nije dozvoljena za ovaj nivo korisnika!" -->
</div>
```

Katalog je skrivjen jer `showService = false` i `valid.length > 0`:
```html
<ul *ngIf="showService && !valid.length">   <!-- false && true → false -->
  <!-- ne prikazuje se -->
</ul>
```

---

## Korak 8 — Korisnik pronalazi i odabiera CA

Korisnik upiše ime u search bar. `GSearchService` traži kupce. Korisnik vidi listu i klikne na jednog.

`SalesComponent.getCa(caId)` se poziva, npr. sa `caId = 12345`:

```typescript
getCa(caId, show: boolean = true) {
  if (show) { this.sharedData.block = 'CA'; }
  // block = koji nivo je aktivan

  this.sharedData.customerId = caId; // = 12345

  this.api.get('/ccm/customer/customerBlock-id', { id: caId, offerId: this.ss.offerId })
    .subscribe(results => {
```

HTTP request:
```
GET /ccm/customer/customerBlock-id?id=12345&offerId=...
```

Backend vraća kompletan objekat kupca:
```javascript
results.payload = {
  id: 12345,
  customerinfo: {
    lastname: "Petrović",
    birthdate: "1980-05-15",
    segclassName: "Masovni"
  },
  customertypeCode: "100",  // fizičko lice
  customertypeName: "Fizičko lice",
  groupedByTechnology: [
    { ptechnologyCode: "GSM", pBaId: 67890 },
    { ptechnologyCode: "FIX", pBaId: 67891 }
  ],
  contacts: [...],
  customeridents: [...],
  ccustomergdpr: {
    status: "2",           // potpisan
    bhtMarketing: "1",
    sourceSystem: "JRK_JPP"
  },
  identExp: "1"            // nije istekao
}
```

```typescript
      this.clearData();
      // sharedData.block = 'CA' → briši BA, SA, ES podatke
```

`clearData()`:
```typescript
clearData() {
  switch (this.sharedData.block) {
    case 'CA':
      this.sharedData.customer.customerBillInfo = {};
      this.sharedData.customer.saggInfo = {};
      this.sharedData.customer.baggInfo = {};
      this.sharedData.customer.saInfo = {};
      this.sharedData.customer.eventSourceInfo = {};
      break;
  }
}
```

```typescript
      this.sharedData.customer.customerGeneralInfo = {};
      this.customerGeneralInfo = results['payload'];
      this.search.customer = this.customerGeneralInfo;
      this.sharedData.customerId = this.customerGeneralInfo.id; // = 12345

      Object.assign(this.sharedData.customer.customerGeneralInfo, this.customerGeneralInfo);
      // sharedData sada ima sve CA podatke

      this.billingAccounts = [];
      this.getGeneralCustomerInfoByCaId(caId, false, show);

      if (this.customerGeneralInfo['groupedByTechnology']) {
        for (let i = 0; i < this.customerGeneralInfo['groupedByTechnology'].length; i++) {
          if (this.customerGeneralInfo['groupedByTechnology'][i])
            this.billingAccounts.push(this.customerGeneralInfo['groupedByTechnology'][i]);
        }
        this.sharedData.customer.customerGeneralInfo.billingAccounts = this.billingAccounts;
        // billingAccounts = [
        //   { ptechnologyCode: "GSM", pBaId: 67890 },
        //   { ptechnologyCode: "FIX", pBaId: 67891 }
        // ]
      }

      this.sharedData.caId = this.sharedData.customer.customerGeneralInfo.id; // = 12345
      this.child.callServiceFromParent('CA');  // ← obavijesti child
    });
}
```

**Ključni poziv:** `this.child.callServiceFromParent('CA')` — parent direktno poziva metodu na child-u.

---

## Korak 9 — `callServiceFromParent('CA')`

```typescript
callServiceFromParent(data?: string) {
  // data = 'CA'

  this.clearcustomeraccounts(); // ca={}, ba={}, ...
  this.showService = false;
  this.response = [];
  this.tabs = [];
  this.tab = [];

  if (this.sharedData.customer.customerGeneralInfo.id) {
    // id = 12345 → postoji → ulazimo
```

```typescript
    this.passParams();
    // sharedData.block = 'CA'
    // TECHNOLOGY_CODE = '' (CA nivo nema tehnologiju)

    this.queryParams['serviceLevel'] = data; // = 'CA'
    this.setcustomeraccounts();
```

`setcustomeraccounts()` sada:
```typescript
this.ca = this.sharedData.customer.customerGeneralInfo.id
  ? this.sharedData.customer.customerGeneralInfo
  : {};
// id = 12345 → postoji → this.ca = { id:12345, customerinfo:{...}, ... }

this.ba = this.sharedData.customer.customerBillInfo || {};
// customerBillInfo = {} (obrisan u clearData) → this.ba = {}
```

```typescript
    this.validateinformations();
```

Filter opet:
```javascript
// required = "ca"
this.ca = { id:12345, customerinfo:{...}, ... }
Object.keys(this.ca).length = 8  // ima propertija
!8 → false
// Uvjet: false → "ca" NE ulazi u valid ✓

// required = "ba"
this.ba = {}
Object.keys({}).length = 0
!0 → true
// Uvjet: true → "ba" OSTAJE u valid ✗

this.valid = ["ba"]  // samo BA nedostaje
```

`this.valid.length = 1` → ulazimo u prvu `if` granu:
```javascript
this.messageValid = 'Evidencija nije dozvoljena za ovaj nivo korisnika!';
```

**Rezultat:** Katalog je još uvijek blokiran, ali sada samo zbog nedostajućeg BA.

Template sada prikazuje:
- Lijevi panel: CA podaci (ime, tip, lista BA-ova)
- Desni panel: poruka o blokadi

Korisnik vidi listu BA-ova i može kliknuti na jedan.

---

## Korak 10 — Korisnik odabiera BA

Korisnik vidi listu BA-ova iz `billingAccounts` u template-u. Klikne na npr. GSM BA.

`SalesComponent.showBa()` se poziva:

```typescript
showBa(isVisible = true, id = null, jump = true) {
  this.sharedData.block = 'BA';
  // block = 'BA' → aktivan nivo je BA

  if (this.sharedData.customer.customerBillInfo) {
    this.sharedData.clearIds();
    this.sharedData.customerId = this.sharedData.customer.customerBillInfo.customerId;
    this.sharedData.baCustomerId = this.sharedData.customer.customerBillInfo.id;
  }

  if (id && jump) {
    this.api.get('/ccm/customer/customerBABlock-id', [id])
      .subscribe(results => {
        this.clearData();
        // sharedData.block = 'BA' → briši SA, ES podatke

        this.customerBillInfo = results['payload'];
        // customerBillInfo = {
        //   id: 67890,
        //   ptechnologyCode: "GSM",
        //   saleslocationId: 5,
        //   mainlocationId: 3,
        //   baTerminatedDebt: "1",              // nema duga
        //   baIPA_NATOCertificateRequired: null
        // }

        Object.assign(this.sharedData.customer.customerBillInfo, this.customerBillInfo);
        this.sharedData.baCustomerId = this.customerBillInfo.id; // = 67890
      });
  }

  this.child.callServiceFromParent('BA');  // ← odmah, ne čeka HTTP
  this.sharedData.customer.show = 2;
}
```

> **Bitno:** `callServiceFromParent('BA')` se poziva **odmah**, a HTTP request za BA je async. BA podaci dolaze malo kasnije.

---

## Korak 11 — `callServiceFromParent('BA')` → Sve provjere ok

```typescript
callServiceFromParent(data?: string) {
  // data = 'BA'

  this.clearcustomeraccounts();
  this.setcustomeraccounts();
```

`setcustomeraccounts()` sada:
```javascript
this.ca = { id:12345, customerinfo:{...}, ... }  // CA postoji ✓
this.ba = { id:67890, ptechnologyCode:"GSM", ... }  // BA postoji ✓
```

```typescript
  this.queryParams['serviceLevel'] = data; // = 'BA'
  this.passParams();
  // sharedData.block = 'BA'
  // TECHNOLOGY_CODE = "GSM"
  // SALESLOCATION_ID = 5
  // MAINLOCATION_ID = 3
  // queryParams = {
  //   processGroupCode: "RESIDENTIAL_SALES",
  //   serviceLevel: "BA",
  //   TECHNOLOGY_CODE: "GSM",
  //   SALESLOCATION_ID: 5,
  //   MAINLOCATION_ID: 3,
  //   groupServicesInd: 0
  // }

  this.validateinformations();
```

Filter:
```javascript
// required = "ca" → this.ca nije prazan → false → NE ulazi
// required = "ba" → this.ba nije prazan → false → NE ulazi
this.valid = []  // prazno!
```

`this.valid.length = 0` → preskačemo prvu `if` granu. Prolazimo kroz ostale `else if`:

### Grana 2 — Dug
```typescript
else if (this.sharedData.customer.customerBillInfo.baTerminatedDebt &&
         this.sharedData.customer.customerBillInfo.baTerminatedDebt != '1') {
  // baTerminatedDebt = "1" → uvjet false → preskačemo ✓
}
```

### Grana 3 — IPA/NATO certifikat
```typescript
else if (this.sharedData.customer.customerBillInfo.baIPA_NATOCertificateRequired === '1') {
  // = null → false → preskačemo ✓
}
```

### Grana 4 — GDPR saglasnost
```typescript
else if (this.queryParams['processGroupCode'] === 'RESIDENTIAL_SALES'  // ✓ true
  && customertypeCode === '100'  // fizičko lice ✓ true
  && (!ccustomergdpr || (ccustomergdpr.sourceSystem === 'JRK_JPP' && status !== '2'))) {
  // ccustomergdpr = { status:"2", sourceSystem:"JRK_JPP" }
  // ccustomergdpr.status !== '2' → false
  // Cijeli uvjet: true && true && false → false → preskačemo ✓
}
```

### Grana 5 — Identifikacijski dokument
```typescript
else if (this.sharedData.customer.customerGeneralInfo.identExp &&
         this.sharedData.customer.customerGeneralInfo.identExp != '1') {
  // identExp = "1" → uvjet false → preskačemo ✓
}
```

### Grana 6 — Pravno lice bez ovlaštene osobe
```typescript
else if (customertypeCode === '200' && !contacts.find(...)) {
  // customertypeCode = "100" (fizičko lice) → false → preskačemo ✓
}
```

### Grana 7 — Direktni marketing
```typescript
else if (ccustomergdpr && ccustomergdpr.bhtMarketing == "0") {
  // bhtMarketing = "1" → false → preskačemo ✓
}
```

### Sve prošlo! Ulazimo u `else`
```typescript
else {
  this.queryParams['USER_CODE'] = this.user.get().code;
  // queryParams = {
  //   processGroupCode: "RESIDENTIAL_SALES",
  //   serviceLevel: "BA",
  //   TECHNOLOGY_CODE: "GSM",
  //   SALESLOCATION_ID: 5,
  //   MAINLOCATION_ID: 3,
  //   USER_CODE: "ABC123",
  //   groupServicesInd: 0
  // }

  this.get(this, 'tabs', this.queryParams, this.getTabItem);
}
```

---

## Korak 12 — `get()` — prvi backend poziv za katalog

```typescript
get(obj, index, param, callback) {
  // obj      = this (SalesCatalogComponent)
  // index    = 'tabs'
  // param    = queryParams (gore)
  // callback = this.getTabItem
```

```typescript
  this.spinner.show();

  if (this.sharedData.block == 'CA') {
    this.tab = []; this.tabs = []; this.showService = false;
    return;  // Za CA ne pozivaj backend
  }
  // sharedData.block = 'BA' → nastavljamo

  obj.api.get('/uomback/sales-entry/data', param).subscribe(response => {
```

HTTP request:
```
GET /uomback/sales-entry/data
  ?processGroupCode=RESIDENTIAL_SALES
  &serviceLevel=BA
  &TECHNOLOGY_CODE=GSM
  &SALESLOCATION_ID=5
  &MAINLOCATION_ID=3
  &USER_CODE=ABC123
  &groupServicesInd=0
```

Backend vraća listu **kategorija ponuda**:
```javascript
response.payload = [
  {
    name: "Internet",
    icon: "fa fa-wifi",
    levelId: 1,
    levelName: "categoryId",
    key: "101",
    resultType: null
  },
  {
    name: "Telefon",
    icon: "fa fa-phone",
    levelId: 1,
    levelName: "categoryId",
    key: "102",
    resultType: null
  },
  // ...
]
```

```typescript
    obj[index] = response['payload'];
    // this['tabs'] = response.payload
    // this.tabs = [...kategorije...]

    this.response = obj[index];

    if (callback && obj[index].length > 0) {
      callback(obj[index][0], obj);
      // getTabItem({ name:"Internet", levelId:1, key:"101", ... }, this)
      // Automatski otvori prvu kategoriju

      this.showService = true;  // ← template se otključava!
    }
```

---

## Korak 13 — `getTabItem()` — drugi backend poziv za ponude

```typescript
getTabItem(tab: any, obj?: SalesCatalogComponent) {
  // tab = { name:"Internet", levelId:1, levelName:"categoryId", key:"101" }

  obj.query = {
    levelId: tab.levelId,   // = 1
    categoryId: tab.key     // = "101"
  };
  Object.assign(obj.query, obj.queryParams);
  // obj.query = {
  //   levelId: 1,
  //   categoryId: "101",
  //   processGroupCode: "RESIDENTIAL_SALES",
  //   serviceLevel: "BA",
  //   TECHNOLOGY_CODE: "GSM",
  //   ...
  // }

  if (obj.sharedData.customer.customerGeneralInfo.id)
    obj.queryPlaceHolder['p_CA_ID'] = 12345;

  if (obj.sharedData.customer.customerBillInfo.id)
    obj.queryPlaceHolder['p_BA_ID'] = 67890;

  Object.assign(obj.query, obj.queryPlaceHolder);

  obj.get(obj, 'tab', obj.query);
  // Drugi poziv: GET /uomback/sales-entry/data?levelId=1&categoryId=101&p_CA_ID=12345&...
```

Backend vraća konkretne **ponude** u kategoriji "Internet":
```javascript
response.payload = [
  {
    name: "BH Net Standard",
    code: "BHN_STD",
    productOfferId: 5001,
    specificationId: 3001,
    price: "15.00"
  },
  // ...
]
```

```typescript
this.tab = [...ponude...]  // prikazuje se u template-u
```

---

## Krajnji rezultat — Template prikazuje katalog

```javascript
// showService = true ✓
// valid.length = 0 ✓
// tabs = [Internet, Telefon, ...]
// tab = [BH Net Standard, ...]
```

Template se otključava:
```html
<!-- Tabovi kategorija su vidljivi -->
<ul *ngIf="showService && !valid.length">
  <li *ngFor="let tab of tabs; let i=index"
      (click)="active=i; getTab(tab);">
    <i class="{{tab.icon}}"></i> {{tab.name}}
  </li>
</ul>

<!-- Katalog ponuda je vidljiv -->
<child-menu *ngIf="showService && !valid.length && response.length"
  [tabs]="tab" [query]="query">
</child-menu>
```

---

## Vizualni sažetak cijelog toka

```
Backend: GET /uaa/user/menu/UOM
  ↓ (vrača JSON stablo menija)
  ↓ crateBreadcrumb() parsira refParameter3 iz stringa u objekat
  ↓
Korisnik klikne "Osnovne usluge"
  ↓
selectMenu(item) → Object.assign(refParameter3 + orderTypeName) → queryParams
  ↓
router.navigate(['sales/residential'], { queryParams })
  ↓ URL: /sales/residential?processGroupCode=RESIDENTIAL_SALES&r=ca&r=ba&...
  ↓
Angular Router matchuje 'sales/:type' → kreira SalesComponent
  ↓
SalesComponent.ngOnInit()
  Object.assign(this, queryParams)
  this.processGroupCode = "RESIDENTIAL_SALES", this.r = ["ca","ba"]
  ↓
SalesCatalogComponent.ngOnInit() (automatski kreirano)
  Object.assign(this, queryParams)
  queryParams = { processGroupCode:"RESIDENTIAL_SALES", serviceLevel:"CA", groupServicesInd:0 }
  validateinformations() → valid = ["ca","ba"] → BLOKIRAN
  ↓
Korisnik pronalazi CA (id=12345)
  ↓
getCa(12345) → HTTP → sharedData.customer.customerGeneralInfo = { id:12345, ... }
  ↓
child.callServiceFromParent('CA')
  validateinformations() → valid = ["ba"] → JOŠ BLOKIRAN
  ↓
Korisnik odabiera BA (id=67890, GSM)
  ↓
showBa(true, 67890) → HTTP → sharedData.customer.customerBillInfo = { id:67890, ... }
  ↓
child.callServiceFromParent('BA')
  queryParams dobija TECHNOLOGY_CODE="GSM", SALESLOCATION_ID=5, ...
  validateinformations() → valid = [] → SVE PROVJERE OK
  ↓
GET /uomback/sales-entry/data?processGroupCode=...&serviceLevel=BA&TECHNOLOGY_CODE=GSM&...
  ↓ (vrača kategorije: Internet, Telefon, ...)
  ↓
getTabItem(tabs[0]) → automatski otvori prvu kategoriju
  ↓
GET /uomback/sales-entry/data?levelId=1&categoryId=101&p_CA_ID=12345&p_BA_ID=67890&...
  ↓ (vrača ponude u toj kategoriji)
  ↓
showService = true → KATALOG VIDLJIV
  ↓
Template prikazuje tabove kategorija i katalog ponuda
```

---

## Ključne lekcije

| Koncept | Zašto je bitno |
|---------|---|
| `refParameter3` je JSON string | Mora se parsirati u `crateBreadcrumb()`, nije automatski objekat |
| `orderTypeName` kreira frontend | Nije iz baze, samo putuje kroz URL na frontendu |
| `Object.assign(this, params)` | Kopira sve query params direktno na komponentu — Power & Danger |
| `SharedDataService` je singleton | Svi ga koriste, resetovanje vidljivo svima |
| `setcustomeraccounts()` + `validateinformations()` | Svaki put kad korisnik odabere nivo, ova dva se pozivaju redom |
| `valid` niz filtrira nedostajuće nivoe | `r=["ca","ba"]` znači "CA i BA moraju biti odabrani" |
| Parent poziva `child.callServiceFromParent()` | Parent direktno kontroliše child logiku, ne kroz evente |
| Multiple HTTP poziva | Prvo kategorije, zatim ponude u kategoriji — kaskadni zahtjevi |
| `showService = true` otključava template | Svi `*ngIf` zavise od ovoga |
