import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/orders_cubit.dart';
import '../models/order_model.dart';

const _navy = Color(0xFF0F1729);
const _card = Color(0xFF1A2540);

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // read() is safe in initState; the Cubit's stream delivers asynchronously
    context.read<OrdersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('My Orders',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final firstLoad = state.orders.isEmpty &&
              (state.status == OrdersStatus.initial ||
                  state.status == OrdersStatus.loading);
          if (firstLoad) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (state.status == OrdersStatus.failure && state.orders.isEmpty) {
            return _Message(
              icon: Icons.wifi_off_rounded,
              title: 'Could not load orders',
              subtitle: state.errorMessage ?? 'Check your connection',
              actionLabel: 'Try Again',
              onAction: () => context.read<OrdersCubit>().load(),
            );
          }

          if (state.orders.isEmpty) {
            return const _Message(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Your completed orders will appear here',
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            backgroundColor: _card,
            onRefresh: () => context.read<OrdersCubit>().load(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, i) => _OrderCard(order: state.orders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  (Color, IconData) get _status => switch (order.status) {
    'paid' => (AppTheme.success, Icons.check_circle_outline),
    'pending' => (const Color(0xFFF39C12), Icons.access_time),
    'failed' => (AppTheme.error, Icons.cancel_outlined),
    _ => (Colors.white54, Icons.info_outline),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _status;
    final d = order.createdAt.toLocal();
    final date = '${d.day} ${_months[d.month - 1]} ${d.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration:
      BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(order.status.toUpperCase(),
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount paid',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('₹${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              Text(date,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          if (order.razorpayPaymentId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Payment ID: ${order.razorpayPaymentId}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration:
              const BoxDecoration(color: _card, shape: BoxShape.circle),
              child: Icon(icon, size: 52, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 13)),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(actionLabel!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}