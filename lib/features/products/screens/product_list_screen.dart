import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../auth/screens/profile_screen.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1729),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          SearchScreen(),
          WishlistScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Consumer2<CartProvider, WishlistProvider>(
          builder: (context, cart, wishlist, _) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2540),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', isSelected: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: Icons.search_rounded, label: 'Search', isSelected: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
                _NavItemBadge(icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded, label: 'Wishlist', isSelected: _currentIndex == 2, badge: wishlist.count, onTap: () => setState(() => _currentIndex = 2)),
                _NavItemBadge(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Bag', isSelected: _currentIndex == 3, badge: cart.itemCount, onTap: () => setState(() => _currentIndex = 3)),
                _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', isSelected: _currentIndex == 4, onTap: () => setState(() => _currentIndex = 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Nav Item Badge ───────────────────────────────────────────────────────────

class _NavItemBadge extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final int badge;
  final VoidCallback onTap;
  const _NavItemBadge({required this.icon, required this.activeIcon, required this.label, required this.isSelected, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isSelected ? activeIcon : icon, color: isSelected ? Colors.white : Colors.white38, size: 24),
                if (badge > 0)
                  Positioned(
                    right: -7, top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1A2540), width: 1.5),
                      ),
                      child: Text('$badge', style: TextStyle(color: isSelected ? AppTheme.primary : Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getGreeting(), style: const TextStyle(color: Colors.white60, fontSize: 14)),
                            const Text('Arush 👋', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF1A2540), borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                            ),
                            Positioned(
                              right: 10, top: 10,
                              child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tappable search bar
                    GestureDetector(
                      onTap: () {
                        final scaffold = context.findAncestorStateOfType<_ProductListScreenState>();
                        if (scaffold != null) {
                          scaffold.setState(() => scaffold._currentIndex = 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFF1A2540), borderRadius: BorderRadius.circular(16)),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.white38, size: 22),
                            SizedBox(width: 10),
                            Expanded(child: Text('Search for clothes, shoes...', style: TextStyle(color: Colors.white38, fontSize: 14))),
                            Icon(Icons.mic_outlined, color: AppTheme.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner
            const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(bottom: 24), child: _DarkBannerCarousel())),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('See all', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          _DarkCategoryIcon(emoji: '👗', label: 'Dresses', isSelected: true),
                          _DarkCategoryIcon(emoji: '👕', label: 'Tops'),
                          _DarkCategoryIcon(emoji: '👖', label: 'Bottoms'),
                          _DarkCategoryIcon(emoji: '👟', label: 'Shoes'),
                          _DarkCategoryIcon(emoji: '👜', label: 'Bags'),
                          _DarkCategoryIcon(emoji: '⌚', label: 'Accessories'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trending Now
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trending Now 🔥', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('View all', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20),
                      itemCount: provider.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = provider.featuredProducts[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                          child: Container(
                            width: 155,
                            margin: const EdgeInsets.only(right: 14),
                            decoration: BoxDecoration(color: const Color(0xFF1A2540), borderRadius: BorderRadius.circular(20)),
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: const Color(0xFF243050)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                                          const Icon(Icons.star_rounded, color: AppTheme.star, size: 15),
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
              ),
            ),

            // All Products header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('All Products', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('${provider.products.length} items', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            ),

            // Product Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = provider.products[index];
                    return _DarkProductCardWithPreview(
                      product: product,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                    );
                  },
                  childCount: provider.products.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Banner Carousel ──────────────────────────────────────────────────────────

class _DarkBannerCarousel extends StatefulWidget {
  const _DarkBannerCarousel();

  @override
  State<_DarkBannerCarousel> createState() => _DarkBannerCarouselState();
}

class _DarkBannerCarouselState extends State<_DarkBannerCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<Map<String, String>> banners = const [
    {'title': 'Monsoon Fiesta', 'subtitle': 'Fresh styles, bold looks', 'image': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800'},
    {'title': 'Summer Edit', 'subtitle': 'Up to 60% off on new arrivals', 'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800'},
    {'title': 'New Arrivals', 'subtitle': 'Shop the latest trends', 'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final next = (_current + 1) % banners.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
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
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: banner['image']!, fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF1A2540))),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20, left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(banner['title']!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text(banner['subtitle']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Shop Now →', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
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
          children: List.generate(banners.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _current == i ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(color: _current == i ? Colors.white : Colors.white24, borderRadius: BorderRadius.circular(3)),
          )),
        ),
      ],
    );
  }
}

