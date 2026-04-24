// ============================================
// FILE: lib/views/competition_screen/competition_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../viewmodels/competition_viewmodel.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/competition_card.dart';
import '../../widgets/pagination_controls.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionViewModel>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CompetitionViewModel>(
          builder: (context, vm, _) {
            return RefreshIndicator(
              color: AppColors.secondary,
              onRefresh: () => vm.fetchCompetitions(page: vm.currentPage),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSearchField(vm)),
                  SliverToBoxAdapter(child: _buildCategoryChips(vm)),
                  _buildBodySliver(vm),
                  SliverToBoxAdapter(child: _buildPaginationFooter(vm)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info Lomba',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Temukan kompetisi yang tepat dan asah\nkemampuan analisismu. Jadilah yang terbaik.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(CompetitionViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.formFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: vm.onSearchChanged,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari nama kompetisi...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(CompetitionViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: vm.categories.length,
          itemBuilder: (context, index) {
            final category = vm.categories[index];
            return CategoryChip(
              label: category,
              isActive: vm.activeCategory == category,
              onTap: () => vm.onCategoryChanged(category),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodySliver(CompetitionViewModel vm) {
    if (vm.isLoading && vm.competitions.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
        ),
      );
    }

    if (vm.hasError && vm.competitions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildError(vm),
      );
    }

    if (vm.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmpty(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      sliver: SliverList.separated(
        itemCount: vm.competitions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return CompetitionCard(competition: vm.competitions[index]);
        },
      ),
    );
  }

  Widget _buildPaginationFooter(CompetitionViewModel vm) {
    if (vm.competitions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: PaginationControls(
        currentPage: vm.currentPage,
        lastPage: vm.lastPage,
        onPageSelected: vm.goToPage,
      ),
    );
  }

  Widget _buildError(CompetitionViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Text(
            vm.errorMessage ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: vm.retry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Text(
            'Belum ada lomba yang cocok dengan pencarian atau filter kamu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
