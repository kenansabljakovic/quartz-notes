# Customer Overview Modul — Detaljni Vodic za Juniore

> Ovaj dokument objasnjava kako funkcionira `customer-overview` modul, koji je srce aplikacije. Koristi se za prikaz 360° pregleda klijenta.

---

## 📍 Kako se dolazi do ove stranice?

```
app-routing.module.ts (linija 15):
  path: 'customer' → lazy load CustomerModule
```

Kada korisnik ide na `/customer360/customer/search`:

1. Angular provjerava da li je ulogovan (`OAuthGuard`)
2. Lazy loaduje `CustomerModule` (prvi put kad se koristi)
3. Renderuje `CustomerOverview` komponentu (child ruta `search`)

---

## 🎨 Sta se renderuje prvo? Layout

`customer-overview.component.html` je ultra jednostavan — samo 3 dijela:

```
┌──────────────────────────────────────────────────┐
│  <app-customer-search>                           │
│  Forma za pretragu + grid sa rezultatima         │
├──────────────────────────────────────────────────┤
│  <customer-services>  (*ngIf="selected.caId")    │
│  360 view (pojavi se tek kad se izabere klijent) │
├──────────────────────────────────────────────────┤
│  "Kreiraj novu interakciju" dugme (desno)        │
└──────────────────────────────────────────────────┘
```

**Kljucna logika**: `*ngIf="customer.selected.caId"` znaci:
- Dok se ne odabere klijent → vidis **samo pretragu**
- Kad se izabere klijent → prikazuje se i **360 view**

---

## 🔍 Tok Pretrage

Evo koraka kada korisnik pretrazi klijenta:

```
1. Korisnik unese podatke u formu
           ↓
2. Klik "Pretrazi" → search() metoda (linija 199 u search component-u)
           ↓
3. Validacija (min 3 karaktera, ispravni identifikacijski podaci, itd.)
           ↓
4. Priprema filtera → prepareSearchFilters() (linija 306)
           ↓
5. Set API endpoint → CustomersGridApi = CustomerApi.CUSTOMER_SEARCH
           ↓
6. ZxGrid automatski pozove API sa filterima (server-side pagination)
           ↓
7. Rezultati se prikazu u AG Grid tabeli
           ↓
8. Korisnik klikne na red → onCellClicked() (linija 693)
           ↓
9. customer.selected = izabrani klijent
           ↓
10. *ngIf="customer.selected.caId" postaje TRUE
           ↓
11. <customer-services> se renderuje → 360 view se otvara
```

### Nivoi pretrage

**Osnovni filteri** (vidljivi odmah):
- Korisnik (Ime i prezime)
- Username

**Dodatni filteri** (klik "Jos filtera"):
- CA (Customer Account)
- BA (Billing Account)
- Tehnologija
- Klasa
- Adresa
- ICCID
- IMSI
- IBFU
- I mnogo vise...

---

## 🎯 360 View (`Customer360Component`)

Kada se izabere klijent, renderuje se `customer360.component.html`:

```
┌────────────────┬──────────────────────────────────┐
│                │                                  │
│  MENU (lijevo) │  SADRZAJ (desno)                 │
│                │  Zavisi od toga koji meni        │
│                │  je kliknut                      │
│ ┌────────────┐ │                                  │
│ │360 Pregled │ │  billing / threesixty /          │
│ │Billing     │ │  bonus / tem-views /             │
│ │TEM Views   │ │  technical-details /             │
│ │TEM Actions │ │  eloqua / wfms /                 │
│ │...         │ │  webshop / report-overview       │
│ └────────────┘ │                                  │
└────────────────┴──────────────────────────────────┘
```

### Kako funkcionira izbor menija

