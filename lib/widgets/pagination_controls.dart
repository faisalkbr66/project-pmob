// ============================================
// FILE: lib/widgets/pagination_controls.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.onPageSelected,
  });

  final int currentPage;
  final int lastPage;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    if (lastPage <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: () => onPageSelected(currentPage - 1),
        ),
        const SizedBox(width: 8),
        ..._buildPageItems().map((w) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: w,
            )),
        const SizedBox(width: 8),
        _ArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < lastPage,
          onTap: () => onPageSelected(currentPage + 1),
        ),
      ],
    );
  }

  /// Tampilkan halaman 1..min(3,last), lalu "..." jika masih ada,
  /// dan halaman terakhir. Cukup untuk UI mockup.
  List<Widget> _buildPageItems() {
    final items = <Widget>[];
    final maxShown = lastPage <= 3 ? lastPage : 3;

    for (int i = 1; i <= maxShown; i++) {
      items.add(_pageNumber(i));
    }
    if (lastPage > 4) {
      items.add(_ellipsis());
    }
    if (lastPage > maxShown) {
      items.add(_pageNumber(lastPage));
    }
    return items;
  }

  Widget _pageNumber(int page) {
    final active = page == currentPage;
    return GestureDetector(
      onTap: active ? null : () => onPageSelected(page),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDark : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$page',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _ellipsis() {
    return SizedBox(
      width: 28,
      height: 34,
      child: Center(
        child: Text(
          '...',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5EC)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
