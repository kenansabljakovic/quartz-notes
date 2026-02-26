# AG Grid — Date Filter Vodic

> Ovaj dokument objasnjava kako funkcioniraju date filteri u AG Grid-u (verzija 30.2) u kontekstu ovog projekta koji koristi `@zff/grid` wrapper.

---

## 📌 Kontekst

Projekt koristi:
- **AG Grid 30.2** (`ag-grid-community`, `ag-grid-enterprise`, `ag-grid-angular`)
- **@zff/grid (v3.0.5)** kao wrapper oko AG Grid-a koji **mijenja defaultno ponasanje** filtera
- **ZxGrid** komponenta koja prima `GridOptions` i prosljedjuje ih AG Grid-u

---

## 🧅 Arhitektura (ZFF → AG Grid)

```
Tvoj kod (columnDefs / GridOptions)
        ↓
@zff/grid setPredefinedFilter()   ← Ovdje se mijenjaju filter defaulti
        ↓
<zx-grid [gridOptions]="...">
        ↓
AG Grid 30.2
```

> ⚠️ **@zff/grid intercepta kolone tipa `filter: "date"` i postavlja vlastite defaulte** — AG Grid "cisti" defaulti ne vaze direktno u ovom projektu.

---

## 📊 Stvarne default filter opcije u ovom projektu

Kada definiras kolonu sa `filter: "date"` **bez** `filterParams.filterOptions`, `@zff/grid` hardkodira sljedece opcije:

| Opcija | Dostupna |
|--------|----------|
| `equals` | ✅ |
| `lessThan` | ✅ |
| `lessThanOrEqual` | ✅ |
| `greaterThan` | ✅ |
| `greaterThanOrEqual` | ✅ |
| `notEqual` | ❌ iskljucen u @zff/grid |
| `inRange` | ❌ iskljucen u @zff/grid |
| `blank` | ❌ iskljucen u @zff/grid |
| `notBlank` | ❌ iskljucen u @zff/grid |

Takodje, `@zff/grid` forsira `maxNumConditions: 1` — korisnik ne moze kombinovati dva uslova (AND/OR).

### Zasto — izvorni kod @zff/grid

U `/node_modules/@zff/grid/fesm2022/zff-grid.mjs`, funkcija `setPredefinedFilter()` za tip `date`:

```javascript
date: {
    filter: 'agDateColumnFilter',
    filterParams: {
        ...{ filterOptions: ['equals', 'lessThan', 'lessThanOrEqual', 'greaterThan', 'greaterThanOrEqual'] },
        ...col.filterParams,        // ← tvoj filterParams ide OVDJE i moze override-ati
        ...filterComparator('date', gridOptions),
        ...{ maxNumConditions: 1 }, // ← ovo ide NA KRAJU i ne moze se override-ati ovako
    },
    ...
}
```

> ⚠️ **Napomena o `maxNumConditions`**: Posto se `maxNumConditions: 1` spread-a **nakon** `col.filterParams`, override iz tvog koda **nece raditi** — @zff/grid ce ga uvijek pregaziti nazad na `1`.

---

## ✅ Sve dostupne opcije za `filter: "date"` (AG Grid 30.2)

Ovo su sve opcije koje AG Grid 30.2 podrzava za date filtere (mogu se koristiti u `filterOptions`):

| Opcija | Opis |
|--------|------|
| `equals` | Tacan datum |
| `notEqual` | Nije taj datum |
| `lessThan` | Prije datuma (striktno) |
| `lessThanOrEqual` | Prije datuma ili jednako |
| `greaterThan` | Posle datuma (striktno) |
| `greaterThanOrEqual` | Posle datuma ili jednako |
| `inRange` | **Od - do (range filter)** |
| `blank` | Prazno polje |
| `notBlank` | Nije prazno |

---

## 🔧 Kako dodati `inRange` ("od - do")

Posto je `col.filterParams` spread-an **nakon** hardkodiranih @zff/grid opcija, tvoj `filterParams` ih moze zamijeniti. Medutim, `filterOptions` je **zamjena, ne dopuna** — kada ga postavis, koriste se iskljucivo navedene opcije.

**Nema nacina da se "doda" samo jedna opcija bez navodenja cijele liste.**

### Primjer za dodavanje `inRange` uz ostale opcije:

