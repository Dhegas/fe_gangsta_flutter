# README — Frontend Pattern & Design System

## Project

**SaaS POS & Self-Order untuk UMKM Kuliner Indonesia**
Target tenant: **toko bakso, lontong, soto, warung makan, kedai, dan usaha F&B sejenis**

Role utama:

- **Customer**
- **Merchant**
- **Admin**

Dokumen ini menjadi **fondasi pattern frontend** agar pengembangan UI/UX, struktur komponen, naming, dan styling tetap konsisten sejak awal.

---

# 1. Design Direction

## Core Concept

Sistem ini harus terasa seperti:

- **modern**
- **cepat dipakai**
- **mudah dipahami pemilik UMKM**
- **rapi seperti aplikasi kasir profesional**
- **hangat dan familiar untuk pasar Indonesia**

Visual style mengacu pada arah desain premium–editorial yang kamu kirim, tetapi disederhanakan agar tetap realistis untuk implementasi SaaS UMKM.

## Product Personality

- **Praktis** → tidak ribet untuk merchant
- **Cepat** → cocok untuk jam sibuk toko
- **Ramah** → tidak terasa terlalu “corporate”
- **Profesional** → tetap layak untuk sistem berbayar / SaaS

---

# 2. Brand & Visual Identity

## Color Palette

Gunakan token warna berikut sebagai **source of truth**:

### Core Brand Colors

- **Primary**: `#FF6B35`
- **Secondary**: `#2ECC71`
- **Tertiary**: `#F1C40F`
- **Neutral**: `#F8FAFC`

## Color Usage Rules

### Primary — `#FF6B35`

Gunakan untuk:

- CTA utama
- tombol action penting
- active state utama
- highlight elemen penting
- badge status order aktif

**Makna:** hangat, cepat, kuliner, action.

### Secondary — `#2ECC71`

Gunakan untuk:

- status sukses
- pembayaran berhasil
- pesanan selesai
- availability / open / ready
- grafik positif

**Makna:** aman, selesai, valid.

### Tertiary — `#F1C40F`

Gunakan untuk:

- warning ringan
- status pending
- meja butuh perhatian
- notifikasi non-kritis

**Makna:** perhatian, waiting, caution.

### Neutral — `#F8FAFC`

Gunakan untuk:

- background utama
- section lembut
- card area terang
- base UI surface

**Makna:** bersih, modern, ringan.

---

# 3. Typography System

## Font Rules

### Headlines

Gunakan: **Plus Jakarta Sans**

Dipakai untuk:

- page title
- section heading
- card title penting
- angka KPI / statistik
- nama halaman dashboard

### Body & Label

Gunakan: **Inter**

Dipakai untuk:

- paragraf
- deskripsi menu
- tabel
- label input
- caption
- helper text
- button text
- sidebar text

---

## Typography Scale

### Display

- `display-lg` → 48px / 56px / Bold
- `display-md` → 40px / 48px / Bold
- `display-sm` → 32px / 40px / SemiBold

### Headline

- `headline-lg` → 28px / 36px / Bold
- `headline-md` → 24px / 32px / SemiBold
- `headline-sm` → 20px / 28px / SemiBold

### Title

- `title-lg` → 18px / 28px / SemiBold
- `title-md` → 16px / 24px / SemiBold
- `title-sm` → 14px / 20px / SemiBold

### Body

- `body-lg` → 16px / 28px / Regular
- `body-md` → 14px / 24px / Regular
- `body-sm` → 12px / 20px / Regular

### Label

- `label-lg` → 14px / 20px / Medium
- `label-md` → 12px / 16px / Medium
- `label-sm` → 11px / 16px / Medium

---

# 4. Layout Principles

## Layout Philosophy

Frontend harus dibangun dengan prinsip:

- **clean first**
- **mobile-first**
- **component-driven**
- **role-based layout**
- **scalable for SaaS multi-tenant**

## Grid Recommendation

- **Mobile** → 4 column feel
- **Tablet** → 8 column feel
- **Desktop** → 12 column feel

## Spacing Scale

Gunakan spacing token berikut:

