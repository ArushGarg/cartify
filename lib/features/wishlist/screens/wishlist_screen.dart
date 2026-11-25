import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../products/screens/product_detail_screen.dart';
import '../cubit/wishlist_cubit.dart';

const _navy = Color(0xFF0F1729);
const _card = Color(0xFF1A2540);

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Wishlist',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      Text('${state.count} saved',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: state.items.isEmpty
                      ? const _EmptyWishlist()
                      : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.60,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final product = state.items[i];
                      return ProductCard(
                        product: product,
                        onOpen: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration:
            const BoxDecoration(color: _card, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border_rounded,
                size: 52, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text('Nothing saved yet',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Tap the heart on any product to save it',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}