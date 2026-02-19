PROJEKTNA INICIJATIVA

Business Product Catalog (BPC)

# Naziv projekta

Redizajn postojeće chatbot baze i njen upgrade na „Business Product Catalog (BPC)“.

# Inicijator projekta

IT Direkcija – Sektor za OSS/BSS IT sisteme

# Uvod

Trenutno ne postoji centralni elektronski cjenovnik koji bi služio kao izvor podataka za sve poslovne i tehničke sisteme. Cjenovnik se održava ručno, u Word i PDF formatu, bez strukturisane baze. Zbog toga su podaci teško pretraživi, neprilagođeni za automatizaciju i ne mogu se koristiti u sistemima kao što su chtatbot, Revenue Assurance, DWH, mobilna aplikacija i sl. Pretraga Cjenovnika od strane prodajnog osoblja i osoblja podrške je otežana, odnosno ne postoji napredni search cjenovnika.

Chatbot sistem koristi posebnu internu bazu, kreiranu za potrebe projekta chatbot-a, koja nije dizajnirana kao centralni izvor podataka. Zbog toga postoji potreba da se isti podaci održavaju paralelno u više sistema, što povećava rizik od grešaka i dodatno opterećuje resurse IT i poslovnih sektora.

# Cilj projekta

Cilj projekta je kreirati centralizovani, strukturisani Business Product Catalog (BPC) koji će postati jedinstveni izvor podataka o svim uslugama i tarifnim paketima BH Telecoma.

Novi BPC sistem će omogućiti:

- Standardizovan i kontrolisan unos podataka o uslugama i tarifnim paketima.
- Razmjenu i korištenje podataka u više IT i poslovnih sistema (chatbot, JPP, mobilna aplikacija, Revenue Assurance, DWH).
- Automatsko generisanje zvaničnih dokumenata – PDF cjenovnika, izvoda iz cjenovnika i sažetaka ugovora.

# Scope projekta

Projekat obuhvata sljedeće aktivnosti i komponente:

- Analizu postojeće chatbot baze i dizajn nove baze podataka (proširene za sve potrebne elemente).
- Definisanje meta-modela i strukture BPC baze.
- Izradu administrativnih formi (unos, ažuriranje, publishing).
- Razvoj API servisa za razmjenu podataka sa JPP, chatbotom, mobilnom aplikacijom, DWH i Revenue Assurance sistemima.
- Implementaciju mehanizma za automatsko generisanje PDF dokumenata.
- Napredna pretraga cjenovnika za prodajno i osoblje podrške
- Uspostavljanje procesa održavanja i verzioniranja podataka u BPC sistemu.
Projekat ne obuhvata funkcionalne promjene u poslovnim procesima unosa i odobravanja sadržaja (to ostaje u nadležnosti IDRP-a).

Ključne funkcionalnosti BPC sistema:

- Role-based unos i izmjene
BPC omogućava kontrolisan unos i ažuriranje podataka prema korisničkim ulogama (IDRP, pravna služba, IT). Svaka uloga ima jasno definisan set prava – unos, odobravanje, potvrđivanje i publikovanje podataka.

- Jedinstveni unos podataka
Svi podaci o uslugama unose se na jednom mjestu i automatski koriste u više sistema (sažeci ugovora, web stranica, chatbot, Revenue Assurance, DWH). Time se eliminiše višestruki unos i povećava konzistentnost

- Verzioniranje i historija izmjena
Svaka objavljena verzija cjenovnika i servisa ima jedinstvenu oznaku verzije. Sistem čuva potpunu historiju izmjena i omogućava pregled razlika između verzija.

Ove funkcionalnosti čine osnovu novog koncepta BPC-a kao centralnog i jedinstvenog izvora istine (Single Source of Truth) za sve podatke o uslugama i tarifama.

Funkcionalna arhitektura sistema:

# Aktivnosti / Faze projekta

Prijedlog je da se projekat radi u 5 faza:

Faza 1 – Analiza postojećeg stanja i zahtjeva

- Analiza strukture postojeće chatbot baze.
- Identifikacija nedostajućih polja potrebnih za druge sisteme.
- Prikupljanje Word urneka (cjenovnik, izvod, sažetak) i specifikacije zahtjeva za naprednu pretragu cjenovnika od IDRP-a.
- Analiza unije i presjeka elemenata dokumenata i definisanje obaveznih polja.

Faza 2 – Dizajn nove baze i API strukture (BPC)

- Dizajn meta-modela baze prema analiziranim potrebama.
- Definisanje verzioniranja, kontrola i publish mehanizama.
- Dizajn API sloja za komunikaciju sa integrisanim sistemima.

Faza 3 – Razvoj i implementacija

- Razvoj baze i formi za unos i ažuriranje podataka.
- Razvoj API-ja
- Razvoj mehanizama napredne pretrage za prodajno osoblje i osoblje podrške
- Razvoj mehanizma za automatsko generisanje PDF dokumenata.
- Povezivanje sa chatbot sistemom i drugim internim servisima.

Faza 4 – Testiranje i validacija

- Funkcionalno testiranje (BPC, PDF, API).
- Test integracije sa JPP, chatbotom i DWH sistemima.
- Validacija sadržaja u saradnji sa IDRP timom.

Faza 5 – Produkcija i održavanje

- Deploy u produkciono okruženje.
- Obuka Product Ownera za unos i održavanje podataka.
- Uspostavljanje procedura održavanja i verzioniranja.

# Očekivani rezultati

- Implementiran BPC sistem sa centralnom bazom podataka.
- API interfejsi prema internim sistemima.
- Alati za naprednu pretragu cjenovnika
- Automatizovano generisanje PDF dokumenata (cjenovnik, izvod, sažetak).
- Jedinstveni izvor podataka o uslugama za sve poslovne i tehničke sisteme.

# Potrebni resursi

Za realizaciju projekta neophodni su:

- IT resursi (razvoj, testiranje, integracije), Tehnička podrška za servere, baze i API gateway.
- Učešće IDRP-a (dostava dokumenata i specifikacija i validacija sadržaja)

Potrebno je formirati Tim sa sljedećim zadacima i nosiocima:

- Specifikacija zahtjeva, urneci dokumenata, validacija sadržaja:
- Amra Jaliman
- Sanita Maglić
- Andrea Kapel-Kozarić
- Emir Duraković
- Mahira Vojvodić
- Alen Ramić
- Adil Izetbegović
- Analiza i arhitektura rješenja
- Dženana Meholjić
- Kanita Imamović Čatić
- Razvoj:
- Amil Čohadžić
- Kenan Sabljaković
- Alma Brajlović
- Lejla Šarić
- (možda i ove nove koji će doći na mjesto developera)
- QA
- Aida Merdović
- Fatima Dautović
# Rizici

- Nedostatak resursa u IT-u zbog postojećeg opterećenja.
- Rizik usklađivanja sa budućim ODA/TMF standardima.
# Zaključak / Preporuka

Predlaže se pokretanje projekta „Business Product Catalog (BPC)” kao strateškog koraka ka centralizaciji podataka o uslugama i smanjenju duplog unosa informacija, uz plan fazne implementacije do Q2 2026. godine.

BPC će dugoročno omogućiti:

- konzistentnost i jedinstvenost podataka,
- automatizaciju procesa,
- efikasniju saradnju između IT i poslovnih sektora,
- brže reagovanje na regulatorne i tržišne promjene.
