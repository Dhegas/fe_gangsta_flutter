import 'package:flutter/material.dart';

class MenuSearchField extends StatelessWidget {
  const MenuSearchField({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Cari menu favoritmu...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
