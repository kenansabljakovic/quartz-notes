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

---

## types.ts - Rječnik projekta

### Zašto ovaj fajl postoji?

Zamislimo da razgovaramo sa drugom osobom o automobilu. Ako kažeš "prenesi mi ključeve", druga osoba treba da zna šta su "ključevi" — male metalne stvari koje se stavljaju u bravu. TypeScript **interfejsi** su kao dogovor između programera šta znači svaki termin. Kada vidiš `InputObject` u kodu, tačno znaš koje podatke sadrži.

Ovaj fajl je **rječnik** cijelog projekta. Definira "oblik" (shape) svakog objekta koji se koristi u model builder-u.

Fajl ima dvije sekcije:
- **Linije 1–171**: Angular interfejsi portovani iz `z-dynamic/interfaces/data.value.interface.ts`
- **Linije 176–201**: Novi interfejsi samo za `buildModel()` (naši dodaci)

---

### Centralni interfejs: `InputObject`

Ovo je **najvažniji** tip u cijelom projektu. Svaki element u strukturi (FIRSTNAME, Budenje, FlatBHTelecom) je `InputObject`.

```typescript
export interface InputObject {
  // Identifikacija
  name?: any;                       // "FIRSTNAME", "Budenje", "FlatBHTelecom"
  code?: string;                    // "FIRSTNAME", "2246", "5919"
  label?: string;                   // "Ime", "Budenje", "Flat BH Telecom"
  template?: string;                // "text", "select", "CheckboxAD", "basic_block"
  elementType?: string;             // "text", "select", "CheckboxAD", "loadElements"

  // Status
  active?: boolean;                 // Da li je element aktivan (prikazan)
  disabled?: boolean;               // Da li je onemogućen (ne može se editovati)
  visible?: boolean;                // Da li je vidljiv

  // Kako dobiti vrijednost
  value?: InputValue;               // Izvor vrijednosti (formula, lookup, default, autoincrement)
  mappingRef?: string;              // Reference na drugo polje ("external.P_CA_ID", "head.NAME")

  // Klasifikacija
  businessClassification?: string;  // "SPECIFICATION", "OFFER", "Attribute"
  businessParams?: object;          // { ACTION_CODE: "NewPOTS" }

  // API pozivi
  externalAPI?: string;             // URL za dohvatanje child strukture
  externalMessages?: string;        // SQL za dohvatanje validacionih poruka

  // Rekurzivna struktura (djeca)
  inputs?: InputObject[];           // Atributi (FIRSTNAME, NAME)
  elements?: InputObject[];         // Glavni elementi (Budenje, Preuzimanja)
  children?: InputObject[];         // Specifikacije (default_block elementi)
  actions?: InputObject[];          // Akcije (loadOffer979 - select dropdown)
  messages?: InputObject[];         // Validacione poruke

  // Runtime
  parameters?: any;                 // Runtime parametri sa parent() lancem
  output?: DynamicOutput;           // Link na output entry
  set?: boolean;                    // Flag: da li je ValueManager.set() već pozvan

  // Datumski raspon validnosti
  validFrom?: string;               // "01/01/2024"
  validTo?: string;                 // "31/12/2024"

  // Ostalo
  dependency?: DependencyElement[]; // UI dependency (disabled/visible/refresh)
  validation?: InputValidation;     // Pravila (mandatory, min, max, pattern)
  attributes?: InputAttributes;     // CSS klase
  initActivity?: boolean;           // Da li je inicijalno aktivan
}
```

#### Analogija za InputObject

Zamislimo da InputObject opisuje jednu komponentu u Ikea namještaju:

- **name**: Naziv komponente ("Noga stola", "Zavrtanj A5")
- **code**: Barcode ("12345")
- **label**: Čitljiv naziv na kutiji ("Čelična noga 70cm")
- **template**: Tip komponente ("noga", "zavrtanj", "ploča")
- **active**: Da li se koristi u ovoj konfiguraciji (true/false)
- **value.defaultValue**: Ako piše "2 komada" na instrukcijama
- **value.generationFormula**: "Idi u magacin i donesi točan broj koji piše u sekciji 3.4" (API poziv)
- **inputs/elements/children**: Pod-komponente (zavrtnji koji drže nogu)

