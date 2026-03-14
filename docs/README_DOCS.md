# Proje Dokümanları (.md) Rehberi

Proje kökündeki kalan `.md` dosyaları:

| Dosya | Amaç |
|-------|------|
| **README.md** | Proje tanıtımı, kurulum, özellikler |
| **PRIVACY_POLICY.md** | Gizlilik politikası (uygulama/store) |
| **TODO.md** | Yapılacaklar listesi (Kanban) |
| **PROJECT_RULES.md** | Geliştirme kuralları (dil, ekran, tema) |
| **RELEASE_NOTES.md** | Sürüm notları |
| **STORE_LISTING.md** | Mağaza listeleme metinleri |

**Supabase:** Uygulama sadece **project URL** ve **anon (publishable) key** kullanır. Bu değerler artık kodda yok; derleme sırasında `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` ile verilir. Örnek için `.env.example` dosyasına bakın. Veritabanı şifresi (direct Postgres) uygulamada kullanılmaz; sadece migrasyon/yönetim için şifre yöneticisinde saklayın.

**GitHub public repo:** Gizli bilgiler `.gitignore`'da (`.env`, `key.properties`, `google-services.json` vb.). Gerçek anahtar/şifre repoya eklenmez.
