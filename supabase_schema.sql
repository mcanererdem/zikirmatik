-- Zikirmatik Supabase – tek SQL şema dosyası
-- Supabase Dashboard > SQL Editor içinde bu dosyayı çalıştırın.
-- Tüm tablolar, RLS politikaları, RPC ve storage kuralları burada tanımlıdır.

DROP TABLE IF EXISTS user_achievements CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;

-- 1. users
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  avatar_url TEXT,
  total_zikrs INTEGER DEFAULT 0,
  last_zikr_date TIMESTAMP,
  show_in_leaderboard BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Idempotent şema güncellemesi (table zaten varsa)
ALTER TABLE users
ADD COLUMN IF NOT EXISTS show_in_leaderboard BOOLEAN NOT NULL DEFAULT false;

-- 2. achievements
CREATE TABLE IF NOT EXISTS achievements (
  id VARCHAR(50) PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(10) DEFAULT '🏆',
  requirement TEXT,
  points INTEGER DEFAULT 0,
  category VARCHAR(20) DEFAULT 'regular',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. user_achievements
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(50) REFERENCES achievements(id),
  unlocked_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- 4. leaderboard_daily
CREATE TABLE IF NOT EXISTS leaderboard_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  daily_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- 5. leaderboard_weekly
CREATE TABLE IF NOT EXISTS leaderboard_weekly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  weekly_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, week_start)
);

-- 6. leaderboard_monthly
CREATE TABLE IF NOT EXISTS leaderboard_monthly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  month_start DATE NOT NULL,
  monthly_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, month_start)
);

-- Varsayılan kupa kayıtları
INSERT INTO achievements (id, title, description, icon, requirement, points, category) VALUES
('bronze_kupa', 'Bronz Kupa', 'İlk 100 zikirini tamamla', '🥉', '100 zikir', 50, 'bronze'),
('silver_kupa', 'Gümüş Kupa', '500 zikir tamamla', '🥈', '500 zikir', 150, 'silver'),
('gold_kupa', 'Altın Kupa', '1000 zikir tamamla', '🥇', '1000 zikir', 300, 'gold'),
('diamond_kupa', 'Elmas Kupa', '5000 zikir tamamla', '💎', '5000 zikir', 500, 'diamond'),
('platinum_kupa', 'Platin Kupa', '10000 zikir tamamla', '🏆', '10000 zikir', 1000, 'platinum')
ON CONFLICT (id) DO NOTHING;

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_daily_date ON leaderboard_daily(date);
CREATE INDEX IF NOT EXISTS idx_leaderboard_weekly_week_start ON leaderboard_weekly(week_start);
CREATE INDEX IF NOT EXISTS idx_leaderboard_monthly_month_start ON leaderboard_monthly(month_start);