---

### `InputValue` - Odakle dolazi vrijednost?

```typescript
export interface InputValue {
  defaultValue?: any;          // Statička vrijednost: "5919", null, true, 42
  autoincrement?: any;         // Sekvencijalni broj: 200, 201, 202...
  generationFormula?: string;  // API poziv: "POST@/some/endpoint?param=#:P_CA_ID#"
  lookupStatement?: string;    // SQL upit: "SELECT name FROM customer WHERE id=#:P_CA_ID#"
  data?: object[];             // Opcije za select/radio (ako je statička lista)
  selected?: object;           // Trenutno selektovana stavka (za dropdown)
  column?: object[];           // Kolone za tabelu
  options?: object;            // Dodatne opcije
  temp?: object[];             // Privremeni podaci
}
```

#### Prioritet izvora vrijednosti

ValueManager gleda po redosljedu — ako nađe prvi izvor, ignoriše ostale:

```
1. autoincrement      → model[name] = 200++
2. mappingRef         → model[name] = model["OTHER_FIELD"] ili parameters.P_CA_ID
3. defaultValue       → model[name] = "5919"
4. generationFormula  → HTTP poziv → model[name] = response
5. lookupStatement    → DB lookup  → model[name] = response
```

#### Primjer (element "FIRSTNAME")

```json
{
  "name": "FIRSTNAME",
  "template": "text",
  "value": {
    "generationFormula": "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#, #:P_CA_ID#, 'FIRSTNAME') from dual"
  }
}
```

ValueManager vidi `generationFormula`, parsira SQL (zamijeni `#:P_CA_ID#` sa `130025794`), pošalje na backend, dobije `"JNF-8241"` → `model["FIRSTNAME"] = "JNF-8241"`.

---

### `DynamicOutput` - Output entry struktura

```typescript
export interface DynamicOutput {
  attr?: any;               // Pod-objekat za inputs
  items?: any;              // Pod-objekat za elements
  spec?: any;               // Pod-objekat za children

  name?: string;            // "FIRSTNAME", "Budenje"
  code?: string;            // "FIRSTNAME", "2246"
  active?: boolean;         // Da li je aktivan
  label?: string;           // "Ime", "Budenje"
  value?: any;              // Link na model

  calss?: string;           // "SPECIFICATION", "OFFER", "Attribute"
                            // (da, "calss" je typo u Angular-u koji je namjerno sačuvan!)
  elementType?: string;     // "text", "select", "CheckboxAD"
  businessParams?: object;  // { ACTION_CODE: "NewPOTS" }

  adind?: string;           // Samo za CheckboxAD: "A" (add), "D" (delete)
  attvalue?: any;           // Za inputs: kopija vrijednosti iz model-a
}
```

**Zašto output postoji?** Angular UI koristi output da zna koje polje prikazati kao text input a koje kao checkbox, koji label da koristi, da li je nešto aktivno. Model Builder gradi output za **full parity** sa Angular-om.

---

### `InputValidation` - Pravila

```typescript
export interface InputValidation {
  mandatory?: boolean;           // Obavezno polje
  mandatoryFormula?: string;     // SQL koji vraća 1 (mandatory) ili 0 (optional)
  formatPattern?: string;        // Regex: "^[0-9]{3}-[0-9]{3}$"
  min?: number;                  // Minimalna vrijednost (za brojeve)
  max?: number;                  // Maksimalna vrijednost
  maxlength?: number;            // Maksimalna dužina stringa
  validationFormula?: string;    // SQL koji vraća error message ako nije valid
  valueType?: string;            // "number", "string", "date"
}
```

