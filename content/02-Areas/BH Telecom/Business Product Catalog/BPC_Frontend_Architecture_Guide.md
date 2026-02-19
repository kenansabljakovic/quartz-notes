# BPC Frontend Architecture Guide

> Ovaj dokument je pripremljen kao kompletni vodič za razvoj Business Product Catalog (BPC) frontend aplikacije u Reactu. Namijenjen je Claude Code agentu i developerima koji nemaju pristup postojećem UOM Angular projektu. Sadrži sve donesene arhitekturalne odluke, obrasce, i primjere koda koji treba slijediti tokom razvoja.

---

## 1. Kontekst projekta

### Šta je BPC?

**Business Product Catalog (BPC)** je novi sistem BH Telecoma — centralizovana, strukturisana baza svih usluga i tarifnih paketa. Trenutno se cjenovnik održava ručno u Word/PDF formatu bez strukturisane baze podataka, što otežava pretragu i onemogućava automatizaciju.

**BPC će biti "Single Source of Truth"** — jedno mjesto za sve podatke o uslugama, koje koriste:
- JPP (interni prodajni alat, postojeći Angular projekt)
- Chatbot sistem
- Mobilna aplikacija
- DWH (Data Warehouse)
- Revenue Assurance

### Ključne funkcionalnosti

1. **Role-based unos i izmjene** — Uloge: IDRP, pravna služba, IT. Svaka uloga ima jasno definisan set prava (unos, odobravanje, potvrđivanje, publiciranje).
2. **Jedinstveni unos podataka** — Podaci se unose jednom i automatski koriste u svim sistemima.
3. **Verzioniranje i historija izmjena** — Svaka objavljena verzija ima jedinstvenu oznaku. Sistem čuva potpunu historiju i omogućava diff prikaz razlika.
4. **Napredna pretraga** — Za prodajno osoblje i osoblje podrške.
5. **Automatsko generisanje PDF dokumenata** — Cjenovnik, izvod iz cjenovnika, sažeci ugovora.

### Publish workflow (tok objave)

```
Draft → In Review → Approved → Published
  ↑                               ↓
  └───── Nova verzija kreirana ───┘
```

---

## 2. Kontekst iz postojećeg UOM Angular projekta

> **Napomena:** Claude Code nema direktni pristup UOM projektu, ali sljedeće informacije su izvučene analizom tog projekta i trebaju informisati odluke za BPC.

### Šta je UOM i zašto je relevantan?

UOM (Angular 4, iz 2017.) je interni prodajni alat BH Telecoma — CRM/workflow aplikacija za operatere. Radi se o istoj firmi, istom IT timu, i vjerovatno istom backend timu. Stoga BPC backend vjerovatno:
- Koristi iste konvencije API odgovora
- Ima iste auth mehanizme
- Može imati iste sesijske/autentikacijske tokove

### API konvencije iz UOM-a (primjenjuju se na BPC)

**Request format — svaki POST/PUT/PATCH body je umotavan:**
```json
{
  "languageId": 0,
  "channel": "BPC",
  "entity": { "vaši podaci ovdje" }
}
```

**Response format — stvarni podaci su uvijek u `payload`:**
```json
{
  "payload": { "stvarni podaci" },
  "successful": true,
  "responseCode": 200,
  "responseDetail": "OK",
  "transactionId": "abc-123",
  "cache": false
}
```

**URL parametri:**
- Ako je query `Array` → path segmenti: `/api/resource/1/2/3`
- Ako je query `Object` → query string: `/api/resource?key=val&key2=val2`

**Auth greška:**
- HTTP 403 → provjeriti `/authentication-status` endpoint
- Ako nije autentificiran → redirect na login (bez full page reload)

### Šabloni komunikacije između komponenti iz UOM-a (ne kopirati direktno)

UOM koristi `SharedDataService` — jedan mega-servis sa 30+ javnih propertyja koje svaka komponenta može slobodno čitati i pisati. Ovo je **anti-pattern** koji treba izbjeći u BPC-u. Koristi se za:
- Čuvanje trenutnog korisnika (`customer`, `caId`, `baId`, `esId`...)
- Komunikaciju između komponenti (RxJS Subjects)
- Global UI state (spinner, breadcrumbs)

Za BPC, ovaj mega-state treba **razbiti na domenske store-ove** koristeći Zustand (vidi sekciju 5).

### Dynamic Form Engine iz UOM-a (z-dynamic) — konceptualna baza za BPC

UOM ima sofisticiran engine koji renderuje forme iz JSON metapodataka sa backenda. BPC treba sličan sistem jer admin forme za unos usluga moraju biti fleksibilne i meta-podatak-drivene.

**Konceptualni tok iz UOM-a koji treba replicirati:**
```
Backend šalje: InputObject[] (JSON metapodaci koji opisuju formu)
                    ↓
DynamicField komponenta:
  { template: "input", name: "cijena", label: "Cijena (KM)", required: true }
                    ↓
Renderuje:  <TextInput name="cijena" label="Cijena (KM)" required />
```

**Dependency system iz UOM-a (treba replicirati):**
Svako polje može imati dependencies — kad se vrijednost polja X promijeni, polje Y se:
- `activate` / `deactivate` — prikazuje ili skriva
- `reset` — briše vrijednost
- `refresh` — ponovo učitava opcije (za dropdowne koji zavise od drugog polja)
- `required` / `disabled` — mijenja validacijska pravila
- `setvalue` — kopira vrijednost iz drugog polja

**Validation system iz UOM-a (treba replicirati):**
- `mandatory` — obavezno polje
- `formatPattern` — regex validacija
- `min`/`max` — numerički opseg ili dužina stringa
- `validationFormula` — validacija putem API poziva (async)

Greška validacije propagira se prema gore — ako polje ima grešku, parent sekcija i tab dobijaju error indikator.

---

## 3. Tech Stack odluke

