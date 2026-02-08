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