-- Veri bütünlüğü: sayılar negatif olamaz.
DO $$
BEGIN
  -- Existing usernames may violate the format constraint.
  -- Normalize first, then enforce constraints.
  WITH normalized AS (
    SELECT
      u.id,
      u.username,
      lower(regexp_replace(coalesce(u.username, ''), '[^a-zA-Z0-9_.]+', '', 'g')) AS cleaned
    FROM users u
  ),
  prepared AS (
    SELECT
      n.id,
      CASE
        WHEN n.cleaned = '' THEN 'user_' || substr(replace(n.id::text, '-', ''), 1, 8)
        WHEN char_length(n.cleaned) < 3 THEN n.cleaned || '_' || substr(replace(n.id::text, '-', ''), 1, 3)
        ELSE n.cleaned
      END AS base_name
    FROM normalized n
  ),
  ranked AS (
    SELECT
      p.id,
      left(p.base_name, 20) AS truncated_name,
      row_number() OVER (PARTITION BY left(p.base_name, 20) ORDER BY p.id) AS rn
    FROM prepared p
  ),
  final_names AS (
    SELECT
      r.id,
      CASE
        WHEN r.rn = 1 THEN r.truncated_name
        ELSE left(r.truncated_name, greatest(3, 20 - (char_length(r.rn::text) + 1))) || '_' || r.rn::text
      END AS final_name
    FROM ranked r
  )
  UPDATE users u
  SET username = f.final_name
  FROM final_names f
  WHERE u.id = f.id
    AND u.username IS DISTINCT FROM f.final_name;

  -- Normalize display_name values before applying length constraint.
  -- Empty/too-short names become NULL; too-long names are truncated.
  UPDATE users
  SET display_name = CASE
    WHEN display_name IS NULL THEN NULL
    WHEN char_length(trim(display_name)) < 2 THEN NULL
    WHEN char_length(trim(display_name)) > 30 THEN left(trim(display_name), 30)
    ELSE trim(display_name)
  END
  WHERE display_name IS NOT NULL;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_total_zikrs_non_negative'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_total_zikrs_non_negative CHECK (total_zikrs >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'leaderboard_daily_count_non_negative'
  ) THEN
    ALTER TABLE leaderboard_daily
      ADD CONSTRAINT leaderboard_daily_count_non_negative CHECK (daily_count >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'leaderboard_weekly_count_non_negative'
  ) THEN
    ALTER TABLE leaderboard_weekly
      ADD CONSTRAINT leaderboard_weekly_count_non_negative CHECK (weekly_count >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'leaderboard_monthly_count_non_negative'
  ) THEN
    ALTER TABLE leaderboard_monthly
      ADD CONSTRAINT leaderboard_monthly_count_non_negative CHECK (monthly_count >= 0);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_username_length_valid'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_username_length_valid
      CHECK (char_length(username) BETWEEN 3 AND 20);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_username_format_valid'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_username_format_valid
      CHECK (username ~ '^[A-Za-z0-9_.]+$');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_display_name_length_valid'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_display_name_length_valid
      CHECK (display_name IS NULL OR char_length(display_name) BETWEEN 2 AND 30);
  END IF;
END $$;

-- RLS açma
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_weekly ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_monthly ENABLE ROW LEVEL SECURITY;

-- RLS politikaları (DROP sonra CREATE – dosya tekrar çalıştırılabilir)
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Public can read users for leaderboard" ON users;
DROP POLICY IF EXISTS "Public can upsert users (device id)" ON users;
DROP POLICY IF EXISTS "Public can update users (device id)" ON users;

DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Users can insert own achievements" ON user_achievements;
DROP POLICY IF EXISTS "Public can upsert achievements (device id)" ON user_achievements;

DROP POLICY IF EXISTS "Users can view own leaderboard data" ON leaderboard_daily;
DROP POLICY IF EXISTS "Users can update own leaderboard data" ON leaderboard_daily;
DROP POLICY IF EXISTS "Users can insert own leaderboard data" ON leaderboard_daily;
DROP POLICY IF EXISTS "Public can read daily leaderboard" ON leaderboard_daily;
DROP POLICY IF EXISTS "Public can upsert daily leaderboard (device id)" ON leaderboard_daily;
DROP POLICY IF EXISTS "Public can update daily leaderboard (device id)" ON leaderboard_daily;

DROP POLICY IF EXISTS "Users can view own weekly leaderboard data" ON leaderboard_weekly;
DROP POLICY IF EXISTS "Users can update own weekly leaderboard data" ON leaderboard_weekly;
DROP POLICY IF EXISTS "Users can insert own weekly leaderboard data" ON leaderboard_weekly;
DROP POLICY IF EXISTS "Public can read weekly leaderboard" ON leaderboard_weekly;
DROP POLICY IF EXISTS "Public can upsert weekly leaderboard (device id)" ON leaderboard_weekly;
DROP POLICY IF EXISTS "Public can update weekly leaderboard (device id)" ON leaderboard_weekly;