| Kategorija | Odabrana tehnologija | Razlog |
|---|---|---|
| Framework | React 18+ sa TypeScript | Zahtjev projekta |
| Build tool | Vite | Brži dev server od CRA, izvrsna DX |
| Routing | React Router v7 | Standardni React router |
| Server state | TanStack Query v5 | Automatski caching, invalidacija, retry |
| Client state | Zustand | Lagan, jednostavan, po-domenski |
| Forme | React Hook Form + Zod | Izolirani re-renderi po polju, type-safe validacija |
| UI komponente | shadcn/ui + Radix UI | Headless, pristupačno, lako prilagodljivo |
| Stilovi | Tailwind CSS | Utility-first, konzistentan design system |
| HTTP klijent | Axios | Interceptori za wrapping/unwrapping, error handling |
| Tabele | TanStack Table v8 | Headless, virtualizacija, sortiranje, filtriranje |
| Virtualizacija | TanStack Virtual | Za dugačke liste proizvoda |
| Rich text | TipTap | Moderni editor, extensible (za template editor) |
| PDF prikaz | react-pdf | Pregled generisanih dokumenata |
| Diff prikaz | react-diff-viewer-continued | Za prikaz razlika između verzija |
| Ikone | Lucide React | Konzistentne, tree-shakeable |
| Testiranje | Vitest + React Testing Library | Brzo, moderne API |
| Linting | ESLint + typescript-eslint | Striktna TypeScript provjera |

---

## 4. Projektna struktura (folder architecture)

```
bpc-frontend/
├── public/
│   └── favicon.ico
│
├── src/
│   ├── app/                          # App-level setup
│   │   ├── App.tsx                   # Root komponenta, providers
│   │   ├── routes.tsx                # Sve rute sa lazy loading
│   │   ├── providers.tsx             # QueryClient, AuthProvider, ThemeProvider
│   │   └── layout/
│   │       ├── AppShell.tsx          # Header + sidebar + content wrapper
│   │       ├── Header.tsx
│   │       ├── Sidebar.tsx
│   │       └── Breadcrumbs.tsx
│   │
│   ├── features/                     # Feature-based struktura (glavni kod)
│   │   │
│   │   ├── auth/                     # Autentikacija i autorizacija
│   │   │   ├── components/
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   ├── RoleGuard.tsx     # HOC za zaštitu ruta po ulozi
│   │   │   │   └── PermissionGate.tsx # Skriva UI elemente bez dozvole
│   │   │   ├── hooks/
│   │   │   │   ├── useAuth.ts        # Trenutni korisnik, login, logout
│   │   │   │   └── usePermission.ts  # Provjera dozvola
│   │   │   ├── store/
│   │   │   │   └── auth.store.ts     # Zustand store za auth state
│   │   │   ├── api/
│   │   │   │   └── auth.api.ts
│   │   │   └── types/
│   │   │       └── auth.types.ts
│   │   │
│   │   ├── products/                 # Upravljanje uslugama/tarifama (CRUD)
│   │   │   ├── pages/
│   │   │   │   ├── ProductListPage.tsx
│   │   │   │   ├── ProductDetailPage.tsx
│   │   │   │   └── ProductEditPage.tsx
│   │   │   ├── components/
│   │   │   │   ├── ProductTable.tsx
│   │   │   │   ├── ProductForm.tsx   # Koristi dynamic-forms engine
│   │   │   │   ├── ProductCard.tsx
│   │   │   │   ├── ProductFilters.tsx
│   │   │   │   └── ProductStatusBadge.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useProducts.ts    # TanStack Query hooks
│   │   │   │   ├── useProduct.ts
│   │   │   │   └── useProductMutations.ts
│   │   │   ├── api/
│   │   │   │   └── products.api.ts
│   │   │   └── types/
│   │   │       └── product.types.ts
│   │   │
│   │   ├── versions/                 # Verzioniranje i publishing workflow
│   │   │   ├── pages/
│   │   │   │   ├── VersionTimelinePage.tsx
│   │   │   │   └── VersionDiffPage.tsx
│   │   │   ├── components/
│   │   │   │   ├── VersionTimeline.tsx   # Historija verzija
│   │   │   │   ├── VersionDiffViewer.tsx # Diff prikaz između verzija
│   │   │   │   ├── PublishWorkflow.tsx   # Draft→Review→Approved→Published
│   │   │   │   └── VersionBadge.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useVersions.ts
│   │   │   │   └── usePublishWorkflow.ts
│   │   │   ├── api/
│   │   │   │   └── versions.api.ts
│   │   │   └── types/
│   │   │       └── version.types.ts
│   │   │
│   │   ├── search/                   # Napredna pretraga cjenovnika
│   │   │   ├── pages/
│   │   │   │   └── SearchPage.tsx
│   │   │   ├── components/
│   │   │   │   ├── SearchBar.tsx
│   │   │   │   ├── FacetedFilters.tsx   # Filtri po kategoriji, tipu, statusu
│   │   │   │   ├── SearchResults.tsx
│   │   │   │   └── SavedSearches.tsx    # Sačuvane pretrage korisnika
│   │   │   ├── hooks/
│   │   │   │   ├── useSearch.ts
│   │   │   │   └── useSavedSearches.ts
│   │   │   ├── api/
│   │   │   │   └── search.api.ts
│   │   │   └── types/
│   │   │       └── search.types.ts
│   │   │
│   │   └── documents/                # PDF generisanje i pregled
│   │       ├── pages/
│   │       │   └── DocumentPreviewPage.tsx
│   │       ├── components/
│   │       │   ├── DocumentPreview.tsx  # Pregled prije generisanja
│   │       │   ├── TemplateEditor.tsx   # TipTap editor za template
│   │       │   └── DownloadButton.tsx
│   │       ├── hooks/
│   │       │   └── useDocumentGeneration.ts
│   │       ├── api/
│   │       │   └── documents.api.ts
│   │       └── types/
│   │           └── document.types.ts
│   │
│   ├── dynamic-forms/                # Ekvivalent UOM z-dynamic engine-a
│   │   ├── DynamicForm.tsx           # Glavni form renderer
│   │   ├── DynamicField.tsx          # Field type resolver
│   │   ├── DependencyManager.ts      # Cross-field dependency logika
│   │   ├── ValidationManager.ts      # Schema + async validacija
│   │   ├── fields/                   # Konkretni field komponenti
│   │   │   ├── TextField.tsx
│   │   │   ├── SelectField.tsx
│   │   │   ├── DateField.tsx
│   │   │   ├── CheckboxField.tsx
│   │   │   ├── TextareaField.tsx
│   │   │   ├── NumberField.tsx
│   │   │   └── AutocompleteField.tsx
│   │   └── types/
│   │       └── schema.types.ts       # FieldSchema, FormSchema tipovi
│   │
│   └── shared/                       # Dijeljeni kod koji koriste sve features
│       ├── components/               # UI komponente
│       │   ├── ui/                   # shadcn/ui komponente (auto-generirane)
│       │   ├── DataTable.tsx         # TanStack Table wrapper
│       │   ├── VirtualList.tsx       # TanStack Virtual wrapper
│       │   ├── Modal.tsx
│       │   ├── ConfirmDialog.tsx
│       │   ├── Spinner.tsx
│       │   ├── ErrorBoundary.tsx
│       │   ├── EmptyState.tsx
│       │   └── StatusBadge.tsx
│       ├── hooks/                    # Utility hooks
│       │   ├── useDebounce.ts
│       │   ├── useLocalStorage.ts    # Sa schema verzioniranjem
│       │   ├── useUrlState.ts        # Sinkronizacija state-a sa URL params
│       │   └── useLatest.ts          # Stabilan ref na najnoviju funkciju
│       ├── lib/                      # Utility funkcije i API klijent
│       │   ├── api-client.ts         # Axios instance sa interceptorima
│       │   ├── query-client.ts       # TanStack Query konfiguracija
│       │   └── utils.ts
│       └── types/                    # Globalni TypeScript tipovi
│           ├── api.types.ts          # RestPayload, ApiError...
│           └── common.types.ts
│
├── .env.local                        # Lokalne env varijable (nije u git)
├── .env.example                      # Template za env varijable
├── vite.config.ts
├── tsconfig.json                     # Striktni TypeScript
├── tailwind.config.ts
└── package.json
```

