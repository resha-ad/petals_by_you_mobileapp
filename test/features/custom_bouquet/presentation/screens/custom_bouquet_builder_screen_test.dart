import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/cart/presentation/state/cart_state.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/screens/custom_bouquet_builder_screen.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/state/custom_bouquet_state.dart';
import 'package:sprint1_project/features/custom_bouquet/presentation/view_model/custom_bouquet_view_model.dart';

// ── Fake view models ──────────────────────────────────────────────────────────

class _FakeCustomBouquetViewModel extends CustomBouquetViewModel {
  final CustomBouquetState _presetState;
  _FakeCustomBouquetViewModel(this._presetState);

  @override
  CustomBouquetState build() => _presetState;

  @override
  void nextStep() {}
  @override
  void prevStep() {}
  @override
  void goToStep(int s) {}
  @override
  void toggleFlower(BouquetFlower flower) {}
  @override
  void setFlowerCount(String flowerId, int count) {}
  @override
  void selectWrapping(BouquetWrapping wrapping) {}
  @override
  void setNote(String note) {}
  @override
  void setRecipientName(String name) {}
  @override
  Future<bool> submit() async => false;
  @override
  void reset() {}
}

class _FakeCartViewModel extends CartViewModel {
  @override
  CartState build() => const CartState();
  @override
  Future<void> loadCart() async {}
}

// ── Fixtures ──────────────────────────────────────────────────────────────────
const tRose = BouquetFlower(
  flowerId: 'rose',
  name: 'Rose',
  count: 5,
  pricePerStem: 120,
);
const tTulip = BouquetFlower(
  flowerId: 'tulip',
  name: 'Tulip',
  count: 3,
  pricePerStem: 90,
);
const tWrapping = BouquetWrapping(
  id: 'kraft',
  name: 'Kraft Paper',
  price: 50,
  color: '#EFE',
  darkColor: '#5D4',
);

// ── Helper ────────────────────────────────────────────────────────────────────
Widget buildScreen(CustomBouquetState state) {
  return ProviderScope(
    overrides: [
      customBouquetViewModelProvider.overrideWith(
        () => _FakeCustomBouquetViewModel(state),
      ),
      cartViewModelProvider.overrideWith(() => _FakeCartViewModel()),
    ],
    child: const MaterialApp(home: CustomBouquetBuilderScreen()),
  );
}