// ─── Category Icon ────────────────────────────────────────────────────────────

class _DarkCategoryIcon extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  const _DarkCategoryIcon({required this.emoji, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.15) : const Color(0xFF1A2540),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: AppTheme.primary, width: 2) : Border.all(color: Colors.white10, width: 1),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: 7),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primary : Colors.white54)),
        ],
      ),
    );
  }
}

// ─── Dark Product Card ────────────────────────────────────────────────────────

class _DarkProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  const _DarkProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final originalPrice = product.price * 1.4;
    final discountPercent = ((originalPrice - product.price) / originalPrice * 100).round();
    final rating = '4.${(product.stock % 5 + 5)}';

    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A2540), borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image — fixed height
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFF243050)),
                    errorWidget: (_, __, ___) => Container(color: const Color(0xFF243050), child: const Icon(Icons.image_outlined, color: Colors.white24)),
                  ),
                ),
                // NEW badge
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
                // Wishlist
                Positioned(
                  top: 8, right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) => GestureDetector(
                      onTap: () => wishlist.toggleWishlist(product),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          wishlist.isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: wishlist.isWishlisted(product.id) ? AppTheme.primary : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                // Rating pill
                Positioned(
                  bottom: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.star, size: 12),
                        const SizedBox(width: 3),
                        Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.category, style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        Row(
                          children: [
                            Text('₹${originalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.white38, decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 4),
                            Text('$discountPercent%', style: const TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, _) => GestureDetector(
                        onTap: () {
                          cart.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${product.name} added to bag'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.primary,
                          ));
                        },
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Card With Long Press Preview ─────────────────────────────────────

class _DarkProductCardWithPreview extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  const _DarkProductCardWithPreview({required this.product, required this.onTap});

  void _showPreview(BuildContext context) {
    HapticFeedback.mediumImpact();
    final originalPrice = product.price * 1.4;
    final discountPercent = ((originalPrice - product.price) / originalPrice * 100).round();

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: true,
        pageBuilder: (ctx, animation, _) {
          return GestureDetector(
            onTap: () => Navigator.pop(ctx),
            behavior: HitTestBehavior.opaque,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2540),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 50, offset: const Offset(0, 20))],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 14, left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
                                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                Positioned(
                                  top: 12, right: 12,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(ctx),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12, right: 56,
                                  child: Consumer<WishlistProvider>(
                                    builder: (context, wishlist, _) => GestureDetector(
                                      onTap: () => wishlist.toggleWishlist(product),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Icon(
                                          wishlist.isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border,
                                          size: 18,
                                          color: wishlist.isWishlisted(product.id) ? AppTheme.primary : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12, left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppTheme.star, size: 14),
                                        const SizedBox(width: 3),
                                        Text('4.${(product.stock % 5 + 5)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text(product.category, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                                          Row(
                                            children: [
                                              Text('₹${originalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.white38, decoration: TextDecoration.lineThrough)),
                                              const SizedBox(width: 6),
                                              Text('$discountPercent% off', style: const TextStyle(fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Consumer<CartProvider>(
                                        builder: (context, cart, _) => GestureDetector(
                                          onTap: () {
                                            cart.addToCart(product);
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text('${product.name} added to bag'),
                                              duration: const Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: AppTheme.primary,
                                            ));
                                          },
                                          child: Container(
                                            width: 52, height: 52,
                                            decoration: BoxDecoration(
                                              gradient: AppTheme.primaryGradient,
                                              shape: BoxShape.circle,
                                              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6))],
                                            ),
                                            child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      onTap();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.07),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: const Center(child: Text('View Full Details →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showPreview(context),
      child: _DarkProductCard(product: product, onTap: onTap),
    );
  }
}