**Napomena**: Model Builder **NE** izvršava validaciju. Samo čita i popunjava `model`. Angular UI koristi ove podatke za real-time validaciju dok korisnik kuca.

---

### `DependencyElement` - UI zavisnosti

```typescript
export interface DependencyElement {
  name?: string;           // Ime elementa koji se mijenja
  element?: string;        // Ime elementa koji triger-uje promjenu
  effect?: string;         // "disabled", "visible", "refresh"
  elementEvent?: string;   // "change", "blur", "focus"
  elementValue?: any;      // Vrijednost koja triger-uje effect
  effectSource?: string;   // Izvor za refresh (API poziv)
}
```

**Primjer**: "Ako `Budenje === true`, onemogući polje `WakeUpTime`"

```json
{
  "name": "WakeUpTime",
  "element": "Budenje",
  "effect": "disabled",
  "elementEvent": "change",
  "elementValue": false
}
```

**Napomena**: Model Builder **NE** procesira dependency. To je UI stvar koja se izvršava u Angular-u kada korisnik mijenja vrijednosti.

---

### Novi interfejsi (za buildModel API)

#### `BuildModelInput` - Ulaz u buildModel()

```typescript
export interface BuildModelInput {
  offerId: string;              // "5919" - koji offer korisnik želi
  specId: string;               // "979"  - specifikacija (FlatpaketiPOTS)
  processId: string;            // "10"   - proces (NewPOTS)
  backendBaseUrl: string;       // "http://172.30.80.1:48080"
  headers?: Record<string, string>;   // { Cookie: "SESSION=..." }
  customerParams: {
    P_CA_ID?: string;           // "130025794" - Customer Account ID
    P_BA_ID?: string;           // "330021716" - Billing Account ID
    P_SA_ID?: string;           // Service Account ID (ako postoji)
    [key: string]: any;         // Bilo koji drugi custom parametar
  };
}
```

#### `BuildModelResult` - Izlaz iz buildModel()

```typescript
export interface BuildModelResult {
  model: Record<string, any>;   // Popunjen model objekat
  output: Record<string, any>;  // Output struktura (metadata)
  errors: ErrorEntry[];         // Lista grešaka tokom procesiranja
  structure: any;               // Originalna struktura iz backend-a (za debug)
}
```

#### `ErrorEntry` - Format greške

```typescript
export interface ErrorEntry {
  element: string;  // "FIRSTNAME" - koji element je failao
  error: string;    // "HTTP 404: Not Found" - šta se desilo
  phase: string;    // "fetchStructure", "dblookup", "generate" - u kojoj fazi
}
```

**Zašto ne throw-ujemo exception?** Zato što jedan element može failati ali to ne znači da cijela forma treba failati. Ostali elementi se normalno procesiraju — kao u Angular-u.

---

### Zašto toliko `?` (optional polja)?

```typescript
name?: string;  // ← Znak pitanja znači "možda postoji, možda ne"
```

Različiti tipovi elemenata imaju različita polja:

| Element | Ima | Nema |
|---------|-----|------|
| Text input ("FIRSTNAME") | `value.generationFormula` | `elements` |
| Select ("loadOffer979") | `value.data` (opcije) | `generationFormula` |
| CheckboxAD ("Budenje") | `value.lookupStatement` | `inputs` |
| basic_block ("FlatBHTelecom") | `inputs`, `elements`, `children` | `value` |

Sa `name?:` kažemo TypeScript-u "možda postoji, možda ne — ne brini ako nedostaje".

---

### Mapa ključnih tipova

