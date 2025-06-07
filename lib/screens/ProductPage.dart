import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/widgets/MobileImageViewer.dart';
import 'package:jersey_ecommerce/widgets/SizeSelector.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final sampleImages = [
      'https://i.redd.it/bb92a2i3gva91.jpg',
      'https://cdn.dotpe.in/longtail/store-items/8184062/lwBRcDWJ.webp',
      'https://images.meesho.com/images/products/390152813/atbxg_512.webp',
      'https://img.drz.lazcdn.com/static/bd/p/afc387c139fe27168ca4eac6f5d52c14.jpg_720x720q80.jpg',
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
              Column(
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
                      Text("4.5", style: GoogleFonts.robotoSlab(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Real Madrid Jersey",
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
                          "Rs. 2000",
                          style: GoogleFonts.russoOne(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
              Positioned(
                bottom: 20,
                right: 0,
                left: 0,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedSize == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a size')),
                      );
                    } else {
                      // Proceed to add to cart
                      print("Adding size $selectedSize to cart");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Color(0xff3282B8),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Add to Cart - Rs. 2000",
                    style: GoogleFonts.russoOne(
                      fontSize: 18,
                      color: Colors.white,
                    ),
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
