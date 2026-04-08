# README — Clean Code Structure & Feature Blueprint

Dokumen ini adalah acuan struktur clean code untuk implementasi lanjutan project Flutter SaaS UMKM Kuliner.
Dokumen ini melengkapi [README.md](README.md) (design system) dan [RingkasanSystem.md](RingkasanSystem.md) (business domain).

## 1. Tujuan Dokumen

1. Menyatukan standar arsitektur clean code per fitur dan per role.
2. Menjadi blueprint folder/file untuk implementasi bertahap setelah MVP dimulai.
3. Menjaga konsistensi agar code tetap scalable, reusable, dan mudah di-maintain.

## 2. Prinsip Clean Code Wajib

1. Pisahkan concern: data, domain, presentation.
2. Satu file satu tanggung jawab utama.
3. Hindari hardcode style, gunakan design token/theme.
4. Hindari hardcode endpoint/secret, simpan di config layer.
5. Semua state perubahan UI melewati state layer, bukan langsung di widget acak.
6. Gunakan naming convention sesuai README utama:
   - class/widget: PascalCase
   - method/variable: camelCase
   - file/folder: snake_case
7. Fitur baru wajib mengikuti struktur folder yang sama agar onboarding cepat.

## 3. Struktur Root yang Direkomendasikan

```bash
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_names.dart
│   │   └── route_guards.dart
│   ├── bootstrap/
│   │   ├── app_bootstrap.dart
│   │   └── dependency_injection.dart
│   └── guards/
│       ├── auth_guard.dart
│       └── role_guard.dart
│
├── core/
│   ├── config/
│   │   ├── env.dart
│   │   └── app_flavor.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── app_regex.dart
│   ├── error/
│   │   ├── failures.dart
│   │   ├── exceptions.dart
│   │   └── error_mapper.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── network_info.dart
│   │   └── interceptors/
│   ├── storage/
│   │   ├── secure_storage_service.dart
│   │   ├── local_storage_service.dart
│   │   └── session_storage_service.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   ├── input_validator.dart
│   │   └── debounce.dart
│   └── widgets/
│       ├── app_loading.dart
│       ├── app_empty_state.dart
│       ├── app_error_state.dart
│       └── app_shimmer.dart
│
├── design_system/
│   ├── tokens/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   ├── app_typography.dart
│   │   └── app_shadow.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_extensions.dart
│   └── widgets/
│       ├── buttons/
│       ├── inputs/
│       ├── cards/
│       ├── chips/
│       └── feedback/
│
├── shared/
│   ├── models/
│   ├── entities/
│   ├── services/
│   └── widgets/
│
└── features/
    ├── customer/
    ├── merchant/
    └── admin/
```

## 4. Template Struktur Per Feature

Semua feature wajib mengikuti template ini:

```bash
features/<role>/<feature_name>/
├── data/
│   ├── datasources/
│   │   ├── <feature_name>_remote_datasource.dart
│   │   └── <feature_name>_local_datasource.dart
│   ├── models/
│   │   ├── <feature_name>_model.dart
│   │   └── <feature_name>_request_model.dart
│   └── repositories/
│       └── <feature_name>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature_name>_entity.dart
│   ├── repositories/
│   │   └── <feature_name>_repository.dart
│   └── usecases/
│       ├── get_<feature_name>.dart
│       ├── create_<feature_name>.dart
│       ├── update_<feature_name>.dart
│       └── delete_<feature_name>.dart
└── presentation/
    ├── state/
    │   ├── <feature_name>_state.dart
    │   └── <feature_name>_status.dart
    ├── controllers/
    │   └── <feature_name>_controller.dart
    ├── pages/
    │   ├── <feature_name>_page.dart
    │   └── <feature_name>_detail_page.dart
    └── widgets/
        ├── <feature_name>_card.dart
        ├── <feature_name>_filter.dart
        └── <feature_name>_form.dart
```

## 5. Blueprint Role & Feature Selanjutnya

### 5.1 Customer Features

