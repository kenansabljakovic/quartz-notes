# EVIDENCIJA-USLUGE - KORAK PO KORAK OBJAŠNJENJE

Kompletna analiza `evidencija-usluge.component.ts` i `evidencija-usluge.template.html` komponente, objašnjena korak po korak.

---

## KORAK 1: Deklaracija komponente (linija 1-75)

### 1.1 @Component decorator (linija 28-31)

**File:** `evidencija-usluge.component.ts`

```typescript
@Component({
  templateUrl: 'evidencija-usluge.template.html',
  styleUrls: ['evidencija-usluge.template.scss']
})
```

**Šta ovo znači:**
- **@Component** je Angular decorator koji govori "ovo je komponenta"
- **templateUrl** - pokazuje na HTML fajl koji će se koristiti za prikaz
- **styleUrls** - pokazuje na SCSS fajl koji sadrži stilove za ovu komponentu

**Analogija:**
Zamislite da pravite kuću:
- `@Component` je nacrt koji kaže "ovo je kuća"
- `templateUrl` je plan kuće (kako izgleda)
- `styleUrls` je dizajn enterijera (kako je uređena)

---

### 1.2 Klasa i index signature (linija 32-33)

```typescript
export class VpnEvidencijaUslugeComponent {
  [x: string]: any;
```

#### Šta je `[x: string]: any;`?

Ovo je TypeScript **index signature**. Dozvoljava da na komponentu dinamički dodaješ properties bez da ih prethodno deklarišeš.

#### Detaljno objašnjenje:

```typescript
[x: string]: any;
 │   │       │
 │   │       └─ Tip vrijednosti: bilo šta (any)
 │   └─ Tip ključa: mora biti string
 └─ Ime varijable (može biti bilo šta: x, key, prop...)
```

**Bez index signature:**
```typescript
class Person {
  name: string;
  age: number;
}

let person = new Person();
person.name = "John";      // ✓ OK - name je deklarisan
person.age = 30;           // ✓ OK - age je deklarisan
person.city = "Sarajevo";  // ✗ ERROR! Property 'city' does not exist on type 'Person'
```

**Sa index signature:**
```typescript
class Person {
  [x: string]: any;  // ← Dozvoljava bilo koji property!
  name: string;
  age: number;
}

let person = new Person();
person.name = "John";      // ✓ OK
person.age = 30;           // ✓ OK
person.city = "Sarajevo";  // ✓ OK - dinamički property!
person.country = "BiH";    // ✓ OK - dinamički property!
person.anything = 12345;   // ✓ OK - dinamički property!
```

#### Zašto je ovo važno za evidencija-usluge komponentu?

Kasnije u kodu (linija 85-90) vidimo:
```typescript
this.route.queryParams.subscribe((params: Params) => {
  Object.assign(this, params);  // ← Kopira SVE params properties na "this"
});
```

**Primjer:**

URL: `/evidencija/residential/1174/162/0?processId=10&offerId=1174&caId=130025794&basketnum=257697/26`

Query parametri:
```javascript
params = {
  processId: "10",
  offerId: "1174",
  caId: "130025794",
  basketnum: "257697/26"
}
```

`Object.assign(this, params)` radi:
```typescript
this.processId = "10";
this.offerId = "1174";
this.caId = "130025794";
this.basketnum = "257697/26";
```

**BEZ** `[x: string]: any;` → TypeScript bi javio GREŠKE jer ovi properties nisu deklarisani.

**SA** `[x: string]: any;` → Sve radi bez problema!

---

#### Praktični primjeri:

**Primjer 1: Dinamičko dodavanje properties**

```typescript
class MyComponent {
  [x: string]: any;
  name: string = "John";
}

let comp = new MyComponent();

// Možeš dodati bilo šta:
comp.age = 30;
comp.city = "Sarajevo";
comp.hobbies = ["football", "reading"];
comp.address = { street: "Titova", number: 10 };

console.log(comp.age);      // 30
console.log(comp.city);     // "Sarajevo"
console.log(comp.hobbies);  // ["football", "reading"]
```

**Primjer 2: Object.assign sa URL parametrima**

```typescript
class FormComponent {
  [x: string]: any;

  constructor() {
    // URL: ?id=123&name=Test&status=active
    let urlParams = {
      id: "123",
      name: "Test",
      status: "active"
    };

    Object.assign(this, urlParams);
    // Sada je:
    // this.id = "123"
    // this.name = "Test"
    // this.status = "active"
  }
}
```

**Primjer 3: Pristup preko bracket notation**

```typescript
class DataComponent {
  [x: string]: any;
  firstName: string = "John";
}

let comp = new DataComponent();

// Možeš pristupiti na 2 načina:
console.log(comp.firstName);       // "John" - dot notation
console.log(comp["firstName"]);    // "John" - bracket notation

// Sa bracket notation možeš koristiti varijable:
let fieldName = "firstName";
console.log(comp[fieldName]);      // "John"

// Dinamičko postavljanje:
let fields = ["age", "city", "country"];
fields.forEach(field => {
  comp[field] = "some value";
});

console.log(comp.age);      // "some value"
console.log(comp.city);     // "some value"
console.log(comp.country);  // "some value"
```

**Primjer 4: U našem kontekstu - evidencija-usluge**

```typescript
export class VpnEvidencijaUslugeComponent {
  [x: string]: any;  // ← Ovo dozvoljava sve dole:

  // URL params će biti kopirani direktno na this:
  // this.processId
  // this.offerId
  // this.specId
  // this.basketnum
  // this.ordnum
  // this.caId
  // this.baId
  // ... i još mnogo toga!

  ngOnInit() {
    this.route.queryParams.subscribe((params: Params) => {
      Object.assign(this, params);  // Kopira SVE
    });

    this.route.params.subscribe((params: Params) => {
      Object.assign(this, params);  // Kopira SVE
    });

    // Sada možeš koristiti:
    console.log(this.processId);  // "10"
    console.log(this.offerId);    // "1174"
    console.log(this.basketnum);  // "257697/26"
  }
}
```

---

#### Prednosti i nedostaci:

**Prednosti:**
- ✅ Fleksibilnost - možeš dodati bilo šta u runtime-u
- ✅ Lako kopiranje objekta sa Object.assign()
- ✅ Ne moraš unaprijed znati sve properties

**Nedostaci:**
- ❌ Gubiš type safety - TypeScript ne može provjeriti tipove
- ❌ Typo-i neće biti uhvaćeni (this.processID umjesto this.processId)
- ❌ IDE autocomplete neće raditi za dinamičke properties
- ❌ Teže za održavanje - ne znaš koji su properties dostupni

**Bolji pristup (alternativa):**
```typescript
interface RouteParams {
  processId?: string;
  offerId?: string;
  specId?: string;
  basketnum?: string;
  ordnum?: string;
}

class VpnEvidencijaUslugeComponent implements RouteParams {
  processId?: string;
  offerId?: string;
  specId?: string;
  basketnum?: string;
  ordnum?: string;

  // Sada imaš type safety i autocomplete!
}
```

Ali ovaj kod koristi `[x: string]: any` jer ima **previše** URL parametara da bi ih sve ručno deklarisao, i neki parametri dolaze samo u određenim scenarijima.

---

### 1.3 Propertiji komponente (linija 34-55)

```typescript
@Input() confing: FlowConfig;    // Konfiguracija koraka (tabovi), dolazi od parent komponente

public structure: DynamicRest;    // Struktura forme (JSON sa backenda)
public basket: EvOrderBasket;     // Korpa/zahtjev
public order: any = {};           // Detalji narudžbe (kada je edit/preview)
public contact: any = { contact: true };   // Kontakt osoba
public ocontact: any = {};        // Ovlaštena osoba
public ca: any = {};              // Customer Account
public ba: any = {};              // Billing Account
public sa: any = {};              // Service Account
public es: any = {};              // Event Source
public sagg: any = {};            // Service Account Group
public bagg: any = {};            // Billing Account Group
public clicked = false;           // Sprječava double-click na dugme
private params: any;              // Kopija URL parametara

public hasitems: boolean;         // Ima li stavki u korpi
public ifResponsible: Boolean = true;  // Može li korisnik editovati
public gotooverview = false;      // Može li ići na pregled
public check = false;             // Webshop provjera
```

**Inicijalne vrijednosti:**
```javascript
basket = undefined           // još nije kreiran
order = {}                   // prazan objekat
contact = { contact: true }  // default: korisnik JE kontakt osoba
ocontact = {}                // prazan objekat
ca = {}                      // prazan objekat
ba = {}                      // prazan objekat
sa = {}                      // prazan objekat
es = {}                      // prazan objekat
clicked = false              // nije kliknuto
hasitems = undefined         // još ne znamo
ifResponsible = true         // defaultno može editovati
gotooverview = false         // ne može ići na pregled
check = false                // nije prošla webshop provjera
```

---

### 1.4 Constructor - Dependency Injection (linija 59-75)

Angular koristi **Dependency Injection** pattern. Svi potrebni servisi se automatski "ubrizgavaju" u constructor.

```typescript
constructor(
  private api: RestApiService,       // HTTP pozivi
  private parse: ApiCallParse,       // Parsiranje API poziva
  private ApiDispatcher: ApiDispatcher,  // Slanje API poziva
  public search: GSearchService,     // Globalna pretraga
  private message: ToastrService,    // Notification poruke
  private role: AccessControl,       // Kontrola pristupa
  private route: ActivatedRoute,     // URL parametri
  public dnd: DragService,           // Drag & drop
  private action: Actions,           // Transformacija za spremanje
  private user: UserService,         // Info o korisniku
  public db: Model,                  // Stanje forme (db.model, db.output)
  private router: Router,            // Navigacija
  private Dependency: DependencyManager,  // Dependency tracking
  public sharedData: SharedDataService,   // Globalno stanje
  public spinner: Spinner,           // Loading indikator
  private location: Location,        // Browser location API
  private ss: SharedService          // Shared servis
) { }
```

**Najvažniji servisi:**

| Servis | Varijabla | Svrha | Primjer korištenja |
|---|---|---|---|
| `RestApiService` | `api` | HTTP pozivi | `this.api.get('/url', params)` |
| `Model` | `db` | Stanje forme | `this.db.model`, `this.db.output` |
| `Actions` | `action` | Transformacija | `this.action.save()` |
| `ActivatedRoute` | `route` | URL parametri | `this.route.queryParams` |
| `SharedDataService` | `sharedData` | Globalno stanje | `this.sharedData.customer` |
| `UserService` | `user` | User info | `this.user.user.dbuserInd` |
| `Router` | `router` | Navigacija | `this.router.navigate(['/path'])` |
| `Spinner` | `spinner` | Loading | `this.spinner.show()` |
| `ToastrService` | `message` | Poruke | `this.message.success('OK!')` |

---

## Sažetak koraka 1:

```
┌────────────────────────────────────────────────────────────────────────┐
│  KORAK 1: DEKLARACIJA KOMPONENTE                                       │
│  ════════════════════════════════                                      │
│                                                                        │
│  1. @Component decorator → povezuje klasu sa template-om i stilovima   │
│                                                                        │
│  2. [x: string]: any → dozvoljava dinamičke properties                 │
│     - Koristi se za Object.assign(this, params)                       │
│     - URL parametri se automatski kopiraju na komponentu              │
│                                                                        │
│  3. Properties → varijable stanja komponente                           │
│     - basket, order, ca, ba, sa, es → podaci o korisniku/narudžbi     │
│     - structure → dinamička forma                                     │
│     - hasitems, ifResponsible → kontrolne zastavice                   │
│                                                                        │
│  4. Constructor → Dependency Injection                                 │
│     - Angular automatski injektuje servise                            │
│     - api, db, action, router → najvažniji servisi                    │
│                                                                        │
│  NIŠTA SE JOŠ NE IZVRŠAVA!                                            │
│  Ovo je samo "priprema" - stvarna akcija počinje u ngOnInit()         │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## DODATAK: ŠTA JE `this`?

Prije nego što pređemo na `ngOnInit()`, moramo razumjeti šta je `this`.

### Osnovni koncept:

**`this` je ključna riječ koja pokazuje na TRENUTNI OBJEKAT u kojem se kod izvršava.**

Zamislite da ste u kući. Kada kažete "ovo je moja soba", pokazujete prstom na sobu u kojoj se trenutno nalazite. `this` je taj prst - pokazuje na trenutni kontekst.

---

### Primjer 1: `this` u klasi (najjednostavniji)

```typescript
class Person {
  name: string = "John";
  age: number = 30;

  greet() {
    console.log("Hello, my name is " + this.name);
    console.log("I am " + this.age + " years old");
  }
}

let person = new Person();
person.greet();
// Output:
// Hello, my name is John
// I am 30 years old
```

**Šta se desilo:**
```
person.greet() se poziva
    ↓
Unutar greet() metode, this pokazuje na "person" objekat
    ↓
this.name je zapravo person.name → "John"
this.age je zapravo person.age → 30
```

**Vizualno:**

```
┌─────────────────────────────────────┐
│  person objekat                     │
│  ═══════════════                    │
│                                     │
│  name: "John"    ← this.name        │
│  age: 30         ← this.age         │
│                                     │
│  greet() {                          │
│    console.log(this.name)  ────┐   │
│  }                             │   │
│                                │   │
└────────────────────────────────┼───┘
                                 │
                    this pokazuje na ovaj objekat
```

---

### Primjer 2: `this` u Angular komponenti

```typescript
export class VpnEvidencijaUslugeComponent {
  public basket: EvOrderBasket;
  public ca: any = {};
  public ba: any = {};

  ngOnInit() {
    this.basket = {};           // this.basket = komponenta.basket
    this.ca.id = 130025794;     // this.ca = komponenta.ca
    console.log(this.basket);   // ispisuje basket property komponente
  }

  saveBasket() {
    console.log(this.basket);   // opet pokazuje na istu komponentu
  }
}
```

**`this` u ovom slučaju pokazuje na INSTANCU komponente.**

Kada Angular kreira `VpnEvidencijaUslugeComponent`:
```javascript
let komponenta = new VpnEvidencijaUslugeComponent(...);
// "this" unutar svih metoda pokazuje na "komponenta" objekat
```

---

### Primjer 3: Višestruke instance - svaka ima svoj `this`

```typescript
class Counter {
  count: number = 0;

  increment() {
    this.count++;
    console.log("Count:", this.count);
  }
}

let counter1 = new Counter();
let counter2 = new Counter();

counter1.increment();  // Count: 1  (this = counter1)
counter1.increment();  // Count: 2  (this = counter1)

counter2.increment();  // Count: 1  (this = counter2)
counter2.increment();  // Count: 2  (this = counter2)

console.log(counter1.count);  // 2
console.log(counter2.count);  // 2
```

**Svaka instanca ima svoj `this`:**

```
┌──────────────────┐        ┌──────────────────┐
│  counter1        │        │  counter2        │
│  ════════        │        │  ════════        │
│  count: 2        │        │  count: 2        │
│                  │        │                  │
│  increment() {   │        │  increment() {   │
│    this.count++  │        │    this.count++  │
│  }               │        │  }               │
│    ↑             │        │    ↑             │
│    │             │        │    │             │
│  this pokazuje   │        │  this pokazuje   │
│  na counter1     │        │  na counter2     │
└──────────────────┘        └──────────────────┘
```

---

### Primjer 4: `this` u različitim metodama iste klase

```typescript
export class VpnEvidencijaUslugeComponent {
  public basket: any = {};
  public processId: string;

  ngOnInit() {
    this.processId = "10";       // this = komponenta
    this.assignObjects();         // poziva drugu metodu
  }

  assignObjects() {
    this.basket = {};             // this = ista komponenta
    console.log(this.processId);  // "10" - vidi processId jer je isti objekat
  }

  saveBasket() {
    console.log(this.basket);     // {} - vidi basket jer je isti objekat
    console.log(this.processId);  // "10" - vidi processId jer je isti objekat
  }
}
```

**Sve metode dijele isti `this`** jer pripadaju istoj instanci komponente:

```
┌────────────────────────────────────────────────────────┐
│  VpnEvidencijaUslugeComponent instanca                 │
│  ══════════════════════════════════════                │
│                                                        │
│  processId: "10"      ← svi this.processId pokazuju    │
│  basket: {}           ← svi this.basket pokazuju       │
│                                                        │
│  ngOnInit() {                                          │
│    this.processId = "10"  ───┐                         │
│  }                           │                         │
│                              │                         │
│  assignObjects() {           │                         │
│    console.log(this.processId) ───► Vidi "10"          │
│  }                           │                         │
│                              │                         │
│  saveBasket() {              │                         │
│    console.log(this.processId) ───► Vidi "10"          │
│  }                           │                         │
│                              │                         │
└──────────────────────────────┼─────────────────────────┘
                               │
                    SVE metode dijele isti this
```

---

### Primjer 5: `this` i konstruktor injected servisi

```typescript
constructor(
  private api: RestApiService,
  public db: Model,
  private router: Router
) { }
```

Kada se ovo izvrši, Angular radi:
```javascript
this.api = new RestApiService(...);
this.db = new Model(...);
this.router = new Router(...);
```

Kasnije u metodama:
```typescript
ngOnInit() {
  this.api.get('/url');     // this.api = servis koji je injektovan
  this.db.model = {};       // this.db = servis koji je injektovan
  this.router.navigate([]); // this.router = servis koji je injektovan
}
```

**`this` daje pristup injektovanim servisima:**

```
┌────────────────────────────────────────────────────────┐
│  VpnEvidencijaUslugeComponent instanca                 │
│  ══════════════════════════════════════                │
│                                                        │
│  api: RestApiService      ← this.api                   │
│  db: Model                ← this.db                    │
│  router: Router           ← this.router                │
│  basket: {}               ← this.basket                │
│  processId: "10"          ← this.processId             │
│                                                        │
│  ngOnInit() {                                          │
│    this.api.get('/url')    ─────► Poziva metod na api servisu │
│    this.db.model = {}      ─────► Postavlja property na db   │
│    this.basket = {}        ─────► Postavlja svoj property    │
│  }                                                     │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

### Primjer 6: `this` u Object.assign

```typescript
ngOnInit() {
  this.route.queryParams.subscribe((params: Params) => {
    Object.assign(this, params);
  });
}
```

**Šta se dešava:**

```javascript
// URL: ?processId=10&offerId=1174&caId=130025794

params = {
  processId: "10",
  offerId: "1174",
  caId: "130025794"
}

Object.assign(this, params);
// ↓ ekvivalentno sa:

this.processId = params.processId;   // "10"
this.offerId = params.offerId;       // "1174"
this.caId = params.caId;             // "130025794"
```

**Rezultat:**

```
┌────────────────────────────────────────────────────────┐
│  komponenta (this)                                     │
│  ══════════════════                                    │
│                                                        │
│  PRIJE Object.assign:                                  │
│    processId: undefined                                │
│    offerId: undefined                                  │
│    caId: undefined                                     │
│                                                        │
│  NAKON Object.assign(this, params):                    │
│    processId: "10"         ← dodano sa params          │
│    offerId: "1174"         ← dodano sa params          │
│    caId: "130025794"       ← dodano sa params          │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

### Primjer 7: Razlika između `this.property` i `let variable`

```typescript
export class MyComponent {
  public name: string = "John";  // Property na this

  ngOnInit() {
    let age = 30;                // Lokalna varijabla

    console.log(this.name);      // "John" - accessible svugdje u klasi
    console.log(age);            // 30 - accessible samo u ngOnInit

    this.otherMethod();
  }

  otherMethod() {
    console.log(this.name);      // "John" ✓ - radi!
    console.log(age);            // ERROR! ✗ - age ne postoji ovdje
  }
}
```

**Tablica:**

| Tip | Gdje se nalazi | Pristup | Životni vijek |
|---|---|---|---|
| `this.property` | Na objektu (instanci) | Iz svih metoda klase | Dok postoji instanca |
| `let variable` | Lokalno u metodi | Samo u toj metodi | Dok se metoda izvršava |

---

### Primjer 8: `this` u callback funkcijama (TRICKY!)

**Problem:**

```typescript
export class MyComponent {
  public name: string = "John";

  ngOnInit() {
    setTimeout(function() {
      console.log(this.name);  // undefined ili ERROR!
    }, 1000);
  }
}
```

**Zašto ne radi?**
- U regular funkciji (`function() {}`), `this` više ne pokazuje na komponentu
- `this` pokazuje na global objekat (window) ili je undefined

**Rješenje 1: Arrow funkcija**

```typescript
export class MyComponent {
  public name: string = "John";

  ngOnInit() {
    setTimeout(() => {
      console.log(this.name);  // "John" ✓ - radi!
    }, 1000);
  }
}
```

Arrow funkcije (`() => {}`) **naslijeđuju `this` iz nadređenog scope-a**.

**Rješenje 2: Bind**

```typescript
export class MyComponent {
  public name: string = "John";

  ngOnInit() {
    setTimeout(function() {
      console.log(this.name);  // "John" ✓ - radi!
    }.bind(this), 1000);
  }
}
```

---

### Primjer 9: `this` u evidencija-usluge - stvarni kod

```typescript
export class VpnEvidencijaUslugeComponent {
  public basket: EvOrderBasket;
  public ca: any = {};
  public structure: DynamicRest;

  constructor(
    private api: RestApiService,
    public db: Model
  ) { }

  ngOnInit() {
    this.basket = {};                    // Postavlja this.basket
    this.assignObjects();                // Poziva this.assignObjects()
    this.getDynamic('validateinformations'); // Poziva this.getDynamic()
  }

  assignObjects() {
    this.db.assign("model", { auto: {} }); // Koristi this.db (injektovani servis)
    this.structure = {};                   // Postavlja this.structure
  }

  getDynamic(callback?: any) {
    this.api.get('/pcrt/order-entry', {...}).subscribe((r: RestPayload) => {
      this.structure = r.payload;          // Postavlja this.structure
      !callback || this[callback]();       // Poziva this[callback] metodu
    });
  }

  validateinformations() {
    console.log(this.ca);                  // Pristupa this.ca
  }

  saveBasket(callback?: string) {
    this.api.post('/uomback/basket/save', this.setBasket()).subscribe((r: RestPayload) => {
      Object.assign(this.basket, r.payload);  // Ažurira this.basket
      this.saveSuicapture();                   // Poziva this.saveSuicapture()
    });
  }

  saveSuicapture() {
    let jsonSetup = {
      model: JSON.stringify({ model: this.db.model, output: this.setOutput() })
    };
    this.api.post('/uomback/suicapture', jsonSetup).subscribe();
  }
}
```

**Sve ove metode dijele isti `this`:**

```
┌─────────────────────────────────────────────────────────────────┐
│  VpnEvidencijaUslugeComponent instanca (this)                   │
│  ═════════════════════════════════════════                      │
│                                                                 │
│  PROPERTIES (this.xxx):                                         │
│  ─────────────────────                                          │
│  basket: {}                                                     │
│  ca: {}                                                         │
│  structure: DynamicRest                                         │
│                                                                 │
│  INJECTED SERVICES (this.xxx):                                  │
│  ────────────────────────────                                   │
│  api: RestApiService                                            │
│  db: Model                                                      │
│                                                                 │
│  METODE (this.xxxMethod()):                                     │
│  ──────────────────────────                                     │
│  ngOnInit() {                                                   │
│    this.basket = {}         ──┐                                 │
│    this.assignObjects()       │  SVE ove linije pristupaju      │
│  }                            │  istom "this" objektu           │
│                               │                                 │
│  assignObjects() {            │                                 │
│    this.structure = {}      ──┤                                 │
│  }                            │                                 │
│                               │                                 │
│  getDynamic() {               │                                 │
│    this.api.get(...)        ──┤                                 │
│    this.structure = ...     ──┤                                 │
│  }                            │                                 │
│                               │                                 │
│  saveBasket() {               │                                 │
│    this.api.post(...)       ──┤                                 │
│    this.basket = ...        ──┤                                 │
│    this.saveSuicapture()    ──┤                                 │
│  }                            │                                 │
│                               │                                 │
│  saveSuicapture() {           │                                 │
│    this.db.model            ──┤                                 │
│    this.api.post(...)       ──┘                                 │
│  }                                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

### Sažetak - `this` u 5 točaka:

```
┌────────────────────────────────────────────────────────────────────────┐
│                                                                        │
│  1. this = TRENUTNA INSTANCA objekta/komponente                        │
│                                                                        │
│  2. this.property = property na trenutnom objektu                      │
│                                                                        │
│  3. Sve metode iste klase dijele isti this                             │
│                                                                        │
│  4. Constructor injected servisi postaju this.servis                   │
│                                                                        │
│  5. Arrow funkcije () => {} naslijeđuju this iz parent scope-a        │
│     Regular funkcije function() {} mijenjaju this kontekst            │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Praktični savjet:

Kada god vidiš `this.nesto`, pitaj se:

1. **"Na kom objektu je ovo?"** → Na instanci komponente
2. **"Gdje je deklarirano?"** → U property dijelu klase ili u constructoru
3. **"Mogu li pristupiti iz druge metode?"** → Da, ako je `this.property`

---

## KORAK 2: ngOnInit() - Startovanje komponente (linija 79-101)

### Šta je ngOnInit()?

`ngOnInit()` je **Angular lifecycle hook** - specijalna metoda koja se automatski poziva kada Angular kreira komponentu.

**Angular lifecycle:**
```
1. Constructor  → Kreira instancu, injektuje servise
2. ngOnInit()   → Inicijalizacija (ovdje smo sada!) ←
3. ngOnChanges  → Kada se input properties promijene
4. ngOnDestroy  → Kada se komponenta uništava
```

**ngOnInit() je idealno mjesto za:**
- Učitavanje podataka sa servera
- Čitanje URL parametara
- Postavljanje inicijalnog stanja
- Subscribe na Observable-e

---

### Pregled ngOnInit() metode:

```typescript
ngOnInit() {
  console.log('   ngOnInit START');                                          // Linija 80
  this.basket = {}; this.assignObjects(); this.setcustomeraccounts();        // Linija 81

  this.subscribtion = this.route.queryParams.subscribe((params: Params) => { // Linija 83-87
    console.log('Query Params:', params);
    Object.assign(this, params); this.params = params;
    this.search.hideSearch(['11', '21', '22', '36'].indexOf(this.processId) >= 0 ? false : true);
  });

  this.route.params.subscribe((params: Params) => {                         // Linija 88-91
    console.log('Route Params:', params);
    Object.assign(this, params); this.ss.offerId = this.offerId;
  });

  console.log('basketnum:', this.basketnum, '| ordnum:', this.ordnum);       // Linija 92
  if (this.basketnum || this.ordnum) this.getResponsible();                  // Linija 93
  this.ordnum && this.getOrderDetails(this.ordnum);                          // Linija 94
  this.basketnum && this.loadDynamicData() || this.getDynamic('validateinformations'); // Linija 95

  if (this.user.employee.channelType == 'WEBSHOP' && !this.basketnum) {     // Linija 97-99
    this.check = true;
  }
  console.log('   ngOnInit END');                                            // Linija 100
}
```

Izgleda komplicirano? Idemo liniju po liniju!

---

### LINIJA 81: Inicijalizacija osnovnih objekata

```typescript
this.basket = {}; this.assignObjects(); this.setcustomeraccounts();
```

Ovo je zapravo **3 naredbe u jednoj liniji** (odvojene sa `;`):

#### 1. `this.basket = {};`

```javascript
this.basket = {};  // Kreira prazan objekat za basket
```

**Zašto prazan objekat?**
- Basket još ne postoji (novi zahtjev)
- Kasnije će biti popunjen podacima sa backenda

**Stanje:**
```javascript
PRIJE:  this.basket = undefined
NAKON:  this.basket = {}
```

#### 2. `this.assignObjects();`

Poziva metodu koja resetuje `db.model`, `db.output`, `db.params`:

**File:** `evidencija-usluge.component.ts`, linija 131
```typescript
assignObjects() {
  this.Dependency.clear();
  this.structure = {};
  this.db
    .clear(['active', 'activechild'])
    .assign("model", { auto: {} })    // db.model = { auto: {} }
    .assign("output")                  // db.output = {}
    .assign("params")                  // db.params = {}
    .assign("valid", { name: "evidencija", active: true, valid: true, errors: 0, children: {} });
}
```

**Šta radi:**
```
PRIJE assignObjects():
  db.model = undefined
  db.output = undefined
  db.params = undefined

NAKON assignObjects():
  db.model = { auto: {} }    ← Prazan model
  db.output = {}              ← Prazan output
  db.params = {}              ← Prazni parametri
  db.valid = { name: "evidencija", active: true, ... }
```

**Zašto se ovo radi?**
- Čisti prethodno stanje (ako postoji)
- Priprema "čist slate" za novu formu
- Kao da obrišeš tablu prije pisanja

#### 3. `this.setcustomeraccounts();`

Postavlja CA, BA, SA, ES podatke iz `sharedData` servisa:

**File:** `evidencija-usluge.component.ts`, linija 112-124
```typescript
setcustomeraccounts() {
  this.ca = !this.ca.id && Object.assign({}, this.sharedData.customer.customerGeneralInfo.id
    ? this.sharedData.customer.customerGeneralInfo : {});

  this.ba = !this.ba.id && Object.assign({}, this.sharedData.customer.customerBillInfo || {});
  this.es = !this.es.id && Object.assign({}, this.sharedData.customer.eventSourceInfo || {});
  this.sa = this.sharedData.customer.saInfo || {};

  if (this.sharedData.customer.baggInfo.id)
    this.bagg = this.ba = this.sharedData.customer.baggInfo;

  if (this.sharedData.customer.saggInfo.id)
    this.sagg = this.sa = this.sharedData.customer.saggInfo;

  if (this.sharedData.customer.eventSourceInfo.sacustomerId)
    this.sa.id = this.sharedData.customer.eventSourceInfo.sacustomerId;

  if (this.sharedData.customer.eventSourceInfo.saAddress)
    this.sa.address = this.sharedData.customer.eventSourceInfo.saAddress;

  if (this.ba.id && this.ba.addresses && this.ba.addresses.length) {
    this.ba.billingAddress = this.ba.addresses.find(a => a.aroletypeCode == '200').addressCodeName;
  }
}
```

**Šta radi (jednostavno objašnjeno):**
```
Kopira podatke iz globalnog sharedData servisa u lokalne properties:

sharedData.customer.customerGeneralInfo  →  this.ca
sharedData.customer.customerBillInfo     →  this.ba
sharedData.customer.eventSourceInfo      →  this.es
sharedData.customer.saInfo               →  this.sa
```

**Zašto je ovo potrebno?**
- Komponenta treba lokalne kopije CA, BA, SA podataka
- SharedData može biti promijenjen u drugim komponentama
- Lokalne kopije su "snapshot" podataka u trenutku inicijalizacije

---

### LINIJA 83-87: Subscribe na Query Parameters

```typescript
this.subscribtion = this.route.queryParams.subscribe((params: Params) => {
  console.log('Query Params:', params);
  Object.assign(this, params);
  this.params = params;
  this.search.hideSearch(['11', '21', '22', '36'].indexOf(this.processId) >= 0 ? false : true);
});
```

#### Šta su Query Parameters?

**URL primjer:**
```
https://localhost:48080/uom/evidencija/residential/1174/162/0
  ?processId=10
  &caId=130025794
  &baId=330021716
  &basketnum=257697/26
  &from=VPN
  ^
  │
  └─ Ovo su QUERY PARAMETRI (iza ?)
```

**Parsed params objekat:**
```javascript
params = {
  processId: "10",
  caId: "130025794",
  baId: "330021716",
  basketnum: "257697/26",
  from: "VPN"
}
```

#### Šta radi `.subscribe()`?

Angular `queryParams` je **Observable** - stream podataka koji se može promijeniti.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Observable = STREAM podataka                                       │
│  ═══════════════════════════                                        │
│                                                                     │
│  Zamislite rijeku:                                                  │
│  ───────────────────                                                │
│  Observable je rijeka, a subscribe() je mreža koja hvata podatke    │
│                                                                     │
│  Kada se URL promijeni → novi params "propliva" rijekom             │
│                       → subscribe() "uhvati" i procesira            │
│                                                                     │
│  route.queryParams    →  [params1]  [params2]  [params3] ...       │
│                            │          │          │                  │
│                            ▼          ▼          ▼                  │
│  .subscribe(params => {                                             │
│    // Procesiranje svakog params objekta                            │
│  })                                                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

#### Linija po linija:

**Linija 84:**
```typescript
console.log('Query Params:', params);
```
Ispisuje u konzolu browser-a koji su parametri primljeni.

**Linija 85:**
```typescript
Object.assign(this, params);
```

**OVO JE KLJUČNA LINIJA!**

Kopira SVE properties iz `params` objekta na `this` (komponentu):

```javascript
params = {
  processId: "10",
  caId: "130025794",
  baId: "330021716",
  basketnum: "257697/26"
}

Object.assign(this, params);

// Ekvivalentno sa:
this.processId = "10";
this.caId = "130025794";
this.baId = "330021716";
this.basketnum = "257697/26";
```

**Vizualno:**

```
PRIJE Object.assign:
┌──────────────────────────┐
│  this (komponenta)       │
│  ══════════════          │
│  processId: undefined    │
│  caId: undefined         │
│  baId: undefined         │
│  basketnum: undefined    │
└──────────────────────────┘

NAKON Object.assign(this, params):
┌──────────────────────────┐
│  this (komponenta)       │
│  ══════════════          │
│  processId: "10"         │ ← Dodano
│  caId: "130025794"       │ ← Dodano
│  baId: "330021716"       │ ← Dodano
│  basketnum: "257697/26"  │ ← Dodano
└──────────────────────────┘
```

**Linija 85 (nastavak):**
```typescript
this.params = params;
```
Sprema kopiju `params` objekta u `this.params` za kasnije korištenje.

**Linija 86:**
```typescript
this.search.hideSearch(['11', '21', '22', '36'].indexOf(this.processId) >= 0 ? false : true);
```

Kontrolira da li se prikazuje globalna pretraga. Hajde da razložimo:

```typescript
['11', '21', '22', '36'].indexOf(this.processId) >= 0 ? false : true
 │                         │                       │      │      │
 │                         │                       │      │      └─ Ako nije u listi → sakrij
 │                         │                       │      └─ Ako je u listi → prikaži
 │                         │                       └─ Provjeri da li je pronađen
 │                         └─ Traži processId u listi
 └─ Lista processId-eva gdje se globalna pretraga prikazuje
```

**Primjer:**
```javascript
// SCENARIJ 1: processId = "10"
['11', '21', '22', '36'].indexOf("10")  // -1 (nije u listi)
-1 >= 0  // false
false ? false : true  // true
this.search.hideSearch(true)  // SAKRIJ pretragu

// SCENARIJ 2: processId = "11"
['11', '21', '22', '36'].indexOf("11")  // 0 (na indexu 0)
0 >= 0  // true
true ? false : true  // false
this.search.hideSearch(false)  // PRIKAŽI pretragu
```

---

### LINIJA 88-91: Subscribe na Route Parameters

```typescript
this.route.params.subscribe((params: Params) => {
  console.log('Route Params:', params);
  Object.assign(this, params);
  this.ss.offerId = this.offerId;
});
```

#### Šta su Route Parameters?

**URL primjer:**
```
https://localhost:48080/uom/evidencija/residential/1174/162/0?processId=10
                                          │          │    │   │
                                          │          │    │   └─ type = 0
                                          │          │    └─ specId = 162
                                          │          └─ offerId = 1174
                                          └─ type = residential

Ovo su ROUTE PARAMETRI (dio path-a)
```

**Parsed params objekat:**
```javascript
params = {
  type: "residential",
  offerId: "1174",
  specId: "162",
  type: "0"  // može biti duplikat
}
```

**Razlika između Query i Route params:**

| Tip | Gdje | Primjer | Kada se mijenjaju |
|---|---|---|---|
| **Query params** | Nakon `?` | `?processId=10&caId=123` | Navigacija sa queryParams |
| **Route params** | U path-u | `/evidencija/:type/:offerId/:specId` | Navigacija na drugi route |

**Linija 90:**
```typescript
Object.assign(this, params);
```
Opet kopira sve route params na komponentu (isti princip kao query params).

**Linija 90 (nastavak):**
```typescript
this.ss.offerId = this.offerId;
```
Sprema `offerId` u SharedService da ga drugi dijelovi aplikacije mogu koristiti.

---

### LINIJA 92-95: Odlučivanje koja metoda se poziva

Ovo je **najvažniji dio ngOnInit()** - ovdje se odlučuje da li se učitava:
- **Nova forma** (prva poseta)
- **Postojeći basket** (reload)
- **Postojeća narudžba** (edit/preview)

```typescript
console.log('basketnum:', this.basketnum, '| ordnum:', this.ordnum);       // Linija 92
if (this.basketnum || this.ordnum) this.getResponsible();                  // Linija 93
this.ordnum && this.getOrderDetails(this.ordnum);                          // Linija 94
this.basketnum && this.loadDynamicData() || this.getDynamic('validateinformations'); // Linija 95
```

#### LINIJA 92: Debug ispis

```typescript
console.log('basketnum:', this.basketnum, '| ordnum:', this.ordnum);
```

Ispisuje u konzolu da vidiš šta je postavljeno:
```
basketnum: undefined | ordnum: undefined     ← Nova forma
basketnum: 257697/26 | ordnum: undefined     ← Reload basket-a
basketnum: undefined | ordnum: 257697-01/26  ← Edit narudžbe
```

#### LINIJA 93: Provjera odgovornosti

```typescript
if (this.basketnum || this.ordnum) this.getResponsible();
```

**Logika:**
```
AKO postoji basketnum ILI ordnum
  ONDA pozovi getResponsible()
```

**Što radi `getResponsible()`?** (linija 108-111)
```typescript
getResponsible() {
  let request = this.ordnum
    ? { ordnum: this.ordnum, dbuserInd: this.user.user.dbuserInd }
    : { ordnum: this.basketnum, dbuserInd: this.user.user.dbuserInd };

  this.api.get('/uomback/sordresponsible/checkifresponsible', request)
    .subscribe((r: any) => {
      this.ifResponsible = r.payload;
    });
}
```

**Šta radi:**
- Pita backend: "Može li trenutni korisnik editovati ovaj basket/order?"
- Backend vraća `true` ili `false`
- Postavlja `this.ifResponsible`

**Zašto je ovo važno:**
```typescript
// U template-u:
<button [ngClass]="{inactive: !ifResponsible}">Spasi</button>
<input [disabled]="!ifResponsible">

