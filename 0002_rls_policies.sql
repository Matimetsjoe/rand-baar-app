-- ================================================================
-- Rand & Baar / Resort Ordering App — RLS reeglid ja külalise
-- tellimuse jälgimise funktsioon
-- Käivita Supabase projekti SQL Editoris pärast 0001_init.sql
-- ================================================================

-- ---------------------------------------------------------------
-- STAFF_USERS: personal peab saama lugeda OMA rida, muidu ei tööta
-- ükski teine policy, mis viitab staff_users tabelile subpäringus.
-- ---------------------------------------------------------------
create policy "staff_reads_own_row"
  on staff_users for select
  using (auth_user_id = auth.uid());


-- ---------------------------------------------------------------
-- MENU_ITEMS
-- ---------------------------------------------------------------
-- Igaüks (sh anonüümne külaline) näeb saadaolevaid tooteid —
-- menüü peab ju avanema ilma sisselogimiseta.
create policy "public_reads_available_menu_items"
  on menu_items for select
  using (is_available = true);

-- Personal näeb oma hotelli KÕIKI tooteid, k.a. "otsas" olevad
-- (vajalik "Menu Availability" paneeli jaoks).
create policy "staff_reads_own_property_menu_items"
  on menu_items for select
  using (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  );

-- Personal saab tooteid "otsas / saadaval" märkida ainult oma hotellis.
create policy "staff_updates_own_property_menu_items"
  on menu_items for update
  using (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  )
  with check (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  );


-- ---------------------------------------------------------------
-- ORDERS
-- ---------------------------------------------------------------
-- Külaline (anonüümne) saab luua uue tellimuse. Ei anna avalikku
-- SELECT õigust, sest orders sisaldab guest_name / room_number.
create policy "anyone_can_create_order"
  on orders for insert
  with check (true);

-- Personal näeb ainult oma hotelli tellimusi (KDS-i jaoks).
create policy "staff_sees_own_property_orders"
  on orders for select
  using (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  );

-- Personal saab muuta staatust (new -> preparing -> ready -> delivered)
-- ainult oma hotelli tellimustel.
create policy "staff_updates_own_property_orders"
  on orders for update
  using (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  )
  with check (
    property_id in (
      select property_id from staff_users where auth_user_id = auth.uid()
    )
  );


-- ---------------------------------------------------------------
-- ORDER_ITEMS — see tabel jäi eelmises migratsioonis kaitseta,
-- lülitame RLS nüüd ka sellele sisse.
-- ---------------------------------------------------------------
alter table order_items enable row level security;

-- Külaline saab lisada read oma äsja loodud tellimusele.
create policy "anyone_can_add_order_items"
  on order_items for insert
  with check (true);

-- Personal näeb oma hotelli tellimuste ridu.
create policy "staff_sees_own_property_order_items"
  on order_items for select
  using (
    order_id in (
      select id from orders
      where property_id in (
        select property_id from staff_users where auth_user_id = auth.uid()
      )
    )
  );


-- ---------------------------------------------------------------
-- KÜLALISE TELLIMUSE JÄLGIMINE
-- Turvaline viis külalisele staatust näidata ilma, et ta saaks
-- otse orders tabelit lugeda (kaitseb guest_name / room_number).
-- SECURITY DEFINER = funktsioon jookseb tõstetud õigustega,
-- aga tagastab TEADLIKULT ainult mittetundlikud väljad.
-- ---------------------------------------------------------------
create or replace function get_order_status(p_order_id uuid)
returns table (
  id uuid,
  status text,
  created_at timestamptz,
  item_name text,
  item_qty int
)
language sql
security definer
set search_path = public
as $$
  select
    o.id,
    o.status,
    o.created_at,
    oi.name as item_name,
    oi.qty as item_qty
  from orders o
  join order_items oi on oi.order_id = o.id
  where o.id = p_order_id;
$$;

-- Anonüümne külaline (ja sisselogitud kasutajad) tohivad seda funktsiooni kutsuda.
grant execute on function get_order_status(uuid) to anon, authenticated;