---

## 5. Implementacijski obrasci (Patterns)

### 5.1 API Klijent — Axios sa interceptorima

Ovo je temelj svega. Centralni HTTP klijent koji automatski:
- Umata request bodije u `{ languageId, channel, entity }` format (UOM kompatibilnost)
- Izvlači `payload` iz svakog odgovora
- Rukuje 403 greškama (sesija istekla)
- Prikazuje toastr greške automatski

```typescript
// src/shared/lib/api-client.ts
import axios, { AxiosInstance } from 'axios';

// Singleton — jednom kreiran, koristi se svuda
let instance: AxiosInstance | null = null;

export function getApiClient(): AxiosInstance {
  if (instance) return instance;

  instance = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL,
    headers: { 'Content-Type': 'application/json' },
  });

  // REQUEST interceptor — umata body u { entity: ... } format
  instance.interceptors.request.use((config) => {
    const isReadRequest = ['get', 'head', 'options'].includes(
      config.method?.toLowerCase() ?? ''
    );
    if (!isReadRequest && config.data) {
      config.data = {
        languageId: 0,
        channel: 'BPC',
        entity: config.data,
      };
    }
    return config;
  });

  // RESPONSE interceptor — izvlači payload, rukuje greškama
  instance.interceptors.response.use(
    (response) => {
      // Backend uvijek šalje { payload: ..., successful: true/false }
      const data = response.data;
      if (data && 'payload' in data) {
        return { ...response, data: data.payload };
      }
      return response;
    },
    async (error) => {
      if (error.response?.status === 401 || error.response?.status === 403) {
        // Provjeri da li je sesija istekla (isto kao UOM)
        try {
          await axios.get('/authentication-status');
        } catch {
          window.location.href = '/login';
        }
      }
      return Promise.reject(error);
    }
  );

  return instance;
}

export const api = getApiClient();
```

**Tipovi za API odgovore:**
```typescript
// src/shared/types/api.types.ts

// Svaki API odgovor sa servera ima ovu strukturu
export interface RestPayload<T = unknown> {
  payload: T;
  successful: boolean;
  responseCode?: number;
  responseDetail?: string;
  transactionId?: string;
  cache?: boolean;
}

// Standardna greška
export interface ApiError {
  status: number;
  message: string;
  detail?: string;
}
```

---

### 5.2 TanStack Query konfiguracija

```typescript
// src/shared/lib/query-client.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Podaci se smatraju svježim 2 minute
      staleTime: 2 * 60 * 1000,
      // Retry samo jednom pri grešci (ne retry za 404)
      retry: (failureCount, error: any) => {
        if (error?.response?.status === 404) return false;
        return failureCount < 1;
      },
      // Ne refetchovati u pozadini kad tab postane aktivan (za admin panele)
      refetchOnWindowFocus: false,
    },
    mutations: {
      // Automatski prikaži grešku (kombinuj sa toast notifikacijom)
      onError: (error: any) => {
        const message = error?.response?.data?.responseDetail ?? 'Greška pri čuvanju';
        // toast.error(message); ← dodati kad se integrira toast library
        console.error(message);
      },
    },
  },
});
```

**Primjer query hooka za products feature:**
```typescript
// src/features/products/hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi } from '../api/products.api';
import type { ProductFilters, CreateProductDto } from '../types/product.types';

// Query keys — centralizirani da se izbjegnu string greške
export const productKeys = {
  all: ['products'] as const,
  lists: () => [...productKeys.all, 'list'] as const,
  list: (filters: ProductFilters) => [...productKeys.lists(), filters] as const,
  details: () => [...productKeys.all, 'detail'] as const,
  detail: (id: string) => [...productKeys.details(), id] as const,
  versions: (id: string) => [...productKeys.detail(id), 'versions'] as const,
};

// Lista proizvoda sa filterima
export function useProducts(filters: ProductFilters) {
  return useQuery({
    queryKey: productKeys.list(filters),
    queryFn: () => productsApi.getProducts(filters),
    // Paralelizacija — useProducts se može pozvati sa više različitih filtera
    // i TanStack Query će automatski deduplikirati iste pozive
  });
}

// Jedan proizvod
export function useProduct(productId: string) {
  return useQuery({
    queryKey: productKeys.detail(productId),
    queryFn: () => productsApi.getProduct(productId),
    enabled: !!productId, // Ne pozivati ako nema ID-a
  });
}

// Verzije jednog proizvoda — paralelno sa useProduct
export function useProductVersions(productId: string) {
  return useQuery({
    queryKey: productKeys.versions(productId),
    queryFn: () => productsApi.getProductVersions(productId),
    enabled: !!productId,
  });
}

// Kreiranje novog proizvoda
export function useCreateProduct() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateProductDto) => productsApi.createProduct(data),
    onSuccess: () => {
      // Automatski invalidirati listu — sljedeći render povuče svježe podatke
      queryClient.invalidateQueries({ queryKey: productKeys.lists() });
    },
  });
}

// Publiciranje verzije
export function usePublishProduct() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ productId, versionId }: { productId: string; versionId: string }) =>
      productsApi.publishVersion(productId, versionId),
    onSuccess: (_, { productId }) => {
      queryClient.invalidateQueries({ queryKey: productKeys.detail(productId) });
      queryClient.invalidateQueries({ queryKey: productKeys.versions(productId) });
      queryClient.invalidateQueries({ queryKey: productKeys.lists() });
    },
  });
}
```

