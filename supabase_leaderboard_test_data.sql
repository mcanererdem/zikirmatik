-- Leaderboard test verisi – Supabase SQL Editor'da çalıştırın
-- 1) "Tüm Zamanlar" listesi: users tablosundaki herkes zaten görünür (Public can read users for leaderboard politikası ile).
-- 2) "Günlük" listesinde görünsünler diye bugünün tarihine leaderboard_daily kaydı ekleyin:

-- Bugünün tarihine tüm mevcut kullanıcılar için günlük sayı ekle (total_zikrs ile aynı veya test değeri)
INSERT INTO leaderboard_daily (user_id, date, daily_count, updated_at)
SELECT 
  id,
  CURRENT_DATE,
  COALESCE(total_zikrs, 0),
  NOW()
FROM users
ON CONFLICT (user_id, date) DO UPDATE SET
  daily_count = EXCLUDED.daily_count,
  updated_at = NOW();

-- Haftalık leaderboard için bu haftanın başlangıcına kayıt (opsiyonel)
INSERT INTO leaderboard_weekly (user_id, week_start, weekly_count, updated_at)
SELECT 
  id,
  date_trunc('week', CURRENT_DATE)::date,
  COALESCE(total_zikrs, 0),
  NOW()
FROM users
ON CONFLICT (user_id, week_start) DO UPDATE SET
  weekly_count = EXCLUDED.weekly_count,
  updated_at = NOW();

-- Aylık leaderboard için bu ayın 1'ine kayıt (opsiyonel)
INSERT INTO leaderboard_monthly (user_id, month_start, monthly_count, updated_at)
SELECT 
  id,
  date_trunc('month', CURRENT_DATE)::date,
  COALESCE(total_zikrs, 0),
  NOW()
FROM users
ON CONFLICT (user_id, month_start) DO UPDATE SET
  monthly_count = EXCLUDED.monthly_count,
  updated_at = NOW();