void main() {
  // ── Header ─────────────────────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Header', () {
    testWidgets('should show "Build Your Bouquet" title', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState()));
      await tester.pump();

      expect(find.text('Build Your Bouquet'), findsOneWidget);
    });

    testWidgets('should show step label "Flowers" at step 1', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.text('Step 1 of 5 · Flowers'), findsOneWidget);
    });

    testWidgets('should show step label "Count" at step 2', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(flowers: const [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 2 of 5 · Count'), findsOneWidget);
    });

    testWidgets('should show step label "Wrapping" at step 3', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 3)));
      await tester.pump();

      expect(find.text('Step 3 of 5 · Wrapping'), findsOneWidget);
    });

    testWidgets('should show step label "Message" at step 4', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.text('Step 4 of 5 · Message'), findsOneWidget);
    });

    testWidgets('should show step label "Review" at step 5', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 5,
            bouquet: CustomBouquetEntity(
              flowers: const [tRose],
              wrapping: tWrapping,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 5 of 5 · Review'), findsOneWidget);
    });

    testWidgets('should show back arrow icon in header', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState()));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });

  // ── Step Indicator ─────────────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Step Indicator', () {
    testWidgets('should render 5-step indicator bar', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState()));
      await tester.pump();

      // The indicator has 5 segments — find the containing padding widget
      expect(find.byType(Scaffold), findsOneWidget);
      // 5 animated containers are rendered in the indicator row
      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(containers.length, greaterThanOrEqualTo(5));
    });
  });

  // ── Step 1 — Flower selection ──────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Step 1 (Flowers)', () {
    testWidgets('should show "Choose Your Flowers" title', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.text('Choose Your Flowers'), findsOneWidget);
    });

    testWidgets('should show flower names from catalog', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.text('Rose'), findsOneWidget);
      expect(find.text('Tulip'), findsOneWidget);
      expect(find.text('Sunflower'), findsOneWidget);
      expect(find.text('Lily'), findsOneWidget);
    });

    testWidgets('should show price per stem for flowers', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.text('Rs. 120/stem'), findsOneWidget); // Rose
      expect(find.text('Rs. 90/stem'), findsOneWidget); // Tulip
    });

    testWidgets('should show check icon for selected flowers', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 1,
            bouquet: CustomBouquetEntity(flowers: const [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('should not show check icon when no flowers selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });
  });

  // ── Step 2 — Stem counts ───────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Step 2 (Count)', () {
    testWidgets('should show "How Many Stems?" title', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(flowers: const [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('How Many Stems?'), findsOneWidget);
    });

    testWidgets('should show selected flower name in count step', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(flowers: const [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Rose'), findsOneWidget);
    });

    testWidgets('should show current stem count', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(flowers: const [tRose]), // count = 5
          ),
        ),
      );
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should show total stems subtitle', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(
              flowers: const [tRose, tTulip],
            ), // 5 + 3 = 8
          ),
        ),
      );
      await tester.pump();

      expect(find.text('8 stems total'), findsOneWidget);
    });

    testWidgets('should show + and – buttons for each flower', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(flowers: const [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });

    testWidgets('should show fallback message when no flowers selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 2)));
      await tester.pump();

      expect(
        find.text('Please go back and select at least one flower.'),
        findsOneWidget,
      );
    });
  });

  // ── Step 3 — Wrapping ──────────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Step 3 (Wrapping)', () {
    testWidgets('should show "Pick Your Wrapping" title', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 3)));
      await tester.pump();

      expect(find.text('Pick Your Wrapping'), findsOneWidget);
    });

    testWidgets('should show wrapping option names', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 3)));
      await tester.pump();

      expect(find.text('Kraft Paper'), findsOneWidget);
      expect(find.text('Silk Ribbon'), findsOneWidget);
    });

    testWidgets('should show wrapping prices', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 3)));
      await tester.pump();

      expect(find.text('+ Rs. 50'), findsOneWidget); // Kraft Paper
      expect(find.text('+ Rs. 120'), findsOneWidget); // Silk Ribbon
    });

    testWidgets('should show check icon for selected wrapping', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 3,
            bouquet: const CustomBouquetEntity(wrapping: tWrapping),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('should not show check icon when no wrapping selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 3)));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });
  });

  // ── Step 4 — Personal Note ─────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Step 4 (Note)', () {
    testWidgets('should show "Add a Personal Note" title', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.text('Add a Personal Note'), findsOneWidget);
    });

    testWidgets('should show recipient name field', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.text("Recipient's Name"), findsOneWidget);
    });

    testWidgets('should show message field', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.text('Your Message'), findsOneWidget);
    });

    testWidgets('should show quick starter chips', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.text('With all my love ❤️'), findsOneWidget);
      expect(find.text('Happy Birthday! 🎂'), findsOneWidget);
    });

    testWidgets('should show TextFormField widgets for input', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  // ── Step 5 — Review ────────────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Step 5 (Review)', () {
    final tFullState = CustomBouquetState(
      step: 5,
      bouquet: const CustomBouquetEntity(
        flowers: [tRose, tTulip],
        wrapping: tWrapping,
        note: 'With love',
        recipientName: 'Alice',
      ),
    );

    testWidgets('should show "Review Your Bouquet" title', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('Review Your Bouquet'), findsOneWidget);
    });

    testWidgets('should show flower names × counts in review', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('Rose × 5'), findsOneWidget);
      expect(find.text('Tulip × 3'), findsOneWidget);
    });

    testWidgets('should show flower subtotals', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('Rs. 600'), findsOneWidget); // 5 × 120
      expect(find.text('Rs. 270'), findsOneWidget); // 3 × 90
    });

    testWidgets('should show wrapping name and price in review', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('Kraft Paper'), findsOneWidget);
      expect(find.text('+ Rs. 50'), findsOneWidget);
    });

    testWidgets('should show recipient name in review', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('To: Alice'), findsOneWidget);
    });

    testWidgets('should show note in review', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('"With love"'), findsOneWidget);
    });

    testWidgets('should show grand total (flowers + wrapping)', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      // 600 + 270 + 50 = 920
      expect(find.text('Rs. 920'), findsOneWidget);
    });

    testWidgets('should show "Add to Cart →" button', (tester) async {
      await tester.pumpWidget(buildScreen(tFullState));
      await tester.pump();

      expect(find.text('Add to Cart →'), findsOneWidget);
    });

    testWidgets(
      'should show CircularProgressIndicator in button when submitting',
      (tester) async {
        await tester.pumpWidget(
          buildScreen(
            tFullState.copyWith(status: CustomBouquetStatus.submitting),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Add to Cart →'), findsNothing);
      },
    );

    testWidgets(
      'should show Edit buttons for Flowers, Wrapping, Personal Note',
      (tester) async {
        await tester.pumpWidget(buildScreen(tFullState));
        await tester.pump();

        expect(find.text('Edit'), findsNWidgets(3));
      },
    );

    testWidgets('should NOT show wrapping section if no wrapping selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 5,
            bouquet: const CustomBouquetEntity(flowers: [tRose]),
          ),
        ),
      );
      await tester.pump();

      // Only Flowers has an Edit button when no wrapping/note
      expect(find.text('Wrapping'), findsNothing);
    });

    testWidgets('should NOT show note section if note and name are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 5,
            bouquet: const CustomBouquetEntity(flowers: [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Personal Note'), findsNothing);
    });
  });

  // ── Navigation Bar ─────────────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - NavBar', () {
    testWidgets('should show "Continue" button at step 1', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('should show "Review" button label at step 4', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 4)));
      await tester.pump();

      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('should NOT show NavBar at step 5', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 5,
            bouquet: CustomBouquetEntity(
              flowers: const [tRose],
              wrapping: tWrapping,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('should show Back button when step > 1', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          CustomBouquetState(
            step: 2,
            bouquet: CustomBouquetEntity(flowers: const [tRose]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('should NOT show Back button at step 1', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState(step: 1)));
      await tester.pump();

      expect(find.text('Back'), findsNothing);
    });
  });

  // ── Scaffold ───────────────────────────────────────────────────────────────
  group('CustomBouquetBuilderScreen - Scaffold', () {
    testWidgets('should have a Scaffold widget', (tester) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState()));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have a SingleChildScrollView inside step area', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(const CustomBouquetState()));
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
