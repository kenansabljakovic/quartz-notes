# ZFF (ZIRA Frontend Framework) — Reverse Engineering dokumentacija

## Context

ZFF je interni frontend framework koji se koristi u BH Telecom projektima. Izvorni kod nije dostupan, ali je kompletna API površina rekonstruisana iz `.d.ts` fajlova u `node_modules/@zff/` i iz usage patterna u Customer360 projektu. Ova dokumentacija služi kao referenca za korištenje ZFF-a u drugim projektima.

---

## Paketi i verzije

| Paket | Verzija | Opis |
|-------|---------|------|
| `@zff/core` | ^3.2.6 | Servisi: ZxApi, ZxAction, ZxUser, ZxTranslate, ZxMessage, ZxSSE, ZxCaching |
| `@zff/layout` | ^3.3.2 | Layout shell: ZxPageLayout, ZxAppHeader, ZxMenu, OAuthGuard, ZxTheme |
| `@zff/building-components` | ^3.3.8 | UI komponente: ZxBlock, ZxButton, ZxPopup, ZxTab, ZxForms, ZxConfirmation |
| `@zff/grid` | 3.0.5 | AG Grid wrapper: ZxGrid sa server-side paginacijom i exportom |
| `@zff/collections` | ^3.2.3 | CxDocuments, CxMail, CxComment, CxHierarchy, CxMiniUI |
| `@zff/date-picker` | 1.0.2 | Date picker komponenta |

---

## 1. Bootstrapping — AppModule setup

```typescript
imports: [
  ZxCoreModule.options(environment, STATIC_URLs),
  ZxGridModule.options({ exportApi: '/factory/v2/export', exportNewRequest: true }),
  ZxLayoutModule,
  ZxCollectionsModule,
  ZxBuildingComponentsModule,
]
```

**Environment config** (`environment.ts`):
```typescript
{
  endpoint: '',          // prazan — koristi proxy/gateway
  language: 'bs',
  appId: 'CUSTOMER360',
  sseEnabled: true,
  sse: { url: '/eventhub/...', reconnectInterval: 5000, maxRetries: 10 },
  caching: { enabled: true, ttl: 600, endpoints: ['/assets'] }
}
```

**STATIC_URLs**:
```typescript
{
  userUrl: '/uaa/user/logged',
  menuUrl: '/uaa/user/menu',
  guiConfigUrl: '/commonregistry/gui-configuration',
  sseUrl: '/eventhub/user-notifications/v1'
}
```

**Feature module imports** (u svakom lazy-loaded modulu):
```typescript
imports: [
  CommonModule, FormsModule,
  ZxBuildingComponentsModule,
  ZxGridModule,
  RouterModule.forChild([...])
]
```

---

## 2. Layout sistem (`@zff/layout`)

### Template struktura
```html
<zx-loading type="'three-bounce'"></zx-loading>
<zx-page-layout>
  <zx-app-header HEADER></zx-app-header>
  <zx-breadcrumbs BODY-HEADER [config]="breadCrumbConfig">
    <zx-help zx-breadcrumbs-right-side></zx-help>
  </zx-breadcrumbs>
  <zx-menu LEFT-SIDE [config]="menuConfig"></zx-menu>
  <zx-settings BODY-CONTENT [config]="settings"></zx-settings>
  <router-outlet BODY-CONTENT></router-outlet>
</zx-page-layout>
```

**Direktive za poziciju**: `HEADER`, `BODY-HEADER`, `LEFT-SIDE`, `BODY-CONTENT`

### Konfiguracije

```typescript
// Menu
public menuConfig: ZxMenu = new ZxMenu({
  logo: './assets/images/logo.svg',
  logoVisible: true,
  clickHandler: true,
  orientation: 'landscape',
  showExpand: true,
});

// Breadcrumbs
public breadCrumbConfig: ZxBreadcrumbs = new ZxBreadcrumbs({ hideHistory: true });

// Settings
public settings: ZxSetting = new ZxSetting({
  application: true, language: true, userinfo: true, theme: false, about: true,
  app: { name: 'App Name', version: info.version, dependencies: info.dependencies, prefix: ['@angular'] }
});
```

