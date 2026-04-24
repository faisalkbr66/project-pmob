// ============================================
// FILE: lib/widgets/category_chip.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Active "Semua" → navy pekat sesuai desain,
    // Active kategori lain → light purple sesuai desain.
    final bool isSemua = label.toLowerCase() == 'semua';
    final Color bg = isActive
        ? (isSemua ? AppColors.primaryDark : const Color(0xFFFFE6F3))
        : Colors.white;
    final Color fg = isActive
        ? (isSemua ? Colors.white : AppColors.primaryDark)
        : AppColors.textSecondary;
    final Color borderColor =
        isActive ? Colors.transparent : const Color(0xFFE5E5EC);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
