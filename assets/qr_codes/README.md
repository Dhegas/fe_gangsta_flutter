# Store QR Codes

Folder ini berisi QR code SVG untuk semua toko dummy.

Setiap QR code berisi payload dengan format:
- gangsta://store/<store-id>

Daftar lengkap ada di file manifest.json.

Regenerate kapan saja dengan command:
- dart run tool/generate_store_qr_assets.dart