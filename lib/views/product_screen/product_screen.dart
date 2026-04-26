// ============================================
// FILE: lib/views/product_screen/product_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/mentor_model.dart';
import '../../models/product_model.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/featured_mentoring_card.dart';
import '../../widgets/mentoring_card.dart';
import '../../widgets/mentoring_section_header.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/product_tab_chip.dart';
import '../cart_screen.dart';
import 'detail_bootcamp_screen.dart';
import 'detail_kelas_screen.dart';
import 'detail_mentor_screen.dart';
import 'detail_modul_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _muted = Color(0xFF757684);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===== Navigation helpers =====

  void _openProductDetail(ProductModel p) {
    final route = MaterialPageRoute<void>(
      builder: (_) {
        switch (p.type) {
          case ProductType.modul:
            return DetailModulScreen(product: p);
          case ProductType.bootcamp:
            return DetailBootcampScreen(product: p);
          case ProductType.kelas:
          case ProductType.mentoring:
            return DetailKelasScreen(product: p);
        }
      },
    );
    Navigator.of(context).push(route);
  }

  void _openMentorDetail(MentorModel m) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => DetailMentorScreen(mentor: m),
    ));
  }

  Future<void> _openCategorySheet(ProductViewModel vm) async {
    final selected = await showModalBottomSheet<ProductTab>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CategorySheet(active: vm.activeTab),
    );
    if (selected != null) vm.setActiveTab(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Consumer<ProductViewModel>(
          builder: (context, vm, _) {
            return RefreshIndicator(
              color: _purple,
              onRefresh: vm.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(vm)),
                  if (_showSearch) SliverToBoxAdapter(child: _buildSearch(vm)),
                  // Featured: ON-DEMAND MENTORING (gantikan Featured produk lama)
                  if (vm.featuredMentor != null) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 4)),
                    SliverToBoxAdapter(
                      child: FeaturedMentoringCard(
                        spotlightMentor: vm.featuredMentor,
                        totalActive: vm.availableMentorCount,
                        onCta: () => _openMentorDetail(vm.featuredMentor!),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  ],
                  // Sort + Kategori chips
                  SliverToBoxAdapter(child: _buildSortRow(vm)),
                  _buildProductSliver(vm),
                  if (vm.showMentoring) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(child: _buildMentoringSection(vm)),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CartScreen()),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader(ProductViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Produk',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
          ),
          // Cart icon with badge
          CartIconButton(onTap: _openCart),
          const SizedBox(width: 8),
          // Search toggle
          Material(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    vm.onSearchChanged('');
                  }
                });
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  _showSearch ? Icons.close_rounded : Icons.search_rounded,
                  size: 20,
                  color: _muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ProductViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: vm.onSearchChanged,
          style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF1A1B22)),
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            hintStyle: GoogleFonts.manrope(fontSize: 13, color: _muted),
            prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 18),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ===== SORT + KATEGORI ROW =====
  Widget _buildSortRow(ProductViewModel vm) {
    final isFiltered = vm.activeTab != ProductTab.semua;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${vm.showProducts ? vm.gridProducts.length : vm.mentors.length} ${vm.showProducts ? 'produk' : 'mentor'}',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
          ),
          // Sort chips
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // CHIP KATEGORI — dipindah ke urutan pertama (paling kiri)
                  _CategoryChip(
                    label: isFiltered ? vm.activeTab.label : 'Kategori',
                    isActive: isFiltered,
                    onTap: () => _openCategorySheet(vm),
                  ),
                  if (vm.showProducts)
                    for (final s in ProductSort.values)
                      ProductTabChip(
                        label: s.label,
                        isActive: vm.sort == s,
                        onTap: () => vm.setSort(s),
                        variant: ProductChipVariant.sort,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PRODUCT GRID =====
  Widget _buildProductSliver(ProductViewModel vm) {
    if (!vm.showProducts) return const SliverToBoxAdapter(child: SizedBox());

    if (vm.isProductLoading && vm.products.isEmpty) {
      return const SliverToBoxAdapter(child: _LoadingBlock());
    }

    if (vm.productState == ProductSectionState.error && vm.products.isEmpty) {
      return SliverToBoxAdapter(
        child: _ErrorBlock(
          message: vm.productError ?? 'Gagal memuat produk',
          onRetry: vm.retryProducts,
        ),
      );
    }

    final items = vm.gridProducts;
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
          child: _EmptyBlock(label: 'Belum ada produk'));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 230,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductGridCard(
            product: items[index],
            onTap: () => _openProductDetail(items[index]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }

  // ===== MENTORING =====
  Widget _buildMentoringSection(ProductViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MentoringSectionHeader(activeMentorCount: vm.availableMentorCount),
        const SizedBox(height: 14),
        if (vm.isMentorLoading && vm.mentors.isEmpty)
          const _LoadingBlock()
        else if (vm.mentorState == ProductSectionState.error && vm.mentors.isEmpty)
          _ErrorBlock(
            message: vm.mentorError ?? 'Gagal memuat mentor',
            onRetry: vm.retryMentors,
          )
        else if (vm.mentors.isEmpty)
          const _EmptyBlock(label: 'Belum ada mentor tersedia')
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final m in vm.mentors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MentoringCard(
                      mentor: m,
                      onBook: () => _openMentorDetail(m),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ===== Kategori chip (sort row) =====
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _purpleFaint = Color(0x14A600B2);

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? _purple : _muted;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: isActive ? _purpleFaint : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isActive ? _purple : _border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 12, color: fg),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Bottom sheet untuk pilih kategori =====
class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.active});
  final ProductTab active;

  static const Color _navy = Color(0xFF001261);
  static const Color _muted = Color(0xFF757684);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
              Text(
                'Filter Kategori',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih jenis produk yang ingin kamu lihat',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 16),
              for (final tab in ProductTab.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CategoryOption(
                    tab: tab,
                    isActive: tab == active,
                    onTap: () => Navigator.of(context).pop(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final ProductTab tab;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _purpleFaint = Color(0x14A600B2);

  IconData get _icon {
    switch (tab) {
      case ProductTab.semua:
        return Icons.apps_rounded;
      case ProductTab.modul:
        return Icons.menu_book_rounded;
      case ProductTab.kelas:
        return Icons.play_arrow_rounded;
      case ProductTab.bootcamp:
        return Icons.bolt_rounded;
      case ProductTab.mentoring:
        return Icons.groups_rounded;
    }
  }

  String get _label =>
      tab == ProductTab.mentoring ? 'On-Demand Mentoring' : tab.label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _purpleFaint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? _purple : _border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isActive ? _purple : _purpleFaint,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                _icon,
                size: 17,
                color: isActive ? Colors.white : _purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: _purple)
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFFA600B2)),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
                fontSize: 12, color: const Color(0xFF757684)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001261),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.manrope(
              fontSize: 12, color: const Color(0xFF757684)),
        ),
      ),
    );
  }
}