---

### 5.3 Zustand Store — domenski, ne mega-store

Za client-side state koji ne dolazi sa servera (UI state, preferences, temp state).

```typescript
// src/features/auth/store/auth.store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { User, UserRole } from '../types/auth.types';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  // Actions
  setUser: (user: User | null) => void;
  logout: () => void;
  hasPermission: (action: string, resource: string) => boolean;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      isAuthenticated: false,

      setUser: (user) => set({ user, isAuthenticated: !!user }),

      logout: () => set({ user: null, isAuthenticated: false }),

      hasPermission: (action, resource) => {
        const { user } = get();
        if (!user) return false;
        // Logika provjere permisija na osnovu user.roles
        return user.permissions.some(
          (p) => p.action === action && p.resource === resource
        );
      },
    }),
    {
      name: 'bpc-auth', // localStorage key
      partialize: (state) => ({ user: state.user }), // Persist samo user
    }
  )
);
```

```typescript
// src/features/products/store/products-ui.store.ts
// Za UI state koji nije server data (selected rows, expanded sections, itd.)
import { create } from 'zustand';

interface ProductsUiState {
  selectedProductIds: Set<string>;
  expandedSections: Set<string>;
  // Actions
  toggleProductSelection: (id: string) => void;
  clearSelection: () => void;
  toggleSection: (sectionId: string) => void;
}

export const useProductsUiStore = create<ProductsUiState>((set) => ({
  selectedProductIds: new Set(),
  expandedSections: new Set(),

  toggleProductSelection: (id) =>
    set((state) => {
      const next = new Set(state.selectedProductIds);
      next.has(id) ? next.delete(id) : next.add(id);
      return { selectedProductIds: next };
    }),

  clearSelection: () => set({ selectedProductIds: new Set() }),

  toggleSection: (sectionId) =>
    set((state) => {
      const next = new Set(state.expandedSections);
      next.has(sectionId) ? next.delete(sectionId) : next.add(sectionId);
      return { expandedSections: next };
    }),
}));
```

---

### 5.4 Role-Based Access Control

```typescript
// src/features/auth/types/auth.types.ts
export type UserRole = 'IDRP_EDITOR' | 'IDRP_APPROVER' | 'LEGAL' | 'IT_ADMIN' | 'READ_ONLY';

export interface Permission {
  action: 'create' | 'read' | 'update' | 'delete' | 'approve' | 'publish';
  resource: 'product' | 'version' | 'document' | 'user';
}

export interface User {
  id: string;
  username: string;
  email: string;
  roles: UserRole[];
  permissions: Permission[];
}

// Mapa permisija po ulozi — definisana na frontendu kao fallback
// Backend treba biti authoritative source
export const ROLE_PERMISSIONS: Record<UserRole, Permission[]> = {
  IDRP_EDITOR: [
    { action: 'create', resource: 'product' },
    { action: 'update', resource: 'product' },
    { action: 'read', resource: 'product' },
  ],
  IDRP_APPROVER: [
    { action: 'approve', resource: 'product' },
    { action: 'approve', resource: 'version' },
    { action: 'read', resource: 'product' },
  ],
  IT_ADMIN: [
    { action: 'create', resource: 'product' },
    { action: 'update', resource: 'product' },
    { action: 'delete', resource: 'product' },
    { action: 'publish', resource: 'version' },
    { action: 'read', resource: 'product' },
  ],
  LEGAL: [
    { action: 'update', resource: 'document' },
    { action: 'read', resource: 'product' },
  ],
  READ_ONLY: [
    { action: 'read', resource: 'product' },
  ],
};
```

```typescript
// src/features/auth/hooks/usePermission.ts
import { useAuthStore } from '../store/auth.store';

export function usePermission(action: Permission['action'], resource: Permission['resource']): boolean {
  return useAuthStore((state) => state.hasPermission(action, resource));
}

// Hook za provjeru multiple permisija odjednom
export function usePermissions(
  checks: Array<{ action: Permission['action']; resource: Permission['resource'] }>
): boolean[] {
  return useAuthStore((state) =>
    checks.map(({ action, resource }) => state.hasPermission(action, resource))
  );
}
```

```tsx
// src/features/auth/components/PermissionGate.tsx
// Skriva djecu ako korisnik nema permisiju — za UI elemente
interface PermissionGateProps {
  action: Permission['action'];
  resource: Permission['resource'];
  children: React.ReactNode;
  fallback?: React.ReactNode; // Šta prikazati ako nema permisije (default: ništa)
}

export function PermissionGate({ action, resource, children, fallback = null }: PermissionGateProps) {
  const hasPermission = usePermission(action, resource);
  return hasPermission ? <>{children}</> : <>{fallback}</>;
}

// Upotreba:
// <PermissionGate action="publish" resource="version">
//   <PublishButton />
// </PermissionGate>
```

```tsx
// src/features/auth/components/RoleGuard.tsx
// Štiti cijele rute od neautoriziranog pristupa
import { Navigate } from 'react-router-dom';

interface RoleGuardProps {
  roles: UserRole[];
  children: React.ReactNode;
  redirectTo?: string;
}

export function RoleGuard({ roles, children, redirectTo = '/unauthorized' }: RoleGuardProps) {
  const user = useAuthStore((state) => state.user);

  if (!user) return <Navigate to="/login" replace />;

  const hasRequiredRole = roles.some((role) => user.roles.includes(role));
  if (!hasRequiredRole) return <Navigate to={redirectTo} replace />;

  return <>{children}</>;
}
```

---

### 5.5 Routing sa Lazy Loading

