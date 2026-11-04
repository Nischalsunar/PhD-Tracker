-- Versioned document records keep professors, applications, events and tasks distinct.
create table public.navigator_records (
 id uuid primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 kind text not null check(kind in ('professor','application','event','task')),
 payload jsonb not null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(id,user_id),
 check(payload->>'id'=id::text),
 check(payload->>'kind'=kind)
);
create index navigator_owner_kind on public.navigator_records(user_id,kind);
alter table public.navigator_records enable row level security;
create policy owner_access on public.navigator_records for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
create function public.validate_navigator_record() returns trigger language plpgsql set search_path=public as $$
declare linked text;
begin
 if auth.uid() is null or auth.uid() <> new.user_id then raise exception 'Unauthorized'; end if;
 for linked in select jsonb_array_elements_text(coalesce(new.payload->'links','[]')) loop
 if not exists(select 1 from navigator_records where id=linked::uuid and user_id=new.user_id) then raise exception 'Invalid owned relationship'; end if;
 end loop;
 new.updated_at=now(); return new;
end $$;
create trigger validate_navigator before insert or update on public.navigator_records for each row execute function public.validate_navigator_record();
