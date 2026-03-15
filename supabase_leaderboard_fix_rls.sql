-- Leaderboard'da tüm kullanıcılar görünsün (şu an sadece 1 kişi görünüyorsa bu politikayı ekleyin)
-- Supabase SQL Editor'da bu dosyayı çalıştırın. Politikanın FOR SELECT olduğundan emin olun.

DROP POLICY IF EXISTS "Public can read users for leaderboard" ON public.users;

CREATE POLICY "Public can read users for leaderboard"
ON public.users
FOR SELECT
TO public
USING (true);