```tsx
// src/app/routes.tsx
import { lazy, Suspense } from 'react';
import { createBrowserRouter, Outlet } from 'react-router-dom';
import { AppShell } from './layout/AppShell';
import { RoleGuard } from '../features/auth/components/RoleGuard';
import { Spinner } from '../shared/components/Spinner';
import { ErrorBoundary } from '../shared/components/ErrorBoundary';

// Svaka ruta se ucitava tek kad korisnik navigira na nju
// Ovo sprječava UOM-ov problem eager-loading svega odjednom
const ProductListPage = lazy(() => import('../features/products/pages/ProductListPage'));
const ProductDetailPage = lazy(() => import('../features/products/pages/ProductDetailPage'));
const ProductEditPage = lazy(() => import('../features/products/pages/ProductEditPage'));
const VersionTimelinePage = lazy(() => import('../features/versions/pages/VersionTimelinePage'));
const VersionDiffPage = lazy(() => import('../features/versions/pages/VersionDiffPage'));
const SearchPage = lazy(() => import('../features/search/pages/SearchPage'));
const DocumentPreviewPage = lazy(() => import('../features/documents/pages/DocumentPreviewPage'));

// Loading fallback za lazy komponente
const PageLoader = () => (
  <div className="flex items-center justify-center h-64">
    <Spinner size="lg" />
  </div>
);

export const router = createBrowserRouter([
  {
    path: '/',
    element: <AppShell />,
    errorElement: <ErrorBoundary />,
    children: [
      {
        index: true,
        element: <Navigate to="/products" replace />,
      },
      {
        path: 'products',
        element: (
          <Suspense fallback={<PageLoader />}>
            <Outlet />
          </Suspense>
        ),
        children: [
          { index: true, element: <ProductListPage /> },
          { path: ':productId', element: <ProductDetailPage /> },
          {
            path: ':productId/edit',
            element: (
              <RoleGuard roles={['IDRP_EDITOR', 'IT_ADMIN']}>
                <ProductEditPage />
              </RoleGuard>
            ),
          },
          {
            path: ':productId/versions',
            element: <VersionTimelinePage />,
          },
          {
            path: ':productId/versions/diff',
            element: <VersionDiffPage />,
          },
        ],
      },
      {
        path: 'search',
        element: (
          <Suspense fallback={<PageLoader />}>
            <SearchPage />
          </Suspense>
        ),
      },
      {
        path: 'documents/:documentId',
        element: (
          <Suspense fallback={<PageLoader />}>
            <DocumentPreviewPage />
          </Suspense>
        ),
      },
    ],
  },
  {
    path: '/login',
    element: <LoginPage />,
  },
]);
```

---

### 5.6 Dynamic Form Engine

Ovo je direktna inspiracija iz UOM z-dynamic engine-a, ali implementirana na React način.

**Tipovi za schema:**
```typescript
// src/dynamic-forms/types/schema.types.ts

// Tip polja
export type FieldTemplate =
  | 'text'
  | 'number'
  | 'select'
  | 'multiselect'
  | 'date'
  | 'datetime'
  | 'checkbox'
  | 'textarea'
  | 'autocomplete';

// Dependency efekat (iz UOM DependencyManager-a)
export type DependencyEffect =
  | 'activate'
  | 'deactivate'
  | 'reset'
  | 'refresh'
  | 'required'
  | 'disabled'
  | 'setvalue';

export interface FieldDependency {
  field: string;           // Polje koje se promatra
  value?: unknown;         // Vrijednost koja okida efekat (ako nema, svaka promjena)
  effect: DependencyEffect;
  targetValue?: unknown;   // Za 'setvalue' efekat
}

// Validacija
export interface FieldValidation {
  required?: boolean;
  min?: number;
  max?: number;
  pattern?: string;         // Regex pattern
  asyncValidator?: string;  // API endpoint za async validaciju
}

// Schema jednog polja forme (inspirisana UOM InputObject-om)
export interface FieldSchema {
  name: string;
  template: FieldTemplate;
  label: string;
  placeholder?: string;
  defaultValue?: unknown;
  validation?: FieldValidation;
  dependencies?: FieldDependency[];
  options?: Array<{ value: string; label: string }>; // Za select
  optionsApi?: string;    // API endpoint za dinamičke opcije
  optionsApiParams?: Record<string, string>; // Params za options API (može referencirati druga polja: "#fieldName")
  disabled?: boolean;
  hidden?: boolean;
  section?: string;       // Za grupisanje polja u sekcije
  order?: number;
}

// Schema cijele forme
export interface FormSchema {
  id: string;
  fields: FieldSchema[];
  sections?: Array<{ id: string; label: string; collapsed?: boolean }>;
}
```

**DynamicForm — glavni renderer:**
```tsx
// src/dynamic-forms/DynamicForm.tsx
import { useForm, FormProvider } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { DynamicField } from './DynamicField';
import { buildZodSchema } from './ValidationManager';
import { useDependencies } from './DependencyManager';

interface DynamicFormProps {
  schema: FormSchema;
  defaultValues?: Record<string, unknown>;
  onSubmit: (values: Record<string, unknown>) => void | Promise<void>;
  disabled?: boolean;
}

export function DynamicForm({ schema, defaultValues, onSubmit, disabled }: DynamicFormProps) {
  // Zod schema se gradi dynamički iz FormSchema validacionih pravila
  const zodSchema = useMemo(() => buildZodSchema(schema.fields), [schema]);

  const methods = useForm({
    resolver: zodResolver(zodSchema),
    defaultValues: defaultValues ?? buildDefaultValues(schema.fields),
    mode: 'onChange',
  });

  const { fieldStates } = useDependencies(schema.fields, methods.watch);

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)} noValidate>
        {schema.sections ? (
          schema.sections.map((section) => (
            <FormSection key={section.id} section={section}>
              {schema.fields
                .filter((f) => f.section === section.id)
                .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
                .map((field) => (
                  <DynamicField
                    key={field.name}
                    schema={field}
                    state={fieldStates[field.name]}
                    disabled={disabled}
                  />
                ))}
            </FormSection>
          ))
        ) : (
          schema.fields.map((field) => (
            <DynamicField
              key={field.name}
              schema={field}
              state={fieldStates[field.name]}
              disabled={disabled}
            />
          ))
        )}
        <button type="submit" disabled={methods.formState.isSubmitting}>
          {methods.formState.isSubmitting ? 'Čuvanje...' : 'Sačuvaj'}
        </button>
      </form>
    </FormProvider>
  );
}
```

