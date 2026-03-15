-- Leaderboard "Tüm Zamanlar" için RPC fonksiyonu (RLS bypass – tüm kullanıcılar listelenir)
-- Supabase SQL Editor'da bu dosyayı çalıştırın. Sonra uygulama get_leaderboard_all_time RPC'sini kullanır.

CREATE OR REPLACE FUNCTION get_leaderboard_all_time(lim int DEFAULT 50)
RETURNS TABLE (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  total_zikrs int
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT u.id, u.username, u.display_name, u.avatar_url, COALESCE(u.total_zikrs, 0)::int
  FROM users u
  ORDER BY u.total_zikrs DESC NULLS LAST
  LIMIT lim;
$$;

GRANT EXECUTE ON FUNCTION get_leaderboard_all_time(int) TO anon;
GRANT EXECUTE ON FUNCTION get_leaderboard_all_time(int) TO authenticated;
