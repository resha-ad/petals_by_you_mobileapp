import 'package:flutter/material.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/category_row_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/home_header.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/offer_card_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/product_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // You can add real refresh logic here later (e.g. reload products)
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // ← This is the most important line
        padding: const EdgeInsets.only(
          bottom: 100,
        ), // ← Extra space so last item isn't hidden under BottomNav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeHeader(),
            SizedBox(height: 20),
            CategoryRow(),
            SizedBox(height: 20),
            OfferCard(),
            SizedBox(height: 20),

            // New Arrival
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "New Arrival",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 12),
            ProductCard(
              title: "Full Roses",
              price: "Rs. 1800",
              imagePath: "assets/images/roseBouquet.jpg",
            ),
            ProductCard(
              title: "Derby Bouquet",
              price: "Rs. 1500",
              imagePath: "assets/images/derbyBouquet.jpg",
            ),

            SizedBox(height: 24),

            // Our product
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Our product",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 12),
            ProductCard(
              title: "Pink Bouquet",
              price: "Rs. 1700",
              imagePath: "assets/images/pinkBouquet.jpg",
            ),
            ProductCard(
              title: "Tulip",
              price: "Rs. 1200",
              imagePath: "assets/images/tulips.jpg",
            ),

            SizedBox(height: 40), // Extra bottom padding
          ],
        ),
      ),
    );
  }
}