// Ako ifResponsible = false → dugme i input su disabled
```

#### LINIJA 94: Učitavanje detalja narudžbe

```typescript
this.ordnum && this.getOrderDetails(this.ordnum);
```

**Logika:**
```
AKO postoji ordnum
  ONDA pozovi getOrderDetails(ordnum)
```

Ovo je **short circuit evaluacija**:
```javascript
this.ordnum && this.getOrderDetails(this.ordnum)
    ↓
AKO je this.ordnum truthy (postoji)
  ONDA izvršava desnu stranu: this.getOrderDetails(this.ordnum)

AKO je this.ordnum falsy (undefined)
  SHORT CIRCUIT - ne izvršava se desna strana
```

**Što radi `getOrderDetails()`?** (linija 417)
```typescript
getOrderDetails(ordnum) {
  this.spinner.show();
  this.api.get('/uomback/sorder/info', { 'ordnum': ordnum })
    .subscribe((r: any) => {
      this.order = r.payload;
      this.spinner.hide();
    });
}
```

Dohvaća detalje postojeće narudžbe sa backenda.

#### LINIJA 95: NAJVAŽNIJA LINIJA - Load ili create

```typescript
this.basketnum && this.loadDynamicData() || this.getDynamic('validateinformations');
```

Ovo izgleda komplicirano, ali je zapravo logično. Hajde da ga razložimo:

**Logika:**
```
AKO postoji basketnum
  ONDA pozovi loadDynamicData()  (učitaj postojeći basket)
INAČE
  POZOVI getDynamic('validateinformations')  (nova forma)
```

**Detaljno razbijanje:**

```typescript
this.basketnum && this.loadDynamicData() || this.getDynamic('validateinformations')
│              │   │                      │   │
│              │   │                      │   └─ Desna strana ||
│              │   │                      └─ || operator
│              │   └─ Desna strana &&
│              └─ && operator
└─ Lijeva strana &&
```

**Evaluacija korak po korak:**

**SCENARIJ A: basketnum POSTOJI (reload postojećeg basket-a)**
```javascript
basketnum = "257697/26"

this.basketnum && this.loadDynamicData() || this.getDynamic('validateinformations')
      ↓
"257697/26" && this.loadDynamicData()
      ↓
truthy && this.loadDynamicData()
      ↓
Izvršava se: this.loadDynamicData()
      ↓
loadDynamicData() vraća: true
      ↓
true || this.getDynamic('validateinformations')
      ↓
SHORT CIRCUIT - ne poziva se getDynamic()
      ↓
REZULTAT: Pozvan je SAMO loadDynamicData()
```

**SCENARIJ B: basketnum NE POSTOJI (nova forma)**
```javascript
basketnum = undefined

this.basketnum && this.loadDynamicData() || this.getDynamic('validateinformations')
      ↓
undefined && this.loadDynamicData()
      ↓
falsy && ...
      ↓
SHORT CIRCUIT na && → vraća undefined
      ↓
undefined || this.getDynamic('validateinformations')
      ↓
falsy || this.getDynamic('validateinformations')
      ↓
Izvršava se: this.getDynamic('validateinformations')
      ↓
REZULTAT: Pozvan je SAMO getDynamic()
```

**Vizualna tablica odluka:**

```
┌─────────────┬─────────┬──────────────────────────────────────┐
│ basketnum   │ ordnum  │ Što se poziva                        │
├─────────────┼─────────┼──────────────────────────────────────┤
│ undefined   │ undef   │ getDynamic('validateinformations')   │
│             │         │ → NOVA FORMA                         │
├─────────────┼─────────┼──────────────────────────────────────┤
│ "257697/26" │ undef   │ loadDynamicData()                    │
│             │         │ → RELOAD BASKET-A                    │
├─────────────┼─────────┼──────────────────────────────────────┤
│ undefined   │"257.."  │ getDynamic('validateinformations')   │
│             │         │ + getOrderDetails(ordnum)            │
│             │         │ → EDIT/PREVIEW NARUDŽBE              │
└─────────────┴─────────┴──────────────────────────────────────┘
```

---

### LINIJA 97-99: Webshop provjera

```typescript
if (this.user.employee.channelType == 'WEBSHOP' && !this.basketnum) {
  this.check = true;
}
```

**Logika:**
```
AKO je korisnik iz WEBSHOP kanala
  I nema basketnum (nova forma)
ONDA postavi check = true
```

**Što radi `check` flag:**
```typescript
// U template-u (linija 226-227):
<button *ngIf="user.employee.channelType == 'WEBSHOP'" class="btn-check"
  (click)="checkWSH()">
  <i class='fa fa-check-circle'></i> Provjera
</button>
```

Prikazuje dugme "Provjera" za webshop korisnike koje moraju provjeriti broj webshop zahtjeva prije nego nastave.

---

### LINIJA 100: Debug ispis

```typescript
console.log('   ngOnInit END');
```

Označava kraj `ngOnInit()` metode u konzoli.

---

## Sažetak KORAK 2:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ngOnInit() - TOK IZVRŠAVANJA                                       │
│  ════════════════════════════                                       │
│                                                                     │
│  1. Inicijalizacija:                                                │
│     - this.basket = {}                                              │
│     - assignObjects() → db.model = {auto:{}}, db.output = {}        │
│     - setcustomeraccounts() → kopira CA, BA, SA iz sharedData       │
│                                                                     │
│  2. Subscribe na URL parametre:                                     │
│     - queryParams → processId, caId, basketnum, ...                 │
│     - routeParams → type, offerId, specId, ...                      │
│     - Object.assign(this, params) → kopira sve na komponentu        │
│                                                                     │
│  3. Odluka - koja metoda se poziva:                                 │
│                                                                     │
│     A) basketnum POSTOJI → loadDynamicData()                        │
│        - Dohvata suicapture iz baze                                 │
│        - Restaurira db.model, db.output                             │
│        - Prikazuje prethodno unesene podatke                        │
│                                                                     │
│     B) basketnum NE POSTOJI → getDynamic('validateinformations')    │
│        - Dohvata strukturu forme sa backenda                        │
│        - Renderira praznu formu                                     │
│        - Korisnik unosi nove podatke                                │
│                                                                     │
│  4. Dodatne provjere:                                               │
│     - getResponsible() → može li korisnik editovati                 │
│     - getOrderDetails() → dohvata detalje narudžbe (ako ordnum)     │
│     - check flag za webshop korisnike                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## DODATAK: Callback parametar u getDynamic()

Prije nego što pređemo na KORAK 3, hajde da detaljno objasnimo ovaj poziv:

```typescript
this.getDynamic('validateinformations')
```

### Šta znači `'validateinformations'`?

To je **string koji predstavlja IME METODE** koja će biti pozvana NAKON što se `getDynamic()` izvrši.

**To nije:**
- ❌ Vrijednost koja se šalje backendu
- ❌ Neki poseban parametar
- ❌ Keyword ili reserved word

**To jeste:**
- ✅ **Callback** - ime metode koju treba pozvati kasnije
- ✅ String koji pokazuje na metodu `validateinformations()` (linija 126-129)

---

### Kako ovo radi - Callback Pattern

**Definicija metode getDynamic()** (linija 183-199):

```typescript
getDynamic(callback?: any) {              // ← Prima parametar "callback"
  console.log('   getDynamic START');
  console.log('callback:', callback);     // "validateinformations"

  if (this.orderEntrySetupRequests) {
    this.getGroupDynamic(callback);
  } else {
    this.db.setmod(...);

    this.api.get('/pcrt/order-entry', {...}).subscribe((r: RestPayload) => {
      console.log('=== /pcrt/order-entry RESPONSE ===');
      this.structure = r.payload;
      this.db.update(...);

      !callback || this[callback]();     // ← OVDJE SE POZIVA CALLBACK!
      //             ^^^^^^^^^^^^^^^^
      //             Ovo je NAJVAŽNIJE!
    });
  }
}
```

---

### Detaljna analiza linije 194:

```typescript
!callback || this[callback]();
```

Hajde da ovo razložimo kao IF-ELSE:

```typescript
// Originalno:
!callback || this[callback]();

// Jednako kao:
if (!callback) {
  // Ništa (short circuit)
} else {
  this[callback]();  // Pozovi metodu
}

// Ili kraće:
if (callback) {
  this[callback]();
}
```

**Šta je `this[callback]`?**

To je **bracket notacija** za pristupanje property-jima objekta.

```typescript
// Ove dvije sintakse su ISTE:
this.validateinformations()    // Dot notation
this['validateinformations']() // Bracket notation

// Sa callback varijablom:
callback = 'validateinformations'
this[callback]()               // Evaluira se u: this['validateinformations']()
                               // Što je jednako: this.validateinformations()
```

---

### Primjer 1: Kako bracket notacija radi

```typescript
export class MyCar {
  public startEngine() {
    console.log('Vroom!');
  }

  public stopEngine() {
    console.log('Engine stopped');
  }

  public executeAction(actionName: string) {
    // actionName = "startEngine"
    this[actionName]();  // Poziva this.startEngine()
  }
}

// Korištenje:
const car = new MyCar();
car.executeAction('startEngine');  // Ispisuje: "Vroom!"
car.executeAction('stopEngine');   // Ispisuje: "Engine stopped"
```

**Zašto je ovo korisno?**
- Ne moraš unaprijed znati koju metodu ćeš pozvati
- Naziv metode može doći kao parametar
- Flexibilnost - možeš pozvati različite metode sa istom logikom

---

### Primjer 2: U našem slučaju

```typescript
// POZIV:
this.getDynamic('validateinformations')
                 │
                 └─ Ovaj string se prosljeđuje kao parametar "callback"

// UNUTAR getDynamic():
getDynamic(callback?: any) {  // callback = 'validateinformations'

  this.api.get('/pcrt/order-entry', {...}).subscribe((r: RestPayload) => {
    this.structure = r.payload;

    // LINIJA 194:
    !callback || this[callback]();
    //           ├──────────────┘
    //           └─ Evaluira se u:
    //              this['validateinformations']()
    //              što je isto kao:
    //              this.validateinformations()
  });
}
```

---

### Korak po korak izvršavanje:

```
KORAK 1: Poziv
────────────────────────────────────────────────────────────
this.getDynamic('validateinformations')
                │
                └─ callback = 'validateinformations'


KORAK 2: getDynamic() šalje API poziv
────────────────────────────────────────────────────────────
this.api.get('/pcrt/order-entry', {...})
     │
     └─ Šalje HTTP request na backend


KORAK 3: Backend vraća strukturu forme
────────────────────────────────────────────────────────────
Backend response: { structure: {...}, parameters: {...} }


KORAK 4: subscribe() callback se izvršava
────────────────────────────────────────────────────────────
this.structure = r.payload;   ← Sprema strukturu
this.db.update(...);          ← Ažurira db.params


KORAK 5: Poziva se callback metoda
────────────────────────────────────────────────────────────
!callback || this[callback]()
             │
             ├─ callback = 'validateinformations'
             │
             └─ this['validateinformations']()
                │
                └─ this.validateinformations()  ← POZIVA SE METODA!


KORAK 6: validateinformations() se izvršava
────────────────────────────────────────────────────────────
validateinformations() {
  let valid: string[] = this.r
    ? this.r.filter((required: string) =>
        !this[required] || !Object.keys(this[required]).length
      )
    : [];

  !valid.length ||
    setTimeout(() => {
      this.message.warning(
        "Evidencija mora da sadrži (" +
        valid.join(", ").toUpperCase() +
        ") korisnika!"
      ) && this.location.back()
    }, 100);
}
```

---

### Šta radi `validateinformations()` metoda?

**File:** `evidencija-usluge.component.ts`, linija 126-129

```typescript
validateinformations() {
  let valid: string[] = this.r
    ? this.r.filter((required: string) =>
        !this[required] || !Object.keys(this[required]).length
      )
    : [];

  !valid.length ||
    setTimeout(() => {
      this.message.warning(
        "Evidencija mora da sadrži (" +
        valid.join(", ").toUpperCase() +
        ") korisnika!"
      ) && this.location.back()
    }, 100);
}
```

**Šta ovo radi:**

#### DIO 1: Provjera required polja

```typescript
let valid: string[] = this.r
  ? this.r.filter((required: string) =>
      !this[required] || !Object.keys(this[required]).length
    )
  : [];
```

**Razlaženje:**

```typescript
// this.r može biti nešto kao:
this.r = ['ca', 'ba', 'contact']

// Filter prolazi kroz svaki element:
this.r.filter((required: string) => {
  // required = 'ca'
  // Provjerava:
  !this[required]                         // Postoji li this.ca?
  ||                                      // ILI
  !Object.keys(this[required]).length     // this.ca je prazan objekat?
})
```

**Primjer:**

```javascript
// SCENARIJ 1: Sve OK
this.ca = { id: '130025794', customerinfo: {...} }  // Popunjen
this.ba = { id: '330021716', customerName: '...' }  // Popunjen
this.contact = { id: '123', firstname: 'Marko' }    // Popunjen

valid = []  // Prazan array - SVE JE OK!


// SCENARIJ 2: Nešto fali
this.ca = { id: '130025794', customerinfo: {...} }  // OK
this.ba = {}                                        // PRAZAN!
this.contact = undefined                            // NE POSTOJI!

valid = ['ba', 'contact']  // Array sa nedostajućim poljima!
```

#### DIO 2: Prikaz upozorenja

```typescript
!valid.length ||
  setTimeout(() => {
    this.message.warning(
      "Evidencija mora da sadrži (" +
      valid.join(", ").toUpperCase() +
      ") korisnika!"
    ) && this.location.back()
  }, 100);
```

**Razlaženje:**

```typescript
// !valid.length = true SAMO ako je valid prazan array ([])
// || znači: ako je lijeva strana FALSE, izvršava desnu

if (valid.length > 0) {  // Ako nešto fali
  setTimeout(() => {
    // Prikaži warning poruku:
    this.message.warning(
      "Evidencija mora da sadrži (BA, CONTACT) korisnika!"
    );

    // I vrati se nazad:
    this.location.back();
  }, 100);
}
```

**Primjer poruke:**

```
┌──────────────────────────────────────────────────────┐
│  ⚠️  WARNING                                         │
│                                                      │
│  Evidencija mora da sadrži (BA, CONTACT) korisnika! │
│                                                      │
└──────────────────────────────────────────────────────┘

... i korisnik se vraća na prethodnu stranicu
```

---

### Zašto se `validateinformations()` poziva NAKON getDynamic()?

```
REDOSLIJED JE VAŽAN:

1. getDynamic() šalje API poziv
   ↓
2. API vraća strukturu forme
   ↓
3. this.structure = r.payload  (sprema strukturu)
   ↓
4. this.db.update(...)  (ažurira db.params)
   ↓
5. validateinformations()  ← TEK SADA!
   │
   └─ ZAŠTO TEK SADA?
      Jer prije ovog trenutka this.r nije postavljen!

      this.r se postavlja u db.update() ili structure.parameters

      Ako bi validateinformations() bio pozvan PRIJE,
      this.r bi bio undefined i validacija ne bi radila!
```

---

### Drugi primjeri callback-a u ovoj komponenti

**1. `getDynamic('setStructure')`** (linija 369):
```typescript
this.getDynamic('setStructure');
// ↓ poziva this.setStructure() nakon što se struktura učita
```

**2. `getGroupDynamic(callback)`** (linija 186):
```typescript
if (this.orderEntrySetupRequests) {
  this.getGroupDynamic(callback);  // Prosljeđuje callback dalje
}
```

---

### Alternativni načini implementacije (za razumijevanje)

**NAČIN 1: Bez callback-a (direktan poziv)**
```typescript
// Loše - moramo duplicirati kod
ngOnInit() {
  if (basketnum) {
    this.loadDynamicData();
  } else {
    this.getDynamic();
    this.validateinformations();  // Ovdje problem - poziva se PRE nego što struktura stigne!
  }
}

getDynamic() {
  this.api.get(...).subscribe((r: RestPayload) => {
    this.structure = r.payload;
    // validateinformations je već pozvan - nema this.r!
  });
}
```

**NAČIN 2: Sa Promise/async-await (moderan pristup)**
```typescript
async ngOnInit() {
  if (basketnum) {
    await this.loadDynamicData();
  } else {
    await this.getDynamic();
    this.validateinformations();  // Sada je OK
  }
}

async getDynamic() {
  const r = await this.api.get(...).toPromise();
  this.structure = r.payload;
}
```

**NAČIN 3: Sa callback-om (trenutna implementacija)**
```typescript
ngOnInit() {
  if (basketnum) {
    this.loadDynamicData();
  } else {
    this.getDynamic('validateinformations');  // Callback
  }
}

getDynamic(callback?: any) {
  this.api.get(...).subscribe((r: RestPayload) => {
    this.structure = r.payload;
    !callback || this[callback]();  // Poziva validateinformations() u pravom trenutku
  });
}
```

---

### Vizualni dijagram callback flow-a

```
┌───────────────────────────────────────────────────────────────────┐
│  ngOnInit()                                                       │
│  ═══════════                                                      │
│                                                                   │
│  this.getDynamic('validateinformations')                         │
│         │                                                         │
│         └────────────────────────────────────┐                   │
└──────────────────────────────────────────────│───────────────────┘
                                               │
                                               ↓
┌───────────────────────────────────────────────────────────────────┐
│  getDynamic(callback)                                             │
│  ═══════════════════                                              │
│                                                                   │
│  callback = 'validateinformations'  ← Spreman string              │
│                                                                   │
│  this.api.get('/pcrt/order-entry', {...})                        │
│         │                                                         │
│         └──────────► HTTP Request ──────┐                        │
│                                          │                        │
└──────────────────────────────────────────│────────────────────────┘
                                           │
                    ┌──────────────────────┘
                    │
                    ↓
           ╔════════════════════╗
           ║  BACKEND SERVER    ║
           ║  ═══════════       ║
           ║  /pcrt/order-entry ║
           ╚════════════════════╝
                    │
                    │ response: { structure: {...}, parameters: {...} }
                    │
                    ↓
┌───────────────────────────────────────────────────────────────────┐
│  subscribe() callback                                             │
│  ═══════════════════                                              │
│                                                                   │
│  this.structure = r.payload;  ← Struktura spremljena             │
│  this.db.update(...);         ← db.params ažurirani              │
│                                                                   │
│  !callback || this[callback]();                                  │
│                     │                                             │
│                     └─────────────────────────┐                  │
└───────────────────────────────────────────────│──────────────────┘
                                                │
                                                ↓
┌───────────────────────────────────────────────────────────────────┐
│  this[callback]()                                                 │
│  ═══════════════                                                  │
│                                                                   │
│  this['validateinformations']()                                  │
│         │                                                         │
│         └────────────────────────────────────┐                   │
└──────────────────────────────────────────────│───────────────────┘
                                               │
                                               ↓
┌───────────────────────────────────────────────────────────────────┐
│  validateinformations()                                           │
│  ═══════════════════                                              │
│                                                                   │
│  let valid = this.r.filter(...)  ← Provjerava CA, BA, CONTACT    │
│                                                                   │
│  if (valid.length > 0) {                                          │
│    this.message.warning("Fali " + valid.join(", "))              │
│    this.location.back()  ← Vraća korisnika                       │
│  }                                                                │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

---

### Sažetak - Callback pattern

