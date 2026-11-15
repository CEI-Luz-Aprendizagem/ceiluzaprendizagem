-- Redefinir senha de professora ou responsável pelo painel da administração.
-- Cole no Supabase (SQL Editor) e clique em Run. Pode rodar mais de uma vez sem problema.
create or replace function admin_definir_senha(p_email text, p_senha text) returns void as $$
declare v_id uuid;
begin
  if not is_admin() then raise exception 'sem permissão'; end if;
  if p_senha is null or length(p_senha) < 8 then
    raise exception 'A senha precisa ter pelo menos 8 caracteres';
  end if;
  select u.id into v_id from auth.users u where lower(u.email) = lower(trim(p_email));
  if v_id is null then raise exception 'E-mail não encontrado'; end if;
  if exists (select 1 from admins where auth_user_id = v_id) then
    raise exception 'Não é possível redefinir a senha de uma administradora por aqui';
  end if;
  if not (exists (select 1 from vinculos_pais where auth_user_id = v_id)
       or exists (select 1 from vinculos_professoras where auth_user_id = v_id)
       or exists (select 1 from auth.users u2 where u2.id = v_id and u2.raw_user_meta_data ->> 'convite_tipo' is not null)) then
    raise exception 'Essa conta não é de professora nem de responsável';
  end if;
  update auth.users
     set encrypted_password = extensions.crypt(p_senha, extensions.gen_salt('bf')),
         updated_at = now()
   where id = v_id;
end;
$$ language plpgsql security definer set search_path = public;

revoke execute on function admin_definir_senha(text, text) from public, anon;
grant execute on function admin_definir_senha(text, text) to authenticated;
