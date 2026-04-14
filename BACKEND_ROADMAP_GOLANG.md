# Backend Roadmap Golang untuk Project Gangsta App

Dokumen ini adalah panduan implementasi backend dengan Golang agar pengembangan fitur lebih terarah, bertahap, dan mudah dieksekusi oleh tim.

## 1. Tujuan Backend

- Menyediakan API untuk 3 role: Customer, Merchant, Admin.
- Mendukung model SaaS multi-tenant (setiap merchant terisolasi data-nya).
- Siap scale untuk order real-time, POS, laporan, dan membership.
- Menjaga codebase mudah dirawat dengan clean architecture dan modular per fitur.

## 2. Rekomendasi Tech Stack

- Bahasa: Go 1.23+
- HTTP framework: Gin atau Fiber (pilih salah satu, jangan campur)
- Database utama: Supabase (PostgreSQL managed)
- Cache/queue: Redis
- ORM/query: sqlc + pgx (disarankan) atau GORM
- Auth: JWT access + refresh token
- Dokumentasi API: OpenAPI/Swagger
- Migrasi DB: Supabase CLI migration (disarankan) atau golang-migrate
- Logging: slog atau zerolog
- Observability: Prometheus + Grafana + OpenTelemetry
- Deployment: Railway + Dockerfile/Nixpacks + CI/CD (GitHub Actions)

## 3. Arsitektur yang Disarankan

Gunakan pendekatan clean architecture + modular monolith dulu (lebih cepat untuk MVP, tetap scalable), dengan bootstrap struktur `golang-standards/project-layout`.

### Struktur Folder MVP

```txt
backend/
  api/
  build/
  cmd/
    api/
      main.go
  configs/
  internal/
    bootstrap/
    common/
      config/
      middleware/
      response/
      errors/
      auth/
      tenant/
    modules/
      auth/
      customer_menu/
      customer_order/
      payment/
      merchant_menu/
      merchant_pos/
      merchant_table/
      merchant_report/
      admin_tenant/
      admin_subscription/
  pkg/
  migrations/
  docs/
  scripts/
  deployments/
  test/
```

### Struktur Tiap Module

```txt
internal/modules/<module_name>/
  delivery/http/
  usecase/
  domain/
  repository/
  dto/
```

## 4. Prinsip Wajib dari Awal

- Semua tabel bisnis wajib punya tenant_id (kecuali super-admin data).
- Semua query merchant/customer harus difilter tenant_id.
- Simpan SUPABASE_SERVICE_ROLE_KEY hanya di backend, jangan pernah expose ke frontend.
- Aktifkan dan uji Row Level Security (RLS) di tabel sensitif meski akses utama lewat backend.
- Gunakan idempotency key untuk create order/payment.
- Endpoint write wajib pakai transaksi DB untuk flow kritis.
- Pisahkan role authorization: customer, merchant, admin.
- Standard response dan error format harus konsisten.
- Audit log minimal untuk aksi sensitif (refund, delete menu, update subscription).

## 5. Domain Model Inti

Minimal entitas inti yang perlu ada di fase awal:

- tenants
- users
- roles
- merchant_profiles
- tables
- categories
- menus
- orders
- order_items
- payments
- transactions
- subscriptions
- subscription_plans
- audit_logs

## 6. Roadmap Implementasi Bertahap

## Fase 0 - Foundation (Minggu 1)

Target:

- Bootstrap project backend Go.
- Setup config env, logger, middleware, error handler.
- Setup project Supabase, Redis, migration, seed data.
- Setup project Railway (service, env var, health check, domain).
- Setup Swagger, health check, readiness check.
- Setup CI lint + test + build.

Deliverable:

- API dasar hidup di staging.
- Endpoint:
  - GET /health
  - GET /ready

Checklist:

