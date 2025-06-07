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
  @override
  Widget build(BuildContext context) {
    final sampleImages = [
      'https://i.redd.it/bb92a2i3gva91.jpg',
      'https://cdn.dotpe.in/longtail/store-items/8184062/lwBRcDWJ.webp',
      'https://images.meesho.com/images/products/390152813/atbxg_512.webp',
      'https://img.drz.lazcdn.com/static/bd/p/afc387c139fe27168ca4eac6f5d52c14.jpg_720x720q80.jpg',
    ];
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
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                // Handle favorite action
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Handle cart action
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ImageViewerWidget(
                imageUrls: sampleImages,
                height: 400,
                padding: EdgeInsets.all(8),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.black),
                  SizedBox(width: 8),
                  Text("4.5", style: GoogleFonts.robotoSlab(fontSize: 16)),
                ],
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Select a size",
                      style: GoogleFonts.robotoSlab(
                        fontWeight: FontWeight.normal,
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
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizeSelector(),
            ],
          ),
        ),
      ),
    );
  }
}
