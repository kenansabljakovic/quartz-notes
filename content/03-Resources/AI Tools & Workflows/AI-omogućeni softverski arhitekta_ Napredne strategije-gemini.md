# **Evolucija Softverskog Arhitekte u Eri Umjetne Inteligencije: Od "Slijepog Kopiranja" do Strateškog Sistemskog Dizajna**

Razvoj softvera nalazi se u epicentru najveće promjene paradigme od nastanka interneta i prelaska na računarstvo u oblaku (cloud computing). Dostupnost naprednih velikih jezičnih modela (LLM) i agenata umjetne inteligencije (AI) dovela je do fenomena gdje samo generiranje koda više nije usko grlo u razvoju softverskih sustava. Međutim, ova tranzicija iznjedrila je novi, kritični industrijski problem: pojavu "plitkih developera" i sindrom "slijepog kopiranja" (blind copy-pasting syndrome). U ovom stanju, inženjeri koriste AI za brzo generiranje rješenja, ali zanemaruju fundamentalne aspekte inženjerstva kao što su upravljanje stanjem (state management), strategije predmemoriranja (caching), distribuirana sigurnost, performanse u ekstremnim uvjetima i granični slučajevi (edge cases).1  
Ovaj iscrpni, dubinski istraživački izvještaj detaljno analizira kako medior i senior inženjeri mogu prevladati ovu opasnu fazu i transformirati se u softverske arhitekte osnažene umjetnom inteligencijom (AI-empowered architects). Kroz opsežnu sintezu stavova vodećih industrijskih stručnjaka, analizu naprednih tehnika promptiranja, implementaciju inženjeringa konteksta (context engineering) i uspostavljanje rigoroznih procesa validacije, ovaj dokument pruža sveobuhvatan vodič za arhitekturu modernog softverskog inženjerstva u 2026\. godini i nadalje.

## **1\. Kriza "Plitkog Koda" i Redefinicija Inženjerske Ekspertize**

Eksplozija alata za generiranje koda dovela je do situacije u kojoj produkcijski sustavi postaju preplavljeni onim što industrija danas naziva "softverskim muljem" (code slop).3 Brzina kojom se kod piše sada dramatično premašuje brzinu kojom se taj isti kod može pročitati, razumjeti, testirati i sigurno integrirati u veće, međuovisne sustave.  
U prošlosti, kognitivni napor i vrijeme potrebno za pisanje koda funkcionirali su kao prirodni filter za kvalitetu; inženjeri su morali duboko razmisliti prije nego što bi implementirali složenu logiku. Danas, AI agenti mogu generirati tisuće linija koda za nekoliko sekundi, prebacujući teret inženjerstva sa *stvaranja* na *verifikaciju*, *orkestraciju* i *održavanje*.3  
U ovakvom okruženju, puko poznavanje sintakse programskog jezika gubi na vrijednosti. Prava inženjerska ekspertiza sada leži u sistemskom dizajnu, razumijevanju arhitektonskih kompromisa (trade-offs), definiranju granica mikroservisa i izgradnji otpornih sustava koji mogu tolerirati greške i nepredviđena ponašanja.6 Softverski arhitekt u eri umjetne inteligencije nije osoba koja piše najbrži kod, već osoba koja postavlja najpreciznija ograničenja i kontekst unutar kojeg strojevi generiraju rješenja.

## **2\. Filozofija AI Inženjerstva: Perspektive Tehnoloških Lidera i Zajednice**

Da bi se razumjela dubina ove transformacije, neophodno je sagledati filozofiju i predviđanja vodećih mislilaca u tehnološkoj industriji, koji oblikuju način na koji se AI integrira u svakodnevni rad senior inženjera. Dubinsko istraživanje tehničkih blogova, inženjerskih biltena i foruma otkriva jasan konsenzus o tome što čini modernog arhitekta.

### **2.1. Gergely Orosz (The Pragmatic Engineer) i Gubitak Manuelnog Kodiranja**

Gergely Orosz, autor globalno utjecajnog biltena *The Pragmatic Engineer* i knjige *The Software Engineer's Guidebook*, dokumentira fenomene unutar velikih tehnoloških kompanija (Big Tech) i startupa u fazi hiper-rasta. Njegova analiza ukazuje na to da su alati poput AI agenata sposobni prepisati čitave arhitekture (poput prelaska s jednog na drugi web framework) u nevjerojatno kratkom roku. U jednom studijskom slučaju, Orosz demonstrira kako je uz pomoć LLM-a zamijenio eksterni SaaS servis koji je koštao 120 dolara godišnje, generiranjem vlastitog mikro-SaaS rješenja za samo 20 minuta.4  
Međutim, Orosz ističe da postoji inherentna "tuga" (grief) među inženjerima jer AI preuzima veći dio kodiranja, oduzimajući onaj osjećaj zanatskog zadovoljstva.4 Unatoč tome, on naglašava krucijalnu razliku: AI kodiranje nije isto što i softversko inženjerstvo.2 Dok AI može napisati besprijekoran "boilerplate" kod ili implementirati izolirani algoritam, senior inženjeri moraju integrirati te komponente u ekosustave koji zahtijevaju razumijevanje poslovnih pravila, globalnih konfiguracijskih promjena i opasnosti od zavisnosti u produkciji.8 Oroszova filozofija sugerira da inženjeri moraju usmjeriti svoj fokus s implementacije algoritama na orkestraciju sustava i rješavanje problema na najvišoj razini apstrakcije.4

### **2.2. Charity Majors i Opservabilnost kao Lijek za AI Haos**

Charity Majors, suosnivačica i CTO tvrtke Honeycomb, pruža neprocjenjiv uvid u operativni aspekt AI-asistiranog razvoja i kulturu inženjerskih timova. Prema njezinim riječima, umjetna inteligencija će neizbježno automatizirati sve što je determinističko i predvidljivo. Međutim, veliki softverski sustavi su inherentno nedeterministički, prepuni emergentnih ponašanja koja je nemoguće predvidjeti samo statičkim čitanjem koda.5  
Njezina centralna teza, potkrijepljena podacima iz DORA izvještaja za 2025\. godinu (State of AI-Assisted Software Development Report), jest da je generativna umjetna inteligencija isključivo *pojačivač* (amplifier), a ne rješenje.10 U organizacijama koje nemaju dobru opservabilnost, telemetriju i automatizirane testove, AI samo ubrzava kreiranje tehničkog duga i producira "kod koji nitko ne razumije".3 S druge strane, u zdravim inženjerskim kulturama, AI omogućava "normalnim inženjerima" da budu iznimno produktivni i bave se isključivo poslovnom logikom.9 Majors izričito upozorava na opasnost od "kognitivnog propadanja" (cognitive decay) uslijed prevelikog oslanjanja na AI alate. Arhitekti moraju zadržati duboko razumijevanje povratnih sprega (feedback loops) u produkcijskim sustavima kako bi mogli dijagnosticirati probleme koje AI stvori.3

### **2.3. Swizec Teller: Preuzimanje Odgovornosti za Produkciju i "Senior Mindset"**

Swizec Teller, iskusni inženjer i autor biltena s preko 16,000 pretplatnika, fokusira se na "razmišljanje senior inženjera" (Senior Engineer Mindset). Njegova ključna opservacija je da na višim razinama karijere (L5, L6, L7), nitko ne brine o tome *kako* se kod piše, pa čak ni što inženjer radi iz dana u dan; uprava i klijenti brinu isključivo o ishodima.12  
U eri gdje "AI ispunjava dan zauzetošću (busywork)", Teller naglašava da korisnici plaćaju za uslugu i rješenje problema, a ne za linije koda.13 Transformacija iz kucača koda u arhitekta zahtijeva sposobnost postavljanja dugoročne tehničke vizije, kreiranja mapa puta (roadmaps) i preuzimanja odgovornosti za projekte koji traju mjesecima. U tom kontekstu, AI služi isključivo kao taktički alat za izvršavanje mikro-zadataka unutar šire strateške vizije.12

### **2.4. Gregor Hohpe, Neal Ford i "The Architect Elevator"**

