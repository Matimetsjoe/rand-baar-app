# Rand & Baar — projekti märkmed

## Toote kontseptsioon
- QR-kood igas tsoonis/laual (rand, bassein, restoran) → viib mobiilis menüüsse
- Menüü jaguneb kaheks: **tasuta tooted** (sisaldub majutuses) ja **tasulised lisatooted**
- Tasuliste eest saab maksta kahel moel:
  - Kelner toob kohale ja võtab makse kohapeal (kaart/sularaha) — **ei vaja PMS-integratsiooni**
  - Lisatakse toa arvele — vajab hiljem PMS-i "folio" API integratsiooni
- Tellimuse staatused: Uus → Valmistamisel → Valmis → Kätte antud (kinnitab klient ise, või kelner varuvariandina koos nimega)

## Tehnoloogiapinu
| Kiht | Valik | Põhjendus |
|---|---|---|
| Andmebaas | Supabase (PostgreSQL, Frankfurt regioon) | Relatsiooniline andmemudel, tasuta realtime, EU andmekeskus |
| Frontend hosting | Cloudflare Pages | Tasuta, kiire globaalne CDN, GitHub auto-deploy |
| Kliendi äpp | React/web (PWA) | Peab QR-skaneerimisel koheselt laadima — Flutter Web liiga aeglane |
| Personali tahvel | Flutter või Android-native | Vajab kiosk-režiimi, heli/vibra kontrolli |
| Admin-paneel | React (veebipõhine) | Kasutatakse peamiselt arvutist |
| Versioonihaldus | GitHub | Repo ühendatud Cloudflare Pages'iga, SQL-migratsioonid samas repos |

## Andmebaasi struktuur
Tabelid loodud: `properties`, `zones`, `tables`, `menu_items`, `staff_users`, `orders`, `order_items`
(täisskeem failis `supabase-schema.sql`)

## Ärimudel
- **Baastasu**: hooajapõhine (5-7 kuud), suuruse järgi 800-5000 €/hooaeg
- **Tehingutasu**: 1,5-2,5% tasulistest tellimustest (või 0,15-0,25 €/tellimus)
- **Piloot**: esimesed 2-3 klienti — tasuta/odav hooaeg vastutasuks case study + referents

## Sihtturg
- **Eesti** = piloot/testimine (väike turg, madal risk)
- **Peamine turg** = Vahemeri (Hispaania, Kreeka, Türgi) — kasvav all-inclusive/kuurorditurg
- Konkurent Qerko (Tšehhi) on makse-keskne, mitte kuurordi/tsoonipõhine — meie nišš on eristuv

## PMS-integratsiooni valikud (hilisemaks etapiks)
| PMS | Sisenemise lihtsus |
|---|---|
| Mews | Lihtne, iseteenindus-API |
| Cloudbeds | Lihtne, iseteenindus-API |
| Oracle OPERA Cloud | Kulukas (partnerlus + sertifitseerimine), ainult suurte kettide jaoks |

---

## ⚠️ ENNE PÄRIS KLIENDI/HOTELLIGA LIVE MINEKUT

- [ ] **Supabase Pro peale liikuda** (~25 €/kuu) — free tier'il pole varukoopiaid, andmete kaotamise risk
- [ ] **Row Level Security (RLS) sisse lülitada** kõikidele tabelitele — praegu on tabelid avatud, kuna RLS lülitati arendusfaasis välja
- [ ] **Personali autentimine paika panna** (Supabase Auth ↔ `staff_users` seos) — RLS policy'd eeldavad seda
- [ ] Kaardimakse/PMS-integratsioon reaalselt testida, kui minnakse "toa arvele" mudelile
- [ ] Varukoopiate automatiseerimine kontrollida (GitHub Actions + regulaarne dump)

---
*Viimati uuendatud: vestluse käigus, täienda jooksvalt uute otsustega.*