```
InputObject                          ← Jedan element u strukturi
  ├─ value: InputValue               ← Odakle dolazi vrijednost
  ├─ validation: InputValidation     ← Pravila (mandatory, min, max)
  ├─ dependency: DependencyElement[] ← UI zavisnosti (ne procesira se ovdje)
  ├─ output: DynamicOutput           ← Output entry (metadata)
  ├─ inputs: InputObject[]           ← Atributi → output.attr
  ├─ elements: InputObject[]         ← Elementi → output.items
  └─ children: InputObject[]         ← Specifikacije → output.spec

BuildModelInput                      ← Ulaz u buildModel()
  ├─ offerId, specId, processId      ← Šta korisnik želi
  ├─ backendBaseUrl, headers         ← Gdje je backend
  └─ customerParams                  ← P_CA_ID, P_BA_ID, itd.

BuildModelResult                     ← Izlaz iz buildModel()
  ├─ model                           ← Popunjen objekat sa vrijednostima
  ├─ output                          ← Metadata struktura
  ├─ errors                          ← Lista grešaka
  └─ structure                       ← Originalna struktura (za debug)
```

---

### Veza sa ostalim fajlovima

- **value-resolver.ts** koristi `InputObject.value` (`InputValue`) da zna odakle dohvatiti vrijednost
- **structure-processor.ts** koristi `InputObject.inputs/elements/children` za rekurziju
- **output-builder.ts** kreira `DynamicOutput` objekte
- **index.ts** prima `BuildModelInput` i vraća `BuildModelResult`

---

### Zaključak

`types.ts` nije "kod koji radi" — to je "kod koji opisuje". Zamislimo da gradimo kuću:

- **types.ts** = arhitektonski nacrt (gdje će biti vrata, prozori, sobe)
- **Ostali fajlovi** = radnici koji zapravo grade

Nacrt je bitan jer govori radnicima šta da grade. Ali nacrt sam od sebe ne gradi kuću.

**Praktičan savjet**: NE pokušavaj zapamtiti sva polja odjednom! Ovo je **referentni** fajl — vraćaš se ovdje kad naiđeš na nepoznat tip. Kao telefonski imenik — ne učiš ga napamet, ali kad ti treba broj, otvoriš i pogledaš.

---

## Docker Deployment - Produkcijska postavka

### Problem: Lokalni setup nije prikladan za produkciju

Trenutni `test-run.ts` koristi hardcode-ovane vrijednosti:

```typescript
const backendBaseUrl = 'http://172.30.80.1:48080';  // ← WSL2 gateway IP - radi samo lokalno!
const cookie = 'SESSION=2950b4a9-4498-416e-9d62-22e27407d97f';  // ← Manuelno kopirano
```

**Analogija**: Ovo je kao da u GPS-u upišeš tačnu adresu svog komšije umjesto da spasiš "Kućna adresa". Radi dok si u istoj ulici, ali ako se preseliš u drugi grad — GPS je beskoristan.

Kada `buildModel()` postane Docker servis (mikroservis), potrebna su dva prilagođavanja:

1. **backendBaseUrl** - mora biti dinamički (env variable)
2. **SESSION cookie** - autentifikacija prema backend-u

---

### Rješenje 1: Environment variable za backend URL

Umjesto hardcoded IP-a, učitaj iz environment varijable:

```typescript
// test-run.ts ili REST endpoint
const backendBaseUrl = process.env.BACKEND_BASE_URL || 'http://backend:48080';
```

U Docker Compose-u:

```yaml
version: '3.8'
services:
  backend:
    image: uom-backend:latest
    ports:
      - "48080:48080"
    networks:
      - uom-network

  model-builder:
    image: model-builder:latest
    ports:
      - "3000:3000"
    environment:
      - BACKEND_BASE_URL=http://backend:48080  # ← Docker service name kao hostname
    networks:
      - uom-network

networks:
  uom-network:
    driver: bridge
```

**Zašto `http://backend:48080`?** Docker Compose kreira internu DNS rezoluciju — service imena postaju hostname-i. Container `model-builder` može direktno zvati `backend` unutar iste mreže.

**Alternativa (vanjski hostname)**: Ako backend nije u istom Docker Compose stack-u:

```yaml
environment:
  - BACKEND_BASE_URL=http://192.168.1.100:48080  # ← Fizički IP ili domain
```

---

### Rješenje 2: SESSION cookie autentifikacija

Tri pristupa:

