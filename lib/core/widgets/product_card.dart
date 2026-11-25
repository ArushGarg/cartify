import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/cart/cubit/cart_cubit.dart';
import '../../features/products/models/product_model.dart';
import '../../features/wishlist/cubit/wishlist_cubit.dart';
import '../theme/app_theme.dart';

const _cardColor = Color(0xFF1A2540);

// Display-only helpers (the DB has no rating / MRP columns yet)
String ratingOf(Product p) => '4.${p.stock % 5 + 5}';
double mrpOf(Product p) => p.price * 1.4;
int discountPercentOf(Product p) =>
    ((mrpOf(p) - p.price) / mrpOf(p) * 100).round();

SnackBar bagSnackBar(Product p) => SnackBar(
  content: Text('${p.name} added to bag'),
  duration: const Duration(seconds: 1),
  behavior: SnackBarBehavior.floating,
  backgroundColor: AppTheme.primary,
);

// ─── Card ─────────────────────────────────────────────────────────────────────

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onOpen});

  final Product product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      onLongPress: () =>
          showProductPreview(context, product: product, onOpen: onOpen),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: const Color(0xFF243050)),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF243050),
                        child: const Icon(Icons.image_outlined,
                            color: Colors.white24),
                      ),
                    ),
                  ),
                  const Positioned(top: 10, left: 10, child: _NewBadge()),
                  Positioned(
                      top: 8,
                      right: 8,
                      child: WishlistButton(product: product)),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _RatingPill(rating: ratingOf(product)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    maxLines: 1,
                    style:
                    const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PriceBlock(product: product),
                      _GradientCircleButton(
                        icon: Icons.add,
                        size: 36,
                        onTap: () {
                          context.read<CartCubit>().add(product);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(bagSnackBar(product));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

/// Only rebuilds when THIS product's wishlist status changes (BlocSelector)
class WishlistButton extends StatelessWidget {
  const WishlistButton({super.key, required this.product, this.iconSize = 15});

  final Product product;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WishlistCubit, WishlistState, bool>(
      selector: (state) => state.isWishlisted(product.id),
      builder: (context, wished) => GestureDetector(
        onTap: () => context.read<WishlistCubit>().toggle(product),
        child: Container(
          padding: EdgeInsets.all(iconSize / 2),
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
          child: Icon(
            wished ? Icons.favorite : Icons.favorite_border,
            size: iconSize,
            color: wished ? AppTheme.primary : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      gradient: AppTheme.primaryGradient,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text('NEW',
        style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700)),
  );
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, this.large = false});

  final String rating;
  final bool large;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 8, vertical: large ? 5 : 4),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            color: AppTheme.star, size: large ? 14 : 12),
        const SizedBox(width: 3),
        Text(rating,
            style: TextStyle(
                fontSize: large ? 12 : 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      ],
    ),
  );
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.product,
    this.priceSize = 16,
    this.smallSize = 11,
    this.discountSuffix = '%',
  });

  final Product product;
  final double priceSize;
  final double smallSize;
  final String discountSuffix;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('₹${product.price.toStringAsFixed(0)}',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: priceSize)),
      Row(
        children: [
          Text('₹${mrpOf(product).toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: smallSize,
                  color: Colors.white38,
                  decoration: TextDecoration.lineThrough)),
          const SizedBox(width: 4),
          Text('${discountPercentOf(product)}$discountSuffix',
              style: TextStyle(
                  fontSize: smallSize,
                  color: AppTheme.success,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    ],
  );
}

class _GradientCircleButton extends StatelessWidget {
  const _GradientCircleButton(
      {required this.icon, required this.size, required this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.55),
    ),
  );
}

// ─── Long-press preview (peek) ────────────────────────────────────────────────

void showProductPreview(
    BuildContext context, {
      required Product product,
      required VoidCallback onOpen,
    }) {
  HapticFeedback.mediumImpact();
  final messenger = ScaffoldMessenger.of(context);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.8),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, _, __) => Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(ctx),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // taps on the card itself must not dismiss
            child: _ProductPreview(
              product: product,
              onClose: () => Navigator.pop(ctx),
              onOpen: () {
                Navigator.pop(ctx);
                onOpen();
              },
              onAddToBag: () {
                ctx.read<CartCubit>().add(product);
                Navigator.pop(ctx);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(bagSnackBar(product));
              },
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: child,
      ),
    ),
  );
}

class _ProductPreview extends StatelessWidget {
  const _ProductPreview({
    required this.product,
    required this.onClose,
    required this.onOpen,
    required this.onAddToBag,
  });

  final Product product;
  final VoidCallback onClose;
  final VoidCallback onOpen;
  final VoidCallback onAddToBag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                    imageUrl: product.imageUrl, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              const Positioned(top: 14, left: 14, child: _NewBadge()),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child:
                    const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 56,
                child: WishlistButton(product: product, iconSize: 18),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: _RatingPill(rating: ratingOf(product), large: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text(product.category,
                    style:
                    const TextStyle(color: Colors.white38, fontSize: 13)),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PriceBlock(
                      product: product,
                      priceSize: 24,
                      smallSize: 13,
                      discountSuffix: '% off',
                    ),
                    _GradientCircleButton(
                      icon: Icons.add_shopping_cart_rounded,
                      size: 52,
                      onTap: onAddToBag,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onOpen,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Text('View Full Details →',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}