### OAuthGuard
```typescript
import { OAuthGuard } from '@zff/layout';

{ path: 'protected', canActivate: [OAuthGuard], canActivateChild: [OAuthGuard],
  loadChildren: () => import('./module').then(m => m.MyModule) }
```

### ZxAppLoaderService
```typescript
constructor(public appLoader: ZxAppLoaderService) {}
// appLoader.initialize — kontroliše prikaz loadera
// appLoader.loaded — da li je app učitan
// appLoader.progress — procenat učitavanja (0-100)
```

### ZxTheme
```typescript
// CSS varijable: --main, --info, --success, --warning, --danger, --contrast, --backlight, --primary, --secondary, --highlight
theme.load();
theme.apply();
theme.getCSSVariable('--main');
theme.mixColors(color1, color2, percentage);
```

---

## 3. Core servisi (`@zff/core`)

### ZxApi — HTTP klijent
```typescript
import { ZxApi } from '@zff/core';
constructor(private api: ZxApi) {}

// GET
this.api.get('/ccm/customer/search', { customerId: 123 }).subscribe((res: any) => {
  const data = res.payload; // response je wrappan u { payload: ... }
});

// GET sa headerima (4. parametar)
this.api.get('/endpoint', params, null, { headers: { key: 'value' } }).subscribe(...);

// POST
this.api.post('/interaction/create', bodyObj).subscribe((res: any) => { ... });

// PUT
this.api.put('/resource/update', bodyObj).subscribe(...);

// PATCH
this.api.patch('/resource/patch', bodyObj).subscribe(...);

// DELETE
this.api.delete('/resource/123').subscribe(...);

// Upload
this.api.upload('/upload/path', queryParams, fileBody).subscribe(...);

// Download
this.api.download(data, 'application/pdf', 'file.pdf');

// Async/Await pattern
const result = await firstValueFrom(this.api.get('/endpoint', params));
```

### ZxAction — Event bus
```typescript
import { ZxAction } from '@zff/core';
constructor(private action: ZxAction) {}

// Registracija handlera
this.action.set('search', (caId: number) => this.search(caId));
this.action.set('refreshGrid', () => this.grid.api.refreshServerSide());

// Poziv akcije
this.action['search'](12345);
this.action['refreshGrid']();

// Uklanjanje
this.action.unset('search', 'refreshGrid');
```

### ZxUser — Korisnik
```typescript
import { ZxUser } from '@zff/core';
constructor(private user: ZxUser) {}

this.user.id;         // User ID
this.user.code;       // Username
this.user.firstName;
this.user.lastName;
this.user.email;
this.user.language;
this.user.load();     // Učitaj sa servera
```

### ZxMessage — Toast notifikacije
```typescript
import { ZxMessage } from '@zff/core';
constructor(private message: ZxMessage) {}

this.message.success('Uspješno sačuvano!', 'Naslov');
this.message.error('Greška pri spremanju', 'Greška');
this.message.warning('Upozorenje');
this.message.info('Informacija');

// Sa opcijama
this.message.success('Poruka', 'Naslov', {
  position: 'top-right',    // 'top-left' | 'top-center' | 'top-right' | 'bottom-*'
  timeToLive: 5000,
  stripMessageTo: 100
});
```

### ZxTranslate — Lokalizacija
```typescript
import { ZxTranslate } from '@zff/core';
this.translate.locale;              // 'bs'
this.translate.use('en');           // Promijeni jezik
this.translate.translate('key');    // Prevedi
```

### ZxSSE — Server-Sent Events
```typescript
import { ZxSSE } from '@zff/core';
this.sse.connect('/sse/endpoint').subscribe(msg => { ... });
this.sse.disconnect();
```

### ZxCaching — HTTP keširanje
```typescript
// Konfiguriše se kroz environment.caching
{ enabled: true, ttl: 600, endpoints: ['/assets'] }
```