- [ ] Struktur folder final diputuskan
- [ ] Integrasi Supabase project (URL, anon key, service role key)
- [ ] Docker compose (api + redis)
- [ ] Bootstrap folder sesuai golang-standards/project-layout
- [ ] Dockerfile backend siap untuk Railway
- [ ] Railway env var terpasang (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, REDIS_URL, APP_ENV, PORT)
- [ ] Migration awal berjalan otomatis
- [ ] Base middleware (request id, logging, panic recovery)

## Fase 1 - Auth + Multi Tenant Core (Minggu 2)

Target:

- Login/logout/refresh token.
- RBAC dasar untuk 3 role.
- Tenant context resolver dari JWT/header.

Deliverable endpoint:

- POST /auth/login
- POST /auth/refresh
- POST /auth/logout
- GET /auth/me

Checklist:

- [ ] JWT access/refresh jalan
- [ ] Middleware auth + role guard
- [ ] Tenant guard aktif di endpoint merchant/customer
- [ ] Unit test auth minimal 70% module coverage

## Fase 2 - Merchant Menu Management (Minggu 3)

Target:

- CRUD kategori dan menu.
- Status tersedia/tidak tersedia.
- Upload foto menu (boleh lokal dulu, lalu object storage).

Deliverable endpoint:

- GET /merchant/categories
- POST /merchant/categories
- PATCH /merchant/categories/:id
- DELETE /merchant/categories/:id
- GET /merchant/menus
- POST /merchant/menus
- PATCH /merchant/menus/:id
- DELETE /merchant/menus/:id

Checklist:

- [ ] Filter tenant_id konsisten
- [ ] Validasi payload kuat
- [ ] Pagination dan search untuk list menu
- [ ] Integration test CRUD menu

## Fase 3 - Customer Digital Menu + Cart + Order (Minggu 4-5)

Target:

- Customer lihat menu berdasarkan tenant.
- Cart dan submit order.
- Status order lifecycle.

Deliverable endpoint:

- GET /customer/menus
- POST /customer/carts/preview
- POST /customer/orders
- GET /customer/orders/:id
- GET /customer/orders/:id/status

Checklist:

- [ ] Idempotency untuk create order
- [ ] Perhitungan subtotal/tax/service charge konsisten
- [ ] Order state machine sederhana (pending, accepted, cooking, ready, done, canceled)
- [ ] Contract test dengan frontend payload

## Fase 4 - POS Merchant + Transaction (Minggu 6)

Target:

- Merchant bisa create order manual dari POS.
- Simpan transaksi kasir.

Deliverable endpoint:

- POST /merchant/pos/orders
- GET /merchant/pos/orders
- POST /merchant/transactions
- GET /merchant/transactions
- GET /merchant/transactions/:id

Checklist:

- [ ] Sinkron format order dari customer dan POS
- [ ] Nomor struk unik per tenant
- [ ] Audit log untuk void/cancel transaksi

## Fase 5 - Payment Integration Ready (Minggu 7)

Target:

- Payment intent internal.
- Callback webhook payment gateway.
- Rekonsiliasi status pembayaran.

Deliverable endpoint:

- POST /payments/intents
- POST /payments/webhook
- GET /payments/:id/status

Checklist:

- [ ] Signature verification webhook
- [ ] Idempotent webhook handler
- [ ] Retry mechanism untuk event gagal

## Fase 6 - Table Management + Order Board Real Time (Minggu 8)

Target:

- CRUD meja.
- Status meja dan monitor status order real-time.

Deliverable endpoint:

- GET /merchant/tables
- POST /merchant/tables
- PATCH /merchant/tables/:id
- DELETE /merchant/tables/:id
- GET /merchant/orders/board
- WS /merchant/orders/stream

Checklist:

- [ ] WebSocket channel per tenant
- [ ] Backpressure handling sederhana
- [ ] Fallback polling jika WS putus

## Fase 7 - Report + Admin Subscription (Minggu 9-10)

Target:

- Laporan harian/mingguan/bulanan.
- Admin kelola tenant dan paket subscription.

Deliverable endpoint:

- GET /merchant/reports/daily
- GET /merchant/reports/weekly
- GET /merchant/reports/monthly
- GET /admin/tenants
- POST /admin/tenants
- PATCH /admin/tenants/:id/subscription