```
┌─────────────────────────────────────────────────────────────────────┐
│  CALLBACK PATTERN - Jednostavno objašnjenje                         │
│  ═══════════════════════════════════════════                        │
│                                                                     │
│  1. Šalješ IME METODE kao string parametar                          │
│     getDynamic('validateinformations')                              │
│                 │                                                   │
│                 └─ String "validateinformations"                    │
│                                                                     │
│  2. Metoda sprema callback parametar                                │
│     getDynamic(callback?: any) { ... }                              │
│                │                                                    │
│                └─ callback = "validateinformations"                 │
│                                                                     │
│  3. Nakon async operacije (API call), poziva callback               │
│     this.api.get(...).subscribe(() => {                             │
│       this.structure = r.payload;                                   │
│       this[callback]();  ← OVDJE SE POZIVA!                         │
│     });                                                             │
│                                                                     │
│  4. Bracket notacija dinamički poziva metodu                        │
│     this[callback]()                                                │
│     this['validateinformations']()                                  │
│     this.validateinformations()  ← Ovo se izvršava                  │
│                                                                     │
│  5. validateinformations() provjerava da li fali CA, BA, CONTACT    │
│     - Ako fali → warning + vrati se nazad                           │
│     - Ako ne fali → nastavi normalno                                │
│                                                                     │
│  ZAŠTO CALLBACK?                                                    │
│  ─────────────────                                                  │
│  Da se validateinformations() pozove NAKON što struktura            │
│  stigne sa backenda, jer validateinformations() koristi             │
│  this.r koje se postavlja tek nakon što struktura bude učitana     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## KORAK 3B: getDynamic() - Dohvatanje strukture forme (linija 183-199)

### Uvod

`getDynamic()` je **ključna metoda** koja dohvata strukturu dinamičke forme sa backenda. Ova struktura definiše koja polja se prikazuju, validaciju, default vrijednosti, itd.

**Kada se poziva:**
- Kada basketnum **NE POSTOJI** (nova forma)
- Kada korisnik prvi put dolazi na formu
- Kada nema spremljenih podataka u suicapture tabeli

**Šta radi:**
1. Postavlja `db.mod` (disabled/preview/edit)
2. Šalje API poziv `/pcrt/order-entry` na backend
3. Prima strukturu forme kao response
4. Sprema strukturu u `this.structure`
5. Ažurira `db.params` sa parametrima
6. Poziva callback funkciju (npr. `validateinformations()`)

---

### Pregled kompletne metode:

```typescript
getDynamic(callback?: any) {                                              // Linija 183
  console.log('   getDynamic START');                                     // Linija 184
  console.log('callback:', callback);                                     // Linija 185

  if (this.orderEntrySetupRequests) {                                     // Linija 186
    this.getGroupDynamic(callback);
  } else {
    this.db.setmod(                                                       // Linija 187
      this.ordnum,
      this.basketnum,
      this.ca.id,
      this.ba.id,
      !this.basket.save ? "disabled" : !this.ifResponsible ||
        (this.sharedData.basket && this.sharedData.basket.status &&
         this.sharedData.basket.status === '15') ? 'preview' : undefined,
      this.patch
    );

    console.log('db.mod:', this.db.mod);                                  // Linija 189
    console.log('API poziv /pcrt/order-entry sa:', {                      // Linija 190
      productOfferId: this.offerId,
      productSpecificationId: this.specId,
      appProcessId: this.processId
    });

    this.api.get('/pcrt/order-entry', {                                   // Linija 191
      interactionId: 16,
      productOfferId: this.offerId,
      productSpecificationId: this.specId,
      appProcessId: this.processId,
      setupType: this.setupType
    }).subscribe((r: RestPayload) => {
      console.log('=== /pcrt/order-entry RESPONSE ===');                  // Linija 192
      console.log('structure:', r.payload);                               // Linija 193

      this.structure = r.payload;                                         // Linija 194 (dio 1)
      this.db.update(                                                     // Linija 194 (dio 2)
        this.db.params,
        Object.assign(
          Object.assign(this.structure.parameters, this.params),
          this.setparms()
        )
      );
      !callback || this[callback]();                                      // Linija 194 (dio 3)

      console.log('db.params NAKON update:', this.db.params);             // Linija 195
    });

    if (this.db.mod === 'preview') {                                      // Linija 196
      this.basket.headbasketnum = this.headordnum;
    }
  }
  console.log('   getDynamic END');                                       // Linija 198
}
```

Izgleda kompleksno? Idemo liniju po liniju!

---

### LINIJA 183: Potpis metode

```typescript
getDynamic(callback?: any) {
```

**Parametri:**
- `callback?: any` - **Opcionalni** parametar
  - `?` znači da je **optional** (može biti undefined)
  - `any` znači da može biti bilo koji tip (string, function, number...)
  - U praksi: uvijek je **string** (ime metode)

**Primjeri poziva:**

```typescript
// SA callback-om:
this.getDynamic('validateinformations')
// callback = 'validateinformations'

// BEZ callback-a:
this.getDynamic()
// callback = undefined

// SA drugim callback-om:
this.getDynamic('setStructure')
// callback = 'setStructure'
```

---

### LINIJA 184-185: Debug ispisi

```typescript
console.log('   getDynamic START');
console.log('callback:', callback);
```

**Primjer konzolnog ispisa:**

```
   getDynamic START
callback: validateinformations
```

Ovo pomaže u debuggingu da vidiš:
- Kada se metoda poziva
- Koji callback je proslijeđen

---

### LINIJA 186: Provjera orderEntrySetupRequests

```typescript
if (this.orderEntrySetupRequests) {
  this.getGroupDynamic(callback);
} else {
  // Normalan flow (ovdje ćemo se fokusirati)
}
```

**Šta je `orderEntrySetupRequests`?**

To je **poseban parametar** koji dolazi iz URL-a u nekim slučajevima:

```
URL primjer 1 (normalan):
/evidencija/residential/1174/162/0?processId=10&caId=130025794
→ orderEntrySetupRequests = undefined
→ Poziva normalan flow (else blok)

URL primjer 2 (grupna narudžba):
/evidencija/residential/1174/162/0?processId=10&orderEntrySetupRequests=[{...}]
→ orderEntrySetupRequests = "[{...}]"
→ Poziva getGroupDynamic() (za grupne narudžbe)
```

**Za sada fokus na ELSE blok** (normalan flow) - getGroupDynamic() ćemo objasniti kasnije.

---

### LINIJA 187-188: db.setmod() - Postavljanje moda

```typescript
this.db.setmod(
  this.ordnum,        // undefined (nova forma)
  this.basketnum,     // undefined (nova forma)
  this.ca.id,         // 130025794 (CA ID)
  this.ba.id,         // 330021716 (BA ID)
  !this.basket.save ? "disabled" :
    !this.ifResponsible ||
    (this.sharedData.basket && this.sharedData.basket.status &&
     this.sharedData.basket.status === '15') ? 'preview' : undefined,
  this.patch
);
```

#### Šta je db.setmod()?

**File:** `model.service.ts`, linija 23

```typescript
public setmod(order?: string, basket?: string, ca?: number, ids?: number,
              force?: string, patch?: string) {
  this.patch = patch;
  this.mod = force ||
    ['disabled', 'new', 'edit', 'preview'][
      order && basket ? 3 :    // 'preview' - postoji order I basket
      basket ? 2 :             // 'edit' - postoji samo basket
      ca && ids ? 1 :          // 'new' - postoji CA i BA
      0                        // 'disabled' - ništa ne postoji
    ];
}
```

#### Detaljno razlaganje setmod() logike:

**Parametri:**
1. `order` - ordnum (broj narudžbe)
2. `basket` - basketnum (broj basket-a)
3. `ca` - CA ID
4. `ids` - BA ID
5. `force` - forsirani mod (override)
6. `patch` - da li je patch mode

**Logika odlučivanja:**

```typescript
this.mod = force || ['disabled', 'new', 'edit', 'preview'][index]
           │        │                                       │
           │        │                                       └─ Index u array-u
           │        └─ Array sa modovima [0, 1, 2, 3]
           └─ Ako postoji force, koristi force (override)

// Index se određuje sa:
index = order && basket ? 3 :    // Oba postoje → index 3 → 'preview'
        basket ? 2 :             // Samo basket → index 2 → 'edit'
        ca && ids ? 1 :          // CA i BA → index 1 → 'new'
        0                        // Ništa → index 0 → 'disabled'
```

**Tablica odlučivanja:**

```
┌────────────┬────────────┬────────┬────────┬───────┬──────────────┐
│ ordnum     │ basketnum  │ ca.id  │ ba.id  │ Index │ db.mod       │
├────────────┼────────────┼────────┼────────┼───────┼──────────────┤
│ undefined  │ undefined  │ undef  │ undef  │   0   │ 'disabled'   │
├────────────┼────────────┼────────┼────────┼───────┼──────────────┤
│ undefined  │ undefined  │ 130... │ 330... │   1   │ 'new'        │
│            │            │ (CA)   │ (BA)   │       │              │
├────────────┼────────────┼────────┼────────┼───────┼──────────────┤
│ undefined  │ 257697/26  │ ...    │ ...    │   2   │ 'edit'       │
├────────────┼────────────┼────────┼────────┼───────┼──────────────┤
│ 257697-... │ 257697/26  │ ...    │ ...    │   3   │ 'preview'    │
└────────────┴────────────┴────────┴────────┴───────┴──────────────┘
```

**Force parametar (5. argument):**

U našem slučaju (linija 187):

```typescript
!this.basket.save ? "disabled" :
  !this.ifResponsible ||
  (this.sharedData.basket && this.sharedData.basket.status &&
   this.sharedData.basket.status === '15') ? 'preview' : undefined
```

**Razlaženje:**

```javascript
// DIO 1: !this.basket.save ? "disabled"
Ako basket.save ne postoji (prazan objekat)
  → force = "disabled"
INAČE
  ↓ DIO 2

// DIO 2: !this.ifResponsible ? 'preview'
Ako korisnik NIJE odgovoran (ne može editovati)
  → force = 'preview'
INAČE
  ↓ DIO 3

// DIO 3: status === '15' ? 'preview'
Ako basket ima status '15' (otkazan ili završen)
  → force = 'preview'
INAČE
  → force = undefined (koristi normalan mod iz index-a)
```

**Primjeri:**

```javascript
// SCENARIJ 1: Nova forma, korisnik može editovati
ordnum = undefined
basketnum = undefined
ca.id = 130025794
ba.id = 330021716
basket.save = undefined
ifResponsible = true

force = !undefined ? "disabled" : ...
      = true ? "disabled" : ...
      = "disabled"

db.mod = "disabled"  // Force override!


// SCENARIJ 2: Nova forma, basket ima save flag
ordnum = undefined
basketnum = undefined
ca.id = 130025794
ba.id = 330021716
basket.save = true
ifResponsible = true

force = !true ? "disabled" : (!true || ...) ? 'preview' : undefined
      = false ? "disabled" : (false || ...) ? 'preview' : undefined
      = ... : (false || false) ? 'preview' : undefined
      = ... : false ? 'preview' : undefined
      = ... : undefined
      = undefined

index = ca && ids ? 1 : 0
      = true && true ? 1 : 0
      = 1

db.mod = ['disabled', 'new', 'edit', 'preview'][1]
       = 'new'  // Koristi index, ne force!
```

**Što znače modovi:**

| Mod | Značenje | Šta korisnik može |
|---|---|---|
| `'disabled'` | Forma je deaktivirana | Ništa - sve je disabled |
| `'new'` | Nova forma | Može unositi podatke |
| `'edit'` | Editovanje basket-a | Može mijenjati podatke |
| `'preview'` | Samo pregled | Samo gleda, ne može mijenjati |

**Kako se mod koristi u template-u:**

```html
<!-- evidencija-usluge.template.html -->

<!-- Dugme Spasi -->
<button [ngClass]="{inactive: db.mod=='preview' || !ifResponsible}">
  Spasi
</button>
<!-- Ako je preview → dugme je inactive (disabled) -->

<!-- Input polje -->
<input [ngClass]="{inactive: db.mod=='preview'}">
<!-- Ako je preview → input je inactive -->

<!-- Z-pageloader (dinamička forma) -->
<z-pageloader [ngClass]="{inactive: !db.mod || db.mod=='disabled'}">
</z-pageloader>
<!-- Ako je disabled → cijela forma je inactive -->
```

---

### LINIJA 189-190: Debug ispisi

```typescript
console.log('db.mod:', this.db.mod);
console.log('API poziv /pcrt/order-entry sa:', {
  productOfferId: this.offerId,
  productSpecificationId: this.specId,
  appProcessId: this.processId
});
```

**Primjer konzolnog ispisa:**

```
db.mod: new
API poziv /pcrt/order-entry sa: {
  productOfferId: "1174",
  productSpecificationId: "162",
  appProcessId: "10"
}
```

---

### LINIJA 191: API poziv - Dohvatanje strukture

```typescript
this.api.get('/pcrt/order-entry', {
  interactionId: 16,
  productOfferId: this.offerId,
  productSpecificationId: this.specId,
  appProcessId: this.processId,
  setupType: this.setupType
}).subscribe((r: RestPayload) => {
  // Callback se izvršava kada odgovor stigne
});
```

#### Šta je this.api.get()?

**Servis:** `RestApiService`

```typescript
this.api.get(url, params)
    │        │    │
    │        │    └─ Query parametri (šalju se kao ?key=value&key2=value2)
    │        └─ URL putanja
    └─ RestApiService metoda
```

#### Request koji se šalje:

**HTTP Request:**
```
GET /pcrt/order-entry?interactionId=16&productOfferId=1174&productSpecificationId=162&appProcessId=10&setupType=...
Host: backend-server
```

**Parametri:**

| Parametar | Vrijednost | Odakle dolazi | Svrha |
|---|---|---|---|
| `interactionId` | `16` | Hardcoded | Tip interakcije (evidencija usluge) |
| `productOfferId` | `"1174"` | `this.offerId` (iz URL-a) | ID ponude |
| `productSpecificationId` | `"162"` | `this.specId` (iz URL-a) | ID specifikacije proizvoda |
| `appProcessId` | `"10"` | `this.processId` (iz query params) | ID procesa |
| `setupType` | `...` | `this.setupType` (iz query params) | Tip setup-a |

**Primjer punog URL-a:**
```
http://localhost:8080/pcrt/order-entry?interactionId=16&productOfferId=1174&productSpecificationId=162&appProcessId=10
```

#### Response format (RestPayload):

**Interface:** `RestPayload`

```typescript
export interface RestPayload {
  className?: string;      // Ime klase (optional)
  payload?: any;           // Stvarni podaci (struktura forme)
  responseCode?: number;   // HTTP kod (200, 404, 500...)
  responseDetail?: string; // Poruka o grešci
  successful?: boolean;    // Da li je uspješno
}
```

**Pravi response (iz konzole):**

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
            "value": {
              "defaultValue": "1174",
              "data": [
                { "id": null, "value": "1174", "name": "Osnovni paket- Fizicka" }
              ]
            }
          }
        ],
        "elements": [
          {
            "label": "Osnovni paket- Fizicka",
            "code": "1174",
            "name": "Osnovnipaket-Fizicka",
            "template": "basic_block",
            "businessClassification": "OFFER",
            "active": false,
            "visible": true,
            "export": true,
            "icon": "fa fa-wrench wrench",
            "validFrom": "01-01-2007",
            "businessParams": { "ACTION_CODE": "NewPOTS" },
            "parameters": {
              "P_OFFER_ID": "1174",
              "ACTION_CODE": "NewPOTS",
              "P_CLASS_CODE": "ANALOG",
              "PROCESS_ID": "10",
              "TEMPLATE_ID": "767"
            },
            "inputs": [
              { "label": "Ime", "code": "FIRSTNAME", "name": "FIRSTNAME" },
              { "label": "Prezime/Naziv", "code": "NAME", "name": "NAME" },
              { "label": "Funkcija", "code": "JOBTITLE", "name": "JOBTITLE" },
              { "label": "Na lokaciji", "code": "PRIKLJUCAK_ADSL", "name": "PRIKLJUCAK_ADSL" },
              { "label": "Da li je u akciji", "code": "ACTION_PNK", "name": "ACTION_PNK" },
              { "label": "Grupa podtipova", "code": "FRSEGSCLASS_CODE", "name": "FRSEGSCLASS_CODE" },
              { "label": "Trenutni email", "code": "PUSER_EMAIL", "name": "PUSER_EMAIL" },
              { "label": "Kontakt telefon", "code": "DEFAULTCONTACTPHONE", "name": "DEFAULTCONTACTPHONE" },
              { "label": "Naziv paketa", "code": "OFFER_NAME", "name": "OFFER_NAME" },
              { "label": "Email", "code": "DEFAULTCONTACTEMAIL", "name": "DEFAULTCONTACTEMAIL" },
              { "label": "Kolicina", "code": "PQUANTITY_NUM", "name": "PQUANTITY_NUM" },
              { "label": "Indikator", "code": "CCC_IND", "name": "CCC_IND" }
            ],
            "messages": [
              { "label": "Info poruka", "code": "SERVICE_INFO", "name": "SERVICE_INFO" }
            ],
            "children": [
              { "label": "Dodavanje pratioca u nebrojčanu seriju", "code": "960" },
              { "label": "Tarifni paketi", "code": "178", "name": "Tarifnipaketi" },
              { "label": "Zabrana informacija", "code": "742" },
              { "label": "Detaljni ispis poziva, redovno", "code": "165" },
              { "label": "Preuzimanja", "code": "164" },
              { "label": "Specifikacija za Prodaju van poslovnih prostorija - FIKSNA", "code": "1704" },
              { "label": "Fiksna - ugovorni odnos", "code": "2016" },
              { "label": "Net VAS i zabrane poziva - POTS - Automatska realizacija", "code": "3069" },
              { "label": "Net VAS i zabrane poziva - POTS - Radni nalog", "code": "721" }
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

**Što je payload?**

To je **JSON definicija forme** sa 3 dijela:

| Dio | Opis |
|---|---|
| `structure[]` | Definicija forme - koja polja, labele, validacija, hijerarhija |
| `parameters` | Default parametri (`type: 100`) |
| `validation[]` | Globalna validaciona pravila (prazno u ovom slučaju) |

**Hijerarhija:**

```
payload
├── structure[0]: "Osnovne usluge" (SPECIFICATION, code: "162")
│   ├── actions[0]: loadOffer162 (dropdown za izbor ponude)
│   └── elements[0]: "Osnovni paket- Fizicka" (OFFER, code: "1174")
│       ├── inputs[]: FIRSTNAME, NAME, JOBTITLE, PRIKLJUCAK_ADSL...
│       ├── messages[]: SERVICE_INFO
│       └── children[]: Tarifni paketi, Zabrana info, Preuzimanja...
├── parameters: { type: 100 }
└── validation: []
```

**Ova struktura se kasnije renderira kao HTML forma kroz z-pageloader komponentu!**

#### .subscribe() - Observable pattern

```typescript
this.api.get(...).subscribe((r: RestPayload) => {
  // Ovaj kod se izvršava kada response STIGNE
  // r = response objekat tipa RestPayload
});
```

**Šta je Observable?**

- Angular koristi **RxJS** biblioteku za async operacije
- `this.api.get()` vraća **Observable<RestPayload>**
- Observable je kao **Promise** ali moćniji
- `.subscribe()` se poziva kada response stigne sa servera

**Timeline:**

```
T0: this.api.get(...).subscribe(...) se pozove
    │
    └─ HTTP request se šalje na backend

T1: ...čekanje...
    Backend procesira zahtjev, dohvaća strukturu iz baze, builduje JSON

T2: Response stiže
    │
    └─ .subscribe() callback se izvršava
       │
       └─ Kod unutar subscribe() se izvršava
```

**Zašto async?**

```typescript
// SINHRON (blokirajući) - NE MOŽE OVAKO:
let response = this.api.get(...);  // Blokiralo bi browser!
this.structure = response.payload;

// ASINHRON (non-blocking) - KORISTI SE OVAKO:
this.api.get(...).subscribe((response) => {
  // Ovo se izvršava KASNIJE, kada response stigne
  this.structure = response.payload;
});
// Browser nastavlja da radi, ne blokira se
```

---

### LINIJA 192-193: Response logging

```typescript
console.log('=== /pcrt/order-entry RESPONSE ===');
console.log('structure:', r.payload);
```

**Pravi konzolni ispis:**

```
=== /pcrt/order-entry RESPONSE ===
structure: {
  structure: Array(1),      // Niz elemenata forme
  parameters: { type: 100 },
  validation: Array(0)
}
```

---

### LINIJA 194 (dio 1): Spremanje strukture

```typescript
this.structure = r.payload;
```

**Što se dešava:**

```typescript
// PRIJE:
this.structure = {}  // Prazno (iz assignObjects())

// API response:
r = {
  className: "ba.com.zira.commons.message.response.PayloadResponse",
  responseCode: 0,
  responseDetail: "OK",
  payload: {
    structure: [                    // Niz elemenata forme
      {
        label: "Osnovne usluge",
        code: "162",
        template: "default_block",
        elements: [
          {
            label: "Osnovni paket- Fizicka",
            code: "1174",
            template: "basic_block",
            inputs: [ /* FIRSTNAME, NAME, JOBTITLE... */ ],
            children: [ /* Tarifni paketi, Zabrana info... */ ]
          }
        ]
      }
    ],
    parameters: { type: 100 },     // Default parametri
    validation: []                  // Validaciona pravila
  },
  successful: true
}

// NAKON:
this.structure = {
  structure: [                       // ← r.payload.structure
    {
      label: "Osnovne usluge",
      code: "162",
      template: "default_block",
      elements: [{
        label: "Osnovni paket- Fizicka",
        code: "1174",
        template: "basic_block",
        inputs: [
          { label: "Ime", name: "FIRSTNAME" },
          { label: "Prezime/Naziv", name: "NAME" },
          { label: "Funkcija", name: "JOBTITLE" },
          // ... ostala polja
        ],
        children: [
          { label: "Tarifni paketi", code: "178" },
          { label: "Zabrana informacija", code: "742" },
          // ... ostale child specifikacije
        ]
      }]
    }
  ],
  parameters: { type: 100 },       // ← r.payload.parameters
  validation: []                     // ← r.payload.validation
}
```

**Gdje se koristi this.structure?**

**Template:** `evidencija-usluge.template.html`, linija 265-267

```html
<z-pageloader
  *ngIf="structure"
  [items]="structure.structure"
  [parameters]="db.params"
  [model]="db.model"
  [output]="db.output"
  [valid]="db.valid"
></z-pageloader>
```

**Objašnjenje:**

- `*ngIf="structure"` → Prikazuje se SAMO ako structure postoji
- `[items]="structure.structure"` → Prosljeđuje niz elemenata forme (structure[0] = "Osnovne usluge")
- `z-pageloader` komponenta **renderuje dinamičku formu** na osnovu structure!

**Vizualno - kako pravi JSON postaje forma na ekranu:**

```
structure.structure[0]                    ┌────────────────────────────────────┐
  label: "Osnovne usluge"          ───►  │ ══ OSNOVNE USLUGE ══              │
  template: "default_block"               │                                    │
  code: "162"                             │  ┌───────────────────────────────┐ │
                                          │  │ Osnovni paket- Fizicka       │ │
  elements[0]                             │  └───────────────────────────────┘ │
    label: "Osnovni paket- Fizicka" ───►  │                                    │
    template: "basic_block"               │  ┌────────┐ ┌───────────┐ ┌──────┐│
    code: "1174"                          │  │ Ime    │ │Prezime/   │ │Funkc.││
                                          │  │[_____] │ │Naziv     *│ │[___] ││
    inputs[0]: FIRSTNAME           ───►   │  └────────┘ │[________]*│ └──────┘│
    inputs[1]: NAME                ───►   │              └───────────┘         │
    inputs[2]: JOBTITLE            ───►   │                                    │
                                          │  ┌─────────────────────────────┐  │
    children[1]: "Tarifni paketi"  ───►   │  │ □ Tarifni paketi            │  │
    children[2]: "Zabrana info"    ───►   │  │ □ Zabrana informacija       │  │
    children[3]: "Detaljni ispis"  ───►   │  │ □ Detaljni ispis poziva     │  │
                                          │  └─────────────────────────────┘  │
                                          │       *=obavezno polje (NAME)     │
                                          └────────────────────────────────────┘
```

---

### LINIJA 194 (dio 2): Ažuriranje db.params

```typescript
this.db.update(
  this.db.params,
  Object.assign(
    Object.assign(this.structure.parameters, this.params),
    this.setparms()
  )
);
```

Ovo izgleda kompleksno! Hajde da razložimo korak po korak.

#### Šta je db.update()?

**File:** `model.service.ts`, linija 15

```typescript
public update(item: any, newitem?: object) {
  Object.assign(item, newitem);
}
```

**Pojednostavljena verzija:**

```typescript
this.db.update(this.db.params, newParams);
// ↓ Jednako kao:
Object.assign(this.db.params, newParams);
// ↓ Kopira sve properties iz newParams u this.db.params
```

#### Šta je Object.assign()?

**MDN definicija:**

```typescript
Object.assign(target, source1, source2, ...)
              │       │        │
              │       │        └─ Dodatni source objekti
              │       └─ Prvi source objekat
              └─ Target objekat (kopira se u njega)
```

**Primjer:**

```javascript
let target = { a: 1, b: 2 };
let source1 = { b: 3, c: 4 };
let source2 = { c: 5, d: 6 };

Object.assign(target, source1, source2);

console.log(target);
// { a: 1, b: 3, c: 5, d: 6 }
//         ↑     ↑     ↑
//         │     │     └─ source2 prebrisao source1
//         │     └─ source2 dodao
//         └─ source1 prebrisao original
```

**Pravila:**
1. Kopira sve properties sa source objekta(a) u target
2. Ako property postoji, **prebrisuje** ga
3. Ako property ne postoji, **dodaje** ga
4. Vraća target objekat

#### Razlaganje nested Object.assign():

```typescript
Object.assign(
  Object.assign(this.structure.parameters, this.params),
  this.setparms()
)
```

**Korak po korak:**

```typescript
// KORAK 1: Unutrašnji Object.assign
let temp = Object.assign(this.structure.parameters, this.params);

// KORAK 2: Vanjski Object.assign
let finalParams = Object.assign(temp, this.setparms());

// KORAK 3: db.update
this.db.update(this.db.params, finalParams);

// Ili skraćeno:
Object.assign(this.db.params, finalParams);
```

**Sa pravim podacima:**

```javascript
// PRIJE:
this.structure.parameters = {
  type: 100                          // Jedini parametar iz backend response-a
}

this.params = {                      // Iz URL query parametara
  processId: "10",
  caId: "130025794",
  baId: "330021716",
  processGroupCode: "RESIDENTIAL_SALES",
  orderTypeName: "Osnovne usluge"
}

// KORAK 1: Object.assign(this.structure.parameters, this.params)
temp = {
  type: 100,                         // iz structure.parameters
  processId: "10",                   // DODANO iz this.params
  caId: "130025794",                 // DODANO iz this.params
  baId: "330021716",                 // DODANO iz this.params
  processGroupCode: "RESIDENTIAL_SALES",  // DODANO iz this.params
  orderTypeName: "Osnovne usluge"         // DODANO iz this.params
}

// KORAK 2: this.setparms() vraća:
{
  P_MAIN_OFFER_ID: "1174",               // ID ponude
  P_CA_ID: 130025794,                     // Customer Account ID (iz this.ca.id)
  P_BA_ID: 330021716,                     // Billing Account ID (iz this.ba.id)
  P_SA_ID: 456789,                        // Service Address ID (iz this.sa.id)
  P_SALES_SUB_LOCATION_ID: "SL001",      // Podlokacija prodaje
  P_SALES_LOCATION_ID: "L001",           // Lokacija prodaje
  P_LOGGED_USER: "kenan.salkic",         // Ulogovani korisnik
  P_SALES_CHANNEL: "RETAIL",             // Kanal prodaje
  P_APP_USER: "KSALKIC"                  // App user code
}

// KORAK 3: Object.assign(temp, setparms())
finalParams = {
  type: 100,                              // iz structure.parameters
  processId: "10",                        // iz this.params
  caId: "130025794",                      // iz this.params
  baId: "330021716",                      // iz this.params
  processGroupCode: "RESIDENTIAL_SALES",  // iz this.params
  orderTypeName: "Osnovne usluge",        // iz this.params
  P_MAIN_OFFER_ID: "1174",               // DODANO iz setparms()
  P_CA_ID: 130025794,                     // DODANO iz setparms()
  P_BA_ID: 330021716,                     // DODANO iz setparms()
  P_SA_ID: 456789,                        // DODANO iz setparms()
  P_SALES_SUB_LOCATION_ID: "SL001",      // DODANO iz setparms()
  P_SALES_LOCATION_ID: "L001",           // DODANO iz setparms()
  P_LOGGED_USER: "kenan.salkic",         // DODANO iz setparms()
  P_SALES_CHANNEL: "RETAIL",             // DODANO iz setparms()
  P_APP_USER: "KSALKIC"                  // DODANO iz setparms()
}

// KORAK 4: Object.assign(this.db.params, finalParams)
this.db.params = finalParams  // Sve kopirano u db.params!
```

**Pravi konzolni ispis (db.params NAKON update):**

```
db.params NAKON update: {
  type: 100,
  processGroupCode: 'RESIDENTIAL_SALES',
  orderTypeName: 'Osnovne usluge',
  caId: '130025794',
  baId: '330021716',
  P_MAIN_OFFER_ID: '1174',
  P_CA_ID: 130025794,
  P_BA_ID: 330021716,
  P_SA_ID: 456789,
  P_SALES_LOCATION_ID: 'L001',
  P_LOGGED_USER: 'kenan.salkic',
  P_SALES_CHANNEL: 'RETAIL',
  P_APP_USER: 'KSALKIC',
  ...
}
```

**Vizualno sa pravim podacima:**

```
┌──────────────────────────────────────────────────────────────────┐
│  MERGE PROCESS (pravi podaci)                                    │
│  ═════════════════════════════                                   │
│                                                                  │
│  1. this.structure.parameters (iz backend response-a)            │
│  ┌───────────────────────────┐                                  │
│  │ type: 100                  │────┐                             │
│  └───────────────────────────┘    │                             │
│                                    │                             │
│               +                    ↓                             │
│                             Object.assign()                      │
│  2. this.params (iz URL-a)         │                             │
│  ┌─────────────────────────────────┐                            │
│  │ processId: "10"                 │                            │
│  │ caId: "130025794"               │────┤                       │
│  │ baId: "330021716"               │    │                       │
│  │ processGroupCode:               │    │                       │
│  │   "RESIDENTIAL_SALES"           │    │                       │
│  │ orderTypeName:"Osnovne usluge"  │    │                       │
│  └─────────────────────────────────┘    │                       │
│                                          │                       │
│                                          ↓                       │
│                            ┌──────────────────────────┐          │
│                            │  temp objekat            │          │
│                            │  (type + URL params)     │          │
│                            └──────────────────────────┘          │
│                                          │                       │
│               +                          │                       │
│                                          ↓                       │
│  3. this.setparms()              Object.assign()                 │
│  ┌─────────────────────────────────┐    │                       │
│  │ P_MAIN_OFFER_ID: "1174"        │    │                       │
│  │ P_CA_ID: 130025794             │────┤                       │
│  │ P_BA_ID: 330021716             │    │                       │
│  │ P_SA_ID: 456789                │    │                       │
│  │ P_SALES_LOCATION_ID: "L001"   │    │                       │
│  │ P_LOGGED_USER: "kenan.salkic" │    │                       │
│  │ P_SALES_CHANNEL: "RETAIL"     │    │                       │
│  │ P_APP_USER: "KSALKIC"         │    │                       │
│  └─────────────────────────────────┘    │                       │
│                                          │                       │
│                                          ↓                       │
│                          ┌──────────────────────────────┐        │
│                          │  finalParams                 │        │
│                          │  (sve merged - 15+ propova)  │        │
│                          └──────────────────────────────┘        │
│                                          │                       │
│                                   db.update()                    │
│                                          │                       │
│                                          ↓                       │
│                          ┌──────────────────────────────┐        │
│                          │  this.db.params              │        │
│                          │  type: 100                   │        │
│                          │  processId: "10"             │        │
│                          │  caId: "130025794"           │        │
│                          │  P_MAIN_OFFER_ID: "1174"     │        │
│                          │  P_CA_ID: 130025794          │        │
│                          │  P_LOGGED_USER: "kenan..."   │        │
│                          │  ...                         │        │
│                          └──────────────────────────────┘        │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

#### Detaljno objašnjenje setparms():

**File:** `evidencija-usluge.component.ts`, linija 218-236

```typescript
setparms() {
  if (this.orderEntrySetupRequests) {
    Object.assign(this.basket, { P_TECH_CODE: this.ba.ptechnologyCode });
  }

  return Object.assign({
    P_MAIN_OFFER_ID: this.offerId,
    P_CA_ID: this.ca.id,
    P_BA_ID: this.ba.id,
    P_SA_ID: !this.ia ? this.sa.id : null,
    P_SALES_SUB_LOCATION_ID: this.user.getSubSalesLocationId(),
    P_SALES_LOCATION_ID: this.user.getSalesLocationId(),
    P_LOGGED_USER: this.user.getName(),
    P_SALES_CHANNEL: this.user.getChannel(),
    P_APP_USER: this.user.getUserCode()
  }, this.basket);
}
```

**Šta radi:**

1. **DIO 1:** Priprema osnovne parametre:
   ```javascript
   {
     P_MAIN_OFFER_ID: "1174",              // ID ponude
     P_CA_ID: "130025794",                 // Customer Account ID
     P_BA_ID: "330021716",                 // Billing Account ID
     P_SA_ID: "456789",                    // Service Address ID (ako postoji)
     P_SALES_SUB_LOCATION_ID: "SL001",     // Podlokacija prodaje
     P_SALES_LOCATION_ID: "L001",          // Lokacija prodaje
     P_LOGGED_USER: "john.doe",            // Ulogovani korisnik
     P_SALES_CHANNEL: "RETAIL",            // Kanal prodaje (RETAIL, WEBSHOP...)
     P_APP_USER: "JDOE"                    // App user code
   }
   ```

2. **DIO 2:** Merguje sa `this.basket` objektom:
   ```javascript
   Object.assign(basicParams, this.basket)
   // Ako this.basket ima { refnumber: "WS123" }
   // Rezultat: { ...basicParams, refnumber: "WS123" }
   ```

**Zašto P_ prefix?**

Backend očekuje parametre sa `P_` prefixom. Ovi parametri se koriste u:
- **PL/SQL stored procedurama**
- **Oracle funkcijama**
- **Backend business logici**

**Primjer korištenja u pravoj strukturi:**

Input polje FIRSTNAME ima `generationFormula` koja koristi parametre:

```json
{
  "name": "FIRSTNAME",
  "label": "Ime",
  "template": "input",
  "value": {
    "generationFormula": "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual"
  }
}
```

Parametri `P_CLASS_CODE` ("ANALOG") i `P_CA_ID` (130025794) se zamjenjuju iz `db.params` → backend PL/SQL procedura dohvata ime korisnika iz baze.

#### Zašto je ovo važno?

```
db.params sadrži SVE parametre koji su potrebni za:
  1. Renderovanje forme (dependency-ji)
  2. API pozive tokom unosa (autocomplete, validation)
  3. Spremanje u suicapture (P_CA_ID, P_BA_ID...)
  4. Slanje na backend pri finalizaciji

db.params se koristi SVUGDJE u dinamičkoj formi!
```

**Primjer korištenja:**

```html
<!-- U z-pageloader komponenti -->
<z-pageloader [parameters]="db.params"></z-pageloader>

<!-- Z-pageloader prosljeđuje db.params svim child komponentama -->
<!-- Child komponente koriste parameters za dependency logic -->
```

---

### LINIJA 194 (dio 3): Poziv callback funkcije

```typescript
!callback || this[callback]();
```

Ovo smo već detaljno objasnili u **DODATAK 2: Callback parametar u getDynamic()**.

**Kratak recap:**

```typescript
// Ako callback postoji:
callback = 'validateinformations'
!callback || this[callback]()
false || this['validateinformations']()
this.validateinformations()  // POZIVA SE!

// Ako callback NE postoji:
callback = undefined
!callback || this[callback]()
true || ...
SHORT CIRCUIT - desna strana se NE izvršava
```

---

### LINIJA 195: Debug ispis

```typescript
console.log('db.params NAKON update:', this.db.params);
```

**Pravi konzolni ispis:**

```
db.params NAKON update: {
  type: 100,
  processGroupCode: 'RESIDENTIAL_SALES',
  orderTypeName: 'Osnovne usluge',
  processId: '10',
  caId: '130025794',
  baId: '330021716',
  P_MAIN_OFFER_ID: '1174',
  P_CA_ID: 130025794,
  P_BA_ID: 330021716,
  P_SA_ID: 456789,
  P_SALES_LOCATION_ID: 'L001',
  P_LOGGED_USER: 'kenan.salkic',
  P_SALES_CHANNEL: 'RETAIL',
  P_APP_USER: 'KSALKIC',
  ...
}
```

---

### LINIJA 196: Preview mod specijalan slučaj

```typescript
if (this.db.mod === 'preview') {
  this.basket.headbasketnum = this.headordnum;
}
```

**Šta ovo radi:**

```typescript
// Ako je mod === 'preview' (samo čitanje)
// Postavi headbasketnum sa headordnum
this.basket.headbasketnum = this.headordnum;
```

**Zašto?**

U preview modu (kada pregledaš već finaliziranu narudžbu):
- `ordnum` postoji (npr. "257697-01/26")
- `headordnum` je broj glavne narudžbe (npr. "257697/26")
- `basket.headbasketnum` se koristi za prikaz broja narudžbe u template-u

**Template korištenje:**

```html
<span *ngIf="basket.headbasketnum">
  Glavna narudžba: {{ basket.headbasketnum }}
</span>
```

---

### LINIJA 198: Debug ispis kraj

```typescript
console.log('   getDynamic END');
```

**NAPOMENA:** Ovaj log se ispisuje **PRIJE** nego što response stigne!

**Pravi redoslijed ispisa u konzoli:**

```
   getDynamic START
callback: validateinformations
db.mod: new
API poziv /pcrt/order-entry sa: {
  productOfferId: '1174',
  productSpecificationId: '162',
  appProcessId: '10'
}
   getDynamic END                    ← Ispisano ODMAH (ne čeka response!)
... čekanje ~300ms ...
=== /pcrt/order-entry RESPONSE ===  ← Ispisano KASNIJE (kad response stigne)
structure: {
  structure: Array(1),
  parameters: { type: 100 },
  validation: Array(0)
}
db.params NAKON update: {
  type: 100,
  processGroupCode: 'RESIDENTIAL_SALES',
  orderTypeName: 'Osnovne usluge',
  caId: '130025794',
  ...
}
```

**Zašto?**

Jer je `.subscribe()` **asinhron** - kod nastavlja izvršavanje bez čekanja response-a.

---

## getGroupDynamic() - Alternativna implementacija

**File:** `evidencija-usluge.component.ts`, linija 201-207

```typescript
getGroupDynamic(callback?: any) {
  let request = {
    appProcessId: this.processId,
    orderEntrySetupRequests: JSON.parse(this.orderEntrySetupRequests),
    productOfferId: this.offerId,
    productSpecificationId: this.specId
  }

  this.db.setmod(
    this.ordnum,
    this.basketnum,
    this.ca.id,
    this.ba.id,
    !this.basket.save ? "disabled" :
      !this.ifResponsible ||
      (this.sharedData.basket && this.sharedData.basket.status &&
       this.sharedData.basket.status === '15') ? 'preview' : undefined,
    this.patch
  );

  this.api.post('/pcrt/order-entry/group', request)
    .subscribe((r: RestPayload) => {
      this.structure = r.payload;
      this.db.update(
        this.db.params,
        Object.assign(
          Object.assign(this.structure.parameters, this.params),
          this.setparms()
        )
      );
      !callback || this[callback]();
    });

  if (this.db.mod === 'preview') {
    this.basket.headbasketnum = this.headordnum;
  }
}
```

**Razlike od getDynamic():**

| getDynamic() | getGroupDynamic() |
|---|---|
| `this.api.get('/pcrt/order-entry', ...)` | `this.api.post('/pcrt/order-entry/group', ...)` |
| GET request | POST request |
| Parametri u query stringu | Parametri u request body |
| Za **pojedinačne** narudžbe | Za **grupne** narudžbe |

**Kada se koristi getGroupDynamic():**

```
URL primjer:
/evidencija/residential/1174/162/0?processId=10&orderEntrySetupRequests=[{"msisdn":"061123456"},{"msisdn":"061654321"}]

↓

orderEntrySetupRequests nije undefined
↓
Poziva se getGroupDynamic()
```

**Zašto POST umjesto GET?**

```javascript
orderEntrySetupRequests = '[{"msisdn":"061123456","productOfferId":"1174"},{"msisdn":"061654321","productOfferId":"1175"}]'

// Ovo je PREVELIKO za URL query string!
// GET ima ograničenje dužine URL-a (~2000 karaktera)
// POST šalje podatke u body - nema ograničenja
```

**Ostalo je IDENTIČNO** kao u getDynamic().

---

## Sažetak - getDynamic() Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  getDynamic('validateinformations') - KOMPLETNI FLOW            │
│  ═══════════════════════════════════════════════════            │
│                                                                 │
│  KORAK 1: Provjera orderEntrySetupRequests                      │
│  ────────────────────────────────────────                       │
│    if (orderEntrySetupRequests)                                 │
│      → getGroupDynamic() (grupna narudžba)                      │
│    else                                                         │
│      → Normalan flow (nastavak)                                 │
│                                                                 │
│  KORAK 2: Postavljanje db.mod                                   │
│  ────────────────────────────────                               │
│    db.setmod(ordnum, basketnum, ca.id, ba.id, force, patch)     │
│    → Određuje mod: 'disabled', 'new', 'edit', 'preview'         │
│    → db.mod se koristi u template-u za disable/enable forme     │
│                                                                 │
│  KORAK 3: API poziv                                             │
│  ──────────────────                                             │
│    this.api.get('/pcrt/order-entry', {                          │
│      interactionId: 16,                                         │
│      productOfferId: this.offerId,                              │
│      productSpecificationId: this.specId,                       │
│      appProcessId: this.processId,                              │
│      setupType: this.setupType                                  │
│    })                                                           │
│    → Šalje HTTP GET request na backend                          │
│    → Backend vraća strukturu forme kao JSON                     │
│                                                                 │
│  KORAK 4: Subscribe - čekanje response-a                        │
│  ────────────────────────────────────────                       │
│    .subscribe((r: RestPayload) => { ... })                      │
│    → Callback se izvršava kada response stigne                  │
│    → r.payload sadrži strukturu forme                           │
│                                                                 │
│  KORAK 5: Spremanje strukture                                   │
│  ─────────────────────────────                                  │
│    this.structure = r.payload;                                  │
│    → structure.structure[0] = "Osnovne usluge" (code: "162")    │
│    →   elements[0] = "Osnovni paket- Fizicka" (code: "1174")   │
│    →     inputs: FIRSTNAME, NAME, JOBTITLE, ACTION_PNK...       │
│    →     children: Tarifni paketi, Zabrana info, Preuzimanja... │
│    → structure.parameters = { type: 100 }                       │
│                                                                 │
│  KORAK 6: Ažuriranje db.params                                  │
│  ──────────────────────────────                                 │
│    this.db.update(this.db.params, merged_params)                │
│    │                                                            │
│    └─ merged_params = merge 3 objekta:                          │
│       1. structure.parameters → { type: 100 }                   │
│       2. this.params → { processId:"10", caId:"130025794"... }  │
│       3. setparms() → { P_CA_ID:130025794, P_BA_ID:330021716,  │
│                          P_LOGGED_USER:"kenan.salkic"... }      │
│                                                                 │
│  KORAK 7: Poziv callback funkcije                               │
│  ─────────────────────────────────                              │
│    !callback || this[callback]()                                │
│    → Ako callback='validateinformations'                        │
│    → Poziva this.validateinformations()                         │
│    → Validira da li postoje CA, BA, CONTACT                     │
│                                                                 │
│  KORAK 8: Renderovanje forme                                    │
│  ────────────────────────────                                   │
│    Template: <z-pageloader *ngIf="structure" ...>               │
│    → z-pageloader vidi da structure postoji                     │
│    → Renderuje "Osnovne usluge" → "Osnovni paket- Fizicka"     │
│    → Polja: Ime, Prezime/Naziv, Funkcija, Na lokaciji...       │
│    → Children: Tarifni paketi, Zabrana info, Preuzimanja...     │
│    → Korisnik vidi formu i može unositi podatke                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## KORAK 4: Populacija db.model - Od praznog objekta do punog modela

### Uvod

Jedan od najtežih koncepata za razumjeti kod Suicapture mehanizma je **kako se `db.model` puni podacima**. Kada se komponenta učita, `db.model` je prazan objekat:

```typescript
db.model = { auto: {} }
```

Ali kada korisnik klikne "Spasi", `db.model` sadrži sve podatke:

```typescript
db.model = {
  auto: {},
  "Osnovneusluge": {
    "Osnovnipaket-Fizicka": {
      FIRSTNAME: "Kenan",
      NAME: "Testni korisnik",
      JOBTITLE: "Direktor",
      PRIKLJUCAK_ADSL: "1234567",
      // ... sve ostale vrijednosti
    }
  }
}
```

**Kako se ova transformacija dešava?** To ćemo objasniti u 7 faza.

---

### FAZA 1: Inicijalizacija - assignObjects()

**Gdje:** `evidencija-usluge.component.ts`, linija ~131

**Kada:** U `ngOnInit()` poziva se `this.assignObjects()`

**Šta radi:**

```typescript
assignObjects() {
  console.log('=== assignObjects() START ===');

  this.Dependency.clear();
  this.structure = {};

  this.db.clear(['active', 'activechild'])
    .assign("model", { auto: {} })
    .assign("output")
    .assign("params")
    .assign("valid", { children: {}, errors: 0, validated: undefined });

  console.log('db.model NAKON assign:', this.db.model);
  // Output: { auto: {} }

  console.log('=== assignObjects() END ===');
}
```

**Rezultat:**

```
db.model = { auto: {} }     ← PRAZAN objekat, samo sa 'auto' propertijom
db.output = {}
db.params = {}
db.valid = { children: {}, errors: 0, validated: undefined }
```

**Console output:**

```
=== assignObjects() START ===
db.model NAKON assign: {"auto":{}}
db.output NAKON assign: {}
db.params NAKON assign: {}
=== assignObjects() END ===
```

---

### FAZA 2: getDynamic() dohvata strukturu

**Gdje:** `evidencija-usluge.component.ts`, linija ~183

**Kada:** Nakon `assignObjects()`, poziva se `getDynamic('validateinformations')`

**Šta radi:**

```typescript
getDynamic(callback?: string, params?: object) {
  // API poziv
  this.http.get('/pcrt/order-entry', {
    interactionId: 16,
    productOfferId: "1174",          // Osnovni paket- Fizicka
    productSpecificationId: "162",    // Osnovne usluge
    appProcessId: "10",
    setupType: "SALES"
  }).subscribe(r => {
    // Postavlja strukturu
    this.structure = r.payload;

    // Ažurira parametre
    this.db.update(this.db.params, merged_params);

    // Poziva callback
    this[callback]();  // → validateinformations()
  });
}
```

**Rezultat:**

```typescript
this.structure = {
  structure: [
    {
      label: "Osnovne usluge",
      name: "Osnovneusluge",      // ← KEY property
      code: "162",
      template: "default_block",
      elements: [
        {
          label: "Osnovni paket- Fizicka",
          name: "Osnovnipaket-Fizicka",  // ← KEY property
          code: "1174",
          template: "basic_block",
          inputs: [
            { name: "FIRSTNAME", label: "Ime", componentType: "input", ... },
            { name: "NAME", label: "Prezime/Naziv", componentType: "input", ... },
            { name: "JOBTITLE", label: "Funkcija", componentType: "input", ... }
            // ... ostali inputi
          ],
          children: [ /* Tarifni paketi, Zabrana info... */ ]
        }
      ]
    }
  ],
  parameters: { type: 100 }
}
```

**VAŽNO:** U ovoj fazi `db.model` je još uvijek:

```
db.model = { auto: {} }  ← NIJE SE PROMIJENIO!
```

---

### FAZA 3: Renderovanje - DefaultBlock i BasicBlock kreiraju nested objekte

**Gdje:** Template → `<z-pageloader>` → komponente: `defaultblock.component.ts`, `basicblock.component.ts`

**Kada:** Nakon što struktura stigne, Angular renderuje template:

```html
<z-pageloader *ngIf="structure"
  [items]="structure.structure"
  [model]="db.model"
  [output]="db.output"
  [parameters]="db.params">
</z-pageloader>
```

#### 3.1. DefaultBlock se renderuje za "Osnovne usluge"

**Komponenta:** `defaultblock.component.ts`

**ngOnInit():**

```typescript
ngOnInit() {
  console.log('=== DefaultBlock ngOnInit ===');
  console.log('items.name:', this.items.name);           // "Osnovneusluge"
  console.log('items.label:', this.items.label);         // "Osnovne usluge"
  console.log('items.code:', this.items.code);           // "162"
  console.log('model PRIJE kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{}}

  if (!this.model[this.items.name]) this.model[this.items.name] = {};

  console.log('model NAKON kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"Osnovneusluge":{}}

  console.log('Kreiran nested objekat: model["' + this.items.name + '"] = {}');
  console.log('======================');
}
```

**Rezultat:**

```
db.model = {
  auto: {},
  "Osnovneusluge": {}    ← NOVI nested objekat!
}
```

**Console output:**

```
=== DefaultBlock ngOnInit ===
items.name: Osnovneusluge
items.label: Osnovne usluge
items.code: 162
model PRIJE kreiranja: {"auto":{}}
model NAKON kreiranja: {"auto":{},"Osnovneusluge":{}}
Kreiran nested objekat: model["Osnovneusluge"] = {}
======================
```

#### 3.2. DefaultBlock prosleđuje model djetetu - KLJUČNI MOMENAT!

**Template:** `defaultblock.template.html`

```html
<z-dynamic-component
  *ngFor="let element of items.elements"
  [dlcontent]="element.template"
  [items]="element"
  [model]="model"              ← Prosleđuje CIJELI model!
  [output]="output"
  [parent]="model"
  [pname]="items.name">
</z-dynamic-component>
```

**KLJUČNO:** `[model]="model"` prosleđuje CIJELI `db.model` objekat, ne samo nested dio!

#### 3.3. BasicBlock se renderuje za "Osnovni paket- Fizicka"

**Komponenta:** `basicblock.component.ts`

**ngOnInit():**

```typescript
ngOnInit() {
  console.log('=== BasicBlock ngOnInit ===');
  console.log('items.name:', this.items.name);           // "Osnovnipaket-Fizicka"
  console.log('items.label:', this.items.label);         // "Osnovni paket- Fizicka"
  console.log('items.code:', this.items.code);           // "1174"
  console.log('model PRIJE kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"Osnovneusluge":{}}

  if (!this.model[this.items.name]) this.model[this.items.name] = {};

  console.log('model NAKON kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"Osnovneusluge":{},"Osnovnipaket-Fizicka":{}}

  console.log('Kreiran nested objekat: model["' + this.items.name + '"] = {}');
  console.log('======================');
}
```

**Rezultat:**

```
db.model = {
  auto: {},
  "Osnovneusluge": {},
  "Osnovnipaket-Fizicka": {}    ← NOVI nested objekat!
}
```

**ČEKAJ, ZAŠTO NIJE:**

```
db.model = {
  auto: {},
  "Osnovneusluge": {
    "Osnovnipaket-Fizicka": {}    ← Ne, nije ovako!
  }
}
```

**ODGOVOR:** Zato što DefaultBlock prosleđuje `[model]="model"` (cijeli model), a NE `[model]="model[items.name]"` (nested dio).

**Ali kako onda input komponente znaju gdje da stave vrijednosti?**

#### 3.4. BasicBlock prosleđuje model[items.name] djeci - DRUGI KLJUČNI MOMENAT!

**Template:** `basicblock.template.html`

```html
<z-dynamic-component
  *ngFor="let input of items.inputs"
  [dlcontent]="input.componentType"
  [items]="input"
  [model]="model[items.name]"    ← OVDJE! Prosleđuje NESTED objekat!
  [output]="output"
  [parent]="model">
</z-dynamic-component>
```

**KLJUČNO:** `[model]="model[items.name]"` prosleđuje SAMO nested dio modela!

Što znači:

```typescript
// Za input FIRSTNAME, model će biti:
model = db.model["Osnovnipaket-Fizicka"]
// što je REFERENCA na db.model["Osnovnipaket-Fizicka"] !
```

**Ovo je REFERENCA, ne kopija!** Što znači da kada input promijeni `model[items.name]`, on direktno mijenja `db.model["Osnovnipaket-Fizicka"][items.name]`!

---

### FAZA 4: ContentLoader i ValueManager pune inicijalnu vrijednost

**Gdje:** `contentloader.component.ts`, linija ~41

**Kada:** Nakon što se input komponenta renderuje, njen parent ContentLoader poziva `ValueManager.set()`

**Šta radi:**

```typescript
// contentloader.component.ts
ngOnInit() {
  console.log('=== ContentLoader ngOnInit ===');
  console.log('items.name:', this.items.name);           // "FIRSTNAME"
  console.log('items.label:', this.items.label);         // "Ime"
  console.log('model PRIJE ValueManager.set:', this.model);
  // Output: {}

  this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);

  console.log('model NAKON ValueManager.set:', this.model);
  // Output: { FIRSTNAME: "" }  ← INICIJALIZOVANO!
  console.log('======================');
}
```

#### 4.1. ValueManager.set() - Logika inicijalizacije

**Komponenta:** `value.manager.ts`, linija ~25

```typescript
set(field: InputObject, model: object, parameters?: any, mod?: string) {
  // 1. Provjera: Da li polje već ima vrijednost?
  if (model[field.name] !== undefined) {
    return;  // Već ima vrijednost, ne radi ništa
  }

  // 2. generationFormula - Izvršava SQL via backend
  if (field.generationFormula) {
    this.dblookup(field.generationFormula, parameters).subscribe(result => {
      model[field.name] = result;
    });
    return;
  }

  // 3. defaultValue - Statička default vrijednost
  if (field.defaultValue !== undefined) {
    model[field.name] = field.defaultValue;
    return;
  }

  // 4. mappingRef - Uzima vrijednost iz parametara
  if (field.mappingRef && parameters[field.mappingRef] !== undefined) {
    model[field.name] = parameters[field.mappingRef];
    return;
  }

  // 5. Fallback - Prazan string ili null
  model[field.name] = field.componentType === 'checkbox' ? false : '';
}
```

**Primjer sa pravim podacima:**

Polje: **FIRSTNAME** (Ime)

```typescript
{
  name: "FIRSTNAME",
  label: "Ime",
  componentType: "input",
  generationFormula: "SELECT contact.firstname FROM contact WHERE contact.id = :P_CONTACT_ID",
  mappingRef: undefined,
  defaultValue: undefined
}
```

**Izvršavanje:**

1. `model["FIRSTNAME"]` je `undefined` → nastavlja
2. `generationFormula` postoji → poziva backend:

```typescript
this.http.post('/uomback/common/lookupStatement', {
  sql: "SELECT contact.firstname FROM contact WHERE contact.id = :P_CONTACT_ID",
  parameters: { P_CONTACT_ID: 123456 }
}).subscribe(result => {
  model["FIRSTNAME"] = result;  // "Kenan"
});
```

**Rezultat:**

```
db.model["Osnovnipaket-Fizicka"]["FIRSTNAME"] = "Kenan"
```

**Console output:**

```
=== ContentLoader ngOnInit ===
items.name: FIRSTNAME
items.label: Ime
model PRIJE ValueManager.set: {}
EXECUTING SQL: SELECT contact.firstname FROM contact WHERE contact.id = 123456
SQL RESULT: "Kenan"
model NAKON ValueManager.set: {"FIRSTNAME":"Kenan"}
======================
```

**Ovo se ponavlja za SVA polja:**

- `NAME` → SQL → "Testni korisnik"
- `JOBTITLE` → SQL → "Direktor"
- `PRIKLJUCAK_ADSL` → defaultValue → ""
- `PUSER_EMAIL` → SQL → "kenan@test.com"
- ...

**Rezultat nakon SVIH input komponenti:**

```typescript
db.model = {
  auto: {},
  "Osnovneusluge": {},
  "Osnovnipaket-Fizicka": {
    FIRSTNAME: "Kenan",
    NAME: "Testni korisnik",
    JOBTITLE: "Direktor",
    PRIKLJUCAK_ADSL: "",
    PUSER_EMAIL: "kenan@test.com",
    ACTION_PNK: "",
    // ... sve ostale vrijednosti
  }
}
```

---

### FAZA 5: Angular ngModel - Korisnikov unos

**Gdje:** Input template (`input.template.html`)

**Kada:** Korisnik mijenja vrijednost u input polju

**Šta radi:**

```html
<!-- input.template.html -->
<input
  type="text"
  [(ngModel)]="model[items.name]"
  [placeholder]="items.label"
/>
```

**Angular [(ngModel)] TWO-WAY BINDING:**

1. **Model → View:** Kada `model[items.name]` se promijeni, input polje se ažurira
2. **View → Model:** Kada korisnik unese nešto u input, `model[items.name]` se ažurira

**Primjer:**

Korisnik mijenja "Ime" iz "Kenan" → "John"

```
1. Korisnik upiše "John" u input
   ↓
2. Angular detektuje promjenu
   ↓
3. Angular automatski ažurira: model["FIRSTNAME"] = "John"
   ↓
4. Pošto je model = db.model["Osnovnipaket-Fizicka"] (REFERENCA!)
   ↓
5. Direktno se ažurira: db.model["Osnovnipaket-Fizicka"]["FIRSTNAME"] = "John"
```

**NEMA potrebe za dodatnim kodom!** Angular automatski sinhronizuje.

**Rezultat:**

```typescript
db.model = {
  auto: {},
  "Osnovneusluge": {},
  "Osnovnipaket-Fizicka": {
    FIRSTNAME: "John",      ← PROMIJENIO KORISNIK!
    NAME: "Testni korisnik",
    JOBTITLE: "Direktor",
    PRIKLJUCAK_ADSL: "1234567",  ← PROMIJENIO KORISNIK!
    // ...
  }
}
```

---

### FAZA 6: Finalni db.model - Sva polja popunjena

Nakon što korisnik popuni SVA polja i doda child elemente (Tarifni paketi, itd.), `db.model` izgleda:

```typescript
db.model = {
  auto: {},
  "Osnovneusluge": {},
  "Osnovnipaket-Fizicka": {
    FIRSTNAME: "John",
    NAME: "Test Company",
    JOBTITLE: "CEO",
    PRIKLJUCAK_ADSL: "1234567",
    ACTION_PNK: "DA",
    FRSEGSCLASS_CODE: "GOLD",
    PUSER_EMAIL: "john@test.com",
    DEFAULTCONTACTPHONE: "+387611234567",
    OFFER_NAME: "Osnovni paket",
    DEFAULTCONTACTEMAIL: "contact@test.com",
    PQUANTITY_NUM: "1",
    CCC_IND: "N"
  },
  "Tarifnipaketi": {
    "Tarifnipaket1": {
      TARIFF_CODE: "TP100",
      TARIFF_NAME: "Super tarifa",
      PRICE: "50.00"
    }
  },
  "Zabranainfo": {},
  "Preuzimanja": {}
}
```

**db.output** takođe prati strukturu:

```typescript
db.output = {
  "Osnovneusluge": {
    active: true,
    value: {
      "Osnovnipaket-Fizicka": {
        active: true,
        value: db.model["Osnovnipaket-Fizicka"]  ← REFERENCA!
      }
    }
  },
  "Tarifnipaketi": { ... },
  "Zabranainfo": { ... },
  "Preuzimanja": { ... }
}
```

---

### FAZA 7: saveSuicapture() - Slanje na backend

**Gdje:** `evidencija-usluge.component.ts`, linija ~368

**Kada:** Korisnik klikne "Spasi"

**Šta radi:**

```typescript
save() {
  this.clicked = true;
  this.spinner.show();
  this.saveSuicapture();
}

saveSuicapture(params?: any) {
  console.log('=== saveSuicapture START ===');
  console.log('db.model (cijeli model):', this.db.model);
  console.log('db.output (cijeli output):', this.db.output);

  let body = {
    id: this.basketnum,
    processId: this.processId,
    model: JSON.stringify({
      model: this.db.model,           ← CIJELI popunjeni model!
      output: this.setOutput()        ← Transformisani output
    })
  };

  console.log('Request body:', body);
  console.log('=== saveSuicapture END ===');

  this.http.post('/pcrt/sui-capture', body).subscribe(response => {
    // Backend čuva u SUI_CAPTURE tabeli
    console.log('Suicapture saved!', response);
  });
}
```

**Request body:**

```json
{
  "id": "999888777",
  "processId": "10",
  "model": "{\"model\":{\"auto\":{},\"Osnovneusluge\":{},\"Osnovnipaket-Fizicka\":{\"FIRSTNAME\":\"John\",\"NAME\":\"Test Company\",...}},\"output\":{...}}"
}
```

**Backend čuva u SUI_CAPTURE:**

```sql
INSERT INTO SUI_CAPTURE (ID, PROCESS_ID, MODEL, CREATED)
VALUES ('999888777', '10', '{"model":{"auto":{},"Osnovneusluge":{},...}, ...}', SYSDATE);
```

---

## Vizualni dijagram - db.model transformacija

```
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 1: assignObjects()                                        │
│  ════════════════════════                                       │
│                                                                 │
│  db.model = { auto: {} }                                        │
│             ▲                                                   │
│             └─ PRAZAN objekat, samo 'auto'                      │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 2: getDynamic()                                           │
│  ═════════════════════                                          │
│                                                                 │
│  Backend vraća: structure.structure = [                         │
│    {                                                            │
│      name: "Osnovneusluge",                                     │
│      elements: [                                                │
│        {                                                        │
│          name: "Osnovnipaket-Fizicka",                          │
│          inputs: [ {name: "FIRSTNAME"}, {name: "NAME"}, ... ]   │
│        }                                                        │
│      ]                                                          │
│    }                                                            │
│  ]                                                              │
│                                                                 │
│  db.model = { auto: {} }  ← JOŠ UVIJEK PRAZAN!                  │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 3.1: DefaultBlock ngOnInit() - "Osnovne usluge"           │
│  ═══════════════════════════════════════════════════            │
│                                                                 │
│  if (!this.model["Osnovneusluge"])                              │
│    this.model["Osnovneusluge"] = {};                            │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "Osnovneusluge": {}    ← NOVI nested objekat!                │
│  }                                                              │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 3.2: BasicBlock ngOnInit() - "Osnovni paket- Fizicka"     │
│  ══════════════════════════════════════════════════════         │
│                                                                 │
│  if (!this.model["Osnovnipaket-Fizicka"])                       │
│    this.model["Osnovnipaket-Fizicka"] = {};                     │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "Osnovneusluge": {},                                         │
│    "Osnovnipaket-Fizicka": {}    ← NOVI nested objekat!         │
│  }                                                              │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 3.3: BasicBlock prosleđuje model[items.name] djeci        │
│  ═══════════════════════════════════════════════════            │
│                                                                 │
│  Template: [model]="model[items.name]"                          │
│           = model["Osnovnipaket-Fizicka"]                       │
│                                                                 │
│  Input komponente dobijaju:                                     │
│    model = REFERENCA na db.model["Osnovnipaket-Fizicka"]        │
│                                                                 │
│  KLJUČNO: Ovo je REFERENCA, ne kopija!                          │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 4: ValueManager.set() - Inicijalne vrijednosti            │
│  ═══════════════════════════════════════════════════            │
│                                                                 │
│  Za svaki input:                                                │
│    1. FIRSTNAME → SQL → "Kenan"                                 │
│    2. NAME → SQL → "Testni korisnik"                            │
│    3. JOBTITLE → SQL → "Direktor"                               │
│    4. PRIKLJUCAK_ADSL → defaultValue → ""                       │
│    ...                                                          │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "Osnovneusluge": {},                                         │
│    "Osnovnipaket-Fizicka": {                                    │
│      FIRSTNAME: "Kenan",           ← SQL rezultat               │
│      NAME: "Testni korisnik",      ← SQL rezultat               │
│      JOBTITLE: "Direktor",         ← SQL rezultat               │
│      PRIKLJUCAK_ADSL: "",          ← defaultValue               │
│      PUSER_EMAIL: "kenan@test.com" ← SQL rezultat               │
│      // ... sve ostale vrijednosti                              │
│    }                                                            │
│  }                                                              │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 5: Angular [(ngModel)] - Korisnik mijenja vrijednosti     │
│  ══════════════════════════════════════════════════════         │
│                                                                 │
│  Template: <input [(ngModel)]="model[items.name]">             │
│                                                                 │
│  Korisnik upiše "John" umjesto "Kenan":                         │
│    1. Angular detektuje promjenu                                │
│    2. Ažurira: model["FIRSTNAME"] = "John"                      │
│    3. Pošto model = db.model["Osnovnipaket-Fizicka"] (REF!)     │
│    4. Automatski: db.model["Osnovnipaket-Fizicka"]["FIRSTNAME"] │
│                   = "John"                                      │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "Osnovneusluge": {},                                         │
│    "Osnovnipaket-Fizicka": {                                    │
│      FIRSTNAME: "John",             ← PROMIJENIO KORISNIK!      │
│      NAME: "Test Company",          ← PROMIJENIO KORISNIK!      │
│      JOBTITLE: "CEO",               ← PROMIJENIO KORISNIK!      │
│      PRIKLJUCAK_ADSL: "1234567",    ← PROMIJENIO KORISNIK!      │
│      // ...                                                     │
│    }                                                            │
│  }                                                              │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 6: Finalni db.model - Sva polja popunjena                 │
│  ═══════════════════════════════════════════════                │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "Osnovneusluge": {},                                         │
│    "Osnovnipaket-Fizicka": {                                    │
│      FIRSTNAME: "John",                                         │
│      NAME: "Test Company",                                      │
│      JOBTITLE: "CEO",                                           │
│      PRIKLJUCAK_ADSL: "1234567",                                │
│      ACTION_PNK: "DA",                                          │
│      FRSEGSCLASS_CODE: "GOLD",                                  │
│      PUSER_EMAIL: "john@test.com",                              │
│      DEFAULTCONTACTPHONE: "+387611234567",                      │
│      OFFER_NAME: "Osnovni paket",                               │
│      DEFAULTCONTACTEMAIL: "contact@test.com",                   │
│      PQUANTITY_NUM: "1",                                        │
│      CCC_IND: "N"                                               │
│    },                                                           │
│    "Tarifnipaketi": {                                           │
│      "Tarifnipaket1": { TARIFF_CODE: "TP100", ... }             │
│    },                                                           │
│    "Zabranainfo": {},                                           │
│    "Preuzimanja": {}                                            │
│  }                                                              │
│                                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│  FAZA 7: saveSuicapture() - Slanje na backend                   │
│  ═══════════════════════════════════════════════                │
│                                                                 │
│  Request body:                                                  │
│  {                                                              │
│    id: "999888777",                                             │
│    processId: "10",                                             │
│    model: JSON.stringify({                                      │
│      model: db.model,         ← CIJELI popunjeni model!         │
│      output: setOutput()      ← Transformisani output           │
│    })                                                           │
│  }                                                              │
│                                                                 │
│  Backend:                                                       │
│    INSERT INTO SUI_CAPTURE (ID, PROCESS_ID, MODEL, ...)         │
│    VALUES ('999888777', '10', '{"model":{...}, ...}', ...)      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ↓
                   ┌────────────────────┐
                   │  PODACI SAČUVANI!  │
                   └────────────────────┘
```

---

## FAQ - Najčešća pitanja

### Q1: Zašto db.model["Osnovnipaket-Fizicka"] umjesto db.model["Osnovneusluge"]["Osnovnipaket-Fizicka"]?

**A:** Zato što DefaultBlock prosleđuje `[model]="model"` (cijeli model), ne `[model]="model[items.name]"`. Ovo je dizajn odluka - svi blokovi su na istom nivou umjesto nested strukture.

### Q2: Kako input komponente znaju gdje da stave vrijednost?

**A:** BasicBlock prosleđuje `[model]="model[items.name]"` djeci, što je **REFERENCA** na `db.model["Osnovnipaket-Fizicka"]`. Kada input promijeni `model[items.name]`, on direktno mijenja originalni `db.model`.

### Q3: Šta je Angular [(ngModel)] two-way binding?

**A:** `[(ngModel)]` automatski sinhronizuje:
- Model → View: Kada se `model[items.name]` promijeni, input se ažurira
- View → Model: Kada korisnik unese nešto, `model[items.name]` se ažurira

Nema potrebe za dodatnim event handlerima!

### Q4: Kada se poziva ValueManager.set()?

**A:** U `ContentLoader.ngOnInit()` nakon što se input komponenta renderuje. ValueManager postavlja inicijalnu vrijednost (iz SQL, defaultValue, ili prazan string).

### Q5: Zašto je važno da je model = REFERENCA?

**A:** Zato što se objekti u JavaScriptu prosleđuju po referenci, ne po vrijednosti. Kada BasicBlock proslijedi `model[items.name]` input komponenti, input direktno modifikuje originalni `db.model` objekat, ne kopiju.

**Primjer:**

```typescript
let original = { name: "Kenan" };
let referenca = original;      // REFERENCA, ne kopija
referenca.name = "John";
console.log(original.name);    // "John" ← Promijenio se original!
```

### Q6: Kako se dodaju child elementi (Tarifni paketi)?

**A:** Isti proces se ponavlja:
1. Child komponenta kreira `db.model["Tarifnipaketi"] = {}`
2. Child sub-komponenta kreira `db.model["Tarifnipaketi"]["Tarifnipaket1"] = {}`
3. Input komponente pune `db.model["Tarifnipaketi"]["Tarifnipaket1"][fieldName]`

### Q7: Šta je db.output i kako se razlikuje od db.model?

**A:**
- `db.model` = **"flat" struktura** sa svim vrijednostima
- `db.output` = **nested struktura** sa `active` i `value` properties

`db.output` prati hijerarhiju (Osnovne usluge → Osnovni paket → inputs), dok `db.model` ima sve na istom nivou.

### Q8: Zašto je auto: {} u db.model?

**A:** `auto` property se koristi za auto-inkrement polja i druge sistemske vrijednosti koje nisu vezane za specifični blok.

---

## Console.log output - Cijeli flow

Kada pokrenete aplikaciju sa svim console.log-ovima, vidjet ćete:

```
=== assignObjects() START ===
db.model NAKON assign: {"auto":{}}
db.output NAKON assign: {}
db.params NAKON assign: {}
=== assignObjects() END ===

db.model NAKON assignObjects: {"auto":{}}

HTTP GET /pcrt/order-entry?interactionId=16&productOfferId=1174...

=== DefaultBlock ngOnInit ===
items.name: Osnovneusluge
items.label: Osnovne usluge
items.code: 162
model PRIJE kreiranja: {"auto":{}}
model NAKON kreiranja: {"auto":{},"Osnovneusluge":{}}
Kreiran nested objekat: model["Osnovneusluge"] = {}
======================

=== BasicBlock ngOnInit ===
items.name: Osnovnipaket-Fizicka
items.label: Osnovni paket- Fizicka
items.code: 1174
model PRIJE kreiranja: {"auto":{},"Osnovneusluge":{}}
model NAKON kreiranja: {"auto":{},"Osnovneusluge":{},"Osnovnipaket-Fizicka":{}}
Kreiran nested objekat: model["Osnovnipaket-Fizicka"] = {}
======================

=== ContentLoader ngOnInit ===
items.name: FIRSTNAME
items.label: Ime
model PRIJE ValueManager.set: {}
EXECUTING SQL: SELECT contact.firstname FROM contact WHERE contact.id = 123456
SQL RESULT: "Kenan"
model NAKON ValueManager.set: {"FIRSTNAME":"Kenan"}
======================

=== ContentLoader ngOnInit ===
items.name: NAME
items.label: Prezime/Naziv
model PRIJE ValueManager.set: {"FIRSTNAME":"Kenan"}
EXECUTING SQL: SELECT CASE WHEN contact.customertype = 'BUSINESS' THEN contact.companyname ELSE contact.lastname END FROM contact WHERE contact.id = 123456
SQL RESULT: "Testni korisnik"
model NAKON ValueManager.set: {"FIRSTNAME":"Kenan","NAME":"Testni korisnik"}
======================

... (ponavlja se za sva polja)

=== validateinformations() START ===
this.r (required fields): ["ca","ba","contact"]
valid (nedostajuća polja): []
✓ SVI required objekti postoje (ca, ba, contact)
=== validateinformations() END ===

=== saveSuicapture START ===
db.model (cijeli model): {"auto":{},"Osnovneusluge":{},"Osnovnipaket-Fizicka":{"FIRSTNAME":"John","NAME":"Test Company",...}}
db.output (cijeli output): {"Osnovneusluge":{"active":true,"value":{...}}}

=== setOutput() START ===
db.output PRIJE deep copy: {"Osnovneusluge":{"active":true,"value":{...}}}
output NAKON deep copy (prije handleOutput): {"Osnovneusluge":{"active":true,"value":{...}}}
output NAKON handleOutput (finalni output za backend): {"Osnovneusluge":{"active":true,"value":{...}}}
=== setOutput() END ===

Request body: {"id":"999888777","processId":"10","model":"{\"model\":{...},\"output\":{...}}"}
=== saveSuicapture END ===

HTTP POST /pcrt/sui-capture
Suicapture saved! {status: "OK"}
```

---

## Ključne tačke za zapamtiti

```
┌─────────────────────────────────────────────────────────────────┐
│  1. db.model kreće kao prazan objekat: { auto: {} }            │
│                                                                 │
│  2. DefaultBlock i BasicBlock kreiraju nested objekte:          │
│     db.model["Osnovneusluge"] = {}                              │
│     db.model["Osnovnipaket-Fizicka"] = {}                       │
│                                                                 │
│  3. BasicBlock prosleđuje model[items.name] = REFERENCA djeci   │
│                                                                 │
│  4. ValueManager.set() postavlja inicijalnu vrijednost:         │
│     - generationFormula (SQL via backend)                       │
│     - defaultValue (statička vrijednost)                        │
│     - mappingRef (iz parametara)                                │
│     - fallback (prazan string ili false)                        │
│                                                                 │
│  5. Angular [(ngModel)] automatski sinhronizuje View ↔ Model    │
│                                                                 │
│  6. Korisnik mijenja vrijednosti → db.model se automatski       │
│     ažurira (zbog REFERENCE pattern-a)                          │
│                                                                 │
│  7. saveSuicapture() šalje cijeli db.model na backend           │
│                                                                 │
│  KLJUČNI KONCEPT: REFERENCA, ne kopija!                         │
│  ════════════════════════════════════════                       │
│  Kada BasicBlock proslijedi model[items.name] input             │
│  komponenti, input dobija POKAZIVAČ na originalni               │
│  db.model["Osnovnipaket-Fizicka"], ne novu kopiju.              │
│  Zato sve promjene se automatski reflektuju u db.model!         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## KORAK 5: Od `<z-pageloader>` do popunjavanja `db.model` - Ultra-detaljni walkthrough sa STVARNIM podacima

### Uvod

U KORAK 4 smo vidjeli **ŠTA** se dešava sa `db.model` kroz 7 faza. Sada ćemo vidjeti **KAKO TAČNO** se to dešava - od momenta kada se `<z-pageloader>` renderuje do momenta kada `db.model` bude potpuno popunjen.

Ovaj korak koristi **STVARNE podatke** iz konzole i backenda (order-entry response) da bi pokazao tačno kako sistem radi.

**NAPOMENA:** Sve vrijednosti su `null` jer je `db.mod='disabled'`, što znači da se SQL upiti ne izvršavaju. U normalnom modu (`db.mod='new'` ili `db.mod='edit'`), vrijednosti bi bile popunjene sa podacima iz baze.

---

### STARTNA POZICIJA

**Template:** `evidencija-usluge.template.html` (linija 265)

```html
<z-pageloader
  [ngClass]="{inactive:!db.mod||db.mod=='disabled'}"
  *ngIf="structure"
  [model]="db.model"
  [items]="structure.structure"
  [output]="db.output"
  [vparent]="db.valid"
  [valid]="db.valid.children"
  [parameters]="db.params">
</z-pageloader>
```

**Stanje prije renderovanja:**

```typescript
// db.model je prazan (samo auto):
db.model = { auto: {} }

// db.mod = 'disabled' (zato su sve vrijednosti null)

// structure.structure je array sa strukturom sa backenda (/pcrt/order-entry):
structure.structure = [
  {
    label: "Flat paketi POTS",         // ← STVARNI podatak
    name: "FlatpaketiPOTS",             // ← VAŽNO za kreiranje model property-ja
    code: "979",
    template: "default_block",          // ← Ovim se određuje koja komponenta se renderuje
    elements: [
      {
        label: "Flat BH Telecom",       // ← STVARNI podatak
        name: "FlatBHTelecom",          // ← VAŽNO za kreiranje model property-ja
        code: "5919",
        template: "basic_block",        // ← Ovim se određuje koja komponenta se renderuje
        inputs: [
          { name: "FIRSTNAME", label: "Ime", elementType: "text", template: "input",
            value: { generationFormula: "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual" } },
          { name: "NAME", label: "Prezime/Naziv", elementType: "text", template: "input",
            value: { generationFormula: "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'LASTNAME') from dual" },
            validation: { mandatory: true } },
          { name: "JOBTITLE", label: "Funkcija", elementType: "select", template: "select",
            value: { lookupStatement: "select code, displayname from roccupation " } },
          { name: "PRIKLJUCAK_ADSL", label: "Na lokaciji", elementType: "select", template: "select",
            validation: { mandatory: true } },
          { name: "ACTION_PNK", label: "Da li ju u akciji", elementType: "text", template: "input",
            disabled: true, visible: false },
          { name: "FRSEGSCLASS_CODE", label: "Grupa podtipova", elementType: "text", template: "input" },
          { name: "PUSER_EMAIL", label: "Trenutni email", elementType: "text", template: "input", visible: false },
          { name: "DEFAULTCONTACTPHONE", label: "Kontakt telefon", elementType: "text", template: "input", visible: false },
          { name: "OFFER_NAME", label: "Naziv paketa", elementType: "text", template: "input",
            disabled: true, visible: false },
          { name: "DEFAULTCONTACTEMAIL", label: "Email korisnika", elementType: "text", template: "input", visible: false },
          { name: "PQUANTITY_NUM", label: "Količina", elementType: "text", template: "input", visible: false },
          { name: "CCC_IND", label: "CCC indikator", elementType: "text", template: "input", visible: false }
          // Ukupno 14 inputa
        ],
        children: [
          { label: "Tarifni paketi", name: "Tarifnipaketi", code: "178", template: "default_block" },
          { label: "Preuzimanja", name: "Preuzimanja", code: "164", template: "default_block" },
          { label: "Dodatne usluge tehnicke (1)", name: "Dodatneuslugetehnicke(1)", code: "721", template: "default_block" },
          { label: "Promjene", name: "Promjene", code: "740", template: "default_block" },
          { label: "Fiksna  - ugovorni odnos", name: "Fiksnaugovorniodnos", code: "2016", template: "default_block" },
          { label: "Dodavanje pratioca u nebrojčanu seriju", name: "Dodavanjepratiocaunebrojčanuseriju", code: "960", template: "default_block" },
          { label: "Detaljni ispis poziva, redovno", name: "Detaljniispispoziva,redovno", code: "165", template: "default_block" },
          { label: "Specifikacija za Prodaju van poslovnih prostorija - FIKSNA", name: "SpecifikacijazaProdajuvanposlovnihprostorijaFIKSNA", code: "1704", template: "default_block" },
          { label: "Zabrana informacija", name: "Zabranainformacija", code: "742", template: "default_block" }
          // Ukupno 9 children
        ]
      }
    ]
  }
]

// db.output, db.valid, db.params su također inicijalizovani
```

**Angular vidi:**
- `*ngIf="structure"` je `true` (struktura je stigla sa backenda)
- `<z-pageloader>` komponenta se renderuje

---

## 🔥 ANGULAR DATA BINDING - Objašnjenje za početnike

**PRIJE nego što nastavimo sa detaljnim koracima, MORA se razumjeti šta znače uglaste zagrade `[ ]` u template-u!**

### TRIK ZA PAMĆENJE: Zagrade kao strelice

Zagrade ti govore **SMJER** podataka. Zamisli ih kao **strelice**:

```
[property]="value"     →  UGLASTE ZAGRADE = ULAZ (podatak IDE U komponentu)
(event)="handler()"    →  OKRUGLE ZAGRADE = IZLAZ (podatak IZLAZI iz komponente)
[(ngModel)]="value"    →  OBA = ULAZ + IZLAZ (dvosmjerno)
```

### Analogija: KUTIJA ZA POŠTU

Zamisli da je svaka komponenta **kuća**, a data binding je **poštanski sistem**:

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   [property]="value"         KUTIJA ZA PRIMANJE POŠTE       │
│   ┌─────┐                                                   │
│   │ [ ] │ ← Uglaste zagrade = kutija na ulaznim vratima     │
│   └─────┘   Pošta ULAZI u kuću                              │
│             Parent ŠALJE podatke child-u                     │
│                                                              │
│                                                              │
│   (event)="handler()"        ZVONO NA VRATIMA               │
│   ┌─────┐                                                   │
│   │ ( ) │ ← Okrugle zagrade = zvono koje zvoni              │
│   └─────┘   Kuća OBAVJEŠTAVA nekoga napolju                 │
│             Child ŠALJE podatke parent-u                     │
│                                                              │
│                                                              │
│   [(ngModel)]="value"        INTERFON (dvosmjerni)          │
│   ┌──────┐                                                  │
│   │ [()] │ ← Oba = interfon (govoriš i slušaš)             │
│   └──────┘   Podatak IDE u oba smjera                       │
│             Parent ↔ Child (oba smjera)                      │
│                                                              │
│                                                              │
│   property="value"           NALJEPNICA NA KUĆI              │
│   ┌─────┐                                                   │
│   │     │ ← Bez zagrada = naljepnica (statički tekst)       │
│   └─────┘   Nikad se ne mijenja                             │
│             Uvijek isti string                               │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

### 1. `[property]="value"` - UGLASTE ZAGRADE = ULAZ

**Trik za pamćenje:** Uglaste zagrade `[ ]` izgledaju kao **kutija** - podatak ULAZI u kutiju (u komponentu)

**Smjer:** Parent → Child

```
┌─────────────────┐           ┌─────────────────┐
│                 │   [model]  │                 │
│  PARENT         │ ────────→ │  CHILD           │
│  (Evidencija)   │  db.model  │  (PageLoader)    │
│                 │           │                 │
│  db.model = {}  │           │  @Input() model  │
│                 │           │  // prima {}      │
└─────────────────┘           └─────────────────┘
```

**Analogija:** Ti (parent) **daješ poklon** (podatak) djetetu (child). Dijete prima poklon kroz `@Input()`.

```typescript
// PARENT komponenta (daje podatak):
export class EvidencijaComponent {
  db = { model: { auto: {} } };
}
```

```html
<!-- PARENT template (šalje podatak): -->
<z-pageloader [model]="db.model"></z-pageloader>
<!--            └──┬──┘ └──┬───┘
                   │       └─ Šta šaljem? (db.model objekat)
                   └───────── Kome šaljem? (u "model" input child-a) -->
```

```typescript
// CHILD komponenta (prima podatak):
export class PageLoaderComponent {
  @Input() model: object;  // ← PRIMA podatak od parent-a
  //  ↑
  //  @Input() dekorator kaže: "Ovo polje PRIMA podatke izvana"
}
```

---

### 2. `(event)="handler()"` - OKRUGLE ZAGRADE = IZLAZ

**Trik za pamćenje:** Okrugle zagrade `( )` izgledaju kao **usta** - komponenta GOVORI (šalje poruku napolje)

**Smjer:** Child → Parent

```
┌─────────────────┐            ┌─────────────────┐
│                 │  (clicked)  │                 │
│  PARENT         │ ←───────── │  CHILD           │
│  (Evidencija)   │  "kliknuo" │  (Button)        │
│                 │            │                 │
│  onClicked()    │            │  @Output() click │
│                 │            │  // šalje event   │
└─────────────────┘            └─────────────────┘
```

**Analogija:** Dijete (child) **viče** (emituje event) da kaže nešto roditelju (parent). Roditelj sluša.

```typescript
// CHILD komponenta (šalje podatak):
export class ButtonComponent {
  @Output() clicked = new EventEmitter<string>();
  //  ↑
  //  @Output() dekorator kaže: "Ovo polje ŠALJE podatke napolje"

  onClick() {
    this.clicked.emit("Korisnik je kliknuo!");  // ŠALJE poruku parent-u
  }
}
```

```html
<!-- PARENT template (sluša event): -->
<my-button (clicked)="onClicked($event)"></my-button>
<!--         └──┬──┘  └──────┬────────┘
                │             └─ Šta radim kad primim? (pozovi onClicked metodu)
                └─────────────── Koji event slušam? ("clicked" event od child-a) -->
```

```typescript
// PARENT komponenta (prima podatak):
export class EvidencijaComponent {
  onClicked(message: string) {
    console.log(message);  // "Korisnik je kliknuo!"
  }
}
```

---

### 3. `[(ngModel)]="value"` - OBA = ULAZ + IZLAZ

**Trik za pamćenje:** `[( )]` izgleda kao **banana u kutiji** 🍌📦 - Angular zajednica to zove **"banana in a box"**

**Smjer:** Parent ↔ Child (oba smjera)

```
┌─────────────────┐            ┌─────────────────┐
│                 │ [(ngModel)] │                 │
│  PARENT         │ ←────────→ │  INPUT FIELD     │
│  (Evidencija)   │  db.model   │  <input>         │
│                 │ ["FIRSTNAME"]│                 │
│  db.model =     │            │  Korisnik upiše  │
│  {FIRSTNAME:""}  │            │  "Kenan"         │
└─────────────────┘            └─────────────────┘
```

**Analogija:** **Interfon** - ti govoriš I slušaš istovremeno. Kad se promijeni na jednoj strani, automatski se promijeni na drugoj.

```html
<input [(ngModel)]="model[items.name]">
```

**Ovo je SKRAĆENICA za:**

```html
<input
  [ngModel]="model[items.name]"
  (ngModelChange)="model[items.name] = $event">
<!--  └──────┬──────┘                └──────┬──────┘
       ULAZ (prikaži vrijednost)       IZLAZ (ažuriraj kad korisnik promijeni) -->
```

---

### 4. `property="value"` - BEZ ZAGRADA = STATIČKI STRING

**Trik za pamćenje:** Nema zagrada = **naljepnica** - jednom zalijepiš i nikad se ne mijenja

```html
<!-- Ovo je UVIJEK string "hello", nikad se ne mijenja: -->
<child name="hello"></child>

<!-- Ovo EVALUIRA TypeScript izraz: -->
<child [name]="user.name"></child>
```

---

### VIZUALNI TRIK ZA PAMĆENJE

```
┌────────────────────────────────────────────────────┐
│                                                    │
│     [  ]    =  ULAZ     =  @Input()    = Parent→Child  │
│     (  )    =  IZLAZ    =  @Output()   = Child→Parent  │
│     [( )]   =  OBA      =  Input+Output = ↔ Oba smjera │
│     ništa   =  STATIČKO =  Obični string = Nema smjera │
│                                                    │
│  ZAGRADE = STRELICE SMJERA PODATAKA!               │
│                                                    │
│     [ → ]   Podatak IDE U komponentu               │
│     ( ← )   Podatak IZLAZI iz komponente           │
│     [( ↔ )] Podatak IDE u oba smjera               │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

### RAZLIKA: SA i BEZ uglatih zagrada

**SA uglatim zagradama `[model]="db.model"` (Property Binding):**
```html
<z-pageloader [model]="db.model"></z-pageloader>
```
- Angular **evaluira** `db.model` kao TypeScript expression
- Prosleđuje **objekat** `{ auto: {} }`
- Child komponenta prima **objekat**, ne string

**BEZ uglatih zagrada `model="db.model"` (String Literal):**
```html
<z-pageloader model="db.model"></z-pageloader>
```
- Angular **NE evaluira** ništa
- Prosleđuje **string** `"db.model"` (doslovce tekst)
- Child komponenta prima **string** `"db.model"`, ne objekat

**Primjeri:**

```html
<!-- SA uglatim zagradama (Property Binding): -->
<child [value]="db.model"></child>
<!-- Child prima: { auto: {} } (OBJEKAT) -->

<!-- BEZ uglatih zagrada (String Literal): -->
<child value="db.model"></child>
<!-- Child prima: "db.model" (STRING) -->

<!-- Broj: -->
<child [value]="42"></child>
<!-- Child prima: 42 (BROJ) -->

<!-- Boolean: -->
<child [value]="true"></child>
<!-- Child prima: true (BOOLEAN) -->

<!-- Array: -->
<child [value]="[1, 2, 3]"></child>
<!-- Child prima: [1, 2, 3] (ARRAY) -->
```

---

### ANALIZA NAŠEG `<z-pageloader>` TEMPLATE-A

Hajde da analiziramo svaki binding u našem template-u:

```html
<z-pageloader
  [ngClass]="{inactive:!db.mod||db.mod=='disabled'}"
  *ngIf="structure"
  [model]="db.model"
  [items]="structure.structure"
  [output]="db.output"
  [vparent]="db.valid"
  [valid]="db.valid.children"
  [parameters]="db.params">
</z-pageloader>
```

| Binding | Što se evaluira | Vrijednost koja se prosleđuje | Tip |
|---------|----------------|-------------------------------|-----|
| `[ngClass]="{...}"` | Objekat sa class mapom | `{ inactive: true/false }` | Object |
| `*ngIf="structure"` | `this.structure` | `true/false` | Boolean |
| `[model]="db.model"` | `this.db.model` | `{ auto: {} }` | Object |
| `[items]="structure.structure"` | `this.structure.structure` | `[{...}]` (array) | Array |
| `[output]="db.output"` | `this.db.output` | `{}` | Object |
| `[vparent]="db.valid"` | `this.db.valid` | `{ valid: true, ... }` | Object |
| `[valid]="db.valid.children"` | `this.db.valid.children` | `{}` | Object |
| `[parameters]="db.params"` | `this.db.params` | `{ P_OFFER_ID: "5919", ... }` | Object |

**Svi koriste `[ ]` = svi idu u jednom smjeru: Parent (Evidencija) → Child (PageLoader)**

---

### PARENT ↔ CHILD KOMUNIKACIJA

#### Šta je Parent, a šta Child?

**JEDNOSTAVNO PRAVILO:** Pogledaj **template (HTML)**. Komponenta čiji template **sadrži tag** druge komponente je **PARENT**.

```html
<!-- Ovo je template od Evidencija-usluge komponente: -->
<z-pageloader [model]="db.model"></z-pageloader>
<!-- ↑ z-pageloader je CHILD jer se nalazi u TUĐEM template-u -->
<!-- ↑ Evidencija-usluge je PARENT jer NJEN template sadrži z-pageloader -->
```

**Porodično stablo našeg koda:**

```
Evidencija-usluge (PARENT)
    │
    └── z-pageloader (CHILD od Evidencije, ali PARENT za ContentLoader)
            │
            └── z-contentloader (CHILD od PageLoader-a)
                    │
                    └── z-dlcontent (CHILD od ContentLoader-a)
                            │
                            └── DefaultBlock (CHILD od DLContent-a)
                                    │
                                    └── BasicBlock
                                            │
                                            └── InputComponent
```

#### Kako znati smjer podataka?

**TRIK: Pogledaj zagrade u template-u!**

```html
<z-pageloader
  [model]="db.model"           <!-- [ ] = Parent ŠALJE db.model CHILD-u -->
  [items]="structure.structure" <!-- [ ] = Parent ŠALJE structure CHILD-u -->
  (onComplete)="handleDone()"  <!-- ( ) = Child ŠALJE event PARENT-u -->
>
</z-pageloader>
```

**Vizualno:**

```
PARENT (Evidencija)                    CHILD (PageLoader)
┌──────────────────┐                   ┌──────────────────┐
│                  │                   │                  │
│  db.model ───────│──[model]────────→ │ @Input() model   │
│                  │                   │                  │
│  structure ──────│──[items]────────→ │ @Input() items   │
│  .structure      │                   │                  │
│                  │                   │                  │
│  db.output ──────│──[output]───────→ │ @Input() output  │
│                  │                   │                  │
│  db.params ──────│──[parameters]───→ │ @Input() params  │
│                  │                   │                  │
└──────────────────┘                   └──────────────────┘

Sve strelice idu → (u jednom smjeru: Parent → Child)
Jer sve koriste [ ] (uglaste zagrade = ULAZ u child)
```

---

### REFERENCE vs KOPIJE - KRITIČNO ZA RAZUMIJEVANJE!

**Analogija: Google Docs vs Email**

**REFERENCA (Objekat/Array):**
Zamisli da šalješ kolegi **link na Google Docs**. Obojica gledate **ISTI dokument**. Kada kolega promijeni tekst, ti **automatski vidiš promjenu**.

```typescript
let parent = { auto: {} };
let child = parent;  // REFERENCA (isti objekat!)

child["FIRSTNAME"] = "Kenan";
console.log(parent);  // { auto: {}, FIRSTNAME: "Kenan" }
// ↑ Parent VIDI promjenu jer je ISTI objekat!
```

**KOPIJA (String/Number/Boolean):**
Zamisli da šalješ kolegi tekst **emailom**. Svako ima **svoju kopiju**. Kada kolega promijeni tekst, ti **NE vidiš promjenu**.

```typescript
let parent = "Kenan";
let child = parent;  // KOPIJA (novi string!)

child = "John";
console.log(parent);  // "Kenan"
// ↑ Parent NE VIDI promjenu jer je KOPIJA!
```

**U našem kodu:**

```html
<z-pageloader [model]="db.model"></z-pageloader>
```

`db.model` je **objekat** → prosleđuje se **REFERENCA** (Google Docs link)

Zato kada DefaultBlock radi:
```typescript
this.model["FlatpaketiPOTS"] = {};
```
To **automatski mijenja** `db.model` u parent komponenti jer je **ISTI objekat**!

```
db.model = { auto: {} }                    // PARENT vidi ovo
           ↕ (ISTI objekat u memoriji!)
this.model = { auto: {} }                  // CHILD vidi ovo

// Child dodaje property:
this.model["FlatpaketiPOTS"] = {};

// Sada OBA vide:
db.model = { auto: {}, FlatpaketiPOTS: {} }  // PARENT
this.model = { auto: {}, FlatpaketiPOTS: {} } // CHILD
// ↑ ISTI objekat! Promjena u child-u se automatski vidi u parent-u!
```

---

### 📋 REZIME TRIKOVA ZA PAMĆENJE

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  TRIK 1: ZAGRADE = SMJER                                   │
│                                                            │
│    [ ] = ULAZ u child    (kutija za primanje pošte)        │
│    ( ) = IZLAZ iz child-a (zvono na vratima)               │
│    [()]= OBA smjera       (interfon / "banana in a box")   │
│                                                            │
│  TRIK 2: KO JE PARENT?                                     │
│                                                            │
│    Pogledaj TEMPLATE. Ako komponenta A                      │
│    u svom template-u SADRŽI tag <komponenta-b>,             │
│    onda je A = PARENT, B = CHILD                            │
│                                                            │
│  TRIK 3: SMJER PODATAKA                                    │
│                                                            │
│    @Input()  = Child PRIMA od parent-a    [ ]              │
│    @Output() = Child ŠALJE parent-u       ( )              │
│                                                            │
│  TRIK 4: REFERENCA vs KOPIJA                                │
│                                                            │
│    Objekat/Array = REFERENCA (Google Docs link)             │
│    String/Number/Boolean = KOPIJA (Email)                   │
│                                                            │
│    Ako prosleđuješ OBJEKAT, child i parent dijele          │
│    ISTI objekat. Promjena u child-u se automatski           │
│    vidi u parent-u!                                         │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**Sada kada razumiješ šta znače uglaste zagrade `[ ]`, hajde da razumiješ još DVA ključna Angular mehanizma prije nego što nastaviš sa detaljnim koracima!** 🎯

---

## 🔄 ANGULAR MEHANIZMI - *ngFor i Dinamičko kreiranje komponenti

> **VAŽNO:** Ova sekcija objašnjava DVA ključna mehanizma koja ćeš vidjeti u DETALJNIM KORACIMA:
> 1. **Kako *ngFor kreira više child komponenti** (iteracija kroz array)
> 2. **Kako sistem zna koju komponentu kreirati** na osnovu `items.template`
>
> Pročitaj pažljivo - bez ovog razumijevanja, detaljni koraci neće imati smisla! 💡

---

### DIO 1: *ngFor - Parent-Child komunikacija

---

#### 1.1 ANALOGIJA: AMAZON SKLADIŠTE

Zamislite da radite u **Amazon skladištu** i upravo je stigao kamion sa paletom.

```
🚛 KAMION (Backend response)
 └── 📦 PALETA (structure.structure = array)
      └── 📦 VELIKA KUTIJA: "Flat paketi POTS"
           ├── 📦 SREDNJA KUTIJA: "Flat BH Telecom"
           │    ├── 📄 Mali paket: "Ime" (FIRSTNAME)
           │    ├── 📄 Mali paket: "Prezime" (NAME)
           │    ├── 📄 Mali paket: "Funkcija" (JOBTITLE)
           │    ├── 📄 ... (još 11 malih paketa)
           │    │
           │    ├── 📦 Podkutija: "Tarifni paketi"
           │    │    ├── 📄 Mali paket: "Tarifa"
           │    │    └── 📄 ...
           │    ├── 📦 Podkutija: "Preuzimanja"
           │    └── 📦 ... (još 7 podkutija)
           │
           └── (moguće još srednje kutije)
```

**Svaka osoba u skladištu ima JEDNU zadaću:**
- **Šefica smjene** (PageLoader) → otvara PALETU, vadi VELIKE kutije
- **Radnik** (ContentLoader) → otvara JEDNU kutiju, gleda etiketu, prosljeđuje dalje
- **Sorter** (DefaultBlock/BasicBlock) → sortira sadržaj kutije na: artikle, podkutije

**KLJUČNO PRAVILO SKLADIŠTA:**
> Niko ne otvara SVE kutije odjednom. Svaka osoba otvara JEDNU stvar, i za svaki artikal unutra poziva NOVOG radnika.

To je upravo ono što radi `*ngFor` - za SVAKI element u kutiji, poziva NOVOG radnika!

---

#### 1.2 ŠTA JE *ngFor? - Jednostavno objašnjenje

`*ngFor` je Angularova komanda koja kaže:

> "Za SVAKI element u ovom array-u, napravi KOPIJU ovog HTML elementa"

```
Zamislite da imate JEDNU šablonu za koverte:

┌─────────────────────┐
│ Za: ____________     │
│ Od: Amazon           │
│ Sadržaj: ___________ │
└─────────────────────┘

I imate 3 artikla za poslati.

*ngFor kaže: "Napravi 3 koverte, po jednu za svaki artikal"

┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│ Za: FIRSTNAME        │  │ Za: NAME             │  │ Za: JOBTITLE         │
│ Od: Amazon           │  │ Od: Amazon           │  │ Od: Amazon           │
│ Sadržaj: "Ime"       │  │ Sadržaj: "Prezime"   │  │ Sadržaj: "Funkcija"  │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

**U kodu to izgleda ovako:**

```html
<!-- ŠABLON (piše se jednom): -->
<z-contentloader *ngFor="let item of items" [items]="item">
</z-contentloader>

<!-- ANGULAR KREIRA (automatski, za svaki element): -->
<z-contentloader [items]="items[0]"></z-contentloader>  <!-- 1. koverta -->
<z-contentloader [items]="items[1]"></z-contentloader>  <!-- 2. koverta -->
<z-contentloader [items]="items[2]"></z-contentloader>  <!-- 3. koverta -->
```

---

#### 1.3 RAŠČLANJIVANJE SINTAKSE - Svaka riječ ima značenje

```
*ngFor="let item of items"
│       │   │    │   │
│       │   │    │   └── items = IZVOR PODATAKA (array kroz koji iteriramo)
│       │   │    │        → Ovo je @Input() items koji je parent proslijedio
│       │   │    │
│       │   │    └────── of = "IZ" (ključna riječ, kao "iz kutije")
│       │   │
│       │   └─────────── item = LOKALNA VARIJABLA (jedan element iz array-a)
│       │                 → Ovo IME biramo MI! Mogli smo napisati "banana"
│       │                 → let banana of items → banana = items[0], items[1]...
│       │
│       └─────────────── let = "KREIRAJ VARIJABLU" (JavaScript keyword)
│
└─────────────────────── *ngFor = "ZA SVAKI" (Angular direktiva)
```

**Analogija za svaku riječ:**

| Riječ | Analogija Amazon skladište | Primjer |
|-------|---------------------------|---------|
| `*ngFor` | "Za svaku stvar u kutiji..." | Naredba za radnika |
| `let` | "Uzmi jednu stvar i nazovi je..." | Daj joj privremeno ime |
| `item` | "...paket" (ili kako god hoćeš) | Ime koje daješ stvari u ruci |
| `of` | "...iz..." | Pokazuješ odakle vadiš |
| `items` | "...ove kutije" | Kutija iz koje vadiš |

**Na ljudskom jeziku:**
> "Za svaki **paket** iz **ove kutije**, napravi jednu kopiju ovog HTML elementa i daj joj taj **paket**"

---

#### 1.4 STVARNI PRIMJER - Praćenje podataka od početka do kraja

##### FAZA 1: Backend šalje podatke (kamion stiže)

```typescript
// Backend response (= kamion sa paletom)
response = {
  structure: [                    // ← PALETA (array)
    {                             // ← VELIKA KUTIJA #1
      name: "FlatpaketiPOTS",
      label: "Flat paketi POTS",
      template: "default_block",
      elements: [                 // ← SREDNJE KUTIJE unutar velike
        {
          name: "FlatBHTelecom",
          label: "Flat BH Telecom",
          template: "basic_block",
          inputs: [               // ← MALI PAKETI
            { name: "FIRSTNAME", label: "Ime", template: "input" },
            { name: "NAME", label: "Prezime", template: "input" },
            // ... još 11 inputa
          ],
          children: [             // ← PODKUTIJE
            { name: "Tarifnipaketi", label: "Tarifni paketi", template: "basic_block" },
            { name: "Preuzimanja", label: "Preuzimanja", template: "basic_block" },
            // ... još 7 podkutija
          ]
        }
      ]
    }
  ]
}
```

```
U skladištu:

📦 PALETA (structure.structure) sadrži 1 veliku kutiju
 │
 └── 📦 VELIKA KUTIJA: etiketa kaže "default_block"
      │   Naziv: "Flat paketi POTS"
      │
      └── Unutra se nalaze SREDNJE KUTIJE (elements array):
           │
           └── 📦 SREDNJA KUTIJA: etiketa kaže "basic_block"
                │   Naziv: "Flat BH Telecom"
                │
                ├── 📄📄📄 MALI PAKETI (inputs array):
                │   FIRSTNAME, NAME, JOBTITLE, PUSER_EMAIL...
                │
                └── 📦📦📦 PODKUTIJE (children array):
                    Tarifni paketi, Preuzimanja, Zabrana info...
```

---

##### FAZA 2: PageLoader - Šefica otvara paletu

**Stvarni kod** (`pageloader.template.html`):
```html
<z-contentloader
  *ngFor="let item of items"
  [items]="item"
  [model]="model"
  [output]="output"
  ...
></z-contentloader>
```

**Šta se dešava, korak po korak:**

```
ŠEFICA (PageLoader) prima:
   items = structure.structure = [ { name: "FlatpaketiPOTS", ... } ]
                                   ↑
                                   Ovo je ARRAY sa 1 elementom!


KORAK 1: *ngFor gleda u "items" i pita: "Koliko elemenata ima?"
         Odgovor: 1 element (index 0)

KORAK 2: *ngFor kreće u PRVU iteraciju:
         let item = items[0] = { name: "FlatpaketiPOTS", template: "default_block", ... }
         │
         └── "item" je LOKALNA VARIJABLA koja POKAZUJE na items[0]

KORAK 3: Angular kreira JEDNU <z-contentloader> komponentu:
         [items]="item" → ContentLoader prima: { name: "FlatpaketiPOTS", ... }
         [model]="model" → ContentLoader prima: db.model (REFERENCA!)

KORAK 4: Nema više elemenata → *ngFor završava
```

**Analogija:**
```
ŠEFICA otvara paletu:
  "Vidim 1 veliku kutiju na paleti"
  "Pozivam RADNIKA #1 i dajem mu tu kutiju"
  "Nema više kutija, završila sam"
```

**REZULTAT u DOM-u:**
```html
<!-- Angular je kreirao JEDNU instancu: -->
<z-contentloader [items]="{name:'FlatpaketiPOTS', template:'default_block', ...}">
  ...
</z-contentloader>
```

---

##### FAZA 3: ContentLoader - Radnik otvara kutiju i čita etiketu

**Stvarni kod** (`contentloader.template.html`):
```html
<span *ngIf="items.active">
  <z-dlcontent
    [template]="items.template"   ← ČITA ETIKETU!
    [inputs]="{
      items: items,
      model: model,
      ...
    }">
  </z-dlcontent>
