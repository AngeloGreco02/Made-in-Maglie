-- Esegui queste policy DOPO aver creato l'utente admin in
-- Supabase > Authentication > Users.
-- Sostituisci ADMIN_UUID con l'UUID dell'utente amministratore.

create policy "Admin can read tickets"
on public.tickets
for select
to authenticated
using (auth.uid() = 'ADMIN_UUID'::uuid);

create policy "Admin can update tickets"
on public.tickets
for update
to authenticated
using (auth.uid() = 'ADMIN_UUID'::uuid)
with check (auth.uid() = 'ADMIN_UUID'::uuid);

create policy "Admin can read ticket attachments"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'ticket-allegati'
  and auth.uid() = 'ADMIN_UUID'::uuid
);