- `space-1` = 4px
- `space-2` = 8px
- `space-3` = 12px
- `space-4` = 16px
- `space-5` = 20px
- `space-6` = 24px
- `space-8` = 32px
- `space-10` = 40px
- `space-12` = 48px
- `space-16` = 64px
- `space-20` = 80px
- `space-24` = 96px

**Rule penting:**
Jangan terlalu padat. Merchant harus bisa scan informasi dengan cepat.

---

# 5. Surface & Elevation Rules

## UI Style Direction

Mengacu pada pattern premium yang kamu kirim:

- minim border keras
- lebih banyak tonal contrast
- card terasa lembut
- modern dan clean

## Surface Tokens

- `surface-base` → `#FFFFFF`
- `surface-neutral` → `#F8FAFC`
- `surface-soft` → `#F2F4F6`
- `surface-strong` → `#E8EDF2`

## Border Rule

**Hindari terlalu banyak border 1px**.
Gunakan prioritas berikut:

1. background contrast
2. spacing
3. radius
4. baru border jika benar-benar perlu

## Radius Tokens

- `radius-sm` = 8px
- `radius-md` = 12px
- `radius-lg` = 16px
- `radius-xl` = 24px
- `radius-2xl` = 32px

**Default recommendation:**

- button → `radius-lg`
- card → `radius-xl`
- modal → `radius-2xl`
- input → `radius-lg`

## Shadow Rules

Gunakan shadow lembut:

### Soft Shadow

```css
box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
```

### Floating Shadow

```css
box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
```

---

# 6. Interaction Pattern

## State Rules

Setiap komponen interaktif minimal punya state:

- default
- hover
- active
- focus
- disabled
- loading

## Motion Rules

Animasi harus:

- cepat
- halus
- tidak berlebihan

### Recommended Transition

```css
transition: all 180ms ease;
```

### Flutter Motion Mapping

Gunakan durasi ini sebagai acuan di Flutter:

- micro interaction: `Duration(milliseconds: 120)`
- standard interaction: `Duration(milliseconds: 180)`
- screen transition: `Duration(milliseconds: 240)`

Widget yang direkomendasikan:

- `AnimatedContainer`
- `AnimatedOpacity`
- `TweenAnimationBuilder`
- `PageRouteBuilder` (untuk transisi halaman custom)

## Feedback Rules

Semua action penting wajib ada feedback:

- create → success toast
- update → success toast
- delete → confirmation modal
- payment → success / failed state
- order status → realtime badge / status chip

---

# 7. Component Pattern

## 7.1 Button Pattern

### Button Variants

- `primary-button`
- `secondary-button`
- `ghost-button`
- `danger-button`
- `success-button`

### Rules

- CTA utama hanya **1 dominan** per section
- jangan ada 3 tombol primary dalam 1 area kecil

---

## 7.2 Input Pattern

### Standard Inputs

- text input
- textarea
- number input
- currency input
- search input
- select
- multiselect
- date picker
- time picker

### Input Style Rules

- background lembut
- border tipis atau subtle
- focus pakai accent `primary`
- error pakai merah lembut, bukan merah terlalu tajam

---

## 7.3 Card Pattern

Gunakan card untuk:

- menu item
- order summary
- meja status
- laporan ringkas
- tenant summary
- membership plan

### Card Principles

- card harus punya hierarchy jelas
- card tidak boleh terlalu penuh
- satu card = satu fokus informasi utama

---

## 7.4 Badge / Chip Pattern

Gunakan untuk status:

- paid
- unpaid
- processing
- ready
- served
- active
- inactive
- premium
- expired

### Status Color Mapping

- success → secondary
- warning → tertiary
- active order → primary
- inactive / archived → neutral dark tone

---

## 7.5 Table Pattern

Table digunakan untuk:

- riwayat transaksi
- laporan penjualan
- daftar tenant
- daftar user admin
- membership billing

### Rules

- gunakan sticky header bila perlu
- kolom action selalu paling kanan
- action destructive jangan terlalu menonjol

---

# 8. Information Architecture by Role

---

# 9. Frontend Folder / Architecture Pattern