</span>
```

```
RADNIK #1 (ContentLoader) prima kutiju i gleda ETIKETU:

  ┌─────────────────────────────┐
  │  📦 KUTIJA                   │
  │                              │
  │  Etiketa: "default_block"    │  ← items.template
  │  Naziv: "Flat paketi POTS"  │  ← items.label
  │                              │
  │  Radnik ČITA etiketu i kaže: │
  │  "Aha, ovo je DEFAULT BLOCK" │
  │  "Moram pozvati SORTERA za   │
  │   default blokove"           │
  └─────────────────────────────┘

  Radnik poziva SORTERA (DefaultBlockComponent)
  i predaje mu CIJELU KUTIJU + MODEL + OUTPUT...
```

**ContentLoader NE otvara kutiju sam!** On samo:
1. Čita etiketu (`items.template`)
2. Na osnovu etikete bira KOJI SORTER da pozove (vidjećeš to u DIO 2!)
3. Prosljeđuje SVE podatke tom sorteru

---

##### FAZA 4: DefaultBlock - Sorter otvara kutiju i sortira sadržaj

**Ovo je KLJUČNA FAZA gdje počinje "child" dio!**

**Stvarni kod** (`defaultblock.template.html`):
```html
<div class="z-default-block">
  <header>
    <h2>{{items.label}}</h2>  <!-- "Flat paketi POTS" -->
  </header>

  <body>
    <!-- MESSAGES: -->
    <z-contentloader
      *ngFor="let message of items.messages"
      [items]="message"
      [model]="model" ...>
    </z-contentloader>

    <!-- ELEMENTS: ← SREDNJE KUTIJE! -->
    <z-contentloader
      *ngFor="let element of items.elements"
      [items]="element"
      [model]="model" ...>          <!-- ← CIJELI model! -->
    </z-contentloader>

    <!-- CHILDREN: ← PODKUTIJE! -->
    <z-contentloader
      *ngFor="let children of items.children"
      [items]="children"
      [model]="model" ...>          <!-- ← CIJELI model! -->
    </z-contentloader>
  </body>
