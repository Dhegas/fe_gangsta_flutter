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

## 15. Spesifikasi Teknis Repositori (Wajib untuk Penilaian)

Karena project saat ini berupa frontend Flutter di root (`fe_gangsta_flutter`) dan backend Go akan ditambahkan bertahap, skema repositori yang disarankan adalah **monorepo**:

```txt
fe_gangsta_flutter/
  lib/
  ...
  backend/
    cmd/
    internal/
    migrations/
    docs/
    .env.example
    README.md
```

### 15.1 Git Flow dan Aktivitas Commit

- Wajib ada aktivitas commit bertahap (tidak sekali upload langsung jadi).
- Gunakan branch per fitur agar proses review jelas.
- Alur minimum yang direkomendasikan:
  - `main`: branch production-ready.
  - `develop`: branch integrasi harian.
  - `feature/<nama-fitur>`: branch pengembangan fitur.
  - `hotfix/<isu-kritis>`: perbaikan cepat production.
- Standarkan format commit (misal Conventional Commits) agar histori mudah ditelusuri dan otomatisasi release note lebih mudah.

Contoh commit sequence yang baik untuk 1 fitur auth:

1. `feat(auth): add login endpoint and dto`
2. `test(auth): add login usecase unit tests`
3. `docs(auth): update openapi login contract`
4. `refactor(auth): extract token service`

### 15.2 Standar .gitignore

`.gitignore` di root **wajib** melindungi file sensitif dan artefak build. Untuk konteks project ini, minimal mencakup:

- Flutter/Dart build artifacts (`build/`, `.dart_tool/`, `.flutter-plugins*`)
- Backend binary/log (`backend/bin/`, `*.exe`, `*.out`, `*.log`)
- Dependency folder yang tidak boleh di-commit (`node_modules/` jika ada tooling JS)
- File environment (`.env`, `.env.*`)
- File IDE/OS yang tidak relevan

### 15.3 Environment Variables dan .env.example

- Backend wajib menyediakan `backend/.env.example` sebagai panduan setup lokal.
- File `.env` asli tidak boleh di-commit.
- Minimal variabel yang harus ada pada `.env.example`:

```env
APP_ENV=development
PORT=8080
API_BASE_PATH=/api/v1

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
DATABASE_URL=

JWT_ACCESS_SECRET=
JWT_REFRESH_SECRET=
JWT_ACCESS_TTL_MINUTES=15
JWT_REFRESH_TTL_HOURS=168

REDIS_URL=
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:8080
```

Checklist implementasi repositori:

- [ ] Branch `develop` tersedia dan dipakai aktif
- [ ] PR berbasis branch fitur sudah jadi kebiasaan tim
- [ ] `.gitignore` root mencakup Flutter + backend Go + env
- [ ] `backend/.env.example` tersedia dan up to date
- [ ] Secret key tidak pernah masuk commit history

## 16. Standar Dokumentasi README (Pengganti Demo)

Karena tidak ada sesi demo langsung, README menjadi artefak utama evaluasi. Untuk menyesuaikan kondisi repo saat ini:

- `README.md` di root menjelaskan gambaran sistem Gangsta App secara umum (frontend + backend roadmap).
- `backend/README.md` fokus teknis backend Go dan menjadi acuan utama penguji API.

Minimal konten yang wajib ada (khusus backend):

1. **Project Overview**
   - Jelaskan sistem backend SaaS POS + self-order yang melayani role Customer, Merchant, Admin.
2. **Tech Stack**
   - Cantumkan bahasa/framework/library utama (Go, Gin/Fiber, pgx/sqlc atau GORM, JWT, Redis, Supabase).
3. **Database Diagram**
   - Sertakan gambar ERD di `backend/docs/erd.png` atau tautan desain (mis. dbdiagram/FigJam).
4. **Installation Guide**
   - Langkah run lokal dari nol: setup env, migration, jalankan API.
5. **API Documentation Link**
   - Jelaskan akses Swagger UI (contoh: `/swagger/index.html`) atau sertakan Postman collection di `backend/docs/`.

Template struktur `backend/README.md` yang disarankan:

```md
# Gangsta Backend API

## Project Overview
...

## Tech Stack
...

## Database Diagram
- ERD: docs/erd.png

## Installation Guide
1. cp .env.example .env
2. jalankan migration
3. go run ./cmd/api

## API Documentation
- Swagger: http://localhost:8080/swagger/index.html
- Postman: docs/gangsta-backend.postman_collection.json
```