> Rekomendasi utama untuk **Flutter (Dart) Multiplatform**

## Recommended Architecture

Gunakan pattern:

**Feature-Based + Shared Design System**

Artinya:

- file dipisah berdasarkan fitur
- komponen reusable diletakkan di shared
- styling/token/design system terpusat
- scalable untuk 3 role
- bisa jalan untuk mobile, web, dan desktop dari 1 codebase Flutter

## Recommended Structure

```bash
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── bootstrap/
│   └── guards/
│
├── core/
│   ├── constants/
│   ├── network/
│   ├── storage/
│   ├── error/
│   └── utils/
│
├── design_system/
│   ├── tokens/
│   │   ├── color_tokens.dart
│   │   ├── spacing_tokens.dart
│   │   ├── radius_tokens.dart
│   │   └── typography_tokens.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_extensions.dart
│   └── widgets/
│       ├── buttons/
│       ├── inputs/
│       ├── cards/
│       └── feedback/
│
├── shared/
│   ├── models/
│   ├── services/
│   └── widgets/
│
├── features/
│   ├── customer/
│   │   ├── menu/
│   │   ├── order/
│   │   ├── payment/
│   │   ├── review/
│   │   └── transaction/
│   ├── merchant/
│   │   ├── menu_management/
│   │   ├── pos/
│   │   ├── table_management/
│   │   ├── report/
│   │   ├── profile/
│   │   └── transaction/
│   └── admin/
│       ├── tenant_management/
│       ├── membership/
│       ├── dashboard/
│       ├── user_management/
│       └── global_config/
│
└── main.dart
```

### Struktur per Feature (Pattern Detail)

```bash
features/merchant/pos/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── controllers/
    └── state/
```

---

# 10. Naming Convention Pattern

## Component Naming

Gunakan:

- `PascalCase` untuk class/widget
- `camelCase` untuk function / variable / method
- `snake_case` untuk nama file dan folder

### Contoh

- `menu_card.dart`
- `order_status_badge.dart`
- `merchant_sidebar.dart`
- `tenant_subscription_table.dart`

## Widget & Page Naming

- widget class: `MenuCard`, `OrderStatusBadge`
- page/screen class: `MerchantDashboardPage`, `CustomerCheckoutPage`
- state class: `OrderState`, `MerchantReportState`
- controller/notifier class: `OrderController`, `MenuNotifier`

## State Handler Naming

- Riverpod Notifier: `menuNotifierProvider`, `orderStatusProvider`
- Cubit/BLoC: `MenuCubit`, `OrderBloc`
- ChangeNotifier: `MerchantProfileNotifier`

## API Service Naming

- `menu_service.dart`
- `order_service.dart`
- `tenant_service.dart`
- `membership_service.dart`

---

# 11. State Management Pattern

## Recommendation

Pisahkan state menjadi 3 kategori:

### 1. Server State

Untuk data dari backend:

- menu
- order
- transaction
- membership
- tenant

**Rekomendasi Flutter:**

- `Riverpod` (`AsyncNotifier` / `FutureProvider`) untuk fetch + cache data
- atau `BLoC/Cubit` bila tim sudah terbiasa event-driven architecture

### 2. UI State

Untuk state tampilan:

- modal open/close
- selected tab
- drawer state
- toast state
- filter state

**Rekomendasi Flutter:**

- state lokal widget untuk state sederhana
- `StateNotifier` / `Notifier` (Riverpod) untuk UI state lintas halaman
- `ValueNotifier` untuk kebutuhan ringan

### 3. Form State

Untuk:

- create menu
- update profile
- payment form
- membership form

**Rekomendasi Flutter:**

- `Form` + `TextFormField` + `GlobalKey<FormState>`
- validasi dengan `formz` atau validator custom
- gunakan input formatter untuk currency, number, dan mask

## Dependency Recommendation (Paket Umum)

- State management: `flutter_riverpod`
- Networking: `dio`
- Routing: `go_router`
- Immutable model: `freezed`
- JSON serialization: `json_serializable`
- Local storage: `shared_preferences` / `flutter_secure_storage`

---

# 12. Design Token Pattern