Checklist:

- [ ] Query report teroptimasi (index + materialized strategy jika perlu)
- [ ] Endpoint admin diproteksi ketat
- [ ] Export CSV report

## 7. Prioritas Fitur (Agar Cepat Go Live)

Urutan prioritas paling aman:

1. Auth + Tenant + RBAC
2. Merchant Menu Management
3. Customer Order Flow
4. POS + Transaction
5. Payment
6. Report
7. Admin Subscription lanjutan

Jika waktu sempit, go-live v1 cukup sampai poin 4.

## 8. Definition of Done per Fitur

Setiap fitur dinyatakan selesai jika:

- [ ] API spec (OpenAPI) sudah update
- [ ] Unit test dan integration test minimal tersedia untuk happy path + error path utama
- [ ] Validasi input lengkap
- [ ] Logging + metrics dasar ada
- [ ] Endpoint aman dari akses lintas role/tenant
- [ ] Sudah dites dengan frontend role terkait

## 9. Strategi Testing

- Unit test: usecase dan domain rules.
- Integration test: repository + DB (testcontainer atau DB test khusus).
- API test: contract test dari contoh payload frontend.
- Load test ringan: endpoint order create, order status, report daily.

Target awal coverage backend: 60-70%, naik bertahap ke 80% di modul kritis (auth, order, payment).

## 10. Strategi Deployment

- Environment: dev, staging, production.
- Branching sederhana: main + develop + feature branches.
- Tiap merge ke develop deploy otomatis ke staging.
- Deployment utama di Railway (staging service + production service terpisah).
- Gunakan health check endpoint (`/health`) dan restart policy Railway.
- Production dengan rolling update + verifikasi smoke test endpoint kritikal.
- Wajib ada backup strategy dari Supabase + restore drill.

## 11. Risiko Teknis yang Harus Diantisipasi

- Kebocoran data antar tenant (risiko tertinggi).
- Salah konfigurasi RLS/policy di Supabase.
- Race condition pada update status order.
- Double payment akibat webhook retry.
- Query report lambat saat data transaksi membesar.
- Event real-time tidak sinkron dengan state DB.

Mitigasi:

- Tenant guard di middleware + query layer.
- Review policy RLS dengan test otomatis per role/tenant.
- DB transaction + row locking pada flow kritis.
- Idempotency key untuk payment/order.
- Index sejak awal pada kolom tenant_id, created_at, status.

## 12. Backlog Teknis Setelah MVP

- Rate limiting dan WAF.
- CQRS ringan untuk reporting berat.
- Event bus (NATS/Kafka) jika traffic naik.
- Outbox pattern untuk keandalan event.
- Multi-region dan disaster recovery plan.
- Horizontal scaling strategy di Railway saat traffic naik.

## 13. Rencana Eksekusi Mingguan Ringkas

- Minggu 1: Foundation
- Minggu 2: Auth + Tenant
- Minggu 3: Merchant Menu
- Minggu 4-5: Customer Order
- Minggu 6: POS + Transaction
- Minggu 7: Payment
- Minggu 8: Table + Real-time
- Minggu 9-10: Report + Admin

## 14. Next Action Praktis (Hari Ini)

1. Buat folder backend terpisah di root project.
2. Setup Supabase project lalu konfigurasi ENV backend (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, DATABASE_URL jika perlu direct postgres).
3. Bootstrap backend dengan `golang-standards/project-layout` (minimal `cmd`, `internal`, `pkg`, `configs`, `deployments`).
4. Setup service Railway untuk backend dan pasang env var + health check.
5. Implement Fase 0 sampai endpoint health/ready, lalu lanjut Fase 1 auth + tenant guard.

---

Jika diinginkan, dokumen ini bisa dilanjutkan menjadi versi eksekusi detail berisi:

- skema tabel SQL awal,
- contoh payload request/response tiap endpoint,
- template task board (To Do, In Progress, Done) per fase.