Checklist dokumentasi:

- [ ] `README.md` root sinkron dengan status project terbaru
- [ ] `backend/README.md` berisi 5 komponen wajib
- [ ] ERD tersedia (gambar/link valid)
- [ ] Swagger/Postman dapat diakses sesuai instruksi README

## 17. Perencanaan Integrasi (Multiplatform Readiness)

Agar backend siap dikonsumsi aplikasi Flutter (project ini) dan klien web (Angular), kontrak integrasi harus eksplisit sejak awal.

### 17.1 CORS Configuration

- Untuk development, boleh `*` sementara.
- Untuk staging/production, gunakan allowlist origin dari env (`ALLOWED_ORIGINS`).
- Origin minimal dev yang umum:
  - `http://localhost:3000` (web dev server)
  - `http://localhost:5173` (Vite)
  - `http://localhost:8080` (emulator/proxy tertentu)

Contoh policy (konseptual):

- Allowed Methods: `GET, POST, PATCH, PUT, DELETE, OPTIONS`
- Allowed Headers: `Authorization, Content-Type, X-Idempotency-Key, X-Tenant-ID`
- Allow Credentials: `true` (jika pakai cookie/session)

### 17.2 Base URL Standar API

Gunakan prefix versi agar aman untuk evolusi API:

- Base path: `/api/v1`
- Contoh final endpoint:
  - `POST /api/v1/auth/login`
  - `GET /api/v1/merchant/menus`
  - `POST /api/v1/customer/orders`

Aturan environment URL:

- Local: `http://localhost:<PORT>/api/v1`
- Staging: `https://staging-api.<domain>/api/v1`
- Production: `https://api.<domain>/api/v1`

### 17.3 Schema Consistency (Kontrak Response)

Tentukan satu gaya key JSON dan konsisten di semua endpoint. Disarankan:

- Format key: `snake_case`
- Timestamp: ISO-8601 (`created_at`, `updated_at`)
- Error object konsisten
- Pagination object konsisten

Contoh success response:

```json
{
  "success": true,
  "message": "ok",
  "data": {
    "order_id": "ord_123",
    "order_status": "pending"
  },
  "meta": {
    "request_id": "req_abc"
  }
}
```

Contoh error response:

```json
{
  "success": false,
  "message": "validation error",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "table_id",
        "reason": "required"
      }
    ]
  },
  "meta": {
    "request_id": "req_abc"
  }
}
```

Checklist integration contract:

- [ ] CORS policy terdokumentasi dan sesuai environment
- [ ] Prefix `/api/v1` sudah diterapkan konsisten
- [ ] JSON schema style (`snake_case`) disepakati lintas tim
- [ ] Kontrak response didokumentasikan di Swagger/Postman
- [ ] Frontend Flutter sudah uji minimal 1 flow end-to-end (auth + fetch data)

## 18. Engineering Governance (Standar Industri)

Agar backend ini maintainable dalam jangka panjang, tetapkan governance sejak hari pertama.

### 18.1 Architecture Decision Record (ADR)

- Simpan keputusan arsitektur penting di `backend/docs/adr/`.
- Setiap keputusan penting (misal: pilih Gin vs Fiber, pilih sqlc vs GORM, strategi auth) wajib punya 1 file ADR.
- Format minimum ADR:
  - Context
  - Decision
  - Consequences
  - Alternatives considered

### 18.2 Coding Standards

- Gunakan lint dan static analysis sebagai gate wajib:
  - `gofmt` / `goimports`
  - `go vet`
  - `golangci-lint`
- Terapkan aturan sederhana:
  - Jangan ada business logic di handler HTTP.
  - Handler hanya parse request, call usecase, return response.
  - Error harus dibungkus dengan context yang cukup untuk debugging.

### 18.3 Dependency Management

- Gunakan `go.mod` dan pin versi dependency dengan disiplin.
- Update dependency rutin (misal 2 minggu sekali) dan cek CVE.
- Jangan menambahkan dependency baru tanpa alasan yang jelas (catat di PR/ADR).

Checklist governance:

- [ ] Folder ADR tersedia dan mulai dipakai
- [ ] `golangci-lint` aktif di local + CI
- [ ] Aturan layer architecture terdokumentasi
- [ ] Dependency update cadence disepakati tim

