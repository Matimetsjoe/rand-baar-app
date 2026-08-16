# Rand & Baar — kuurordi tellimisrakendus

QR-põhine tellimissüsteem kuurortitele/hotellidele — külaline skaneerib laua/koha
koodi rannas, basseini ääres või restoranis, tellib toidu/joogi mobiilist, ja
tellimus jõuab reaalajas õigesse kööki/baari. Tasulised tooted saab maksta kas
kelnerile kohapeal või lisada toa arvele.

## Struktuur

```
/docs                     — projekti märkmed, otsused, "enne live minekut" nimekiri
/supabase/migrations      — andmebaasi SQL-skeem (Supabase/PostgreSQL)
```

## Tehnoloogiapinu

- **Andmebaas**: Supabase (PostgreSQL, EU/Frankfurt regioon)
- **Frontend hosting**: Cloudflare Pages
- **Kliendi äpp**: React/web (PWA)
- **Personali tahvel**: Flutter / Android-native
- **Admin-paneel**: React

Täpsemad otsused ja põhjendused: [`docs/projekti-markmed.md`](docs/projekti-markmed.md)

## Andmebaas

Skeem asub failis [`supabase/migrations/0001_init.sql`](supabase/migrations/0001_init.sql).
Käivita see Supabase projekti SQL Editoris (valides "Run without RLS" arendusfaasis).

⚠️ Enne päris kliendiga live minekut vaata läbi `docs/projekti-markmed.md` lõpus
olev kontrollnimekiri (RLS, autentimine, varukoopiad).
