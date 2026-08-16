-- ================================================================
-- Rand & Baar / Resort Ordering App — algne andmebaasi struktuur
-- Käivita Supabase projekti SQL Editoris (Database > SQL Editor)
-- ================================================================

-- Laienduse jaoks UUID genereerimiseks
create extension if not exists "pgcrypto";

-- ---------- HOTELLID / KUURORDID ----------
create table properties (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  currency text not null default 'EUR',
  created_at timestamptz not null default now()
);

-- ---------- TSOONID (rand, bassein, restoran) ----------
create table zones (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

-- ---------- LAUAD / KOHAD (QR-koodiga) ----------
create table tables (
  id uuid primary key default gen_random_uuid(),
  zone_id uuid not null references zones(id) on delete cascade,
  label text not null,          -- nt "Laud 12", "Lamamistool 5"
  qr_code text unique not null, -- unikaalne kood, mida QR-pilt kodeerib
  created_at timestamptz not null default now()
);

-- ---------- MENÜÜ TOOTED ----------
create table menu_items (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  category text not null,       -- nt "Joogid", "Söök"
  name text not null,
  description text,
  price numeric(10,2) not null default 0,
  is_paid boolean not null default true,  -- false = tasuta/sisaldub majutuses
  is_available boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- PERSONAL ----------
create table staff_users (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  name text not null,
  role text not null check (role in ('kitchen','bar','waiter','reception','admin')),
  auth_user_id uuid references auth.users(id),  -- seotud Supabase Auth kasutajaga
  pin text,                     -- valikuline PIN-kood kiireks sisselogimiseks tahvlis
  created_at timestamptz not null default now()
);

-- ---------- TELLIMUSED ----------
create table orders (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  zone_id uuid not null references zones(id),
  table_id uuid not null references tables(id),
  room_number text,
  guest_name text,
  settlement_method text not null default 'none'
    check (settlement_method in ('none','waiter','room')),
  status text not null default 'new'
    check (status in ('new','preparing','ready','delivered')),
  total numeric(10,2) not null default 0,
  billed boolean not null default false,
  billed_at timestamptz,
  delivered_by text,            -- nt 'guest' või 'staff:Jaan'
  delivered_at timestamptz,
  created_at timestamptz not null default now()
);

-- ---------- TELLIMUSE READ (konkreetsed tooted tellimuses) ----------
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  menu_item_id uuid references menu_items(id),
  name text not null,           -- salvestame nime/hinna hetkeseisuga, et hilisem menüümuutus ei rikuks ajalugu
  price numeric(10,2) not null,
  qty int not null default 1
);

-- ---------- INDEKSID kiiremaks päringuteks ----------
create index idx_orders_property_status on orders(property_id, status);
create index idx_orders_room on orders(property_id, room_number);
create index idx_menu_items_property on menu_items(property_id, is_available);
create index idx_tables_zone on tables(zone_id);

-- ================================================================
-- ROW LEVEL SECURITY — igaüks näeb ainult oma hotelli andmeid
-- (aktiveeri hiljem, kui personali autentimine on paigas)
-- ================================================================
alter table orders enable row level security;
alter table menu_items enable row level security;
alter table staff_users enable row level security;

-- Näide: personal näeb ainult oma property_id tellimusi
-- (see policy eeldab, et staff_users.auth_user_id on seotud auth.uid()-ga)
create policy "staff_sees_own_property_orders"
  on orders for select
  using (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  );