DROP POLICY IF EXISTS "Users can view own monthly leaderboard data" ON leaderboard_monthly;
DROP POLICY IF EXISTS "Users can update own monthly leaderboard data" ON leaderboard_monthly;
DROP POLICY IF EXISTS "Users can insert own monthly leaderboard data" ON leaderboard_monthly;
DROP POLICY IF EXISTS "Public can read monthly leaderboard" ON leaderboard_monthly;
DROP POLICY IF EXISTS "Public can upsert monthly leaderboard (device id)" ON leaderboard_monthly;
DROP POLICY IF EXISTS "Public can update monthly leaderboard (device id)" ON leaderboard_monthly;

DROP POLICY IF EXISTS "Public can read achievements" ON achievements;

CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid()::text = id::text);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid()::text = id::text);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid()::text = id::text);
CREATE POLICY "Public can read users for leaderboard" ON users FOR SELECT USING (true);

-- Uygulama cihaz-id tabanlı anonim kullanıcı kullandığı için,
-- anon rolüne users tablosuna upsert izni veriyoruz.
CREATE POLICY "Public can upsert users (device id)" ON users
FOR INSERT TO anon
WITH CHECK (true);

CREATE POLICY "Public can update users (device id)" ON users
FOR UPDATE TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own achievements" ON user_achievements FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Cihaz-id tabanlı anonim kullanım için achievements upsert izni
CREATE POLICY "Public can upsert achievements (device id)" ON user_achievements
FOR INSERT TO anon
WITH CHECK (true);

CREATE POLICY "Users can view own leaderboard data" ON leaderboard_daily FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can update own leaderboard data" ON leaderboard_daily FOR UPDATE USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own leaderboard data" ON leaderboard_daily FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view own weekly leaderboard data" ON leaderboard_weekly FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can update own weekly leaderboard data" ON leaderboard_weekly FOR UPDATE USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own weekly leaderboard data" ON leaderboard_weekly FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view own monthly leaderboard data" ON leaderboard_monthly FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can update own monthly leaderboard data" ON leaderboard_monthly FOR UPDATE USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own monthly leaderboard data" ON leaderboard_monthly FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Public can read daily leaderboard" ON leaderboard_daily FOR SELECT USING (true);
CREATE POLICY "Public can read weekly leaderboard" ON leaderboard_weekly FOR SELECT USING (true);
CREATE POLICY "Public can read monthly leaderboard" ON leaderboard_monthly FOR SELECT USING (true);
CREATE POLICY "Public can read achievements" ON achievements FOR SELECT USING (true);

-- Cihaz-id tabanlı anonim kullanım için leaderboard upsert izinleri
CREATE POLICY "Public can upsert daily leaderboard (device id)" ON leaderboard_daily
FOR INSERT TO anon
WITH CHECK (true);

CREATE POLICY "Public can update daily leaderboard (device id)" ON leaderboard_daily
FOR UPDATE TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Public can upsert weekly leaderboard (device id)" ON leaderboard_weekly
FOR INSERT TO anon
WITH CHECK (true);

CREATE POLICY "Public can update weekly leaderboard (device id)" ON leaderboard_weekly
FOR UPDATE TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Public can upsert monthly leaderboard (device id)" ON leaderboard_monthly
FOR INSERT TO anon
WITH CHECK (true);

CREATE POLICY "Public can update monthly leaderboard (device id)" ON leaderboard_monthly
FOR UPDATE TO anon
USING (true)
WITH CHECK (true);

-- RPC: Tüm zamanlar leaderboard (RLS bypass)
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
  WHERE COALESCE(u.show_in_leaderboard, false) = true
  ORDER BY u.total_zikrs DESC NULLS LAST
  LIMIT lim;
$$;

GRANT EXECUTE ON FUNCTION get_leaderboard_all_time(int) TO anon;
GRANT EXECUTE ON FUNCTION get_leaderboard_all_time(int) TO authenticated;