### ZxDom — Dinamičke komponente
```typescript
import { ZxDom } from '@zff/core';
const ref = this.dom.createComponent(MyComponent, { input: 'value' });
this.dom.attachComponent(ref, document.getElementById('target'));
```

### Utility funkcije
```typescript
import { genGUID, genName, ZxJSON, Hash, HashMD5 } from '@zff/core';
genGUID();           // 'Zx-xxxxx-xxx-yxxxx'
genName();           // Jedinstveno ime
ZxJSON(value);       // Parse/stringify
Hash('string');      // String hash
HashMD5('value');    // MD5 hash
```

### Pipe-ovi
```html
{{ 'key' | translate }}
{{ items | filterby: 'name': 'search' }}
{{ items | orderby: 'date': 'desc' }}
{{ htmlContent | sanitize }}
```

### Colors tip
```typescript
type Colors = 'main' | 'primary' | 'secondary' | 'highlight' | 'success' | 'danger' | 'warning' | 'info' | 'contrast';
```

---

## 4. UI Komponente (`@zff/building-components`)

### ZxBlock — Kontejner/Panel
```typescript
import { ZxBlock } from '@zff/building-components';

public myBlock: ZxBlock = new ZxBlock({
  id: 'myBlock',
  name: 'my block',
  label: 'Naslov bloka',
  icon: 'fad fa-search',
  hideExpand: true,    // sakrij expand dugme
  hideHeader: false,   // sakrij header
  expand: true,        // inicijalno expandiran
});
```

```html
<zx-block [config]="myBlock">
  <div zx-block-action-left><!-- lijeve akcije --></div>
  <div zx-block-action-middle><!-- srednje akcije --></div>
  <div zx-block-action><!-- desne akcije --></div>
  <div zx-block-header><!-- custom header --></div>
  <div zx-block-left-side><!-- lijeva strana --></div>
  <div zx-block-body><!-- glavni sadržaj --></div>
  <div zx-block-right-side><!-- desna strana --></div>
  <div zx-block-footer><!-- footer --></div>
</zx-block>
```

### ZxButton — Dugme
```typescript
import { ZxButton } from '@zff/building-components';

public myButtons: ZxButton = new ZxButton({
  id: 'actionButtons',
  name: 'action buttons',
  items: [
    { id: 'save', icon: 'fad fa-save', name: 'save', label: 'Sačuvaj', action: () => this.save() },
    { id: 'cancel', icon: 'fad fa-times', name: 'cancel', label: 'Odustani', action: () => this.cancel() },
    { id: 'delete', icon: 'fad fa-trash', name: 'delete', label: 'Obriši', action: () => this.delete(), disabled: true },
  ]
});

// Programatski enable/disable/hide
this.myButtons.enable('save', 'cancel');
this.myButtons.visible('delete');
```

```html
<zx-button [config]="myButtons" zx-block-action></zx-button>
```

**Button layout opcije**: `'classic' | 'icon' | 'rounded' | 'link'`
**Button sizes**: `'sm' | 'md' | 'lg' | 'xl'`

### ZxPopup — Modal
```typescript
import { ZxPopup } from '@zff/building-components';

public myPopup: ZxPopup = new ZxPopup({
  id: 'detailPopup',
  name: 'detail popup',
  label: 'Detalji',
  icon: 'fa-regular fa-info-circle',
  size: 'col-16',       // širina: col-8, col-12, col-16, col-20, col-24
  hideHeader: false,
  draggable: true,
  overlay: true,
});

// Otvaranje/zatvaranje
this.myPopup.show = true;
this.myPopup.show = false;
// ili
this.myPopup.visible = true;
```

```html
<zx-popup [config]="myPopup">
  <div zx-popup-header><!-- custom header --></div>
  <div zx-popup-body>
    <!-- sadržaj -->
  </div>
  <div zx-popup-footer>
    <zx-button [config]="popupButtons" zx-popup-footer></zx-button>
  </div>
</zx-popup>
```

