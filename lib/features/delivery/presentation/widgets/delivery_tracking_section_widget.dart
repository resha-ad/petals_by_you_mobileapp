import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';
import 'package:sprint1_project/features/delivery/presentation/view_model/delivery_view_model.dart';

const _kPrimary = Color(0xFF1B4332);
const _kAccent = Color(0xFFD4A853);
const _kSurface = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A1A1A);
const _kTextMid = Color(0xFF5C5C5C);
const _kTextLight = Color(0xFF9E9E9E);

/// Drop this widget into the Order Detail screen to show live delivery info.
/// Pass the [orderId] and it handles fetching internally.
class DeliveryTrackingSection extends ConsumerStatefulWidget {
  final String orderId;
  const DeliveryTrackingSection({super.key, required this.orderId});

  @override
  ConsumerState<DeliveryTrackingSection> createState() =>
      _DeliveryTrackingSectionState();
}

class _DeliveryTrackingSectionState
    extends ConsumerState<DeliveryTrackingSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(deliveryViewModelProvider(widget.orderId).notifier)
          .loadDelivery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryViewModelProvider(widget.orderId));

    switch (state.status) {
      case DeliveryFetchStatus.initial:
      case DeliveryFetchStatus.loading:
        return _SectionCard(
          title: 'Delivery',
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(
                color: _kPrimary,
                strokeWidth: 2,
              ),
            ),
          ),
        );

      case DeliveryFetchStatus.noDelivery:
        return _SectionCard(
          title: 'Delivery',
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: _kPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delivery will be arranged after order confirmation.',
                  style: TextStyle(fontSize: 13, color: _kTextMid, height: 1.4),
                ),
              ),
            ],
          ),
        );

      case DeliveryFetchStatus.error:
        return _SectionCard(
          title: 'Delivery',
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: _kTextLight, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.errorMessage ?? 'Could not load delivery info.',
                  style: const TextStyle(fontSize: 12, color: _kTextLight),
                ),
              ),
              GestureDetector(
                onTap: () => ref
                    .read(deliveryViewModelProvider(widget.orderId).notifier)
                    .loadDelivery(),
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

      case DeliveryFetchStatus.loaded:
        final delivery = state.delivery!;
        return Column(
          children: [
            // ── Delivery status card ────────────────────────────────────
            _SectionCard(
              title: 'Delivery',
              trailing: state.isFromCache ? const _OfflineBadge() : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status row
                  Row(
                    children: [
                      _StatusDot(status: delivery.status),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery.status.displayLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _statusColor(delivery.status),
                              ),
                            ),
                            if (delivery.estimatedDelivery != null)
                              Text(
                                'Est. delivery: ${_formatDate(delivery.estimatedDelivery!)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kTextLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Recipient & address
                  _DeliveryInfoRow(
                    icon: Icons.person_outline,
                    label: 'Recipient',
                    value:
                        '${delivery.recipientName} • ${delivery.recipientPhone}',
                  ),
                  const SizedBox(height: 8),
                  _DeliveryInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: delivery.address.displayAddress,
                  ),
                  if (delivery.scheduledDate != null) ...[
                    const SizedBox(height: 8),
                    _DeliveryInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Scheduled',
                      value: _formatDate(delivery.scheduledDate!),
                    ),
                  ],
                ],
              ),
            ),

            // ── Tracking timeline ───────────────────────────────────────
            if (delivery.trackingUpdates.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Tracking Updates',
                child: _TrackingTimeline(
                  updates: delivery.trackingUpdates.reversed.toList(),
                ),
              ),
            ],
          ],
        );
    }
  }

  Color _statusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return const Color(0xFFB08800);
      case DeliveryStatus.assigned:
        return const Color(0xFF0077B6);
      case DeliveryStatus.inTransit:
        return const Color(0xFF7209B7);
      case DeliveryStatus.delivered:
        return const Color(0xFF2D6A4F);
      case DeliveryStatus.failed:
        return Colors.red;
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ── Tracking timeline ─────────────────────────────────────────────────────────
class _TrackingTimeline extends StatelessWidget {
  final List<TrackingUpdateEntity> updates;
  const _TrackingTimeline({required this.updates});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(updates.length, (i) {
        final update = updates[i];
        final isFirst = i == 0; // most recent
        final isLast = i == updates.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + dot
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isFirst ? _kPrimary : const Color(0xFFB0C4B1),
                      shape: BoxShape.circle,
                      border: isFirst
                          ? Border.all(color: _kPrimary, width: 2)
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: const Color(0xFFDDD8CF),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                        color: isFirst ? _kTextDark : _kTextMid,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatDateTime(update.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: _kTextLight,
                          ),
                        ),
                        if (update.updatedBy != null) ...[
                          const Text(
                            ' • ',
                            style: TextStyle(fontSize: 11, color: _kTextLight),
                          ),
                          Text(
                            update.updatedBy!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kTextLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} $hour:$min';
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case DeliveryStatus.pending:
        color = const Color(0xFFB08800);
        icon = Icons.hourglass_empty_rounded;
        break;
      case DeliveryStatus.assigned:
        color = const Color(0xFF0077B6);
        icon = Icons.person_pin_circle_outlined;
        break;
      case DeliveryStatus.inTransit:
        color = const Color(0xFF7209B7);
        icon = Icons.delivery_dining_rounded;
        break;
      case DeliveryStatus.delivered:
        color = const Color(0xFF2D6A4F);
        icon = Icons.check_circle_rounded;
        break;
      case DeliveryStatus.failed:
      case DeliveryStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _DeliveryInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DeliveryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _kTextLight),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: _kTextLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: _kTextMid,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD970)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 10, color: Color(0xFFB08800)),
          SizedBox(width: 4),
          Text(
            'Cached',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF7A5E00),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
