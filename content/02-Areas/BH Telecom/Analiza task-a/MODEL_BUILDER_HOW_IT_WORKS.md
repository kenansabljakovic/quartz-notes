# Model Builder Library - Kompletno objašnjenje

## Analogija: Fabrika automobila

Zamisli Angular aplikaciju kao **fabriku automobila** koja ima mnogo radnika (komponenti) koji rade na traci. Svaki radnik ima svoju specifičnu ulogu:
- Jedan čita nacrte (struktura iz backend-a)
- Drugi uzima dijelove sa police (API pozivi za vrijednosti)
- Treći sastavlja motor (model objekat)
- Četvrti lijepi naljepnice (output objekat)

Problem: ovi radnici žive SAMO unutar fabrike (Angular). Ne možeš ih izvući van i pitati "hej, za ovaj nacrt, šta bi dobio na kraju?".

**Model Builder je robot koji radi isti posao kao svi ti radnici zajedno**, ali van fabrike. Daš mu nacrt, on sam ode po dijelove, sam sastavlja, i vrati ti gotov proizvod.

---

## Šta Angular radi (originalni proces)

### Korak 1: Dohvati strukturu

Kada korisnik otvori formu u Angular-u, aplikacija pozove backend:

```
GET /pcrt/order-entry?interactionId=16&productOfferId=5919&productSpecificationId=979&appProcessId=10
```

Backend vrati ogromnu JSON strukturu - to je "nacrt" forme. Izgleda otprilike ovako:

```json
{
  "parameters": { "P_OFFER_ID": "5919", "..." : "..." },
  "structure": [
    {
      "name": "FlatpaketiPOTS",
      "template": "default_block",
      "businessClassification": "SPECIFICATION",
      "actions": [ { "name": "loadOffer979", "template": "select", "..." : "..." } ],
      "elements": [
        {
          "name": "FlatBHTelecom",
          "template": "basic_block",
          "businessClassification": "OFFER",
          "code": "5919",
          "inputs": [ { "name": "FIRSTNAME" }, { "name": "NAME" } ],
          "elements": [
            { "name": "Budenje", "template": "CheckboxAD" },
            { "name": "Preuzimanja", "template": "default_block" }
          ],
          "children": []
        }
      ]
    }
  ]
}
```

Ovo je **stablo** — svaki element može imati `inputs`, `elements`, `children`, `actions`, `messages`. Svaki od tih pod-nizova sadrži nove elemente koji opet mogu imati svoje pod-nizove. Rekurzija.

### Korak 2: Angular kreira komponente rekurzivno

Angular ovu strukturu pretvara u **stablo komponenti**:

```
ContentLoader (FlatpaketiPOTS)
  └─ DLContent → DefaultBlock
       ├─ ContentLoader (loadOffer979)          ← action
       └─ ContentLoader (FlatBHTelecom)         ← element
            └─ DLContent → BasicBlock
                 ├─ ContentLoader (FIRSTNAME)   ← input
                 ├─ ContentLoader (NAME)        ← input
                 ├─ ContentLoader (Budenje)     ← element (CheckboxAD)
                 └─ ContentLoader (Preuzimanja) ← child
                      └─ DLContent → DefaultBlock
                           └─ ...
```

**Analogija**: Zamisli ruske babuške (matrjoške). Svaka komponenta otvara sebe i unutar sebe kreira manje komponente. Svaka manja opet kreira još manje. I tako do dna.

### Korak 3: Svaka ContentLoader komponenta radi istu sekvencu

Kada se ContentLoader kreira (Angular lifecycle: `ngOnInit`), uvijek radi iste korake, redom:

```typescript
// contentloader.component.ts - ngOnInit()

// 1. Postavi active (default true)
this.active = this.items.active !== undefined ? this.items.active : true;

// 2. Poveži parametre sa parent lancem
this.items.parameters = { ...this.items.parameters, parent: () => this.parameters };

// 3. Pozovi ValueManager da popuni vrijednost
this.vm.set(this.items, this.model, this.items.parameters, this.mode);
//   ↑ OVO je async - poziva API-je, čeka odgovore, popunjava model

// 4. Izračunaj index za output
this.index = this.getIndexName();

// 5. Kreiraj output entry
this.db.setoutput(this.items, this.model, this.output, this.index);
```