### ZxTab — Tabovi
```typescript
import { ZxTab } from '@zff/building-components';

public myTabs: ZxTab = new ZxTab({
  id: 'infoTabs',
  name: 'info tabs',
  orientation: 'portrait',   // 'portrait' | 'landscape'
  hideExpand: true,
  showPin: false,
  expand: true,
  routerDisable: true,       // ne koristi Angular router
  items: [
    { name: 'general', id: 'general-tab', label: 'Opšte' },
    { name: 'details', id: 'details-tab', label: 'Detalji' },
    { name: 'history', id: 'history-tab', label: 'Historija', disabled: false, hidden: false },
  ]
});
```

```html
<zx-tab [config]="myTabs" class="group">
  <!-- Svaki zx-tab-item odgovara jednom tabu po redu -->
  <div zx-tab-item>Sadržaj prvog taba</div>
  <div zx-tab-item>Sadržaj drugog taba</div>
  <div zx-tab-item>Sadržaj trećeg taba</div>
</zx-tab>
```

### ZxConfirmation — Dijalog potvrde
```typescript
import { ZxConfirmation } from '@zff/building-components';
constructor(private confirmation: ZxConfirmation) {}

this.confirmation.warning('Da li ste sigurni?', 'Potvrda',
  { label: 'Da', action: () => this.doAction() },
  { label: 'Ne', action: () => {} }
);

this.confirmation.error('Greška!', 'Upozorenje', ...actions);
this.confirmation.success('Uspješno!', 'Info', ...actions);
this.confirmation.info('Napomena', 'Info', ...actions);
```

### ZxRole — Kontrola pristupa (direktiva)
```html
<zx-button [config]="btn" [ZxRole]="roleConfig" [id]="'btnId'"></zx-button>
```
Role bitmask: `readonly: 1, hidden: 2, disabled: 4, exclude: 8`

---

## 5. ZxForms — Sistem za forme

### Kreiranje forme
```typescript
import { ZxForms } from '@zff/building-components';

public searchModel: any = {};  // model za two-way binding

public searchForm: ZxForms = new ZxForms({
  class: ['col-24'],
  template: 'ZxForm',
  id: 'searchForm',
  name: 'searchForm',
  children: [
    // Text input
    {
      class: ['col-12'], template: 'ZxInput', type: 'text',
      name: 'firstName', label: 'Ime', placeholder: 'Unesite ime',
      validation: { required: true, minLength: 3 }
    },
    // Select dropdown
    {
      class: ['col-6'], template: 'ZxSelect', type: 'select',
      name: 'status', label: 'Status',
      lov: [{ code: 'A', name: 'Aktivan' }, { code: 'I', name: 'Neaktivan' }],
      listmap: { code: 'code', name: 'name' }
    },
    // Autocomplete (sa API-jem)
    {
      class: ['col-12'], template: 'ZxSelect', type: 'autocomplete',
      name: 'service', label: 'Usluga',
      onKeyUp: (c, m) => this.onAutoComplete(c.value, 'name', '/api/lookup', 'service'),
      generate: [{
        method: 'get', init: true, url: '/api/lookup',
        queries: [{ source: 'service', mapping: 'value', from: 'component', as: 'name' }],
        response: [{ source: 'service', mapping: 'payload', from: 'component', as: 'list' }]
      }],
      listmap: { code: 'code', name: 'name' },
      multiple: false, showSelectButtons: false, keepOnSelect: false
    },
    // Date picker
    {
      class: ['col-6'], template: 'ZxDate', type: 'date',
      name: 'birthDate', label: 'Datum rođenja'
    },
    // Checkbox
    {
      class: ['col-6'], template: 'ZxCheckbox',
      name: 'active', label: 'Aktivan'
    },
    // Textarea
    {
      class: ['col-24'], template: 'ZxTextarea',
      name: 'description', label: 'Opis'
    },
  ]
});
```

