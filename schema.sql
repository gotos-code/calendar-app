-- Calendar app — full schema for a brand-new Supabase project.
-- Run this once, top to bottom, in the new project's SQL Editor.

-- ---------- profiles ----------
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  company_name text,
  last_name text,
  first_name text,
  approved boolean not null default false,
  role text not null default 'client' check (role in ('admin','client','operator')),
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

create or replace function is_admin(uid uuid) returns boolean
language sql security definer stable as $$
  select coalesce((select role = 'admin' from profiles where id = uid), false);
$$;

create or replace function is_approved(uid uuid) returns boolean
language sql security definer stable as $$
  select coalesce((select approved from profiles where id = uid), false);
$$;

create or replace function is_operator(uid uuid) returns boolean
language sql security definer stable as $$
  select coalesce((select role = 'operator' from profiles where id = uid), false);
$$;

create policy "own profile select" on profiles for select using (auth.uid() = id);
create policy "own profile update" on profiles for update using (auth.uid() = id);
create policy "admin select all profiles" on profiles for select using (is_admin(auth.uid()));
create policy "admin update all profiles" on profiles for update using (is_admin(auth.uid()));
create policy "approved select all profiles" on profiles for select using (is_approved(auth.uid()));

create or replace function handle_new_user() returns trigger
language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, company_name, last_name, first_name)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'company_name',
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'first_name'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ---------- events ----------
create table events (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  event_type text not null default 'personal' check (event_type in ('personal','appointment')),
  start_at timestamptz not null,
  end_at timestamptz,
  all_day boolean not null default false,
  memo text,
  negotiable boolean not null default false,
  created_at timestamptz not null default now()
);

alter table events enable row level security;

create policy "approved select all events" on events for select using (is_approved(auth.uid()));
create policy "own insert events" on events for insert with check (owner_id = auth.uid() and is_approved(auth.uid()));
create policy "own update events" on events for update using (owner_id = auth.uid() or is_admin(auth.uid()));
create policy "own delete events" on events for delete using (
  (owner_id = auth.uid() and not is_operator(auth.uid())) or is_admin(auth.uid())
);

-- ---------- app_settings ----------
create table app_settings (
  id int primary key default 1,
  client_name text not null default '',
  operator_lead_business_days int not null default 5,
  check (id = 1)
);
insert into app_settings (id, operator_lead_business_days) values (1, 5);

alter table app_settings enable row level security;
create policy "approved select settings" on app_settings for select using (is_approved(auth.uid()));
create policy "admin update settings" on app_settings for update using (is_admin(auth.uid()));

-- ---------- realtime ----------
alter publication supabase_realtime add table events;
alter publication supabase_realtime add table app_settings;

-- ---------- after running the above ----------
-- 1. Sign up your own account through signup.html on the new site.
-- 2. Then run (with your own email):
--    update profiles set role = 'admin', approved = true where email = 'you@example.com';