**Analogija**: Svaki radnik na traci ima istu check-listu. Bez obzira da li sastavlja volan ili retrovizor, uvijek: (1) provjeri je li aktivan, (2) pogleda od koga je dobio materijal, (3) naruči potrebne dijelove, (4) zapiše šta je napravio.

### Korak 4: ValueManager popunjava model

ValueManager (`value.manager.ts`) je najkompleksniji servis. On odlučuje KAKO popuniti `model[name]`:

```
Za element "FIRSTNAME":
  1. Ima li externalAPI? → NE
  2. Ima li externalMessages? → NE
  3. Model[FIRSTNAME] === undefined? → DA, treba popuniti
     a. Autoincrement? → NE
     b. MappingRef? → NE
     c. DefaultValue? → NE
     d. GenerationFormula? → DA!
        "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#, #:P_CA_ID#, 'FIRSTNAME') from dual"
        → Parsira SQL, zamijeni #:P_CA_ID# sa 130025794
        → Pošalje na backend: GET /uomback/common/lookupStatement?method=select...
        → Backend vrati "JNF-8241"
        → model["FIRSTNAME"] = "JNF-8241"
```

**Analogija**: ValueManager je kao Google Maps navigacija. Treba stići do cilja (popuniti model[name]). Prvo proba najkraći put (defaultValue). Ako taj ne postoji, proba alternativni (mappingRef). Ako ni to, naruči Uber (API poziv). Uvijek nađe put do vrijednosti.

### Korak 5: Block komponente kreiraju hijerarhiju u modelu

Kada se kreira `DefaultBlock` ili `BasicBlock`, njihov `ngOnInit` radi:

```typescript
// basicblock.component.ts / defaultblock.component.ts
if (!this.model[this.items.name]) {
  this.model[this.items.name] = {};
}
```

To znači: za element "FlatBHTelecom" kreira se `model["FlatBHTelecom"] = {}`. Svi inputi tog bloka (FIRSTNAME, NAME, Budenje...) idu u taj pod-objekat.

### Korak 6: KRITIČNA razlika između block tipova

Ovo je bila **najteža** stvar za shvatiti i glavna greška u prvim verzijama.

Dva tipa blokova prosljeđuju model djeci NA RAZLIČITE NAČINE:

**default_block** (SPECIFICATION — npr. "FlatpaketiPOTS", "Preuzimanja"):
```html
<!-- defaultblock.template.html -->
<z-contentloader *ngFor="let element of items.elements"
    [model]="model"              ← ISTI model kao roditelj (FLAT)
    [parent]="parent"
    [output]="output.items">
</z-contentloader>
```

**basic_block** (OFFER — npr. "FlatBHTelecom"):
```html
<!-- basicblock.template.html -->
<div *ngIf="output.active">      ← SAMO ako je aktivan!
  <z-contentloader *ngFor="let element of items.elements"
      [model]="model[items.name]"  ← UGNIJEŽĐENI model (NESTED)
      [parent]="model"
      [output]="output.items">
  </z-contentloader>
</div>
```

**Analogija**: Zamisli firmu sa kancelarijama.

- `default_block` je kao **otvoreni office** — svi rade za istim stolom. Kada neko napiše nešto, svi vide. `model` je zajednički sto.
- `basic_block` je kao **zasebna kancelarija** — kreira se novi sto (`model["FlatBHTelecom"] = {}`), i svi unutar te kancelarije pišu na TAJ sto.

Rezultat u modelu:
```javascript
model = {
  auto: {},
  FlatpaketiPOTS: {},       // default_block kreira {}, ali NE stavlja djecu ovdje
  loadOffer979: "5919",     // ← na ISTOM nivou jer je dijete default_block-a
  FlatBHTelecom: {          // basic_block kreira {} i stavlja SVU djecu UNUTRA
    FIRSTNAME: "JNF-8241",
    NAME: "JNF-8241",
    Budenje: false,
    Preuzimanja: {},
  }
}
```

### Korak 7: Output struktura

Paralelno sa modelom, gradi se `output` objekat koji čuva METAPODATKE:

