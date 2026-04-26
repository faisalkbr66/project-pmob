// ============================================
// FILE: lib/widgets/cart_icon_button.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/cart_viewmodel.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key, required this.onTap});

  final VoidCallback onTap;

  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _muted = Color(0xFF757684);
  static const Color _badgeBg = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (_, vm, __) {
        final count = vm.totalItems;
        return Material(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: _muted,
                  ),
                  if (count > 0)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 15),
                        height: 15,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _badgeBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
