import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../payment/bloc/checkout_bloc.dart';
import '../../payment/screens/checkout_screen.dart';
import '../cubit/cart_cubit.dart';
import '../models/cart_item_model.dart';

const _navy = Color(0xFF0F1729);
const _card = Color(0xFF1A2540);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _checkout(BuildContext context) {
    final items = context.read<CartCubit>().state.items;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          // CheckoutBloc lives only as long as the checkout route
          create: (_) => getIt<CheckoutBloc>()..add(CheckoutStarted(items)),
          child: const CheckoutScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Back arrow only when this screen was opened via "Buy Now" (its own route)
    final isOwnRoute = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      if (isOwnRoute)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                        ),
                      const Text('My Bag',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text('${state.itemCount} items',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isEmpty
                      ? const _EmptyBag()
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: state.items.length,
                    itemBuilder: (context, i) =>
                        _CartRow(item: state.items[i]),
                  ),
                ),
                if (!state.isEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    decoration: const BoxDecoration(
                      color: _card,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14)),
                            Text('₹${state.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: AppTheme.primaryShadow,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () => _checkout(context),
                              child: const Center(
                                child: Text('Proceed to Checkout',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();
    final id = item.product.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  width: 72, height: 72, color: const Color(0xFF243050)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(item.product.category,
                    style:
                    const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 8),
                Text('₹${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => cart.remove(id),
                child: const Icon(Icons.delete_outline,
                    color: Colors.white38, size: 20),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF243050),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepButton(
                        icon: Icons.remove, onTap: () => cart.decrement(id)),
                    Text('${item.quantity}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    _StepButton(
                        icon: Icons.add, onTap: () => cart.increment(id)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: AppTheme.primary, size: 18),
    ),
  );
}

class _EmptyBag extends StatelessWidget {
  const _EmptyBag();

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
            child: const Icon(Icons.shopping_bag_outlined,
                size: 52, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text('Your bag is empty',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Items you add will show up here',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}