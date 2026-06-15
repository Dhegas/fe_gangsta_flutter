# 🔥 Gangsta App

> **SaaS POS & Self-Order Platform untuk UMKM Kuliner Indonesia**

Gangsta App membantu merchant F&B menjalankan operasional harian lebih cepat: terima order, proses pembayaran, kelola menu, pantau meja, dan lihat laporan — dari satu platform lintas perangkat.

---

## 📋 Daftar Isi

- [Mengapa Gangsta App?](#-mengapa-gangsta-app)
- [Arsitektur Sistem](#-arsitektur-sistem)
- [Tech Stack](#-tech-stack)
- [Produk & Fitur](#-produk--fitur)
- [Status Integrasi Frontend ↔ Backend](#-status-integrasi-frontend--backend)
- [Struktur Proyek](#-struktur-proyek)
- [API Endpoints](#-api-endpoints)
- [Setup & Menjalankan Proyek](#-setup--menjalankan-proyek)
- [Deployment](#-deployment)
- [Dokumentasi Tambahan](#-dokumentasi-tambahan)
- [Business Model & Roadmap](#-business-model--roadmap)
- [Tim & Kontribusi](#-tim--kontribusi)

---

## 💡 Mengapa Gangsta App?

UMKM kuliner di Indonesia masih menghadapi masalah operasional yang berulang:

| Masalah | Solusi Gangsta App |
|---|---|
| ❌ Pencatatan order manual yang rawan salah | ✅ POS digital & self-ordering via QR |
| ❌ Proses checkout lambat saat jam ramai | ✅ Alur checkout ringkas dengan payment gateway |
| ❌ Laporan penjualan tidak real-time | ✅ Dashboard laporan harian & revenue analytics |
| ❌ Sulit memisahkan alur kerja customer, kasir, dan owner | ✅ Role-based architecture (Customer, Partner, Admin) |
| ❌ Tidak ada notifikasi pesanan real-time | ✅ WebSocket push notification untuk kitchen display |

---

## 🏗 Arsitektur Sistem

### Overview

```mermaid
graph LR
    subgraph "Client Layer"
        CustApp["📱 Customer App"]
        MerchApp["💼 Merchant App"]
        AdminApp["👑 Admin App"]
    end

    subgraph "Frontend - Flutter Web"
        FE["Flutter Web<br/>Feature-Based Architecture<br/>+ Design System"]
    end

    subgraph "Backend - Go + Gin"
        API["REST API<br/>Clean Architecture<br/>Modular Monolith"]
        WS["WebSocket Hub<br/>Real-time Events"]
    end

    subgraph "Infrastructure"
        DB["PostgreSQL<br/>Supabase"]
        Cache["In-Memory Cache<br/>go-cache"]
        Midtrans["Midtrans<br/>Payment Gateway"]
    end

    CustApp --> FE
    MerchApp --> FE
    AdminApp --> FE
    FE -->|HTTPS| API
    FE -->|WSS| WS
    API --> DB
    API --> Cache
    API --> Midtrans
    Midtrans -->|Webhook| API
```

### Multi-Tenant Architecture

Sistem dirancang sebagai **multi-tenant SaaS**. Setiap merchant (Partner) bisa memiliki banyak tenant (cabang), dan setiap tenant memiliki data yang terisolasi.

| Terminologi | Definisi |
|---|---|
| **Partner** | Pelaku usaha / penjual yang mendaftar ke platform. Bisa memiliki banyak tenant. |
| **Tenant** | Unit bisnis / toko fisik cabang yang beroperasi. Data menu, order, meja terikat pada entitas ini. |
| **Customer** | Pengguna akhir (pembeli) yang menggunakan layanan self-ordering. |
| **Admin** | Super user pengelola platform SaaS. |

### Backend Clean Architecture (Per Domain)

```mermaid
graph TD
    Handler["🔷 Delivery Layer<br/>HTTP Handler / Gin"]
    UC["🔶 Usecase Layer<br/>Business Logic"]
    Domain["🟢 Domain Layer<br/>Models & Interfaces"]
    Repo["🟣 Repository Layer<br/>DB Queries / GORM"]

    Handler --> UC
    UC --> Domain
    UC --> Repo
    Repo --> DB[(PostgreSQL)]
    Repo --> Cache[(Cache)]
```

| Layer | Tanggung Jawab |
|---|---|
| **Delivery** | Menangani binding request JSON, validasi input (`validator/v10`), parsing JWT context |
| **Usecase** | Jantung bisnis. Menjalankan logika bisnis dan orkestrasi repository |
| **Domain** | Definisi entitas bisnis (struct) dan kontrak interface |
| **Repository** | Abstraksi data akses. Menggunakan GORM |

---

## 🛠 Tech Stack

### Frontend

| Teknologi | Kegunaan |
|---|---|
| **Flutter 3.x** (Dart SDK ^3.11) | Framework utama — single codebase untuk web, mobile, desktop |
| **Design System** (custom) | Tokenized UI: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius` |
| **http** | HTTP client untuk REST API calls |
| **web_socket_channel** | WebSocket client untuk real-time notifications |
| **shared_preferences** | Penyimpanan lokal untuk session & theme persistence |
| **mobile_scanner** | QR code scanning untuk customer self-order |
| **qr_flutter** + **qr** | QR code generation untuk meja |
| **cached_network_image** | Cache gambar menu |
| **intl** | Formatting tanggal & currency (IDR) |
| **supabase_flutter** | Integrasi Supabase client |

### Backend

| Teknologi | Kegunaan |
|---|---|
| **Go 1.25** | Bahasa utama backend |
| **Gin** | HTTP web framework |
| **GORM** + **pgx** | ORM untuk PostgreSQL |
| **PostgreSQL** (Supabase) | Database utama |
| **go-cache** | In-memory caching (local) |
| **golang-jwt/jwt** v5 | JWT authentication (access + refresh token) |
| **gorilla/websocket** | WebSocket server untuk real-time events |
| **Midtrans** | Payment gateway (Snap API + webhook) |
| **go-redis** v9 | Redis client (opsional, untuk production) |
| **Swaggo** | Auto-generated Swagger/OpenAPI documentation |
| **godotenv** | Environment variable management |
| **bcrypt** (golang.org/x/crypto) | Password hashing |

### Infrastruktur & Deployment

| Teknologi | Kegunaan |
|---|---|
| **Railway** | Backend deployment (with healthcheck) |
| **Vercel** | Frontend web deployment (Flutter web build) |
| **Docker + Nginx** | Container-based local/staging environment |
| **Supabase** | Managed PostgreSQL + (optional) Auth/Storage |

---

## 📦 Produk & Fitur

### 📱 Customer App
- Scan QR Code untuk self-ordering per meja
- Lihat daftar tenant (store discovery) — publik tanpa login
- Lihat menu restoran berdasarkan tenant/slug
- Buat pesanan (self-order via tenant slug) dan pilih metode pembayaran
- Tracking status pesanan real-time via WebSocket
- Lihat riwayat pesanan (order history)
- Pembayaran online via Midtrans Snap
- Checkout preview dengan guest info (nama customer)

### 💼 Merchant App (Partner)
- **Tenant Selection** — Pilih cabang/tenant setelah login
- **Tenant Management** — Buat & kelola multi-cabang (CRUD tenant)
- **POS (Point of Sale)** — Order cepat dari kasir, pilih meja/takeaway, pilih menu, checkout (API-integrated dengan fallback local)
- **Menu Management** — CRUD menu, CRUD kategori, toggle ketersediaan, reorder kategori (API-integrated dengan fallback local)
- **Table Management** — CRUD meja, lihat status meja (API-integrated dengan fallback local)
- **Order Management** — Lihat semua order, update status pesanan (API-integrated)
- **Kitchen Display** — Real-time notification pesanan baru via WebSocket
- **Laporan Penjualan** — Revenue report, top menu, orders per meja, daily summary (API-integrated dengan fallback local)
- **Settings** — Halaman konfigurasi toko (UI tersedia)

### 👑 Admin App
- **Dashboard** — Monitoring overview platform (data lokal/dummy)
- **Tenant Management** — Lihat semua tenant lintas partner (API-integrated)
- **User Management** — Lihat, buat, edit, toggle active, hapus user (API-integrated)
- **Billing** — Overview billing per tenant (data lokal/dummy — belum terhubung backend)
- **Membership** — Daftar paket membership (data lokal/dummy — belum terhubung backend)
- **Global Config** — Konfigurasi platform: fee, tax, maintenance mode, dsb. (data lokal/dummy — belum terhubung backend)

### 🔐 Roles & Access Control

| Role | Middleware Guard | Akses Utama |
|---|---|---|
| 👑 **Admin** | `RoleGuard("ADMIN")` | Semua fitur platform |
| 💼 **Partner** | `RoleGuard("PARTNER")` + `TenantGuard` | Tenant sendiri: menu, order, meja, report, wallet |
| 📱 **Customer** | `RoleGuard("CUSTOMER")` + `TenantResolver` | Self-order, payment, order history |
| 🌐 **Public** | Tanpa auth | Lihat daftar tenant, menu, kategori, meja |

---

## 🔗 Status Integrasi Frontend ↔ Backend

Berikut status koneksi setiap fitur frontend ke backend API saat ini:

| Fitur | Status | Keterangan |
|---|---|---|
| **Auth** (login, register, refresh, logout, me) | ✅ API | Fully connected via remote datasource |
| **Customer — Store Discovery** | ✅ API | Fetch tenant list dari `/api/v1/public/tenants` |
| **Customer — Menu Digital** | ✅ API | Fetch menu via public endpoint, fallback ke local |
| **Customer — Self-Order** | ✅ API | Create order via `/api/v1/customer/orders/tenant/:slug` |
| **Customer — Order History** | ✅ API | Fetch dari `/api/v1/customer/orders/history` |
| **Customer — Order Status Tracking** | ✅ API + WS | API + WebSocket real-time |
| **Customer — Payment (Midtrans)** | ✅ API | Snap initiation via `/api/v1/customer/payments/initiate` |
| **Merchant — Tenant Selection** | ✅ API | Fetch partner tenants dari `/api/v1/partner/tenants` |
| **Merchant — Tenant Management** | ✅ API | CRUD via partner tenant endpoints |
| **Merchant — Menu Management** | ✅ API + fallback | API-first, fallback ke dummy data jika API error |
| **Merchant — Category Management** | ✅ API | Full CRUD + toggle + reorder |
| **Merchant — POS** | ✅ API + fallback | Fetch menu/kategori/meja via API, checkout via API, fallback ke dummy |
| **Merchant — Order Management** | ✅ API | Fetch & update status order via API |
| **Merchant — Table Management** | ✅ API + fallback | CRUD meja via API, fallback ke local |
| **Merchant — Report** | ✅ API + fallback | Fetch laporan via API, fallback ke local |
| **Merchant — Kitchen Display (WS)** | ✅ WebSocket | Real-time order notification per tenant |
| **Merchant — Settings** | 🎨 UI only | Halaman settings tersedia, belum terhubung ke backend |
| **Admin — Dashboard** | 🎨 Local data | Menggunakan dummy store data |
| **Admin — Tenant Management** | ✅ API | Fetch & manage semua tenant via admin endpoint |
| **Admin — User Management** | ✅ API | Full CRUD user via admin endpoint |
| **Admin — Billing** | 🎨 Local data | UI lengkap, menggunakan `BillingLocalDataSource` (dummy) |
| **Admin — Membership** | 🎨 Local data | UI lengkap, menggunakan `MembershipLocalDataSource` (dummy) |
| **Admin — Global Config** | 🎨 Local data | UI lengkap, menggunakan `GlobalConfigLocalDataSource` (dummy) |

> **Catatan:** Fitur bertanda "API + fallback" akan mencoba API terlebih dahulu, jika gagal maka menggunakan data lokal dummy agar UI tetap bisa didemonstrasikan.

---

## 📂 Struktur Proyek

### Frontend (`fe_gangsta_flutter`)

```
lib/
├── main.dart                    # Entry point utama + AuthGate + ThemeState
├── main_customer.dart           # Entry point Customer-only (opsional)
├── main_merchant.dart           # Entry point Merchant-only (opsional)
├── main_admin.dart              # Entry point Admin-only (opsional)
│
├── app/
│   └── app.dart                 # MaterialApp configuration
│
├── core/                        # Core layer (shared utilities)
│   ├── config/                  # App-wide configuration
│   ├── network/
│   │   ├── api_config.dart      # Base URL, token management, URI builder
│   │   └── api_client.dart      # Low-level HTTP client wrapper
│   ├── services/
│   │   ├── api_client.dart      # High-level API service (activeToken, tenantId)
│   │   ├── storage_service.dart # SharedPreferences wrapper (auth persistence)
│   │   └── websocket_service.dart # WebSocket client (auto-reconnect, event routing)
│   └── utils/
│       └── theme_storage.dart   # Theme mode persistence
│
├── design_system/               # Shared design system
│   ├── tokens/
│   │   ├── app_colors.dart      # Color palette (primary: #FF6B35, secondary: #2ECC71)
│   │   ├── app_typography.dart  # Font styles & sizes
│   │   ├── app_spacing.dart     # Spacing scale
│   │   └── app_radius.dart      # Border radius scale
│   └── theme/
│       └── app_theme.dart       # Light & Dark theme configuration
│
├── features/                    # Feature modules (per role)
│   ├── auth/                    # Authentication (login, register, refresh)
│   │   ├── data/                # Remote datasource (API-connected)
│   │   ├── domain/              # Entities (UserRole enum) & interfaces
│   │   └── presentation/       # AuthPage, PartnerRegisterPage
│   │
│   ├── customer/                # Customer-facing features
│   │   ├── dashboard/           # Home, store discovery, scan QR, profile
│   │   ├── menu/                # Menu digital (remote + local datasource)
│   │   └── order/               # Self-order, cart, checkout, order history (remote datasource)
│   │
│   ├── merchant/                # Partner/Merchant features
│   │   ├── tenant_selection_page.dart   # Pilih cabang setelah login
│   │   ├── merchant_landing_page.dart   # Dashboard setelah pilih tenant
│   │   ├── tenant_management/   # CRUD tenant (remote datasource)
│   │   ├── menu_management/     # CRUD menu + kategori (API + local fallback)
│   │   ├── table_management/    # CRUD meja (API + local fallback)
│   │   ├── order_management/    # Order list + status update (remote datasource)
│   │   ├── pos/                 # Point of Sale (API + local fallback)
│   │   ├── report/              # Revenue, top menu, daily summary (API + local fallback)
│   │   ├── settings/            # Merchant settings page (UI only)
│   │   ├── tables/              # Table status view
│   │   └── shared/              # Bottom nav, navigation helpers
│   │
│   └── admin/                   # Admin features
│       ├── admin_landing_page.dart
│       ├── dashboard/           # Platform overview (local datasource)
│       ├── tenant_management/   # All-tenant management (remote datasource)
│       ├── user_management/     # User CRUD (remote datasource)
│       ├── billing/             # Billing overview (local datasource)
│       ├── membership/          # Membership plans (local datasource)
│       └── global_config/       # Platform settings (local datasource)
```

> **Pola fitur:** Setiap modul fitur menggunakan arsitektur `data/` → `domain/` → `presentation/` (Clean Architecture).

### Backend (`saas_gangsta`)

```
saas_gangsta/
├── cmd/api/main.go              # Entry point aplikasi
├── main.go                      # Alternative entry
│
├── internal/
│   ├── bootstrap/               # Application bootstrap & route registration
│   │   ├── app.go               # Gin engine setup + middleware init
│   │   ├── routes.go            # Master routes + WebSocket + health/readiness
│   │   ├── public_routes.go     # Public endpoints (tanpa auth)
│   │   ├── customer_routes.go   # Customer-scoped routes
│   │   ├── partner_routes.go    # Partner-scoped routes (+ TenantGuard)
│   │   └── admin_routes.go      # Admin-scoped routes
│   │
│   ├── config/
│   │   └── config.go            # Environment config loader (godotenv)
│   │
│   ├── middleware/
│   │   ├── auth.go              # JWT authentication
│   │   ├── cors.go              # CORS configuration
│   │   ├── logger.go            # Request logging
│   │   ├── recovery.go          # Panic recovery
│   │   ├── role_guard.go        # Role-based access control
│   │   ├── tenant_guard.go      # Tenant ownership verification (Partner)
│   │   └── tenant_resolver.go   # Tenant slug → ID resolver (Customer/Public)
│   │
│   ├── common/
│   │   ├── cache/               # In-memory cache (go-cache wrapper)
│   │   ├── errors/              # Standardized error responses
│   │   └── response/            # Standardized success responses (envelope)
│   │
│   ├── infrastructure/
│   │   ├── database/            # GORM + PostgreSQL connection & readiness check
│   │   └── websocket/           # WebSocket hub (register/unregister/broadcast)
│   │
│   └── domains/                 # Business domains (modular monolith)
│       ├── category/            # Kategori menu (CRUD + toggle + reorder)
│       ├── menu/                # Menu items (CRUD + toggle available)
│       ├── order/               # Pesanan + order items + status update
│       ├── payment/             # Midtrans Snap + webhook + admin sync
│       ├── report/              # Revenue, top menu, daily summary, orders by table
│       ├── subscription/        # Subscription plans CRUD (domain ada, belum di-register di routes)
│       ├── table/               # Dining tables (CRUD + status)
│       ├── tenant/              # Tenant CRUD (Partner + Admin + Public views)
│       ├── user/
│       │   ├── auth/            # Register, Login, Refresh, Logout, Me
│       │   └── management/      # User CRUD, toggle active
│       └── wallet/              # Partner wallet, transactions, withdrawals, admin management
│
│   # Setiap domain mengikuti struktur:
│   # ├── delivery/http/         # Gin handlers
│   # ├── usecase/               # Business logic
│   # ├── domain/                # Models & interfaces
│   # ├── repository/            # GORM queries
│   # └── dto/                   # Request/Response DTOs
│
├── supabase/migrations/         # 25 SQL migration files (timestamped)
├── scripts/seed.sql             # Development seed data
├── docs/                        # Swagger JSON + generated docs
├── deployments/
│   ├── docker-compose.yml       # Nginx + API + Redis + PostgreSQL
│   ├── Dockerfile               # Production API build
│   └── nginx/                   # Nginx reverse proxy config
├── Dockerfile                   # Root Dockerfile (multi-stage Go build)
├── railway.toml                 # Railway deployment config
├── .env.example                 # Environment variable template
└── go.mod                       # Go module dependencies
```

---

## 🔌 API Endpoints

Semua endpoint di bawah prefix `/api/v1`. Autentikasi menggunakan JWT Bearer Token pada header `Authorization`.

### 🔓 Auth (`/api/v1/auth`)

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `POST` | `/auth/register` | ❌ | Registrasi user baru (customer/partner) |
| `POST` | `/auth/login` | ❌ | Login, dapatkan access + refresh token |
| `POST` | `/auth/refresh` | ❌ | Refresh access token |
| `POST` | `/auth/logout` | ✅ JWT | Logout (invalidate token) |
| `GET` | `/auth/me` | ✅ JWT | Informasi user yang sedang login |

### 👥 Users (`/api/v1/users`) — `RoleGuard("PARTNER", "ADMIN")` + `TenantGuard`

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/users` | List users |
| `GET` | `/users/:id` | Detail user |
| `PUT` | `/users/:id` | Update user |
| `DELETE` | `/users/:id` | Soft-delete user |
| `PATCH` | `/users/:id/toggle-active` | Toggle active status |

### 🌐 Public (`/api/v1/public`) — Tanpa Auth

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/public/tenants` | Daftar tenant yang publik |
| `GET` | `/public/tenants/:slug` | Detail tenant berdasarkan slug |
| `GET` | `/public/tenant/:tenantSlug/categories` | Kategori menu tenant |
| `GET` | `/public/tenant/:tenantSlug/menus` | Menu tenant (untuk customer browsing) |
| `GET` | `/public/tenant/:tenantSlug/tables` | Daftar meja tenant |
| `GET` | `/public/tenant/:tenantSlug/dining-tables` | Alias daftar meja tenant |

### 📱 Customer (`/api/v1/customer`) — `RoleGuard("CUSTOMER")`

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/customer/me` | Validasi context customer |
| `POST` | `/customer/orders/tenant/:tenantSlug` | Buat order baru (via tenant slug + TenantResolver) |
| `GET` | `/customer/orders/history` | Riwayat order customer |
| `GET` | `/customer/tenant/:tenantSlug/orders` | Lihat order di tenant tertentu |
| `GET` | `/customer/tenant/:tenantSlug/orders/:orderId` | Status detail order |
| `POST` | `/customer/payments/initiate` | Inisiasi pembayaran Midtrans Snap |

### 💼 Partner (`/api/v1/partner`) — `RoleGuard("PARTNER")`

#### Tenant Management (tanpa TenantGuard)

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/partner/tenants` | Buat tenant / cabang baru |
| `GET` | `/partner/tenants` | List semua tenant milik partner |
| `GET` | `/partner/tenants/:id` | Detail tenant |
| `PUT` | `/partner/tenants/:id` | Update tenant |
| `DELETE` | `/partner/tenants/:id` | Soft-delete tenant |

#### Operasional (dengan TenantGuard — via header `X-Tenant-ID`)

| Method | Endpoint | Deskripsi |
|---|---|---|
| | **Order Management** | |
| `GET` | `/partner/orders` | List semua order tenant |
| `GET` | `/partner/orders/:id` | Detail order |
| `POST` | `/partner/orders` | Buat order (POS mode) |
| `PATCH` | `/partner/orders/:id/status` | Update status order |
| `DELETE` | `/partner/orders/:id` | Soft-delete order |
| | **Menu Management** | |
| `GET` | `/partner/menus` | List semua menu |
| `GET` | `/partner/menus/:id` | Detail menu |
| `POST` | `/partner/menus` | Tambah menu baru |
| `PUT` | `/partner/menus/:id` | Update menu |
| `DELETE` | `/partner/menus/:id` | Soft-delete menu |
| `PATCH` | `/partner/menus/:id/toggle-available` | Toggle ketersediaan menu |
| | **Category Management** | |
| `POST` | `/partner/categories` | Buat kategori |
| `GET` | `/partner/categories` | List kategori |
| `GET` | `/partner/categories/:id` | Detail kategori |
| `PUT` | `/partner/categories/:id` | Update kategori |
| `DELETE` | `/partner/categories/:id` | Soft-delete kategori |
| `PATCH` | `/partner/categories/:id/toggle-active` | Toggle aktif kategori |
| `PATCH` | `/partner/categories/reorder` | Ubah urutan kategori |
| | **Table Management** | |
| `POST` | `/partner/dining-tables` | Buat meja baru |
| `GET` | `/partner/dining-tables` | List semua meja |
| `GET` | `/partner/dining-tables/:id` | Detail meja |
| `GET` | `/partner/dining-tables/:id/status` | Status meja (occupied/available) |
| `PUT` | `/partner/dining-tables/:id` | Update meja |
| `DELETE` | `/partner/dining-tables/:id` | Soft-delete meja |
| | **Report** | |
| `GET` | `/partner/reports/revenue` | Laporan pendapatan |
| `GET` | `/partner/reports/top-menus` | Menu paling laris |
| `GET` | `/partner/reports/orders-by-table` | Order berdasarkan meja |
| `GET` | `/partner/reports/daily-summary` | Ringkasan harian |

#### Wallet (tanpa TenantGuard — scope by userID dari JWT)

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/partner/wallet` | Dashboard wallet (saldo, total pendapatan, total withdraw) |
| `GET` | `/partner/wallet/transactions` | Riwayat transaksi wallet (pagination) |
| `POST` | `/partner/wallet/withdraw` | Buat permintaan penarikan saldo |
| `GET` | `/partner/wallet/withdrawals` | Daftar withdraw saya (filter status) |
| `GET` | `/partner/wallet/withdrawals/:id` | Detail withdraw |

### 👑 Admin (`/api/v1/admin`) — `RoleGuard("ADMIN")`

| Method | Endpoint | Deskripsi |
|---|---|---|
| | **Tenant Management** | |
| `POST` | `/admin/tenants` | Buat tenant |
| `GET` | `/admin/tenants` | List semua tenant di platform |
| `GET` | `/admin/tenants/:id` | Detail tenant |
| `DELETE` | `/admin/tenants/:id` | Soft-delete tenant |
| `GET` | `/admin/tenants/users/:userId` | Tenant berdasarkan user |
| | **User Management** | |
| `GET` | `/admin/users` | List semua user |
| `GET` | `/admin/users/:id` | Detail user |
| | **Menu Management** (via `X-Tenant-ID` header) | |
| `GET` | `/admin/menus` | List menu tenant |
| `GET` | `/admin/menus/:id` | Detail menu |
| `POST` | `/admin/menus` | Tambah menu |
| `PUT` | `/admin/menus/:id` | Update menu |
| `DELETE` | `/admin/menus/:id` | Soft-delete menu |
| `PATCH` | `/admin/menus/:id/toggle-available` | Toggle ketersediaan |
| | **Wallet Management** | |
| `GET` | `/admin/wallet/partners` | List wallet semua partner |
| `GET` | `/admin/wallet/withdrawals` | List semua withdraw request |
| `PATCH` | `/admin/wallet/withdrawals/:id/approve` | Approve withdraw |
| `PATCH` | `/admin/wallet/withdrawals/:id/reject` | Reject withdraw + refund saldo |
| `PATCH` | `/admin/wallet/withdrawals/:id/transfer` | Tandai transfer selesai |
| | **Payment Sync** | |
| `POST` | `/admin/payments/sync` | Sinkronisasi status pembayaran dengan Midtrans |

> **Catatan:** Domain `subscription` sudah memiliki kode handler dan repository lengkap (CRUD subscription plans), namun **belum di-register** ke `admin_routes.go`. Endpoint-nya siap diaktifkan: `GET/POST /admin/subscriptions/plans`, `PATCH /admin/subscriptions/plans/:id`.

### 🔗 Endpoints Lainnya

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/health` | Service health check |
| `GET` | `/ready` | Service readiness check (DB) |
| `GET` | `/ws?token=...&tenant_id=...` | WebSocket connection (real-time events) |
| `POST` | `/webhook/midtrans` | Midtrans payment webhook callback |
| `GET` | `/swagger/*` | Swagger UI (API documentation) |

---

## ⚡ Setup & Menjalankan Proyek

### Prasyarat

| Tool | Versi |
|---|---|
| Flutter SDK | ≥ 3.11 |
| Dart SDK | ≥ 3.11 |
| Go | ≥ 1.25 |
| PostgreSQL | 16+ (atau Supabase) |
| Redis | 7+ (opsional untuk dev) |

### 1. Backend Setup

```bash
# Clone repository backend
cd saas_gangsta

# Install dependencies
go mod tidy

# Setup environment
cp .env.example .env
# Edit .env sesuai konfigurasi Anda
```

**Environment Variables yang diperlukan:**

| Variable | Wajib | Deskripsi | Contoh |
|---|---|---|---|
| `DATABASE_URL` | ✅ | PostgreSQL connection string | `postgresql://postgres:pass@host:5432/db` |
| `JWT_SECRET` | ✅ | Secret key untuk JWT (min 32 chars) | `super-secret-key-change-me` |
| `APP_PORT` | — | Port server (default: 8080) | `8080` |
| `APP_ENV` | — | Environment mode | `development` / `production` |
| `APP_NAME` | — | Nama service | `saas_gangsta` |
| `CORS_ALLOWED_ORIGINS` | — | Allowed origins (comma-separated) | `http://localhost:3000` |
| `REDIS_URL` | — | Redis connection string | `redis://localhost:6379/0` |
| `MIDTRANS_SERVER_KEY` | — | Midtrans server key | `SB-Mid-server-xxx` |
| `MIDTRANS_CLIENT_KEY` | — | Midtrans client key | `SB-Mid-client-xxx` |
| `MIDTRANS_ENV` | — | Midtrans environment | `sandbox` / `production` |
| `SUPABASE_URL` | Prod | Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | — | Supabase anon key | `eyJxxx` |
| `SUPABASE_SERVICE_ROLE_KEY` | Prod | Supabase service role key | `eyJxxx` |
| `JWT_ACCESS_TOKEN_EXPIRY` | — | Durasi access token (default: 15m) | `15m` |
| `JWT_REFRESH_TOKEN_EXPIRY` | — | Durasi refresh token (default: 168h) | `168h` |

```bash
# Jalankan server
go run cmd/api/main.go

# Server berjalan di http://localhost:8080
# Swagger UI: http://localhost:8080/swagger/index.html
```

#### Docker (Full Stack Local)

```bash
# Jalankan dengan Docker Compose (API + Nginx + Redis + PostgreSQL)
docker compose -f deployments/docker-compose.yml up --build

# Akses API via Nginx: http://localhost:80
# Akses API langsung: http://localhost:8080
```

### 2. Frontend Setup

```bash
# Clone repository frontend
cd fe_gangsta_flutter

# Install dependencies
flutter pub get

# Jalankan di Chrome (default port 3000)
flutter run -d chrome --web-port=3000

# Atau build untuk web
flutter build web
```

**Konfigurasi API URL:**

Frontend menggunakan compile-time environment variable. Untuk pointing ke server production:

```bash
flutter run -d chrome --dart-define=APP_DOMAIN=https://saasgangsta-production.up.railway.app
```

Default: `http://localhost:8080` (local development)

### 3. Database Migrations

Migration files ada di `supabase/migrations/`. Jalankan secara berurutan di PostgreSQL:

```bash
# Contoh: jalankan migration via psql
psql $DATABASE_URL -f supabase/migrations/20260420000001_create_tenants_table.sql
# ... dst

# Atau seed data development
psql $DATABASE_URL -f scripts/seed.sql
```

---

## 🚀 Deployment

### Backend → Railway

Backend di-deploy ke **Railway** menggunakan Docker:

- Config: [railway.toml](railway.toml)
- Dockerfile: [deployments/Dockerfile](deployments/Dockerfile)
- Healthcheck: `GET /health` (timeout: 120s)
- Restart policy: `ON_FAILURE` (max 10 retries)

### Frontend → Vercel

Frontend Flutter Web di-deploy ke **Vercel**:

- Config: [vercel.json](vercel.json) (SPA rewrite rules)
- Build script: [vercel_build.sh](vercel_build.sh)
- Output: `build/web/`

---

## 🔌 Real-time: WebSocket

Gangsta App menggunakan WebSocket untuk notifikasi pesanan real-time:

```
ws://localhost:8080/ws?token=<JWT>&tenant_id=<UUID>
```

**Flow:**
1. **Customer** membuat order → backend broadcast event `new_order` ke tenant
2. **Merchant** (Kitchen Display) menerima notifikasi real-time
3. Status update order → broadcast ke customer yang bersangkutan

**Fitur:**
- Auto-reconnect dengan delay 5 detik
- Branch-specific registration (tenant_id untuk partner, userId untuk customer)
- Multi-client support per tenant (multiple tabs/devices)
- Token-based authentication saat connect

---

## 📊 Database Schema

25 migration files yang mencakup:

| Entity | Tabel | Fitur Utama |
|---|---|---|
| Tenant | `tenants` | Multi-tenant, slug, is_public, user_id |
| User | `users` | Role enum (CUSTOMER, PARTNER, ADMIN), bcrypt password |
| Category | `categories` | Per-tenant, ordering, toggle active |
| Menu | `menus` | Per-tenant, harga, gambar, is_available |
| Dining Table | `dining_tables` | Per-tenant, table_name |
| Order | `orders` | Per-tenant, customer_name, queue_number, payment method, payment status |
| Order Item | `order_items` | Relasi ke order & menu, quantity, price, notes |
| Partner Wallet | `partner_wallets` | Saldo partner, total_earned, total_withdrawn |
| Wallet Transaction | `wallet_transactions` | Riwayat CREDIT/DEBIT wallet |
| Withdraw Request | `withdraw_requests` | Request penarikan dana, status workflow |
| Platform Fee Config | `platform_fee_configs` | Konfigurasi fee platform |

> Semua tabel menggunakan **soft delete** (`deleted_at`) dan **UUID** sebagai primary key.

---

## 📚 Dokumentasi Tambahan

| Dokumen | Deskripsi |
|---|---|
| [Frontend Pattern & Design System](docs/frontend_pattern_design_system.md) | Arsitektur Flutter, design tokens, component guidelines |
| [API Connection Setup](docs/api_connection_setup.md) | Cara Flutter terhubung ke backend API |
| [Swagger API Docs](docs/swagger.json) | OpenAPI specification lengkap |
| [Ringkasan Sistem](RingkasanSystem.md) | Overview arsitektur end-to-end |
| [Backend Roadmap](BACKEND_ROADMAP_GOLANG.md) | Roadmap pengembangan backend |
| [Clean Code Structure](README_CLEAN_CODE_STRUCTURE.md) | Panduan struktur kode yang disarankan |
| [Acuan Code](AcuanCode.md) | Reference & coding standards |

### Swagger API Documentation

Generate/update Swagger docs:

```bash
cd saas_gangsta
swag init -g cmd/api/main.go
```

Akses di: `http://localhost:8080/swagger/index.html`

---

## 📈 Business Model & Roadmap

### Why This Matters

UMKM kuliner di Indonesia masih menghadapi masalah operasional yang berulang. Gangsta App dirancang untuk menyelesaikan bottleneck tersebut dengan pengalaman yang cepat dipakai, ramah merchant, dan scalable sebagai produk SaaS multi-tenant.

### Why We Can Win

- Role-based architecture: customer, merchant, admin dalam satu ekosistem
- Flutter multiplatform: mobile, web, desktop dari satu codebase
- Design system & tokenized UI untuk kecepatan iterasi produk
- Produk difokuskan pada pain point operasional harian, bukan hanya kasir

### Business Model

- **Subscription SaaS** per merchant per bulan
- Potensi add-on:
  - Fitur premium analytics
  - Integrasi pembayaran
  - White-label / multi-outlet package

### Market Opportunity

- Fokus awal: UMKM kuliner Indonesia (warung makan, bakso, soto, kedai)
- Segmen ini besar, fragmented, dan membutuhkan solusi operasional yang simpel namun andal
- Peluang ekspansi: multi-outlet F&B dan vertical hospitality lain

### Roadmap 12 Bulan

| Phase | Fokus | Detail |
|---|---|---|
| **Phase 1: Foundation** | Core POS & Menu | Stabilkan core POS flow, menu management, baseline analytics, onboarding tenant awal |
| **Phase 2: Monetization** | Billing & Subscription | Launch paket berlangganan, billing & membership management, optimasi onboarding |
| **Phase 3: Scale** | Payment & Automation | Integrasi payment, multi-outlet capability, observability & reliability |

### Investor Quick Facts

| Metric | Current | Notes |
|---|---:|---|
| Active Merchants | TBA | Isi jumlah tenant aktif |
| Monthly Transactions | TBA | Total transaksi bulanan |
| Monthly GMV | TBA | Nilai transaksi bruto bulanan |
| MRR | TBA | Monthly Recurring Revenue |
| Churn Rate | TBA | Persentase churn merchant |
| CAC Payback | TBA | Periode balik modal akuisisi |

### Status Saat Ini

- **Tahap:** Product development dan validasi market
- **Fokus:** Mempercepat readiness untuk pilot tenant dan pembuktian unit economics

---

## 🧑‍💻 Tim & Kontribusi

### Coding Standards

| Area | Convention |
|---|---|
| JSON response fields | `camelCase` (e.g., `storeName`) |
| Database columns | `snake_case` (e.g., `store_name`) |
| Multi-tenancy | Semua query bisnis **wajib** filter `tenant_id` dari JWT context |
| Response format | Gunakan helper `response.Success()` / `apperrors.Write()` |
| Validasi input | Gunakan `validator/v10` tags di DTO struct |

### Git Flow

Branch development:
- `dev-dhegas`
- `dev-dekgus`
- `dev-renata`

> Lakukan Pull Request ke branch utama setelah review.

### Definition of Done (DoD)

Sebelum submit Pull Request:
- [ ] Endpoint sesuai spek (Method, Path, Payload)
- [ ] Validasi input berfungsi (`validator/v10`)
- [ ] Filter `tenantId` sudah diterapkan di Repository
- [ ] Response menggunakan format standard envelope
- [ ] Error ditangani tanpa mengekspos detail teknis
- [ ] Swagger sudah di-update (`swag init`)

---

## 📬 Kontak

Jika Anda investor atau strategic partner dan ingin melihat demo produk:

- **Email:** gasdhegas@gmail.com

---

<p align="center">
  <em>Built with ❤️ for UMKM Kuliner Indonesia</em>
</p>