```javascript
output = {
  FlatpaketiPOTS: {
    attr: {},
    items: {
      FlatBHTelecom: {
        attr: {
          FIRSTNAME: { name: "FIRSTNAME", active: true, elementType: "text", attvalue: "JNF-8241" },
          NAME:      { name: "NAME",      active: true, elementType: "text", attvalue: "JNF-8241" }
        },
        items: {
          Budenje: { name: "Budenje", active: false, elementType: "CheckboxAD" }
        },
        spec: {
          Preuzimanja: { ... }
        }
      }
    },
    spec: {}
  }
}
```

Svaka vrsta djece ide u RAZLIČITI pod-objekat output-a:
- `inputs`   → `output.attr`
- `elements` → `output.items`
- `children` → `output.spec`
- `actions` i `messages` → `{}` (ne čuvaju se u output-u)

---

## Šta Model Builder radi (naš port)

### Fajl po fajl

#### 1. `types.ts` — Interfejsi

```
Angular izvor: src/app/z-dynamic/interfaces/data.value.interface.ts
```

Definira tipove podataka. Najvažniji je `InputObject` — to je jedan element iz strukture:

```typescript
export interface InputObject {
  name: string;            // "FIRSTNAME", "Budenje", "FlatBHTelecom"
  code: string;            // "FIRSTNAME", "2246", "5919"
  template: string;        // "text", "select", "CheckboxAD", "basic_block", "default_block"
  elementType: string;     // "text", "select", "CheckboxAD", "loadElements"
  active: boolean;         // Da li je element aktivan
  value: InputValue;       // { defaultValue, generationFormula, lookupStatement, autoincrement }
  mappingRef: string;      // Reference na drugu vrijednost (npr. "external.P_CA_ID")
  inputs: InputObject[];   // Pod-elementi: atributi
  elements: InputObject[]; // Pod-elementi: glavni elementi
  children: InputObject[]; // Pod-elementi: specifikacije
  actions: InputObject[];  // Pod-elementi: akcije (select dropdown-i)
  messages: InputObject[]; // Pod-elementi: validacione poruke
}
```

**Analogija**: Ovo je "nacrt" jednog dijela. Kaže ti kako se zove, koji tip je, i koji pod-dijelovi postoje.

---

#### 2. `http-client.ts` — HTTP komunikacija

```
Angular izvor: src/app/z-dynamic/services/rest.api.service.ts
               src/app/z-dynamic/services/apicall.dispatcher.ts
```

U Angular-u, HTTP pozivi prolaze kroz dva servisa. Mi smo to zamijenili jednom klasom sa native `fetch()`:

```typescript
export class HttpClient {
  // GET sa query parametrima
  async get(path: string, params?: any): Promise<any> {
    const url = this.baseUrl + path + '?' + this.toQueryString(params);
    const response = await fetch(url, { headers: this.getHeaders() });
    const data = await response.json();
    return data.payload !== undefined ? data.payload : data;
  }

  // POST sa JSON tijelom (entity wrapping kao Angular)
  async post(path: string, body: any): Promise<any> {
    const wrapped = { languageId: 0, channel: '', entity: body };
    // ...
  }

  // dispatch() — detektuje metod iz path-a:
  // "POST@/some/path" → POST, "/some/path" → GET (default)
  async dispatch(apiQuery: any): Promise<any> { ... }
}
```

**Ključno otkriće**: Angular-ov `ApiDispatcher` koristi GET kao default. Koristili smo POST za `lookupStatement`, što je vraćalo `405 Method Not Allowed` (285 grešaka!).

**Analogija**: HttpClient je kao poštanski servis. Angular ima svog dostavljača (Angular Http). Mi smo zaposlili novog (fetch), ali mora da nosi iste koverte (headers, Cookie) na iste adrese.

---

#### 3. `api-call-parse.ts` — Parsiranje SQL-a i API poziva

```
Angular izvor: src/app/z-dynamic/services/apicall.parse.service.ts
```

Pretvara šablone u stvarne API pozive. Formula u JSON-u izgleda ovako:

```
"select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#, #:P_CA_ID#, 'FIRSTNAME') from dual"
```

