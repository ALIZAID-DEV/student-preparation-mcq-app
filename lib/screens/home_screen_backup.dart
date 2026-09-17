import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/data_loader_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';
import '../constants/category_constants.dart';
import 'subcategory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DataLoaderService.loadCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
        _error = categories.isEmpty ? 'No categories found.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load categories.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftScaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(
                    message: _error!,
                    onRetry: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadCategories();
                    },
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.ink,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'M I C K E Y preparations',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.line),
                                    ),
                                    child: Text(
                                      '${_categories.length} exams',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: AppColors.muted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const SectionHeader(
                                eyebrow: 'Practice smarter',
                                title: 'Choose your exam track',
                                subtitle:
                                    '100+ practice MCQs in every section — pick a path and start.',
                              ),
                              const SizedBox(height: 22),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                        sliver: SliverList.separated(
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return CategoryTile(
                              index: index,
                              title: category.categoryTitle,
                              description: category.description,
                              icon: CategoryConstants.getIconData(category.icon),
                              tint: CategoryConstants.getLightTint(index),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SubCategoryScreen(category: category),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 42, color: AppColors.muted),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
