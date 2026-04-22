# API Connection Setup (Tanpa Daftar Routes Tetap)

Dokumen ini menjelaskan cara menghubungkan frontend Flutter ke backend Golang tanpa membuat konstanta route statis.

## 1. Konfigurasi Domain API

Konfigurasi domain ada di file:
- `lib/core/network/api_config.dart`

Default domain:
- `https://saasgangsta-production.up.railway.app`

Bisa dioverride saat run/build menggunakan `--dart-define`:

```bash
flutter run --dart-define=APP_DOMAIN=https://saasgangsta-production.up.railway.app
```

## 2. API Client Generik

Client generik ada di file:
- `lib/core/network/api_client.dart`

Fitur utama:
- Mendukung `GET`, `POST`, `PATCH`, `DELETE`
- Otomatis build URI dari `APP_DOMAIN + path`
- Otomatis menambahkan header JSON
- Optional Bearer token via callback `getAccessToken`
- Melempar `ApiException` jika status code bukan 2xx

## 3. Cara Pakai di Repository/DataSource

Contoh pemakaian endpoint berdasarkan path dari Swagger (`swaggo.json`):

```dart
import 'package:fe_gangsta_flutter/core/network/api_client.dart';
import 'package:http/http.dart' as http;

final apiClient = ApiClient(
  client: http.Client(),
  getAccessToken: () => yourToken,
);

final menus = await apiClient.getJson('/merchant/menus', query: {
  'page': 1,
  'limit': 20,
});

await apiClient.postJson('/merchant/menus', body: {
  'name': 'Nasi Goreng Spesial',
  'price': 25000,
});
```

## 4. Strategi Setelah Swagger Diberikan

Setelah `swaggo.json` diberikan:
- Ambil path langsung dari spec Swagger
- Map request payload ke model di data layer
- Map response ke entity/domain model
- Simpan path endpoint di masing-masing feature repository (bukan global route list)