ApiCallParse zamjenjuje markere stvarnim vrijednostima:
- `#:P_CA_ID#` → traži u parametrima → `130025794`
- `$:FIELD`    → traži u modelu

Najvažnija metoda `getElementParamVal()` penje uz `parent()` lanac tražeći parametar:

```typescript
getElementParamVal(params, paramName) {
  // Pogledaj u params
  // Ako nema, pozovi params.parent() i pogledaj tamo
  // Ako ni tamo nema, pozovi parent().parent() ...
  // Sve do korijena
}
```

**Analogija**: Zamisli da pitaš šefa za broj telefona klijenta. Ako tvoj šef ne zna, on pita SVOG šefa. I tako dalje do direktora. `parent()` lanac je hijerarhija šefova.

---

#### 4. `auto-increment.ts` — Brojač

```
Angular izvor: src/app/z-dynamic/services/auto.increment.service.ts
```

Neki elementi dobijaju sekvencijalni broj. Kao brojač na blagajni:

```typescript
export class AutoIncrement {
  set(name: string, start: number) { ... }
  increment(name: string): number { return this.counters[name]++; }
}
```

---

#### 5. `output-builder.ts` — Kreiranje output strukture

```
Angular izvor: src/app/z-dynamic/services/model.service.ts → setoutput()
```

**setOutput()** — kreira ili ažurira output entry za element:
```typescript
function setOutput(el, model, output, index) {
  el.output = output[index] = output[index]
    ? Object.assign(output[index], { name, code, value })
    : {
        attr: {}, items: {}, spec: {},
        name: el.name,
        code: el.code,
        active: el.initActivity,
        calss: el.businessClassification,  // "calss" nije typo — tako je u originalu!
        label: el.label,
        elementType: el.elementType,
      };
}
```

**setModelParent()** — linkovati parent lanac (parent je FUNKCIJA da izbjegne circular ref u JSON):
```typescript
function setModelParent(item, parent, pname) {
  Object.assign(item, { parent: () => parent });
}
```

**Analogija**: `setOutput` je kao popunjavanje formulara za svaki dio na traci. Zapisuješ: "ovo je FIRSTNAME, tip je text, aktivan je, pripada grupi Attribute".

---

#### 6. `value-resolver.ts` — Srce sistema (async port ValueManager-a)

```
Angular izvor: src/app/z-dynamic/services/value.manager.ts
```

Najkompleksniji fajl. U Angular-u, ValueManager koristi `subscribe()` callback-e. Mi smo SVE zamijenili sa `await`:

**Angular (originalno)**:
```typescript
dblookup(el, formula, model, params) {
  this.apiDispatcher.set({ method: '/uomback/common/lookupStatement', ... })
    .call()
    .subscribe(response => {        // ← callback, ne čeka
      this.setvalue(el, model, params, response);
    });
}
```

**Naš port**:
```typescript
async dblookup(el, formula, model, params) {
  const response = await this.httpClient.get('/uomback/common/lookupStatement', {
    method: apiQuery
  });                                // ← await, čeka odgovor
  this.setvalue(el, model, params, response);
}
```

Glavna metoda `set()` odlučuje KOJI izvor vrijednosti da koristi, po prioritetu:

```
set(el, model, parameters, mode):
  1. externalAPI?      → dohvati child strukturu (el.elements = response)
  2. externalMessages? → dohvati validacione poruke
  3. Treba li vrijednost?
     a. autoincrement?      → model[name] = counter++
     b. mappingRef?         → model[name] = vrijednost iz drugog polja
     c. defaultValue?       → model[name] = el.value.defaultValue
     d. generationFormula?  → await API poziv → model[name] = response
     e. lookupStatement?    → await DB lookup → model[name] = response
```

---

#### 7. `structure-processor.ts` — Mozak sistema

```
Angular izvor: contentloader.component.ts + defaultblock.component.ts
               + basicblock.component.ts + njihovi template-ovi
```

U Angular-u, rekurziju obavljaju TRI komponente koje se međusobno kreiraju. Mi smo to zamijenili JEDNOM klasom sa tri metode.

##### processElement() — zamjena za ContentLoader.ngOnInit()

