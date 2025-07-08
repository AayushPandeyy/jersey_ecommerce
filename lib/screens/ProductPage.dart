import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';
import 'package:jersey_ecommerce/utlitlies/Loaders.dart';
import 'package:jersey_ecommerce/widgets/MobileImageViewer.dart';
import 'package:jersey_ecommerce/widgets/SizeSelector.dart';

class ProductPage extends StatefulWidget {
  final JerseyModel model;
  const ProductPage({super.key, required this.model});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? selectedSize;

  int quantity = 1;
  final FirestoreService firestoreService = FirestoreService();

  void buyNow() async {
    await firestoreService.addOrder(
      FirebaseAuth.instance.currentUser!.uid, // Replace with actual user ID
      widget.model, 
      quantity,
      selectedSize ?? "M",
    );
    Navigator.pop(context);
    Loaders().showOrderPlacedPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    final sampleImages = [
      widget.model.jerseyImage[0],
      widget.model.jerseyImage[1],
      widget.model.jerseyImage[2],
      widget.model.jerseyImage[3],
    ];

    final sizes = ["XS", "S", "M", "L", "XL", "XXL"];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.favorite), onPressed: () {}),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    ImageViewerWidget(
                      imageUrls: sampleImages,
                      height: 400,
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          widget.model.rating.toString(),
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              widget.model.jerseyTitle,
                              style: GoogleFonts.russoOne(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Rs. ${widget.model.jerseyPrice}",
                            style: GoogleFonts.russoOne(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.model.jerseyDescription,
                        style: GoogleFonts.robotoSlab(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text(
                          "Quantity",
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  quantity = quantity > 1 ? quantity - 1 : 1;
                                });
                              },
                            ),
                            Text(
                              quantity.toString(),
                              style: GoogleFonts.robotoSlab(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Select a size",
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Size Guide",
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizeSelector(
                      sizes: sizes,
                      selectedSize: selectedSize,
                      onSizeSelected: (size) {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Row(
                  children: [
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedSize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a size'),
                              ),
                            );
                          } else {
                            // TODO: Add to Hive cart box
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xff3282B8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Add to Cart\nRs. ${widget.model.jerseyPrice * quantity}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.russoOne(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Buy Now Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedSize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a size'),
                              ),
                            );
                          } else {
                            buyNow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Buy Now\nRs. ${widget.model.jerseyPrice * quantity}",
                          style: GoogleFonts.russoOne(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
