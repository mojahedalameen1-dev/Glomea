import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { persistSession: false } }
    );

    const { email, password, full_name, username, role_id, is_super_admin, permission_ids } = await req.json();

    // 1. Create User in Auth
    const { data: authUser, error: authError } = await supabaseClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (authError) throw authError;

    // 2. Create in admin_users
    const { error: userError } = await supabaseClient
      .from('admin_users')
      .insert({
        id: authUser.user.id,
        username,
        full_name,
        role_id,
        is_super_admin: is_super_admin ?? false,
      });

    if (userError) throw userError;

    return new Response(JSON.stringify({ success: true, user: authUser.user }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