## 19. Non-Functional Requirements (NFR) dan SLO

Definisikan target kinerja agar tim punya tolok ukur objektif.

### 19.1 NFR Minimum MVP

- Availability API (staging/production): target 99.5%+
- p95 latency endpoint read: < 300 ms
- p95 latency endpoint write: < 500 ms
- Error rate 5xx: < 1% per 15 menit
- RTO (Recovery Time Objective): <= 60 menit
- RPO (Recovery Point Objective): <= 15 menit

### 19.2 SLI/SLO yang Diukur

- Request success ratio (`2xx + 4xx expected`) per endpoint group
- p50/p95/p99 latency per endpoint group
- DB query duration p95
- Queue retry/failure rate (untuk webhook/event)

Checklist NFR:

- [ ] SLO ditulis dan disepakati sebelum production
- [ ] Dashboard metrik SLI tersedia
- [ ] Alert threshold sesuai SLO

## 20. Security Baseline (Wajib Sebelum Go-Live)

### 20.1 Authentication dan Authorization

- JWT access token durasi pendek, refresh token rotasi.
- Simpan refresh token secara aman (hash di DB jika memungkinkan).
- Endpoint sensitif wajib RBAC + tenant guard.
- Terapkan principle of least privilege untuk semua role.

### 20.2 API Security Controls

- Rate limiting pada endpoint kritis (`/auth/login`, `/payments/webhook`, create order).
- Request size limit untuk mencegah abuse.
- Security header minimum (contoh: `X-Content-Type-Options`, `X-Frame-Options`).
- Validasi input ketat (length, enum, format, whitelist).

### 20.3 Secret dan Key Management

- Secret tidak boleh hardcoded.
- Gunakan environment variable/secret manager.
- Rotasi berkala untuk JWT secret dan service key.
- Batasi akses secret hanya untuk service backend.

### 20.4 Audit dan Compliance Dasar

- Audit log untuk aksi sensitif: refund, cancel/void, ubah role, ubah subscription.
- Simpan actor, tenant_id, resource, action, timestamp, before/after (jika relevan).

Checklist security:

- [ ] Rate limiting aktif untuk endpoint kritis
- [ ] Secret scanning aktif di CI
- [ ] Audit log event sensitif aktif
- [ ] Security test dasar (auth bypass, tenant bypass, injection) dijalankan

## 21. Data Management dan Database Standards

### 21.1 Data Modeling

- Semua tabel bisnis wajib punya `tenant_id`, `created_at`, `updated_at`.
- Gunakan soft delete selektif (`deleted_at`) untuk data yang perlu traceability.
- Definisikan foreign key dan constraint dari awal.

### 21.2 Indexing Strategy

- Index default pada:
  - `(tenant_id, created_at)`
  - `(tenant_id, status)`
  - kolom lookup utama (mis. `order_number`, `table_code`)
- Uji query plan endpoint report dari fase awal.

### 21.3 Migration Rules

- Migration harus idempotent dan reversible.
- Dilarang edit migration lama yang sudah dijalankan di environment bersama.
- Setiap migration besar wajib punya rollback plan.

### 21.4 Backup dan Restore

- Aktifkan backup otomatis database.
- Lakukan restore drill berkala (minimal per kuartal).

Checklist data:

- [ ] Standar kolom dasar diterapkan di semua tabel
- [ ] Index untuk query kritis tersedia
- [ ] SOP migration dan rollback terdokumentasi
- [ ] Backup/restore drill pernah diuji

## 22. CI/CD Quality Gates (Standar Industri)

Pipeline minimum di GitHub Actions untuk backend:

1. `lint`: `gofmt` check + `golangci-lint`
2. `test`: unit test + integration test dasar
3. `security`: dependency vulnerability scan + secret scan
4. `build`: build image Docker
5. `deploy-staging`: auto deploy dari `develop`
6. `deploy-production`: manual approval dari `main`

Kriteria merge minimum:

- Semua check CI hijau
- Minimal 1 reviewer approve
- Tidak ada secret terdeteksi
- Test coverage modul kritis tidak turun

Checklist CI/CD:

- [ ] Workflow CI backend aktif
- [ ] Workflow CD staging dan production terpisah
- [ ] Branch protection rule aktif di `main` dan `develop`
- [ ] Release tag/versioning dipakai konsisten