**DependencyManager — srce cross-field logike:**
```typescript
// src/dynamic-forms/DependencyManager.ts
import { useEffect, useState, useCallback } from 'react';
import { UseFormWatch } from 'react-hook-form';

interface FieldState {
  hidden: boolean;
  disabled: boolean;
  required: boolean;
  refreshKey: number; // Increment da se triggera refresh opcija
}

const DEFAULT_FIELD_STATE: FieldState = {
  hidden: false,
  disabled: false,
  required: false,
  refreshKey: 0,
};

export function useDependencies(
  fields: FieldSchema[],
  watch: UseFormWatch<Record<string, unknown>>
) {
  const [fieldStates, setFieldStates] = useState<Record<string, FieldState>>(
    () => Object.fromEntries(fields.map((f) => [f.name, { ...DEFAULT_FIELD_STATE, hidden: f.hidden ?? false, disabled: f.disabled ?? false, required: f.validation?.required ?? false }]))
  );

  // Izgraditi reverse-lookup mapu: koji field ovisi o kojim fieldovima
  // (inspirisano UOM DependencyManager.revertItem)
  const dependencyMap = useMemo(() => {
    const map = new Map<string, Array<{ targetField: string; dep: FieldDependency }>>();
    fields.forEach((field) => {
      field.dependencies?.forEach((dep) => {
        if (!map.has(dep.field)) map.set(dep.field, []);
        map.get(dep.field)!.push({ targetField: field.name, dep });
      });
    });
    return map;
  }, [fields]);

  const applyDependencies = useCallback((changedField: string, value: unknown, allValues: Record<string, unknown>) => {
    const effects = dependencyMap.get(changedField);
    if (!effects) return;

    setFieldStates((prev) => {
      const next = { ...prev };
      effects.forEach(({ targetField, dep }) => {
        // Provjeri da li je uvjet ispunjen
        const conditionMet = dep.value === undefined || dep.value === value;
        if (!conditionMet) return;

        const current = next[targetField] ?? { ...DEFAULT_FIELD_STATE };
        switch (dep.effect) {
          case 'activate':
            next[targetField] = { ...current, hidden: false };
            break;
          case 'deactivate':
            next[targetField] = { ...current, hidden: true };
            break;
          case 'required':
            next[targetField] = { ...current, required: true };
            break;
          case 'disabled':
            next[targetField] = { ...current, disabled: true };
            break;
          case 'refresh':
            next[targetField] = { ...current, refreshKey: current.refreshKey + 1 };
            break;
          // 'reset' i 'setvalue' se handle-uju u DynamicField
        }
      });
      return next;
    });
  }, [dependencyMap]);

  // Watch sve fieldove i okidaj dependency logiku
  useEffect(() => {
    const subscription = watch((values, { name, type }) => {
      if (!name || type !== 'change') return;
      applyDependencies(name, values[name], values);
    });
    return () => subscription.unsubscribe();
  }, [watch, applyDependencies]);

  return { fieldStates };
}
```

---

### 5.7 Performance Obrasci

#### Paralelni API pozivi (elimisanje waterfall-a)

Ovo je kritično za product detail stranicu gdje se paralelno učitavaju informacije o proizvodu, verzijama i dokumentima.

```tsx
// src/features/products/pages/ProductDetailPage.tsx
import { Suspense } from 'react';
import { useParams } from 'react-router-dom';
import { useProduct, useProductVersions } from '../hooks/useProducts';

// ❌ IZBJEGAVATI — waterfall pattern
function ProductDetailWaterfall({ productId }: { productId: string }) {
  const { data: product } = useProduct(productId);
  // Ovo čeka da product bude učitan, pa tek onda počinje učitavati verzije
  const { data: versions } = useProductVersions(product?.id ?? '');
  // ...
}

// ✅ ISPRAVNO — Suspense streaming pattern
// Svaka sekcija se renderuje čim njeni podaci stignu, neovisno od ostalih
export function ProductDetailPage() {
  const { productId } = useParams<{ productId: string }>();

  return (
    <div className="space-y-6">
      {/* Brzi podaci — nema Suspense, inline loader */}
      <Suspense fallback={<ProductHeaderSkeleton />}>
        <ProductHeader productId={productId!} />
      </Suspense>

      <div className="grid grid-cols-2 gap-6">
        {/* Verzije i dokumenti se učitavaju paralelno, neovisno jedni od drugih */}
        <Suspense fallback={<SectionSkeleton />}>
          <ProductVersionsSection productId={productId!} />
        </Suspense>

        <Suspense fallback={<SectionSkeleton />}>
          <ProductDocumentsSection productId={productId!} />
        </Suspense>
      </div>
    </div>
  );
}
```

#### Re-render optimizacija za tablice i liste

```tsx
// src/features/products/components/ProductTable.tsx
import { memo, useMemo, useCallback } from 'react';

// Stabilni default props — hoistani van komponente da ne stvaraju novi objekt svaki render
const DEFAULT_COLUMNS: ColumnDef<Product>[] = [];
const DEFAULT_DATA: Product[] = [];

// memo sprječava re-render ako props nisu promijenjeni
const ProductRow = memo(function ProductRow({
  product,
  isSelected,
  onSelect,
}: {
  product: Product;
  isSelected: boolean;
  onSelect: (id: string) => void;
}) {
  // useCallback za stabilan reference na handler
  const handleSelect = useCallback(() => onSelect(product.id), [product.id, onSelect]);

  return (
    <tr onClick={handleSelect} className={isSelected ? 'bg-blue-50' : ''}>
      <td>{product.name}</td>
      <td>{product.category}</td>
      <td><ProductStatusBadge status={product.status} /></td>
    </tr>
  );
});

export function ProductTable({
  products = DEFAULT_DATA,
  columns = DEFAULT_COLUMNS,
}: ProductTableProps) {
  const selectedIds = useProductsUiStore((state) => state.selectedProductIds);
  const toggleSelection = useProductsUiStore((state) => state.toggleProductSelection);

  // Map index za O(1) membership provjeru umjesto O(n) Array.includes()
  const productIndex = useMemo(
    () => new Map(products.map((p) => [p.id, p])),
    [products]
  );

  return (
    <table>
      <tbody>
        {products.map((product) => (
          <ProductRow
            key={product.id}
            product={product}
            isSelected={selectedIds.has(product.id)} // O(1) lookup
            onSelect={toggleSelection}
          />
        ))}
      </tbody>
    </table>
  );
}
```

#### useTransition za publish workflow

