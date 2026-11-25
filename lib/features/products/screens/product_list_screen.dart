import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../auth/screens/profile_screen.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/screens/cart_screen.dart';
import '../../wishlist/cubit/wishlist_cubit.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import '../cubit/product_cubit.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

const _navy = Color(0xFF0F1729);
const _card = Color(0xFF1A2540);

const _categoryEmoji = {
  'All': '✨',
  'Shoes': '👟',
  'Clothing': '👕',
  'Electronics': '🎧',
  'Bags': '👜',
  'Accessories': '⌚',
};

void _openProduct(BuildContext context, Product product) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
  );
}

// ─── Shell with floating pill nav ─────────────────────────────────────────────

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // select() = rebuild this widget only when these two numbers change
    final cartCount = context.select((CartCubit c) => c.state.itemCount);
    final wishCount = context.select((WishlistCubit c) => c.state.count);

    final items = <(IconData, IconData, String, int)>[
      (Icons.home_outlined, Icons.home_rounded, 'Home', 0),
      (Icons.search_rounded, Icons.search_rounded, 'Search', 0),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Wishlist',
      wishCount),
      (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Bag',
      cartCount),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 0),
    ];

    return Scaffold(
      backgroundColor: _navy,
      body: IndexedStack(
        index: _index,
        children: [
          _HomeTab(onSearchTap: () => setState(() => _index = 1)),
          const SearchScreen(),
          const WishlistScreen(),
          const CartScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavItem(
                  icon: items[i].$1,
                  activeIcon: items[i].$2,
                  label: items[i].$3,
                  badge: items[i].$4,
                  selected: _index == i,
                  onTap: () => setState(() => _index = i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? activeIcon : icon,
                    color: selected ? Colors.white : Colors.white38, size: 24),
                if (badge > 0)
                  Positioned(
                    right: -7,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: _card, width: 1.5),
                      ),
                      child: Text('$badge',
                          style: TextStyle(
                              color: selected ? AppTheme.primary : Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Home tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onSearchTap});

  final VoidCallback onSearchTap;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state.status == ProductStatus.initial ||
            state.status == ProductStatus.loading) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (state.status == ProductStatus.failure) {
          return _ErrorView(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: () => context.read<ProductCubit>().load(),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            const SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: _BannerCarousel()),
            ),
            SliverToBoxAdapter(child: _categories(context, state)),
            SliverToBoxAdapter(child: _trending(context, state)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('All Products',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text('${state.visible.length} items',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final product = state.visible[i];
                    return ProductCard(
                      product: product,
                      onOpen: () => _openProduct(context, product),
                    );
                  },
                  childCount: state.visible.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting,
                      style:
                      const TextStyle(color: Colors.white60, fontSize: 14)),
                  const Text('Arush 👋',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ],
              ),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _card, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 24),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: _card, borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.white38, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Search for clothes, shoes...',
                        style: TextStyle(color: Colors.white38, fontSize: 14)),
                  ),
                  Icon(Icons.mic_outlined, color: AppTheme.primary, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categories(BuildContext context, ProductState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categories',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: state.categories.length,
              itemBuilder: (context, i) {
                final cat = state.categories[i];
                return _CategoryChip(
                  emoji: _categoryEmoji[cat] ?? '🛍️',
                  label: cat,
                  selected: cat == state.selectedCategory,
                  onTap: () => context.read<ProductCubit>().selectCategory(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _trending(BuildContext context, ProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text('Trending Now 🔥',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20),
            itemCount: state.featured.length,
            itemBuilder: (context, i) {
              final product = state.featured[i];
              return GestureDetector(
                onTap: () => _openProduct(context, product),
                child: Container(
                  width: 155,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                      color: _card, borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFF243050)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800)),
                                const Icon(Icons.star_rounded,
                                    color: AppTheme.star, size: 15),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary : Colors.white10,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(height: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppTheme.primary : Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 56),
            const SizedBox(height: 16),
            const Text('Could not load products',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Banner carousel ──────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const _banners = [
    ('Monsoon Fiesta', 'Fresh styles, bold looks',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800'),
    ('Summer Edit', 'Up to 60% off on new arrivals',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'),
    ('New Arrivals', 'Shop the latest trends',
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800'),
  ];

  final _controller = PageController();
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_controller.hasClients) return;
      _controller.animateToPage(
        (_current + 1) % _banners.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) {
              final (title, subtitle, image) = _banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: _card),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text(subtitle,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Shop Now →',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _current == i ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}