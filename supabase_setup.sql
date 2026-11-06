-- =====================================================
--  مكتبة دار سبك — إعداد قاعدة البيانات (Supabase)
--  الصق هذا الملف كله في: SQL Editor ثم اضغط Run
--  (تكدر تشغله أكثر من مرة بدون مشكلة)
-- =====================================================

-- 1) الجداول
create table if not exists public.categories (
  id        text primary key,
  ar        text not null,
  en        text default '',
  icon      text default '',
  img_url   text default '',
  position  bigint default 0
);

create table if not exists public.books (
  id         text primary key,
  cat_id     text not null references public.categories(id) on delete cascade,
  t          text default '',   -- اسم الكتاب
  a          text default '',   -- المؤلف
  d          text default '',   -- النبذة
  p          text default '',   -- السعر
  img_url    text default '',   -- رابط الغلاف
  position   bigint default 0,
  s          boolean default false,  -- كتاب تجريبي
  created_at timestamptz default now()
);

create table if not exists public.settings (
  key   text primary key,
  value jsonb not null
);

-- 2) الحماية (RLS): الكل يقرأ، والأدمن المسجّل فقط يكتب
alter table public.categories enable row level security;
alter table public.books      enable row level security;
alter table public.settings   enable row level security;

drop policy if exists "read categories"  on public.categories;
drop policy if exists "write categories" on public.categories;
drop policy if exists "read books"       on public.books;
drop policy if exists "write books"      on public.books;
drop policy if exists "read settings"    on public.settings;
drop policy if exists "write settings"   on public.settings;

create policy "read categories"  on public.categories for select using (true);
create policy "read books"       on public.books      for select using (true);
create policy "read settings"    on public.settings   for select using (true);

create policy "write categories" on public.categories for all to authenticated using (true) with check (true);
create policy "write books"      on public.books      for all to authenticated using (true) with check (true);
create policy "write settings"   on public.settings   for all to authenticated using (true) with check (true);

-- 3) مخزن صور الأغلفة (عام للقراءة، والأدمن فقط يرفع)
insert into storage.buckets (id, name, public)
values ('covers', 'covers', true)
on conflict (id) do update set public = true;

drop policy if exists "covers read"   on storage.objects;
drop policy if exists "covers insert" on storage.objects;
drop policy if exists "covers update" on storage.objects;
drop policy if exists "covers delete" on storage.objects;

create policy "covers read"   on storage.objects for select using (bucket_id = 'covers');
create policy "covers insert" on storage.objects for insert to authenticated with check (bucket_id = 'covers');
create policy "covers update" on storage.objects for update to authenticated using (bucket_id = 'covers');
create policy "covers delete" on storage.objects for delete to authenticated using (bucket_id = 'covers');