```bash
features/customer/
├── menu/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── order/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── order_remote_datasource.dart
│   │   │   └── cart_local_datasource.dart
│   │   ├── models/
│   │   │   ├── order_model.dart
│   │   │   └── cart_item_model.dart
│   │   └── repositories/
│   │       └── order_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── order_entity.dart
│   │   │   └── cart_item_entity.dart
│   │   ├── repositories/
│   │   │   └── order_repository.dart
│   │   └── usecases/
│   │       ├── add_to_cart.dart
│   │       ├── remove_from_cart.dart
│   │       ├── get_cart_summary.dart
│   │       └── submit_order.dart
│   └── presentation/
│       ├── state/
│       ├── controllers/
│       ├── pages/
│       │   ├── cart_page.dart
│       │   └── checkout_preview_page.dart
│       └── widgets/
├── payment/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── payment_method_page.dart
│       │   ├── payment_status_page.dart
│       │   └── payment_receipt_page.dart
│       └── widgets/
├── transaction/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── transaction_history_page.dart
│       │   └── transaction_detail_page.dart
│       └── widgets/
└── review/
    ├── data/
    ├── domain/
    └── presentation/
        ├── pages/
        │   └── review_page.dart
        └── widgets/
```

### 5.2 Merchant Features

```bash
features/merchant/
├── menu_management/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── menu_list_page.dart
│       │   ├── create_menu_page.dart
│       │   └── edit_menu_page.dart
│       └── widgets/
├── pos/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── pos_page.dart
│       │   └── pos_checkout_page.dart
│       └── widgets/
├── table_management/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── table_status_page.dart
│       │   └── table_detail_page.dart
│       └── widgets/
├── report/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── report_overview_page.dart
│       │   ├── report_daily_page.dart
│       │   ├── report_weekly_page.dart
│       │   └── report_monthly_page.dart
│       └── widgets/
├── profile/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   └── merchant_profile_page.dart
│       └── widgets/
└── transaction/
    ├── data/
    ├── domain/
    └── presentation/
        ├── pages/
        │   ├── merchant_transaction_list_page.dart
        │   └── merchant_transaction_detail_page.dart
        └── widgets/
```

### 5.3 Admin Features

```bash
features/admin/
├── tenant_management/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── tenant_list_page.dart
│       │   ├── tenant_detail_page.dart
│       │   └── tenant_status_page.dart
│       └── widgets/
├── membership/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── membership_list_page.dart
│       │   ├── create_membership_page.dart
│       │   └── edit_membership_page.dart
│       └── widgets/
├── dashboard/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   └── admin_dashboard_page.dart
│       └── widgets/
├── billing/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── billing_overview_page.dart
│       │   └── billing_detail_page.dart
│       └── widgets/
├── user_management/
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── pages/
│       │   ├── user_list_page.dart
│       │   └── user_detail_page.dart
│       └── widgets/
└── global_config/
    ├── data/
    ├── domain/
    └── presentation/
        ├── pages/
        │   └── global_config_page.dart
        └── widgets/
```

## 6. Struktur Router Berdasarkan Role

```bash
app/router/
├── app_router.dart
├── route_names.dart
├── customer_routes.dart
├── merchant_routes.dart
└── admin_routes.dart
```

Aturan route:

1. Public route:
   - splash
   - login
   - register
2. Customer route hanya bisa diakses role customer.
3. Merchant route hanya bisa diakses role merchant.
4. Admin route hanya bisa diakses role admin.
5. Route guard harus validasi session + role.

## 7. Struktur Shared Reusable Widget Lintas Role

```bash
shared/widgets/
├── app_scaffold/
│   ├── role_scaffold.dart
│   └── app_top_bar.dart
├── status/
│   ├── status_badge.dart
│   └── payment_status_chip.dart
├── feedback/
│   ├── toast_helper.dart
│   ├── confirmation_dialog.dart
│   └── error_banner.dart
└── forms/
    ├── app_text_field.dart
    ├── app_search_field.dart
    ├── app_currency_field.dart
    └── app_dropdown_field.dart
```

## 8. Roadmap Implementasi Bertahap

1. Foundation:
   - rapikan app bootstrap, router, dependency injection
   - finalisasi design system tokens dan shared widgets inti
2. Customer MVP:
   - menu -> cart/order -> payment status
3. Merchant MVP:
   - menu management -> POS -> table status -> report harian
4. Admin MVP:
   - tenant management -> membership -> billing monitoring
5. Hardening:
   - error handling global
   - analytics/logging
   - test unit/domain/presentation

## 9. Definition of Done per Feature

1. Folder feature lengkap data-domain-presentation.
2. Tidak ada hardcode style di page/widget.
3. State logic tidak ditulis di widget kompleks.
4. API contract dan mapper ada di data layer.
5. Ada validasi input + loading + error + empty state.
6. Analyzer bersih tanpa issue.

## 10. Catatan Penting

1. Struktur ini adalah source of truth untuk implementasi fitur berikutnya.
2. Jika ada penambahan fitur baru, tambahkan melalui pola yang sama.
3. Hindari loncat langsung ke UI tanpa domain dan data contract yang jelas.