#### **Pristup A: Proxy (proslijedi korisnikov SESSION)**

Model Builder **NE** koristi vlastitu autentifikaciju. Angular prosljeđuje korisnikov SESSION, a Model Builder ga samo proslijedi backend-u.

**Flow**:
```
Angular UI → POST /api/buildModel + Cookie: SESSION=abc123
  ↓
Model Builder REST endpoint → čita SESSION iz request headers
  ↓
buildModel({ headers: { Cookie: request.headers.cookie } })
  ↓
HttpClient → svi pozivi prema backend-u uključuju taj SESSION
```

**Express.js endpoint primjer**:

```typescript
import express from 'express';
import { buildModel } from './lib/model-builder';

const app = express();
app.use(express.json());

app.post('/api/buildModel', async (req, res) => {
  try {
    // Proslijedi korisnikov SESSION cookie
    const result = await buildModel({
      offerId: req.body.offerId,
      specId: req.body.specId,
      processId: req.body.processId,
      backendBaseUrl: process.env.BACKEND_BASE_URL,
      headers: {
        Cookie: req.headers.cookie || '',  // ← Proslijedi cookie kao što je stigao
      },
      customerParams: req.body.customerParams,
    });

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, () => console.log('Model Builder running on port 3000'));
```

**Prednosti**:
- ✅ Najjednostavnije — bez dodatne autentifikacije
- ✅ Koristi iste permisije kao korisnik (security)
- ✅ Audit trail — svaki API poziv zabilježen pod korisnikovim SESSION-om

**Mane**:
- ❌ Zahtijeva da korisnik ima validan SESSION (ne može se koristiti za batch poslove)

**Docker Compose** (isti kao prije, bez promjena).

---

#### **Pristup B: Service Account (Model Builder ima svoj SESSION)**

Model Builder se loguje na backend sa **service account** kredencijalima i održava vlastiti SESSION.

**Flow**:
```
Model Builder startup → POST /login sa service account username/password
  ↓
Backend vraća SESSION cookie
  ↓
Model Builder sprema SESSION u memoriju
  ↓
buildModel({ headers: { Cookie: serviceAccountSession } })
```

**Express.js primjer**:

```typescript
let serviceSession = '';

// Funkcija za login (poziva se na startup ili kad SESSION expire-a)
async function loginAsServiceAccount() {
  const response = await fetch(process.env.BACKEND_BASE_URL + '/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: process.env.SERVICE_ACCOUNT_USER,  // "model-builder-service"
      password: process.env.SERVICE_ACCOUNT_PASS,  // "SecurePassword123"
    }),
  });

  // Izvuci SESSION iz Set-Cookie header-a
  const setCookie = response.headers.get('set-cookie');
  const match = setCookie?.match(/SESSION=([^;]+)/);
  if (match) {
    serviceSession = 'SESSION=' + match[1];
    console.log('Service account logged in:', serviceSession.substring(0, 20) + '...');
  }
}

// Login na startup
loginAsServiceAccount();

// Relogin svaka 2 sata (ako SESSION traje 2h)
setInterval(loginAsServiceAccount, 2 * 60 * 60 * 1000);

app.post('/api/buildModel', async (req, res) => {
  const result = await buildModel({
    ...req.body,
    backendBaseUrl: process.env.BACKEND_BASE_URL,
    headers: {
      Cookie: serviceSession,  // ← Koristi service account SESSION
    },
  });

  res.json(result);
});
```

**Docker Compose**:

```yaml
model-builder:
  environment:
    - BACKEND_BASE_URL=http://backend:48080
    - SERVICE_ACCOUNT_USER=model-builder-service  # ← Novi env vars
    - SERVICE_ACCOUNT_PASS=SecurePassword123
```

**Prednosti**:
- ✅ Radi i bez korisnikovog SESSION-a (batch poslovi, CRON jobovi)
- ✅ Jedan SESSION za sve pozive (manje load na backend auth)