## 23. Observability dan Incident Management

### 23.1 Logging Standard

- Gunakan structured logging (JSON) dengan field minimal:
  - `timestamp`
  - `level`
  - `message`
  - `request_id`
  - `tenant_id`
  - `user_id` (jika ada)
  - `path` dan `status_code`

### 23.2 Metrics dan Tracing

- Metrics minimum:
  - request count
  - latency histogram
  - error count per endpoint
  - DB query duration
- Tracing minimum untuk flow kritis:
  - auth
  - create order
  - payment webhook

### 23.3 Alerting dan On-Call

- Alert kategori P1/P2/P3 didefinisikan.
- Alert P1 wajib punya respon awal < 15 menit.
- Siapkan runbook di `backend/docs/runbooks/` untuk incident umum.

Checklist observability:

- [ ] Structured logging aktif di semua endpoint
- [ ] Dashboard API/DB tersedia
- [ ] Alert rule untuk SLO breach aktif
- [ ] Minimal 3 runbook incident tersedia

## 24. API Contract Governance

Kontrak API harus stabil agar klien Flutter/Angular tidak sering break.

### 24.1 Versioning dan Compatibility

- Gunakan versioning path (`/api/v1`).
- Perubahan breaking change wajib:
  - buat versi baru (`/api/v2`) atau
  - beri periode deprecate yang jelas.

### 24.2 OpenAPI sebagai Source of Truth

- OpenAPI wajib update untuk setiap endpoint baru/perubahan schema.
- PR backend yang mengubah request/response tanpa update OpenAPI tidak boleh merge.

### 24.3 Consumer Contract Test

- Buat contract test minimal untuk flow:
  - login
  - list menu
  - create order
  - order status

Checklist API governance:

- [ ] OpenAPI selalu sinkron dengan implementasi
- [ ] Breaking change policy terdokumentasi
- [ ] Contract test dengan frontend berjalan di CI

## 25. Definition of Ready (DoR) dan DoD Industri

Sebelum mulai mengerjakan sebuah fitur (DoR), item berikut harus lengkap:

- [ ] User story dan acceptance criteria jelas
- [ ] API contract (request/response/error) disepakati
- [ ] Dampak tenant/security sudah ditinjau
- [ ] Rencana test (unit/integration/API) sudah ditulis
- [ ] Estimasi dan owner fitur sudah ditetapkan

Fitur dinyatakan selesai (DoD) jika:

- [ ] Kriteria pada Bagian 8 terpenuhi
- [ ] OpenAPI dan README ter-update
- [ ] Dashboard metrik endpoint baru tersedia
- [ ] Runbook/operasional impact tercatat
- [ ] Sudah diuji di staging dengan frontend terkait

## 26. Rencana Eksekusi 30-60-90 Hari (Industry Track)

### 0-30 Hari (Foundation + Guardrails)

- Selesaikan Fase 0 dan Fase 1.
- Aktifkan CI lint/test/build.
- Tetapkan standar response, error, logging, request_id, tenant guard.

### 31-60 Hari (Core Business Flow)

- Selesaikan Fase 2, Fase 3, Fase 4.
- Pastikan idempotency, transaksi DB, dan contract test berjalan.
- Mulai observability (dashboard + alert awal).

### 61-90 Hari (Production Hardening)

- Selesaikan Fase 5, Fase 6, Fase 7.
- Hardening security (rate limit, audit log lengkap, secret rotation).
- Uji backup/restore, incident drill, dan readiness go-live.

## 27. Exit Criteria Go-Live Backend

Backend dinyatakan siap go-live jika seluruh poin berikut terpenuhi:

- [ ] Semua endpoint prioritas v1 stabil di staging
- [ ] Tidak ada high/critical vulnerability terbuka
- [ ] SLO baseline tercapai dalam uji beban ringan
- [ ] Monitoring, alerting, dan runbook aktif
- [ ] Rollback plan deployment diuji
- [ ] Frontend Flutter lulus UAT untuk flow utama (auth, menu, order, transaksi)

---

Jika diinginkan, dokumen ini bisa dilanjutkan menjadi versi eksekusi detail berisi:

- skema tabel SQL awal,
- contoh payload request/response tiap endpoint,
- template task board (To Do, In Progress, Done) per fase.