```typescript
async processElement(item, model, output, parameters, parent, pname) {
  // 1. Validacija datuma
  if (!this.valueResolver.isValid(item)) return;

  // 2. Postavi active (null i undefined → true)
  item.active = (item.active !== undefined && item.active !== null) ? item.active : true;

  // 3. Poveži parent lanac
  setModelParent(model, parent, pname);
  item.parameters = { ...item.parameters, parent: () => parameters };

  // 4. Pozovi ValueManager.set() — popunjava model[name]
  await this.valueResolver.set(item, model, item.parameters, this.mode);

  // 5. Izračunaj index i kreiraj output entry
  const index = this.getIndexName(item, model, parent, pname);
  setOutput(item, model, output, index);

  // 6. CheckboxAD post-processing (MORA biti nakon setOutput!)
  if (item.active && item.elementType === 'CheckboxAD') {
    this.processCheckboxAD(item, model, output[index]);
  }

  // 7. Render gating: *ngIf="items.active" u ContentLoader template-u
  if (!item.active) return;  // block se NE kreira, djeca se NE procesiraju

  // 8. Kreiraj block model (ngOnInit blok komponente)
  if (isBlock) model[item.name] = model[item.name] || {};

  // 9. Rekurzija u djecu
  if (isDefaultBlock) {
    await this.processDefaultBlockChildren(...);   // FLAT model
  } else if (isBasicBlock) {
    if (outputEntry.active) {                      // *ngIf="output.active"
      await this.processBasicBlockChildren(...);   // NESTED model
    }
  }
}
```

##### processDefaultBlockChildren() — zamjena za defaultblock.template.html

```typescript
async processDefaultBlockChildren(item, model, outputTarget, parameters, parent, pname) {
  // default_block prosljeđuje ISTI model djeci (flat)
  // [model]="model" u Angular template-u

  for (action  of item.actions)   await processElement(action,  model, {},                       params, parent, pname);

  // Offer activation: nakon actions, aktiviraj elemente čiji code odgovara
  for (action of item.actions) {
    const selectedValue = model[action.name];  // npr. "5919"
    for (element of item.elements) {
      if (element.code === selectedValue) element.active = true;
    }
  }

  for (message of item.messages) await processElement(message, model, {},                       params, parent, pname);
  for (input   of item.inputs)   await processElement(input,   model, outputTarget.attr || ..., params, parent, pname);
  for (element of item.elements) await processElement(element, model, outputTarget.items || .., params, parent, pname);
  for (child   of item.children) await processElement(child,   model, outputTarget.spec || ..., params, parent, pname);
}
```

##### processBasicBlockChildren() — zamjena za basicblock.template.html

```typescript
async processBasicBlockChildren(item, model, outputTarget, parameters, pname) {
  // basic_block prosljeđuje UGNIJEŽĐENI model djeci
  // [model]="model[items.name]" u Angular template-u

  const nestedModel = model[item.name];  // model["FlatBHTelecom"]
  const newParent   = model;             // roditelj = model iznad

  for (message of item.messages) await processElement(message, nestedModel, {},                       params, newParent, pname);
  for (element of item.elements) await processElement(element, nestedModel, outputTarget.items || .., params, newParent, pname);
  for (input   of item.inputs)   await processElement(input,   nestedModel, outputTarget.attr || ..., params, newParent, pname);
  for (child   of item.children) await processElement(child,   nestedModel, outputTarget.spec || ..., params, newParent, pname);
}
```

---

#### 8. `index.ts` — Orchestracija

```typescript
export async function buildModel(input) {
  // 1. HTTP klijent sa cookie-jem
  const httpClient = new HttpClient(input.backendBaseUrl, input.headers);

  // 2. Dohvati strukturu
  const response = await httpClient.get('/pcrt/order-entry', {
    interactionId: 16,
    productOfferId: input.offerId,
    productSpecificationId: input.specId,
    appProcessId: input.processId
  });

  // 3. Inicijalizacija
  const model = { auto: {} };
  const output = {};
  const params = { ...response.parameters, ...input.customerParams, P_MAIN_OFFER_ID: input.offerId };

  // 4. Kreiraj servise
  const apiParse     = new ApiCallParse();
  const autoInc      = new AutoIncrement(model);
  const valueResolver = new ValueResolver(httpClient, apiParse, autoInc, model, params, errors);
  const processor     = new StructureProcessor(valueResolver, errors, model);

  // 5. Rekurzivno procesiraj
  await processor.processStructure(response.structure, model, output, params);

  // 6. Očisti cirkularne reference (parent() funkcije)
  return { model: safeClone(model), output: safeClone(output), errors, structure: response };
}
```

