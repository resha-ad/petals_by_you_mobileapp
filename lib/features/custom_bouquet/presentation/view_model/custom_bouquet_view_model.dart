import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/usecases/create_custom_bouquet_usecase.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/state/custom_bouquet_state.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';

final customBouquetViewModelProvider =
    NotifierProvider<CustomBouquetViewModel, CustomBouquetState>(
      CustomBouquetViewModel.new,
    );

class CustomBouquetViewModel extends Notifier<CustomBouquetState> {
  late final CreateCustomBouquetUsecase _createUsecase;

  @override
  CustomBouquetState build() {
    _createUsecase = ref.read(createCustomBouquetUsecaseProvider);
    return const CustomBouquetState();
  }

  void nextStep() {
    if (state.step < 5 && state.canProceed) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void prevStep() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void goToStep(int s) => state = state.copyWith(step: s);

  // ── Flower selection ──────────────────────────────────────────────────────
  void toggleFlower(BouquetFlower flower) {
    final flowers = List<BouquetFlower>.from(state.bouquet.flowers);
    final idx = flowers.indexWhere((f) => f.flowerId == flower.flowerId);
    if (idx >= 0) {
      flowers.removeAt(idx);
    } else {
      flowers.add(flower.copyWith(count: 3));
    }
    state = state.copyWith(bouquet: state.bouquet.copyWith(flowers: flowers));
  }

  void setFlowerCount(String flowerId, int count) {
    final flowers = state.bouquet.flowers
        .map((f) => f.flowerId == flowerId ? f.copyWith(count: count) : f)
        .toList();
    state = state.copyWith(bouquet: state.bouquet.copyWith(flowers: flowers));
  }

  void selectWrapping(BouquetWrapping wrapping) {
    state = state.copyWith(bouquet: state.bouquet.copyWith(wrapping: wrapping));
  }

  void setNote(String note) {
    state = state.copyWith(bouquet: state.bouquet.copyWith(note: note));
  }

  void setRecipientName(String name) {
    state = state.copyWith(
      bouquet: state.bouquet.copyWith(recipientName: name),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<bool> submit() async {
    state = state.copyWith(
      status: CustomBouquetStatus.submitting,
      clearError: true,
    );
    final result = await _createUsecase(state.bouquet);
    bool success = false;
    result.fold(
      (failure) => state = state.copyWith(
        status: CustomBouquetStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        success = true;
        state = state.copyWith(status: CustomBouquetStatus.success);
        // Refresh cart in background
        ref.read(cartViewModelProvider.notifier).loadCart();
      },
    );
    return success;
  }

  void reset() => state = const CustomBouquetState();
}