</div>
```

**Šta se dešava, korak po korak:**

```
SORTER (DefaultBlock) otvara kutiju "Flat paketi POTS":

┌────────────────────────────────────────────────────────┐
│  📦 OTVORENA KUTIJA: "Flat paketi POTS"                │
│                                                         │
│  Unutra nalazim:                                        │
│                                                         │
│  📬 messages array:  [prazno]                           │
│     → *ngFor: "Nema poruka, preskačem"                  │
│                                                         │
│  📦 elements array:  [1 srednja kutija]                 │
│     → *ngFor: "Imam 1 element, pozivam 1 radnika"      │
│     → let element = { name: "FlatBHTelecom", ... }      │
│     → [items]="element" → šaljem radniku                │
│                                                         │
│  📦 children array:  [prazno ili undefined]             │
│     → *ngFor: "Nema children, preskačem"                │
└────────────────────────────────────────────────────────┘
```

**Fokusirajmo se na `*ngFor="let element of items.elements"`:**

```typescript
// items.elements je ARRAY:
items.elements = [
  {                                    // index 0
    name: "FlatBHTelecom",
    label: "Flat BH Telecom",
    template: "basic_block",           // ← ETIKETA za sljedeću kutiju!
    inputs: [ ... 14 inputa ... ],     // ← MALI PAKETI unutra
    children: [ ... 9 children ... ]   // ← PODKUTIJE unutra
  }
]

// *ngFor iteracija:
// Iteracija 1: let element = items.elements[0]
//              element = { name: "FlatBHTelecom", template: "basic_block", ... }
//
// [items]="element" → novi ContentLoader prima OVAJ OBJEKAT kao svoj @Input() items
```

```
SORTER vadi SREDNJU KUTIJU iz velike kutije:

  📦 VELIKA KUTIJA: "Flat paketi POTS" (DefaultBlock)
   │
   │  *ngFor="let element of items.elements"
   │  ┌─────────────────────────────────┐
   │  │ Iteracija 1:                     │
   │  │                                  │
   │  │ let element = {                  │
   │  │   name: "FlatBHTelecom",         │
   │  │   template: "basic_block",       │
   │  │   inputs: [14 paketa],           │
   │  │   children: [9 podkutija]        │
   │  │ }                                │
   │  │                                  │
   │  │ SORTER poziva NOVOG RADNIKA:     │
   │  │ "Ej, Radniče #2! Evo ti kutija  │
   │  │  sa etiketom 'basic_block'"      │
   │  │                                  │
   │  │ [items]="element" ← PREDAJE MU  │
   │  └─────────────────────────────────┘
   │
   │  Nema više elemenata → *ngFor završava
   │
```

---

##### FAZA 5: ContentLoader #2 - Radnik čita novu etiketu

```
RADNIK #2 (novi ContentLoader) prima kutiju:

  Prima: @Input() items = { name: "FlatBHTelecom", template: "basic_block", ... }

  Čita etiketu: items.template = "basic_block"

  Kaže: "Aha, ovo je BASIC BLOCK"
        "Pozivam SORTERA za basic blokove!"

  Poziva BasicBlockComponent i predaje mu sve
```

---

##### FAZA 6: BasicBlock - Sorter otvara SREDNJU kutiju

**OVDJE JE KLJUČ ZA "CHILD" DIO!**

**Stvarni kod** (`basicblock.template.html`):
```html
<div class="z-basic-block" *ngIf="output.active">

  <!-- ELEMENTS: -->
  <z-contentloader
    *ngFor="let element of items.elements"
    [items]="element"
    [model]="model[items.name]" ...>     <!-- ← NESTED DIO modela! -->
  </z-contentloader>

  <!-- INPUTS: ← MALI PAKETI! -->
  <z-contentloader
    *ngFor="let input of items.inputs"
    [items]="input"
    [model]="model[items.name]"          <!-- ← NESTED DIO modela! -->
    [parent]="model" ...>                <!-- ← CIJELI model kao parent! -->
  </z-contentloader>

  <!-- CHILDREN: ← PODKUTIJE! -->
  <z-contentloader
    *ngFor="let children of items.children"
    [items]="children"
    [model]="model[items.name]"          <!-- ← NESTED DIO modela! -->
    [parent]="model" ...>                <!-- ← CIJELI model kao parent! -->
  </z-contentloader>

</div>
```

**Šta se dešava sa inputs (mali paketi):**

```typescript
// BasicBlock ima:
// this.items = { name: "FlatBHTelecom", inputs: [...], children: [...] }
// this.model = db.model = { auto: {}, FlatpaketiPOTS: {}, FlatBHTelecom: {} }

// *ngFor="let input of items.inputs"
// items.inputs = [
//   { name: "FIRSTNAME", label: "Ime", template: "input" },          // index 0
//   { name: "NAME", label: "Prezime", template: "input" },           // index 1
//   { name: "JOBTITLE", label: "Funkcija", template: "input" },      // index 2
//   ... još 11 inputa
// ]

// ITERACIJA 1:
let input = items.inputs[0]
// input = { name: "FIRSTNAME", label: "Ime", template: "input" }
// [items]="input"                → child prima OVAJ OBJEKAT
// [model]="model[items.name]"    → child prima model["FlatBHTelecom"] = {}
// [parent]="model"               → child prima CIJELI db.model

// ITERACIJA 2:
let input = items.inputs[1]
// input = { name: "NAME", label: "Prezime", template: "input" }
// [items]="input"                → child prima OVAJ OBJEKAT
// [model]="model[items.name]"    → child prima model["FlatBHTelecom"] = {}
// [parent]="model"               → child prima CIJELI db.model

// ... i tako za svih 14 inputa
```

```
SORTER (BasicBlock) otvara kutiju "Flat BH Telecom":

┌──────────────────────────────────────────────────────────────┐
│  📦 OTVORENA KUTIJA: "Flat BH Telecom"                       │
│                                                               │
│  KORAK 1: Sortira MALE PAKETE (inputs)                        │
│  ─────────────────────────────────────                        │
│                                                               │
│  *ngFor="let input of items.inputs"                           │
│                                                               │
│  📄 Paket 1: FIRSTNAME                                        │
│     → let input = { name:"FIRSTNAME", template:"input" }      │
│     → [items]="input" → Radnik #3 prima ovaj paket            │
│     → [model]="model['FlatBHTelecom']" → prima DIO modela     │
│     → Radnik #3 renderuje: <input> polje za "Ime"             │
│                                                               │
│  📄 Paket 2: NAME                                             │
│     → let input = { name:"NAME", template:"input" }           │
│     → [items]="input" → Radnik #4 prima ovaj paket            │
│     → [model]="model['FlatBHTelecom']" → prima ISTI DIO       │
│     → Radnik #4 renderuje: <input> polje za "Prezime"         │
│                                                               │
│  📄 Paket 3: JOBTITLE                                         │
│     → ... isti proces ...                                     │
│                                                               │
│  📄 ... (još 11 malih paketa, svaki dobije svog radnika)      │
│                                                               │
│                                                               │
│  KORAK 2: Sortira PODKUTIJE (children)                        │
│  ─────────────────────────────────────                        │
│                                                               │
│  *ngFor="let children of items.children"                      │
│                                                               │
│  📦 Podkutija 1: "Tarifni paketi"                             │
│     → let children = { name:"Tarifnipaketi",                  │
│                         template:"basic_block",                │
│                         inputs: [...], children: [...] }       │
│     → [items]="children" → Radnik #17 prima OVU KUTIJU        │
│     → [model]="model['FlatBHTelecom']" → prima DIO modela     │
│     → Radnik #17 otvara kutiju, čita etiketu "basic_block"    │
│     → Poziva NOVOG SORTERA (BasicBlock)                        │
│     → SORTER OTVARA I PONAVLJA SVE OD POČETKA! (REKURZIJA)   │
│                                                               │
│  📦 Podkutija 2: "Preuzimanja"                                │
│     → ... isti proces ...                                     │
│                                                               │
│  📦 ... (još 7 podkutija)                                     │
└──────────────────────────────────────────────────────────────┘
```

---

#### 1.5 CHILD DIO - SUPER DETALJNO OBJAŠNJENJE

##### Šta je "child"?

**U Angular svijetu**, "child" je komponenta koja je **kreirana unutar druge komponente**.

**U ovom projektu**, "child" ima **DVA značenja:**

| Pojam | Značenje | Primjer |
|-------|----------|---------|
| **Angular child** | Komponenta kreirana u template-u druge komponente | `<z-contentloader>` unutar `<z-default-block>` |
| **items.children** | Property u JSON podacima sa backenda | `{ children: [{name:"Tarifnipaketi"}, ...] }` |

**Nemoj ih miješati!** Angular child je SVAKA komponenta kreirana u template-u. `items.children` je samo JEDAN od array-ova (pored `items.elements` i `items.inputs`).

---

##### Analogija za CHILD: Porodično stablo

```
Zamislite PORODIČNO STABLO:

👴 PRADEDA: "Flat paketi POTS" (DefaultBlock)
 │
 │  Pradeda ima JEDNO DIJETE u "elements":
 │
 ├── 👨 OTAC: "Flat BH Telecom" (BasicBlock)
 │    │
 │    │  Otac ima OSOBINE (inputs):
 │    │  📋 Ime: FIRSTNAME
 │    │  📋 Prezime: NAME
 │    │  📋 Funkcija: JOBTITLE
 │    │  📋 Email: PUSER_EMAIL
 │    │  📋 ... (još 10 osobina)
 │    │
 │    │  Otac ima VLASTITU DJECU (children):
 │    │
 │    ├── 👦 SIN 1: "Tarifni paketi" (BasicBlock)
 │    │    │  Sin ima SVOJE osobine (inputs)
 │    │    │  Sin ima SVOJU djecu (children)
 │    │    │  └── 👶 UNUK: ...
 │    │    │
 │    ├── 👦 SIN 2: "Preuzimanja" (BasicBlock)
 │    │    │  Sin ima SVOJE osobine
 │    │    │  Sin ima SVOJU djecu
 │    │    │
 │    ├── 👧 KĆERKA 3: "Zabrana info" (BasicBlock)
 │    ├── 👦 SIN 4: "POTS servis" (BasicBlock)
 │    ├── 👧 KĆERKA 5: ...
 │    └── ... (ukupno 9 djece)
 │
 └── (moguća druga djeca u elements)
```

**Poenta porodične analogije:**
- Svaka OSOBA (komponenta) ima **osobine** (inputs) i **djecu** (children)
- Svako DIJETE je opet **osoba** koja može imati **svoju djecu**
- To je **REKURZIJA** - isti obrazac se ponavlja na svakom nivou

---

##### Kako *ngFor kreira "djecu" - KORAK PO KORAK

Pratimo jedan child od nastanka do renderovanja:

**KORAK A: BasicBlock ima items.children**

```typescript
// BasicBlock ("Flat BH Telecom") ima u svom items objektu:
this.items = {
  name: "FlatBHTelecom",
  template: "basic_block",
  children: [
    //  ↓ OVO JE ARRAY SA 9 ELEMENATA
    { name: "Tarifnipaketi", label: "Tarifni paketi", template: "basic_block", inputs: [...], children: [...] },
    { name: "Preuzimanja", label: "Preuzimanja", template: "basic_block", inputs: [...] },
    { name: "Zabranainfo", label: "Zabrana info", template: "basic_block", inputs: [...] },
    // ... još 6
  ]
}
```

**KORAK B: *ngFor čita array i kreće iterirati**

```html
<!-- BasicBlock template: -->
<z-contentloader
  *ngFor="let children of items.children"
  [items]="children"
  [model]="model[items.name]"
  [parent]="model"
  ...>
</z-contentloader>
```

```
*ngFor pita: "Koliko elemenata ima items.children?"
Odgovor: 9

*ngFor kaže: "OK, napraviću 9 kopija <z-contentloader>-a"
```

**KORAK C: PRVA ITERACIJA (Tarifni paketi)**

```
*ngFor ITERACIJA 1:
═══════════════════

let children = items.children[0]
             = { name: "Tarifnipaketi", label: "Tarifni paketi", template: "basic_block", ... }
  │
  │  "children" je sad LOKALNA VARIJABLA koja pokazuje na ovaj objekat
  │
  │  Angular kreira NOVU <z-contentloader> instancu i prosljeđuje:
  │
  ├── [items]="children"
  │   │
  │   │  ŠTA CHILD PRIMA:
  │   │  @Input() items = { name: "Tarifnipaketi",
  │   │                      label: "Tarifni paketi",
  │   │                      template: "basic_block",
  │   │                      inputs: [...],
  │   │                      children: [...] }
  │   │
  │   │  VAŽNO: Child prima KOMPLETNU DEFINICIJU sebe!
  │   │  Ima svoju etiketu (template), svoje inpute, svoju djecu
  │   │
  │
  ├── [model]="model[items.name]"
  │   │
  │   │  RAŠČLANJIVANJE:
  │   │  model = db.model (cijeli model koji BasicBlock ima)
  │   │  items.name = "FlatBHTelecom" (IME PARENT-a, NE childa!)
  │   │  model[items.name] = model["FlatBHTelecom"] = { FIRSTNAME: null, NAME: null, ... }
  │   │
  │   │  ŠTA CHILD PRIMA:
  │   │  @Input() model = db.model["FlatBHTelecom"]
  │   │                 = { FIRSTNAME: null, NAME: null, JOBTITLE: null, ... }
  │   │
  │   │  ANALOGIJA: Otac daje sinu SVOJ URED (ne cijelu kuću!)
  │   │  Sin može dodavati stvari u očev ured jer je to REFERENCA
  │   │
  │
  └── [parent]="model"
      │
      │  ŠTA CHILD PRIMA:
      │  @Input() parent = db.model (CIJELI model!)
      │
      │  ANALOGIJA: Sin dobija KLJUČ OD CIJELE KUĆE (parent)
      │  ali radi primarno u OČEVOM UREDU (model)
```

**KORAK D: ŠTA RADI TAJ CHILD?**

```
NOVI ContentLoader (#17) prima:
  items = { name: "Tarifnipaketi", template: "basic_block", ... }

ContentLoader čita etiketu: items.template = "basic_block"
ContentLoader kaže: "Pozivam BasicBlock sortera!"

NOVI BasicBlock se kreira za "Tarifni paketi"
  │
  │  Ima SVOJE items.inputs → *ngFor kreira inpute za tarifne pakete
  │  Ima SVOJE items.children → *ngFor kreira DJECU tarifnih paketa
  │
  │  I PROCES SE PONAVLJA! (REKURZIJA)
  │
  └── Ako "Tarifni paketi" ima children, oni će opet imati inpute i djecu...
```

```
VIZUALNO - Rekurzija:

📦 "Flat paketi POTS" (DefaultBlock)
 │
 ├── *ngFor elements → 📦 "Flat BH Telecom" (BasicBlock)
 │                      │
 │                      ├── *ngFor inputs → 📄 FIRSTNAME (Input)
 │                      ├── *ngFor inputs → 📄 NAME (Input)
 │                      ├── *ngFor inputs → 📄 JOBTITLE (Input)
 │                      │   ... (14 inputa ukupno)
 │                      │
 │                      ├── *ngFor children → 📦 "Tarifni paketi" (BasicBlock) ← REKURZIJA!
 │                      │                     │
 │                      │                     ├── *ngFor inputs → 📄 TARIFA (Input)
 │                      │                     ├── *ngFor inputs → 📄 ...
 │                      │                     └── *ngFor children → 📦 ... ← OPET REKURZIJA!
 │                      │
 │                      ├── *ngFor children → 📦 "Preuzimanja" (BasicBlock) ← REKURZIJA!
 │                      │                     │
 │                      │                     ├── *ngFor inputs → ...
 │                      │                     └── *ngFor children → ...
 │                      │
 │                      ├── *ngFor children → 📦 "Zabrana info" (BasicBlock)
 │                      ├── *ngFor children → 📦 "POTS servis" (BasicBlock)
 │                      └── ... (9 children ukupno)
```

---

##### KLJUČNA STVAR: Ko je PARENT, a ko CHILD?

Ovo je dio koji zbunjuje. Hajde da ga raščistimo potpuno.

```
PRAVILO: PARENT je onaj čiji template SADRŽI *ngFor.
         CHILD je komponenta koju *ngFor KREIRA.
```

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  BasicBlock template (OVO JE PARENT):                        │
│  ════════════════════════════════════                         │
│                                                              │
│  this.items = { name: "FlatBHTelecom", ... }                 │
│  this.model = db.model                                       │
│                                                              │
│  <z-contentloader                                            │
│    *ngFor="let children of items.children"  ← PARENT čita   │
│    [items]="children"  ────────────────────── PARENT šalje   │
│    [model]="model[items.name]" ───────────── PARENT šalje    │
│    [parent]="model"  ─────────────────────── PARENT šalje    │
│  >                                                           │
│                                                              │
│     │         │           │                                  │
│     │ items   │ model     │ parent                           │
│     ▼         ▼           ▼                                  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐   │
│  │                                                        │   │
│  │  ContentLoader (OVO JE CHILD):                         │   │
│  │  ═════════════════════════════                         │   │
│  │                                                        │   │
│  │  @Input() items = { name:"Tarifnipaketi", ... }        │   │
│  │  @Input() model = db.model["FlatBHTelecom"]            │   │
│  │  @Input() parent = db.model                            │   │
│  │                                                        │   │
│  │  Child NE BIRA šta prima!                              │   │
│  │  Parent ODLUČUJE šta šalje!                            │   │
│  │                                                        │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Analogija - Roditelj i dijete u školi:**
```
RODITELJ (BasicBlock) pakuje RUKSAK za dijete (ContentLoader):

  📋 [items]="children"
     → Stavlja u ruksak DNEVNIK (informacije o razredu)
     → Dijete zna u koji razred ide

  📋 [model]="model[items.name]"
     → Stavlja u ruksak KLJUČ OD SVOG UREDA
     → Dijete može raditi SAMO u roditeljskom uredu
     → NE daje mu ključ cijele kuće!

  📋 [parent]="model"
     → Stavlja u ruksak KLJUČ CIJELE KUĆE (za hitne slučajeve)
     → Dijete može pristupiti svemu AKO TREBA
```

---

##### DVA TIPA SORTIRANJA: DefaultBlock vs BasicBlock

**Ovo je KRITIČNA razlika za razumijevanje child dijela:**

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  DefaultBlock prosleđuje djeci:                               ║
║  ─────────────────────────────                                ║
║  [model]="model"           ← CIJELI model (cijela kuća!)     ║
║  [parent]="parent"         ← parent od svog parent-a          ║
║                                                               ║
║  BasicBlock prosleđuje djeci:                                 ║
║  ────────────────────────────                                 ║
║  [model]="model[items.name]"  ← NESTED DIO (samo svoj ured!) ║
║  [parent]="model"             ← svoj model kao parent         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

**Zašto je ovo važno? Pogledaj STVARNI primjer:**

```typescript
// DefaultBlock ("Flat paketi POTS") ima:
this.model = db.model = {
  auto: {},
  FlatpaketiPOTS: {},
  FlatBHTelecom: {}
}

// DefaultBlock prosljeđuje "Flat BH Telecom"-u:
[model]="model"  →  child.model = db.model (CIJELA KUĆA)

// ────────────────────────────────────────────────

// BasicBlock ("Flat BH Telecom") ima:
this.model = db.model  // (primio je cijelu kuću od DefaultBlock-a)
this.items.name = "FlatBHTelecom"

// BasicBlock prosljeđuje "Tarifni paketi"-u:
[model]="model[items.name]"
       = model["FlatBHTelecom"]
       = db.model["FlatBHTelecom"]  // (SAMO JEDAN URED!)
       = { FIRSTNAME: null, NAME: null, JOBTITLE: null, ... }
```

```
VIZUALNO:

db.model (cijela kuća):
┌──────────────────────────────────────┐
│  auto: {}                             │
│  FlatpaketiPOTS: {}                   │
│  FlatBHTelecom: { ← OVO JE URED      │
│    FIRSTNAME: null,                   │
│    NAME: null,                        │
│    JOBTITLE: null,                    │
│    Tarifnipaketi: { ← SOBA U UREDU   │
│      TARIFA: null,                    │
│      ...                              │
│    },                                 │
│    Preuzimanja: { ← DRUGA SOBA       │
│      ...                              │
│    }                                  │
│  }                                    │
└──────────────────────────────────────┘

DefaultBlock kaže:
  "Sine, evo ti KLJUČ OD CIJELE KUĆE" → [model]="model"

BasicBlock kaže:
  "Sine, evo ti KLJUČ SAMO OD MOG UREDA" → [model]="model['FlatBHTelecom']"

Kad child "Tarifni paketi" piše u model:
  model["TARIFA"] = "Flat 1"
To je ZAPRAVO:
  db.model["FlatBHTelecom"]["TARIFA"] = "Flat 1"

Jer model JE REFERENCA na db.model["FlatBHTelecom"]!
```

---

##### KOMPLETNO STABLO - Od PageLoadera do zadnjeg inputa

```
PageLoader
│ items = structure.structure (array)
│ model = db.model
│
│ *ngFor="let item of items" → 1 iteracija
│ [items]="item" + [model]="model"
│
└── ContentLoader (items.template = "default_block")
    │ items = { name: "FlatpaketiPOTS" }
    │ model = db.model                        ← CIJELI MODEL
    │
    └── DefaultBlock
        │ *ngFor="let element of items.elements" → 1 iteracija
        │ [items]="element" + [model]="model"     ← ŠALJE CIJELI MODEL!
        │
        └── ContentLoader (items.template = "basic_block")
            │ items = { name: "FlatBHTelecom" }
            │ model = db.model                    ← JOŠ UVIJEK CIJELI MODEL
            │
            └── BasicBlock
                │
                │ *ngFor="let input of items.inputs" → 14 iteracija
                │ [items]="input" + [model]="model['FlatBHTelecom']"  ← DIO MODELA!
                │
                ├── ContentLoader → Input (FIRSTNAME)
                │   items = { name: "FIRSTNAME" }
                │   model = db.model["FlatBHTelecom"]     ← REFERENCA!
                │   → ValueManager.set() → model["FIRSTNAME"] = null
                │   → REZULTAT: db.model["FlatBHTelecom"]["FIRSTNAME"] = null
                │
                ├── ContentLoader → Input (NAME)
                │   items = { name: "NAME" }
                │   model = db.model["FlatBHTelecom"]     ← ISTA REFERENCA!
                │   → ValueManager.set() → model["NAME"] = null
                │   → REZULTAT: db.model["FlatBHTelecom"]["NAME"] = null
                │
                ├── ... (još 12 inputa)
                │
                │
                │ *ngFor="let children of items.children" → 9 iteracija
                │ [items]="children" + [model]="model['FlatBHTelecom']"  ← DIO MODELA!
                │
                ├── ContentLoader (items.template = "basic_block") ← REKURZIJA!
                │   │ items = { name: "Tarifnipaketi" }
                │   │ model = db.model["FlatBHTelecom"]
                │   │
                │   └── BasicBlock
                │       │
                │       │ *ngFor inputs → [model]="model['Tarifnipaketi']"
                │       │              = db.model["FlatBHTelecom"]["Tarifnipaketi"]
                │       │
                │       ├── Input (TARIFA)
                │       │   model["TARIFA"] = null
                │       │   = db.model["FlatBHTelecom"]["Tarifnipaketi"]["TARIFA"] = null
                │       │
                │       └── *ngFor children → ... (OPET REKURZIJA!)
                │
                ├── ContentLoader → BasicBlock ("Preuzimanja")
                │   └── ...
                │
                └── ... (još 7 children)
```

---

#### 1.6 MEMORIJSKI TRIKOVI - Kako zapamtiti

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  TRIK 1: *ngFor = FOTOKOPIR MAŠINA                           ║
║  ───────────────────────────────────                          ║
║    Imate 1 original (HTML šablon)                             ║
║    Imate 5 stranica za kopirati (array sa 5 elemenata)        ║
║    Fotokopir pravi 5 kopija, svaku sa drugačijim sadržajem    ║
║                                                               ║
║  TRIK 2: "let X of Y" = "UZMI X IZ Y"                        ║
║  ──────────────────────────────────────                        ║
║    let input of items.inputs                                  ║
║    "Uzmi input iz items.inputs"                               ║
║    "Uzmi jednu stvar iz kutije"                               ║
║                                                               ║
║  TRIK 3: [items]="nešto" = "STAVI U RUKSAK"                  ║
║  ────────────────────────────────────────────                  ║
║    Parent PAKUJE ruksak za child-a                             ║
║    Child otvara ruksak i koristi sadržaj                       ║
║                                                               ║
║  TRIK 4: RAZLIKA DefaultBlock vs BasicBlock                   ║
║  ───────────────────────────────────────────                   ║
║    Default = "Evo ti cijela kuća" (model)                     ║
║    Basic = "Evo ti samo tvoja soba" (model[items.name])       ║
║                                                               ║
║  TRIK 5: CHILD = nova instanca ISTE komponente                ║
║  ─────────────────────────────────────────────                 ║
║    Parent ContentLoader kreira child ContentLoader             ║
║    Child ContentLoader kreira SVOG child ContentLoader         ║
║    = REKURZIJA (Matrjoška lutke)                               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

### DIO 2: Dinamičko kreiranje komponenti (items.template → Component)

---

#### 2.1 SISTEM SA 3 DIJELA

Zamislite **biblioteku** sa **katalogom**:

```
📚 BIBLIOTEKA KOMPONENTI (dynamic.module.ts)
   │
   │  Na polici u biblioteci stoje FIZIČKE knjige (komponente):
   │
   ├── 📕 Knjiga #0: BasicBlockComponent
   ├── 📘 Knjiga #1: DefaultBlockComponent
   ├── 📙 Knjiga #2: CheckBlockComponent
   ├── 📗 Knjiga #3: StandardPopupComponent
   ├── 📓 Knjiga #4: SwitchTabComponent
   ├── 📔 Knjiga #5: FormComponent
   ├── 📕 Knjiga #6: ButtonComponent
   ├── 📘 Knjiga #7: CheckboxComponent
   ├── 📙 Knjiga #8: InputComponent
   ├── 📗 Knjiga #9: PopupButtonComponent
   └── ... (ukupno 27 komponenti)


🗂️ KATALOG (dlcontent.ts - konstanta "key")
   │
   │  Katalog prevodi IME KNJIGE u BROJ POLICE:
   │
   ├── "basic_block" → Polica #0
   ├── "default_block" → Polica #1
   ├── "checkblock" → Polica #2
   ├── "standard_popup" → Polica #3
   ├── "switchtab" → Polica #4
   ├── "form" → Polica #5
   ├── "button" → Polica #6
   ├── "checkbox" → Polica #7
   ├── "input" → Polica #8
   ├── "number" → Polica #8  ← ISTA POLICA kao "input"!
   ├── "readonly" → Polica #8  ← ISTA POLICA kao "input"!
   ├── "popbutton" → Polica #9
   └── ... (ukupno 27 mapiranja)


👨‍💼 BIBLIOTEKAR (DLContent komponenta)
   │
   │  Bibliotekar:
   │  1. Prima NALOG (items.template = "basic_block")
   │  2. Gleda u KATALOG (key["basic_block"] = 0)
   │  3. Uzima knjigu sa POLICE #0 (Components[0] = BasicBlockComponent)
   │  4. KREIRA KOPIJU knjige za tebe (createComponent)
   │  5. UPISUJE tvoje podatke u kopiju (Object.assign)
```

---

#### 2.2 STVARNI KOD - Korak po korak

##### KORAK 1: Biblioteka komponenti se kreira

**File:** `dynamic.module.ts` (linija 72-101)

```typescript
export const Components = [
  BasicBlockComponent,        // Index 0
  DefaultBlockComponent,      // Index 1
  CheckBlockComponent,        // Index 2
  StandardPopupComponent,     // Index 3
  SwitchTabComponent,         // Index 4
  FormComponent,              // Index 5
  ButtonComponent,            // Index 6
  CheckboxComponent,          // Index 7
  InputComponent,             // Index 8
  PopupButtonComponent,       // Index 9
  RadioComponent,             // Index 10
  SelectComponent,            // Index 11
  TextareaComponent,          // Index 12
  DateComponent,              // Index 13
  DynamicTableComponent,      // Index 14
  AgGridComponent,            // Index 15
  DynamicTableRowComponent,   // Index 16
  PriceBlockComponent,        // Index 17
  NavigatorComponent,         // Index 18
  MultipleSwitchTabComponent, // Index 19
  NotificationComponent,      // Index 20
  InOutComponent,             // Index 21
  CheckboxADComponent,        // Index 22
  TabViewComponent,           // Index 23
  PageTabComponent,           // Index 24
  AutoCompleteComponent,      // Index 25
  BoxOptionsComponent,        // Index 26
  NavigatorComponentMojIzborComponent  // Index 27
];
```

**Šta se ovdje dešava:**

```
Components je ARRAY sa KLASAMA (ne instance, nego definicije!)

Components[0] = BasicBlockComponent
Components[1] = DefaultBlockComponent
Components[8] = InputComponent
...

To je kao KATALOG sa RECEPTIMA:
  - Index 0 = Recept za pravljenje BasicBlock torte
  - Index 1 = Recept za pravljenje DefaultBlock torte
  - Index 8 = Recept za pravljenje Input torte
```

---

##### KORAK 2: Katalog (mapa) se kreira

**File:** `dlcontent.ts` (linija 16-47)

```typescript
export const key = {
    basic_block: 0,          // "basic_block" → Components[0]
    default_block: 1,        // "default_block" → Components[1]
    checkblock: 2,           // "checkblock" → Components[2]
    standard_popup: 3,       // itd...
    switchtab: 4,
    form: 5,
    button: 6,
    checkbox: 7,
    input: 8,                // "input" → Components[8]
    number: 8,               // "number" → Components[8] (ISTI kao input!)
    readonly: 8,             // "readonly" → Components[8] (ISTI kao input!)
    popbutton: 9,
    radio: 10,
    select: 11,
    textarea: 12,
    date: 13,
    tableview: 14,
    grid: 15,
    tablerow: 16,
    PriceBlock: 17,
    navigator: 18,
    MultipleSwitchTab: 19,
    Notification: 20,
    InOut: 21,
    CheckboxAD: 22,
    TabView: 23,
    PageTab: 24,
    AutoComplete: 25,
    BoxOptions: 26,
    navigatormojizbor: 27
};
```

**Šta je "key" objekat?**

```
key je MAPA koja prevodi STRING u NUMBER:

  key["basic_block"] = 0
  key["default_block"] = 1
  key["input"] = 8
  key["number"] = 8  ← ISTI broj!
  key["readonly"] = 8  ← ISTI broj!

Zašto "input", "number", i "readonly" imaju ISTI broj?
  Jer sve TRI koriste InputComponent!
  To je kao 3 različita imena za istu knjigu:
    - "Harry Potter" (input)
    - "HP1" (number)
    - "The Boy Who Lived" (readonly)
  Sve pokazuju na ISTU knjigu na polici #8!
```

**Analogija - Telefonski imenik:**

```
┌─────────────────────────────────┐
│  IMENIK (key objekat)            │
├─────────────────────────────────┤
│  Pekara "Kod Marka"  → 061-123  │ ← key["basic_block"] = 0
│  Mesara "Zlatni Rezač" → 061-456│ ← key["default_block"] = 1
│  Pizza "Napoli"      → 061-789  │ ← key["input"] = 8
│  Pizza "Napoli Nord" → 061-789  │ ← key["number"] = 8 (isti broj!)
│  Pizza "Napoli Jug"  → 061-789  │ ← key["readonly"] = 8 (isti broj!)
└─────────────────────────────────┘

Zoveš različito ime, dobiješ ISTI broj, dođeš na ISTO mjesto!
```

---

##### KORAK 3: Bibliotekar prima nalog

**File:** `contentloader.template.html`

```html
<span *ngIf="items.active">
  <z-dlcontent
    [template]="items.template"   ← NALOG: "basic_block"
    [inputs]="{
      items: items,
      model: model,
      ...
    }">
  </z-dlcontent>