**Analogija**: `index.ts` je **šef smjene** u fabrici. Ne radi ništa sam, ali koordinira sve radnike.

---

## Bugovi koje smo otkrili i kako smo ih riješili

### Bug 1: 285 grešaka — POST umjesto GET

**Simptom**: Svaki lookupStatement vratio `405 Method Not Allowed`

**Uzrok**: Koristili `httpClient.post('/uomback/common/lookupStatement')`. Angular-ov `ApiDispatcher` koristi GET kao default (nema `POST@` prefiks u URL-u).

**Ispravka**: `dblookup()` i `setmessages()` promijenjeni sa `post()` na `get()`.

**Lekcija**: Uvijek provjeri Network tab u DevTools, ne pretpostavljaj HTTP metod.

---

### Bug 2: Model preduboko ugniježđen

**Simptom**: `model.FlatpaketiPOTS.FlatBHTelecom.FIRSTNAME` umjesto `model.FlatBHTelecom.FIRSTNAME`

**Uzrok**: Prva verzija je SVE blokove tretirala isto — prosljeđivala `model[items.name]` djeci.

**Ispravka**: Razdvojili u `processDefaultBlockChildren()` (flat) i `processBasicBlockChildren()` (nested).

**Lekcija**: Razlika je bila u TEMPLATE-u, ne u KOMPONENTI. Template odlučuje šta prosljeđuje djeci.

---

### Bug 3: FlatBHTelecom prazan {}

**Simptom**: FlatBHTelecom postojao ali bez ijednog polja unutra.

**Uzrok**: `output.active = false` za FlatBHTelecom blokirao child procesiranje (`*ngIf="output.active"`). Angular koristi dependency sistem za aktivaciju ponuda — kada select action postavi vrijednost "5919", element sa `code="5919"` se aktivira.

**Ispravka**: Dodali offer activation logiku nakon procesiranja actions:
```typescript
for (action of item.actions) {
  const selectedValue = model[action.name];  // "5919"
  for (element of item.elements) {
    if (element.code === selectedValue) element.active = true;
  }
}
```

---

### Bug 4: CheckboxAD vrijednosti null umjesto false

**Simptom**: `Budenje = null`, `Budenje_init` ne postoji.

**Uzrok**: Boolean konverzija dešavala se samo unutar `dblookup()`/`generate()` callback-a, ne za elemente sa `defaultValue` ili bez formule.

**Ispravka**: Dodali `processCheckboxAD()` koji se pokreće NAKON `setOutput()`:
```typescript
processCheckboxAD(item, model, outputEntry) {
  const rawValue = model[item.name];
  this.rootModel[item.name + 'lookupValue'] = rawValue;  // sačuvaj original
  model[item.name] = toBooleanConversion(rawValue);       // konvertuj u true/false
  model[item.name + '_init'] = false;                     // uvijek false na init
  outputEntry.active = (_init !== model[name]);
}
```

---

### Bug 5: active: null ne defaultuje na true

**Simptom**: Root element `FlatpaketiPOTS` se uopšte ne procesira — model prazan.

**Uzrok**: API vraća `active: null`. Kod radio `item.active !== undefined ? item.active : true`. Ali `null !== undefined` je `true`, pa active ostaje `null` (falsy)!

**Ispravka**:
```typescript
item.active = (item.active !== undefined && item.active !== null) ? item.active : true;
```

---

### Bug 6: Render gating preagresivan (Codex bug)

**Simptom**: default_block djeca se ne procesiraju.

**Uzrok**: Codex dodao `if (!shouldRender) return;` za SVE elemente. Ali ContentLoader template ima `*ngIf="items.active"` koji gates **blok komponentu**, ne samu ContentLoader komponentu. ContentLoader.ngOnInit() UVIJEK radi — samo blok se ne instantira ako je inactive.

**Ispravka**: Render gating stavljen NAKON setOutput() ali PRIJE kreiranja block modela i child recursion-a.