Gregor Hohpe, autor koncepta *The Architect Elevator*, objašnjava da moderni arhitekt mora biti sposoban voziti se "liftom" između "strojarnice" (engine room \- gdje se piše kod i rješavaju tehnički problemi) i "penthausa" (boardroom \- gdje uprava donosi poslovne i strateške odluke).16 Arhitekt koji koristi AI mora znati prevesti poslovne zahtjeve u tehničke specifikacije koje AI može obraditi, ali i prevesti tehničke rizike koje AI kod donosi natrag u poslovni jezik.17  
Neal Ford (ThoughtWorks), koautor knjiga *Fundamentals of Software Architecture* i *Building Evolutionary Architectures*, nadovezuje se na ovo objašnjavajući Prvi zakon softverske arhitekture: "Sve u softverskoj arhitekturi je kompromis (trade-off)".6 Drugo pravilo glasi da je pitanje "Zašto?" neusporedivo važnije od pitanja "Kako?".6 AI je trenutno fantastičan u davanju odgovora na "kako" implementirati određeni obrazac, ali je ljudski arhitekt taj koji mora kvantificirati rizike i donijeti odluku zasnovanu na podacima, balansirajući između performansi, skalabilnosti i vremena razvoja.18

### **2.5. Puls Tehnološke Zajednice (Reddit i Stručni Forumi)**

Diskusije na platformama poput Reddit zajednica r/ExperiencedDevs, r/softwarearchitecture i r/PromptEngineering potvrđuju ove stavove. Iskusni inženjeri ističu da se AI alati ne smiju tretirati kao "čarobni štapići" koji arhitekturiraju sustave, već kao "alati za ubrzavanje saznanja" i partneri za "brainstorming".19 Zajednica se slaže da se prijelaz na arhitektonsku razinu događa kada inženjer prestane validirati *kod* koji AI izbaci, i počne validirati *pretpostavke* na kojima taj kod počiva.22

## **3\. Napredne Tehnike Promptiranja za Sistemski Dizajn**

Da bi se umjetna inteligencija iskoristila za arhitekturu i sistemski dizajn umjesto za puko generiranje "boilerplate" funkcija, neophodno je napustiti primitivne tehnike "Zero-shot" promptiranja (postavljanje pitanja bez ikakvog konteksta) i primijeniti sofisticirane inženjerske okvire.23 Komunikacija s LLM-ovima na razini arhitekture zahtijeva strategije koje prisiljavaju model da obrazlaže, kritizira, secira i strukturira svoje izlaze, smanjujući prostor za halucinacije i generičke savjete.25

### **3.1. Sokratovski Metod i "Oružana Radoznalost" (Weaponized Curiosity)**

Kada se dizajnira arhitektura baze podataka ili protok podataka (data flow), najveća greška koju medior inženjer može napraviti jest tražiti od AI-ja konačno rješenje (npr. "Dizajniraj mi arhitekturu za aplikaciju za dopisivanje"). Umjesto toga, Sokratovski metod pretvara model iz puke "mašine za odgovore" u "nemilosrdnog profesora na poslijediplomskim studijima" koji prisiljava inženjera da ispita vlastite pretpostavke i brani svoje odluke.26  
Ova metodologija (Socratic Prompting) provodi se kroz specifičan arhitektonski okvir promptiranja koji se sastoji od definiranja persone, procesa ispitivanja i strukturiranog izlaza.27  
**Napredni Prompt za Sokratovski Sistemski Dizajn:**  
"Djeluj kao Principal Software Architect i akademski stručnjak za distribuirane sustave. Tvoj zadatak NIJE da mi daš konačno rješenje ili gotov dizajn. Tvoj zadatak je da koristiš Sokratovski metod kako bi mi pomogao dekonstruirati i rafinirati moju sljedeću arhitektonsku pretpostavku.  
Ograničenja:

1. Prvo jasno restatiraj moju pretpostavku.  
2. Započni 'Why-Chain' (Lanac Zašto) \- postavi mi duboko tehničko pitanje koje propitkuje temelj moje odluke u kontekstu CAP teorema, mrežne latencije ili skaliranja baze. Čekaj moj odgovor.  
3. Nastavi s ispitivanjem 'Zašto' i traženjem protuprimjera sve dok ne dođemo do srži problema.  
4. Primijeni tehniku Inverzije: Pitaj me što bi se dogodilo da je potpuno suprotna arhitektura primijenjena.  
5. Na kraju, pomozi mi formulirati 'Pravo Pitanje' visoke vrijednosti koje moramo riješiti. Moja početna pretpostavka: 'Smatram da naš monolitni sustav za obradu plaćanja trebamo razbiti na 15 neovisnih mikroservisa temeljenih na događajima (event-driven) kako bismo postigli bolju skalabilnost.'" 27

Kroz ovaj proces, AI vas može dovesti do zaključka da problem nije u skaliranju procesora, već u zaključavanju baze podataka (database locking), te da bi prelazak na mikroservise donio eksponencijalno povećanje mrežne latencije bez rješavanja stvarnog uskog grla.27

### **3.2. Obrasci Đavoljeg Odvjetnika (Red Teaming u Arhitekturi)**

