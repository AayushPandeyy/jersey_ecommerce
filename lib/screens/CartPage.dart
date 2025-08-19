import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/models/CartModel.dart';
import 'package:jersey_ecommerce/screens/CheckoutScreen.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.marcellus(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: FirestoreService().getCartItems(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return  Center(child: Text('Something went wrong. ${snapshot.error}'));
          }

          final cartItems = snapshot.data!;
          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          double total = cartItems.fold(
            0,
            (sum, item) => sum + item.jersey.jerseyPrice * item.quantity,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.jersey.jerseyImage[0], width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        title: Text(item.jersey.jerseyTitle, style: GoogleFonts.marcellus(fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Size: ${item.selectedSize}', style: GoogleFonts.robotoSlab()),
                            Text('Qty: ${item.quantity}', style: GoogleFonts.robotoSlab()),
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Rs. ${(item.jersey.jerseyPrice * item.quantity).toStringAsFixed(0)}',
                                style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                await FirestoreService().deleteFromCart(item.id, userId);
                              },
                              child: const Icon(Icons.delete, color: Colors.red),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: GoogleFonts.marcellus(fontSize: 18)),
                        Text('Rs. ${total.toStringAsFixed(0)}',
                            style: GoogleFonts.marcellus(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CheckoutPage(cartItems: cartItems)));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Proceed to Checkout',
                          style: GoogleFonts.marcellus(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