```tsx
// src/features/versions/components/PublishWorkflow.tsx
import { useTransition } from 'react';
import { usePublishProduct } from '../../products/hooks/useProducts';

export function PublishButton({ productId, versionId }: { productId: string; versionId: string }) {
  const [isPending, startTransition] = useTransition();
  const { mutateAsync: publish } = usePublishProduct();

  const handlePublish = () => {
    // startTransition označava ovu operaciju kao ne-hitnu
    // UI ostaje interaktivan tokom publishinga
    startTransition(async () => {
      await publish({ productId, versionId });
    });
  };

  return (
    <button
      onClick={handlePublish}
      disabled={isPending}
      className="btn-primary"
    >
      {isPending ? 'Objavljivanje...' : 'Objavi verziju'}
    </button>
  );
}
```

---

### 5.8 localStorage sa Schema Verzioniranjem

BPC čuva korisničke pretrage i filtre lokalno. Bitno je verzionirati shemu da se izbjegnu problemi kad se struktura promijeni.

```typescript
// src/shared/hooks/useLocalStorage.ts
import { useState } from 'react';

interface VersionedSchema<T> {
  version: number;
  data: T;
}

export function useVersionedLocalStorage<T>(
  key: string,
  defaultValue: T,
  schemaVersion: number
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      if (!item) return defaultValue;

      const parsed: VersionedSchema<T> = JSON.parse(item);

      // Ako verzija ne odgovara, vrati default (ignorisi stare podatke)
      if (parsed.version !== schemaVersion) {
        localStorage.removeItem(key);
        return defaultValue;
      }

      return parsed.data;
    } catch {
      return defaultValue;
    }
  });

  const setValue = (value: T) => {
    const versioned: VersionedSchema<T> = { version: schemaVersion, data: value };
    localStorage.setItem(key, JSON.stringify(versioned));
    setStoredValue(value);
  };

  return [storedValue, setValue];
}

// Primjer upotrebe za saved search pretrage:
// const [savedSearches, setSavedSearches] = useVersionedLocalStorage(
//   'bpc_saved_searches',
//   [],
//   2  // Povećaj ovo kad se struktura promijeni
// );
```

---

### 5.9 Verzioniranje i Diff Viewer

```tsx
// src/features/versions/components/VersionTimeline.tsx
import { useProductVersions } from '../../products/hooks/useProducts';

interface Version {
  id: string;
  versionNumber: string;
  status: 'DRAFT' | 'IN_REVIEW' | 'APPROVED' | 'PUBLISHED';
  createdAt: string;
  createdBy: string;
  changes?: string;
}

const STATUS_CONFIG = {
  DRAFT: { label: 'Nacrt', color: 'bg-gray-100 text-gray-700' },
  IN_REVIEW: { label: 'Na pregledu', color: 'bg-yellow-100 text-yellow-700' },
  APPROVED: { label: 'Odobreno', color: 'bg-blue-100 text-blue-700' },
  PUBLISHED: { label: 'Objavljeno', color: 'bg-green-100 text-green-700' },
};

export function VersionTimeline({ productId }: { productId: string }) {
  const { data: versions, isLoading } = useProductVersions(productId);
  const [compareVersions, setCompareVersions] = useState<[string?, string?]>([]);

  if (isLoading) return <TimelineSkeleton />;

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2>Historija verzija</h2>
        {compareVersions.filter(Boolean).length === 2 && (
          <Link to={`/products/${productId}/versions/diff?v1=${compareVersions[0]}&v2=${compareVersions[1]}`}>
            Uporedi odabrane verzije
          </Link>
        )}
      </div>

      <ol className="relative border-l border-gray-200">
        {versions?.map((version) => {
          const config = STATUS_CONFIG[version.status];
          return (
            <li key={version.id} className="mb-10 ml-6">
              <span className="absolute -left-3 w-6 h-6 rounded-full bg-white border-2 border-gray-200" />
              <div className="flex items-center gap-3">
                <span className="font-mono text-sm font-bold">v{version.versionNumber}</span>
                <span className={`px-2 py-0.5 rounded text-xs font-medium ${config.color}`}>
                  {config.label}
                </span>
                <time className="text-xs text-gray-500">{formatDate(version.createdAt)}</time>
              </div>
              <p className="mt-1 text-sm text-gray-600">{version.changes}</p>
              <p className="text-xs text-gray-400">Kreirao: {version.createdBy}</p>
            </li>
          );
        })}
      </ol>
    </div>
  );
}
```

---

### 5.10 Napredna Pretraga

```tsx
// src/features/search/components/FacetedFilters.tsx
// Inspirisano UOM GlobalSearchComponent ali čišće implementirano
import { useCallback } from 'react';
import { useUrlState } from '../../shared/hooks/useUrlState';

// Filteri se sinkroniziraju sa URL parametrima — korisnik može kopirati URL
export function ProductSearch() {
  const [filters, setFilters] = useUrlState<ProductFilters>({
    query: '',
    category: '',
    status: '',
    dateFrom: '',
    dateTo: '',
  });

  const debouncedQuery = useDebounce(filters.query, 300);

  const searchFilters = useMemo(
    () => ({ ...filters, query: debouncedQuery }),
    [filters, debouncedQuery]
  );

  const { data, isLoading, isFetching } = useProducts(searchFilters);

  return (
    <div className="grid grid-cols-4 gap-6">
      <aside className="col-span-1">
        <SearchFiltersPanel filters={filters} onChange={setFilters} />
      </aside>
      <main className="col-span-3">
        <SearchBar
          value={filters.query}
          onChange={(query) => setFilters((prev) => ({ ...prev, query }))}
          isSearching={isFetching}
        />
        {isLoading ? (
          <SearchResultsSkeleton />
        ) : (
          <SearchResults products={data?.items ?? []} total={data?.total ?? 0} />
        )}
      </main>
    </div>
  );
}
```

---

## 6. Konvencije i pravila

### TypeScript

```json
// tsconfig.json — striktni mode od prvog dana
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

### Imenovanje

| Šta | Konvencija | Primjer |
|---|---|---|
| Komponente | PascalCase | `ProductForm.tsx` |
| Hooks | camelCase sa `use` prefiksom | `useProducts.ts` |
| Store | camelCase + `.store.ts` sufiks | `auth.store.ts` |
| API moduli | camelCase + `.api.ts` sufiks | `products.api.ts` |
| Tipovi | camelCase + `.types.ts` sufiks | `product.types.ts` |
| Stranice | PascalCase + `Page` sufiks | `ProductListPage.tsx` |
| CSS klase | Tailwind utility klase | `className="flex items-center gap-4"` |

### Uvoz — direktni, ne barrel

```typescript
// ❌ IZBJEGAVATI — barrel uvoz vuče cijeli modul u bundle
import { ProductForm, ProductList, useProducts } from '@/features/products';

