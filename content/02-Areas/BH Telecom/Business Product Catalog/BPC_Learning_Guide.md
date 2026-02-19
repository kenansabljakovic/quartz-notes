# BPC Frontend — Vodič za učenje

> Strukturisani plan učenja za razvoj BPC frontend aplikacije u Reactu.
> Procijenjeno trajanje: **4-6 mjeseci** uz 1-2 sata učenja dnevno.

---

## Faza 0 — Preduslovi (2-3 sedmice)

### HTML i CSS osnove

**Šta je:** Struktura (HTML) i izgled (CSS) svake web stranice. React piše HTML kroz JSX, Tailwind CSS je CSS koji pišeš direktno u HTML klasama.

**Resursi:**
- [MDN Web Docs — HTML](https://developer.mozilla.org/en-US/docs/Learn/HTML)
- [MDN Web Docs — CSS](https://developer.mozilla.org/en-US/docs/Learn/CSS)
- [CSS Flexbox Froggy](https://flexboxfroggy.com/) — interaktivna igra za Flexbox
- [CSS Grid Garden](https://cssgridgarden.com/) — interaktivna igra za Grid

**Šta praktikovati:** Napravi statičku HTML stranicu sa navigacijom, tablicom i formom. Stilizuj je ručnim CSS-om.

---

### JavaScript osnove (ES6+)

**Šta je:** Programski jezik koji React koristi. Moraš znati moderne JS koncepte jer se koriste svuda u kodu.

**Ključni koncepti koji se direktno koriste u BPC:**

| Koncept | Gdje se koristi u BPC |
|---|---|
| `const`, `let` | Svugdje |
| Arrow funkcije `() => {}` | Svugdje u Reactu |
| Destructuring `{ a, b } = obj` | Props, state, API odgovori |
| Spread operator `...` | Ažuriranje state-a |
| `Promise`, `async/await` | Svi API pozivi |
| `Promise.all()` | Paralelni API pozivi |
| Array metode: `map`, `filter`, `find`, `reduce` | Liste proizvoda, filtriranje |
| `Map` i `Set` | Performansni lookupovi u tablicama |
| Optional chaining `?.` | Sigurno čitanje API odgovora |
| Nullish coalescing `??` | Default vrijednosti |
| Template literals | String formatiranje |
| Modules `import/export` | Svaki fajl u projektu |

**Resursi:**
- [JavaScript.info](https://javascript.info/) — **najpreporučeniji**, besplatan, izuzetno detaljan
- [Eloquent JavaScript](https://eloquentjavascript.net/) — besplatna knjiga
- [freeCodeCamp — JavaScript Algorithms](https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures/) — interaktivno

**Šta praktikovati:** Napiši funkciju koja uzima listu proizvoda i vraća filtrirane, sortirane i grupisane po kategoriji. Koristi `filter`, `sort`, `reduce`, `Map`.

---

## Faza 1 — TypeScript (1-2 sedmice)

**Analogija:** JavaScript je kao pisanje poruke bez pravopisne provjere — greške vidiš tek kad pošalješ. TypeScript je kao Word sa crvenim podvlakama — greške vidiš dok pišeš.

**Zašto je kritičan za BPC:** Cijeli projekt koristi `strict: true` TypeScript. Svaki API odgovor, svaka props komponente, svaki store ima definirane tipove.

**Ključni koncepti:**

| Koncept | Primjer iz BPC |
|---|---|
| Osnovni tipovi | `string`, `number`, `boolean`, `null`, `undefined` |
| Interface | `interface Product { id: string; name: string; }` |
| Type | `type UserRole = 'ADMIN' \| 'EDITOR' \| 'VIEWER'` |
| Generics | `useQuery<Product>()`, `Promise<Product[]>` |
| Optional props | `interface Props { label?: string }` |
| Union types | `'DRAFT' \| 'PUBLISHED' \| 'APPROVED'` |
| Utility types | `Partial<Product>`, `Pick<Product, 'id' \| 'name'>` |
| `as const` | Za query keys: `['products'] as const` |
| `Record<K, V>` | `Record<UserRole, Permission[]>` |
| Type narrowing | `if (error instanceof Error) { error.message }` |

**Resursi:**
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html) — oficijalna dokumentacija
- [Total TypeScript — Free Tutorials](https://www.totaltypescript.com/tutorials) — **visoko preporučeno**, praktično
- [Execute Program — TypeScript](https://www.executeprogram.com/courses/typescript) — interaktivno

**Šta praktikovati:** Uzmi JS kod iz prethodne vježbe i prepiši ga u TypeScript. Definiši `interface` za `Product` i `ProductFilter`.

---

## Faza 2 — React osnove (3-4 sedmice)

**Analogija:** React je kao LEGO. Gradi male, višekratno upotrebljive komponente (kockice) i sklapaš ih u veće cjeline (stranicu).

**Resursi (opšti):**
- [React oficijalna dokumentacija (nova)](https://react.dev/learn) — **obavezan**
- [Scrimba — Learn React for Free](https://scrimba.com/learn/learnreact)

### 2.1 Fundamentalni koncepti

**Naučiti redom:**

1. **JSX** — HTML koji pišeš u JavaScript fajlu
   ```tsx
   function ProductCard({ name, price }: { name: string; price: number }) {
     return (
       <div className="card">
         <h2>{name}</h2>
         <p>{price} KM</p>
       </div>
     );
   }
   ```

2. **Props** — Prosljeđivanje podataka od roditelja ka djetetu

3. **State sa `useState`** — Interno pamćenje komponente
   ```tsx
   const [isOpen, setIsOpen] = useState(false);
   ```

4. **`useEffect`** — Pokretanje koda kao "side effect"
   > **Važno za BPC:** Treba izbjegavati `useEffect` za derived state i event handling. Naučiti KADA ga koristiti i kada ne.

5. **Conditional rendering** — Uvijek ternary, nikad `&&` sa non-boolean vrijednostima
   ```tsx
   {products.length > 0 ? <ProductList /> : <EmptyState />}
   ```

6. **Lists i keys**
   ```tsx
   {products.map(p => <ProductCard key={p.id} {...p} />)}
   ```

7. **Event handling** — `onClick`, `onChange`, `onSubmit`

8. **Lifting state up** — Callback funkcije za komunikaciju dijete → roditelj

9. **Composition** — `children` prop

**Šta praktikovati:** Napravi React aplikaciju: lista proizvoda u tablici, filter po kategoriji, modal za detalje. Bez vanjskih biblioteka.

---

### 2.2 Napredni React koncepti (kritični za BPC)

#### `useMemo` i `useCallback`

**Šta su:** Alati za optimizaciju koji sprječavaju nepotrebno ponovono izračunavanje i kreiranje funkcija.

**Analogija:** `useMemo` je kao kalkulator koji pamti zadnji rezultat — ako su ulazni podaci isti, ne računa ponovo. `useCallback` radi isto za funkcije.

```tsx
// useMemo — filtriranje liste u BPC
const filteredProducts = useMemo(
  () => products.filter(p => p.status === selectedStatus),
  [products, selectedStatus]
);

// useCallback — event handleri koji se prosljeđuju djeci
const handleSelect = useCallback(
  (id: string) => toggleSelection(id),
  [toggleSelection]
);
```

**Resursi:**
- [React docs — useMemo](https://react.dev/reference/react/useMemo)
- [React docs — useCallback](https://react.dev/reference/react/useCallback)
- [When to useMemo and useCallback — Kent C. Dodds](https://kentcdodds.com/blog/usememo-and-usecallback)

---

#### `memo`

**Šta je:** Omota komponentu i sprječava njen re-render ako se props nije promijenio.

**Gdje se koristi u BPC:** `ProductRow` u tablici — tablice mogu imati stotine redova, ne smijemo re-renderovati sve kad se jedan promijeni.

**Resurs:** [React docs — memo](https://react.dev/reference/react/memo)

---

#### `lazy` i `Suspense` — Code Splitting

**Šta je:** Umjesto da se cijela aplikacija učita odjednom, React može učitati dijelove tek kad su potrebni.

**Analogija:** Kao da u knjižari ne kupuješ sve knjige odjednom, već samo onu koju čitaš trenutno.

```tsx
const ProductListPage = lazy(() => import('./ProductListPage'));

<Suspense fallback={<Spinner />}>
  <ProductListPage />
</Suspense>
```

**Resursi:**
- [React docs — lazy](https://react.dev/reference/react/lazy)
- [React docs — Suspense](https://react.dev/reference/react/Suspense)

---

#### `useTransition`

**Šta je:** Označava operaciju kao "ne-hitnu" — UI ostaje responsivan dok se ona izvršava.

**Gdje se koristi u BPC:** Publish dugme — kad korisnik klikne "Objavi verziju", UI ne smije biti zamrznut dok API poziv traje.

**Resurs:** [React docs — useTransition](https://react.dev/reference/react/useTransition)

---

#### `useRef`

**Šta je:** Pamti vrijednost između rendera bez da izaziva re-render. Također direktan pristup DOM elementu.

**Resurs:** [React docs — useRef](https://react.dev/reference/react/useRef)

---

#### Context API

**Šta je:** Prosljeđuje podatke duboko u stablo komponenti bez "prop drilling".

**Napomena za BPC:** Koristi se umjereno — za auth i theme. Za kompleksniji state koristimo Zustand.

**Resurs:** [React docs — createContext](https://react.dev/reference/react/createContext)

---

## Faza 3 — Tailwind CSS (1 sedmica)

**Šta je:** CSS koji pišeš direktno u HTML klasama, bez pisanja CSS fajlova.

**Analogija:** Umjesto da odeš u krojačnicu i naručiš odijelo (pisanje CSS-a od nule), biraš gotove dijelove sa police (Tailwind utility klase) i slažeš ih.

```tsx
// Umjesto CSS fajla sa .card klasom, pišeš direktno u JSX:
<div className="flex p-4 rounded-lg shadow-md bg-white">
```

**Resursi:**
- [Tailwind CSS Dokumentacija](https://tailwindcss.com/docs) — izuzetno dobra, sa interaktivnim primjerima
- [Tailwind CSS kurs — The Net Ninja](https://www.youtube.com/playlist?list=PL4cUxeGkcC9gpXORlEHjc5bgnIi5HEGhw)
- [Tailwind Play](https://play.tailwindcss.com/) — online playground

**Šta praktikovati:** Prepraviti prethodnu React aplikaciju sa Tailwindom. Fokus na: flex, grid, spacing (`p-`, `m-`, `gap-`), colours, borders, shadows, responsive prefixes (`md:`, `lg:`).

---

## Faza 4 — shadcn/ui (3-5 dana)

**Šta je:** Kolekcija gotovih React komponenti (dugmad, modali, tablice, forme) koja koriste Tailwind za stilizaciju. Komponente se kopiraju direktno u tvoj projekt — nisu vanjska zavisnost.

**Analogija:** IKEA kit — dobiješ gotove dijelove koje možeš prilagoditi.

**Ključne komponente koje BPC koristi:**
- `Button`, `Input`, `Select`, `Checkbox`, `Textarea`
- `Dialog` (modal prozori)
- `Table`
- `Badge` (status oznake: Draft, Published...)
- `Tabs`, `Dropdown Menu`, `Toast`

**Resursi:**
- [shadcn/ui Dokumentacija](https://ui.shadcn.com/)
- [shadcn/ui — Getting Started](https://ui.shadcn.com/docs/installation)

---

## Faza 5 — React Router v7 (3-5 dana)

**Šta je:** Biblioteka za navigaciju — preklapa URL adrese sa React komponentama.

**Analogija:** Poštanski sistem — svaka adresa (URL) odgovara određenoj lokaciji (komponenti/stranici).

**Koncepti koji se koriste u BPC:**

| Koncept | Primjer |
|---|---|
| `createBrowserRouter` | Konfiguracija svih ruta |
| `<RouterProvider>` | Omata cijelu aplikaciju |
| `<Outlet>` | Gdje se renderuje child ruta |
| `useParams` | Čita `:productId` iz URL-a |
| `useNavigate` | Programatska navigacija |
| `useSearchParams` | Čita/piše URL query parametre (`?status=DRAFT`) |
| `<Navigate>` | Redirect komponenta |

**Resursi:**
- [React Router Dokumentacija](https://reactrouter.com/start/library/installation)
- [React Router Tutorial](https://reactrouter.com/start/library/routing)

**Šta praktikovati:** Dodaj routing u aplikaciju — `ProductListPage`, `ProductDetailPage` sa `:id` parametrom, navigacija između stranica.

---

## Faza 6 — Axios i HTTP komunikacija (3-5 dana)

**Šta je:** Biblioteka za slanje HTTP zahtjeva (GET, POST, PUT, DELETE) ka backend API-u.

**Zašto Axios, a ne `fetch`:** Axios ima interceptore — možeš "presresti" svaki request ili response i automatski nešto uraditi (dodati auth header, unwrapati payload, handlovati 403 grešku).

**Ključni koncepti:**

| Koncept | Kako se koristi u BPC |
|---|---|
| `axios.create()` | Kreiranje instance sa base URL-om |
| `interceptors.request` | Automatski umata body u `{ entity: ... }` format |
| `interceptors.response` | Automatski izvlači `payload` iz odgovora |
| Error interceptor | Detektuje 403 i redirectuje na login |
| `Promise.all()` | Paralelni API pozivi |

**Resursi:**
- [Axios Dokumentacija](https://axios-http.com/docs/intro)
- [Axios Interceptors Tutorial — Fireship](https://www.youtube.com/watch?v=ZieIroC9zbI)

---

## Faza 7 — TanStack Query (1-2 sedmice)

**Šta je:** Biblioteka za upravljanje server-side state-om — automatski kešira API pozive, refetchuje podatke, prati loading/error stanje.

**Analogija:** Pametni asistent koji pamti sve što si ga pitao. Ako ga pitaš isto nešto drugi put, odmah odgovori iz sjećanja (cache). Ako prođe neko vrijeme, automatski provjeri da li se nešto promijenilo.

**Zašto je kritičan za BPC:** Zamjenjuje ručno pisani cache i HTTP servis. Sve što je UOM radio ručno (keširanje, invalidacija, loading state, error state), TanStack Query radi automatski.

**Ključni koncepti:**

| Koncept | Šta radi |
|---|---|
| `QueryClient` | Centralni registar svih cachiranih podataka |
| `useQuery` | Fetchuje i kešira podatke za read operacije |
| `useMutation` | Za create/update/delete operacije |
| `queryKey` | Jedinstveni ključ za svaki skup podataka (adresa u kešu) |
| `queryClient.invalidateQueries` | "Zastarjeli" keš — sljedeći useQuery refetchuje |
| `staleTime` | Koliko dugo se podaci smatraju svježim |
| `enabled` | Uvjetno pokretanje query-a |
| `isLoading`, `isFetching`, `isError` | Status query-a |
| `data`, `error` | Rezultati query-a |

**Resursi:**
- [TanStack Query Dokumentacija](https://tanstack.com/query/latest/docs/framework/react/overview)
- [TkDodo's Blog](https://tkdodo.eu/blog/practical-react-query) — **najpreporučeniji** blog, pisao maintainer
- [TanStack Query kurs — Jack Herrington](https://www.youtube.com/watch?v=novnyCaa7To)

**Šta praktikovati:** Poveži aplikaciju sa [DummyJSON](https://dummyjson.com/products) API-jem. Koristi `useQuery` za listu, `useMutation` za kreiranje, `invalidateQueries` za refresh liste.

---

## Faza 8 — Zustand (3-5 dana)

**Šta je:** Lagan library za upravljanje client-side state-om — podaci koji ne dolaze sa servera.

**Analogija:** Mini-baza u memoriji browsera. Bilo koja komponenta može čitati ili pisati u nju, bez prosljeđivanja props-a.

**Razlika TanStack Query vs Zustand:**
- `TanStack Query` → server state (podaci sa API-a: liste proizvoda, detalji, verzije)
- `Zustand` → client state (UI stanje: koji redovi su selektovani, da li je modal otvoren, korisnički podaci nakon logina)

**Resursi:**
- [Zustand Dokumentacija](https://zustand.docs.pmnd.rs/getting-started/introduction)
- [Zustand Tutorial — Jack Herrington](https://www.youtube.com/watch?v=_ngCLZ5Iz-0)
- [Zustand vs Context API](https://www.youtube.com/watch?v=5-1LM2NySR0)

---

## Faza 9 — React Hook Form + Zod (1-2 sedmice)

**Šta su:**
- **React Hook Form (RHF)** — Biblioteka za upravljanje formama koja minimizira re-rendere
- **Zod** — Biblioteka za definisanje i validaciju sheme podataka (TypeScript-friendly)

**Zašto su zajedno:** Zod definiše "pravila" forme (obavezna polja, format, min/max), a RHF ih automatski primjenjuje.

**Analogija za Zod:** Kao šablona za popunjavanje obrazaca — kad neko preda obrazac, Zod automatski provjeri da li je sve uredno popunjeno.

```tsx
import { z } from 'zod';

const ProductSchema = z.object({
  name: z.string().min(3, 'Naziv mora imati min. 3 znaka'),
  price: z.number().positive('Cijena mora biti pozitivna'),
  category: z.enum(['INTERNET', 'GSM', 'FIKSNA']),
  validFrom: z.date(),
});

// TypeScript tip se automatski izvlači iz Zod sheme!
type ProductFormData = z.infer<typeof ProductSchema>;
```

**Ključni koncepti RHF:**

| Koncept | Šta radi |
|---|---|
| `useForm` | Hook koji inicijalizira formu |
| `register` | Registruje native HTML input |
| `Controller` | Za custom komponente (shadcn/ui, select...) |
| `handleSubmit` | Wrapper za submit koji validira prije slanja |
| `formState.errors` | Validacijske greške |
| `formState.isSubmitting` | True dok se form šalje |
| `reset` | Resetuje formu na default vrijednosti |
| `setValue` | Programatski postavi vrijednost polja |
| `watch` | Promatra vrijednost polja u realnom vremenu |

**Resursi:**
- [React Hook Form Dokumentacija](https://react-hook-form.com/get-started)
- [Zod Dokumentacija](https://zod.dev/)
- [Zod Tutorial — Fireship](https://www.youtube.com/watch?v=L6BE-U3oy80)
- [RHF sa Zod](https://www.youtube.com/watch?v=cc_xmawJ8Kg)

**Šta praktikovati:** Napravi formu za kreiranje novog proizvoda sa validacijom: naziv (obavezan, min 3 znaka), cijena (pozitivan broj), kategorija (dropdown), datum važenja (ne u prošlosti).

---

## Faza 10 — Vite (1-2 dana)

**Šta je:** Alat za build koji pokreće dev server i kompajlira kod za produkciju. Nevjerojatno brz dev server.

**Šta moraš znati:**
- Pokretanje dev servera: `npm run dev`
- Environment varijable: moraju počinjati sa `VITE_` da bi bile dostupne u kodu
- `vite.config.ts` — konfiguracija (path aliasi, proxy za API)

**Resursi:**
- [Vite Dokumentacija — Getting Started](https://vite.dev/guide/)
- [Path aliasi u Vite](https://vite.dev/config/shared-options.html#resolve-alias)

---

## Faza 11 — TanStack Table (1 sedmica)

**Šta je:** Headless biblioteka za pravljenje tablica — pruža logiku (sortiranje, filtriranje, paginacija, selekcija) ali ne i UI. Ti pišeš HTML/JSX i kombinuješ sa Tailwindom i shadcn/ui.

**Gdje se koristi u BPC:** Tablica proizvoda sa sortiranjem po koloni, filtriranjem, multi-selekcijom za bulk akcije.

**Resursi:**
- [TanStack Table Dokumentacija](https://tanstack.com/table/latest)
- [TanStack Table Tutorial — Jack Herrington](https://www.youtube.com/watch?v=CjqG277Hmgg)

---

## Faza 12 — Napredni koncepti (1-2 sedmice)

### Error Boundaries

**Šta su:** React komponente koje "hvataju" JavaScript greške i prikazuju fallback UI umjesto da sruše cijelu aplikaciju.

**Resursi:**
- [React docs — Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- Biblioteka: `react-error-boundary`

---

### Virtualizacija lista

**Šta je:** Umjesto renderovanja 1000 redova tablice, renderuje se samo ono što je vidljivo na ekranu.

**Biblioteka:** TanStack Virtual

**Resurs:** [TanStack Virtual Dokumentacija](https://tanstack.com/virtual/latest)

---

### Custom Hooks

**Šta su:** Funkcije koje počinju sa `use` i mogu koristiti React hooks unutra — za izdvajanje logike koja se ponavlja.

**Primjeri iz BPC:**
- `useDebounce` — odgađa izvršavanje (za search inpute: ne šalji API poziv na svako slovo)
- `useLocalStorage` — čita/piše u localStorage sa schema verzioniranjem
- `useUrlState` — sinkronizira state sa URL parametrima

**Resurs:** [React docs — Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)

---

## Faza 13 — Testiranje (1-2 sedmice)

**Šta je:**
- **Vitest** — Test runner, brz (kao Jest ali za Vite projekte)
- **React Testing Library (RTL)** — Testira komponente onako kako korisnik interaguje sa njima

**Filozofija RTL:** Testiraš ponašanje, ne implementaciju. Ne testiraš "je li `useState` pozvan", nego "kad korisnik klikne dugme, vidi li se tekst 'Sačuvano'?"

**Resursi:**
- [Vitest Dokumentacija](https://vitest.dev/guide/)
- [React Testing Library Dokumentacija](https://testing-library.com/docs/react-testing-library/intro/)
- [Kent C. Dodds — Testing best practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [RTL Tutorial — The Net Ninja](https://www.youtube.com/playlist?list=PL4cUxeGkcC9gm4_-5UsNmLqMosM-dzuvQ)

---

## Faza 14 — Specifične biblioteke za BPC

Ove biblioteke uči kad dođeš do implementacije te konkretne funkcionalnosti.

| Biblioteka | Svrha | Kada učiti |
|---|---|---|
| [TipTap](https://tiptap.dev/) | Rich text editor za template dokumenata | Kad počneš Document feature |
| [react-pdf](https://react-pdf.org/) | Prikaz PDF dokumenata u browseru | Kad počneš PDF preview |
| [react-diff-viewer](https://github.com/praneshr/react-diff-viewer) | Prikaz razlika između verzija | Kad počneš Versioning feature |

---

## Timeline — preporučeni redoslijed

```
Sedmica  1-2 : HTML, CSS osnove, JavaScript/ES6+
Sedmica  3-4 : TypeScript fundamentals
Sedmica  5-7 : React osnove (useState, useEffect, props, JSX)
Sedmica  8   : Tailwind CSS
Sedmica  9   : shadcn/ui + React Router
Sedmica 10   : Axios + HTTP koncepti
Sedmica 11-12: TanStack Query
Sedmica 13   : Zustand
Sedmica 14-15: React Hook Form + Zod
Sedmica 16   : Vite + project setup
Sedmica 17-18: Napredni React (memo, lazy, Suspense, useTransition)
Sedmica 19   : TanStack Table
Sedmica 20   : Custom Hooks + testiranje osnove
```

---

## Jedan projekt za cijelo učenje — "Mini BPC"

Umjesto izolovanih vježbi, gradi **jedan projekt koji raste** kroz sve faze:

| Faza | Šta dodaješ |
|---|---|
| Faza 2 | Statička lista proizvoda, filter po kategoriji (samo React) |
| Faza 3-4 | Tailwind + shadcn/ui stilizacija |
| Faza 5 | Routing — lista i detalji stranica |
| Faza 6-7 | [DummyJSON API](https://dummyjson.com/products) integracija, TanStack Query |
| Faza 8 | Zustand za selekciju redova |
| Faza 9 | Forma za kreiranje/editovanje, RHF + Zod validacija |
| Faza 11 | TanStack Table sa sortiranjem i filtriranjem |
| Faza 12 | Lazy loading stranica, Error Boundary |
| Faza 13 | Testovi za form komponentu |

Na kraju imaš funkcionalan CRUD admin panel — gotovo identičan onome što BPC treba.

---

## Konvencije i pravila koja treba zapamtiti

### Uvoz — direktni, ne barrel

```typescript
// ❌ IZBJEGAVATI — barrel uvoz vuče cijeli modul u bundle
import { ProductForm, ProductList } from '@/features/products';

// ✅ ISPRAVNO — direktni uvoz
import { ProductForm } from '@/features/products/components/ProductForm';
```

### Conditional rendering — uvijek ternary

```tsx
// ❌ ZAMKA — 0 se renderuje kao "0" u DOM-u
{products.length && <ProductList />}

// ✅ ISPRAVNO
{products.length > 0 ? <ProductList products={products} /> : <EmptyState />}
```

### Effects — samo za nužne slučajeve

```tsx
// ❌ IZBJEGAVATI — effect za derived state
const [filtered, setFiltered] = useState([]);
useEffect(() => {
  setFiltered(products.filter(p => p.status === status));
}, [products, status]);

// ✅ ISPRAVNO — izračunaj tokom rendera
const filtered = useMemo(
  () => products.filter(p => p.status === status),
  [products, status]
);
```

### Default props — hoistati van komponente

```tsx
// ❌ PROBLEM — novi Array objekt svaki render = beskonačni re-renderi
function MyComponent({ items = [] }) { ... }

// ✅ ISPRAVNO — stabilan referentni objekt
const DEFAULT_ITEMS: Item[] = [];
function MyComponent({ items = DEFAULT_ITEMS }) { ... }
```

### TypeScript — bez `any`

```typescript
// ❌ NIKAD
const response: any = await api.get('/products');

// ✅ UVIJEK tipizovati
const response: Product[] = await api.get<Product[]>('/products');
```

---

## Korisni opšti resursi

| Resurs | Šta je | Besplatan? |
|---|---|---|
| [react.dev](https://react.dev) | Oficijalna React dokumentacija | Da |
| [javascript.info](https://javascript.info) | Kompletni JS vodič | Da |
| [TkDodo Blog](https://tkdodo.eu/blog) | Blog o TanStack Query i Reactu | Da |
| [Kent C. Dodds Blog](https://kentcdodds.com/blog) | Patterns, testiranje, best practices | Da |
| [ui.shadcn.com](https://ui.shadcn.com) | shadcn/ui dokumentacija | Da |
| [Josh Comeau's Blog](https://www.joshwcomeau.com/) | CSS, React, animacije | Da |
| [Fireship YouTube](https://www.youtube.com/@Fireship) | Kratki pregledi tehnologija | Da |
| [Jack Herrington YouTube](https://www.youtube.com/@jherr) | Dublje React i TypeScript tutorijali | Da |

---

*Dokument kreiran: Februar 2026.*
*Namijenjen kao referenca tokom razvoja BPC frontend aplikacije.*
*Kombinuje lekcije iz analize UOM Angular projekta i Vercel React Best Practices smjernica.*