</span>
```

**Šta se dešava:**

```
ContentLoader renderuje template:

  <z-dlcontent
    [template]="items.template"
    [inputs]="{ ... }">
  </z-dlcontent>


Ako je items.template = "basic_block", Angular prosleđuje:

  @Input() template = "basic_block"  ← STRING!
  @Input() inputs = { items: {...}, model: {...}, ... }
```

```
ANALOGIJA:

Dolazite u biblioteku i dajete NALOG bibliotekaru:

  Kupac (ContentLoader): "Molim vas, treba mi knjiga 'basic_block'"
  Bibliotekar (DLContent): "U redu, potražiću u katalogu..."
```

---

##### KORAK 4: Bibliotekar traži u katalogu i uzima knjigu

**File:** `dlcontent.ts` (linija 65-74)

```typescript
updateComponent() {
    if (!this.isViewInitialized) { return; }
    if (this.cmpRef) { this.cmpRef.destroy(); }

    // LINIJA 69: KLJUČNA LINIJA!
    let component: any = Components[key[this.template]];
    //                   │         │   └── this.template = "basic_block"
    //                   │         └────── key["basic_block"] = 0
    //                   └──────────────── Components[0] = BasicBlockComponent

    // component = BasicBlockComponent (KLASA, ne instanca!)

    let factory = this.cfResolver.resolveComponentFactory(component);
    // factory = "recept" kako napraviti BasicBlockComponent

    this.cmpRef = this.target.createComponent(factory)
    // KREIRA NOVU INSTANCU BasicBlockComponent-a!

    Object.assign(this.cmpRef.instance, this.inputs)
    // PROSLJEĐUJE SVE inputs (items, model, parent...) novoj instanci

    this.cdRef.detectChanges();
    // Kaže Angularu: "Ažuriraj view!"
}
```

---

#### 2.3 RAŠČLANJIVANJE LINIJE 69 - KORAK PO KORAK

Ovo je **KLJUČNA LINIJA** gdje se dešava mapiranje:

```typescript
let component: any = Components[key[this.template]];
```

Hajde da je razložimo **IZNUTRA KA SPOLJA**:

##### KORAK A: Prvo se izvršava `this.template`

```typescript
this.template = "basic_block"  // STRING koji je prosleđen iz ContentLoader-a
```

```
Bibliotekar gleda u NALOG:
  "Kupac traži knjigu sa nazivom 'basic_block'"
```

---

##### KORAK B: Zatim se izvršava `key[this.template]`

```typescript
key[this.template]
= key["basic_block"]   // Pristup property-ju objekta "key"
= 0                    // Vrijednost koja se nalazi u key objektu
```

**Kako radi pristup objektu?**

```typescript
// key je objekat:
const key = {
    basic_block: 0,
    default_block: 1,
    input: 8,
    // ...
};

// Pristup property-ju:
key["basic_block"]  // Vraća: 0
key.basic_block     // Isto kao gore (alternativna sintaksa)

// Varijabilni pristup:
let template = "basic_block";
key[template]       // Vraća: 0 (koristi vrijednost varijable)
```

```
Bibliotekar gleda u KATALOG:
  "U katalogu piše: 'basic_block' se nalazi na polici #0"
```

---

##### KORAK C: Na kraju se izvršava `Components[...]`

```typescript
Components[key[this.template]]
= Components[0]                  // Pristup array-u na indexu 0
= BasicBlockComponent            // Klasa koja se nalazi na indexu 0
```

**Kako radi pristup array-u?**

```typescript
// Components je array:
const Components = [
    BasicBlockComponent,        // index 0
    DefaultBlockComponent,      // index 1
    CheckBlockComponent,        // index 2
    // ...
];

// Pristup elementu:
Components[0]  // Vraća: BasicBlockComponent
Components[1]  // Vraća: DefaultBlockComponent

// Varijabilni pristup:
let index = 0;
Components[index]  // Vraća: BasicBlockComponent (koristi vrijednost varijable)
```

```
Bibliotekar ide do POLICE #0 i uzima KNJIGU:
  "Na polici #0 se nalazi knjiga 'BasicBlockComponent'"
```

---

##### REZULTAT:

```typescript
let component = BasicBlockComponent;  // Sada "component" varijabla pokazuje na KLASU
```

```
Bibliotekar drži knjigu u rukama:
  "Imam recept kako napraviti BasicBlock"
```

---

#### 2.4 KONKRETNI PRIMJERI - Različiti template stringovi

```typescript
// PRIMJER 1: items.template = "basic_block"
this.template = "basic_block"
key[this.template] = key["basic_block"] = 0
Components[0] = BasicBlockComponent
→ KREIRA BasicBlockComponent

// PRIMJER 2: items.template = "default_block"
this.template = "default_block"
key[this.template] = key["default_block"] = 1
Components[1] = DefaultBlockComponent
→ KREIRA DefaultBlockComponent

// PRIMJER 3: items.template = "input"
this.template = "input"
key[this.template] = key["input"] = 8
Components[8] = InputComponent
→ KREIRA InputComponent

// PRIMJER 4: items.template = "number"
this.template = "number"
key[this.template] = key["number"] = 8  ← ISTI INDEX kao "input"!
Components[8] = InputComponent
→ KREIRA InputComponent (ISTU kao za "input"!)

// PRIMJER 5: items.template = "readonly"
this.template = "readonly"
key[this.template] = key["readonly"] = 8  ← ISTI INDEX!
Components[8] = InputComponent
→ KREIRA InputComponent (OPET ISTU!)
```

---

#### 2.5 ANALOGIJA - Kompletna priča

```
🏢 FIRMA "DYNAMIC COMPONENTS DOO"
───────────────────────────────────

📋 NARUDŽBENICA od kupca (ContentLoader):
   "Potrebna mi je komponenta tipa: 'basic_block'"
   ↓
   [template]="items.template"  → template = "basic_block"

👨‍💼 NARUDŽBE (DLContent - updateComponent):
   Prima narudžbenicu i kreće u proces...

📚 KORAK 1: Pogledaj u KATALOG (key objekat)
   "basic_block" se mapira na kod: 0
   key["basic_block"] = 0

📦 KORAK 2: Idi u MAGACIN (Components array)
   Uzmi proizvod sa šifrom 0
   Components[0] = BasicBlockComponent

🏭 KORAK 3: Pošalji u PROIZVODNJU (ComponentFactoryResolver)
   factory = this.cfResolver.resolveComponentFactory(BasicBlockComponent)
   "Napravi novu instancu prema ovom receptu"

📦 KORAK 4: KREIRAJ PROIZVOD (createComponent)
   this.cmpRef = this.target.createComponent(factory)
   Nova instanca BasicBlockComponent-a je kreirana!

✍️ KORAK 5: PERSONALIZUJ PROIZVOD (Object.assign)
   Object.assign(this.cmpRef.instance, this.inputs)
   Upiši podatke kupca: items, model, parent, vparent...

✅ KORAK 6: ISPORUČI KUPCU (detectChanges)
   this.cdRef.detectChanges()
   "Proizvod je spreman! Prikaži ga u UI-ju"
```

---

#### 2.6 ZAŠTO DVA NIVOA? (key objekat + Components array)

Možda se pitaš: **Zašto ne direktno mapirati?**

```typescript
// OPCIJA 1 (trenutna implementacija):
const key = { basic_block: 0 };
const Components = [BasicBlockComponent];
let component = Components[key["basic_block"]];

// OPCIJA 2 (teoretska alternativa):
const ComponentsMap = {
  basic_block: BasicBlockComponent
};
let component = ComponentsMap["basic_block"];
```

**Odgovor: Legacy kod + fleksibilnost**

```
RAZLOG 1: Legacy
  Backend šalje template stringove: "basic_block", "default_block"...
  Ali Angular treba ARRAY za entryComponents (stara verzija Angulara)
  key objekat je MOST između backend konvencije i Angular potreba

RAZLOG 2: Više stringova → ista komponenta
  "input", "number", "readonly" → svi koriste InputComponent
  key["input"] = 8
  key["number"] = 8
  key["readonly"] = 8
  Components[8] = InputComponent
  Lakše održavati jedan mapiranje nego duplirati logiku

RAZLOG 3: Mogućnost override-a
  Možeš lako promijeniti mapiranje:
  key["basic_block"] = 10  (koristi novu komponentu)
  Ne moraš dirati Components array
```

---

#### 2.7 ŠTA SE DEŠAVA NAKON KREIRANJA? (Object.assign)

```typescript
Object.assign(this.cmpRef.instance, this.inputs)
```

**Šta je `this.inputs`?**

```typescript
// U contentloader.template.html:
[inputs]="{
  items: items,           // items objekat iz ContentLoader-a
  model: model,           // model objekat
  parent: parent,         // parent objekat
  pname: pname,           // pname string
  vparent: vparent,       // vparent objekat
  valid: valid[index] || valid,
  parameters: items.parameters,
  output: output[index] || output[items.name] || output
}"

// DLContent prima:
@Input() inputs = {
  items: { name: "FlatBHTelecom", template: "basic_block", ... },
  model: db.model,
  parent: undefined,
  pname: undefined,
  vparent: db.valid,
  valid: db.valid.children,
  parameters: undefined,
  output: db.output
};
```

**Šta radi `Object.assign`?**

```typescript
// this.cmpRef.instance = nova instanca BasicBlockComponent-a

Object.assign(this.cmpRef.instance, this.inputs)

// JE ISTO KAO:
this.cmpRef.instance.items = this.inputs.items;
this.cmpRef.instance.model = this.inputs.model;
this.cmpRef.instance.parent = this.inputs.parent;
this.cmpRef.instance.pname = this.inputs.pname;
this.cmpRef.instance.vparent = this.inputs.vparent;
this.cmpRef.instance.valid = this.inputs.valid;
this.cmpRef.instance.parameters = this.inputs.parameters;
this.cmpRef.instance.output = this.inputs.output;
```

**Analogija - Popunjavanje formulara:**

```
Imate PRAZAN FORMULAR (nova instanca BasicBlockComponent):

┌─────────────────────────┐
│  BasicBlock              │
├─────────────────────────┤
│  items: [ ]              │ ← Prazno polje
│  model: [ ]              │ ← Prazno polje
│  parent: [ ]             │ ← Prazno polje
│  vparent: [ ]            │ ← Prazno polje
│  ...                     │
└─────────────────────────┘

Object.assign POPUNJAVA FORMULAR:

┌─────────────────────────┐
│  BasicBlock              │
├─────────────────────────┤
│  items: {name:"FlatBH"}  │ ← Popunjeno!
│  model: db.model         │ ← Popunjeno!
│  parent: undefined       │ ← Popunjeno!
│  vparent: db.valid       │ ← Popunjeno!
│  ...                     │
└─────────────────────────┘
```

---

#### 2.8 KOMPLETNA PRIČA - Od backend-a do renderovanja

```
BACKEND šalje JSON:
══════════════════
{
  "name": "FlatBHTelecom",
  "template": "basic_block",  ← STRING!
  "inputs": [...]
}

↓

CONTENTLOADER prima items:
══════════════════════════
this.items = { template: "basic_block", ... }

↓

CONTENTLOADER renderuje <z-dlcontent>:
═══════════════════════════════════════
<z-dlcontent
  [template]="items.template"   ← "basic_block"
  [inputs]="{ items, model, ... }">
</z-dlcontent>

↓

DLCONTENT prima @Input():
═════════════════════════
@Input() template = "basic_block"
@Input() inputs = { items: {...}, model: {...} }

↓

DLCONTENT.updateComponent() SE IZVRŠAVA:
════════════════════════════════════════
1. key["basic_block"] = 0
2. Components[0] = BasicBlockComponent
3. factory = cfResolver.resolveComponentFactory(BasicBlockComponent)
4. cmpRef = target.createComponent(factory)  ← NOVA INSTANCA!
5. Object.assign(cmpRef.instance, inputs)   ← POPUNJAVANJE!
6. cdRef.detectChanges()                     ← RENDEROVANJE!

↓

BASICBLOCK SE RENDERUJE:
════════════════════════
<div class="z-basic-block">
  <z-contentloader *ngFor="let input of items.inputs" ...>
  <z-contentloader *ngFor="let children of items.children" ...>
</div>

↓

*ngFor KREIRA NOVE <z-contentloader> INSTANCE:
══════════════════════════════════════════════
Za svaki input/child, proces se PONAVLJA!
```

---

### 📦 FINALNI REZIME - Sve na jednom mjestu

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  ŠTA SMO NAUČILI:                                             ║
║  ═══════════════                                              ║
║                                                               ║
║  1️⃣ *ngFor = FOTOKOPIR MAŠINA                                ║
║     Za SVAKI element u array-u, kreira KOPIJU HTML elementa   ║
║                                                               ║
║  2️⃣ let item of items                                         ║
║     "item" = lokalna varijabla za trenutni element            ║
║     "items" = @Input() array iz parent komponente             ║
║                                                               ║
║  3️⃣ [items]="item" = PROPERTY BINDING                         ║
║     Parent prosljeđuje podatke child-u                         ║
║                                                               ║
║  4️⃣ REKURZIJA                                                 ║
║     ContentLoader poziva ContentLoader koji poziva...          ║
║     = Stablo komponenti proizoljne dubine                     ║
║                                                               ║
║  5️⃣ items.template = "basic_block"                            ║
║     → key["basic_block"] = 0                                  ║
║     → Components[0] = BasicBlockComponent                     ║
║     → createComponent(BasicBlockComponent)                    ║
║     = NOVA INSTANCA komponente!                               ║
║                                                               ║
║  6️⃣ Object.assign(instance, inputs)                           ║
║     Prosljeđuje sve @Input() podatke novoj instanci           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

**Sada kada razumiješ Angular Data Binding, *ngFor, i dinamičko kreiranje komponenti,
  spreman si za DETALJNE KORAKE gdje ćeš vidjeti SVE OVO U AKCIJI!** 🎯🚀

---

### DETALJNI KORACI

#### KORAK 5.1: PageLoader renderuje template

**File:** `pageloader.component.ts`
- Selector: `z-pageloader`
- Template: `pageloader.template.html`

**PageLoader prima inputs:**

```typescript
@Input() items: InputObject;        // = structure.structure (array)
@Input() model: object;             // = db.model (REFERENCA!)
@Input() output?: DynamicOutput;    // = db.output
@Input() vparent?: InputValid;      // = db.valid
@Input() valid?: InputValid;        // = db.valid.children
@Input() parameters?: object;       // = db.params
```

**Template:** `pageloader.template.html`

```html
<z-contentloader
  *ngFor="let item of items"
  [items]="item"
  [vparent]="vparent"
  [valid]="valid"
  [model]="model"           <!-- REFERENCA na db.model! -->
  [parent]="parent"
  [parameters]="parameters"
  [output]="output">
</z-contentloader>
```

**VAŽNA NAPOMENA - Zašto `structure.structure`?**

Možda si primjetio u template-u (linija 4480):
```html
[items]="structure.structure"  <!-- Zašto dva puta "structure"? -->
```

Ovo je **zbunjujuće imenovanje**, ali evo zašto:

1. **`structure`** (prva instanca) = **cijeli response objekat** sa backenda:
   ```typescript
   // U evidencija-usluge.component.ts
   this.http.post('/pcrt/order-entry', {...})
     .subscribe(response => {
       this.structure = response;  // ← Cijeli response objekat
     });
   ```

2. **`.structure`** (druga instanca) = **property unutar response objekta** (array komponenti):
   ```json
   // Backend response:
   {
     "structure": [           // ← Property imena "structure"
       {
         "label": "Flat paketi POTS",
         "name": "FlatpaketiPOTS",
         "template": "default_block",
         "elements": [...]
       }
     ]
   }
   ```

**Dakle:**
- `structure` (varijabla) = `{ structure: [...] }` (cijeli response)
- `structure.structure` (property) = `[{...}, {...}]` (array komponenti)

**Bolje bi bilo:**
```typescript
// Umjesto:
[items]="structure.structure"

// Jasnije bi bilo:
this.components = response.structure;  // Izvuci array
[items]="components"  // Koristi array direktno
```

Ali postojeći kod koristi `structure.structure` zbog legacy imenovanja. 😅

---

**Šta se dešava:**

1. **PageLoader** iteruje kroz `items` sa `*ngFor`
2. `items` = `structure.structure` = array sa 1 elementom (index 0):

```typescript
items[0] = {
  label: "Flat paketi POTS",    // ← STVARNI podatak
  name: "FlatpaketiPOTS",
  code: "979",
  template: "default_block",
  elements: [ {...} ]
}
```

3. Za **prvi (i jedini) element**, Angular kreira `<z-contentloader>` sa:

```typescript
// ContentLoader prima:
items = structure.structure[0]  // "Flat paketi POTS"
model = db.model               // { auto: {} }  ← REFERENCA!
output = db.output
vparent = db.valid
valid = db.valid.children
parameters = db.params
parent = undefined
```

---

#### KORAK 5.2: ContentLoader.ngOnInit() - "Flat paketi POTS"

**File:** `contentloader.component.ts` (linija 26-54)

**ContentLoader component:**
- Selector: `z-contentloader`
- Extends: `PageLoaderComponent`
- Template: `contentloader.template.html`

**ngOnInit() izvršavanje - STVARNI console.log output:**

```typescript
ngOnInit() {
  // Linija 27: Validacija (validFrom/validTo)
  if (this.db.mod != 'preview' && !this.isValid()) return;

  /////////////////////  Ne diraj redoslijed izvrsavanja  /////////////////////

  // Linija 30-33: Console logging - STVARNI output:
  console.log('--- ContentLoader ngOnInit ---');
  console.log('items.name:', this.items.name);           // "FlatpaketiPOTS"
  console.log('items.template:', this.items.template);   // "default_block"
  console.log('items.code:', this.items.code);           // "979"

  // Linija 35: Postavlja active flag
  this.items.active = this.items.active != undefined ? this.items.active : true;
  this.db.set(this.model, this.parent, this.pname);

  // Linija 36: Postavlja initActivity
  if (this.items.initActivity == undefined) {
    this.items.initActivity = this.items.active ? true : false;
  }

  // Linija 38: Postavlja parametre i dependency
  this.items.set || this.setParametars();
  this.Depedency.set(this.items, this.model);
  this.ValueManager.setDP(this.Depedency);

  // Linija 40-42: Poziva ValueManager.set() - STVARNI console.log output:
  console.log('model PRIJE ValueManager.set():', JSON.stringify(this.model));
  // Output: {"auto":{}}

  // VAŽNO: Poziva se ValueManager.set() SAMO AKO template NIJE 'Inputoutput'
  this.items.template == 'Inputoutput' || this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);
  //  ↑ Za "default_block" template, ValueManager.set() postavlja property na null

  console.log('model NAKON ValueManager.set():', JSON.stringify(this.model));
  // Output: {"auto":{},"FlatpaketiPOTS":null}  ← Dodao property sa null vrijednošću!

  // Linija 44-48: Postavlja output
  this.getIndexName();  // this.index = this.items.name = "FlatpaketiPOTS"
  console.log('index za output:', this.index);  // "FlatpaketiPOTS"

  console.log('PRIJE setoutput - output:', this.output);
  this.db.setoutput(this.items, this.model, this.output, this.index);
  // ↑ Kreira output["FlatpaketiPOTS"] = { active: true, value: {...} }
  console.log('NAKON setoutput - output[index]:', this.output[this.index]);

  // Linija 51: Postavlja validaciju
  this.Validation.set(this.items, this.valid, this.vparent, this.index, this.db.mod);

  /////////////////////  Ne diraj redoslijed izvrsavanja  /////////////////////
}
```

---

### DETALJNO OBJAŠNJENJE SVAKE LINIJE U ngOnInit()

#### **Linija 27: Validacija (validFrom/validTo)**

```typescript
if (this.db.mod != 'preview' && !this.isValid()) return;
```

**Šta radi:**
- Provjerava da li je komponenta **validna po datumu** (validFrom/validTo)
- Ako mod **nije** 'preview' I komponenta **nije validna**, prekida izvršavanje

**isValid() metoda:**
```typescript
isValid(): boolean {
  const now = new Date();
  const validFrom = this.items.validFrom ? new Date(this.items.validFrom) : null;
  const validTo = this.items.validTo ? new Date(this.items.validTo) : null;

  // Ako nema validFrom i validTo, komponenta je validna
  if (!validFrom && !validTo) return true;

  // Provjerava da li je trenutni datum između validFrom i validTo
  if (validFrom && now < validFrom) return false;  // Prerano
  if (validTo && now > validTo) return false;      // Prekasno

  return true;  // Datum je OK
}
```

**Primjer:**
```typescript
// Komponenta je dostupna samo do 31.12.2024:
items = {
  name: "FlatpaketiPOTS",
  validTo: "2024-12-31T23:59:59"
}

// Ako je današnji datum 15.01.2025:
isValid() → false  // Komponenta nije više validna!
ngOnInit() → return  // Prekida izvršavanje, komponenta se NE renderuje
```

**Zašto je ovo važno:**
- Backend može poslati komponente koje su **vremenski ograničene** (npr. sezonske ponude)
- Ova provjera osigurava da se **stare ponude ne prikazuju** nakon isteka roka

---

#### **Linija 35: Postavlja active flag**

```typescript
this.items.active = this.items.active != undefined ? this.items.active : true;
```

**Šta radi:**
- Postavlja `items.active` na `true` ako nije već postavljen

**Logika:**
```typescript
// Ako items.active JE definisan (true ili false):
if (this.items.active != undefined) {
  this.items.active = this.items.active;  // Zadrži postojeću vrijednost
}
// Ako items.active NIJE definisan (undefined):
else {
  this.items.active = true;  // Postavi na true (default)
}
```

**Primjeri:**
```typescript
// Primjer 1: Backend je poslao active = false
items = { name: "FlatpaketiPOTS", active: false }
items.active = false  // Zadrži false

// Primjer 2: Backend nije poslao active
items = { name: "FlatpaketiPOTS" }
items.active = true  // Postavi na true (default)

// Primjer 3: Backend je poslao active = true
items = { name: "FlatpaketiPOTS", active: true }
items.active = true  // Zadrži true
```

**Zašto je ovo važno:**
- `items.active` se koristi u template-u: `<span *ngIf="items.active">`
- Ako je `active = false`, komponenta se **NE renderuje**
- Default je `true` jer većina komponenti treba biti aktivna

**Koja komponenta se konkretno NE renderuje?**

Kada je `items.active = false`, **NE renderuje se `<z-dlcontent>` komponenta** u `contentloader.template.html`:

```html
<span *ngIf="items.active" class="...">
  <z-dlcontent                          ← OVO SE NE RENDERUJE!
    [template]="items.template"
    [inputs]="{...}">
  </z-dlcontent>
</span>
```

Pošto se `<z-dlcontent>` ne renderuje, **NE kreira se finalna komponenta** prema `items.template`:

| items.template | Komponenta koja se NE kreira |
|----------------|------------------------------|
| `"default_block"` | DefaultBlockComponent |
| `"basic_block"` | BasicBlockComponent |
| `"input"` | InputComponent |
| `"select"` | SelectComponent |
| `"checkbox"` | CheckboxComponent |
| `"textarea"` | TextareaComponent |

**Konkretni primjeri sa stvarnim komponentama:**

**Primjer 1: FlatpaketiPOTS sa active = false**
```typescript
// Backend vraća:
{
  "label": "Flat paketi POTS",
  "name": "FlatpaketiPOTS",
  "active": false,              // ← Backend postavio na false!
  "template": "default_block",
  "elements": [...]
}
```

**Rezultat:**
```
ContentLoader → items.active = false
                     ↓
Template: <span *ngIf="items.active"> → FALSE
                     ↓
<z-dlcontent> se NE RENDERUJE
                     ↓
DLContent NE kreira DefaultBlockComponent
                     ↓
❌ DefaultBlock "Flat paketi POTS" se NE PRIKAZUJE!
❌ Sve child komponente se također NE prikazuju:
   - BasicBlock "Flat BH Telecom"
   - Svi inputi (FIRSTNAME, NAME, JOBTITLE, ...)
   - Svi children (Tarifnipaketi, Preuzimanja, ...)
```

**Korisnik vidi:** (PRAZAN EKRAN - kao da komponenta ne postoji)

**Primjer 2: Pojedinačni input sa active = false**
```typescript
// Backend vraća:
{
  "label": "Trenutni email",
  "name": "PUSER_EMAIL",
  "active": false,              // ← Backend postavio na false!
  "template": "input"
}
```

**Rezultat:**
```
❌ Input polje "Trenutni email" se NE PRIKAZUJE!
```

**Razlika: active vs visible**

| Property | Ponašanje | DOM | Korištenje |
|----------|-----------|-----|------------|
| `active = false` | NE RENDERUJE SE | Element **NE postoji** u DOM-u | Trajno sakrivene komponente |
| `visible = false` | RENDERUJE SE, ali sakriven | Element **postoji** u DOM-u (sakriven sa CSS) | Dinamičko show/hide (dependency) |

```html
<!-- active = false: -->
<span *ngIf="items.active">           <!-- Angular NE KREIRA DOM element -->
  <z-dlcontent>...</z-dlcontent>
</span>

<!-- visible = false: -->
<div [ngClass]="{hidden: !items.visible}">  <!-- Angular KREIRA DOM, ali ga sakriva -->
  <input [(ngModel)]="model[items.name]">
</div>
```

**Kada backend postavlja active = false?**

1. **Privremeno isključene opcije:**
   ```typescript
   { name: "SpecijalnaPromocija", active: false }  // Ponuda privremeno nedostupna
   ```

2. **Opcije specifične za tip korisnika:**
   ```typescript
   { name: "PoslovniPaket", active: customerType === 'BUSINESS' }  // Samo za business
   ```

3. **Opcije sa geografskim uslovima:**
   ```typescript
   { name: "FiberOptika", active: region === 'Sarajevo' }  // Samo u Sarajevu
   ```

4. **A/B testiranje:**
   ```typescript
   { name: "NoviPaket", active: Math.random() > 0.5 }  // 50% korisnika
   ```

---

#### **Linija 35 (nastavak): db.set()**

```typescript
this.db.set(this.model, this.parent, this.pname);
```

**Šta radi:**
- Postavlja **globalne reference** u Model servisu

**db.set() metoda (iz model.service.ts):**
```typescript
set(model: object, parent: object, pname: string) {
  this.currentModel = model;      // Trenutni model (može biti nested)
  this.parentModel = parent;      // Parent model (cijeli db.model)
  this.parentName = pname;        // Parent name (ime parent komponente)
}
```

**Zašto je ovo važno:**
- Dependency mehanizam treba **pristup trenutnom modelu**
- ValueManager treba znati **koji je parent model**
- Ovo omogućava da se **dinamički prati kontekst** komponente

**Primjer:**
```typescript
// Za DefaultBlock "FlatpaketiPOTS":
this.db.set(
  db.model,      // model = { auto: {} }
  undefined,     // parent = undefined (nema parent-a)
  undefined      // pname = undefined
);

// Za BasicBlock "FlatBHTelecom" (child od DefaultBlock):
this.db.set(
  db.model,                    // model = cijeli db.model
  db.model["FlatpaketiPOTS"],  // parent = nested model
  "FlatpaketiPOTS"             // pname = ime parent-a
);

// Za input "FIRSTNAME" (child od BasicBlock):
this.db.set(
  db.model["FlatBHTelecom"],   // model = nested model (samo FlatBHTelecom dio)
  db.model,                    // parent = cijeli db.model
  "FlatBHTelecom"              // pname = ime parent-a
);
```

---

#### **Linija 36: Postavlja initActivity**

```typescript
if (this.items.initActivity == undefined) {
  this.items.initActivity = this.items.active ? true : false;
}
```

**Šta radi:**
- Postavlja **početni active state** komponente
- Ovo se koristi za **tracking da li je komponenta bila aktivna na startu**

**Logika:**
```typescript
// Ako initActivity nije postavljen:
if (this.items.initActivity == undefined) {
  // Postavi initActivity = trenutni active state
  this.items.initActivity = this.items.active;
}
// Ako je initActivity već postavljen, NE MIJENJAJ GA!
```

**Zašto je ovo važno:**
- **Dependency mehanizam** može **dinamički mijenjati** `items.active`
- `initActivity` pamti **originalni state** prije dependency promjena
- Ovo omogućava **reset na početno stanje**

**Primjer:**
```typescript
// Inicijalno:
items.active = true
items.initActivity = true  // Pamti originalni state

// Dependency mijenja active:
items.active = false  // Sakrio se zbog dependency

// Reset na početno stanje:
items.active = items.initActivity  // → true (vrati na original)
```

---

#### **Linija 38: setParametars()**

```typescript
this.items.set || this.setParametars();
```

**Logika sa short-circuit evaluacijom:**
```typescript
// Ovo je ekvivalent:
if (!this.items.set) {
  this.setParametars();
}
```

**Šta radi:**
- **Ako** `items.set` je `false` ili `undefined`, poziva `setParametars()`
- **Ako** `items.set` je `true`, **preskače** `setParametars()`

**setParametars() metoda:**
```typescript
setParametars() {
  // Postavlja parametre iz parent komponente
  if (this.parameters) {
    this.items.parameters = Object.assign(
      {},
      this.parameters,              // Parent parametri
      this.items.parameters || {}   // Trenutni parametri (merge)
    );
  }

  // Označava da su parametri već postavljeni
  this.items.set = true;
}
```

**Zašto je ovo važno:**
- **Parametri se nasljeđuju** od parent komponente
- Svaka komponenta može imati **svoje parametre + parent parametre**
- `items.set = true` sprječava **duplo postavljanje parametara**

**Primjer:**
```typescript
// DefaultBlock "FlatpaketiPOTS" ima parametre:
parameters = {
  P_PARENT_OFFER_ID: "5919",
  P_OFFER_ID: "5919"
}

// BasicBlock "FlatBHTelecom" nasljeđuje + dodaje svoje:
items.parameters = {
  P_PARENT_OFFER_ID: "5919",    // ← Nasledio od parent-a
  P_OFFER_ID: "5919",           // ← Nasledio od parent-a
  ACTION_CODE: "NewPOTS",       // ← Dodao svoj parametar
  P_CLASS_CODE: "ANALOG"        // ← Dodao svoj parametar
}
```

---

#### **Linija 38 (nastavak): Depedency.set()**

```typescript
this.Depedency.set(this.items, this.model);
```

**Šta radi:**
- Registruje **dependency pravila** za ovu komponentu

**Depedency.set() metoda:**
```typescript
set(items: InputObject, model: object) {
  if (!items.dependency || !items.dependency.length) return;  // Nema dependency

  // Prolazi kroz sve dependency pravila:
  items.dependency.forEach(dep => {
    // Registruje listener za source polje:
    this.register(dep.source, dep.target, dep.effect, model);
  });
}
```

**Dependency pravila:**
```json
{
  "dependency": [
    {
      "source": "PRIKLJUCAK_ADSL",      // Izvor (trigger polje)
      "target": "ACTION_PNK",            // Meta (polje koje se mijenja)
      "effect": "show",                  // Efekat (show/hide/enable/disable)
      "condition": "value == '0'"        // Uslov
    }
  ]
}
```

**Primjer izvršavanja:**
```typescript
// Korisnik odabere "IMA ADSL" (value = "0"):
model["PRIKLJUCAK_ADSL"] = "0"

// Dependency se aktivira:
if (model["PRIKLJUCAK_ADSL"] == "0") {
  items["ACTION_PNK"].visible = true;  // Prikaži polje ACTION_PNK
}
```

**Zašto je ovo važno:**
- Omogućava **dinamičko prikazivanje/sakrivanje** polja
- Omogućava **uslovnu validaciju** (npr. obavezno samo ako...)
- Omogućava **kompleksnu biznis logiku** bez hardkodovanja

---

#### **Linija 38 (nastavak): ValueManager.setDP()**

```typescript
this.ValueManager.setDP(this.Depedency);
```

**Šta radi:**
- Prosleđuje **Dependency servis** u ValueManager
- ValueManager treba dependency da bi mogao **triggerovati promjene**

**setDP() metoda:**
```typescript
setDP(dependency: DependencyService) {
  this.dependency = dependency;  // Čuva referencu na dependency servis
}
```

**Zašto je ovo važno:**
- ValueManager može **pozvati dependency.run()** nakon postavljanja vrijednosti
- Ovo omogućava **automatsko triggerovanje dependency** kada se vrijednost promijeni

**Primjer:**
```typescript
// ValueManager postavlja vrijednost:
model["PRIKLJUCAK_ADSL"] = "0"

