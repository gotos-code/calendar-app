// Supabase project: calendar-app (separate from SO CRM)
const SUPABASE_URL = "https://mdfwkegatoqnxflaoxjn.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_myI7Mr5ev__B4Lc99PMwxw_jd0zLO1V";

// Named `sb`, not `supabase` — the UMD bundle itself declares a global
// `var supabase`, and a top-level `const supabase` here would collide with
// it ("Identifier 'supabase' has already been declared").
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Redirects to login if not signed in, or to a "pending approval" state if
// signed in but not yet approved. Returns the profile row when approved.
async function requireApprovedSession() {
  const { data: { session } } = await sb.auth.getSession();
  if (!session) {
    location.href = "login.html";
    return null;
  }
  const { data: profile, error } = await sb
    .from("profiles")
    .select("*")
    .eq("id", session.user.id)
    .single();

  if (error || !profile) {
    location.href = "login.html";
    return null;
  }
  if (!profile.approved) {
    location.href = "index.html";
    return null;
  }
  return profile;
}

async function logout() {
  await sb.auth.signOut();
  location.href = "login.html";
}