```typescript
{
  field: "created",
  headerName: "Datum kreiranja",
  filter: "date",
  valueFormatter: (x: any) => this.ds.formatDateForGrid(x),
  sort: 'desc',
  initialSortIndex: 1,
  filterParams: {
    filterOptions: ['equals', 'lessThan', 'lessThanOrEqual', 'greaterThan', 'greaterThanOrEqual', 'inRange']
    // Mora se navesti CIJELA lista — ne moze se samo dodati 'inRange'
  }
}
```

---

## 📋 `filterParams` opcije za date

### `filterOptions`
Niz opcija koje se prikazuju u filter dropdown-u. Ovo je **kompletna zamjena** defaultne liste.

```typescript
filterParams: {
  filterOptions: ['equals', 'lessThan', 'lessThanOrEqual', 'greaterThan', 'greaterThanOrEqual', 'inRange']
}
```

### `defaultOption`
Koja opcija je unaprijed odabrana kad se otvori filter. Default je `'equals'`.

```typescript
filterParams: {
  filterOptions: ['equals', 'inRange'],
  defaultOption: 'inRange'  // ← inRange ce biti selektovan po defaultu
}
```

### `inRangeInclusive`
Kada je `true`, "od" i "do" datumi su **ukljuceni** u rezultat.

```typescript
filterParams: {
  filterOptions: ['inRange'],
  inRangeInclusive: true   // ← 01.01.2025 - 31.01.2025 ukljucuje i ta dva datuma
}
```

Bez ovoga (default `false`), filtriranje je striktno:
- `dateFrom < cellValue < dateTo`

Sa `inRangeInclusive: true`:
- `dateFrom <= cellValue <= dateTo`

### `comparator`
Custom funkcija za poredjenje datuma. Potrebna kada datumi nisu JS `Date` objekti (npr. string formati).

```typescript
filterParams: {
  filterOptions: ['equals', 'lessThan', 'lessThanOrEqual', 'greaterThan', 'greaterThanOrEqual', 'inRange'],
  comparator: (filterLocalDateAtMidnight: any, cellValue: any) =>
    this.ds.gridFilterComparator(filterLocalDateAtMidnight, cellValue)
}
```

### `includeBlanksInRange`
Ako `true`, prazne vrijednosti prolaze kroz `inRange` filter.

```typescript
filterParams: {
  filterOptions: ['inRange'],
  includeBlanksInRange: true
}
```

---

## 🆚 Razlika: default vs eksplicitno

### Bez `filterParams` (default — @zff/grid defaulti):
```typescript
{field: "created", filter: "date", ...}
// Prikazuje: equals, lessThan, lessThanOrEqual, greaterThan, greaterThanOrEqual
// inRange NIJE dostupan!
// maxNumConditions je 1 (jedan uslov)
```

### Sa `filterParams.filterOptions`:
```typescript
{
  field: "created",
  filter: "date",
  filterParams: {
    filterOptions: ['equals', 'lessThan', 'lessThanOrEqual', 'greaterThan', 'greaterThanOrEqual', 'inRange']
  }
}
// Prikazuje SAMO navedene opcije, ukljucujuci inRange ✅
```

---

## 🎨 Kako izgleda `inRange` filter u UI-ju

```
┌─────────────────────────────────┐
│ Datum kreiranja                 │
├─────────────────────────────────┤
│ Filter: [inRange ▼]             │
├─────────────────────────────────┤
│ Od:  [📅 01.01.2025]           │
│ Do:  [📅 31.01.2025]           │
├─────────────────────────────────┤
│ [Primijeni] [Obriši]            │
└─────────────────────────────────┘
```

---

## 📝 Korisne napomene

1. **@zff/grid mijenja AG Grid date filter defaulte** — cistih AG Grid defaulta nema, uvijek prolaze kroz `setPredefinedFilter()` u @zff/grid
2. **`inRange` mora biti eksplicitno dodan** — iskljucen je u @zff/grid defaultima
3. **`filterOptions` je zamjena, ne dopuna** — mora se navesti cijela lista zeljenih opcija
4. **`maxNumConditions: 1` je forsiran od @zff/grid** i ne moze se override-ati iz column definicije
5. **Server-side filtering**: Ako grid koristi `rowModelType: 'serverSide'`, backend mora obraditi `inRange` filter parametre (`dateFrom` i `dateTo`)

---

## 🔗 Reference

- [AG Grid Date Filter (v30.1)](https://ag-grid.com/archive/30.1.0/angular-data-grid/filter-date)
- [AG Grid Filter Conditions (v30.1)](https://ag-grid.com/archive/30.1.0/angular-data-grid/filter-conditions)
