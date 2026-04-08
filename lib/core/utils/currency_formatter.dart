class CurrencyFormatter {
  const CurrencyFormatter._();

  static String toRupiah(int value) {
    final reversed = value.toString().split('').reversed.toList();
    final chunks = <String>[];

    for (var i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.skip(i).take(3).toList().reversed.join());
    }

    return 'Rp ${chunks.reversed.join('.')}';
  }
}