### Template za forme
```html
<zx-form-loader [component]="searchForm" [model]="searchModel" zx-block-body></zx-form-loader>
```

### Form API
```typescript
// Validacija
if (this.searchForm.isValid) { ... }

// Pristup polju
this.searchForm.get('status').list = newOptions;
this.searchForm.get('firstName').visible = false;
this.searchForm.get('firstName').disabled = true;

// Iteracija djece
this.searchForm.children.forEach(child => child.visible = true);
```

### Template tipovi (template property)
| Template | Opis |
|----------|------|
| `ZxForm` | Kontejner forme |
| `ZxInput` | Tekstualni input |
| `ZxSelect` | Dropdown / autocomplete |
| `ZxDate` | Date picker |
| `ZxCheckbox` | Checkbox |
| `ZxRadio` | Radio button |
| `ZxTextarea` | Multi-line text |
| `ZxFile` | File upload |
| `ZxCurrency` | Currency input |
| `ZxRange` | Range slider |
| `ZxTags` | Tags input |
| `ZxFieldset` | Fieldset container |
| `ZxSeparator` | Vizualni separator |

### Validacija (validation property)
```typescript
{
  required: true,
  minLength: 3, maxLength: 50,
  min: 0, max: 100,
  pattern: '^[0-9]+$',
  equalLength: 13,
  equal: 'otherField',
  between: [1, 100],
  minDate: '2020-01-01', maxDate: '2030-12-31',
  minSelection: 1, maxSelection: 5
}
```

### Event handleri na poljima
```typescript
{
  onChange: (component, model) => { ... },
  onModelChange: (component, model) => { ... },
  onKeyUp: (component, model) => { ... },
  onKeyDown: (component, model) => { ... },
  onEnter: (component, model) => { ... },
  onFocusIn: (component, model) => { ... },
  onFocusOut: (component, model) => { ... },
  onSelect: (component, model) => { ... },
  onUnselect: (component, model) => { ... },
  onChecked: (component, model) => { ... },
  onUnchecked: (component, model) => { ... },
  onInit: (component, model) => { ... },
  onAfterViewInit: (component, model) => { ... },
  onDestroy: (component, model) => { ... },
  onReset: (component, model) => { ... },
}
```

---

## 6. ZxGrid — AG Grid wrapper (`@zff/grid`)

### Konfiguracija
```typescript
import { GridOptions } from 'ag-grid-community';

public myGrid: GridOptions = {
  columnDefs: [
    { field: 'id', headerName: 'ID', filter: 'text', type: 'text', width: 100 },
    { field: 'name', headerName: 'Naziv', filter: 'text', type: 'text' },
    { field: 'date', headerName: 'Datum', filter: 'date', type: 'datetime',
      valueFormatter: (data) => this.dateService.formatDateForGrid(data),
      filterParams: {
        comparator: (filter, cell) => this.dateService.gridFilterComparator(filter, cell)
      }
    },
    { field: 'status', headerName: 'Status', filter: 'select',
      filterParams: { lovApi: '/api/statuses', useAsLookup: true }
    },
    { field: 'action', headerName: '', cellRenderer: 'linkRenderer',
      cellRendererParams: { onClick: (params) => this.onRowClick(params) }
    },
  ],
  rowModelType: 'serverSide',
  pagination: true,
  paginationPageSize: 10,
  cacheBlockSize: 10,
  domLayout: 'autoHeight',
  onSelectionChanged: (event) => {
    const selected = event.api.getSelectedRows()[0];
  },
} as GridOptions;
```

### Template
```html
<!-- Server-side sa API source-om -->
<zx-grid [gridOptions]="myGrid" [source]="'/api/data'" [params]="queryParams"
  code="my-grid" [exportOverrides]="exportConfig" zx-tab-item></zx-grid>

<!-- Client-side sa array source-om -->
<zx-grid [gridOptions]="myGrid" [source]="dataArray" zx-block-body></zx-grid>
```