## Token Categories

Semua styling harus mengacu ke token, **jangan hardcode warna di banyak tempat**.

### Token Group

- colors
- spacing
- radius
- typography
- shadows
- z-index
- breakpoints
- motion

## Example Token Naming

```dart
AppColors.primary
AppColors.secondary
AppColors.tertiary
AppColors.neutral
AppColors.surfaceBase
AppColors.surfaceSoft
AppColors.textPrimary
AppColors.textSecondary
AppColors.statusSuccess
AppColors.statusWarning
AppColors.statusError

AppSpacing.space1
AppSpacing.space2
AppSpacing.space4

AppRadius.sm
AppRadius.md
AppRadius.lg
```

## Theme Integration Rule

Semua token harus diakses via theme/design system, bukan hardcode langsung di widget.

Contoh pendekatan:

- `Theme.of(context).textTheme` untuk tipografi
- `Theme.of(context).colorScheme` untuk warna semantik
- `ThemeExtension` untuk token custom brand

---

# 13. Responsive Pattern

## Device Priority

Urutan prioritas UI:

1. **Merchant tablet / desktop**
2. **Customer mobile**
3. **Admin desktop**

Karena use case-nya:

- customer scan QR → mostly mobile
- merchant pakai kasir / tablet / laptop
- admin pakai dashboard → desktop first

## Flutter Breakpoint Recommendation

Gunakan breakpoint konsisten di layout engine Flutter:

- compact: `< 600` (phone)
- medium: `600 - 1023` (tablet)
- expanded: `>= 1024` (desktop/web wide)

Widget/layout yang direkomendasikan:

- `LayoutBuilder`
- `MediaQuery`
- `Wrap` / `GridView`
- `NavigationBar` (mobile), `NavigationRail` (tablet), `Sidebar` custom (desktop)

## Responsive Rules

### Customer

- mobile-first
- tombol besar
- menu mudah discroll
- checkout singkat

### Merchant

- tablet-friendly
- cepat klik saat ramai
- dashboard modular
- data tidak berantakan

### Admin

- desktop dashboard heavy
- table & analytics optimized
- manajemen data efisien

## Platform Adaptation Rules (Flutter)

- Mobile (Android/iOS): prioritaskan gesture, single-column, CTA besar
- Web: optimalkan SEO halaman publik jika diperlukan dan perhatikan ukuran layar besar
- Desktop (Windows/macOS/Linux): perbesar density data, dukung shortcut keyboard, dan hover interaction
- Semua platform: behavior bisnis harus konsisten, hanya layout/interaksi yang menyesuaikan device

---

# 14. UX Rules (Penting)

## Customer UX

Harus:

- cepat order
- tidak membingungkan
- sedikit step
- jelas total harga
- jelas status pesanan

## Merchant UX

Harus:

- cepat input order
- cepat update status
- cepat edit menu
- mudah baca laporan
- minim salah klik

## Admin UX

Harus:

- mudah monitoring tenant
- mudah kelola membership
- mudah lihat merchant aktif / nonaktif
- mudah audit pembayaran

---

# 15. Frontend Principles Summary

## Wajib Diikuti

- gunakan **feature-based architecture**
- gunakan **design tokens**
- gunakan **role-based layout**
- gunakan **component reuse** semaksimal mungkin
- semua fitur baru harus mengikuti naming convention ini
- semua UI baru harus mengikuti typography, spacing, radius, dan color token

## Dilarang

- hardcode warna sembarangan
- bikin komponen tanpa pattern
- campur logic API langsung di page
- styling acak per file tanpa token
- bikin UI terlalu ramai untuk merchant

---

# 16. Next Step Recommendation

Setelah README pattern ini, langkah yang paling ideal adalah:

1. buat **Design Tokens file**
2. buat **UI component guideline**
3. buat **folder structure real project FE**
4. buat **wireframe per role**
5. baru masuk ke implementasi halaman

---

# Reference Note

Dokumen ini juga mengadopsi arah visual dari file desain yang kamu kirim: editorial-premium, minim border keras, tonal layering, dan hospitality-oriented UI language.
