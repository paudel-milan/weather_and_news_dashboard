// lib/widgets/search_input_field.dart

import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final TextInputAction textInputAction; // For keyboard action button

  const SearchInputField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onSubmitted,
    this.onChanged,
    this.suffixIcon,
    this.textInputAction = TextInputAction.search, // Default to search action
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      textInputAction: textInputAction, // Set keyboard action
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: suffixIcon, // Allows external control of suffix (e.g., loading indicator)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Inherit from theme or remove for filled style
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).primaryColor, width: 2), // Highlight on focus
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor, // Use cardColor for filled background
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}