// ✅ ISPRAVNO — direktni uvoz, bundler uključi samo što treba
import { ProductForm } from '@/features/products/components/ProductForm';
import { useProducts } from '@/features/products/hooks/useProducts';
```

### Conditional rendering — uvijek ternary

```tsx
// ❌ ZAMKA — 0 se renderuje kao "0" u DOM-u
{products.length && <ProductList />}

// ✅ ISPRAVNO
{products.length > 0 ? <ProductList products={products} /> : <EmptyState />}

// ✅ ISPRAVNO — za boolean uvjet
{isLoading ? <Spinner /> : <Content />}
```

### Effects — samo za nužne slučajeve

```tsx
// ❌ IZBJEGAVATI — effect za derived state je spor
const [filtered, setFiltered] = useState([]);
useEffect(() => {
  setFiltered(products.filter(p => p.status === status));
}, [products, status]);

// ✅ ISPRAVNO — izračunaj tokom rendera
const filtered = useMemo(
  () => products.filter(p => p.status === status),
  [products, status]
);

// ❌ IZBJEGAVATI — effect za event handling
useEffect(() => {
  if (isSubmitting) {
    handleSave();
  }
}, [isSubmitting]);

// ✅ ISPRAVNO — event handling u event handleru
const handleSubmit = async () => {
  await handleSave();
};
```

---

## 7. Environment varijable

```bash
# .env.example — kopirati u .env.local za lokalni razvoj

# API base URL
VITE_API_BASE_URL=http://localhost:8080

# Da li koristiti mock podatke (za razvoj bez backend-a)
VITE_USE_MOCK_DATA=false

# Feature flags
VITE_FEATURE_PDF_GENERATION=true
VITE_FEATURE_ADVANCED_SEARCH=true
```

---

## 8. Prioriteti implementacije (redoslijed razvoja)

### Faza A — Temelji (Sprint 1-2)

1. **Projektni setup**
   - Vite + React + TypeScript (striktni)
   - Tailwind CSS + shadcn/ui inicijalizacija
   - React Router v7 sa lazy loading strukturom
   - Axios klijent sa interceptorima (sekcija 5.1)
   - TanStack Query konfiguracija (sekcija 5.2)
   - ESLint + Prettier konfiguracija

2. **Auth + Role sistem**
   - Login forma
   - Zustand auth store sa persist (sekcija 5.3)
   - `usePermission` hook (sekcija 5.4)
   - `PermissionGate` i `RoleGuard` komponente (sekcija 5.4)
   - Zaštita ruta

### Faza B — Core Features (Sprint 3-5)

3. **Product CRUD**
   - `useProducts`, `useProduct`, `useCreateProduct` hooks (sekcija 5.2)
   - `ProductListPage` sa tablicom i paginacijom
   - `ProductDetailPage` sa Suspense streaming (sekcija 5.7)
   - Dynamic Form Engine za admin forme (sekcija 5.6)
   - Dependency i Validation manager

4. **Napredna pretraga** (sekcija 5.10)
   - Faceted filteri
   - URL state sinkronizacija
   - Debounced search
   - Saved searches sa verzioniranjem (sekcija 5.8)

### Faza C — Verzioniranje i Dokumenti (Sprint 6-8)

5. **Verzioniranje** (sekcija 5.9)
   - Version timeline komponenta
   - Diff viewer između verzija
   - Publish workflow (Draft→Review→Approved→Published)
   - `useTransition` za publish akcije (sekcija 5.7)

6. **PDF generisanje**
   - Document preview sa `react-pdf`
   - Template editor sa TipTap
   - Download mehanizam

### Faza D — Integracije i Polishing (Sprint 9-10)

7. **API integracije** sa chatbot, JPP, mobilnom app
8. **Performance optimizacije** (virtualizacija lista, bundle analiza)
9. **Testiranje** (Vitest + React Testing Library)
10. **Accessibility** pregled

---

## 9. Checklist za code review

Svaki PR treba proći sljedeće provjere:

**Performans:**
- [ ] Nema waterfall API poziva (koristi `Promise.all` ili paralelne `useQuery` hookove)
- [ ] Koristi `useMemo` za skupo izračunavanje
- [ ] Koristi `useCallback` za event handlere koji se prosljeđuju kao props
- [ ] Nema barrel importa iz feature foldera
- [ ] Nove teške komponente su lazy-loadvane

**Patterns:**
- [ ] Server state je u TanStack Query, ne u lokalnom `useState`
- [ ] Nema `useEffect` za derived state (koristi `useMemo`)
- [ ] Conditional rendering koristi ternary, ne `&&` sa non-boolean vrijednostima
- [ ] localStorage podatak ima verzioniranu shemu
- [ ] Default prop vrijednosti su hoistane van komponente (ne `defaultValue={[]}`)

**TypeScript:**
- [ ] Nema `any` tipova
- [ ] Sve API response funkcije imaju generičke tipove
- [ ] Svi eventi su tipizovani

**Sigurnost:**
- [ ] RBAC provjere su na UI-u I na backendu (nikad samo frontend)
- [ ] Nema hardkodiranih API ključeva ili tokena
- [ ] Korisničke permisije se provjeravaju u `PermissionGate`

---

## 10. Ključne datoteke koje treba kreirati prva (Bootstrap order)

```
1. vite.config.ts
2. tsconfig.json (sa paths aliasima)
3. src/shared/lib/api-client.ts     ← Axios sa interceptorima
4. src/shared/lib/query-client.ts   ← TanStack Query setup
5. src/app/providers.tsx             ← Wrap-uje sve providere
6. src/app/App.tsx                   ← Root komponenta
7. src/app/routes.tsx                ← Sve rute
8. src/features/auth/               ← Auth cijeli feature
9. src/dynamic-forms/               ← Form engine
10. src/features/products/           ← Core feature
```

---

*Dokument kreiran: Februar 2026. Autor: Kenan Sabljaković, uz asistenciju Claude Code-a.*
*Baziran na analizi postojećeg UOM Angular projekta i Vercel React Best Practices smjernicama.*
