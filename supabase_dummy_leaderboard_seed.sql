-- Dummy leaderboard seed for test/QA.
-- WARNING: Review and optionally clean existing rows before running in production.
-- Suggested cleanup (optional):
-- DELETE FROM leaderboard_daily WHERE user_id IN (SELECT id FROM users WHERE username LIKE 'qa_user_%');
-- DELETE FROM leaderboard_weekly WHERE user_id IN (SELECT id FROM users WHERE username LIKE 'qa_user_%');
-- DELETE FROM leaderboard_monthly WHERE user_id IN (SELECT id FROM users WHERE username LIKE 'qa_user_%');
-- DELETE FROM user_achievements WHERE user_id IN (SELECT id FROM users WHERE username LIKE 'qa_user_%');
-- DELETE FROM users WHERE username LIKE 'qa_user_%';

CREATE TEMP TABLE IF NOT EXISTS tmp_seed_users (
  id uuid PRIMARY KEY,
  username text NOT NULL,
  display_name text,
  total_zikrs integer NOT NULL,
  daily_count integer NOT NULL,
  weekly_count integer NOT NULL,
  monthly_count integer NOT NULL,
  bronze_count integer NOT NULL,
  silver_count integer NOT NULL,
  gold_count integer NOT NULL,
  diamond_count integer NOT NULL,
  platinum_count integer NOT NULL
) ON COMMIT DROP;

TRUNCATE TABLE tmp_seed_users;

INSERT INTO tmp_seed_users (
  id, username, display_name, total_zikrs, daily_count, weekly_count, monthly_count,
  bronze_count, silver_count, gold_count, diamond_count, platinum_count
) VALUES
  ('00000000-0000-0000-0000-000000000101'::uuid, 'qa_user_1', 'QA One', 24000, 800, 5500, 24000, 8, 6, 5, 3, 2),
  ('00000000-0000-0000-0000-000000000102'::uuid, 'qa_user_2', 'QA Two', 18000, 600, 4000, 18000, 12, 8, 3, 1, 0),
  ('00000000-0000-0000-0000-000000000103'::uuid, 'qa_user_3', 'QA Three', 13000, 430, 2900, 13000, 15, 5, 2, 0, 0),
  ('00000000-0000-0000-0000-000000000104'::uuid, 'qa_user_4', 'QA Four', 9200, 310, 2100, 9200, 10, 3, 1, 0, 0),
  ('00000000-0000-0000-0000-000000000105'::uuid, 'qa_user_5', 'QA Five', 5600, 190, 1300, 5600, 6, 1, 0, 0, 0);

INSERT INTO users (
  id, username, display_name, total_zikrs, show_in_leaderboard, created_at, updated_at
)
SELECT
  id, username, display_name, total_zikrs, true, now(), now()
FROM tmp_seed_users
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  display_name = EXCLUDED.display_name,
  total_zikrs = EXCLUDED.total_zikrs,
  show_in_leaderboard = true,
  updated_at = now();

INSERT INTO user_achievements (user_id, achievement_id, unlocked_at)
SELECT su.id, ach.achievement_id, now()
FROM tmp_seed_users su
CROSS JOIN LATERAL (
  VALUES
    ('bronze_kupa', su.bronze_count > 0),
    ('silver_kupa', su.silver_count > 0),
    ('gold_kupa', su.gold_count > 0),
    ('diamond_kupa', su.diamond_count > 0),
    ('platinum_kupa', su.platinum_count > 0)
) AS ach(achievement_id, unlocked)
WHERE ach.unlocked
ON CONFLICT (user_id, achievement_id) DO UPDATE SET
  unlocked_at = EXCLUDED.unlocked_at;

INSERT INTO leaderboard_daily (user_id, date, daily_count, created_at, updated_at)
SELECT
  su.id,
  CURRENT_DATE,
  su.daily_count,
  now(),
  now()
FROM tmp_seed_users su
ON CONFLICT (user_id, date) DO UPDATE SET
  daily_count = EXCLUDED.daily_count,
  updated_at = now();

INSERT INTO leaderboard_weekly (user_id, week_start, weekly_count, created_at, updated_at)
SELECT
  su.id,
  date_trunc('week', CURRENT_DATE)::date,
  su.weekly_count,
  now(),
  now()
FROM tmp_seed_users su
ON CONFLICT (user_id, week_start) DO UPDATE SET
  weekly_count = EXCLUDED.weekly_count,
  updated_at = now();

INSERT INTO leaderboard_monthly (user_id, month_start, monthly_count, created_at, updated_at)
SELECT
  su.id,
  date_trunc('month', CURRENT_DATE)::date,
  su.monthly_count,
  now(),
  now()
FROM tmp_seed_users su
ON CONFLICT (user_id, month_start) DO UPDATE SET
  monthly_count = EXCLUDED.monthly_count,
  updated_at = now();
