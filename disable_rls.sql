-- RLS Politikalarını Geçici Olarak Devre Dışı Bırak
-- Bu script sadece test amaçlıdır!

-- Users tablosu için RLS'i devre dışı bırak
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- User_achievements tablosu için RLS'i devre dışı bırak  
ALTER TABLE user_achievements DISABLE ROW LEVEL SECURITY;

-- Leaderboard_daily tablosu için RLS'i devre dışı bırak
ALTER TABLE leaderboard_daily DISABLE ROW LEVEL SECURITY;

-- Leaderboard_weekly tablosu için RLS'i devre dışı bırak
ALTER TABLE leaderboard_weekly DISABLE ROW LEVEL SECURITY;

-- Leaderboard_monthly tablosu için RLS'i devre dışı bırak
ALTER TABLE leaderboard_monthly DISABLE ROW LEVEL SECURITY;

-- Achievements tablosu için RLS'i devre dışı bırak
ALTER TABLE achievements DISABLE ROW LEVEL SECURITY;

-- Alternatif: RLS'i açık tut ama anon kullanıcıya izin ver
-- CREATE POLICY "Allow anonymous users to read/write" ON users FOR ALL USING (true) WITH CHECK (true);

-- Test için anon kullanıcıya tüm izinler
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon;