Inženjeri često pate od pristranosti potvrđivanja (confirmation bias) kada osmišljavaju arhitekturu. Zaljube se u određenu tehnologiju (npr. Kafka ili Kubernetes) i nesvjesno ignoriraju njezine mane. Korištenje AI-ja u ulozi "Đavoljeg odvjetnika" (Devil's Advocate) ili kroz tehnike "Red Teaming-a" presudno je za testiranje otpornosti sustava prije nego što se napiše ijedna linija koda.29  
Simulacija kolaboracije s antagonističkim AI agentima, poznata kao *Adversarial Collaboration Simulator* (ACS), pokazala se iznimno učinkovitom za otkrivanje "slijepih pjega" u dizajnu.30 Ovaj pristup dijeli AI na više logičkih agenata unutar istog kontekstnog prozora:

* **Teza (Worker Agent):** Agent koji predlaže optimistično rješenje zasnovano na standardnim praksama i pruženim zahtjevima.  
* **Antiteza (Devil's Advocate Agent):** Sistematski skeptik čiji je jedini cilj pronaći skrivene mane, granične slučajeve (edge cases) i tačke loma (failure modes).32 Ovaj agent namjerno napada arhitekturu tražeći greške u upravljanju stanjem, potencijalne "race" uvjete, probleme sa zombificiranim procesima ili uska grla u bazi podataka.  
* **Sinteza (Reviewer Agent):** Orator koji moderira debatu i donosi arhitektonsku odluku tek kada se prijeđe zadani prag sigurnosti (confidence threshold) i kada su svi rizici koje je iznio Đavolji odvjetnik adekvatno adresirani i mitigirani.32

Ovakav višefazni prompt prisiljava AI da ne popušta pred korisnikom i da pruži dubinsku kritiku, tjerajući arhitekta da detaljno dokumentira strategije oporavka od grešaka (disaster recovery).29

### **3.3. "Flipped Interaction" i "Context-Driven" Promptiranje**

Tradicionalno promptiranje zasniva se na tome da inženjer daje upute umjetnoj inteligenciji. Napredni arhitekti koriste *Flipped Interaction Pattern* (obrnuta interakcija), gdje je model taj koji postavlja pitanja korisniku dok ne prikupi dovoljno specifikacija za kreiranje pouzdanog sustava.33  
**Primjer Flipped Interaction Prompt-a:**  
"Dizajniram sustav za obradu podataka u realnom vremenu za IoT uređaje. Prvo, postavi mi seriju pojašnjavajućih pitanja o našim zahtjevima i ograničenjima (npr. throughput, latencija, sigurnost, budget). Ne generiraj nikakav kod niti rješenje. Čekaj moje odgovore na tvoja pitanja. Zatim, predstavi mi kompromise između Kafka i RabbitMQ pristupa u mom specifičnom kontekstu. Konačno, tek kada se usuglasimo oko pristupa, vodi me kroz implementaciju korak po korak." 33  
Ovaj obrazac je dio šire znanosti poznate kao **Inženjering Konteksta (Context Engineering)**. Kako navode stručnjaci iz tvrtke Anthropic i AI zajednice, sam tekst prompta (instrukcija) postao je manje bitan od strukture informacija koje model dobiva na raspolaganje.35  
Veliki jezični modeli temelje se na "Transformer" arhitekturi, koja omogućuje svakom tokenu da obrati pažnju (attention mechanism) na svaki drugi token u kontekstu. To rezultira s $n^2$ parnih odnosa za $n$ tokena.35 Zbog ovog kvadratnog rasta složenosti, modeli koji primaju ogromne kontekstualne prozore podložni su "kvarenju konteksta" (context rot) – gube fokus, zaboravljaju važne instrukcije s početka prompta i počinju halucinirati.35 Zbog toga, inženjering konteksta zahtijeva prelazak s prostog pisanja teksta na strukturiranje cjelokupnog toka informacija (povijest, dohvaćeni RAG podaci, JSON sheme) koje LLM koristi.37

### **3.4. Prompt Chaining, Chain-of-Thought (CoT) i Tree of Thoughts (ToT)**

Da bi AI donio kvalitetne odluke o arhitekturi, mora mu se dopustiti da "razmišlja na glas".

* **Chain-of-Thought (CoT):** Dodavanjem jednostavne fraze "Razmisli korak po korak" ili strukturiranjem prompta tako da AI prvo izloži svoju analizu prije konačnog odgovora, drastično se povećava točnost logičkog rezoniranja.23  
* **Tree of Thoughts (ToT):** Za najkompleksnije probleme sistemskog dizajna koristi se ToT. Modelu se naređuje da istraži više paralelnih grana rješenja (npr. Grana 1: Rješenje temeljeno na NoSQL bazi; Grana 2: Rješenje temeljeno na PostgreSQL-u; Grana 3: In-memory graf baza). Zatim se od modela traži da samostalno evaluira svaku granu prema definiranim kriterijima (skalabilnost, cijena, brzina razvoja) i odabere optimalan put.24

## **4\. Model Context Protocol (MCP) i Arhitektura Sljedeće Generacije**

Jedan od najvažnijih tehnoloških iskoraka u razvoju softvera osnaženom umjetnom inteligencijom je **Model Context Protocol (MCP)**, open-source standard koji je uvela tvrtka Anthropic, a brzo prihvatila cijela industrija.39 MCP funkcionira kao univerzalni standard ("USB-C za AI") za sigurno povezivanje AI modela i agenata s vanjskim bazama podataka, internim API-jima i alatima.40 Razumijevanje i dizajniranje MCP arhitekture postalo je krucijalna vještina za senior inženjere.  
Prije MCP-a, povezivanje AI aplikacija s podacima bio je fragmentiran proces, stvarajući $N \\times M$ problem integracije (N AI aplikacija puta M izvora podataka jednako je ogromnom broju prilagođenih integracija).41 MCP to rješava standardiziranim klijent-poslužitelj (client-server) modelom.

### **4.1. Arhitektonski Anti-obrasci: Zamka API Omotača (The API Wrapper Trap)**

Kada inženjeri počnu raditi s AI agentima, najčešća arhitektonska greška je jednostavno umotavanje postojećih REST API-ja u MCP servere i izlaganje tih API-ja agentima.39 Postojeći API-ji dizajnirani su za korisnička sučelja (UI) vođena ljudima, a ne za autonomne agente. Ovo dovodi do fundamentalnog neslaganja (impedance mismatch) koje se manifestira kroz "N+1 problem na steroidima".39  
Kada AI agent treba dobiti kompletan pregled klijenta, umjesto jednog optimiziranog poziva bazi, on kroz omotani API vrši kaskadne zavisne pozive: prvo dohvaća klijenta, pa narudžbe, pa detalje narudžbi, pa statuse isporuke. Ono što bi trebala biti jedna operacija postaje preko 20 mrežnih API poziva, što rezultira masovnom potrošnjom tokena, ogromnom latencijom i eksponencijalno većom vjerojatnošću kvara.39

| Karakteristika | Tradicionalni REST API (Za UI) | MCP Server API (Za AI Agente) |
| :---- | :---- | :---- |
| **Granularnost** | Visoka (mali, specifični resursi) | Niska (agregirani, bogati resursi) |
| **Izvedba** | Višestruki mrežni pozivi (N+1) | Jedan poziv koji vraća puni kontekst |
| **Dokumentacija** | Za ljude (Swagger/OpenAPI) | Za strojeve (Striktan JSON Schema opis) |
| **Upravljanje stanjem** | Može oslanjati na sesije | Strogo bezdržavno (Stateless) i Idempotentno |

### **4.2. Najbolje Prakse za Dizajniranje Produkcijskih MCP Servera**

Pravi softverski arhitekt dizajnira MCP sustave poštujući stroge konvencije koje uzimaju u obzir prirodu jezičnih modela:

* **Ograničeni Kontekst (Bounded Context):** MCP server modelira se oko jednog usko definiranog mikroservisnog domena. Alati moraju biti visoko kohezivni s jasnim JSON shemama, kako model ne bi bio zbunjen oko toga koji alat treba pozvati za koju akciju.42  
* **Idempotentnost i Bezdržavnost (Statelessness):** S obzirom na to da AI agenti često autonomno ponavljaju zahtjeve (retry) ili paralelno pozivaju funkcije kada haluciniraju, operacije unutar MCP servera moraju biti apsolutno idempotentne. Preporučuje se korištenje tokena za paginaciju kako bi odgovori bili deterministički, ograničeni i predvidljivi.42  
* **Inženjering Sigurnosti (Security-First):** Autentifikacija se više ne prepušta slučaju; OAuth 2.1 je obavezan standard. Implementacija strogih "sandboxing" mehanizama osigurava da anomalno ponašanje AI-ja (npr. Prompt Injection napadi) ne rezultira kompromitiranjem produkcijske baze podataka. Sustav mora podržavati dinamičku registraciju klijenata i strogo određene opsege (scopes).42 Nikada se ne smiju vraćati tajni ključevi ili lozinke unutar rezultata alata.42

## **5\. Infrastruktura i Vizualizacija: Od Teksta do Arhitekture**

Prije implementacije ijedne linije koda, arhitektura mora biti deterministički vizualizirana kako bi se otkrili logički procijepi. Tradicionalno crtanje dijagrama rukom je sporo i teško za održavanje. Suvremeni arhitekti koriste principe "Infrastructure-as-Code" primijenjene na dijagrame (Diagram-as-Code).

### **5.1. Mermaid.js i Inženjering Vizualnih Promptova**

Alati poput **Mermaid.js** omogućuju softverskim inženjerima da koriste Markdown notaciju za generiranje dijagrama.44 Korištenje umjetne inteligencije za generiranje Mermaid sintakse stvara snažan zaštitni mehanizam protiv AI halucinacija. Zašto? Zato što je Mermaid sintaksa deterministička.44  
Kada od AI-ja tražite da napiše Mermaid kod za arhitekturu, vi ga prisiljavate da svoju nejasnu internu logiku prevede u stroga pravila dijagrama stanja (State Diagram) ili dijagrama sekvenci (Sequence Diagram). Ako AI preskoči važan logički korak u obradi podataka, Mermaid renderiranje će vizualno pokazati prekid toka ili sintaksnu grešku, djelujući kao prvi sloj validacije.44  
**Napredni prompt za Mermaid.js arhitekturu:**  
"\# Uloga: Ti si Senior Systems Architect stručan u Mermaid.js sintaksi.

# **Kontekst: Dizajniramo SaaS "Freemium to Pro" proces nadogradnje.**

# **Zadatak: Generiraj Mermaid.js State Diagram (dijagram stanja). Logika mora uključivati četiri faze: Okidač (Trigger), Validacijska vrata (baza provjerava limite), Segmentacija Persone (Enterprise korisnici idu u 'Contact Sales', standardni u 'Upgrade Modal') i Rezolucija.**

Osiguraj da je sintaksa validna i da pokriva slučajeve prekida mrežne veze tijekom naplate." 44  
Ovi dijagrami se zatim mogu verzijonirati u GitHub repozitorijima ili integrirati direktno u alate poput Datadog-a ili Notion-a.50

### **5.2. AI Alati za Arhitektonski Dizajn**

Pored tekstualnih alata poput ChatGPT-a ili Claude-a, moderni arhitekti koriste specijalizirane AI vizualne alate:

* **Eraser.io:** Iznimno popularan alat za tehničko crtanje koji omogućuje interoperabilne modove \- unos preko AI promptova, povlačenje elemenata (drag-and-drop) i generiranje koda.51  
* **Lucidchart & Miro:** Implementirali su snažne AI značajke za pretvaranje tekstualnih zahtjeva u flowchart dijagrame, ubrzavajući fazu konceptualizacije.51  
* **Cloudairy:** Pozicionira se kao "pametni AI arhitekt" specijaliziran isključivo za sistemski dizajn, popunjavajući jaz između poslovne strategije i inženjerskog izvršavanja.52

## **6\. Arhitektonske Odluke i Kompromisi (CAP, PACELC i ADR)**

Kada neiskusni developer pita AI "Koju bazu podataka da koristim za svoju aplikaciju?", AI često podrazumijevano sugerira "najmoderniju" tehnologiju (npr. MongoDB ili PostgreSQL) bez razumijevanja temeljnih distribuiranih ograničenja. Edukativni skok ka arhitektu događa se kada inženjer koristi AI za modeliranje graničnih uvjeta koristeći **CAP teorem** (Consistency, Availability, Partition Tolerance) i njegovog nasljednika, **PACELC teorem**.7  
Distribuirani sustavi ne mogu istovremeno jamčiti konzistentnost (svi čvorovi vide iste podatke) i dostupnost (svaki zahtjev dobiva odgovor) u slučaju particije mreže (pada veze između čvorova).54

| Dizajn Sustava | CAP Kompromis (Trade-off) | Tipična Tehnologija / Primjena |
| :---- | :---- | :---- |
| **CP (Consistency \+ Partition Tolerance)** | Žrtvuje se dostupnost tijekom prekida mreže radi očuvanja integriteta podataka. | HBase, MongoDB (sa strogom konzistentnošću). Koristi se za financijske transakcije. 54 |
| **AP (Availability \+ Partition Tolerance)** | Žrtvuje se trenutna konzistentnost (oslanja se na "eventual consistency") kako bi sustav uvijek odgovarao. | CouchDB, Cassandra. Koristi se za feedove društvenih mreža. 54 |
| **CA (Consistency \+ Availability)** | Nema tolerancije na mrežne greške. | Relacijske baze na jednom čvoru (rijetko u modernim distribuiranim cloud sustavima). 54 |

Tokom sistemskog dizajna, napredni inženjeri promptiraju AI da analizira kompromise koristeći ove teoreme.53 Umjesto pitanja "kako", arhitekt postavlja prompt koji prisiljava model da detaljno opiše strategije rješavanja konflikata (Conflict Resolution), upravljanje Quorum čitanjima/pisanjima i mehanizme povratnog rješenja (Fallback Logic) kada servis nije dostupan.54  
Na primjer, arhitektura slična Netflixu ili Uberu često koristi *Multi-Stage Ranking Pipelines* i dijeli arhitekturu na "Offline" (batch procesiranje) i "Online" (posluživanje u realnom vremenu) komponente.57 Razumijevanje ovih obrazaca omogućuje preciznije usmjeravanje AI alata pri generiranju infrastrukture.

### **6.1. Architecture Decision Records (ADR) i GenAI**

Sve ove odluke moraju biti dokumentirane. Ovdje AI briljira u ulozi *ADR Analitičara*.58 Architecture Decision Record (ADR) je kratki dokument koji bilježi važnu arhitektonsku odluku, njen kontekst i posljedice.59  
Inženjeri mogu prelijepiti postojeći visokonivovski dizajn, prezentaciju ili čak blokove koda u AI i zatražiti: *"Analiziraj ovaj nacrt sustava i generiraj formalni ADR. Identificiraj koje su arhitektonske odluke ovdje donesene implicitno, a trebale bi biti eksplicitno dokumentirane. Primijeni rigorozne provjere kvalitete: nedostaju li informacije o operativnom održavanju, sigurnosnim posljedicama ili alternativnim rješenjima koja su odbačena?"*.58 Ovim se osigurava da buduće generacije developera ne ponavljaju iste greške pokušavajući prepisati sustav iz neznanja.61

## **7\. Actionable Workflows: Od Jira Tiketa do Produkcijskog Koda**

Dizajniranje sustava od nule do produkcije uz pomoć AI-ja podrazumijeva stroge iterativne petlje koje sustavno eliminiraju "plitki kod". Analiza industrijskih obrazaca otkriva visoko optimiziran tok rada koji moderni senior inženjeri koriste svakodnevno.2

### **Faza 1: Analiza Zahtjeva i Postavljanje Konteksta (Jira i Rovo)**

Proces započinje korisničkom pričom (Jira tiketom). Moderni alati poput Atlassian Rovo Dev-a integriraju se duboko u ekosustav tvrtke, omogućujući AI-ju da povuče kontekst ne samo iz jednog tiketa, već i iz povezanih Confluence dokumenata i GitHub repozitorija.2 AI može automatski prepoznati ovisnosti, predvidjeti tko bi trebao raditi na zadatku, pa čak i predvidjeti hoće li zadatak probiti SLA rokove na temelju povijesne brzine tima (team velocity).64

### **Faza 2: Generiranje Tehničke Specifikacije i AI Dijagramiranje**

Umjesto pokušaja generiranja cijele aplikacije u jednom promptu (što neminovno dovodi do halucinacija), inženjer hrani AI model zahtjevom i traži izradu stroge tehničke specifikacije.63 Ovo uključuje gore spomenuti Sokratovski metod i kreiranje ADR dokumenta. Tek nakon što čovjek i stroj usuglase arhitekturu, inženjer traži od AI-ja da generira Mermaid.js dijagrame kako bi vizualno potvrdio logičke tokove.44

### **Faza 3: "Test-Driven" Arhitektura (Chain-of-Thought-with-Tests)**

Sljedeći korak je najvažniji za sprječavanje "slijepog kopiranja". Primjenjuje se arhitektonski obrazac **Chain-of-Thought-with-Tests**.34 Ovaj pristup potpuno preokreće tradicionalnu interakciju s AI alatima:

1. Od AI-ja se prvo traži da napiše opsežne, iscrpne testove (Unit, Integration, E2E) za sve komponente zasnovane na odobrenoj specifikaciji, obavezno pokrivajući granične slučajeve (Edge Cases).  
2. Čovjek pregledava testove. Zbog toga što su testovi deklarativni, inženjeru je puno lakše uočiti je li AI "razumio" poslovnu logiku analizirajući koje je testove napisao, nego čitajući tisuće linija implementacijskog koda.  
3. Tek kada arhitekt potvrdi validnost testne suite, modelu se daje dozvola da dizajnira produkcijski kod (poslovnu logiku) koji mora proći te specifične testove.34

Ovaj pristup drastično poboljšava pouzdanost koda jer postavlja matematički jasne granice funkcioniranja unutar kojih AI mora operirati, smanjujući prostor za kreativne, ali opasne halucinacije.34

### **Faza 4: Implementacija uz Alate Svjesne Konteksta (Context-Aware IDEs)**

U ovoj fazi koriste se integrirana razvojna okruženja (IDE) namijenjena za AI, poput **Cursor-a** ili CLI alata poput **Aider-a**, zajedno s GitHub Copilotom. Ovi alati primjenjuju *Code-as-Context Pattern*, što znači da AI agent ima uvid u cijeli repozitorij koda (Codebase), a ne samo u otvoreni prozor.34 Agent razumije kako promjena u bazi podataka utječe na frontend komponente, smanjujući greške u integraciji. Inženjer ovdje djeluje kao nadzornik (mentor) "brzom, ali neiskusnom" AI asistentu, usmjeravajući ga prema ispravnoj implementaciji u malim iterativnim koracima.63

### **Faza 5: AI-Asistirana Revizija Koda (Principal Code Review)**

Posljednji korak prije spajanja koda (merging) na glavnu granu je stroga revizija (Code Review). Principal inženjeri ne koriste AI samo za generiranje koda, već i kao strogog recenzenta tuđeg (i vlastitog) koda. Umjesto jednostavnog dotjerivanja stila i sintakse (što prepuštaju linterima), oni dizajniraju promptove koji pretvaraju AI u eksperta za sigurnost i performanse.22  
**Checklista za AI Code Review prompt mora uključivati analizu sljedećih stavki:**

* **Performanse i Baza Podataka:** Postoje li N+1 upiti bazi? Ima li nepotrebnih petlji koje uzrokuju skokove vremenske složenosti (Big O)? Da li se veliki podaci učitavaju u radnu memoriju umjesto u "chunkovima"? 67  
* **Upravljanje Stanjem (State Management) i Paralelizam:** Je li kod siguran za višenitno izvršavanje (thread-safe)? Postoje li potencijalni "race" uvjeti pri asinkronim pozivima? Kako su obrađeni izuzeci (exceptions) i čisti li se memorija adekvatno (memory leaks)? 65  
* **Sigurnost i Ovisnosti:** Provjeravaju li se svi ulazni podaci korisnika? Provjerava li AI poznate ranjivosti (npr. oslanjajući se na Snyk izvoze) poput Arbitrary Code Execution, Prototype Pollution ili SSRF ranjivosti?58  
* **Opservabilnost:** Sadrži li novi kod dovoljno telemetrije, logova i metrika kako bi problemi u produkciji bili vidljivi i laki za otklanjanje, što direktno utječe na poboljšanje DORA metrika (npr. Mean Time To Recovery \- MTTR)?65

Kroz ovakav sustavni radni tok, AI doista postaje asistent u kritičkom razmišljanju, a inženjer zadržava potpunu intelektualnu kontrolu nad ishodima sustava, u potpunosti eliminirajući rizik "plitkog programiranja".63

## **8\. Prevladavanje Halucinacija, Edge-Case Testiranje i "Prompt Caching"**

Halucinacije modela (kada AI samouvjereno izmišlja nepostojeće biblioteke, krive API rute ili netočnu poslovnu logiku) ne rješavaju se ljubaznijim molbama u promptu, već rigoroznom inženjerskom kontrolom. Srž problema leži u tome što arhitektura velikih jezičnih modela funkcionira po principu probabilistike – oni predviđaju sljedeći najvjerojatniji token na temelju podataka na kojima su trenirani. Zbog toga oni prirodno teže "najčešćem" ili "najprosječnijem" rješenju, potpuno ignorirajući rijetke scenarije i granične slučajeve (edge cases).69

### **8.1. Analiza Graničnih Vrijednosti (Boundary Value Analysis \- BVA)**

Ekstremne situacije su mjesta gdje se softverski sustavi najčešće lome. Ako sustav obrađuje prijave, što se događa ako korisnik pošalje datoteku od točno 0 bajtova, ili payload od 10 gigabajta? Što ako sustav koji podržava 128 znakova za lozinku primi niz od 512 znakova?70  
Tradicionalno ručno testiranje često previđa ove anomalije zbog ljudskog fokusa na "sretne putanje" (happy paths). Ovdje AI postaje neprocjenjiv alat. Moderno osiguravanje kvalitete (QA) prešlo je na *AI-first QA* metodologije.71 Od AI modela se eksplicitno traži da primijeni inženjersku tehniku **Boundary Value Analysis (BVA)**.72  
**Strukturirani Prompt za Generiranje BVA Testova:**  
"Kao QA inženjer specijaliziran za otpornost sustava, analiziraj sljedeći kod komponente za procesiranje transakcija. Tvoj zadatak je generirati opsežan plan testiranja fokusiran ISKLJUČIVO na granične slučajeve (Edge Cases) i Boundary Value Analysis (BVA).  
Zahtijevam strukturirani izlaz u JSON ili Markdown formatu koji mora pokriti:

1. Negativne putanje: Što se događa pri Timeout greškama API-ja trećih strana ili padu mreže usred transakcije?  
2. Ekstremne granične vrijednosti: Testiraj točne granice memorijskog limita, konkurentne (parallel) transakcije koje prelaze zadane limite (rate limiting).  
3. Neočekivane ulaze: Null vrijednosti, znakove izvan UTF-8 standarda, negativne brojeve tamo gdje se očekuju pozitivni.  
4. Sigurnosne granice: Pokušaji SQL injekcija, manipulacija JSON Web Tokenima (JWT) i Session Hijacking scenariji. Za svaki testni slučaj napiši asertacije koje očekuju siguran 'fail' sustava, a ne njegov krah (graceful degradation)." 70

Ovaj sustavni pristup prisiljava inženjere da dizajniraju arhitekturu koja se može nositi s kaosom iz stvarnog svijeta, umjesto idealiziranim uvjetima koje AI inače generira.69

### **8.2. Rješavanje Kvarenja Konteksta kroz "Prompt Caching"**

Jedan od najvećih izazova u radu sa složenom arhitekturom je veličina konteksta. Kada u AI učitavate stotine stranica dokumentacije o vašoj bazi podataka, arhitektonskim odlukama, ADR-ovima i prethodnim PR-ovima, LLM se usporava i dolazi do već opisanog "kvarenja konteksta" (context rot).35 Uz to, financijski trošak obrade milijuna tokena pri svakom novom upitu postaje neodrživ.  
Rješenje ovog problema koje moraju savladati svi senior inženjeri je **Prompt Caching** (Keširanje promptova).74 Vodeći provideri poput Anthropic-a (Claude) i OpenAI-ja uveli su ovu značajku na razini svojih API-ja. Keširanje promptova omogućava inženjerima da pohrane ogromne količine statičkog konteksta (npr. kompletne instrukcije sustava, pravila kodiranja tvrtke, definicije MCP alata i API dokumentaciju) u privremenu memoriju (cache) na serverima AI providera.74  
*Mehanika:* Sustav prepoznaje identične prefikse u promptovima. Ako započnete razgovor koji koristi isti temeljni kontekst kao prethodni upit, model ne mora iznova "čitati" i računati težine za tih 100,000 tokena; on povlači već izračunate vrijednosti iz cache memorije.74 *Posljedice za Arhitekte:* Ovo dramatično smanjuje latenciju odgovora, smanjuje financijske troškove za više od 50%, i najvažnije, omogućava stvaranje AI agenata koji mogu konzistentno i bez "zaboravljanja" operirati satima u pozadini, rješavajući kompleksne refaktoring zadatke bez gubitka niti misli (continuity).74

## **9\. Akcijski Plan od 5 Koraka za Tranziciju u AI-Osnaženog Arhitekta**

Sinteza svih gore navedenih koncepata rezultira ovim visokooktanskim akcijskim planom koji medior/senior inženjeri mogu implementirati već danas kako bi unaprijedili svoju karijeru, zaštitili svoje sustave od "plitkog koda" i ovladali AI alatima na razini softverskog arhitekta.

### **Korak 1: Uspostavljanje Sokratovskog Okvira za Evaluaciju Zahtjeva**

**Akcija:** Prije nego što napišete ijednu liniju koda za sljedeći Jira tiket, kreirajte fiksni *System Prompt* (ili prilagođeni GPT/Claude Project). Dajte modelu instrukciju da preuzme ulogu arhitekta i zabranite mu da generira kodni predložak. **Izvršenje:** Kopirajte zahtjev iz tiketa i zatražite primjenu *Why-Chain* metode. Dozvolite AI-ju da vas preispituje o skalabilnosti, troškovima i mrežnoj latenciji. Identificirajte "Pravo Pitanje" i stvarni poslovni problem prije odabira tehnologije.27

### **Korak 2: Formalizacija Odluka putem AI-Generiranih ADR-ova**

**Akcija:** Nijedna arhitektonska odluka (odluka o izboru baze, frameworka, ili obrasca komunikacije) ne smije proći bez Architecture Decision Recorda. **Izvršenje:** Nakon što se s AI asistentom usuglasite oko dizajna, upotrijebite ulogu "ADR Analitičara". Zatražite od modela da generira strukturirani ADR koji bilježi tehnički kontekst, odabrano rješenje i njegove posljedice. Zatim aktivirajte obrazac *Đavoljeg odvjetnika* (Red Teaming) kako bi AI pokušao "razbiti" taj isti ADR traženjem propusta u CAP teoremu, sigurnosti ili performansama.32

### **Korak 3: Vizualizacija kroz "Diagram-as-Code" (Mermaid.js)**

**Akcija:** Eliminirajte arhitektonske dvosmislenosti pretvaranjem logike u stroge vizualne dijagrame korištenjem tekstualne sintakse koja se može verzionirati u Git-u. **Izvršenje:** Koristeći AI, prevedite svoj ADR i poslovna pravila u Mermaid.js kod za dijagrame stanja (State Diagrams) i dijagrame sekvenci (Sequence Diagrams). Ovaj korak služi kao deterministički filter; ako AI ne može generirati valjan Mermaid kod, to znači da arhitektonska logika ima rupa i "slijepih pjega" koje treba hitno adresirati.44

### **Korak 4: Implementacija "Chain-of-Thought-with-Tests" Metodologije**

**Akcija:** Preokrenite tradicionalni redoslijed generiranja koda kako biste u potpunosti zaustavili sindrom "slijepog kopiranja". **Izvršenje:** Ne dopuštajte AI-ju da prvo piše poslovnu logiku. Zatražite isključivo pisanje opsežne testne suite (Unit i Integration testova) fokusirane na *Boundary Value Analysis* i rubne slučajeve. Kao inženjer, vaša primarna zadaća postaje čitanje i odobravanje tih testova. Tek nakon što su stroge granice u obliku testova postavljene i odobrene, naredite AI agentu u IDE-u (poput Cursor-a) da napiše implementacijski kod koji će te testove proći.34

### **Korak 5: Standardizacija Integracija uz Model Context Protocol (MCP)**

**Akcija:** Pripremite se za budućnost ekosustava odbacivanjem primitivnih API omotača i usvajanjem MCP standarda za sve interne alate koje AI agenti koriste. **Izvršenje:** Kada razvijate interne alate ili povezujete baze podataka sa svojim AI agentima, dizajnirajte MCP servere koji su striktno bezdržavni (stateless) i idempotentni. Osigurajte primjenu OAuth 2.1 sigurnosnih protokola i definirajte uske obuhvate (bounded contexts) sa striktnim JSON shemama kako biste spriječili "N+1 problem" i osigurali da agenti pouzdano i sigurno komuniciraju s vašim poslužiteljima.39 Integrirajte *Prompt Caching* tehnike na razini API-ja kako biste smanjili latenciju, optimizirali troškove i omogućili asinkroni, dugotrajni rad AI agenata nad vašim arhitekturama.74

#### **Works cited**

1. The Future of AI in Software Development: Tools, Risks, and Evolving Roles, accessed on March 10, 2026, [https://www.pace.edu/news/ai-software-development](https://www.pace.edu/news/ai-software-development)  
2. AI-Coding Is Not the Same as Software Engineering (And It Matters) \- Atlassian Community, accessed on March 10, 2026, [https://community.atlassian.com/forums/Rovo-articles/AI-Coding-Is-Not-the-Same-as-Software-Engineering-And-It-Matters/ba-p/3202617](https://community.atlassian.com/forums/Rovo-articles/AI-Coding-Is-Not-the-Same-as-Software-Engineering-And-It-Matters/ba-p/3202617)  
3. “You Had One Job”: Why Twenty Years of DevOps Has Failed to Do it \- Honeycomb, accessed on March 10, 2026, [https://www.honeycomb.io/blog/you-had-one-job-why-twenty-years-of-devops-has-failed-to-do-it](https://www.honeycomb.io/blog/you-had-one-job-why-twenty-years-of-devops-has-failed-to-do-it)  
4. The grief when AI writes most of the code \- The Pragmatic Engineer, accessed on March 10, 2026, [https://blog.pragmaticengineer.com/the-grief-when-ai-writes-most-of-the-code/](https://blog.pragmaticengineer.com/the-grief-when-ai-writes-most-of-the-code/)  
5. AI Won't Solve Your Toughest Engineering Problems | Honeycomb's Charity Majors by Chain of Thought \- Spotify for Creators, accessed on March 10, 2026, [https://creators.spotify.com/pod/profile/galileoai/episodes/AI-Wont-Solve-Your-Toughest-Engineering-Problems--Honeycombs-Charity-Majors-e319rmo](https://creators.spotify.com/pod/profile/galileoai/episodes/AI-Wont-Solve-Your-Toughest-Engineering-Problems--Honeycombs-Charity-Majors-e319rmo)  
6. \#120 \- Software Architecture: From Fundamentals to the Hard Parts \- Neal Ford \- YouTube, accessed on March 10, 2026, [https://www.youtube.com/watch?v=DGL8YvMZWaI](https://www.youtube.com/watch?v=DGL8YvMZWaI)  
7. The Complete Guide to System Design in 2026 \- DEV Community, accessed on March 10, 2026, [https://dev.to/fahimulhaq/complete-guide-to-system-design-oc7](https://dev.to/fahimulhaq/complete-guide-to-system-design-oc7)  
8. Gergely Orosz \- The Pragmatic Engineer, accessed on March 10, 2026, [https://blog.pragmaticengineer.com/author/gergely/](https://blog.pragmaticengineer.com/author/gergely/)  
9. AI – charity.wtf, accessed on March 10, 2026, [https://charity.wtf/category/ai/](https://charity.wtf/category/ai/)  
10. What the 2025 DORA Report Teaches Us About Observability and Platform Quality, accessed on March 10, 2026, [https://www.honeycomb.io/blog/what-2025-dora-report-teaches-us-about-observability-platform-quality](https://www.honeycomb.io/blog/what-2025-dora-report-teaches-us-about-observability-platform-quality)  
11. How to help normal engineers do great work with Charity Majors from Honeycomb, accessed on March 10, 2026, [https://www.youtube.com/watch?v=j0DQcZDwnv4](https://www.youtube.com/watch?v=j0DQcZDwnv4)  
12. What makes a senior engineer \- Swizec Teller, accessed on March 10, 2026, [https://swizec.com/blog/what-makes-a-senior-engineer/](https://swizec.com/blog/what-makes-a-senior-engineer/)  
13. AI fills my day with busywork \- Swizec Teller, accessed on March 10, 2026, [https://swizec.com/blog/ai-fills-my-day-with-busywork/](https://swizec.com/blog/ai-fills-my-day-with-busywork/)  
14. Swizec Teller, accessed on March 10, 2026, [https://swizec.com/](https://swizec.com/)  
15. Swizec Teller: What is a Senior (Engineer) Mindset? \- YouTube, accessed on March 10, 2026, [https://www.youtube.com/watch?v=gcnkQEL7CdY](https://www.youtube.com/watch?v=gcnkQEL7CdY)  
16. The architect elevator | Thoughtworks, accessed on March 10, 2026, [https://www.thoughtworks.com/insights/podcasts/technology-podcasts/architect-elevator](https://www.thoughtworks.com/insights/podcasts/technology-podcasts/architect-elevator)  
17. How a Solution Architect thinks — Part 1, working with requirements | by Anuar Nurmakanov, accessed on March 10, 2026, [https://medium.com/@ssshogunnn/how-a-solution-architect-thinks-part-1-working-with-requirements-662b81541e04](https://medium.com/@ssshogunnn/how-a-solution-architect-thinks-part-1-working-with-requirements-662b81541e04)  
18. What Makes Software Architecture So Intractable By Neal Ford \#GSAS24 \- YouTube, accessed on March 10, 2026, [https://www.youtube.com/watch?v=zcaqHVbg-LE](https://www.youtube.com/watch?v=zcaqHVbg-LE)  
19. LLM's are so much better when instructed to be socratic. : r/PromptEngineering, accessed on March 10, 2026, [https://www.reddit.com/r/PromptEngineering/comments/1re707k/llms\_are\_so\_much\_better\_when\_instructed\_to\_be/?tl=en](https://www.reddit.com/r/PromptEngineering/comments/1re707k/llms_are_so_much_better_when_instructed_to_be/?tl=en)  
20. Best AI tool for architecture and system design before "coding" starts : r/vibecoding \- Reddit, accessed on March 10, 2026, [https://www.reddit.com/r/vibecoding/comments/1olxys5/best\_ai\_tool\_for\_architecture\_and\_system\_design/](https://www.reddit.com/r/vibecoding/comments/1olxys5/best_ai_tool_for_architecture_and_system_design/)  
21. How to learn about high level architecture of popular companies like Twitter, Netflix, Uber, Facebook, Instagram, etc? : r/softwarearchitecture \- Reddit, accessed on March 10, 2026, [https://www.reddit.com/r/softwarearchitecture/comments/l8ax0h/how\_to\_learn\_about\_high\_level\_architecture\_of/](https://www.reddit.com/r/softwarearchitecture/comments/l8ax0h/how_to_learn_about_high_level_architecture_of/)  
22. How do you do code review ? & what strategy should be applied in a code review ? : r/SoftwareEngineering \- Reddit, accessed on March 10, 2026, [https://www.reddit.com/r/SoftwareEngineering/comments/18h76u4/how\_do\_you\_do\_code\_review\_what\_strategy\_should\_be/](https://www.reddit.com/r/SoftwareEngineering/comments/18h76u4/how_do_you_do_code_review_what_strategy_should_be/)  
23. Prompt Engineering: Advanced Techniques \- MLQ.ai, accessed on March 10, 2026, [https://blog.mlq.ai/prompt-engineering-advanced-techniques/](https://blog.mlq.ai/prompt-engineering-advanced-techniques/)  
24. Prompting Techniques | Prompt Engineering Guide, accessed on March 10, 2026, [https://www.promptingguide.ai/techniques](https://www.promptingguide.ai/techniques)  
25. Prompt Design and Engineering: Introduction and Advanced Methods \- arXiv, accessed on March 10, 2026, [https://arxiv.org/html/2401.14423v4](https://arxiv.org/html/2401.14423v4)  
26. The Socratic Prompt: How to Make a Language Model Stop Guessing and Start Thinking, accessed on March 10, 2026, [https://towardsai.net/p/machine-learning/the-socratic-prompt-how-to-make-a-language-model-stop-guessing-and-start-thinking](https://towardsai.net/p/machine-learning/the-socratic-prompt-how-to-make-a-language-model-stop-guessing-and-start-thinking)  
27. AI Prompting – Socratic Method – SEHD Impact, accessed on March 10, 2026, [https://sehd.ucdenver.edu/impact/2025/09/09/ai-prompting-socratic-method/](https://sehd.ucdenver.edu/impact/2025/09/09/ai-prompting-socratic-method/)  
28. The Architecture of Engineered Intelligence: From Socratic-Zero to Prompt Engineering 2.0 and Agentic AI Engineering | by Yi Zhou \- Medium, accessed on March 10, 2026, [https://medium.com/generative-ai-revolution-ai-native-transformation/the-architecture-of-engineered-intelligence-prompt-engineering-2-0-and-agentic-ai-engineering-5c4cab1aef17](https://medium.com/generative-ai-revolution-ai-native-transformation/the-architecture-of-engineered-intelligence-prompt-engineering-2-0-and-agentic-ai-engineering-5c4cab1aef17)  
29. AI Red-Teaming Is a Sociotechnical Problem \- Communications of the ACM, accessed on March 10, 2026, [https://cacm.acm.org/research/ai-red-teaming-is-a-sociotechnical-problem/](https://cacm.acm.org/research/ai-red-teaming-is-a-sociotechnical-problem/)  
30. This Is Brilliant: ChatGPT's Devil's Advocate Team : r/PromptEngineering \- Reddit, accessed on March 10, 2026, [https://www.reddit.com/r/PromptEngineering/comments/1kn61he/this\_is\_brilliant\_chatgpts\_devils\_advocate\_team/](https://www.reddit.com/r/PromptEngineering/comments/1kn61he/this_is_brilliant_chatgpts_devils_advocate_team/)  
31. Red Teaming AI Red Teaming \- arXiv, accessed on March 10, 2026, [https://arxiv.org/html/2507.05538v2](https://arxiv.org/html/2507.05538v2)  
32. The Devil's Advocate Architecture: How Multi-Agent AI Systems Mirror Human Decision-Making Psychology | by Dr. Jerry A. Smith | Medium, accessed on March 10, 2026, [https://medium.com/@jsmith0475/the-devils-advocate-architecture-how-multi-agent-ai-systems-mirror-human-decision-making-9c9e6beb09da](https://medium.com/@jsmith0475/the-devils-advocate-architecture-how-multi-agent-ai-systems-mirror-human-decision-making-9c9e6beb09da)  
33. Must Known 4 Essential AI Prompts Strategies for Developers | by Reynald \- Medium, accessed on March 10, 2026, [https://reykario.medium.com/4-must-know-ai-prompt-strategies-for-developers-0572e85a0730](https://reykario.medium.com/4-must-know-ai-prompt-strategies-for-developers-0572e85a0730)  
34. How Context-First Prompt Engineering Patterns Actually Ship Production Code, accessed on March 10, 2026, [https://www.augmentcode.com/guides/how-context-first-prompt-engineering-patterns-actually-ship-production-code](https://www.augmentcode.com/guides/how-context-first-prompt-engineering-patterns-actually-ship-production-code)  
35. Effective context engineering for AI agents \- Anthropic, accessed on March 10, 2026, [https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)  
36. Context Engineering Guide, accessed on March 10, 2026, [https://www.promptingguide.ai/guides/context-engineering-guide](https://www.promptingguide.ai/guides/context-engineering-guide)  
37. Prompt Engineering Is Dead, and Context Engineering Is Already Obsolete: Why the Future Is Automated Workflow Architecture with LLMs \- OpenAI Developer Community, accessed on March 10, 2026, [https://community.openai.com/t/prompt-engineering-is-dead-and-context-engineering-is-already-obsolete-why-the-future-is-automated-workflow-architecture-with-llms/1314011](https://community.openai.com/t/prompt-engineering-is-dead-and-context-engineering-is-already-obsolete-why-the-future-is-automated-workflow-architecture-with-llms/1314011)  
38. Engineering for AI Agents \- Redis, accessed on March 10, 2026, [https://redis.io/blog/engineering-for-ai-agents/](https://redis.io/blog/engineering-for-ai-agents/)  
39. Beyond API Wrappers: Architecting MCP Servers for Production Agentic AI Systems, accessed on March 10, 2026, [https://medium.com/@aditya\_mehra/beyond-api-wrappers-architecting-mcp-servers-for-production-agentic-ai-systems-cf93804be22a](https://medium.com/@aditya_mehra/beyond-api-wrappers-architecting-mcp-servers-for-production-agentic-ai-systems-cf93804be22a)  
40. I Tried 20+ MCP (Model Context Protocol) Courses on Udemy: Here are My Top 5 Recommendations for…, accessed on March 10, 2026, [https://medium.com/javarevisited/i-tried-20-mcp-model-context-protocol-courses-on-udemy-here-are-my-top-5-recommendations-for-921440120326](https://medium.com/javarevisited/i-tried-20-mcp-model-context-protocol-courses-on-udemy-here-are-my-top-5-recommendations-for-921440120326)  
41. Unlocking AWS Knowledge with MCP: A Complete Guide to Model Context Protocol and the MCPraxis…, accessed on March 10, 2026, [https://ashishkasaudhan.medium.com/unlocking-aws-knowledge-with-mcp-a-complete-guide-to-model-context-protocol-and-the-mcpraxis-597663eb451c](https://ashishkasaudhan.medium.com/unlocking-aws-knowledge-with-mcp-a-complete-guide-to-model-context-protocol-and-the-mcpraxis-597663eb451c)  
42. 15 Best Practices for Building MCP Servers in Production \- The New Stack, accessed on March 10, 2026, [https://thenewstack.io/15-best-practices-for-building-mcp-servers-in-production/](https://thenewstack.io/15-best-practices-for-building-mcp-servers-in-production/)  
43. The Model Context Protocol (MCP): Deep dive into structure and concepts, accessed on March 10, 2026, [https://www.analytical-software.de/en/the-model-context-protocol-mcp-deep-dive-into-structure-and-concepts/](https://www.analytical-software.de/en/the-model-context-protocol-mcp-deep-dive-into-structure-and-concepts/)  
44. Stop Using Ugly Charts: How to Build Pro-Level Diagrams with Mermaid.js and Nano Banana 2 | by Dmitry Kostyuk | Feb, 2026 | ITNEXT, accessed on March 10, 2026, [https://itnext.io/stop-using-ugly-charts-how-to-build-pro-level-diagrams-with-mermaid-js-and-nano-banana-2-f2c96d914350](https://itnext.io/stop-using-ugly-charts-how-to-build-pro-level-diagrams-with-mermaid-js-and-nano-banana-2-f2c96d914350)  
45. Mastering Mermaid JS: The Visual Superpower Every Developer Should Know, accessed on March 10, 2026, [https://levelup.gitconnected.com/mastering-mermaid-js-the-visual-superpower-every-developer-should-know-186e352b7631](https://levelup.gitconnected.com/mastering-mermaid-js-the-visual-superpower-every-developer-should-know-186e352b7631)  
46. Mermaid | Diagramming and charting tool, accessed on March 10, 2026, [https://mermaid.js.org/](https://mermaid.js.org/)  
47. Mermaid: AI-Powered Diagramming & Text-to-Chart Tool, accessed on March 10, 2026, [https://mermaid.ai/](https://mermaid.ai/)  
48. Creating Software Architecture Diagrams with Mermaid, draw.io, and ChatGPT \- Medium, accessed on March 10, 2026, [https://medium.com/@somasharma\_81597/creating-software-architecture-diagrams-with-mermaid-draw-io-and-chatgpt-4941fbf4c83a](https://medium.com/@somasharma_81597/creating-software-architecture-diagrams-with-mermaid-draw-io-and-chatgpt-4941fbf4c83a)  
49. Generating Mermaid Syntax Diagrams with AI-powered Amazon Bedrock ‍♀️, accessed on March 10, 2026, [https://blog.serverlessadvocate.com/generating-mermaid-syntax-diagrams-with-ai-powered-amazon-bedrock-%EF%B8%8F-29f8dd1602d3](https://blog.serverlessadvocate.com/generating-mermaid-syntax-diagrams-with-ai-powered-amazon-bedrock-%EF%B8%8F-29f8dd1602d3)  
50. Build diagrams with Mermaid JS \- Datadog Docs, accessed on March 10, 2026, [https://docs.datadoghq.com/notebooks/guide/build\_diagrams\_with\_mermaidjs/](https://docs.datadoghq.com/notebooks/guide/build_diagrams_with_mermaidjs/)  
51. Best AI diagram tools in 2025 \- Eraser.io, accessed on March 10, 2026, [https://www.eraser.io/guides/best-ai-diagram-tools-in-2025](https://www.eraser.io/guides/best-ai-diagram-tools-in-2025)  
52. Top 5 System Design Diagram Tools: How the Best Apps Are Planned in 2026 \- Medium, accessed on March 10, 2026, [https://medium.com/@cloudairyhq/top-5-system-design-diagram-tools-how-the-best-apps-are-planned-in-2026-8a4f93664593](https://medium.com/@cloudairyhq/top-5-system-design-diagram-tools-how-the-best-apps-are-planned-in-2026-8a4f93664593)  
53. CAP Theorem in System Design: A Complete Interview Guide for Engineers, accessed on March 10, 2026, [https://www.systemdesignhandbook.com/guides/cap-theorem-in-system-design/](https://www.systemdesignhandbook.com/guides/cap-theorem-in-system-design/)  
54. The CAP Theorem in Distributed Systems: Understanding the Tradeoffs Between Consistency, Availability, and Partition Tolerance | by SEEKR | Medium, accessed on March 10, 2026, [https://medium.com/@capitalcoin007/the-cap-theorem-in-distributed-systems-understanding-the-tradeoffs-between-consistency-b890c4f85ce4](https://medium.com/@capitalcoin007/the-cap-theorem-in-distributed-systems-understanding-the-tradeoffs-between-consistency-b890c4f85ce4)  
55. CAP Theorem & Strategies for Distributed Systems | Splunk, accessed on March 10, 2026, [https://www.splunk.com/en\_us/blog/learn/cap-theorem.html](https://www.splunk.com/en_us/blog/learn/cap-theorem.html)  
56. What Is CAP Theorem and Why It Matters for AI Storage \- MinIO, accessed on March 10, 2026, [https://www.min.io/learn/cap-theorem](https://www.min.io/learn/cap-theorem)  
57. How Netflix, Uber, and Google Build AI Systems: Architecture Deep Dive \- DEV Community, accessed on March 10, 2026, [https://dev.to/matt\_frank\_usa/how-netflix-uber-and-google-build-ai-systems-architecture-deep-dive-17g5](https://dev.to/matt_frank_usa/how-netflix-uber-and-google-build-ai-systems-architecture-deep-dive-17g5)  
58. Software Tools: Generative AI Prompts | Grounded Architecture ..., accessed on March 10, 2026, [https://grounded-architecture.io/gen-ai-prompts](https://grounded-architecture.io/gen-ai-prompts)  
59. AI generated Architecture Decision Records (ADR) \- Adolfi.dev, accessed on March 10, 2026, [https://adolfi.dev/blog/ai-generated-adr/](https://adolfi.dev/blog/ai-generated-adr/)  
60. Architecture decision record (ADR) examples for software planning, IT leadership, and template documentation \- GitHub, accessed on March 10, 2026, [https://github.com/joelparkerhenderson/architecture-decision-record](https://github.com/joelparkerhenderson/architecture-decision-record)  
61. Streamlining Architecture Decision Records with ADR Sync | by Yuji Isobe | Medium, accessed on March 10, 2026, [https://medium.com/@yujiisobe/streamlining-architecture-decision-records-with-adr-sync-2a0e38c309a1](https://medium.com/@yujiisobe/streamlining-architecture-decision-records-with-adr-sync-2a0e38c309a1)  
62. Accelerating Architectural Decision Records (ADRs) with Generative AI | Equal Experts, accessed on March 10, 2026, [https://www.equalexperts.com/blog/our-thinking/accelerating-architectural-decision-records-adrs-with-generative-ai/](https://www.equalexperts.com/blog/our-thinking/accelerating-architectural-decision-records-adrs-with-generative-ai/)  
63. Kinde From Jira Ticket to Production Code: AI-Powered Spec ..., accessed on March 10, 2026, [https://kinde.com/learn/ai-for-software-engineering/workflows/from-jira-ticket-to-production-code-ai-powered-spec-workflows/](https://kinde.com/learn/ai-for-software-engineering/workflows/from-jira-ticket-to-production-code-ai-powered-spec-workflows/)  
64. Implementing AI in Jira Workflow Design: A Complete Technical and Architectural Guide with Use Cases \- Atlassian Community, accessed on March 10, 2026, [https://community.atlassian.com/forums/Jira-Cloud-Admins-articles/Implementing-AI-in-Jira-Workflow-Design-A-Complete-Technical-and/ba-p/3194644](https://community.atlassian.com/forums/Jira-Cloud-Admins-articles/Implementing-AI-in-Jira-Workflow-Design-A-Complete-Technical-and/ba-p/3194644)  
65. A Code Review Checklist \- Focus on these 10 Important Topics \- Dr. Michaela Greiler, accessed on March 10, 2026, [https://www.michaelagreiler.com/code-review-checklist-2/](https://www.michaelagreiler.com/code-review-checklist-2/)  
66. The Ultimate Code Review Checklist for Developers \- Axify, accessed on March 10, 2026, [https://axify.io/blog/code-review-checklist](https://axify.io/blog/code-review-checklist)  
67. Effective Code Review Checklist \- Chirag Goel \- Medium, accessed on March 10, 2026, [https://engineerchirag.medium.com/effective-code-review-checklist-c735abbcd613](https://engineerchirag.medium.com/effective-code-review-checklist-c735abbcd613)  
68. Your Questions About AI-Assisted Development Answered \- Honeycomb, accessed on March 10, 2026, [https://www.honeycomb.io/blog/your-questions-about-ai-assisted-development-answered](https://www.honeycomb.io/blog/your-questions-about-ai-assisted-development-answered)  
69. Prompt Engineering In Software Testing: AI for QA Guide, accessed on March 10, 2026, [https://testfort.com/blog/prompt-engineering-in-software-testing](https://testfort.com/blog/prompt-engineering-in-software-testing)  
70. What Are Edge Test Cases & How AI Helps \- testRigor AI-Based Automated Testing Tool, accessed on March 10, 2026, [https://testrigor.com/blog/what-are-edge-test-cases/](https://testrigor.com/blog/what-are-edge-test-cases/)  
71. Writing Effective Prompts for Testing Scenarios: AI Assisted Quality Engineering, accessed on March 10, 2026, [https://techcommunity.microsoft.com/blog/azuredevcommunityblog/writing-effective-prompts-for-testing-scenarios-ai-assisted-quality-engineering/4488001](https://techcommunity.microsoft.com/blog/azuredevcommunityblog/writing-effective-prompts-for-testing-scenarios-ai-assisted-quality-engineering/4488001)  
72. Boundary Value Test Input Generation Using Prompt Engineering with LLMs: Fault Detection and Coverage Analysis \- arXiv, accessed on March 10, 2026, [https://arxiv.org/html/2501.14465v1](https://arxiv.org/html/2501.14465v1)  
73. Awesome QA Prompt: Using AI to Make Testing Work Better | by Nao | Jan, 2026 | Medium, accessed on March 10, 2026, [https://naodeng.medium.com/awesome-qa-prompt-using-ai-to-make-testing-work-better-0b0a1b8b36b9](https://naodeng.medium.com/awesome-qa-prompt-using-ai-to-make-testing-work-better-0b0a1b8b36b9)  
74. Build Hour: Prompt Caching \- YouTube, accessed on March 10, 2026, [https://www.youtube.com/watch?v=tECAkJAI\_Vk](https://www.youtube.com/watch?v=tECAkJAI_Vk)  
75. Cache engineering : how to build successful Agents : r/ClaudeCode \- Reddit, accessed on March 10, 2026, [https://www.reddit.com/r/ClaudeCode/comments/1r9dfpx/cache\_engineering\_how\_to\_build\_successful\_agents/](https://www.reddit.com/r/ClaudeCode/comments/1r9dfpx/cache_engineering_how_to_build_successful_agents/)  
76. Building an AI-native engineering team | OpenAI, accessed on March 10, 2026, [https://cdn.openai.com/business-guides-and-resources/building-an-ai-native-engineering-team.pdf](https://cdn.openai.com/business-guides-and-resources/building-an-ai-native-engineering-team.pdf)