-- RPC: Liderlik görünürlüğünü aç/kapat (RLS bypass)
-- show=false iken günlük/haftalık/aylık leaderboard kayıtlarını da temizler.
CREATE OR REPLACE FUNCTION set_leaderboard_visibility(p_user_id uuid, p_show boolean)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE users
  SET show_in_leaderboard = p_show
  WHERE id = p_user_id;

  IF NOT p_show THEN
    DELETE FROM leaderboard_daily WHERE user_id = p_user_id;
    DELETE FROM leaderboard_weekly WHERE user_id = p_user_id;
    DELETE FROM leaderboard_monthly WHERE user_id = p_user_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION set_leaderboard_visibility(uuid, boolean) TO anon;
GRANT EXECUTE ON FUNCTION set_leaderboard_visibility(uuid, boolean) TO authenticated;

-- RPC: Kupa leaderboard (RLS bypass)
DROP FUNCTION IF EXISTS get_leaderboard_by_cups(int);
CREATE OR REPLACE FUNCTION get_leaderboard_by_cups(lim int DEFAULT 50)
RETURNS TABLE (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  total_zikrs int,
  cup_count int,
  bronze_count int,
  silver_count int,
  gold_count int,
  diamond_count int,
  platinum_count int,
  top_cup text
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  WITH user_cups AS (
    SELECT
      u.id,
      u.username,
      u.display_name,
      u.avatar_url,
      COALESCE(u.total_zikrs, 0)::int AS total_zikrs,
      COUNT(ua.achievement_id)::int AS cup_count,
      COUNT(*) FILTER (WHERE ua.achievement_id = 'bronze_kupa')::int AS bronze_count,
      COUNT(*) FILTER (WHERE ua.achievement_id = 'silver_kupa')::int AS silver_count,
      COUNT(*) FILTER (WHERE ua.achievement_id = 'gold_kupa')::int AS gold_count,
      COUNT(*) FILTER (WHERE ua.achievement_id = 'diamond_kupa')::int AS diamond_count,
      COUNT(*) FILTER (WHERE ua.achievement_id = 'platinum_kupa')::int AS platinum_count,
      CASE
        WHEN COUNT(ua.achievement_id) = 0 THEN NULL
        ELSE (
          SELECT ua2.achievement_id
          FROM user_achievements ua2
          JOIN achievements a2 ON a2.id = ua2.achievement_id
          WHERE ua2.user_id = u.id
          ORDER BY a2.points DESC, ua2.unlocked_at DESC
          LIMIT 1
        )
      END AS top_cup
    FROM users u
    LEFT JOIN user_achievements ua ON ua.user_id = u.id
    LEFT JOIN achievements a ON a.id = ua.achievement_id
    WHERE COALESCE(u.show_in_leaderboard, false) = true
    GROUP BY u.id, u.username, u.display_name, u.avatar_url, u.total_zikrs
  )
  SELECT *
  FROM user_cups
  ORDER BY cup_count DESC NULLS LAST, total_zikrs DESC NULLS LAST
  LIMIT lim;
$$;

GRANT EXECUTE ON FUNCTION get_leaderboard_by_cups(int) TO anon;
GRANT EXECUTE ON FUNCTION get_leaderboard_by_cups(int) TO authenticated;

-- RPC: Hesabı silme (users tablosu + cascade ile ilişkili kayıtlar)
-- Not: RLS bypass için SECURITY DEFINER kullanıyoruz.
CREATE OR REPLACE FUNCTION delete_user_account(user_id uuid)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  DELETE FROM users WHERE id = user_id;
$$;

GRANT EXECUTE ON FUNCTION delete_user_account(uuid) TO anon;
GRANT EXECUTE ON FUNCTION delete_user_account(uuid) TO authenticated;

-- Storage: avatars (Dashboard > Storage’da "avatars" bucket oluşturun, limit 1 MB)
DROP POLICY IF EXISTS "Allow public uploads to avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow public update avatars" ON storage.objects;

CREATE POLICY "Allow public uploads to avatars"
ON storage.objects FOR INSERT TO public
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Allow public read avatars"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'avatars');

CREATE POLICY "Allow public update avatars"
ON storage.objects FOR UPDATE TO public
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');
