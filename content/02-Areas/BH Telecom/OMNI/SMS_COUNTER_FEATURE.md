# SMS_COUNTER_FEATURE.md

## Opis izmjene

Dodan je live brojač karaktera za polje "Sadržaj poruke" u SMS formi. Brojač se ažurira u realnom vremenu dok korisnik kuca poruku, i mijenja boju u crvenu kada broj karaktera premaši dozvoljeni limit od 157.

---

## Kontekst

Prije ove izmjene, validacija od 157 karaktera postojala je samo u `send()` metodi:

```typescript
if(this.replyModel.messageContent.length > 157) {
    this.toastr.error('Poruka ne smije imati više od 157 karaktera. Trenutni broj karaktera: ' + this.replyModel.messageContent.length);
    return;
}
```

Korisnik nije imao nikakvu informaciju o broju karaktera dok je pisao poruku — grešku bi vidio tek nakon klika na "Pošalji SMS". Cilj izmjene je da korisnik vidi brojač u realnom vremenu i na taj način spriječi slanje neispravne poruke.

---

## Izmijenjeni fajlovi

### 1. `interaction-customer-reply.component.html`

**Dodano** (linija 7-9):

```html
<p [class.error]="replyModel.messageContent?.length > 157" class="char-counter">
    {{ replyModel.messageContent?.length || 0 }} / 157
</p>
```

**Pozicija u template-u** — unutar `#reply` diva, između `zx-form-loader` i `zx-button`:

```html
<div id="reply">
    <zx-form-loader [component]="replyForm" [model]="replyModel"></zx-form-loader>
    <p [class.error]="replyModel.messageContent?.length > 157" class="char-counter">
        {{ replyModel.messageContent?.length || 0 }} / 157
    </p>
    <zx-button [config]="sendButton"></zx-button>
</div>
```

#### Objašnjenje HTML-a

**`class="char-counter"`**
Statičan CSS class koji uvijek postoji na elementu. Koristi se za stilizovanje u SCSS fajlu.

**`[class.error]="replyModel.messageContent?.length > 157"`**
Angular property binding. Uglaste zagrade `[]` govore Angularu da evaluira izraz unutar navodnika kao TypeScript kod (ne kao literal string). Sintaksa `[class.error]` dodaje class `error` na element ako je izraz `true`, ili ga uklanja ako je `false`.
- `length > 157` → `true` → element dobija `class="char-counter error"`
- `length <= 157` → `false` → element ima samo `class="char-counter"`

**`replyModel.messageContent?.length`**
`?.` je optional chaining operator. Štiti od greške kada je `messageContent` još `undefined` (korisnik ništa nije ukucao). Bez `?.`, izraz `undefined.length` bi bacio JavaScript grešku. Sa `?.`, rezultat je `undefined` umjesto greške.

**`|| 0`**
Ako je izraz `undefined` (prazan textarea), prikaži `0`. Operator `||` vraća desnu vrijednost kada je lijeva falsy (`undefined`, `null`, `0`, `''`).

**`{{ ... }} / 157`**
Angular interpolacija `{{ }}` evaluira izraz i umetne rezultat kao tekst u DOM — to je dinamički broj karaktera. ` / 157` je literal string koji se uvijek prikazuje nepromijenjeno. Zajedno daju prikaz npr. `45 / 157`. Vrijednost `157` odgovara limitu definiranom u `send()` metodi.

---

### 2. `interaction-customer-reply.component.scss`

**Dodano** unutar `#reply` bloka:

```scss
p.char-counter {
    position: absolute;
    top: 7px;
    right: 28%;
    font-size: 12px;
    color: #42526E;
    margin: 0;
    &.error {
        color: red;
    }
}
```

#### Objašnjenje SCSS-a

**`#reply` ima `position: relative`** (postojalo prije izmjene)
Ovo je preduvjet za `position: absolute` na child elementu. Apsolutno pozicioniran element se pozicionira u odnosu na najbliži `position: relative` predak. Bez ovoga, counter bi se pozicionirao u odnosu na cijelu stranicu.

**`position: absolute`**
Izvlači element iz normalnog toka dokumenta. Forma i button se neće pomaknuti zbog countera — on "lebdi" iznad layouta.

**`top: 7px`**
Udaljenost od gornje ivice `#reply` diva. Vrijednost je podešena da se counter vizualno poklopi sa labelom "Sadržaj poruke *" koju generira ZFF `zx-form-loader`.

**`right: 28%`**
Udaljenost od desne ivice `#reply` diva. Vrijednost `28%` odgovara otprilike širini `col-6` kolone gdje se nalazi "Popuni opis" switch, tako da counter ostaje unutar desne granice textarea-e i ne ulazi u prostor switcha.

**`margin: 0`**
`<p>` element ima defaultni browser margin (gore i dolje). Bez `margin: 0` pozicioniranje bi moglo biti neprecizno.

**`&.error { color: red; }`**
SCSS nesting sintaksa. `&` je referenca na parent selector, pa se ovo kompajlira u `p.char-counter.error { color: red; }`. Primijeni se samo kada element istovremeno ima i `char-counter` i `error` class — što se dešava kada Angular doda `error` class kroz `[class.error]` binding.

---

## Tok u browseru

| Akcija | Stanje |
|--------|--------|
| Korisnik otvori formu | `messageContent` je `undefined` → prikazuje `0 / 157` u boji `#42526E` |
| Korisnik kuca | Angular change detection osvježava `{{ }}` na svaki keystroke → broj raste |
| Broj dostigne 158 | `[class.error]` postaje `true` → dodaje se class `error` → boja postaje crvena |
| Korisnik obriše tekst | Vraća se na `0 / 157`, class `error` se uklanja |
| Korisnik klikne "Pošalji" sa >157 | `send()` metoda i dalje baca toastr error kao dodatna zaštita |

---

## Zašto live counter, a ne samo toastr na send?

Angular change detection se već pokreće na svaki keystroke zbog `ngModel` bindinga unutar `zx-form-loader`. Dodavanje `{{ }}` izraza ne dodaje novi change detection ciklus — samo jednu evaluaciju unutar postojećeg. Uticaj na performanse je zanemariv jer se radi o trivijalnoj operaciji (čitanje `.length` stringa).

---

## Pattern konzistentnosti sa projektom

Ovaj pristup (plain HTML sa `{{ }}` interpolacijom unutar ZFF komponenti) je standard u cijelom projektu:
- `/billing/bill-state-popup.component.html` — koristi `[ngClass]` i `{{ }}` na `<p>` elementima
- `/wfms/comments/comments.component.html` — koristi `{{ }}` u `<span>` i `<textarea>` elementima
- `/tem-actions/tem-actions.component.html` — koristi `{{ }}` u `<span>` i `<p>` elementima

Dakle, ova izmjena je u potpunoj skladu sa postojećim konvencijama u kodu.
