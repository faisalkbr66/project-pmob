// ============================================
// FILE: lib/widgets/add_review_sheet.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/review_viewmodel.dart';

/// Bottom sheet untuk tulis ulasan.
/// Dipanggil via showModalBottomSheet dari ReviewSection.
class AddReviewSheet extends StatefulWidget {
  const AddReviewSheet({
    super.key,
    required this.productId,
    required this.vm,
  });

  final int productId;
  final ReviewViewModel vm;

  @override
  State<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<AddReviewSheet> {
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _yellow = Color(0xFFF8E545);
  static const Color _yellowDark = Color(0xFF201C00);
  static const Color _border = Color(0x14001261);

  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih rating terlebih dahulu',
              style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await widget.vm.submit(
      widget.productId,
      _rating,
      _commentCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vm.submitError ?? 'Gagal mengirim ulasan',
              style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5EC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Tulis Ulasan',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bagikan pengalamanmu dengan produk ini',
                    style: GoogleFonts.manrope(fontSize: 12, color: _muted),
                  ),
                  const SizedBox(height: 20),

                  // Star rating
                  Text(
                    'Rating',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < _rating;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: filled
                                  ? _yellow
                                  : _surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: filled ? _yellow : _border,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              filled ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 24,
                              color: filled ? _yellowDark : _muted,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_rating > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      _ratingLabel(_rating),
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Comment
                  Text(
                    'Komentar',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    style: GoogleFonts.manrope(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ceritakan pengalamanmu...',
                      hintStyle: GoogleFonts.manrope(
                          fontSize: 13, color: _muted),
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _purple, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: GoogleFonts.manrope(
                          fontSize: 10, color: _muted),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Komentar tidak boleh kosong';
                      }
                      if (v.trim().length < 10) {
                        return 'Minimal 10 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  ListenableBuilder(
                    listenable: widget.vm,
                    builder: (_, __) {
                      final busy = widget.vm.isSubmitting;
                      return SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: busy
                                ? null
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [_purple, Color(0xFF6B0075)],
                                  ),
                            color: busy ? _surface : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: busy ? null : _submit,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (busy)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _purple,
                                        ),
                                      )
                                    else
                                      const Icon(Icons.send_rounded,
                                          size: 15, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      busy ? 'Mengirim...' : 'Kirim Ulasan',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: busy ? _muted : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _ratingLabel(int r) => const [
        '',
        'Sangat Buruk',
        'Buruk',
        'Cukup',
        'Bagus',
        'Luar Biasa!',
      ][r];
}
