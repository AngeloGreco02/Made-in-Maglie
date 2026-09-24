-- Made in Maglie: richieste commerciali e directory attività
create table if not exists public.business_requests (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  category text not null,
  owner_name text not null,
  email text not null,
  phone text not null,
  address text not null,
  instagram text,
  facebook text,
  website text,
  description text not null,
  message text,
  plan text not null default 'Free',
  status text not null default 'nuova' check (status in ('nuova','contattata','approvata','rifiutata')),
  created_at timestamptz not null default now()
);

alter table public.business_requests enable row level security;

drop policy if exists "Public can submit business requests" on public.business_requests;
create policy "Public can submit business requests"
on public.business_requests
for insert to anon, authenticated
with check (true);

drop policy if exists "Admin can read business requests" on public.business_requests;
create policy "Admin can read business requests"
on public.business_requests
for select to authenticated
using (auth.uid() = 'ADMIN_UUID'::uuid);

drop policy if exists "Admin can update business requests" on public.business_requests;
create policy "Admin can update business requests"
on public.business_requests
for update to authenticated
using (auth.uid() = 'ADMIN_UUID'::uuid)
with check (auth.uid() = 'ADMIN_UUID'::uuid);

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  category text not null,
  address text,
  phone text,
  whatsapp text,
  website text,
  instagram text,
  facebook text,
  description text,
  logo_url text,
  cover_url text,
  google_maps_url text,
  status text not null default 'published' check (status in ('draft','published','archived')),
  featured boolean not null default false,
  package text not null default 'Free',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.businesses enable row level security;

drop policy if exists "Public can read published businesses" on public.businesses;
create policy "Public can read published businesses"
on public.businesses
for select to anon, authenticated
using (status = 'published');

drop policy if exists "Admin can manage businesses" on public.businesses;
create policy "Admin can manage businesses"
on public.businesses
for all to authenticated
using (auth.uid() = 'ADMIN_UUID'::uuid)
with check (auth.uid() = 'ADMIN_UUID'::uuid);

-- Dati iniziali corrispondenti alle attività già presenti nel sito.
insert into public.businesses (name, category, address, status)
select * from (values
('Candido 1859','Moda e stile','Piazza Aldo Moro, 9, 73024 Maglie LE','published'),
('Amélie Restaurant','Gusto e sapori','Via Giuseppe Garibaldi, 12, 73024 Maglie LE','published'),
('Caffè Leopardi','Gusto e sapori','Via Alcide De Gasperi, 7, 73024 Maglie LE','published'),
('Corso Vittorio Outlet','Moda e stile','Via Vittorio Emanuele, 119, 73024 Maglie LE','published'),
('Belami - Hotel Ristorante Cantina','Gusto e ospitalità','Via Roma, 86, 73024 Maglie LE','published'),
('Cubi','Gusto e sapori','Via S. Giuseppe, 12, 73024 Maglie LE','published'),
('ONCE','Arte e artigianato','Via Fratelli Piccinno, 90, 73024 Maglie LE','published'),
('CRiS&CO','Moda e stile','Via Umberto I, 51, 73024 Maglie LE','published'),
('Classico Maglie','Gusto e sapori','Piazza Aldo Moro, 22, 73024 Maglie LE','published'),
('Caffè della Libertà','Gusto e sapori','Piazza Aldo Moro, 16, 73024 Maglie LE','published'),
('La Sellerie Limited','Moda e stile','Via Giacomo Matteotti, 15, 73024 Maglie LE','published'),
('Negro Service - Punto Edison Maglie','Servizi','Via Scorrano, 5, 73024 Maglie LE','published'),
('TRENDY','Moda e stile','Via Francesca Capece, 12, 73024 Maglie LE','published'),
('Maglie Territorio Ambiente Servizi','Servizi','Via Indipendenza, 5, 73024 Maglie LE','published'),
('Salute e Benessere','Salute e benessere','Maglie, Lecce','published')
) as v(name,category,address,status)
where not exists (
  select 1 from public.businesses b where lower(b.name)=lower(v.name)
);