---

### Bug 7: Dupla CheckboxAD logika (Codex bug)

**Simptom**: `lookupValue` se prepisivao sa boolean umjesto raw vrijednošću.

**Uzrok**: CheckboxAD logika postojala na DVA mjesta:
1. `value-resolver.ts:setvalue()` — konvertuje raw u boolean, sprema lookupValue
2. `structure-processor.ts:processCheckboxAD()` — opet čita `model[name]` koji je sad boolean

**Ispravka**: Uklonili CheckboxAD logiku iz `value-resolver.ts` — sada se obrađuje SAMO u `processCheckboxAD()`.

---

## Vizualni pregled toka podataka

```
buildModel({ offerId: "5919", P_CA_ID: "130025794", P_BA_ID: "330021716" })
    │
    ▼
GET /pcrt/order-entry → JSON struktura sa 1000+ elemenata
    │
    ▼
processStructure(structure, model={auto:{}}, output={})
    │
    ▼
processElement("FlatpaketiPOTS", template="default_block")
    ├── ValueManager.set() → ništa (nema formulu)
    ├── setOutput() → output["FlatpaketiPOTS"] = {attr:{}, items:{}, spec:{}}
    ├── active=true → kreira model["FlatpaketiPOTS"] = {}
    └── processDefaultBlockChildren() [FLAT: model=model]
        │
        ├── processElement("loadOffer979", template="select")
        │   ├── ValueManager.set() → model["loadOffer979"] = "5919" (defaultValue)
        │   └── setOutput() → output u {} (actions se ne čuvaju)
        │
        ├── Offer activation: model["loadOffer979"]="5919" → FlatBHTelecom.code="5919" → activate!
        │
        └── processElement("FlatBHTelecom", template="basic_block")
            ├── ValueManager.set() → ništa
            ├── setOutput() → output.items["FlatBHTelecom"] = {attr:{}, items:{}, spec:{}}
            ├── active=true, output.active=true → kreira model["FlatBHTelecom"] = {}
            └── processBasicBlockChildren() [NESTED: model=model["FlatBHTelecom"]]
                │
                ├── processElement("FIRSTNAME", template="text")
                │   ├── GET /uomback/common/lookupStatement?method=select...130025794...
                │   │   └── response: "JNF-8241"
                │   │       └── model["FlatBHTelecom"]["FIRSTNAME"] = "JNF-8241"
                │   └── setOutput() → output.attr["FIRSTNAME"] = {active:true, attvalue:"JNF-8241"}
                │
                ├── processElement("Budenje", template="CheckboxAD")
                │   ├── GET /uomback/common/lookupStatement?method=SELECT...
                │   │   └── response: null (korisnik nema ovu uslugu)
                │   │       └── model["FlatBHTelecom"]["Budenje"] = null (privremeno)
                │   ├── setOutput() → output.items["Budenje"] = {active:false}
                │   └── processCheckboxAD()
                │       ├── rootModel["BudenjelookupValue"] = null  ← sačuvaj original
                │       ├── model["FlatBHTelecom"]["Budenje"] = false  ← null → false
                │       ├── model["FlatBHTelecom"]["Budenje_init"] = false
                │       └── outputEntry.active = (false === false) ? false : true → false
                │
                └── ... (još 100+ elemenata)
```

---

## Krajnji rezultat

```
Angular browser:                         buildModel():
─────────────────────────────────────────────────────────────────
model.FlatBHTelecom.FIRSTNAME            model.FlatBHTelecom.FIRSTNAME
= "JNF-8241"                             = "JNF-8241"                    ✅

model.FlatBHTelecom.Budenje              model.FlatBHTelecom.Budenje
= false                                  = false                          ✅

model.BudenjelookupValue                 model.BudenjelookupValue
= null                                   = null                           ✅

model.ZabranaadresezainformacijePOTS     model.ZabranaadresezainformacijePOTS
lookupValue = "1"                        lookupValue = "1"                ✅
─────────────────────────────────────────────────────────────────
106/106 ključeva ✅  |  0 razlika u vrijednostima ✅  |  0 grešaka ✅
```