// ValueManager automatski triggeruje dependency:
this.dependency.run("PRIKLJUCAK_ADSL");  // Aktivira sva dependency pravila

// Dependency mijenja vidljivost:
items["ACTION_PNK"].visible = true;  // Prikaži ACTION_PNK
```

---

#### **Linija 42: ValueManager.set()**

```typescript
this.items.template == 'Inputoutput' || this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);
```

**Logika sa short-circuit evaluacijom:**
```typescript
// Ovo je ekvivalent:
if (this.items.template != 'Inputoutput') {
  this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);
}
```

**Šta radi:**
- **Ako** template je 'Inputoutput', **preskače** ValueManager.set()
- **Ako** template **nije** 'Inputoutput', **poziva** ValueManager.set()

**ValueManager.set() - već objašnjeno u KORAK 5.12, ali ukratko:**
```typescript
set(field, model, parameters, mod) {
  // 1. Provjera: Da li polje već ima vrijednost?
  if (model[field.name] !== undefined) return;

  // 2. Ako je mod = 'disabled', postavi null:
  if (mod === 'disabled' || mod === 'preview') {
    model[field.name] = null;
    return;
  }

  // 3. Izvršava SQL (generationFormula):
  if (field.value?.generationFormula) {
    this.dblookup(field.value.generationFormula, parameters)
      .subscribe(result => {
        model[field.name] = result;  // Postavi vrijednost iz baze
      });
    return;
  }

  // 4. Koristi defaultValue:
  if (field.value?.defaultValue !== undefined) {
    model[field.name] = field.value.defaultValue;
    return;
  }

  // 5. Fallback:
  model[field.name] = field.elementType === 'checkbox' ? false : '';
}
```

**Zašto se preskače za 'Inputoutput'?**
- 'Inputoutput' template ima **specijalnu logiku** koja **ručno upravlja** vrijednostima
- Automatsko postavljanje bi **pregazilo** custom logiku

---

#### **Linija 44: getIndexName()**

```typescript
this.getIndexName();  // this.index = this.items.name = "FlatpaketiPOTS"
```

**Šta radi:**
- Postavlja `this.index` na **jedinstveni identifikator** komponente

**getIndexName() metoda:**
```typescript
getIndexName() {
  // Ako items.name postoji, koristi ga:
  if (this.items.name) {
    this.index = this.items.name;  // "FlatpaketiPOTS"
    return;
  }

  // Ako items.name ne postoji, generiši random ID:
  this.index = 'component_' + Math.random().toString(36).substr(2, 9);
}
```

**Zašto je ovo važno:**
- `this.index` se koristi kao **ključ** u `db.output` objektu
- `db.output[this.index]` čuva **output strukturu** za ovu komponentu
- **Mora biti jedinstveno** da bi izbjeglo kolizije

**Primjer:**
```typescript
// Za "FlatpaketiPOTS":
this.index = "FlatpaketiPOTS"

// Output se kreira na:
db.output["FlatpaketiPOTS"] = { active: true, value: {...} }

// Za "FlatBHTelecom":
this.index = "FlatBHTelecom"

// Output se kreira na:
db.output["FlatBHTelecom"] = { active: true, value: {...} }
```

---

#### **Linija 44 (nastavak): db.setoutput()**

```typescript
this.db.setoutput(this.items, this.model, this.output, this.index);
```

**Šta radi:**
- Kreira **output strukturu** za ovu komponentu u `db.output` objektu

**db.setoutput() metoda (iz model.service.ts):**
```typescript
setoutput(items: InputObject, model: object, output: object, index: string) {
  // Kreira output objekat sa strukturom:
  output[index] = {
    active: items.active || true,           // Da li je komponenta aktivna
    value: model,                           // REFERENCA na model!
    items: {},                              // Za child elements
    attr: {},                               // Za child inputs
    spec: {}                                // Za child children
  };

  // Ako items ima elements, kreira prazne objekte:
  if (items.elements) {
    output[index].items = {};
  }

  // Ako items ima inputs, kreira prazne objekte:
  if (items.inputs) {
    output[index].attr = {};
  }

  // Ako items ima children, kreira prazne objekte:
  if (items.children) {
    output[index].spec = {};
  }
}
```

**Primjer:**
```typescript
// Za "FlatpaketiPOTS" (DefaultBlock):
db.output = {
  "FlatpaketiPOTS": {
    active: true,
    value: db.model,            // REFERENCA na cijeli db.model
    items: {},                  // Za child elements (FlatBHTelecom)
    attr: {},                   // Prazan (DefaultBlock nema inputs)
    spec: {}                    // Prazan (DefaultBlock nema children na ovom nivou)
  }
}

// Za "FlatBHTelecom" (BasicBlock):
db.output["FlatpaketiPOTS"].items = {
  "FlatBHTelecom": {
    active: true,
    value: db.model["FlatBHTelecom"],  // REFERENCA na nested model
    items: {},                          // Prazan (BasicBlock nema elements)
    attr: {},                           // Za child inputs (FIRSTNAME, NAME, ...)
    spec: {}                            // Za child children (Tarifnipaketi, ...)
  }
}
```

**Zašto je ovo važno:**
- **db.output** se koristi za **tracking state** svih komponenti
- **Suicapture mehanizam** koristi output za **čuvanje podataka**
- **Child komponente** čitaju `output[parent].items/attr/spec` da znaju gdje da se smjeste

---

#### **Linija 51: Validation.set()**

```typescript
this.Validation.set(this.items, this.valid, this.vparent, this.index, this.db.mod);
```

**Šta radi:**
- Registruje **validaciona pravila** za ovu komponentu

**Validation.set() metoda:**
```typescript
set(items: InputObject, valid: InputValid, vparent: InputValid, index: string, mod: string) {
  if (!items.validation) return;  // Nema validacije

  // Kreira validation objekat:
  valid[index] = {
    valid: true,                    // Da li je validna
    errors: [],                     // Lista grešaka
    mandatory: items.validation.mandatory || false,
    minValue: items.validation.minValue,
    maxValue: items.validation.maxValue,
    formatPattern: items.validation.formatPattern,
    // ... ostala validation pravila
  };

  // Ako je mandatory, odmah validira:
  if (items.validation.mandatory && mod != 'disabled') {
    this.validate(items, {});  // Validira odmah
  }
}
```

**Primjer:**
```typescript
// Za "NAME" input (mandatory: true):
db.valid.children["NAME_5919"] = {
  valid: false,                // Nije validno (prazan string)
  errors: ["Ovo polje je obavezno"],
  mandatory: true,
  minValue: undefined,
  maxValue: undefined,
  formatPattern: undefined
}

// Kada korisnik upiše vrijednost:
model["NAME"] = "Testni korisnik"

// Validation.validate() ažurira:
db.valid.children["NAME_5919"] = {
  valid: true,                 // Sada je validno!
  errors: [],                  // Nema grešaka
  mandatory: true,
  // ...
}
```

**Zašto je ovo važno:**
- **Blokira submit** ako ima nevalidnih polja
- **Prikazuje error poruke** korisniku
- **Omogućava kompleksnu validaciju** (regex, range, custom...)

---

### REDOSLIJED IZVRŠAVANJA - ZAŠTO JE VAŽAN?

Komentar kaže: **"Ne diraj redoslijed izvrsavanja"**

**Zašto?**

```typescript
// 1. Validacija MORA biti prva (da prekine ako nije validna)
if (!this.isValid()) return;

// 2. active flag MORA biti postavljen prije db.set()
this.items.active = ...

// 3. db.set() MORA biti prije Dependency (da dependency zna trenutni model)
this.db.set(this.model, this.parent, this.pname);

// 4. setParametars() MORA biti prije Dependency (da dependency ima parametre)
this.setParametars();

// 5. Dependency.set() MORA biti prije ValueManager.setDP() (da registruje pravila)
this.Depedency.set(this.items, this.model);

// 6. ValueManager.setDP() MORA biti prije ValueManager.set() (da može triggerovati dependency)
this.ValueManager.setDP(this.Depedency);

// 7. ValueManager.set() MORA biti prije getIndexName() (da postavi vrijednosti)
this.ValueManager.set(...);

// 8. getIndexName() MORA biti prije setoutput() (da output zna gdje da se kreira)
this.getIndexName();

// 9. setoutput() MORA biti prije Validation.set() (da validation zna output strukturu)
this.db.setoutput(...);

// 10. Validation.set() MORA biti zadnja (da validira nakon što su sve vrijednosti postavljene)
this.Validation.set(...);
```

**Ako se promijeni redoslijed, mogu se desiti problemi:**
- Dependency pravila ne rade jer parametri nisu postavljeni
- Validacija ne radi jer output nije kreiran
- Vrijednosti se ne postavljaju jer model nije registrovan
- itd.

---

**KLJUČNA PRIMJEDBA:**

Za "default_block" template, `ValueManager.set()` **postavlja property na null** zbog `db.mod='disabled'`:
- default_block nije input komponenta, ali postavlja property zbog suicapture mehanizma
- ValueManager.set() kreira property sa null vrijednošću (jer db.mod='disabled' sprječava SQL izvršavanje)

**Rezultat nakon ngOnInit():**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": null  // ← Property kreiran sa null vrijednošću
}

db.output = {
  "FlatpaketiPOTS": {
    active: true,
    value: db.model  // ← REFERENCA!
  }
}
```

---

#### KORAK 5.3: ContentLoader renderuje template

**File:** `contentloader.template.html`

```html
<span *ngIf="items.active" class="...">
  <z-dlcontent
    [template]="items.template"    <!-- "default_block" -->
    [inputs]="{
      items: items,                <!-- { label: 'Osnovne usluge', name: 'Osnovneusluge', ... } -->
      model: model,                <!-- db.model (REFERENCA!) -->
      parent: parent,              <!-- undefined -->
      pname: pname,                <!-- undefined -->
      vparent: vparent,            <!-- db.valid -->
      valid: valid[index]||valid,  <!-- db.valid.children["Osnovneusluge"] || db.valid.children -->
      parameters: items.parameters,<!-- undefined -->
      output: output[index]||output[items.name]||output
                                   <!-- db.output["Osnovneusluge"] -->
    }">
  </z-dlcontent>
</span>
```

**Šta se dešava:**

1. Provjerava `items.active` = `true` (postavljeno u ngOnInit)
2. Renderuje `<z-dlcontent>` komponentu
3. Prosleđuje `template="default_block"` i sve ostale inputs u `inputs` objektu

**z-dlcontent prima:**

```typescript
template = "default_block"
inputs = {
  items: { label: "Flat paketi POTS", name: "FlatpaketiPOTS", code: "979", template: "default_block", elements: [...] },
  model: db.model,  // REFERENCA!
  parent: undefined,
  pname: undefined,
  vparent: db.valid,
  valid: db.valid.children,
  parameters: undefined,
  output: db.output["FlatpaketiPOTS"]
}
```

---

#### KORAK 5.4: DLContent dinamički kreira DefaultBlockComponent

**File:** `dlcontent.ts` (linija 51-83)

**DLContent component:**
- Selector: `z-dlcontent`
- Template: `<div #target></div>` (prazan container)
- Purpose: Dinamički kreira komponente na osnovu `template` property-ja

**Inputs:**

```typescript
@Input() template: string;   // "default_block"
@Input() inputs: object;     // { items, model, output, ... }
```

**Ključni kod - updateComponent() metoda (linija 65-75):**

```typescript
updateComponent() {
  if (!this.isViewInitialized) { return; }
  if (this.cmpRef) { this.cmpRef.destroy(); }

  // Linija 69: Lookup u key objektu
  // key["default_block"] = 1
  let component: any = Components[key[this.template]];
  //                             ↑ key["default_block"] = 1
  //                   Components[1] = DefaultBlockComponent

  // Linija 70: Kreira factory za DefaultBlockComponent
  let factory = this.cfResolver.resolveComponentFactory(component);

  // Linija 72: Dinamički kreira instancu DefaultBlockComponent
  this.cmpRef = this.target.createComponent(factory)
  // ↑ Kreira novu instancu DefaultBlockComponent i ubacuje je u <div #target>

  // Linija 73: KLJUČNO! Prosleđuje sve inputs komponenti!
  Object.assign(this.cmpRef.instance, this.inputs)
  // ↑ Ovo je ekvivalent:
  // defaultBlockInstance.items = inputs.items
  // defaultBlockInstance.model = inputs.model  ← REFERENCA!
  // defaultBlockInstance.parent = inputs.parent
  // defaultBlockInstance.pname = inputs.pname
  // defaultBlockInstance.vparent = inputs.vparent
  // defaultBlockInstance.valid = inputs.valid
  // defaultBlockInstance.parameters = inputs.parameters
  // defaultBlockInstance.output = inputs.output

  // Linija 74: Pokreće change detection
  this.cdRef.detectChanges();
}
```

**Mapiranje template → Component:**

Iz `dlcontent.ts` (linija 16-47):

```typescript
export const key = {
  basic_block: 0,      // → Components[0] = BasicBlockComponent
  default_block: 1,    // → Components[1] = DefaultBlockComponent
  checkblock: 2,       // → Components[2] = CheckBlockComponent
  standard_popup: 3,   // → Components[3] = StandardPopupComponent
  switchtab: 4,        // → Components[4] = SwitchTabComponent
  form: 5,             // → Components[5] = FormComponent
  button: 6,           // → Components[6] = ButtonComponent
  checkbox: 7,         // → Components[7] = CheckboxComponent
  input: 8,            // → Components[8] = InputComponent
  number: 8,           // → Components[8] = InputComponent (ista kao input)
  readonly: 8,         // → Components[8] = InputComponent (ista kao input)
  popbutton: 9,        // → Components[9] = PopupButtonComponent
  radio: 10,           // → Components[10] = RadioComponent
  select: 11,          // → Components[11] = SelectComponent
  textarea: 12,        // → Components[12] = TextareaComponent
  date: 13,            // → Components[13] = DateComponent
  // ... itd.
};
```

**Rezultat:**

DefaultBlockComponent instanca je kreirana sa:

```typescript
defaultBlockInstance = {
  items: {
    label: "Flat paketi POTS",      // ← STVARNI podatak
    name: "FlatpaketiPOTS",
    code: "979",
    template: "default_block",
    elements: [
      {
        label: "Flat BH Telecom",   // ← STVARNI podatak
        name: "FlatBHTelecom",
        code: "5919",
        template: "basic_block",
        inputs: [
          { name: "FIRSTNAME", ... },
          { name: "NAME", ... },
          { name: "JOBTITLE", ... },
          // ... 14 inputa ukupno
        ],
        children: [
          { name: "Tarifnipaketi", ... },
          { name: "Preuzimanja", ... },
          // ... 9 children ukupno
        ]
      }
    ]
  },
  model: db.model,  // ← REFERENCA! Pokazuje na ISTI objekat kao i db.model!
  output: db.output["FlatpaketiPOTS"],
  vparent: db.valid,
  valid: db.valid.children,
  parameters: undefined,
  parent: undefined,
  pname: undefined
}
```

---

#### KORAK 5.5: DefaultBlockComponent.ngOnInit() - KREIRANJE NESTED OBJEKTA!

**File:** `defaultblock.component.ts` (linija 24-40)

**STVARNI console.log output iz konzole:**

```typescript
ngOnInit() {
  console.log('=== DefaultBlock ngOnInit ===');
  console.log('items.name:', this.items.name);           // "FlatpaketiPOTS"
  console.log('items.label:', this.items.label);         // "Flat paketi POTS"
  console.log('items.code:', this.items.code);           // "979"
  console.log('model PRIJE kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"FlatpaketiPOTS":null}
  // ↑ Property već postoji (null), postavljen u ContentLoader.ngOnInit()

  // Linija 31: KLJUČNA LINIJA - KREIRA NESTED OBJEKAT!
  if (!this.model[this.items.name]) this.model[this.items.name] = {};
  //     ↑ this.model = db.model (REFERENCA!)
  //         this.items.name = "FlatpaketiPOTS"
  //
  // Provjerava: Da li db.model["FlatpaketiPOTS"] postoji i nije null/undefined/false?
  //   - db.model["FlatpaketiPOTS"] = null (falsy vrijednost!)
  //   - !null = true, dakle uslov je ispunjen
  //   - Postavlja: db.model["FlatpaketiPOTS"] = {} (zamjenjuje null sa praznim objektom)
  //
  // EKVIVALENT:
  //   if (!db.model["FlatpaketiPOTS"]) {  // !null = true
  //     db.model["FlatpaketiPOTS"] = {};   // null → {}
  //   }

  console.log('model NAKON kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"FlatpaketiPOTS":{}}
  // ↑ null je zamjenjen sa praznim objektom {}

  console.log('Kreiran nested objekat: model["' + this.items.name + '"] = {}');
  // Output: Kreiran nested objekat: model["FlatpaketiPOTS"] = {}

  console.log('======================');

  // Linija 37-39: Dependency logic (minimizacija itd.)
  !this.items.dependency || !this.items.dependency.length || this.items.dependency.map((dependency) => {
    if (dependency.effect === "minimize") { this.items.minimize = false; }
  });
}
```

**KRITIČNO RAZUMIJEVANJE:**

Pošto je `this.model` **REFERENCA** na `db.model`, linija 31:

```typescript
if (!this.model[this.items.name]) this.model[this.items.name] = {};
```

**DIREKTNO MODIFIKUJE** `db.model`!

**Zašto?**

U JavaScriptu/TypeScriptu, objekti se prosleđuju **po referenci**, ne po vrijednosti:

```typescript
let original = { auto: {} };
let referenca = original;      // REFERENCA, ne kopija!

referenca["Osnovneusluge"] = {};

console.log(original);
// Output: { auto: {}, Osnovneusluge: {} }
// ↑ original je također promijenjen!
```

**Rezultat:**

```typescript
// PRIJE ngOnInit():
db.model = {
  auto: {},
  "FlatpaketiPOTS": null  // ← null vrijednost
}

// NAKON ngOnInit():
db.model = {
  auto: {},
  "FlatpaketiPOTS": {}  // ← null zamjenjen sa praznim objektom!
}
```

**Console output - STVARNI iz konzole:**

```
=== DefaultBlock ngOnInit ===
items.name: FlatpaketiPOTS
items.label: Flat paketi POTS
items.code: 979
model PRIJE kreiranja: {"auto":{},"FlatpaketiPOTS":null}
model NAKON kreiranja: {"auto":{},"FlatpaketiPOTS":{}}
Kreiran nested objekat: model["FlatpaketiPOTS"] = {}
======================
```

---

#### KORAK 5.6: DefaultBlock renderuje template sa elements

**File:** `defaultblock.template.html` (linija 1-25)

```html
<div class="z-default-block">
  <div *ngIf="items.elementType === 'droppable' && dnd.start" class="dropArea" dnd-droppable (onDropSuccess)="drop($event)">
    <h6>Drop</h6>
  </div>

  <header>
    <h2 (click)="Depedency.run(items.dname)">{{items.label}}</h2>
    <!-- Prikazuje: "Flat paketi POTS" -->
    <i (click)="items.visible = !items.visible" class="expend fa {{ items.visible ? 'fa-angle-up': 'fa-angle-down'}}"></i>
  </header>

  <body [ngClass]="{ hidden: !items.visible }">
    <p *ngIf="items.description">{{items.description}}</p>

    <div>
      <z-contentloader *ngFor="let message of items.messages" [items]="message" [model]="model" ...></z-contentloader>
    </div>

    <div [ngClass]="{ hidden: items.minimize}">
      <!-- Linija 17: inputs (za DefaultBlock, items.inputs je undefined) -->
      <z-contentloader *ngFor="let input of items.inputs" [items]="input" [pname]="pname" [model]="model" ...></z-contentloader>

      <!-- Linija 18: KLJUČNA LINIJA - renderuje elements! -->
      <z-contentloader
        *ngFor="let element of items.elements"
        [items]="element"           <!-- element = "Osnovni paket- Fizicka" -->
        [pname]="pname"             <!-- undefined -->
        [model]="model"             <!-- ← PROSLEĐUJE CIJELI MODEL! -->
        [vparent]="valid"
        [valid]="valid.children"
        [parent]="parent"           <!-- undefined -->
        [output]="output.items || output"
        [parameters]="parameters">  <!-- undefined -->
      </z-contentloader>
    </div>

    <div [ngClass]="{ hidden: items.minimize === false}" >
      <!-- Linija 22: children -->
      <z-contentloader *ngFor="let children of items.children" [items]="children" [pname]="pname" [model]="model" ...></z-contentloader>
    </div>
  </body>
</div>
```

**Šta se dešava na liniji 18:**

1. `*ngFor="let element of items.elements"` iteruje kroz `elements` array
2. `items.elements` sadrži 1 element: "Flat BH Telecom"

```typescript
items.elements[0] = {
  label: "Flat BH Telecom",    // ← STVARNI podatak
  name: "FlatBHTelecom",
  code: "5919",
  template: "basic_block",     // ← Sada je basic_block!
  inputs: [
    { name: "FIRSTNAME", ... },
    { name: "NAME", ... },
    { name: "JOBTITLE", ... },
    // ... 14 inputa ukupno
  ],
  children: [
    { name: "Tarifnipaketi", ... },
    { name: "Preuzimanja", ... },
    // ... 9 children ukupno
  ]
}
```

3. Za **prvi (i jedini) element**, Angular kreira novi `<z-contentloader>` sa:

```typescript
// ContentLoader prima:
items = {
  label: "Flat BH Telecom",    // ← STVARNI podatak
  name: "FlatBHTelecom",
  code: "5919",
  template: "basic_block",
  inputs: [ {...}, {...}, ... ],
  children: [ {...} ]
}

model = this.model         // ← DefaultBlock prosleđuje this.model
     = db.model            // { auto: {}, "FlatpaketiPOTS": {} }
                           // ← JOŠ UVIJEK CIJELI MODEL!

output = this.output.items || this.output
parameters = this.parameters  // undefined
vparent = this.valid
valid = this.valid.children
parent = this.parent          // undefined
pname = this.pname            // undefined
```

**KLJUČNA RAZLIKA:**

DefaultBlock prosleđuje `[model]="model"` (cijeli model), **NE** `[model]="model[items.name]"` (nested dio).

**Zašto?**

Pogledaj zakomentiran kod u `defaultblock.template.html` (linija 26-50) - tamo se koristi `[model]="model[items.name]"`, ali trenutni aktivni kod (linija 1-25) koristi `[model]="model"`.

Ovo znači da "Osnovni paket- Fizicka" (BasicBlock) prima **cijeli** `db.model`, ne samo `db.model["Osnovneusluge"]`.

---

#### KORAK 5.7-5.8: ContentLoader → DLContent → BasicBlockComponent

Isti proces kao KORAK 5.2-5.4, ali sada za "basic_block" template:

1. **ContentLoader.ngOnInit()** izvršava se za "Flat BH Telecom"
2. **ContentLoader** renderuje `<z-dlcontent template="basic_block">`
3. **DLContent.updateComponent()** kreira **BasicBlockComponent** instancu:

```typescript
// key["basic_block"] = 0
let component = Components[0];  // BasicBlockComponent

// Kreira instancu i prosleđuje inputs
Object.assign(basicBlockInstance, {
  items: {
    label: "Flat BH Telecom",     // ← STVARNI podatak
    name: "FlatBHTelecom",
    code: "5919",
    template: "basic_block",
    inputs: [
      { name: "FIRSTNAME", ... },
      { name: "NAME", ... },
      // ... 14 inputa ukupno
    ],
    children: [
      { name: "Tarifnipaketi", ... },
      // ... 9 children ukupno
    ]
  },
  model: db.model,  // ← REFERENCA! { auto: {}, "FlatpaketiPOTS": {} }
  output: db.output["FlatpaketiPOTS"].items || db.output["FlatpaketiPOTS"],
  // ... ostali inputs
});
```

---

#### KORAK 5.9: BasicBlockComponent.ngOnInit() - DRUGI NESTED OBJEKAT!

**File:** `basicblock.component.ts` (linija 20-32)

**STVARNI console.log output iz konzole:**

```typescript
ngOnInit() {
  console.log('=== BasicBlock ngOnInit ===');
  console.log('items.name:', this.items.name);           // "FlatBHTelecom"
  console.log('items.label:', this.items.label);         // "Flat BH Telecom"
  console.log('items.code:', this.items.code);           // "5919"
  console.log('model PRIJE kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"FlatpaketiPOTS":{},"loadOffer979":"5919","FlatBHTelecom":null}
  // ↑ Primijetite: "loadOffer979":"5919" je dodan (to je select element iz actions)
  // ↑ Primijetite: "FlatBHTelecom":null je dodan (iz ContentLoader.ngOnInit())

  // Linija 27: KLJUČNA LINIJA - KREIRA DRUGI NESTED OBJEKAT!
  if (!this.model[this.items.name]) this.model[this.items.name] = {};
  //     ↑ this.model = db.model (REFERENCA!)
  //         this.items.name = "FlatBHTelecom"
  //
  // Provjerava: Da li db.model["FlatBHTelecom"] postoji i nije null/undefined/false?
  //   - db.model["FlatBHTelecom"] = null (falsy vrijednost!)
  //   - !null = true, dakle uslov je ispunjen
  //   - Postavlja: db.model["FlatBHTelecom"] = {} (zamjenjuje null sa praznim objektom)
  //
  // EKVIVALENT:
  //   if (!db.model["FlatBHTelecom"]) {  // !null = true
  //     db.model["FlatBHTelecom"] = {};   // null → {}
  //   }

  console.log('model NAKON kreiranja:', JSON.stringify(this.model));
  // Output: {"auto":{},"FlatpaketiPOTS":{},"loadOffer979":"5919","FlatBHTelecom":{}}
  // ↑ null je zamjenjen sa praznim objektom {}

  console.log('Kreiran nested objekat: model["' + this.items.name + '"] = {}');
  // Output: Kreiran nested objekat: model["FlatBHTelecom"] = {}

  console.log('======================');
}
```

**Rezultat:**

```typescript
// PRIJE ngOnInit():
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",      // ← Dodan od strane select elementa
  "FlatBHTelecom": null         // ← Dodan od strane ContentLoader
}

// NAKON ngOnInit():
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {}  // ← null zamjenjen sa praznim objektom!
}
```

**Console output - STVARNI iz konzole:**

```
=== BasicBlock ngOnInit ===
items.name: FlatBHTelecom
items.label: Flat BH Telecom
items.code: 5919
model PRIJE kreiranja: {"auto":{},"FlatpaketiPOTS":{},"loadOffer979":"5919","FlatBHTelecom":null}
model NAKON kreiranja: {"auto":{},"FlatpaketiPOTS":{},"loadOffer979":"5919","FlatBHTelecom":{}}
Kreiran nested objekat: model["FlatBHTelecom"] = {}
======================
```

---

#### KORAK 5.10: BasicBlock renderuje template sa inputs - KLJUČNA RAZLIKA!

**File:** `basicblock.template.html` (linija 1-12)

```html
<span *ngIf="!model['minimize']">
  <z-contentloader *ngFor="let message of items.messages" [items]="message" [model]="model[items.name]" ...></z-contentloader>
</span>

<div class="z-basic-block" [ngClass]="{hidden:!items.visible, inactive:items.blocked}" *ngIf="output.active">
  <!-- Linija 6: elements -->
  <z-contentloader *ngFor="let element of items.elements" [items]="element" [pname]="pname" [model]="model[items.name]" ...></z-contentloader>

  <!-- Linija 8-9: inputs - KLJUČNA LINIJA! -->
  <z-contentloader
    *ngFor="let input of items.inputs"
    [items]="input"
    [pname]="pname"                    <!-- undefined -->
    [model]="model[items.name]"        <!-- ← PROSLEĐUJE NESTED DIO! -->
    [vparent]="valid"
    [valid]="valid.children"
    [output]="output.attr || output"
    [parent]="model"                   <!-- ← parent je CIJELI model -->
    [parameters]="parameters">
  </z-contentloader>

  <!-- Linija 10-11: children -->
  <z-contentloader *ngFor="let children of items.children" [items]="children" [pname]="pname" [model]="model[items.name]" ...></z-contentloader>
</div>
```

**OVDJE JE KLJUČNA RAZLIKA!**

**DefaultBlock vs BasicBlock:**

| Komponenta | Prosleđuje djeci |
|------------|------------------|
| DefaultBlock | `[model]="model"` (cijeli model) |
| BasicBlock | `[model]="model[items.name]"` (nested dio) |

**Šta se dešava na liniji 8-9:**

1. `*ngFor="let input of items.inputs"` iteruje kroz `inputs` array
2. `items.inputs` sadrži 11 inputa: FIRSTNAME, NAME, JOBTITLE, itd.
3. Za **prvi input** (FIRSTNAME), Angular kreira `<z-contentloader>` sa:

```typescript
// ContentLoader prima:
items = {
  name: "FIRSTNAME",
  label: "Ime",
  componentType: "input",
  template: "input",
  generationFormula: "SELECT contact.firstname FROM contact WHERE contact.id = :P_CONTACT_ID",
  validation: { mandatory: false, ... },
  // ... ostale properties
}

model = this.model[this.items.name]      // ← NESTED DIO!
     = this.model["FlatBHTelecom"]
     = db.model["FlatBHTelecom"]        // ← REFERENCA NA NESTED OBJEKAT!
     = {}                                // ← Trenutno prazan objekat

parent = this.model                      // ← CIJELI MODEL!
      = db.model                         // ← REFERENCA NA CIJELI MODEL!

pname = this.pname  // undefined
```

**KRITIČNO RAZUMIJEVANJE:**

```typescript
// BasicBlock prima:
this.model = db.model  // REFERENCA na cijeli model

// BasicBlock prosleđuje djeci:
[model] = this.model[this.items.name]
        = this.model["FlatBHTelecom"]
        = db.model["FlatBHTelecom"]  // REFERENCA na nested objekat!

// Pošto je model[items.name] = db.model["FlatBHTelecom"],
// kada input komponenta dodaje property:
//   model["FIRSTNAME"] = null  (jer db.mod='disabled')
// to je EKVIVALENT:
//   db.model["FlatBHTelecom"]["FIRSTNAME"] = null
```

**Ali trenutno db.model["FlatBHTelecom"] je prazan objekat {}!**

To će se promijeniti u sljedećem koraku...

---

#### KORAK 5.11: ContentLoader.ngOnInit() za input FIRSTNAME

ContentLoader ponovo izvršava `ngOnInit()`, ali sada za **input** komponentu:

**STVARNI console.log output iz konzole:**

```typescript
ngOnInit() {
  console.log('--- ContentLoader ngOnInit ---');
  console.log('items.name:', this.items.name);           // "FIRSTNAME"
  console.log('items.template:', this.items.template);   // "input"
  console.log('items.code:', this.items.code);           // "FIRSTNAME"

  // ... isti kod kao prije (linija 35-38) ...

  // Linija 40-42: OVDJE SE DEŠAVA MAGIJA!
  console.log('model PRIJE ValueManager.set():', JSON.stringify(this.model));
  // Output: {}  ← Prazan jer je model = db.model["FlatBHTelecom"]

  this.items.template == 'Inputoutput' || this.ValueManager.set(this.items, this.model, this.items.parameters, this.db.mod);
  // ↑ Pošto template je "input" (NE "Inputoutput"), poziva se ValueManager.set()!

  console.log('model NAKON ValueManager.set():', JSON.stringify(this.model));
  // Output: {"FIRSTNAME":null}  ← Property kreiran sa null vrijednošću!
  // ↑ NAPOMENA: null jer je db.mod='disabled' (SQL se ne izvršava)

  // ... ostatak koda (setoutput, validation) ...
}
```

**KLJUČNO:** Za "input" template, `ValueManager.set()` **RADI**, ali vrijednost je `null` jer `db.mod='disabled'`!

---

#### KORAK 5.12: ValueManager.set() - POSTAVLJANJE NA NULL (zbog db.mod='disabled')!

**File:** `value.manager.ts` (linija ~25-33)

**STVARNA logika sa stvarnim console.log outputom:**

```typescript
set(field: InputObject, model: object, parameters?: any, mod?: string) {
  // field.name = "FIRSTNAME"
  // model = db.model["FlatBHTelecom"]  (REFERENCA!)
  // parameters = db.params
  // mod = "disabled"  ← KLJUČNO!

  console.log('=== ValueManager.set() START ===');
  console.log('field.name:', field.name);           // "FIRSTNAME"
  console.log('model PRIJE:', model);               // {}
  console.log('mod:', mod);                         // "disabled"
  console.log('generationFormula:', field.value?.generationFormula);
  // Output: "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual"

  // 1. Provjera: Da li polje već ima vrijednost?
  if (model[field.name] !== undefined) {
    console.log('Polje već ima vrijednost, preskačem');
    return;
  }
  // model["FIRSTNAME"] je undefined → nastavlja

  // 2. Provjera: Da li je mod = 'disabled'?
  if (mod === 'disabled' || mod === 'preview') {
    console.log('mod je disabled/preview, postavljam property na null');

    // KLJUČNO: Zbog disabled moda, NE izvršava SQL!
    // Umjesto toga, postavlja property na null
    model[field.name] = null;
    //  ↑ model = db.model["FlatBHTelecom"] (REFERENCA!)
    //    field.name = "FIRSTNAME"
    //
    // Ovo je EKVIVALENT:
    //   db.model["FlatBHTelecom"]["FIRSTNAME"] = null

    console.log('model NAKON:', model);  // {"FIRSTNAME":null}
    return;
  }

  // 3. generationFormula - Izvršava SQL via backend (SAMO AKO mod NIJE disabled!)
  if (field.value?.generationFormula) {
    console.log('Koristim generationFormula (SQL)');

    // Poziva backend da izvrši SQL
    this.dblookup(field.value.generationFormula, parameters).subscribe(result => {
      console.log('SQL rezultat:', result);  // npr. "Kenan"

      // KLJUČNO: Postavlja vrijednost u model!
      model[field.name] = result;
      //  ↑ model = db.model["FlatBHTelecom"] (REFERENCA!)
      //    field.name = "FIRSTNAME"
      //    result = "Kenan"
      //
      // Ovo je EKVIVALENT:
      //   db.model["FlatBHTelecom"]["FIRSTNAME"] = "Kenan"

      console.log('model NAKON SQL:', model);  // {"FIRSTNAME":"Kenan"}
    });
    return;
  }

  // 3. defaultValue - Statička default vrijednost
  if (field.defaultValue !== undefined) {
    console.log('Koristim defaultValue');
    model[field.name] = field.defaultValue;
    return;
  }

  // 4. mappingRef - Uzima vrijednost iz parametara
  if (field.mappingRef && parameters[field.mappingRef] !== undefined) {
    console.log('Koristim mappingRef');
    model[field.name] = parameters[field.mappingRef];
    return;
  }

  // 5. Fallback - Prazan string ili false
  console.log('Fallback - prazan string');
  model[field.name] = field.componentType === 'checkbox' ? false : '';

  console.log('=== ValueManager.set() END ===');
}
```

**dblookup() metoda:**

```typescript
dblookup(sql: string, parameters: any): Observable<any> {
  return this.http.post('/uomback/common/lookupStatement', {
    sql: sql,
    parameters: parameters
  }).map(response => response.json());
}
```

**Izvršavanje za FIRSTNAME sa db.mod='disabled':**

```
=== ValueManager.set() START ===
field.name: FIRSTNAME
model PRIJE: {}
mod: disabled
generationFormula: select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual
mod je disabled/preview, postavljam property na null
model NAKON: {"FIRSTNAME":null}
=== ValueManager.set() END ===
```

**NAPOMENA:** SQL se **NE IZVRŠAVA** jer je `db.mod='disabled'`. Umjesto toga, property se postavlja na `null`.

**Rezultat:**

```typescript
// model je REFERENCA na db.model["FlatBHTelecom"]
// Dakle:
db.model["FlatBHTelecom"] = {
  FIRSTNAME: null  // ← PRVA VRIJEDNOST (null zbog disabled moda)!
}

// Kompletan db.model:
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: null  // ← NOVA VRIJEDNOST (null!)
  }
}
```

**Kada bi mod bio 'new' ili 'edit' (normalan rad):**

```
=== ValueManager.set() START ===
field.name: FIRSTNAME
model PRIJE: {}
mod: new
generationFormula: select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual
Koristim generationFormula (SQL)

HTTP POST /uomback/common/lookupStatement
  Request Body:
    {
      "sql": "select uomcommon.fgetFirstLastname(#:P_CLASS_CODE#,#:P_CA_ID#,'FIRSTNAME') from dual",
      "parameters": { "P_CLASS_CODE": "ANALOG", "P_CA_ID": 123456 }
    }

Backend executes SQL...
Backend returns: "Kenan"

SQL rezultat: "Kenan"
model["FIRSTNAME"] = "Kenan"
model NAKON SQL: {"FIRSTNAME":"Kenan"}
=== ValueManager.set() END ===
```

**Tada bi rezultat bio:**

```typescript
db.model["FlatBHTelecom"] = {
  FIRSTNAME: "Kenan"  // ← PRAVA VRIJEDNOST iz baze!
}
```

---

#### KORAK 5.13: DLContent kreira InputComponent

**DLContent.updateComponent():**

```typescript
// key["input"] = 8
let component = Components[8];  // InputComponent

let factory = this.cfResolver.resolveComponentFactory(component);
this.cmpRef = this.target.createComponent(factory)

// Prosleđuje inputs
Object.assign(this.cmpRef.instance, {
  items: { name: "FIRSTNAME", label: "Ime", template: "input", ... },
  model: db.model["FlatBHTelecom"],  // REFERENCA!
  output: db.output["FlatpaketiPOTS"].attr || db.output["FlatpaketiPOTS"],
  vparent: db.valid,
  valid: db.valid.children,
  parent: db.model,  // CIJELI model!
  parameters: db.params
});
```

