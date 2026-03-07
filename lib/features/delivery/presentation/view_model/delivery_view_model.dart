import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';
import 'package:sprint1_project/features/delivery/domain/usecases/delivery_usecase.dart';

// ── State ─────────────────────────────────────────────────────────────────────
enum DeliveryFetchStatus { initial, loading, loaded, noDelivery, error }

class DeliveryState extends Equatable {
  final DeliveryFetchStatus status;
  final DeliveryEntity? delivery;
  final String? errorMessage;
  final bool isFromCache;

  const DeliveryState({
    this.status = DeliveryFetchStatus.initial,
    this.delivery,
    this.errorMessage,
    this.isFromCache = false,
  });

  DeliveryState copyWith({
    DeliveryFetchStatus? status,
    DeliveryEntity? delivery,
    bool clearDelivery = false,
    String? errorMessage,
    bool clearError = false,
    bool? isFromCache,
  }) {
    return DeliveryState(
      status: status ?? this.status,
      delivery: clearDelivery ? null : (delivery ?? this.delivery),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, delivery, errorMessage, isFromCache];
}

// ── ViewModel ─────────────────────────────────────────────────────────────────
// Keyed by orderId so each order detail screen gets its own delivery state.
final deliveryViewModelProvider =
    StateNotifierProvider.family<DeliveryViewModel, DeliveryState, String>(
      (ref, orderId) => DeliveryViewModel(ref, orderId),
    );

class DeliveryViewModel extends StateNotifier<DeliveryState> {
  final Ref _ref;
  final String _orderId;

  late final GetDeliveryByOrderIdUsecase _getDelivery;
  late final INetworkInfo _networkInfo;

  DeliveryViewModel(this._ref, this._orderId) : super(const DeliveryState()) {
    _getDelivery = _ref.read(getDeliveryByOrderIdUsecaseProvider);
    _networkInfo = _ref.read(networkInfoProvider);
  }

  Future<void> loadDelivery() async {
    state = state.copyWith(
      status: DeliveryFetchStatus.loading,
      clearDelivery: true,
      clearError: true,
    );

    final isOnline = await _networkInfo.isConnected;
    final result = await _getDelivery(_orderId);

    result.fold(
      (failure) {
        // "no delivery yet" is a soft non-error — show placeholder
        if (failure.message.contains('No delivery info available') ||
            failure.message.contains('not cached')) {
          state = state.copyWith(
            status: DeliveryFetchStatus.noDelivery,
            clearError: true,
          );
        } else {
          state = state.copyWith(
            status: DeliveryFetchStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (delivery) => state = state.copyWith(
        status: DeliveryFetchStatus.loaded,
        delivery: delivery,
        isFromCache: !isOnline,
        clearError: true,
      ),
    );
  }
}
