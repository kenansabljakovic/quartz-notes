# JAVASCRIPT TRUTHY & FALSY VRIJEDNOSTI

**Datum:** 2026-02-06
**Svrha:** Razumijevanje koje vrijednosti se evaluiraju kao `true` ili `false` u boolean kontekstu

---

## SADRŽAJ

1. [FALSY Vrijednosti](#falsy-vrijednosti)
2. [TRUTHY Vrijednosti](#truthy-vrijednosti)
3. [Praktični Primjeri](#praktični-primjeri)
4. [Logički Operatori](#logički-operatori)
5. [Česte Greške](#česte-greške)

---

# FALSY VRIJEDNOSTI

## Definicija

**FALSY** vrijednosti su vrijednosti koje se automatski konvertuju u `false` kada se koriste u boolean kontekstu (if statement, ternary operator, logički operatori).

## 8 FALSY VRIJEDNOSTI (sve ostalo je TRUTHY)

```javascript
┌──────────────┬─────────────────┬──────────────────────────────────────────┐
│ #  │ VALUE   │ TYPE            │ OPIS                                     │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 1  │ false   │ Boolean         │ Boolean false vrijednost                 │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 2  │ 0       │ Number          │ Broj nula                                │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 3  │ -0      │ Number          │ Negativna nula (rijetko se koristi)      │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 4  │ 0n      │ BigInt          │ BigInt nula                              │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 5  │ ""      │ String          │ Prazan string (nema karaktera)           │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 6  │ null    │ Null            │ Eksplicitno "ništa"                      │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 7  │ undefined│ Undefined       │ Nedefinisana vrijednost                  │
├────┼─────────┼─────────────────┼──────────────────────────────────────────┤
│ 8  │ NaN     │ Number          │ Not a Number (rezultat nevažeće operacije)│
└────┴─────────┴─────────────────┴──────────────────────────────────────────┘
```

---

## TESTIRANJE FALSY VRIJEDNOSTI

### 1. false

```javascript
false               // boolean false

// Testiranje:
Boolean(false)      // false
!false              // true
!!false             // false

// U if statement-u:
if (false) {
  // NIKADA se ne izvršava
}
```

---

### 2. 0 (broj nula)

```javascript
0                   // broj nula

// Testiranje:
Boolean(0)          // false
!0                  // true
!!0                 // false

// U if statement-u:
if (0) {
  // NIKADA se ne izvršava
}

// Praktično:
let count = 0;
if (count) {
  console.log("Ima stavki");
} else {
  console.log("Nema stavki");  // ← Izvršava se
}
```

---

### 3. -0 (negativna nula)

```javascript
-0                  // negativna nula (ista kao 0)

// Testiranje:
Boolean(-0)         // false
!(-0)               // true
!!(-0)              // false

// Napomena:
0 === -0            // true (identične)
Object.is(0, -0)    // false (tehnički različite, ali rijetko bitno)
```

---

### 4. 0n (BigInt nula)

```javascript
0n                  // BigInt nula

// Testiranje:
Boolean(0n)         // false
!0n                 // true
!!0n                // false

// Napomena:
0n === 0            // false (različiti tipovi)
0n == 0             // true (loose equality konvertuje)
```

---

### 5. "" (prazan string)

```javascript
""                  // prazan string (nula karaktera)

// Testiranje:
Boolean("")         // false
!""                 // true
!!""                // false

// U if statement-u:
if ("") {
  // NIKADA se ne izvršava
}

// Praktično:
let name = "";
if (name) {
  console.log("Ime postoji");
} else {
  console.log("Ime je prazno");  // ← Izvršava se
}

// Provjera length-a:
"".length           // 0 (također falsy)
```

---

### 6. null

```javascript
null                // eksplicitno "ništa"

// Testiranje:
Boolean(null)       // false
!null               // true
!!null              // false

// typeof:
typeof null         // "object" ⚠️ BUG u JavaScript-u!

// U if statement-u:
if (null) {
  // NIKADA se ne izvršava
}

// Praktično:
let user = null;    // eksplicitno postavljeno na "nema vrijednosti"
if (user) {
  console.log("User postoji");
} else {
  console.log("User ne postoji");  // ← Izvršava se
}
```

---

### 7. undefined

```javascript
undefined           // nedefinisana vrijednost

// Testiranje:
Boolean(undefined)  // false
!undefined          // true
!!undefined         // false

// typeof:
typeof undefined    // "undefined"

// U if statement-u:
if (undefined) {
  // NIKADA se ne izvršava
}

// Praktično:
let basket = {};
basket.save         // undefined (property ne postoji)

if (basket.save) {
  console.log("Basket je spašen");
} else {
  console.log("Basket nije spašen");  // ← Izvršava se
}

// Razlika null vs undefined:
null === undefined       // false (različiti tipovi)
null == undefined        // true (loose equality)
```

---

### 8. NaN (Not a Number)

```javascript
NaN                 // rezultat nevažeće matematičke operacije

// Testiranje:
Boolean(NaN)        // false
!NaN                // true
!!NaN               // false

// typeof:
typeof NaN          // "number" ⚠️ Čudno, ali NaN je tip Number

// U if statement-u:
if (NaN) {
  // NIKADA se ne izvršava
}

// ⚠️ TRICKY - NaN nije jednak sam sebi!
NaN === NaN         // false (JEDINA vrijednost koja nije === sebi!)
NaN == NaN          // false

// Ispravna provjera za NaN:
isNaN(NaN)              // true
Number.isNaN(NaN)       // true (preporučeno)

// Kako dobiti NaN:
parseInt("tekst")       // NaN
0 / 0                   // NaN
Math.sqrt(-1)           // NaN
"broj" * 5              // NaN
```

---

# TRUTHY VRIJEDNOSTI

## Definicija

**TRUTHY** vrijednosti su **SVE vrijednosti koje NISU na listi od 8 FALSY vrijednosti**.

Automatski se konvertuju u `true` u boolean kontekstu.

---

## LISTA TRUTHY VRIJEDNOSTI

```javascript
┌─────────────────────────────┬──────────────────────────────────────────┐
│ KATEGORIJA                  │ PRIMJERI                                 │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Boolean                     │ true                                     │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Brojevi (osim 0, -0, 0n)    │ 1, -1, 3.14, -99, 0.1, Infinity,        │
│                             │ -Infinity, 100n                          │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Stringovi (osim "")         │ "text", "0", "false", " " (razmak)       │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Objekti                     │ {}, {name: "John"}                       │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Array-evi                   │ [], [1,2,3], [null]                      │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Funkcije                    │ function() {}, () => {}                  │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Date objekti                │ new Date()                               │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Regularne ekspresije        │ /regex/                                  │
├─────────────────────────────┼──────────────────────────────────────────┤
│ Symbol                      │ Symbol("id")                             │
└─────────────────────────────┴──────────────────────────────────────────┘
```

---

## TRUTHY PRIMJERI

### 1. Boolean true

```javascript
true                // boolean true

Boolean(true)       // true
!true               // false
!!true              // true

if (true) {
  // UVIJEK se izvršava
}
```

---

### 2. Brojevi (osim 0)

```javascript
// Pozitivni brojevi:
1                   // truthy
100                 // truthy
3.14                // truthy
0.0001              // truthy

// Negativni brojevi:
-1                  // truthy
-999                // truthy

// Specijalni brojevi:
Infinity            // truthy
-Infinity           // truthy

// BigInt (osim 0n):
1n                  // truthy
-5n                 // truthy

// Testiranje:
Boolean(1)          // true
!1                  // false
!!42                // true

if (5) {
  console.log("Broj 5 je truthy");  // ← Izvršava se
}
```

---

### 3. Stringovi (osim "")

```javascript
// Bilo koji string sa sadržajem:
"text"              // truthy
"hello"             // truthy
"   "               // truthy (razmak je karakter!)

// ⚠️ TRICKY - ovi stringovi su TRUTHY:
"0"                 // truthy (string, ne broj!)
"false"             // truthy (string, ne boolean!)
"null"              // truthy (string, ne null!)
"undefined"         // truthy (string, ne undefined!)

// Testiranje:
Boolean("text")     // true
!"hello"            // false
!!"abc"             // true

// Primjer:
if ("0") {
  console.log("String '0' je truthy!");  // ← Izvršava se
}

if ("false") {
  console.log("String 'false' je truthy!");  // ← Izvršava se
}
```

---

### 4. Objekti (uvijek truthy, čak i prazni)

```javascript
// Prazan objekat:
{}                  // truthy ⚠️ TRICKY!

// Objekat sa propertyima:
{name: "John"}      // truthy
{value: 0}          // truthy (objekat je truthy, čak i kad property nije)

// Testiranje:
Boolean({})         // true
!{}                 // false
!!{name: "A"}       // true

// U if statement-u:
if ({}) {
  console.log("Prazan objekat je truthy!");  // ← Izvršava se
}

// ⚠️ GREŠKA - provjera praznog objekta:
let obj = {};
if (obj) {
  // Izvršava se, iako je objekat prazan!
}

// ✅ ISPRAVNO - provjera da li objekat ima properties:
if (Object.keys(obj).length > 0) {
  // NE izvršava se za prazan objekat
}
```

---

### 5. Array-evi (uvijek truthy, čak i prazni)

```javascript
// Prazan array:
[]                  // truthy ⚠️ TRICKY!

// Array sa elementima:
[1, 2, 3]           // truthy
[null]              // truthy (array je truthy, čak i sa falsy elementima)
[false, 0, ""]      // truthy

// Testiranje:
Boolean([])         // true
![]                 // false
!![1, 2]            // true

// U if statement-u:
if ([]) {
  console.log("Prazan array je truthy!");  // ← Izvršava se
}

// ⚠️ GREŠKA - provjera praznog array-a:
let arr = [];
if (arr) {
  // Izvršava se, iako je array prazan!
}

// ✅ ISPRAVNO - provjera length-a:
if (arr.length > 0) {
  // NE izvršava se za prazan array
}

// ILI:
if (arr.length) {
  // NE izvršava se (0 je falsy)
}
```

---

### 6. Funkcije

```javascript
// Function declaration:
function foo() {}   // truthy

// Function expression:
let bar = function() {};  // truthy

// Arrow function:
let baz = () => {};       // truthy

// Testiranje:
Boolean(foo)        // true
!foo                // false

if (foo) {
  console.log("Funkcija je truthy");  // ← Izvršava se
}
```

---

### 7. Date objekti

```javascript
new Date()          // truthy
new Date("invalid") // truthy (čak i invalid date!)

Boolean(new Date()) // true

if (new Date()) {
  console.log("Date objekat je truthy");  // ← Izvršava se
}
```

---

### 8. Ostale truthy vrijednosti

```javascript
// Regular expressions:
/regex/             // truthy

// Symbol:
Symbol("id")        // truthy

// Error objekti:
new Error("msg")    // truthy
```

---

# PRAKTIČNI PRIMJERI

## Primjer 1: basket.save provjera (iz našeg koda)

```javascript
// POČETNO STANJE:
let basket = {};              // Prazan objekat
basket.save                   // undefined (property ne postoji)

// PROVJERA:
!basket.save                  // !undefined = true
                              // Basket NIJE spašen

// U ternary operator-u:
!this.basket.save ? "disabled" : "enabled"
↑
true → vraća "disabled"


// NAKON PRVOG SAVE-a:
basket.save = true;

// PROVJERA:
!basket.save                  // !true = false
                              // Basket JE spašen

// U ternary operator-u:
!this.basket.save ? "disabled" : "enabled"
↑
false → vraća "enabled"
```

---

## Primjer 2: Default vrijednosti sa ||

```javascript
// Ako je user.name falsy, koristi "Gost"
let name = user.name || "Gost";

// Evaluacija:
user.name = undefined
undefined || "Gost"  → "Gost"

user.name = ""
"" || "Gost"         → "Gost"

user.name = "Marko"
"Marko" || "Gost"    → "Marko"

user.name = 0
0 || "Gost"          → "Gost" ⚠️ Problem ako 0 je validna vrijednost!


// Bolji način (nullish coalescing):
let name = user.name ?? "Gost";
// Zamjenjuje samo null ili undefined, ne i 0 ili ""
```

---

## Primjer 3: Provjera array length-a

```javascript
let items = [];

// ❌ LOŠE:
if (items) {
  console.log("Ima stavki");  // ← Izvršava se! (prazan array je truthy)
}

// ✅ DOBRO:
if (items.length) {
  console.log("Ima stavki");  // NE izvršava se (0 je falsy)
}

// ✅ EKSPLICITNO:
if (items.length > 0) {
  console.log("Ima stavki");  // NE izvršava se
}
```

---

## Primjer 4: Provjera string-a

```javascript
let input = "";

// ❌ LOŠE (ako "0" je validan unos):
if (input) {
  console.log("Unos postoji");  // NE izvršava se za ""
}

// ✅ DOBRO (eksplicitna provjera):
if (input !== "") {
  console.log("Unos postoji");
}

// ILI:
if (input.length > 0) {
  console.log("Unos postoji");
}
```

---

# LOGIČKI OPERATORI

## Operator ! (NOT)

```javascript
// Invertuje boolean vrijednost:
!true               // false
!false              // true

// Sa falsy vrijednostima:
!0                  // true
!""                 // true
!null               // true
!undefined          // true
!NaN                // true

// Sa truthy vrijednostima:
!1                  // false
!"text"             // false
![]                 // false
!{}                 // false
```

---

## Operator !! (Double NOT)

```javascript
// Konvertuje u boolean (isto kao Boolean()):
!!true              // true
!!false             // false

!!0                 // false
!!1                 // true
!!""                // false
!!"text"            // true
!![]                // true
!!{}                // true
!!null              // false
!!undefined         // false
!!NaN               // false

// Ekvivalentno:
!!value === Boolean(value)  // true (uvijek)
```

---

## Operator || (OR)

```javascript
// Vraća PRVU TRUTHY vrijednost, ili ZADNJU ako su sve falsy

// Primjeri:
false || "text"             // "text" (prva truthy)
0 || 1                      // 1 (prva truthy)
"" || "default"             // "default" (prva truthy)
null || undefined || "A"    // "A" (prva truthy)

// Sve falsy:
false || 0 || ""            // "" (zadnja falsy)
null || undefined           // undefined (zadnja falsy)

// Praktično - default vrijednosti:
let name = userName || "Anonimus";
let count = userCount || 0;
```

---

## Operator && (AND)

```javascript
// Vraća PRVU FALSY vrijednost, ili ZADNJU ako su sve truthy

// Primjeri:
true && "text"              // "text" (sve truthy, vraća zadnju)
"text" && 0                 // 0 (prva falsy)
1 && 2 && 3                 // 3 (sve truthy, vraća zadnju)
"A" && null && "B"          // null (prva falsy)

// Sve falsy:
false && 0                  // false (prva falsy)
null && undefined           // null (prva falsy)

// Praktično - conditional execution:
user && user.name && console.log(user.name);
// Izvršava console.log samo ako user i user.name postoje
```

---

## Operator ?? (Nullish Coalescing)

```javascript
// Vraća desnu stranu samo ako je lijeva null ili undefined
// (ne provjera sve falsy vrijednosti)

// Primjeri:
null ?? "default"           // "default"
undefined ?? "default"      // "default"

// Razlika od ||:
0 ?? "default"              // 0 (0 nije null/undefined)
"" ?? "default"             // "" ("" nije null/undefined)
false ?? "default"          // false

// Poređenje:
0 || "default"              // "default" (0 je falsy)
0 ?? "default"              // 0 (0 nije null/undefined)

"" || "default"             // "default" ("" je falsy)
"" ?? "default"             // "" ("" nije null/undefined)
```

---

# ČESTE GREŠKE

## Greška 1: Prazan objekat/array

```javascript
// ❌ LOŠE:
let obj = {};
if (obj) {
  console.log("Objekat postoji");  // Uvijek se izvršava!
}

// ✅ DOBRO:
if (Object.keys(obj).length > 0) {
  console.log("Objekat ima properties");
}


// ❌ LOŠE:
let arr = [];
if (arr) {
  console.log("Array postoji");  // Uvijek se izvršava!
}

// ✅ DOBRO:
if (arr.length > 0) {
  console.log("Array ima elemente");
}
```

---

## Greška 2: String brojevi

```javascript
// ❌ LOŠE:
let stringNum = "0";
if (stringNum) {
  console.log("Broj postoji");  // Izvršava se! (string "0" je truthy)
}

// ✅ DOBRO:
if (Number(stringNum)) {
  console.log("Broj postoji");  // NE izvršava se (Number("0") = 0)
}

// ILI:
if (parseInt(stringNum, 10) !== 0) {
  console.log("Broj postoji");
}
```

---

## Greška 3: String "false"

```javascript
// ❌ LOŠE:
let value = "false";
if (value) {
  console.log("True");  // Izvršava se! (string "false" je truthy)
}

// ✅ DOBRO:
if (value === "true") {
  console.log("True");
}

// ILI konvertuj u boolean:
if (value === "true" || value === true) {
  console.log("True");
}
```

---

## Greška 4: NaN provjera

```javascript
// ❌ LOŠE:
let result = NaN;
if (result === NaN) {
  console.log("NaN");  // NIKADA se ne izvršava! (NaN !== NaN)
}

// ✅ DOBRO:
if (Number.isNaN(result)) {
  console.log("NaN");  // Izvršava se
}

// ILI:
if (isNaN(result)) {
  console.log("NaN");  // Izvršava se
}
```

---

## Greška 5: 0 kao validna vrijednost

```javascript
// ❌ LOŠE (ako 0 je validan broj):
let count = 0;
let displayCount = count || "Nema";
// displayCount = "Nema" (0 je falsy, pa koristi default)

// ✅ DOBRO:
let displayCount = count ?? "Nema";
// displayCount = 0 (0 nije null/undefined)

// ILI:
let displayCount = typeof count === 'number' ? count : "Nema";
```

---

# CHEAT SHEET

```
╔═══════════════════════════════════════════════════════════════════╗
║                    8 FALSY VRIJEDNOSTI                            ║
╠═══════════════════════════════════════════════════════════════════╣
║  false  │  0  │  -0  │  0n  │  ""  │  null  │  undefined  │  NaN  ║
╚═══════════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════════╗
║                    TRUTHY (sve ostalo)                            ║
╠═══════════════════════════════════════════════════════════════════╣
║  true, brojevi≠0, stringovi≠"", [], {}, funkcije, Date, Symbol   ║
╚═══════════════════════════════════════════════════════════════════╝

OPERATORI:
  !value        - invertuje (true→false, false→true)
  !!value       - konvertuje u boolean (isto kao Boolean(value))
  a || b        - vraća prvu TRUTHY ili zadnju
  a && b        - vraća prvu FALSY ili zadnju
  a ?? b        - vraća b samo ako je a null ili undefined

TRICKY:
  [] je TRUTHY      (ali [].length je 0, što je FALSY)
  {} je TRUTHY      (ali Object.keys({}).length je 0, što je FALSY)
  "0" je TRUTHY     (string, ne broj)
  "false" je TRUTHY (string, ne boolean)
  NaN !== NaN       (koristiti Number.isNaN())
  typeof null === "object" (legacy bug)
```

---

*Ažurirano: 2026-02-06*