### ZxGrid inputs
| Input | Tip | Opis |
|-------|-----|------|
| `gridOptions` | GridOptions | AG Grid konfiguracija |
| `source` | string \| any[] | API endpoint ili data array |
| `params` | any | Query parametri za API |
| `code` | string | Grid identifikator (za export/state) |
| `exportOverrides` | any | Export konfiguracija |
| `refreshInterval` | any | Auto-refresh interval |
| `ZxFilters` | any | Custom filteri |
| `frameworkComponents` | any | Custom rendereri |

### Globalne grid opcije (utility)
```typescript
// src/app/pages/shared/grid-options/grid-options.ts
static getDefaultGridOptions(code: string = 'export'): GridOptions {
  return {
    code,
    tooltipShowDelay: 200,
    defaultColDef: {
      filterParams: { filterOptions: ['contains','notContains','equals','notEqual','startsWith','endsWith'] },
      cellRenderer: (x) => {
        if (x.colDef.type == 'datetime' && x.value) return moment(x.value).format('DD.MM.YYYY HH:mm:ss');
        return x.valueFormatted || x.value;
      }
    },
    sideBar: { toolPanels: ['columns', 'filters', 'layouts'] }
  };
}
```

---

## 7. Collections (`@zff/collections`)

| Komponenta | Opis |
|------------|------|
| `CxDocumentsComponent` | Upravljanje dokumentima |
| `CxMailComponent` | Email/poruke |
| `CxCommentComponent` | Komentari |
| `CxHierarchyComponent` | Vizualizacija hijerarhije |
| `CxMiniUI` module | CxCheckbox, CxGroup, CxRadio, CxListSwitcher |

---

## 8. Direktive

| Direktiva | Opis |
|-----------|------|
| `[ZxRole]` | Role-based pristup (readonly/hidden/disabled/exclude) |
| `ZxRippleDirective` | Material ripple efekat |
| `ZxTooltipDirective` | Tooltip |
| `ZxClickOutsideDirective` | Detekcija klika izvan elementa |

---

## 9. Theming — CSS varijable

```scss
// ZFF theme varijable
--main, --info, --success, --warning, --danger, --contrast
--backlight, --primary, --secondary, --highlight

// App-level override (styles.scss)
--normal-font: 12px;
--input-padding: 4px 8px;
--input-height: 28px;
--input-border-color: #ccc;
--menu-width: 50px;
```

---

## 10. Česti obrasci korištenja

### Tipičan page component
```typescript
@Component({ ... })
export class MyPageComponent implements OnInit {
  constructor(private api: ZxApi, private action: ZxAction) {}

  // Blok
  public mainBlock = new ZxBlock({ id: 'main', name: 'main', label: 'Naslov' });

  // Forma
  public formConfig = new ZxForms({ template: 'ZxForm', children: [...] });
  public model: any = {};

  // Grid
  public gridOptions: GridOptions = { columnDefs: [...], rowModelType: 'serverSide', ... };
  public gridSource = '/api/endpoint';
  public gridParams: any = {};

  // Dugmad
  public buttons = new ZxButton({ items: [
    { id: 'search', label: 'Traži', icon: 'fad fa-search', action: () => this.search() }
  ]});

  // Popup
  public detailPopup = new ZxPopup({ id: 'detail', label: 'Detalji', size: 'col-16' });

  ngOnInit() {
    this.action.set('refresh', () => this.refresh());
  }

  search() {
    this.gridParams = { ...this.model };
  }
}
```

### Tipičan template
```html
<zx-block [config]="mainBlock">
  <zx-form-loader zx-block-body [component]="formConfig" [model]="model"></zx-form-loader>
  <zx-button zx-block-action [config]="buttons"></zx-button>
</zx-block>

<zx-tab [config]="tabs">
  <zx-grid [gridOptions]="gridOptions" [source]="gridSource" [params]="gridParams" zx-tab-item></zx-grid>
</zx-tab>

<zx-popup [config]="detailPopup">
  <div zx-popup-body><!-- sadržaj --></div>
</zx-popup>
```