```
1. Korisnik klikne na stavku menija
           ↓
2. MenuComponent.execMenu() ili showView()
           ↓
3. Pozove ZxAction: action['selectedMenu']('BASIC_SERVICE')
           ↓
4. Customer360Component hvata taj event (linija 21 u .ts):
   action.set('selectedMenu', (item) => this.changeSelectedView(item))
           ↓
5. selectedComponent = 'BASIC_SERVICE' (ili 'BILLING', 'WFMS', itd.)
           ↓
6. U HTML-u, *ngIf i [style.display] kontrolisu koja komponenta se prikazuje
           ↓
7. Odgovrajuca komponenta se renderuje (BillingComponent, etc.)
```

---

## 🧠 Centralni Servis (`Customer360Service`)

Ovo je **"mozak"** cijelog modula. On drzi sve globalno stanje za 360 view.

### Glavna svojstva (properties)

| Property | Tip | Sta cuva |
|----------|-----|----------|
| `selected` | Object | Trenutno izabrani klijent (caId, baId, userId, caName...) |
| `customerDetail` | Object | Detaljni podaci klijenta (ime, adresa, loyalscore, interactionCount...) |
| `details` | Array | Tehnicki detalji (linecode, pair, switch, networkgroup...) |
| `zimbraDetails` | Array | Zimbra email podaci (quota, storage...) |
| `radiusModel` | Array | Radius profil podaci |
| `TEM_VIEWS` | Array | Lista TEM view-ova (dinamicki dio menija) |
| `TEM_ACTIONS` | Array | Lista TEM akcija (drugi dio menija) |
| `baggData` | Array | BAGG podaci za klijenta |
| `basicServicesParams` | Object | Filter parametri za osnovne usluge |

### Helper metode (vazne!)

Ove metode kontrolisu koji dijelovi UI se prikazuju:

```typescript
// Prikazujem kartice (billing)?
cs.showAnalyitcCard(selectedComponent) // true/false

// Prikazujem WFMS?
cs.showWFMS(selectedComponent) // true/false

// Prikazujem Webshop?
cs.showWebshop(selectedComponent) // true/false

// Skrivam tab ako tehnologija ne odgovara?
cs.setClass(component, data) // 'not-fix-tech' ili undefined

// Je li TEM view ili akcija?
cs.checkIfTemView(component) // true/false
cs.checkIfTemAction(component) // true/false
```

### Glavne akcije (metode koje vuce podatke)

```typescript
getCustomerDetails(value)        // Povuci sve detaljne podatke klijenta
getZimbraData()                  // Povuci Zimbra email podatke
getRadiusData()                  // Povuci Radius profil
getTemViews()                    // Povuci TEM views iz registry-ja
getTemActions()                  // Povuci TEM actions
getInteractionsCount()           // Brojac interakcija
getLoyalScore()                  // Loyalty score klijenta
```

---

## 🔗 Kako komponente komuniciraju?

U ovoj aplikaciji ima 3 glavna mehanizma komunikacije:

### 1. **DIREKTNO preko servisa** (najcesci nacin)

Komponenta A pise podatke:
```typescript
this.customer.selected = noviKlijent;
this.customer.customerDetail = detalji;
```

Komponenta B cita podatke:
```typescript
<div *ngIf="customer.selected.caId">
  {{ customer.customerDetail.caName }}
</div>
```

### 2. **ZxAction — Event Bus** (labava veza)

Komponenta A emituje event:
```typescript
this.action['selectedMenu']('BILLING');
```

Komponenta B sluša event:
```typescript
this.action.set('selectedMenu', (item) => {
  this.changeSelectedView(item);
});
```

**Prednost**: Komponente ne trebaju znati jedna za drugu.

### 3. **@Input binding** (parent → child)

Roditelj prosljedjuje podatke:
```html
<customer-services [selectedCustomer]="customer.selected.caId">
</customer-services>
```

Dijete prima podatke:
```typescript
@Input() selectedCustomer?: string;
```

---

## 🏗️ Gradivni blokovi (ZFF komponente)

Svaka stranica koristi iste ZFF blokove kao Lego kockice:

| Blok | Sta radi | Gdje vidis |
|------|----------|-----------|
| `ZxBlock` | Okvir sa headerom | Svaka sekcija (pretraga, rezultati, 360 view) |
| `ZxForms` | Generise formu iz JSON config objekta | Pretraga klijenta, filteri |
| `ZxButton` | Grupa dugmadi | "Pretrazi", "Odustani", "Sacuvaj" |
| `ZxGrid` + `GridOptions` | AG Grid tabela | Tabele sa rezultatima |
| `ZxTab` | Tab navigacija | Rezultati / Zahtjevi (Orders) |
| `ZxPopup` | Modal prozor | Detalji, potvrde, interakcije |

---

## 🌳 Vizuelna hijerarhija komponenti

```
CustomerOverview
│
├── CustomerSearch360Component
│   ├── SearchBlock (ZxBlock)
│   │   ├── searchForm (ZxForms)
│   │   ├── SearchButtons (ZxButton)
│   │   └── search() metoda
│   │
│   ├── ResultBlock (ZxBlock)
│   │   ├── CustomersTabs (ZxTab)
│   │   │   └── CustomersGrid (AG Grid tabela)
│   │   │
│   │   └── OrderTabs (ZxTab)
│   │       └── OrdersGrid (AG Grid tabela)
│   │
│   └── CustomerDetailComponent (mali detalji)
│
└── Customer360Component  (*ngIf="customer.selected.caId")
    │
    ├── MenuComponent (meni lijevo)
    │   └── ZxAction['selectedMenu'] za promjenu prikaza
    │
    └── Dinamicki sadrzaj (desno):
        ├── BillingComponent (kartice sa brojevima)
        │   ├── AnaliticCardComponent
        │   ├── BillsOverviewComponent
        │   └── CreditOverviewComponent
        │
        ├── ThreeSixtyComponent (360 pregled)
        │   ├── BasicServicesComponent
        │   ├── HierarchyComponent (GoJS dijagram)
        │   ├── ClaimComplaintComponent
        │   └── BaggSaggJrkComponent
        │
        ├── BonusComponent (bonus podaci)
        │   ├── BonusiComponent
        │   ├── BonusPlusComponent
        │   └── PrepaidComponent
        │
        ├── TechnicalDetailsComponent (tehnicki detalji)
        │   ├── TDetailsComponent (osnovna polja)
        │   ├── ZimbraComponent (email)
        │   ├── RadiusComponent (internet)
        │   └── MojaTvComponent (IPTV)
        │
        ├── TemViewsComponent (dinamicki iz registry-ja)
        ├── TemActionsComponent (akcije)
        ├── EloquaComponent (email kampanje)
        ├── WfmsComponent (radni nalozi)
        ├── WebshopComponent (web prodaja)
        └── ReportOverviewComponent (izvještaji)
```

---

## 🎓 Savjet: Univerzalni obrazac

Svaka komponenta/modul u ovoj aplikaciji prati **isti obrazac**:

```
1. FORMA     (ZxForms sa poljima)
    ↓
2. API POZIV (ZxApi.get() ili .post())
    ↓
3. PODACI U SERVIS (or local property)
    ↓
4. PRIKAZ U UI (ZxGrid, ZxBlock, itd.)
```

### Primjer: Svaka komponenta izgleda ovako

```typescript
export class BiloKojaKomponenta {
  // 1. FORMA
  public nekiForm!: ZxForms;
  public nekiModel: any = {};

  // 2. UI BLOKOVI
  public nekiBlock: ZxBlock = new ZxBlock({...});
  public nekiButton!: ZxButton;
  public nekiGrid: GridOptions = {...};

  constructor(
    private api: ZxApi,           // Za API pozive
    private service: NekiService, // Za globalno stanje
    private action: ZxAction      // Za komunikaciju
  ) {}

  ngOnInit() {
    this.initForm();              // Kreiraj formu
    this.initButtons();           // Kreiraj dugmad
    this.loadData();              // Povuci podatke
  }

  loadData() {
    // API poziv
    this.api.get('/endpoint', params).subscribe((response) => {
      // Spasi u servis
      this.service.nekiPodatak = response.payload;

      // Ili emituj event
      this.action['ereignisIme'](response.payload);
    });
  }
}
```

