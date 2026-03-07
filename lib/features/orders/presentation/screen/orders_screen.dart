import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/app/themes/app_colors.dart';
import 'package:sprint1_project/features/orders/presentation/screen/orders_detail_screen.dart';
import 'package:sprint1_project/features/orders/presentation/view_model/orders_view_model.dart';
import 'package:sprint1_project/features/orders/presentation/widgets/orders_widgets.dart';

const _kPrimary = Color(0xFF1B4332);

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersViewModelProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    final isOffline = state.isFromCache;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: RefreshIndicator(
          color: _kPrimary,
          backgroundColor: AppColors.surface(context),
          onRefresh: () =>
              ref.read(ordersViewModelProvider.notifier).loadOrders(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: OrdersHeader(onBack: () => Navigator.pop(context)),
              ),
              if (isOffline)
                SliverToBoxAdapter(
                  child: _OfflineBanner(
                    onRetry: () =>
                        ref.read(ordersViewModelProvider.notifier).loadOrders(),
                  ),
                ),
              if (state.status == OrdersStatus.loading && state.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _kPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (state.status == OrdersStatus.error &&
                  state.orders.isEmpty)
                SliverFillRemaining(
                  child: _ErrorState(
                    message: state.errorMessage,
                    onRetry: () =>
                        ref.read(ordersViewModelProvider.notifier).loadOrders(),
                  ),
                )
              else if (state.orders.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => OrderCard(
                        order: state.orders[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailScreen(orderId: state.orders[i].id),
                          ),
                        ),
                      ),
                      childCount: state.orders.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _OfflineBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.offlineBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.offlineBorder(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: Color(0xFFB08800),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline — showing saved orders',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.isDark(context)
                    ? const Color(0xFFCCAA00)
                    : const Color(0xFF7A5E00),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                color: _kPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: AppColors.textHint(context),
          ),
          const SizedBox(height: 18),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your order history will appear here',
            style: TextStyle(fontSize: 13, color: AppColors.textHint(context)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.iconContainer(context, const Color(0xFFE8F4EE)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: Color(0xFF52B788),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Couldn\'t load orders',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message ?? 'Check your connection',
            style: TextStyle(fontSize: 13, color: AppColors.textHint(context)),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
