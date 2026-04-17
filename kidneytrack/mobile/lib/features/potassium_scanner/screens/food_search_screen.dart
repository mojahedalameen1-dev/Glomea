import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kidneytrack_mobile/core/services/food_nutrition_service.dart';
import 'package:kidneytrack_mobile/core/models/food_item.dart';
import 'package:kidneytrack_mobile/features/potassium_scanner/widgets/kidney_result_modal.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchController = TextEditingController();
  final _foodService = FoodNutritionService();
  List<FoodItem> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    // Optimized Debounce for speed
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (value.trim().isNotEmpty) {
        _onSearch(value.trim());
      } else {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _onSearch(String value) async {
    setState(() => _isLoading = true);
    // Service now handles parallel parallel fetching for maximum speed
    final results = await _foodService.searchByName(value);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(l10n.searchFoods, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearch,
                decoration: InputDecoration(
                  hintText: l10n.searchProductHint,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildSkeletonGrid()
          : _results.isEmpty
              ? _buildEmptyState(l10n)
              : _buildResultsGrid(),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return _FoodGridItem(
          food: _results[index],
          onTap: () => _showDetails(_results[index]),
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _SkeletonItem(),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchController.text.isEmpty ? Icons.fastfood_outlined : Icons.search_off_rounded,
              size: 70,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isEmpty ? l10n.searchAnyFoodOrBrand : l10n.noMatchingResults,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty ? l10n.nutritionalFactsHint : l10n.ensureCorrectSpelling,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showDetails(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KidneyResultModal(food: food),
    );
  }
}

class _FoodGridItem extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _FoodGridItem({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = _getOverallStatus(food);
    final statusColor = status == 2 ? Colors.red : status == 1 ? Colors.orange : Colors.green;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 12,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                          ? Image.network(
                              food.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        boxShadow: [
                          BoxShadow(color: statusColor.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.brand.isNotEmpty ? food.brand : l10n.dataNotAvailable,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(child: Icon(Icons.fastfood, color: Colors.grey[300], size: 40));
  }

  int _getOverallStatus(FoodItem f) {
    int getS(double? v, double w, double d) {
      if (v == null) return 0;
      if (v >= d) return 2;
      if (v >= w) return 1;
      return 0;
    }
    final pS = getS(f.potassium, 150, 200);
    final phS = getS(f.phosphorus, 100, 150);
    final naS = getS(f.sodium, 200, 300);
    if (pS == 2 || phS == 2 || naS == 2) return 2;
    if (pS == 1 || phS == 1 || naS == 1) return 1;
    return 0;
  }
}

class _SkeletonItem extends StatefulWidget {
  @override
  State<_SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<_SkeletonItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Opacity(
            opacity: 0.3 + (0.4 * _controller.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: 100, color: Colors.grey[200]),
                        const SizedBox(height: 8),
                        Container(height: 10, width: 60, color: Colors.grey[200]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
