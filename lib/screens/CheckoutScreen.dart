import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/CartModel.dart';
import 'package:jersey_ecommerce/models/CartOrderModel.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';
import 'package:jersey_ecommerce/utlitlies/Loaders.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List<CartItemModel> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirestoreService firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String selectedPaymentMethod = 'Cash on Delivery';
  bool isLoading = false;

  // Your Stripe configuration
  static const String stripePublishableKey =
      'pk_test_51RxlabIdq3n9dEVZ5Xyo2JxpFS0zulswMAaUTXjck0Sro3GkDPDDZ7Iro93bUawnIOzw17KKnRz9dk9jgOz6nEIA006kAwxmi5';
  static const String stripeSecretKey =
      'sk_test_51RxlabIdq3n9dEVZZ3U3SaU3jEk71n7DXV48ydpPqbhPo4PBlLAaIQIiH9OWNltJucOE4K3fu5YeeszFjhJMlYDY00VcdN7TBZ';

  double get subtotal => widget.cartItems.fold(
    0.0,
    (sum, item) => sum + (item.jersey.jerseyPrice * item.quantity),
  );

  double get deliveryFee => 150.0;
  double get total => subtotal + deliveryFee;

  int get totalItems =>
      widget.cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void initState() {
    super.initState();
    // Initialize Stripe
    Stripe.publishableKey = stripePublishableKey;
  }

  void placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (selectedPaymentMethod == 'Online Payment') {
        // Process Stripe payment
        await processStripePayment();
      } else {
        // Process Cash on Delivery
        await processCODOrder();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> processStripePayment() async {
    try {
      // Create product name from cart items
      String productName = widget.cartItems.length == 1
          ? widget.cartItems.first.jersey.jerseyTitle
          : "${widget.cartItems.length} Jerseys";

      // Step 1: Create payment intent on your backend
      final paymentIntent = await createPaymentIntent(
       (total.toInt()).toString(), // Stripe expects amount in cents
        'usd', // Change to your currency
      );

      if (paymentIntent == null) {
        throw Exception('Failed to create payment intent');
      }

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Jersey Store',
          customerId: paymentIntent['customer'],
          customerEphemeralKeySecret: paymentIntent['ephemeralKey'],
          style: ThemeMode.light,
          billingDetails: BillingDetails(
            name: _nameController.text,
            phone: _phoneController.text,
            address: Address(
              city: _cityController.text,
              country: 'US', // Change to your country
              line1: _addressController.text,
              postalCode: _postalCodeController.text,
              state: '',
              line2: '',
            ),
          ),
        ),
      );

      // Step 3: Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      print('Stripe Payment Success');

      try {
        // Create order using the unified createOrder method
        await FirestoreService().createOrder(
          userId: FirebaseAuth.instance.currentUser!.uid,
          cartItems: widget.cartItems,
          fullname: _nameController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          paymentMethod: PaymentMethod.ONLINE_PAYMENT,
          status: OrderStatus.PENDING,
          paymentStatus: PaymentStatus.PAID,
          stripePaymentIntentId: paymentIntent['id'],
        );

        Navigator.pop(context);
        Loaders().showOrderPlacedPopup(context);

        for (var cartitem in widget.cartItems) {
          // Update stock in Firestore
          await firestoreService.updateJerseyStock(
             cartitem.jersey.jerseyId,
            cartitem.jersey.stock - cartitem.quantity,
          );
          
        }



        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! Your order has been placed.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving order: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful but failed to save order: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on StripeException catch (e) {
      print('Stripe Error: ${e.error.localizedMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.error.localizedMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Payment Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        // Amount must be in smaller unit of currency
        // so we have multiply it by 100
        'amount': ((int.parse(amount)) * 100).toString(), 
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey =
          "sk_test_51RxlabIdq3n9dEVZZ3U3SaU3jEk71n7DXV48ydpPqbhPo4PBlLAaIQIiH9OWNltJucOE4K3fu5YeeszFjhJMlYDY00VcdN7TBZ";
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body: ${response.body.toString()}');
      return jsonDecode(response.body.toString());
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
}

  Future<void> processCODOrder() async {
    await FirestoreService().createOrder(
      userId: FirebaseAuth.instance.currentUser!.uid,
      cartItems: widget.cartItems,
      fullname: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      postalCode: _postalCodeController.text,
      paymentMethod: PaymentMethod.CASH_ON_DELIVERY,
      status: OrderStatus.PENDING,
      paymentStatus: PaymentStatus.PENDING,
    );

    Navigator.pop(context);
    Loaders().showOrderPlacedPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: FirestoreService().getUserDataByEmail(
          FirebaseAuth.instance.currentUser!.email!,
        ),
        builder: (context, asyncSnapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Checkout',
                style: GoogleFonts.russoOne(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Form(
              key: _formKey,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary
                        Text(
                          'Order Summary',
                          style: GoogleFonts.russoOne(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cart Items List
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.cartItems.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade300),
                            itemBuilder: (context, index) {
                              final item = widget.cartItems[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.jersey.jerseyImage[0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.jersey.jerseyTitle,
                                            style: GoogleFonts.russoOne(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Size: ${item.selectedSize}',
                                            style: GoogleFonts.robotoSlab(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Qty: ${item.quantity}',
                                            style: GoogleFonts.robotoSlab(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rs. ${item.jersey.jerseyPrice}',
                                          style: GoogleFonts.robotoSlab(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rs. ${(item.jersey.jerseyPrice * item.quantity).toStringAsFixed(0)}',
                                          style: GoogleFonts.russoOne(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Shipping Information
                        Text(
                          'Shipping Information',
                          style: GoogleFonts.russoOne(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: GoogleFonts.robotoSlab(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: GoogleFonts.robotoSlab(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            labelStyle: GoogleFonts.robotoSlab(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  labelStyle: GoogleFonts.robotoSlab(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter city';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _postalCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Postal Code',
                                  labelStyle: GoogleFonts.robotoSlab(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter postal code';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Payment Method
                        Text(
                          'Payment Method',
                          style: GoogleFonts.russoOne(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: Row(
                                  children: [
                                    Icon(Icons.money, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cash on Delivery',
                                      style: GoogleFonts.robotoSlab(),
                                    ),
                                  ],
                                ),
                                value: 'Cash on Delivery',
                                groupValue: selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                              Divider(height: 1, color: Colors.grey.shade300),
                              RadioListTile<String>(
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Stripe',
                                        style: GoogleFonts.robotoSlab(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Card Payment',
                                      style: GoogleFonts.robotoSlab(),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  'Pay securely with Stripe',
                                  style: GoogleFonts.robotoSlab(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                value: 'Online Payment',
                                groupValue: selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Order Total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal (${totalItems} items)',
                                    style: GoogleFonts.robotoSlab(fontSize: 16),
                                  ),
                                  Text(
                                    'Rs. ${subtotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.robotoSlab(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery Fee',
                                    style: GoogleFonts.robotoSlab(fontSize: 16),
                                  ),
                                  Text(
                                    'Rs. ${deliveryFee.toStringAsFixed(0)}',
                                    style: GoogleFonts.robotoSlab(fontSize: 16),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: GoogleFonts.russoOne(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${total.toStringAsFixed(0)}',
                                    style: GoogleFonts.russoOne(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                                height: 24,
                              ),
                              Text(
                                "!!! Order Once Placed Cannot Be Changed !!!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.allerta(
                                  fontSize: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 70),
                      ],
                    ),
                  ),

                  // Place Order Button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : placeOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              selectedPaymentMethod == 'Online Payment'
                              ? Colors.indigo.shade600
                              : Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (selectedPaymentMethod == 'Online Payment')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Stripe',
                                        style: GoogleFonts.robotoSlab(
                                          color: Colors.indigo.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (selectedPaymentMethod == 'Online Payment')
                                    const SizedBox(width: 8),
                                  Text(
                                    selectedPaymentMethod == 'Online Payment'
                                        ? 'Pay Rs. ${total.toStringAsFixed(0)}'
                                        : 'Place Order - Rs. ${total.toStringAsFixed(0)}',
                                    style: GoogleFonts.russoOne(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}