---

#### KORAK 5.14: InputComponent renderuje template sa ngModel - TWO-WAY BINDING!

**File:** `input.template.html` (linija 1-30)

```html
<div class="z-inputs" *ngIf="items.visible" dnd-droppable (onDropSuccess)="dropInput($event)" [dropEnabled]="items.drop">
  <label *ngIf="items.elementType !== 'date'" [ngClass]="{required:items.validation.mandatory}">
    {{items.label}}  <!-- "Ime" -->
  </label>

  <input
    *ngIf="items.elementType !== 'date'"
    [ngClass]="{readonly: items.template === 'readonly', inactive:db.mod=='preview', invalid:!items.is.valid }"
    [id]="items.dname"
    [name]="items.dname"
    [(ngModel)]="model[items.name]"      <!-- ← ANGULAR TWO-WAY BINDING! -->
    [disabled]="items.disabled?'disabled':'false'"
    [readonly]="items.disabled?'readonly':false"
    [required]="items.validation.mandatory ? model[items.name] ? false:true:false"
    [min]="!items.validation.minValue || items.validation.minValue"
    [max]="!items.validation.maxValue || items.validation.maxValue"
    [maxlength]="!items.validation.maxValue || items.validation.maxValue"
    [pattern]="items.validation.formatPattern ? items.validation.formatPattern:''"
    [type]="items.elementType || 'text'"
    (focusout)="Validation.validate(items, parameters);"
    (change)="Depedency.depend(items.dname);"
  />
</div>
```

**Angular [(ngModel)] Two-Way Binding:**

```typescript
// InputComponent prima:
this.items.name = "FIRSTNAME"
this.model = db.model["FlatBHTelecom"]  // REFERENCA!

// Template koristi:
[(ngModel)]="model[items.name]"
          = model["FIRSTNAME"]
          = db.model["FlatBHTelecom"]["FIRSTNAME"]
```

**Kako radi [(ngModel)]:**

`[(ngModel)]` je skraćenica za:
- `[ngModel]="..."` - property binding (Model → View)
- `(ngModelChange)="... = $event"` - event binding (View → Model)

**Automatska sinhronizacija:**

1. **Inicijalno prikazivanje (Model → View):**
   - Angular čita `model["FIRSTNAME"]` = `null`
   - Prikazuje **prazan input** (jer je null, a ne string)
   - Korisnik vidi: `[             ]` (prazno polje)

2. **Korisnik mijenja vrijednost (View → Model):**
   - Korisnik upiše "Kenan" u input
   - Angular detektuje promjenu (via `input` event)
   - Angular automatski poziva: `model["FIRSTNAME"] = "Kenan"`
   - Pošto je `model` REFERENCA na `db.model["FlatBHTelecom"]`
   - Promjena se automatski reflektuje:

```typescript
// PRIJE korisničke promjene:
db.model["FlatBHTelecom"]["FIRSTNAME"] = null

// Korisnik upisuje "Kenan" → Angular automatski ažurira:
db.model["FlatBHTelecom"]["FIRSTNAME"] = "Kenan"

// Korisnik mijenja na "John" → Angular automatski ažurira:
db.model["FlatBHTelecom"]["FIRSTNAME"] = "John"

// NEMA POTREBE ZA DODATNIM KODOM!
```

**NEMA event handler-a, NEMA callback-a, NEMA ručnog ažuriranja!**

Angular automatski sinhronizuje model i view u oba smjera!

---

#### KORAK 5.15: Proces se ponavlja za SVA polja

Isti proces (KORAK 5.11-5.14) se ponavlja za **SVA polja** u `items.inputs`:

**Lista inputa (STVARNI iz order-entry strukture):**

1. **FIRSTNAME** (Ime) - template: input, generationFormula: SQL - visible: true
2. **NAME** (Prezime/Naziv) - template: input, generationFormula: SQL, mandatory: true - visible: true
3. **JOBTITLE** (Funkcija) - template: select, lookupStatement: SQL - visible: true
4. **PRIKLJUCAK_ADSL** (Na lokaciji) - template: select, data: [IMA ADSL, NEMA ADSL], mandatory: true - visible: true
5. **ACTION_PNK** (Da li ju u akciji) - template: input, generationFormula: SQL, disabled: true - visible: false
6. **FRSEGSCLASS_CODE** (Grupa podtipova) - template: input, generationFormula: SQL - visible: true
7. **PUSER_EMAIL** (Trenutni email) - template: input, generationFormula: SQL - visible: false
8. **FIRSTNAME** (Ime) - duplikat, template: input, generationFormula: SQL - visible: false
9. **NAME** (Prezime/Naziv korisnika) - duplikat, template: input, generationFormula: SQL - visible: false
10. **DEFAULTCONTACTPHONE** (Kontakt telefon) - template: input, generationFormula: SQL - visible: false
11. **OFFER_NAME** (Naziv paketa) - template: input, generationFormula: SQL, disabled: true - visible: false
12. **DEFAULTCONTACTEMAIL** (Email korisnika) - template: input, generationFormula: SQL - visible: false
13. **PQUANTITY_NUM** (Količina) - template: input, generationFormula: SQL - visible: false
14. **CCC_IND** (CCC indikator) - template: input, generationFormula: SQL - visible: false

**Za svaki input:**
1. ContentLoader.ngOnInit() → ValueManager.set()
2. DLContent → InputComponent/SelectComponent
3. Komponenta renderuje sa [(ngModel)]

**Nakon što se SVA polja inicijalizuju (sa db.mod='disabled'):**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: null,              // ← null zbog disabled moda
    NAME: null,                   // ← null zbog disabled moda
    JOBTITLE: null,               // ← null zbog disabled moda
    PRIKLJUCAK_ADSL: null,        // ← null zbog disabled moda
    ACTION_PNK: null,             // ← null zbog disabled moda
    FRSEGSCLASS_CODE: null,       // ← null zbog disabled moda
    PUSER_EMAIL: null,            // ← null zbog disabled moda
    DEFAULTCONTACTPHONE: null,    // ← null zbog disabled moda
    OFFER_NAME: null,             // ← null zbog disabled moda
    DEFAULTCONTACTEMAIL: null,    // ← null zbog disabled moda
    PQUANTITY_NUM: null,          // ← null zbog disabled moda
    CCC_IND: null                 // ← null zbog disabled moda
  }
}
```

**Korisnik mijenja vrijednosti:**

- Upiše "Kenan" u polju "Ime"
  - Angular automatski: `db.model["FlatBHTelecom"]["FIRSTNAME"] = "Kenan"`
- Upiše "Testni korisnik" u polju "Prezime/Naziv"
  - Angular automatski: `db.model["FlatBHTelecom"]["NAME"] = "Testni korisnik"`
- Bira "Direktor" u polju "Funkcija" (select dropdown)
  - Angular automatski: `db.model["FlatBHTelecom"]["JOBTITLE"] = "Direktor"`
- Bira "IMA ADSL" u polju "Na lokaciji"
  - Angular automatski: `db.model["FlatBHTelecom"]["PRIKLJUCAK_ADSL"] = "0"`

**Finalni db.model nakon korisničkih promjena:**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: "Kenan",                      // ← Unio korisnik
    NAME: "Testni korisnik",                 // ← Unio korisnik
    JOBTITLE: "Direktor",                    // ← Odabrao korisnik
    PRIKLJUCAK_ADSL: "0",                    // ← Odabrao korisnik (IMA ADSL)
    ACTION_PNK: null,                        // ← Ostao null (disabled field)
    FRSEGSCLASS_CODE: "GOLD",                // ← Unio korisnik
    PUSER_EMAIL: null,                       // ← Ostao null (visible: false)
    DEFAULTCONTACTPHONE: null,               // ← Ostao null (visible: false)
    OFFER_NAME: null,                        // ← Ostao null (disabled field)
    DEFAULTCONTACTEMAIL: null,               // ← Ostao null (visible: false)
    PQUANTITY_NUM: null,                     // ← Ostao null (visible: false)
    CCC_IND: null                            // ← Ostao null (visible: false)
  }
}
```

**NAPOMENA:** Kada bi `db.mod='new'` ili `db.mod='edit'` (normalan rad), sva polja bi bila popunjena sa SQL rezultatima umjesto null vrijednosti!

---

#### KORAK 5.16: Child elementi se renderuju (Tarifni paketi, Zabrana info...)

**BasicBlock template - Linija 10-11:**

```html
<z-contentloader
  *ngFor="let children of items.children"
  [items]="children"
  [pname]="pname"
  [model]="model[items.name]"    <!-- ← NESTED DIO! -->
  [vparent]="valid"
  [valid]="valid.children"
  [output]="output.spec || output"
  [parent]="model"
  [parameters]="parameters">
</z-contentloader>
```

**Za child "Tarifni paketi" (STVARNI podatak):**

```typescript
children = {
  label: "Tarifni paketi",     // ← STVARNI podatak
  name: "Tarifnipaketi",
  code: "178",
  template: "default_block",
  elements: [ {...} ]
}

model = this.model[this.items.name]
     = this.model["FlatBHTelecom"]
     = db.model["FlatBHTelecom"]  // REFERENCA!
```

**Ali čekaj, zašto child dobija `model["FlatBHTelecom"]` a ne cijeli `db.model`?**

**Odgovor:** Zato što BasicBlock prosleđuje `[model]="model[items.name]"` za children!

**Ali to znači da će child "Tarifni paketi" kreirati:**

```typescript
// U DefaultBlock.ngOnInit() za "Tarifni paketi":
if (!this.model[this.items.name]) this.model[this.items.name] = {};
//     ↑ this.model = db.model["FlatBHTelecom"]
//       this.items.name = "Tarifnipaketi"
//
// EKVIVALENT:
//   db.model["FlatBHTelecom"]["Tarifnipaketi"] = {};
```

**Rezultat:**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: null,
    NAME: null,
    // ... ostali inputi ...
    "Tarifnipaketi": null  // ← NESTED unutar "FlatBHTelecom"!
  }
}
```

**NAPOMENA iz STVARNOG console.log-a:** Children se ZAPRAVO kreiraju **na istom nivou** kao parent zbog načina kako BasicBlock template prosleđuje model u zakomentiranom kodu (linija 8-9 u basicblock.template.html).

**Stvarni rezultat iz console.log-a:**

```typescript
// Iz other.md, vidimo da DefaultBlock za "Tarifnipaketi" prima model sa SVim vrijednostima:
// model PRIJE kreiranja: {"FIRSTNAME":null,"NAME":null,...,"Preuzimanja":{},...,"Tarifnipaketi":null}

db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: null,
    NAME: null,
    // ... ostali inputi (12 ukupno) ...
    CCC_IND: null
  },
  "Preuzimanja": {},              // ← Root nivo (child)
  "loadOffer164": null,           // ← Action za Preuzimanja
  "OtkazivanjeISDNBRAzboginstalacijePOTSa": null,
  "OtkazivanjeISDNPRAzboginstalacijePOTSa": null,
  "Tarifnipaketi": {},            // ← Root nivo (child)
  "loadOffer178": null,           // ← Action za Tarifnipaketi
  // ... ostali children ...
  "Zabranainformacija": {}        // ← Root nivo (child)
}
```

---

### FINALNI db.model - Potpuno popunjen

**Sa db.mod='disabled' (STVARNO stanje iz console.log-a):**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: null,           // ← null jer db.mod='disabled'
    NAME: null,
    JOBTITLE: null,
    PRIKLJUCAK_ADSL: null,
    ACTION_PNK: null,
    FRSEGSCLASS_CODE: null,
    PUSER_EMAIL: null,
    DEFAULTCONTACTPHONE: null,
    OFFER_NAME: null,
    DEFAULTCONTACTEMAIL: null,
    PQUANTITY_NUM: null,
    CCC_IND: null
  },
  "Preuzimanja": {},
  "loadOffer164": null,
  "OtkazivanjeISDNBRAzboginstalacijePOTSa": null,
  "OtkazivanjeISDNPRAzboginstalacijePOTSa": null,
  "Tarifnipaketi": {},
  "loadOffer178": null,
  "Dodatneuslugetehnicke(1)": {},
  // ... ostali children ...
  "Zabranainformacija": {}
}
```

**Nakon što korisnik popuni polja (ručni unos):**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: "Kenan",                // ← Unio korisnik
    NAME: "Testni korisnik",           // ← Unio korisnik
    JOBTITLE: "Direktor",              // ← Odabrao korisnik
    PRIKLJUCAK_ADSL: "0",              // ← Odabrao korisnik (IMA ADSL)
    ACTION_PNK: null,                  // ← Ostao null (disabled)
    FRSEGSCLASS_CODE: "GOLD",          // ← Unio korisnik
    PUSER_EMAIL: null,                 // ← Ostao null (visible: false)
    DEFAULTCONTACTPHONE: null,         // ← Ostao null (visible: false)
    OFFER_NAME: null,                  // ← Ostao null (disabled)
    DEFAULTCONTACTEMAIL: null,         // ← Ostao null (visible: false)
    PQUANTITY_NUM: null,               // ← Ostao null (visible: false)
    CCC_IND: null                      // ← Ostao null (visible: false)
  },
  "Preuzimanja": {},
  "Tarifnipaketi": {},
  "Zabranainformacija": {},
  // ... ostali children ...
}
```

**SA NORMALNIM MODOM (db.mod='new' ili 'edit') - sve vrijednosti bi bile iz baze:**

```typescript
db.model = {
  auto: {},
  "FlatpaketiPOTS": {},
  "loadOffer979": "5919",
  "FlatBHTelecom": {
    FIRSTNAME: "Kenan",                      // ← Iz baze (SQL)
    NAME: "Testni korisnik",                 // ← Iz baze (SQL)
    JOBTITLE: "Direktor",                    // ← Iz baze (SQL)
    PRIKLJUCAK_ADSL: "0",                    // ← Iz baze
    ACTION_PNK: "N",                         // ← Iz baze (SQL)
    FRSEGSCLASS_CODE: "GOLD",                // ← Iz baze (SQL)
    PUSER_EMAIL: "kenan@bhtelecom.ba",       // ← Iz baze (SQL)
    DEFAULTCONTACTPHONE: "+387611234567",    // ← Iz baze (SQL)
    OFFER_NAME: "Flat BH Telecom",           // ← Iz baze (SQL)
    DEFAULTCONTACTEMAIL: "kenan@test.com",   // ← Iz baze (SQL)
    PQUANTITY_NUM: "1",                      // ← Iz baze (SQL)
    CCC_IND: "N"                             // ← Iz baze (SQL)
  },
  "Preuzimanja": {},
  "Tarifnipaketi": {},
  "Zabranainformacija": {},
  // ... ostali children ...
}
```

---

### VIZUALNI DIJAGRAM - Kompletan proces od `<z-pageloader>` do popunjavanja `db.model`

```
┌─────────────────────────────────────────────────────────────────┐
│  STARTNA POZICIJA                                               │
│  ════════════════                                               │
│                                                                 │
│  <z-pageloader [items]="structure.structure"                    │
│                 [model]="db.model">                             │
│                                                                 │
│  db.model = { auto: {} }                                        │
│  db.mod = 'disabled'  ← KLJUČNO! Zato su sve vrijednosti null  │
│  structure.structure = [{                                       │
│    label: "Flat paketi POTS", name: "FlatpaketiPOTS",          │
│    template: "default_block",                                   │
│    elements: [{                                                 │
│      label: "Flat BH Telecom",                                  │
│      name: "FlatBHTelecom",                                     │
│      template: "basic_block",                                   │
│      inputs: [{ name: "FIRSTNAME", ... }, ...] // 14 inputa     │
│    }]                                                           │
│  }]                                                             │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.1: PageLoader renderuje template                      │
│  ══════════════════════════════════════                         │
│                                                                 │
│  Template: <z-contentloader *ngFor="let item of items"          │
│                             [items]="item"                      │
│                             [model]="model">  ← REFERENCA!      │
│                                                                 │
│  Za items[0] ("Flat paketi POTS"), kreira ContentLoader        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.2: ContentLoader.ngOnInit() - "Flat paketi POTS"      │
│  ═══════════════════════════════════════════════════            │
│                                                                 │
│  items.template = "default_block"                               │
│  model = db.model  ← REFERENCA!                                 │
│                                                                 │
│  ValueManager.set() → Postavlja property na null (disabled mod) │
│  db.setoutput() → Kreira output["FlatpaketiPOTS"]               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.3: ContentLoader renderuje template                   │
│  ═════════════════════════════════════════                      │
│                                                                 │
│  <z-dlcontent [template]="default_block"                        │
│               [inputs]="{items, model, ...}">                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.4: DLContent dinamički kreira DefaultBlockComponent   │
│  ═══════════════════════════════════════════════════════════    │
│                                                                 │
│  let component = Components[key["default_block"]];              │
│  // Components[1] = DefaultBlockComponent                       │
│                                                                 │
│  this.cmpRef = this.target.createComponent(factory);            │
│  Object.assign(this.cmpRef.instance, this.inputs);              │
│  // Prosleđuje items, model (REFERENCA!), output, ...           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.5: DefaultBlockComponent.ngOnInit()                   │
│  ═════════════════════════════════════════════                  │
│                                                                 │
│  if (!this.model[this.items.name])                              │
│    this.model[this.items.name] = {};                            │
│                                                                 │
│  // this.model = db.model (REFERENCA!)                          │
│  // this.items.name = "FlatpaketiPOTS"                          │
│  // PRIJE: db.model["FlatpaketiPOTS"] = null                    │
│  // Uslov !null = true, dakle izvršava se                       │
│  // EKVIVALENT: db.model["FlatpaketiPOTS"] = {}                 │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "FlatpaketiPOTS": {}  ← null zamjenjen sa {}!                │
│  }                                                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.6: DefaultBlock renderuje template sa elements        │
│  ════════════════════════════════════════════════════            │
│                                                                 │
│  <z-contentloader *ngFor="let element of items.elements"        │
│                   [items]="element"                             │
│                   [model]="model">  ← CIJELI MODEL!             │
│                                                                 │
│  Za element[0] ("Flat BH Telecom"), kreira ContentLoader       │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.7-5.8: ContentLoader → DLContent → BasicBlock         │
│  ═══════════════════════════════════════════════════            │
│                                                                 │
│  Isti proces kao 5.2-5.4, ali za "basic_block" template         │
│                                                                 │
│  let component = Components[key["basic_block"]];                │
│  // Components[0] = BasicBlockComponent                         │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.9: BasicBlockComponent.ngOnInit()                     │
│  ═══════════════════════════════════════                        │
│                                                                 │
│  if (!this.model[this.items.name])                              │
│    this.model[this.items.name] = {};                            │
│                                                                 │
│  // this.model = db.model (REFERENCA!)                          │
│  // this.items.name = "FlatBHTelecom"                           │
│  // PRIJE: db.model["FlatBHTelecom"] = null                     │
│  // Uslov !null = true, dakle izvršava se                       │
│  // EKVIVALENT: db.model["FlatBHTelecom"] = {}                  │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "FlatpaketiPOTS": {},                                        │
│    "loadOffer979": "5919",  ← dodan od select elementa          │
│    "FlatBHTelecom": {}  ← null zamjenjen sa {}!                 │
│  }                                                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.10: BasicBlock renderuje template sa inputs           │
│  ═════════════════════════════════════════════════              │
│                                                                 │
│  <z-contentloader *ngFor="let input of items.inputs"            │
│                   [items]="input"                               │
│                   [model]="model[items.name]"  ← NESTED DIO!    │
│                   [parent]="model">            ← CIJELI MODEL!  │
│                                                                 │
│  Za input[0] (FIRSTNAME):                                       │
│    model = db.model["Osnovnipaket-Fizicka"]  ← REFERENCA!       │
│    parent = db.model  ← REFERENCA!                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.11: ContentLoader.ngOnInit() - "FIRSTNAME"            │
│  ════════════════════════════════════════════                   │
│                                                                 │
│  items.template = "input"                                       │
│  model = db.model["Osnovnipaket-Fizicka"]  ← REFERENCA!         │
│                                                                 │
│  ValueManager.set(items, model, ...) → RADI! (je input)         │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.12: ValueManager.set() - POPUNJAVANJE!                │
│  ════════════════════════════════════════════                   │
│                                                                 │
│  field.name = "FIRSTNAME"                                       │
│  model = db.model["FlatBHTelecom"]  ← REFERENCA!                │
│  mod = "disabled"  ← KLJUČNO!                                   │
│                                                                 │
│  if (mod === 'disabled' || mod === 'preview') {                 │
│    // NE IZVRŠAVA SQL! Umjesto toga:                            │
│    model[field.name] = null;                                    │
│    // model["FIRSTNAME"] = null                                 │
│    return;                                                      │
│  }                                                              │
│                                                                 │
│  // SQL se ne izvršava jer je mod='disabled'                    │
│  // U normalnom modu (mod='new' ili 'edit'):                    │
│  // HTTP POST /uomback/common/lookupStatement                   │
│  //   sql: "select uomcommon.fgetFirstLastname(...)"            │
│  //   parameters: { P_CLASS_CODE: "ANALOG", P_CA_ID: 123 }     │
│  // Response: "Kenan" (ime iz baze)                             │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "FlatpaketiPOTS": {},                                        │
│    "loadOffer979": "5919",                                      │
│    "FlatBHTelecom": {                                           │
│      FIRSTNAME: null  ← null zbog disabled moda!                │
│    }                                                            │
│  }                                                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.13: DLContent kreira InputComponent                   │
│  ═════════════════════════════════════════                      │
│                                                                 │
│  let component = Components[key["input"]];                      │
│  // Components[8] = InputComponent                              │
│                                                                 │
│  Object.assign(inputInstance, {                                 │
│    items: { name: "FIRSTNAME", label: "Ime", ... },             │
│    model: db.model["FlatBHTelecom"]  ← REFERENCA!               │
│  });                                                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.14: InputComponent sa [(ngModel)] - TWO-WAY BINDING!  │
│  ══════════════════════════════════════════════════════         │
│                                                                 │
│  <input [(ngModel)]="model[items.name]">                        │
│         ↑                                                       │
│         └─ model["FIRSTNAME"]                                   │
│            = db.model["FlatBHTelecom"]["FIRSTNAME"]             │
│                                                                 │
│  Angular automatski:                                            │
│    1. Model → View: Prikazuje "" (prazan input jer je null)    │
│    2. View → Model: Kada korisnik mijenja, ažurira model        │
│                                                                 │
│  Korisnik upiše "Kenan":                                        │
│    Angular: model["FIRSTNAME"] = "Kenan"                        │
│    Pošto model = db.model["FlatBHTelecom"] (REF!)               │
│    Automatski: db.model["FlatBHTelecom"]["FIRSTNAME"]           │
│                = "Kenan"                                        │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "FlatpaketiPOTS": {},                                        │
│    "loadOffer979": "5919",                                      │
│    "FlatBHTelecom": {                                           │
│      FIRSTNAME: "Kenan"  ← UNIO KORISNIK!                       │
│    }                                                            │
│  }                                                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.15: Proces se ponavlja za SVA polja                   │
│  ═════════════════════════════════════════════                  │
│                                                                 │
│  Za SVAKI input (FIRSTNAME, NAME, JOBTITLE, ...):               │
│    1. ContentLoader.ngOnInit() → ValueManager.set()             │
│    2. DLContent → InputComponent                                │
│    3. InputComponent sa [(ngModel)]                             │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "FlatpaketiPOTS": {},                                        │
│    "loadOffer979": "5919",                                      │
│    "FlatBHTelecom": {                                           │
│      FIRSTNAME: null,        // ← null zbog disabled moda       │
│      NAME: null,                                                │
│      JOBTITLE: null,                                            │
│      PRIKLJUCAK_ADSL: null,                                     │
│      ACTION_PNK: null,                                          │
│      FRSEGSCLASS_CODE: null,                                    │
│      PUSER_EMAIL: null,                                         │
│      DEFAULTCONTACTPHONE: null,                                 │
│      OFFER_NAME: null,                                          │
│      DEFAULTCONTACTEMAIL: null,                                 │
│      PQUANTITY_NUM: null,                                       │
│      CCC_IND: null                                              │
│    }                                                            │
│  }                                                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  KORAK 5.16: Child elementi se renderuju                       │
│  ════════════════════════════════════════                       │
│                                                                 │
│  BasicBlock: <z-contentloader *ngFor="let children of           │
│                                        items.children">          │
│                                                                 │
│  Za children (Tarifni paketi, Zabrana info, ...):               │
│    Proces se ponavlja (KORAK 5.1-5.15)                          │
│                                                                 │
│  db.model = {                                                   │
│    auto: {},                                                    │
│    "FlatpaketiPOTS": {},                                        │
│    "loadOffer979": "5919",                                      │
│    "FlatBHTelecom": { ... },  // 12 fields sa null vrijednošću  │
│    "Preuzimanja": {},                                           │
│    "loadOffer164": null,                                        │
│    "Tarifnipaketi": {},                                         │
│    "loadOffer178": null,                                        │
│    "Zabranainformacija": {},                                    │
│    // ... ostali children ...                                   │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ↓
                ┌────────────────────┐
                │  db.model POPUNJEN! │
                └────────────────────┘
```

---

### KLJUČNI KONCEPTI - Rezime

```
┌─────────────────────────────────────────────────────────────────┐
│  1. REFERENCA, ne kopija!                                       │
│     ══════════════════════                                      │
│                                                                 │
│     Kada komponenta prima [model]="db.model", ona prima         │
│     POKAZIVAČ na isti objekat, ne kopiju.                       │
│                                                                 │
│     let original = { auto: {} };                                │
│     let referenca = original;  // REFERENCA!                    │
│     referenca["Osnovneusluge"] = {};                            │
│     console.log(original);                                      │
│     // { auto: {}, Osnovneusluge: {} }  ← Original se mijenja!  │
│                                                                 │
│     Sve promjene se automatski reflektuju u originalnom         │
│     db.model objektu!                                           │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  2. DefaultBlock vs BasicBlock                                  │
│     ═══════════════════════════                                 │
│                                                                 │
│     DefaultBlock prosleđuje djeci:                              │
│       [model]="model"  ← Cijeli model                           │
│                                                                 │
│     BasicBlock prosleđuje djeci:                                │
│       [model]="model[items.name]"  ← Nested dio                 │
│                                                                 │
│     Zato DefaultBlock i BasicBlock kreiraju nested objekte      │
│     na root nivou db.model, ali BasicBlock prosleđuje djeci     │
│     samo nested dio!                                            │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  3. Kreiranje nested objekata                                   │
│     ═══════════════════════════                                 │
│                                                                 │
│     DefaultBlock i BasicBlock u ngOnInit() kreiraju:            │
│                                                                 │
│     if (!this.model[this.items.name])                           │
│       this.model[this.items.name] = {};                         │
│                                                                 │
│     Ovo DIREKTNO modifikuje db.model zbog reference pattern-a! │
│                                                                 │
│     DefaultBlock: db.model["FlatpaketiPOTS"] = {}               │
│     BasicBlock: db.model["FlatBHTelecom"] = {}                  │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  4. DLContent - Dynamic Component Loader                        │
│     ════════════════════════════════════                        │
│                                                                 │
│     DLContent koristi key objekat da mapira template name →     │
│     Components array index:                                     │
│                                                                 │
│       const key = {                                             │
│         basic_block: 0,    // → BasicBlockComponent             │
│         default_block: 1,  // → DefaultBlockComponent           │
│         input: 8,          // → InputComponent                  │
│         select: 11,        // → SelectComponent                 │
│         ...                                                     │
│       };                                                        │
│                                                                 │
│     updateComponent() {                                         │
│       let component = Components[key[this.template]];           │
│       let factory = this.cfResolver                             │
│                     .resolveComponentFactory(component);        │
│       this.cmpRef = this.target.createComponent(factory);       │
│       Object.assign(this.cmpRef.instance, this.inputs);         │
│     }                                                           │
│                                                                 │
│     Dinamički kreira komponente na osnovu template property-ja! │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  5. ValueManager.set() - Inicijalizacija vrijednosti           │
│     ═════════════════════════════════════════════               │
│                                                                 │
│     ValueManager.set() radi SAMO za input komponente           │
│     (input, select, checkbox, textarea, date, ...)             │
│                                                                 │
│     NE radi za block komponente (default_block, basic_block)    │
│                                                                 │
│     Puni inicijalne vrijednosti iz:                             │
│       1. generationFormula (SQL via backend)                    │
│       2. defaultValue (statička vrijednost)                     │
│       3. mappingRef (iz parametara)                             │
│       4. fallback (prazan string ili false)                     │
│                                                                 │
│     Primjer:                                                    │
│       // Ako je db.mod='disabled' ili 'preview':                │
│       if (mod === 'disabled' || mod === 'preview') {            │
│         model[field.name] = null;  // NE izvršava SQL!          │
│         return;                                                 │
│       }                                                         │
│                                                                 │
│       // Ako je db.mod='new' ili 'edit' (normalan rad):         │
│       field.generationFormula =                                 │
│         "select uomcommon.fgetFirstLastname(...)"               │
│                                                                 │
│       this.dblookup(generationFormula, parameters)              │
│         .subscribe(result => {                                  │
│           model[field.name] = result;  // "Kenan" iz baze       │
│         });                                                     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  6. Angular [(ngModel)] - Two-Way Binding                       │
│     ══════════════════════════════════════                      │
│                                                                 │
│     [(ngModel)] je skraćenica za:                               │
│       [ngModel]="..." - property binding (Model → View)         │
│       (ngModelChange)="... = $event" - event (View → Model)     │
│                                                                 │
│     Angular automatski sinhronizuje:                            │
│       - Model → View: Prikazuje vrijednost u input polju        │
│       - View → Model: Ažurira model kada korisnik mijenja       │
│                                                                 │
│     Primjer:                                                    │
│       <input [(ngModel)]="model[items.name]">                   │
│                                                                 │
│       // Inicijalno: model["FIRSTNAME"] = null                  │
│       // Prikazuje prazan input                                 │
│                                                                 │
│       // Korisnik upisuje "Kenan"                               │
│       // Angular automatski:                                    │
│       model["FIRSTNAME"] = "Kenan"                              │
│       // Pošto model = db.model["FlatBHTelecom"] (REF!)         │
│       db.model["FlatBHTelecom"]["FIRSTNAME"] = "Kenan"          │
│                                                                 │
│     NEMA POTREBE ZA DODATNIM KODOM!                             │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  7. Redoslijed izvršavanja                                      │
│     ═══════════════════════                                     │
│                                                                 │
│     PageLoader →                                                │
│       ContentLoader.ngOnInit() →                                │
│         ContentLoader.template →                                │
│           DLContent.updateComponent() →                         │
│             Komponenta.ngOnInit() (DefaultBlock/BasicBlock) →   │
│               Komponenta.template →                             │
│                 ... (rekurzivno za djecu)                       │
│                                                                 │
│     Za SVE komponente:                                          │
│       1. Angular kreira instancu                                │
│       2. Angular postavlja @Input() properties                  │
│       3. Angular poziva ngOnInit()                              │
│       4. Angular renderuje template                             │
│       5. Template može kreirati nove komponente (ngFor, itd.)   │
│       6. Proces se ponavlja rekurzivno                          │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  8. Zašto se koristi ovaj složen sistem?                       │
│     ═══════════════════════════════════════                     │
│                                                                 │
│     - DINAMIČKA FORMA: Struktura forme dolazi sa backenda,     │
│       nije hardkodovana u template-u                            │
│                                                                 │
│     - REUSABLE KOMPONENTE: Ista komponenta (InputComponent)    │
│       se koristi za SVA input polja                             │
│                                                                 │
│     - ČIST KOD: Nema copy-paste koda za svako polje             │
│                                                                 │
│     - AUTOMATSKA SINHRONIZACIJA: Angular [(ngModel)] automatski │
│       ažurira db.model kada korisnik mijenja vrijednosti        │
│                                                                 │
│     - CENTRALIZOVANA LOGIKA: ValueManager.set() na jednom       │
│       mjestu upravlja inicijalizacijom svih polja               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Vizualni dijagram - Kompletan flow

```
┌─────────────────────────────────────────────────────────────────┐
│  ngOnInit()                                                     │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
         basketnum NE POSTOJI
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  getDynamic('validateinformations')                             │
│  ═══════════════════════════════════                            │
│                                                                 │
│  callback = 'validateinformations'                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  Provjera: orderEntrySetupRequests?                             │
└─────┬───────────────────────────────────────────┬───────────────┘
      │ DA                                        │ NE
      │                                           │
      ↓                                           ↓
┌──────────────────────┐          ┌────────────────────────────────┐
│ getGroupDynamic()    │          │  db.setmod(...)                │
│ (POST request)       │          │  → db.mod = 'new'              │
└──────────────────────┘          └────────────┬───────────────────┘
                                               │
                                               ↓
                          ┌─────────────────────────────────────────┐
                          │  HTTP GET /pcrt/order-entry             │
                          │  ═══════════════════════════            │
                          │  Query params:                          │
                          │  - interactionId: 16                    │
                          │  - productOfferId: "1174"               │
                          │  - productSpecificationId: "162"        │
                          │  - appProcessId: "10"                   │
                          │  - setupType: "SALES"                   │
                          └────────────┬────────────────────────────┘
                                       │
                                       ↓
                          ╔════════════════════════════════╗
                          ║  BACKEND                       ║
                          ║  ═══════                       ║
                          ║  /pcrt/order-entry             ║
                          ║                                ║
                          ║  - Pronađi formu za offer 1174 ║
                          ║  - Pronađi spec 162            ║
                          ║  - Builduje JSON strukturu:    ║
                          ║    "Osnovne usluge"            ║
                          ║    → "Osnovni paket- Fizicka"  ║
                          ║    → inputs, children...       ║
                          ╚════════════╦═══════════════════╝
                                       │
                                       ↓
                          ┌─────────────────────────────────────────┐
                          │  HTTP Response                          │
                          │  ════════════                           │
                          │  {                                      │
                          │    payload: {                           │
                          │      structure: [{                      │
                          │        label: "Osnovne usluge",         │
                          │        code: "162",                     │
                          │        elements: [{                     │
                          │          label: "Osnovni paket-Fizicka",│
                          │          inputs: [FIRSTNAME, NAME...]   │
                          │        }]                               │
                          │      }],                                │
                          │      parameters: { type: 100 }          │
                          │    }                                    │
                          │  }                                      │
                          └────────────┬────────────────────────────┘
                                       │
                                       ↓
                          ┌─────────────────────────────────────────┐
                          │  .subscribe() callback                  │
                          │  ══════════════════════                 │
                          │                                         │
                          │  1. this.structure = r.payload          │
                          │  2. db.update(db.params, merged)        │
                          │  3. this[callback]()                    │
                          └────────────┬────────────────────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
                    ↓                                     ↓
   ┌──────────────────────────────────┐  ┌────────────────────────────────┐
   │  this.structure populated        │  │  validateinformations()        │
   │  ═══════════════════════          │  │  ═══════════════════════       │
   │                                  │  │                                │
   │  structure.structure = [{        │  │  - Provjerava CA, BA, CONTACT  │
   │    label: "Osnovne usluge",      │  │  - Ako fali → warning          │
   │    code: "162",                  │  │  - Ako fali → location.back()  │
   │    template: "default_block",    │  │  - Ako OK → nastavlja          │
   │    elements: [{                  │  │                                │
   │      label: "Osnovni paket-      │  │                                │
   │             Fizicka",            │  │                                │
   │      code: "1174",               │  │                                │
   │      inputs: [FIRSTNAME,NAME..] │  │                                │
   │      children: [Tarifni paketi..]│  │                                │
   │    }]                            │  │                                │
   │  }]                              │  │                                │
   └──────────────┬───────────────────┘  └────────────────────────────────┘
                  │
                  ↓
   ┌─────────────────────────────────────────────────────────────────┐
   │  Template rendering                                             │
   │  ══════════════════                                             │
   │                                                                 │
   │  <z-pageloader *ngIf="structure"                                │
   │    [items]="structure.structure"                                │
   │    [model]="db.model"                                           │
   │    [output]="db.output"                                         │
   │    [parameters]="db.params">                                    │
   │  </z-pageloader>                                                │
   │                                                                 │
   │  → z-pageloader vidi structure                                  │
   │  → Renderuje dinamičku formu                                    │
   │  → Korisnik može unositi podatke                                │
   └─────────────────────────────────────────────────────────────────┘
                                 │
                                 ↓
                        ┌────────────────────┐
                        │  FORMA PRIKAZANA!  │
                        └────────────────────┘
```

---

## Ključne tačke za zapamtiti:

```
┌─────────────────────────────────────────────────────────────────┐
│  1. getDynamic() dohvata STRUKTURU forme sa backenda            │
│     → Struktura je JSON definicija polja, labela, validacije    │
│                                                                 │
│  2. db.setmod() postavlja mod ('disabled', 'new', 'edit',       │
│     'preview')                                                  │
│     → Mod kontroliše da li je forma disabled/enabled            │
│                                                                 │
│  3. API poziv je ASINHRON (Observable)                          │
│     → .subscribe() callback se izvršava KASNIJE                 │
│                                                                 │
│  4. db.params se merguje iz 3 izvora:                           │
│     - structure.parameters → { type: 100 }                      │
│     - this.params → { processId:"10", caId:"130025794"... }     │
│     - setparms() → { P_CA_ID, P_BA_ID, P_LOGGED_USER... }      │
│                                                                 │
│  5. Callback ('validateinformations') se poziva NAKON što       │
│     struktura stigne                                            │
│     → Validira da CA, BA, CONTACT postoje                       │
│                                                                 │
│  6. z-pageloader renderuje formu na osnovu structure.structure  │
│     → "Osnovne usluge" (default_block) → "Osnovni paket-       │
│       Fizicka" (basic_block) → inputs (FIRSTNAME, NAME...) →   │
│       children (Tarifni paketi, Zabrana info, Preuzimanja...)   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Ažurirano: 2026-02-06*
*Korak 1: Deklaracija komponente i index signature*
*Dodatak 1: Detaljno objašnjenje `this` ključne riječi*
*Korak 2: ngOnInit() - Startovanje komponente*
*Dodatak 2: Callback parametar u getDynamic()*
*Korak 3B: getDynamic() - Dohvatanje strukture forme*
