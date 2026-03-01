-- Zikirmatik Supabase Database Schema
-- Execute these queries in Supabase SQL Editor

-- 1. users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  avatar_url TEXT,
  total_zikrs INTEGER DEFAULT 0,
  last_zikr_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. achievements table
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

-- 3. user_achievements table
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(50) REFERENCES achievements(id),
  unlocked_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- 4. leaderboard_daily table
CREATE TABLE IF NOT EXISTS leaderboard_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  daily_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- 5. leaderboard_weekly table
CREATE TABLE IF NOT EXISTS leaderboard_weekly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  weekly_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, week_start)
);

-- 6. leaderboard_monthly table
CREATE TABLE IF NOT EXISTS leaderboard_monthly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  month_start DATE NOT NULL,
  monthly_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, month_start)
);

-- Insert sample achievements (5 kupamız var)
INSERT INTO achievements (id, title, description, icon, requirement, points, category) VALUES
('bronze_kupa', 'Bronz Kupa', 'İlk 100 zikirini tamamla', '🥉', '100 zikir', 50, 'bronze'),
('silver_kupa', 'Gümüş Kupa', '500 zikir tamamla', '🥈', '500 zikir', 150, 'silver'),
('gold_kupa', 'Altın Kupa', '1000 zikir tamamla', '🥇', '1000 zikir', 300, 'gold'),
('diamond_kupa', 'Elmas Kupa', '5000 zikir tamamla', '💎', '5000 zikir', 500, 'diamond'),
('platinum_kupa', 'Platin Kupa', '10000 zikir tamamla', '🏆', '10000 zikir', 1000, 'platinum')
ON CONFLICT (id) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_daily_date ON leaderboard_daily(date);
CREATE INDEX IF NOT EXISTS idx_leaderboard_weekly_week_start ON leaderboard_weekly(week_start);
CREATE INDEX IF NOT EXISTS idx_leaderboard_monthly_month_start ON leaderboard_monthly(month_start);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_weekly ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_monthly ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid()::text = id::text);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid()::text = id::text);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid()::text = id::text);

CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own achievements" ON user_achievements FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view own leaderboard data" ON leaderboard_daily FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can update own leaderboard data" ON leaderboard_daily FOR UPDATE USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own leaderboard data" ON leaderboard_daily FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view own weekly leaderboard data" ON leaderboard_weekly FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can update own weekly leaderboard data" ON leaderboard_weekly FOR UPDATE USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own weekly leaderboard data" ON leaderboard_weekly FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view own monthly leaderboard data" ON leaderboard_monthly FOR SELECT USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can update own monthly leaderboard data" ON leaderboard_monthly FOR UPDATE USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can insert own monthly leaderboard data" ON leaderboard_monthly FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Public read policies for leaderboard views
CREATE POLICY "Public can read daily leaderboard" ON leaderboard_daily FOR SELECT USING (true);
CREATE POLICY "Public can read weekly leaderboard" ON leaderboard_weekly FOR SELECT USING (true);
CREATE POLICY "Public can read monthly leaderboard" ON leaderboard_monthly FOR SELECT USING (true);
CREATE POLICY "Public can read achievements" ON achievements FOR SELECT USING (true);