---

## 🚀 Korak po korak — Kako poceti da ucis

### 1. Pretrazi klijenta
- Idi na `http://localhost:4200/customer360/customer/search`
- Unesite nesto u pretragu
- Klikni "Pretrazi"

### 2. Prati HTML
- Otvori `customer-search.component.html`
- Vidi: `<zx-block>`, `<zx-form-loader>`, `<zx-grid>`

### 3. Prati TypeScript
- Otvori `customer-search.component.ts`
- Vidi: `search()` metoda, `onCellClicked()`, `prepareSearchFilters()`

### 4. Izaberi klijenta
- Klikni na red u tabeli
- Vidi kako se `customer.selected` popuni
- Vidi kako se 360 view pojavi

### 5. Prati 360 view
- Otvori `customer360.component.html`
- Vidi kako se meni koristi `*ngIf="['BASIC_SERVICE'].includes(selectedComponent)"`
- Klikni na razlicite stavke menija

### 6. Razumij servis
- Otvori `customer-overview.service.ts`
- Vidi gdje se svi podaci cuvaju
- Vidi helper metode za kontrolu UI-ja

---

## 📚 Kljucne datoteke

| Datoteka | Uloga |
|----------|-------|
| `customer-overview.component.ts` | Glavna komponenta (layout) |
| `customer-overview.component.html` | HTML - tri dijela |
| `customer-search.component.ts` | Pretraga i rezultati |
| `customer-search.component.html` | Forma + grid |
| `customer-overview.service.ts` | Centralni servis (stanje) |
| `customer360.component.ts` | 360 view Container |
| `customer360.component.html` | Meni + dinamicki sadrzaj |
| `menu/menu.component.ts` | Meni logika |
| `constants/*.constant.ts` | API putanje |

---

## 💡 Vazne konstante

API putanje su definirane u `constants/` folder-u:

```typescript
// customer360.constant.ts
export const Customer360Api = {
  BASIC_SERVICE: '/ccm/eventsource/...',
  ADDITIONAL_SERVICE: '/ccm/eventsource/...',
  // ...
}

// customerApi.constant.ts
export const CustomerApi = {
  CUSTOMER_SEARCH: '/ccm/customer/search',
  CUSTOMER_DETAILS_SEARCH: '/ccm/customer/...',
  // ...
}
```

Ovo omogucava da se API endpoint-i ne ponavljaju po kodu.

---

## 🔧 Praktican primjer: Kako dodati novi filter u pretragu?

1. Otvori `customer-search.component.ts`
2. U `initSearchForm()` metodi (linija 377), dodaj novi field:
```typescript
{
  class: ['col-6'],
  template: 'ZxInput',
  type: 'text',
  name: 'mojePolje',
  label: 'Moj novi filter',
  visible: false,
  additional: true  // Prikazuje se tek sa "Jos filtera"
}
```

3. U `prepareSearchFilters()` (linija 306), filter ce se automatski dodati ako ima vrijednost

4. Gotovo! Filter je aktivan.

---

## 📝 Rezime

**Sto memorisati:**

- ✅ `Customer360Service` = centralno stanje (selected, customerDetail, detalji...)
- ✅ `CustomerSearch360Component` = pretraga i prikaz rezultata u gridu
- ✅ `Customer360Component` = 360 view container (meni + dinamicki sadrzaj)
- ✅ `ZxAction` = komuniciranje bez direktnih referenci
- ✅ `ZxApi` = sve HTTP pozive
- ✅ Svaka komponenta = forma + API + servis + prikaz

**Kad razumijes ovo, mozes otvoriti bilo koju drugu komponentu u projektu i odmah ces prepoznati isti obrazac.**

