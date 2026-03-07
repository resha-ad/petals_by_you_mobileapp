import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/presentation/state/cart_state.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/usecases/create_custom_bouquet_usecase.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/state/custom_bouquet_state.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/view_model/custom_bouquet_view_model.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockCreateCustomBouquetUsecase extends Mock
    implements CreateCustomBouquetUsecase {}

// ── Fake CartViewModel ────────────────────────────────────────────────────────
// submit() calls ref.read(cartViewModelProvider.notifier).loadCart()
// so we must override cartViewModelProvider with a no-op fake.
class _FakeCartViewModel extends CartViewModel {
  @override
  CartState build() => const CartState();

  @override
  Future<void> loadCart() async {}
}

void main() {
  late MockCreateCustomBouquetUsecase mockCreateUsecase;
  late ProviderContainer container;

  // ── Fixtures ──────────────────────────────────────────────────────────────
  const tRose = BouquetFlower(
    flowerId: 'rose',
    name: 'Rose',
    count: 3,
    pricePerStem: 120,
  );
  const tTulip = BouquetFlower(
    flowerId: 'tulip',
    name: 'Tulip',
    count: 2,
    pricePerStem: 90,
  );
  const tWrapping = BouquetWrapping(
    id: 'kraft',
    name: 'Kraft Paper',
    price: 50,
    color: '#EFE',
    darkColor: '#5D4',
  );

  setUpAll(() {
    registerFallbackValue(const CustomBouquetEntity());
  });

  setUp(() {
    mockCreateUsecase = MockCreateCustomBouquetUsecase();

    container = ProviderContainer(
      overrides: [
        createCustomBouquetUsecaseProvider.overrideWithValue(mockCreateUsecase),
        // Override cartViewModelProvider so submit()'s loadCart() is a no-op
        cartViewModelProvider.overrideWith(() => _FakeCartViewModel()),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ── initial state ─────────────────────────────────────────────────────────
  group('initial state', () {
    test('should start at step 1 with empty bouquet', () {
      final state = container.read(customBouquetViewModelProvider);
      expect(state.step, 1);
      expect(state.bouquet.flowers, isEmpty);
      expect(state.bouquet.wrapping, isNull);
      expect(state.bouquet.note, '');
      expect(state.bouquet.recipientName, '');
      expect(state.status, CustomBouquetStatus.idle);
      expect(state.errorMessage, isNull);
    });

    test('canProceed should be false at step 1 with no flowers', () {
      expect(container.read(customBouquetViewModelProvider).canProceed, false);
    });
  });

  // ── step navigation ───────────────────────────────────────────────────────
  group('nextStep / prevStep / goToStep', () {
    test('nextStep should not advance when canProceed is false', () {
      // Step 1 with no flowers → canProceed=false
      container.read(customBouquetViewModelProvider.notifier).nextStep();
      expect(container.read(customBouquetViewModelProvider).step, 1);
    });

    test('nextStep should advance when canProceed is true', () {
      // Add a flower so step 1 canProceed=true
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);
      container.read(customBouquetViewModelProvider.notifier).nextStep();
      expect(container.read(customBouquetViewModelProvider).step, 2);
    });

    test('prevStep should go back one step', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);
      container.read(customBouquetViewModelProvider.notifier).nextStep();
      expect(container.read(customBouquetViewModelProvider).step, 2);

      container.read(customBouquetViewModelProvider.notifier).prevStep();
      expect(container.read(customBouquetViewModelProvider).step, 1);
    });

    test('prevStep should not go below step 1', () {
      container.read(customBouquetViewModelProvider.notifier).prevStep();
      expect(container.read(customBouquetViewModelProvider).step, 1);
    });

    test('nextStep should not advance beyond step 5', () {
      container.read(customBouquetViewModelProvider.notifier).goToStep(5);
      container.read(customBouquetViewModelProvider.notifier).nextStep();
      expect(container.read(customBouquetViewModelProvider).step, 5);
    });

    test('goToStep should set exact step', () {
      container.read(customBouquetViewModelProvider.notifier).goToStep(3);
      expect(container.read(customBouquetViewModelProvider).step, 3);
    });
  });

  // ── toggleFlower ──────────────────────────────────────────────────────────
  group('toggleFlower', () {
    test('should add flower when not already selected', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);

      final flowers = container
          .read(customBouquetViewModelProvider)
          .bouquet
          .flowers;
      expect(flowers.length, 1);
      expect(flowers.first.flowerId, 'rose');
    });

    test('should remove flower when already selected', () {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.toggleFlower(tRose);
      expect(
        container.read(customBouquetViewModelProvider).bouquet.flowers.length,
        1,
      );

      vm.toggleFlower(tRose);
      expect(
        container.read(customBouquetViewModelProvider).bouquet.flowers,
        isEmpty,
      );
    });

    test('newly toggled flower should default to count of 3', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);

      final flower = container
          .read(customBouquetViewModelProvider)
          .bouquet
          .flowers
          .first;
      expect(flower.count, 3);
    });

    test('should support multiple different flowers', () {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.toggleFlower(tRose);
      vm.toggleFlower(tTulip);

      final flowers = container
          .read(customBouquetViewModelProvider)
          .bouquet
          .flowers;
      expect(flowers.length, 2);
    });

    test('removing one flower should not affect others', () {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.toggleFlower(tRose);
      vm.toggleFlower(tTulip);
      vm.toggleFlower(tRose); // remove rose

      final flowers = container
          .read(customBouquetViewModelProvider)
          .bouquet
          .flowers;
      expect(flowers.length, 1);
      expect(flowers.first.flowerId, 'tulip');
    });
  });

  // ── setFlowerCount ────────────────────────────────────────────────────────
  group('setFlowerCount', () {
    setUp(() {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);
    });

    test('should update count for the specified flowerId', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .setFlowerCount('rose', 8);

      final flower = container
          .read(customBouquetViewModelProvider)
          .bouquet
          .flowers
          .first;
      expect(flower.count, 8);
    });

    test('should not affect other flowers when updating count', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tTulip);
      container
          .read(customBouquetViewModelProvider.notifier)
          .setFlowerCount('rose', 10);

      final tulip = container
          .read(customBouquetViewModelProvider)
          .bouquet
          .flowers
          .firstWhere((f) => f.flowerId == 'tulip');
      expect(tulip.count, 3); // unchanged
    });
  });

  // ── selectWrapping ────────────────────────────────────────────────────────
  group('selectWrapping', () {
    test('should set wrapping on bouquet', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .selectWrapping(tWrapping);

      expect(
        container.read(customBouquetViewModelProvider).bouquet.wrapping,
        tWrapping,
      );
    });

    test('should replace existing wrapping', () {
      const newWrapping = BouquetWrapping(
        id: 'silk',
        name: 'Silk Ribbon',
        price: 120,
        color: '#FCE',
        darkColor: '#880',
      );
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.selectWrapping(tWrapping);
      vm.selectWrapping(newWrapping);

      expect(
        container.read(customBouquetViewModelProvider).bouquet.wrapping!.id,
        'silk',
      );
    });
  });

  // ── setNote / setRecipientName ────────────────────────────────────────────
  group('setNote', () {
    test('should update note on bouquet', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .setNote('With all my love');

      expect(
        container.read(customBouquetViewModelProvider).bouquet.note,
        'With all my love',
      );
    });

    test('should clear note when set to empty string', () {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.setNote('Something');
      vm.setNote('');

      expect(container.read(customBouquetViewModelProvider).bouquet.note, '');
    });
  });

  group('setRecipientName', () {
    test('should update recipientName on bouquet', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .setRecipientName('Carol');

      expect(
        container.read(customBouquetViewModelProvider).bouquet.recipientName,
        'Carol',
      );
    });
  });

  // ── canProceed per step ───────────────────────────────────────────────────
  group('canProceed', () {
    test('step 1: false when no flowers selected', () {
      container.read(customBouquetViewModelProvider.notifier).goToStep(1);
      expect(container.read(customBouquetViewModelProvider).canProceed, false);
    });

    test('step 1: true when at least one flower selected', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);
      expect(container.read(customBouquetViewModelProvider).canProceed, true);
    });

    test('step 2: true when all flowers have count > 0', () {
      container
          .read(customBouquetViewModelProvider.notifier)
          .toggleFlower(tRose);
      container.read(customBouquetViewModelProvider.notifier).goToStep(2);
      // Default count is 3 → canProceed=true
      expect(container.read(customBouquetViewModelProvider).canProceed, true);
    });

    test('step 3: false when no wrapping selected', () {
      container.read(customBouquetViewModelProvider.notifier).goToStep(3);
      expect(container.read(customBouquetViewModelProvider).canProceed, false);
    });

    test('step 3: true after wrapping selected', () {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.goToStep(3);
      vm.selectWrapping(tWrapping);
      expect(container.read(customBouquetViewModelProvider).canProceed, true);
    });

    test('step 4: always true', () {
      container.read(customBouquetViewModelProvider.notifier).goToStep(4);
      expect(container.read(customBouquetViewModelProvider).canProceed, true);
    });

    test('step 5: always true', () {
      container.read(customBouquetViewModelProvider.notifier).goToStep(5);
      expect(container.read(customBouquetViewModelProvider).canProceed, true);
    });
  });

  // ── submit ────────────────────────────────────────────────────────────────
  group('submit', () {
    test('should return true and set status=success on success', () async {
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Right('new_bouquet_id'));

      final success = await container
          .read(customBouquetViewModelProvider.notifier)
          .submit();

      expect(success, true);
      expect(
        container.read(customBouquetViewModelProvider).status,
        CustomBouquetStatus.success,
      );
    });

    test('should emit submitting → success statuses', () async {
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Right('id'));

      final statuses = <CustomBouquetStatus>[];
      container.listen(
        customBouquetViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(customBouquetViewModelProvider.notifier).submit();

      expect(statuses, [
        CustomBouquetStatus.submitting,
        CustomBouquetStatus.success,
      ]);
    });

    test('should return false and set status=error on failure', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to build a bouquet.',
      );
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final success = await container
          .read(customBouquetViewModelProvider.notifier)
          .submit();

      expect(success, false);
      expect(
        container.read(customBouquetViewModelProvider).status,
        CustomBouquetStatus.error,
      );
    });

    test('should set errorMessage on failure', () async {
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(customBouquetViewModelProvider.notifier).submit();

      expect(
        container.read(customBouquetViewModelProvider).errorMessage,
        'Network error',
      );
    });

    test('should emit submitting → error statuses on failure', () async {
      const failure = ApiFailure(message: 'Err');
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final statuses = <CustomBouquetStatus>[];
      container.listen(
        customBouquetViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(customBouquetViewModelProvider.notifier).submit();

      expect(statuses, [
        CustomBouquetStatus.submitting,
        CustomBouquetStatus.error,
      ]);
    });

    test('should clear previous errorMessage before submitting', () async {
      // First call fails
      const failure = ApiFailure(message: 'First error');
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      await container.read(customBouquetViewModelProvider.notifier).submit();
      expect(
        container.read(customBouquetViewModelProvider).errorMessage,
        'First error',
      );

      // Second call succeeds — error should be cleared
      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Right('id'));
      await container.read(customBouquetViewModelProvider.notifier).submit();

      expect(
        container.read(customBouquetViewModelProvider).errorMessage,
        isNull,
      );
    });

    test('should pass current bouquet to usecase', () async {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.toggleFlower(tRose);
      vm.selectWrapping(tWrapping);
      vm.setNote('Hello');
      vm.setRecipientName('Dan');

      when(
        () => mockCreateUsecase(any()),
      ).thenAnswer((_) async => const Right('id'));

      await vm.submit();

      final captured =
          verify(() => mockCreateUsecase(captureAny())).captured.first
              as CustomBouquetEntity;
      expect(captured.flowers.first.flowerId, 'rose');
      expect(captured.wrapping!.id, 'kraft');
      expect(captured.note, 'Hello');
      expect(captured.recipientName, 'Dan');
    });
  });

  // ── reset ─────────────────────────────────────────────────────────────────
  group('reset', () {
    test('should restore state to initial', () {
      final vm = container.read(customBouquetViewModelProvider.notifier);
      vm.toggleFlower(tRose);
      vm.selectWrapping(tWrapping);
      vm.setNote('Hi');
      vm.goToStep(4);

      vm.reset();

      final state = container.read(customBouquetViewModelProvider);
      expect(state.step, 1);
      expect(state.bouquet.flowers, isEmpty);
      expect(state.bouquet.wrapping, isNull);
      expect(state.bouquet.note, '');
      expect(state.status, CustomBouquetStatus.idle);
    });
  });

  // ── CustomBouquetState unit tests ─────────────────────────────────────────
  group('CustomBouquetState', () {
    test('copyWith should update only specified fields', () {
      const s = CustomBouquetState();
      final updated = s.copyWith(step: 3, status: CustomBouquetStatus.error);
      expect(updated.step, 3);
      expect(updated.status, CustomBouquetStatus.error);
      expect(updated.bouquet, const CustomBouquetEntity()); // unchanged
      expect(updated.errorMessage, isNull);
    });

    test('clearError=true should nullify errorMessage', () {
      const s = CustomBouquetState(errorMessage: 'some error');
      expect(s.copyWith(clearError: true).errorMessage, isNull);
    });

    test('two states with same values should be equal', () {
      const s1 = CustomBouquetState(step: 2);
      const s2 = CustomBouquetState(step: 2);
      expect(s1, s2);
    });

    test('props should contain step, bouquet, status, errorMessage', () {
      const s = CustomBouquetState(step: 2, status: CustomBouquetStatus.error);
      expect(s.props, [
        2,
        const CustomBouquetEntity(),
        CustomBouquetStatus.error,
        null,
      ]);
    });
  });

  // ── CustomBouquetStatus enum ──────────────────────────────────────────────
  group('CustomBouquetStatus', () {
    test('all values should exist', () {
      expect(CustomBouquetStatus.values, contains(CustomBouquetStatus.idle));
      expect(
        CustomBouquetStatus.values,
        contains(CustomBouquetStatus.submitting),
      );
      expect(CustomBouquetStatus.values, contains(CustomBouquetStatus.success));
      expect(CustomBouquetStatus.values, contains(CustomBouquetStatus.error));
    });
  });
}
