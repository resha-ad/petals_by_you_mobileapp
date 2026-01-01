import 'package:flutter/material.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/category_row_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/home_header.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/offer_card_widget.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/widgets/product_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeHeader(),
            SizedBox(height: 20),

            CategoryRow(),
            SizedBox(height: 20),

            /// Offer card
            OfferCard(),
            SizedBox(height: 20),

            /// New Arrival
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

            /// Our product
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
          ],
        ),
      ),
    );
  }
}
