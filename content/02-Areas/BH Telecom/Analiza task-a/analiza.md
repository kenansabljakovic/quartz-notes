 ULTRA-DETALJNA ANALIZA: /uomback/suicapture

  SADRŽAJ

  1. #1-arhitektura-sistema
  2. #2-inicijalizacija-komponente
  3. #3-kako-se-gradi-dbmodel
  4. #4-kako-se-gradi-dboutput
  5. #5-kako-se-gradi-structure
  6. #6-transformacija-podataka-za-slanje
  7. #7-http-poziv-i-wrapper
  8. #8-učitavanje-sačuvanog-stanja

  ---
  1. ARHITEKTURA SISTEMA

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

  ---
  2. INICIJALIZACIJA KOMPONENTE

  2.1 Kada korisnik otvori URL

  // evidencija-usluge.component.ts - ngOnInit()

```js
  ngOnInit() {
    // KORAK 1: Inicijaliziraj prazne objekte
    this.basket = {};                    // Prazna korpa
    this.assignObjects();                // Resetuj stanje
    this.setcustomeraccounts();          // Popuni ca, ba, sa iz SharedDataService
```
    // KORAK 2: Pretplati se na URL query parametre
    this.subscribtion = this.route.queryParams.subscribe((params: Params) => {
      Object.assign(this, params);       // params → this.processId, this.basketnum, itd.
      this.params = params;
    });

    // KORAK 3: Pretplati se na URL route parametre
    this.route.params.subscribe((params: Params) => {
      Object.assign(this, params);       // params → this.offerId, this.specId, this.type
    });

    // KORAK 4: Ako postoji basketnum, učitaj sačuvano stanje
    if (this.basketnum) {
      this.loadDynamicData();            // GET /uomback/suicapture/ordnum
    } else {
      this.getDynamic('validateinformations');  // GET /pcrt/order-entry (nova forma)
    }
  }

  2.2 assignObjects() - Resetiranje stanja

  assignObjects() {
    this.Dependency.clear();             // Očisti dependency manager
    this.structure = {};                 // Očisti strukturu forme

    this.db                              // Model servis
      .clear(['active', 'activechild'])  // Obriši active i activechild
      .assign("model", { auto: {} })     // Inicijaliziraj model sa auto objektom
      .assign("output")                  // Inicijaliziraj prazan output
      .assign("params")                  // Inicijaliziraj prazne params
      .assign("valid", {                 // Inicijaliziraj validaciju
        name: "evidencija",
        active: true,
        valid: true,
        errors: 0,
        children: {}
      });
  }

  Rezultat nakon assignObjects():
  this.db = {
    model: { auto: {} },      // Za auto-popunjene vrijednosti
    output: {},               // Za strukturiranu reprezentaciju forme
    params: {},               // Za parametre forme
    valid: {                  // Za validaciono stanje
      name: "evidencija",
      active: true,
      valid: true,
      errors: 0,
      children: {}
    }
  }

  2.3 setcustomeraccounts() - Popunjavanje računa

  setcustomeraccounts() {
    // Iz SharedDataService dohvati korisničke podatke koji su prethodno selektovani

    // Customer Account (CA) - glavni korisnik
    this.ca = !this.ca.id && Object.assign({},
      this.sharedData.customer.customerGeneralInfo.id
        ? this.sharedData.customer.customerGeneralInfo
        : {}
    );

    // Billing Account (BA) - račun za naplatu
    this.ba = !this.ba.id && Object.assign({},
      this.sharedData.customer.customerBillInfo || {}
    );

    // Event Source (ES) - izvor eventa
    this.es = !this.es.id && Object.assign({},
      this.sharedData.customer.eventSourceInfo || {}
    );

    // Service Account (SA) - servisni račun
    this.sa = this.sharedData.customer.saInfo || {};

    // Specijalni slučajevi za BAGG i SAGG (agregacija)
    if (this.sharedData.customer.baggInfo.id) {
      this.bagg = this.ba = this.sharedData.customer.baggInfo;
    }
    if (this.sharedData.customer.saggInfo.id) {
      this.sagg = this.sa = this.sharedData.customer.saggInfo;
    }
  }

  SharedDataService.customer struktura:
  // sharedData.service.ts linija 47
  customer: any = {
    show: 1,
    customerBlock: {},
    contactInfo: {},
    addressInfo: [],
    customerGeneralInfo: {        // ← this.ca dolazi odavde
      billingAccount: {},
      billingAccounts: []
    },
    customerBillInfo: {},         // ← this.ba dolazi odavde
    saInfo: {},                   // ← this.sa dolazi odavde
    eventSourceInfo: {},          // ← this.es dolazi odavde
    customerNames: {},
    saggInfo: {},                 // ← this.sagg (agregacija)
    baggInfo: {},                 // ← this.bagg (agregacija)
    saList: []
  };

  ---
  3. KAKO SE GRADI db.model

  3.1 Učitavanje dinamičke forme

  getDynamic(callback?: any) {
    // Postavi mod (new/edit/preview/disabled)
    this.db.setmod(this.ordnum, this.basketnum, this.ca.id, this.ba.id, ...);

    // Dohvati strukturu forme sa backenda
    this.api.get('/pcrt/order-entry', {
      interactionId: 16,
      productOfferId: this.offerId,      // npr. "1174"
      productSpecificationId: this.specId, // npr. "162"
      appProcessId: this.processId,       // npr. "10"
      setupType: this.setupType
    }).subscribe((r: RestPayload) => {
      this.structure = r.payload;         // ← JSON struktura forme

      // Spoji parametre
      this.db.update(this.db.params,
        Object.assign(
          Object.assign(this.structure.parameters, this.params),
          this.setparms()
        )
      );
    });
  }

  Primjer this.structure (sa backenda):
  {
    "parameters": {
      "P_MAIN_OFFER_ID": "1174"
    },
    "structure": [
      {
        "name": "osnovni_podaci",
        "label": "Osnovni podaci",
        "template": "basic_block",
        "businessClassification": "SPECIFICATION",
        "elements": [
          {
            "name": "broj_telefona",
            "label": "Broj telefona",
            "template": "input",
            "elementType": "text",
            "businessClassification": "Attribute",
            "validation": { "mandatory": true, "maxlength": 20 },
            "value": { "defaultValue": "" }
          }
        ]
      }
    ],
    "validation": []
  }

  3.2 Kako ContentLoader popunjava db.model

  Svaki element forme prolazi kroz ContentLoaderComponent:

  // contentloader.component.ts

  ngOnInit(){
    // 1. Aktiviraj element ako je validan
    this.items.active = this.items.active != undefined ? this.items.active : true;

    // 2. Postavi parent-child vezu
    this.db.set(this.model, this.parent, this.pname);

    // 3. Postavi parametre
    this.setParametars();

    // 4. Registriraj zavisnosti (dependency)
    this.Depedency.set(this.items, this.model);

    // 5. Postavi početnu vrijednost u model
    // ValueManager.set() popunjava this.model[items.name]
    this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);

    // 6. Generiši indeks za output
    this.getIndexName();

    // 7. KRITIČNO: Registriraj element u db.output
    this.db.setoutput(this.items, this.model, this.output, this.index);

    // 8. Postavi validaciju
    this.Validation.set(this.items, this.valid, this.vparent, this.index, this.db.mod);
  }

  3.3 ValueManager.set() - Postavljanje početne vrijednosti

  // value.manager.ts

  public set(el: InputObject, model: any, parameters?: any, mod: string = 'new') {
    // Ako element ima externalAPI, dohvati djecu
    !el.externalAPI || ['disabled', 'preview'].indexOf(mod) >= 0
      || this.setChildren(el, model, parameters);

    // Ako element ima poruke, prikaži ih
    !el.externalMessages || !el.externalMessages.length
      || this.setmessages(el, model, parameters);

    // Za radio/select ili ako vrijednost nije definirana
    if (['radio', 'select'].indexOf(el.template) >= 0 || model[el.name] === undefined) {

      if (model[el.name] === undefined) {
        // Pokušaj: autoincrement → mappingRef → defaultValue
        this.autoincrement(el, model, parameters)
          || this.setValueByRefOrCode(el, model, parameters)
          || this.setDefaultValue(el, model);
      }

      // Ako ima generationFormula, izvrši je
      this[this.declare(el.value.generationFormula)](
        el, el.value.generationFormula, model, parameters, ...
      );

      // Ako ima lookupStatement (SQL), izvrši ga
      this[this.declare(el.value.lookupStatement)](
        el, el.value.lookupStatement, model, parameters, ...
      );
    }
  }

  3.4 Kako korisnikov unos ažurira db.model

  Template koristi two-way binding:

  <!-- input.template.html -->
  <input
    [(ngModel)]="model[items.name]"   <!-- ← Two-way binding -->
    (change)="Depedency.depend(items.dname);"
    (focusout)="Validation.validate(items, parameters);"
  />

  Tok podataka:
  Korisnik upiše "061123456" u input polje
           ↓
  [(ngModel)]="model[items.name]"
           ↓
  model["broj_telefona"] = "061123456"
           ↓
  this.db.model["broj_telefona"] = "061123456"  (jer model === db.model)
           ↓
  (change) trigger → Depedency.depend() → Ažurira zavisna polja

  Primjer db.model nakon korisnikovog unosa:
  this.db.model = {
    auto: {
      // Auto-popunjene vrijednosti
    },
    broj_telefona: "061123456",
    ime_prezime: "Marko Marković",
    email: "marko@email.com",
    paket: "PAKET_100",
    // ... ostala polja forme
  }

  ---
  4. KAKO SE GRADI db.output

  4.1 Model.setoutput() - Registracija u output strukturu

  // model.service.ts

  public setoutput(el: InputObject, model: any, output: any, index: string) {
    el.output = output[index] = output[index]
      ? Object.assign(output[index], {
          name: el.name,
          code: el.code,
          value: !el.export || model
        })
      : {
          attr: {},                           // Atributi (child elementi)
          items: {},                          // Items (ponude)
          spec: {},                           // Specifikacije
          name: el.name,                      // Ime elementa
          code: el.code,                      // Kod elementa
          value: !el.export || model,         // Referenca na model objekt
          active: el.initActivity,            // Da li je aktivan
          calss: el.businessClassification,   // "Attribute", "OFFER", "SPECIFICATION"
          businessParams: el.businessParams,  // Poslovni parametri
          label: el.label,                    // Labela
          elementType: el.elementType,        // "text", "select", "checkbox"
          dataReference: el.dataReference     // Referenca na podatke
        };
  }

  4.2 Struktura db.output

  Hijerarhijska struktura:
  this.db.output = {
    // SPECIFIKACIJA (wrapper za grupu elemenata)
    "osnovni_podaci": {
      name: "osnovni_podaci",
      code: "SPEC_001",
      calss: "SPECIFICATION",
      active: true,
      label: "Osnovni podaci",

      attr: {
        // ATRIBUTI unutar specifikacije
        "broj_telefona": {
          name: "broj_telefona",
          code: "ATT_001",
          calss: "Attribute",
          active: true,
          label: "Broj telefona",
          elementType: "text",
          value: { broj_telefona: "061123456" },  // ← Referenca na model
          // attvalue se dodaje kasnije tokom handleOutput()
        },
        "ime_prezime": {
          name: "ime_prezime",
          code: "ATT_002",
          calss: "Attribute",
          value: { ime_prezime: "Marko Marković" },
        }
      },

      items: {
        // PONUDE (offers) unutar specifikacije
        "paket_internet": {
          name: "paket_internet",
          code: "1234",
          calss: "OFFER",
          active: true,
          label: "Internet paket",

          attr: {
            // Atributi ponude
            "brzina": {
              name: "brzina",
              code: "ATT_SPEED",
              calss: "Attribute",
              value: { brzina: "100" }
            }
          },

          items: {
            // Child ponude
          }
        }
      },

      spec: {
        // Child specifikacije
      }
    }
  }

  4.3 setOutput() i handleOutput() - Priprema za slanje

  // evidencija-usluge.component.ts

  setOutput() {
    // 1. Deep copy db.output (da ne mutiramo original)
    let output: DynamicOutput = JSON.parse(JSON.stringify(this.db.output));

    // 2. Transformiraj strukturu
    this.handleOutput(output);

    return output;
  }

  handleOutput(output: DynamicOutput) {
    for (let item in output) {
      // Rekurzivno procesiraj nested strukture
      this.handleOutput(output[item].attr);
      this.handleOutput(output[item].items);
      this.handleOutput(output[item].spec);

      // Za ATRIBUTE: konvertuj value objekt u attvalue string
      if (output[item].calss === "Attribute" && output[item].value) {
        // value: { broj_telefona: "061123456" }
        // → attvalue: "061123456"
        output[item].attvalue = output[item].value[output[item].name] || null;
      }

      // Obriši value objekt (nije potreban za backend)
      delete output[item].value;
    }
  }

  Prije handleOutput():
  {
    "broj_telefona": {
      name: "broj_telefona",
      calss: "Attribute",
      value: { broj_telefona: "061123456" },  // ← Interno predstavljanje
    }
  }

  Poslije handleOutput():
  {
    "broj_telefona": {
      name: "broj_telefona",
      calss: "Attribute",
      attvalue: "061123456",  // ← Spremno za backend
      // value je obrisano
    }
  }

  ---
  5. KAKO SE GRADI structure

  5.1 Komponente structure objekta

  // saveSuicapture() - linija 277

  structure: JSON.stringify({
    ca: this.ca,             // Customer Account
    ba: this.ba,             // Billing Account
    sa: this.sa,             // Service Account
    contact: this.contact,   // Kontakt
    ocontact: this.ocontact, // Drugi kontakt
    basket: this.basket,     // Korpa
    hasitems: this.hasitems  // Flag
  })

  5.2 Detaljna struktura svakog objekta

  this.ca (Customer Account):
  this.ca = {
    id: 130025794,
    status: "A",
    activationdate: "2026-01-30T09:12:31.000",
    customerstypeCode: "1000",
    customertypeCode: "100",
    customertypeName: "Fizičko lice",
    mainlocationId: 2,
    mainlocationName: "Direkcija Sarajevo",
    pCaId: 130025794,

    customerinfo: {
      birthdate: "2026-01-19",
      firstname: "JNF-8241",
      lastname: "130025794 - JNF-8241 JNF-8241",
      genderCode: "M"
    },

    contacts: [
      {
        id: 45112814,
        firstname: "JNF-8241 JNF-8241",
        email: "omar.bilalovic@gmail.com",
        mobilephone: "061/677889"
      }
    ],

    addresses: [
      {
        id: 21177314,
        townName: "GRAD SARAJEVO",
        addressname: "24 Juni",
        houseno: "234",
        zipCode: "71000"
      }
    ],

    customeridents: [
      {
        identtypeCode: "SCHOOL",
        identno: "119955"
      }
    ],

    groupedByTechnology: [
      {
        billingAccounts: [
          { id: 330021716, customerName: "JNF-8241-B", ... }
        ]
      }
    ]
  }

  this.basket (Korpa):
  this.basket = {
    id: 257461,
    basketnum: "257459-01/26",
    headbasketnum: "257459/26",
    statusName: "U pripremi",
    cacustomerId: 130025794,
    bacustomerId: 330021716,
    acontactId: 45112814,
    saleslocationId: 2,
    salesslocationId: 24,
    description: "Opis zahtjeva",
    expecteddate: "2026-02-15",
    comments: "Komentar",
    baskettypeCode: "NEW",
    basketatts: [
      { attname: "PRODUCTOFFER_ID", attvalue: "1174" },
      { attname: "SPECIFICATION_ID", attvalue: "162" },
      { attname: "PROCESS_ID", attvalue: "10" }
    ]
  }

  ---
  6. TRANSFORMACIJA PODATAKA ZA SLANJE

  6.1 saveSuicapture() - Kompletna funkcija

  saveSuicapture() {
    // KORAK 1: Kreiraj JSON objekt za slanje
    let jsonSetup = {

      // A) Entry parametri - identifikacija forme
      entryParams: JSON.stringify({
        processId: this.processId,                 // "10"
        offerId: this.offerId,                     // "1174"
        specId: this.specId,                       // "162"
        appProcessId: this.appProcessId,           // undefined ili vrijednost
        orderEntrySetupRequests: this.orderEntrySetupRequests,  // za grupne zahtjeve
        productOfferId: this.productOfferId,
        productSpecificationId: this.productSpecificationId
      }),

      // B) Model - stanje forme
      model: JSON.stringify({
        model: this.db.model,      // { auto: {}, broj_telefona: "061123456", ... }
        output: this.setOutput()   // Transformirana output struktura
      }),

      // C) Structure - kontekst korisnika/računa
      structure: JSON.stringify({
        ca: this.ca,               // Kompletan CA objekt
        ba: this.ba,               // Kompletan BA objekt
        sa: this.sa,               // SA objekt
        contact: this.contact,     // Kontakt
        ocontact: this.ocontact,   // Drugi kontakt
        basket: this.basket,       // Korpa
        hasitems: this.hasitems    // true/false
      }),

      // D) Ključ za dohvatanje
      ordnum: this.basket.basketnum  // "257459-01/26"
    };

    // KORAK 2: Pošalji na backend
    this.api.post('/uomback/suicapture', jsonSetup).subscribe();
  }

  6.2 Dijagram transformacije

  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │                        KOMPONENTA (VpnEvidencijaUslugeComponent)                │
  │                                                                                 │
  │  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐               │
  │  │  this.processId │   │  this.db.model  │   │    this.ca      │               │
  │  │  this.offerId   │   │  this.db.output │   │    this.ba      │               │
  │  │  this.specId    │   │                 │   │    this.basket  │               │
  │  └────────┬────────┘   └────────┬────────┘   └────────┬────────┘               │
  │           │                     │                     │                        │
  │           ▼                     ▼                     ▼                        │
  │  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐               │
  │  │ JSON.stringify  │   │   setOutput()   │   │ JSON.stringify  │               │
  │  │                 │   │   handleOutput()│   │                 │               │
  │  └────────┬────────┘   └────────┬────────┘   └────────┬────────┘               │
  │           │                     │                     │                        │
  │           ▼                     ▼                     ▼                        │
  │       entryParams            model                structure                    │
  │       (string)              (string)              (string)                     │
  │                                                                                 │
  │  ┌─────────────────────────────────────────────────────────────────────────┐   │
  │  │                           jsonSetup                                      │   │
  │  │  {                                                                       │   │
  │  │    entryParams: "{\"processId\":\"10\",\"offerId\":\"1174\",...}",      │   │
  │  │    model: "{\"model\":{\"auto\":{},\"broj_telefona\":\"061123456\"}...}",│   │
  │  │    structure: "{\"ca\":{\"id\":130025794,...},\"basket\":{...}}",       │   │
  │  │    ordnum: "257459-01/26"                                                │   │
  │  │  }                                                                       │   │
  │  └────────────────────────────────────┬────────────────────────────────────┘   │
  │                                       │                                        │
  └───────────────────────────────────────┼────────────────────────────────────────┘
                                          │
                                          ▼
                           ┌──────────────────────────────┐
                           │   this.api.post(...)         │
                           └──────────────┬───────────────┘
                                          │
                                          ▼

  ---
  7. HTTP POZIV I WRAPPER

  7.1 RestApiService.post()

  // rest.api.service.ts

  post(path: string, data: any): Observable<RestPayload> {
    return this.http.post(
      path,                              // "/uomback/suicapture"
      this.setEntity(data),              // ← WRAPPING
      this.options                       // Headers: Content-Type: application/json
    ).map((response: Response) => {
      return <RestPayload>response.json();
    }).catch((error: Response) => {
      this.handleError(error);
      this.message.error(error.json().message);
      this.spinner.hide();
      return Observable.throw(error.statusText);
    });
  }

  7.2 setEntity() - Wrapper funkcija

  // rest.api.service.ts - linija 106-108

  private setEntity(data: any) {
    return {
      languageId: 0,     // Hardkodirano
      channel: '',       // Hardkodirano prazno
      entity: data       // ← Tvoji podaci idu ovdje
    };
  }

  7.3 Finalna struktura HTTP requesta

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

  7.4 Zašto .subscribe() bez handlera?

  this.api.post('/uomback/suicapture', jsonSetup).subscribe();
  //                                               ↑
  //                                        Nema success/error handlera

  Razlozi:
  1. Fire-and-forget - Ne čeka se odgovor
  2. Background persisting - Stanje se spašava u pozadini
  3. Nije kritično - Ako ne uspije, korisnik može ponovo spasiti
  4. Performance - Ne blokira UI dok čeka response

  ---
  8. UČITAVANJE SAČUVANOG STANJA

  8.1 loadDynamicData() - Detaljna analiza

  loadDynamicData() {
    // GET request na backend
    this.api.get('/uomback/suicapture/ordnum', { ordnum: this.basketnum })
      .subscribe((r: RestPayload) => {

        // Ako nema podataka, učitaj svježu formu
        if (!r.payload) return this.getDynamic();

        // ═══════════════════════════════════════════════════════════════
        // KORAK 1: Vrati stanje forme (model i output)
        // ═══════════════════════════════════════════════════════════════
        Object.assign(this.db, JSON.parse(r.payload.model));
        // r.payload.model = '{"model":{"auto":{},"broj_telefona":"061123456"},"output":{...}}'
        // Poslije: this.db.model = { auto: {}, broj_telefona: "061123456", ... }
        // Poslije: this.db.output = { ... }

        // ═══════════════════════════════════════════════════════════════
        // KORAK 2: Vrati entry parametre
        // ═══════════════════════════════════════════════════════════════
        Object.assign(this, JSON.parse(r.payload.entryParams));
        // r.payload.entryParams = '{"processId":"10","offerId":"1174","specId":"162"}'
        // Poslije: this.processId = "10"
        // Poslije: this.offerId = "1174"
        // Poslije: this.specId = "162"

        // ═══════════════════════════════════════════════════════════════
        // KORAK 3: Vrati kontekst korisnika/računa
        // ═══════════════════════════════════════════════════════════════
        Object.assign(this, JSON.parse(r.payload.structure));
        // r.payload.structure = '{"ca":{...},"ba":{...},"basket":{...}}'
        // Poslije: this.ca = { id: 130025794, ... }
        // Poslije: this.ba = { id: 330021716, ... }
        // Poslije: this.basket = { basketnum: "257459-01/26", ... }
        // Poslije: this.hasitems = true

        // ═══════════════════════════════════════════════════════════════
        // KORAK 4: Sinhronizuj sa SharedDataService
        // ═══════════════════════════════════════════════════════════════
        Object.assign(this.sharedData.customer.customerGeneralInfo, this.ca);
        Object.assign(this.sharedData.customer.customerBillInfo, this.ba);
        Object.assign(this.sharedData.customer.eventSourceInfo, this.es);
        this.sharedData.caId = this.ca.pCaId;

        // ═══════════════════════════════════════════════════════════════
        // KORAK 5: Učitaj dinamičku strukturu forme
        // ═══════════════════════════════════════════════════════════════
        this.getDynamic();      // GET /pcrt/order-entry
        this.handleFlow(this.hasitems);  // Omogući/onemogući korake
      });

    return true;
  }

  8.2 Dijagram učitavanja

  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │                         KORISNIK OTVARA URL SA basketnum                        │
  │                                                                                 │
  │  URL: /evidencija/residential/1174/162/0?basketnum=257459-01/26&...             │
  └────────────────────────────────────────┬────────────────────────────────────────┘
                                           │
                                           ▼
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │  ngOnInit() → this.basketnum = "257459-01/26" → loadDynamicData()               │
  └────────────────────────────────────────┬────────────────────────────────────────┘
                                           │
                                           ▼
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │  GET /uomback/suicapture/ordnum?ordnum=257459-01/26                             │
  │                                                                                 │
  │  Response:                                                                      │
  │  {                                                                              │
  │    "payload": {                                                                 │
  │      "model": "{\"model\":{...},\"output\":{...}}",                            │
  │      "entryParams": "{\"processId\":\"10\",...}",                              │
  │      "structure": "{\"ca\":{...},\"ba\":{...},\"basket\":{...}}"               │
  │    }                                                                            │
  │  }                                                                              │
  └────────────────────────────────────────┬────────────────────────────────────────┘
                                           │
           ┌───────────────────────────────┼───────────────────────────────┐
           │                               │                               │
           ▼                               ▼                               ▼
  ┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
  │  JSON.parse(model)  │     │JSON.parse(entryPar.)│     │JSON.parse(structure)│
  │         │           │     │         │           │     │         │           │
  │         ▼           │     │         ▼           │     │         ▼           │
  │  Object.assign(     │     │  Object.assign(     │     │  Object.assign(     │
  │    this.db, ...)    │     │    this, ...)       │     │    this, ...)       │
  │                     │     │                     │     │                     │
  │  Rezultat:          │     │  Rezultat:          │     │  Rezultat:          │
  │  this.db.model = {} │     │  this.processId=10  │     │  this.ca = {...}    │
  │  this.db.output = {}│     │  this.offerId=1174  │     │  this.ba = {...}    │
  │                     │     │  this.specId=162    │     │  this.basket = {...}│
  └─────────────────────┘     └─────────────────────┘     └─────────────────────┘
           │                               │                               │
           └───────────────────────────────┼───────────────────────────────┘
                                           │
                                           ▼
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │  Sinhronizacija sa SharedDataService:                                           │
  │                                                                                 │
  │  sharedData.customer.customerGeneralInfo ← this.ca                              │
  │  sharedData.customer.customerBillInfo ← this.ba                                 │
  │  sharedData.caId ← this.ca.pCaId                                                │
  └────────────────────────────────────────┬────────────────────────────────────────┘
                                           │
                                           ▼
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │  getDynamic() → GET /pcrt/order-entry                                           │
  │                                                                                 │
  │  Učitava JSON strukturu forme sa backenda                                       │
  │  Dinamički kreira input polja na osnovu strukture                               │
  │  Polja se populiraju vrijednostima iz this.db.model                             │
  └────────────────────────────────────────┬────────────────────────────────────────┘
                                           │
                                           ▼
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │                    FORMA JE PRIKAZANA SA SAČUVANIM STANJEM                      │
  │                                                                                 │
  │  ┌─────────────────────────────────────────────────────────────────────────┐   │
  │  │  Broj telefona: [ 061123456        ]  ← Vrijednost iz db.model          │   │
  │  │  Ime i prezime: [ Marko Marković   ]  ← Vrijednost iz db.model          │   │
  │  │  Email:         [ marko@email.com  ]  ← Vrijednost iz db.model          │   │
  │  │                                                                          │   │
  │  │  Customer: JNF-8241 (130025794)       ← Vrijednost iz this.ca           │   │
  │  │  Billing:  JNF-8241-B (330021716)     ← Vrijednost iz this.ba           │   │
  │  │  Basket:   257459-01/26               ← Vrijednost iz this.basket       │   │
  │  └─────────────────────────────────────────────────────────────────────────┘   │
  │                                                                                 │
  └─────────────────────────────────────────────────────────────────────────────────┘

  ---
  REZIME - KOMPLETAN ŽIVOTNI CIKLUS

  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │                              ŽIVOTNI CIKLUS SUICAPTURE                          │
  ├─────────────────────────────────────────────────────────────────────────────────┤
  │                                                                                 │
  │  1. NOVI ZAHTJEV (bez basketnum)                                                │
  │     ├─→ ngOnInit()                                                              │
  │     ├─→ assignObjects() → Inicijalizuj db.model = { auto: {} }                  │
  │     ├─→ setcustomeraccounts() → Popuni ca, ba, sa iz SharedDataService          │
  │     ├─→ getDynamic() → GET /pcrt/order-entry                                    │
  │     └─→ Prikaži praznu formu                                                    │
  │                                                                                 │
  │  2. KORISNIK POPUNJAVA FORMU                                                    │
  │     ├─→ [(ngModel)] → db.model["polje"] = vrijednost                            │
  │     ├─→ ContentLoader.setoutput() → Registruj u db.output                       │
  │     └─→ Dependency/Validation → Ažuriraj zavisna polja                          │
  │                                                                                 │
  │  3. KORISNIK KLIKNE SPREMI                                                      │
  │     ├─→ save() → saveBasket()                                                   │
  │     ├─→ POST /uomback/basket/save                                               │
  │     ├─→ saveSuicapture()                                                        │
  │     │   ├─→ entryParams = JSON.stringify({ processId, offerId, specId })        │
  │     │   ├─→ model = JSON.stringify({ model: db.model, output: setOutput() })    │
  │     │   ├─→ structure = JSON.stringify({ ca, ba, basket, ... })                 │
  │     │   └─→ POST /uomback/suicapture { entity: jsonSetup }                      │
  │     └─→ validateAndSave() / saveItem() → Spremi stavke                          │
  │                                                                                 │
  │  4. KORISNIK SE VRATI (sa basketnum)                                            │
  │     ├─→ ngOnInit() → basketnum postoji                                          │
  │     ├─→ loadDynamicData()                                                       │
  │     │   ├─→ GET /uomback/suicapture/ordnum?ordnum=basketnum                     │
  │     │   ├─→ JSON.parse(model) → Object.assign(db, ...)                          │
  │     │   ├─→ JSON.parse(entryParams) → Object.assign(this, ...)                  │
  │     │   └─→ JSON.parse(structure) → Object.assign(this, ...)                    │
  │     ├─→ getDynamic() → Učitaj strukturu forme                                   │
  │     └─→ Forma se prikaže sa sačuvanim vrijednostima                             │
  │                                                                                 │
  └─────────────────────────────────────────────────────────────────────────────────┘