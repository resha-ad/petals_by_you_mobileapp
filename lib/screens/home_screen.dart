import 'package:flutter/material.dart';
import 'package:sprint1_project/widgets/category_row_widget.dart';
import 'package:sprint1_project/widgets/home_header_widget.dart';
import 'package:sprint1_project/widgets/offer_card_widget.dart';
import 'package:sprint1_project/widgets/product_card_widget.dart';
import 'package:sprint1_project/widgets/search_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeHeader(),
            SearchBarWidget(),
            CategoryRow(),
            OfferCard(),

            ProductCard(
              title: "Pink Bouquet",
              price: "Rs. 1700",
              imagePath: "assets/images/bouquet.png",
            ),
            ProductCard(
              title: "Tulip",
              price: "Rs. 1200",
              imagePath: "assets/images/tulip.png",
            ),
          ],
        ),
      ),
    );
  }
}