**Mane**:
- ❌ Audit trail ne pokazuje ko je STVARNI korisnik
- ❌ Svi pozivi imaju iste permisije (service account mora imati široke permisije)
- ❌ SESSION rotation logika (refresh kad expire-a)

---

#### **Pristup C: Hybrid (pokušaj korisnikov SESSION, fallback na service account)**

```typescript
app.post('/api/buildModel', async (req, res) => {
  let cookie = req.headers.cookie;  // Probaj korisnikov SESSION

  if (!cookie || cookie === '') {
    // Fallback: koristi service account SESSION
    cookie = serviceSession;
  }

  const result = await buildModel({
    ...req.body,
    backendBaseUrl: process.env.BACKEND_BASE_URL,
    headers: { Cookie: cookie },
  });

  res.json(result);
});
```

**Kada koristiti**:
- Angular poziv → proslijedi korisnikov SESSION
- CRON job / interno → koristi service account SESSION

---

### Preporuka: Počni sa Pristupom A (Proxy)

Za **prvu verziju**, koristi **Pristup A** (Proxy):
- Najjednostavniji (bez dodatne logike)
- Security best practice (korisnik može vidjeti samo svoje podatke)
- Lako testirati (kopiraj SESSION iz browser-a)

**Kasnije**, ako treba batch processing ili CRON jobovi, dodaj **Pristup C** (Hybrid).

---

### Kompletan Docker Compose primjer (Pristup A)

```yaml
version: '3.8'

services:
  backend:
    image: uom-backend:latest
    ports:
      - "48080:48080"
    networks:
      - uom-network

  model-builder:
    build: ./model-builder
    ports:
      - "3000:3000"
    environment:
      - BACKEND_BASE_URL=http://backend:48080
      - NODE_ENV=production
    networks:
      - uom-network
    depends_on:
      - backend

  angular-ui:
    image: nginx:alpine
    volumes:
      - ./dist:/usr/share/nginx/html
    ports:
      - "80:80"
    networks:
      - uom-network

networks:
  uom-network:
    driver: bridge
```

**Angular servis** (kako poziva Model Builder):

```typescript
// model-builder.service.ts
buildModel(offerId: string, specId: string, processId: string, customerParams: any) {
  // Angular automatski šalje cookie-je sa withCredentials: true
  return this.http.post('http://localhost:3000/api/buildModel', {
    offerId,
    specId,
    processId,
    customerParams
  }, { withCredentials: true });  // ← Ovo šalje SESSION cookie
}
```

---

### Testiranje Docker setup-a

```bash
# Build image
cd model-builder
docker build -t model-builder:latest .

# Pokreni Docker Compose
docker-compose up -d

# Testiraj sa curl-om (proslijedi SESSION)
curl -X POST http://localhost:3000/api/buildModel \
  -H "Content-Type: application/json" \
  -H "Cookie: SESSION=2950b4a9-4498-416e-9d62-22e27407d97f" \
  -d '{
    "offerId": "5919",
    "specId": "979",
    "processId": "10",
    "customerParams": {
      "P_CA_ID": "130025794",
      "P_BA_ID": "330021716"
    }
  }'
```

---

### Analogija: Restoran dostave

- **Pristup A (Proxy)**: Korisnik zove restoran sa svojim brojem telefona. Dostavljač vidi "narudžba za Kenana". Restoran zna ko je naručio i vodi statistiku.
- **Pristup B (Service Account)**: Korisnik zove aplikaciju. Aplikacija zove restoran sa SVOJIM brojem. Restoran vidi samo "narudžba od aplikacije X" — ne zna ko je stvarni korisnik.
- **Pristup C (Hybrid)**: Ako korisnik zove direktno, koristi svoj broj. Ako aplikacija radi automatsku narudžbu (npr. pretplata), koristi svoj broj.

**Za jelo koje korisnik naručio (real-time)** → koristi korisnički broj (Proxy)
**Za automatske narudžbe (CRON)** → koristi aplikacijski broj (Service Account)