Kompletna Angular fabrika sa 7 komponenti, 5 servisa i stotinama `subscribe()` callback-a —
replicirana u 8 fajlova čistog async TypeScript-a.

---

## Vodič za čitanje koda — od najjednostavnijeg do najsloženijeg

### Korak 1: Počni sa `types.ts`

Ovo je "rječnik" projekta. Prije nego što čitaš bilo šta drugo, moraš znati šta su `InputObject`, `BuildModelInput`, `BuildModelResult`. Ne moraš zapamtiti svako polje — samo skeniraj da vidiš šta postoji. Vratićeš se ovdje kad naiđeš na nepoznat tip.

### Korak 2: `auto-increment.ts`

Najmanji fajl (~30 linija). Ima samo `set()` i `increment()`. Pročitaj ga za 2 minute i imaš prvi "gotov" fajl u glavi. To ti daje samopouzdanje.

### Korak 3: `output-builder.ts`

Takođe mali. Dvije funkcije: `setOutput()` i `setModelParent()`. Fokusiraj se na to ŠTA output objekat sadrži — `attr`, `items`, `spec` su tri ključne kutije u koje se pakuju različiti tipovi djece.

### Korak 4: `http-client.ts`

Ako znaš šta je `fetch()`, ovo je jednostavno. Zapamti samo jednu stvar: `dispatch()` gleda da li URL počinje sa `POST@` — ako da, koristi POST. Ako ne, koristi GET. To je sva magija.

### Korak 5: `api-call-parse.ts`

Ovo je prvi "teži" fajl. Ali ključ je razumjeti samo DVA markera:
- `#:FIELD#` → zamijeni sa vrijednošću iz **parametara**
- `$:FIELD`  → zamijeni sa vrijednošću iz **modela**

I jednu metodu: `getElementParamVal()` koja ide uz `parent()` lanac. Sve ostalo su varijacije na tu temu.

### Korak 6: `index.ts`

Ovo je "main" — pročitaj ga PRIJE value-resolver i structure-processor. Ima samo 100 linija i pokazuje ti REDOSLIJED operacija. Ne ulazi u detalje pojedinih servisa, samo vidi kako se sastavljaju zajedno. Ovo ti daje "ptičju perspektivu".

### Korak 7: `value-resolver.ts`

Sada si spreman za teže stvari. Kreni od metode `set()` — to je ulazna tačka. Čitaj je kao flowchart: "ako ima externalAPI, uradi ovo. Ako ima generationFormula, uradi ono." Ne pokušavaj razumjeti SVE helper metode odjednom. Fokusiraj se na `set()` → `dblookup()` → `setvalue()` tok. To je 80% posla.

### Korak 8: `structure-processor.ts`

Ostavi ovo za kraj. Ovo je najsloženiji fajl, ali ako si prošao korake 1-7, razumiješ sve dijelove koje on koristi. Kreni od `processElement()` i čitaj komentare — svaki korak ima komentar koji kaže koji Angular dio zamjenjuje. Onda pogledaj razliku između `processDefaultBlockChildren()` (flat model) i `processBasicBlockChildren()` (nested model).

---

### Praktični savjet

Nemoj čitati kod pasivno. Otvori `test-run.ts`, pokreni ga sa stvarnim SESSION cookie-jem, i dodaj `console.log()` u `processElement()`:

```typescript
console.log('Processing:', item.name, 'template:', item.template, 'active:', item.active);
```

Gledaj kako se elementi procesiraju jedan po jedan. Vidjet ćeš:
```
Processing: FlatpaketiPOTS  template: default_block  active: true
Processing: loadOffer979    template: select          active: true
Processing: FlatBHTelecom   template: basic_block     active: true
Processing: FIRSTNAME       template: text            active: true
Processing: NAME            template: text            active: true
Processing: Budenje         template: CheckboxAD      active: true
...
```

To je 10x bolje od čitanja koda u editoru. Vidiš tok izvršavanja uživo.

---

### Redoslijed čitanja (cheat sheet)

```
types.ts → auto-increment.ts → output-builder.ts → http-client.ts
    → api-call-parse.ts → index.ts → value-resolver.ts → structure-processor.ts
```

Jednostavno → složeno. Svaki fajl gradi na znanju iz prethodnog.
