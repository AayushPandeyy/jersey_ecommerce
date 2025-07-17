import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';
import 'package:jersey_ecommerce/models/OrderModel.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';
import 'package:jersey_ecommerce/utlitlies/Loaders.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final JerseyModel model;
  final String selectedSize;
  final int quantity;

  const CheckoutPage({
    super.key,
    required this.model,
    required this.selectedSize,
    required this.quantity,
  });

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

  double get subtotal => widget.model.jerseyPrice * widget.quantity;
  double get deliveryFee => 150.0;
  double get total => subtotal + deliveryFee;

  void placeOrder(OrderModel model) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (selectedPaymentMethod == 'Online Payment') {
        // Process Khalti payment
        await processKhaltiPayment(model);
      } else {
        // Process Cash on Delivery
        await processCODOrder(model);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> processKhaltiPayment(OrderModel model) async {
    try {
      // Generate unique product ID
      String productId = "jersey_${DateTime.now().millisecondsSinceEpoch}";
      
      // Configure Khalti payment
      PaymentConfig config = PaymentConfig(
        amount: (total * 100).toInt(), // Khalti expects amount in paisa (multiply by 100)
        productIdentity: productId,
        productName: widget.model.jerseyTitle,
        productUrl: '', // Optional
        additionalData: {
          'size': widget.selectedSize,
          'quantity': widget.quantity.toString(),
          'customer_name': _nameController.text,
          'customer_phone': _phoneController.text,
        },
      );

      // Launch Khalti payment
      KhaltiScope.of(context).pay(
        config: config,
        preferences: [
          PaymentPreference.khalti,
          PaymentPreference.eBanking,
          PaymentPreference.mobileBanking,
          PaymentPreference.connectIPS,
          PaymentPreference.sct,
        ],
        onSuccess: (PaymentSuccessModel success) async {
          // Payment successful
          print('Khalti Payment Success: ${success.toString()}');
          
          OrderModel updatedModel = OrderModel(
            status: OrderStatus.PENDING,
            jersey: model.jersey,
            quantity: model.quantity,
            selectedSize: model.selectedSize,
            fullname: model.fullname,
            phoneNUmber: model.phoneNUmber,
            address: model.address,
            city: model.city,
            postalCode: model.postalCode,
            totalAmount: model.totalAmount,
            paymentMethod: PaymentMethod.ONLINE_PAYMENT,
            orderDate: model.orderDate,
            paymentStatus: PaymentStatus.PAID,
            khaltiTransactionId: success.token,
            khaltiProductId: productId,
            khaltiRefId: success.token,
            paymentDate: DateTime.now(),
            id: '',
          );

          try {
            await firestoreService.addOrder(
              FirebaseAuth.instance.currentUser!.uid,
              updatedModel,
            );

            Navigator.pop(context);
            Navigator.pop(context);
            Loaders().showOrderPlacedPopup(context);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment successful! Transaction ID: ${success.token}'),
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
        },
        onFailure: (PaymentFailureModel failure) {
          print('Khalti Payment Failed: ${failure.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onCancel: () {
          print('Khalti Payment Cancelled');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );
    } catch (e) {
      print('Khalti Payment Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> processCODOrder(OrderModel model) async {
    await firestoreService.addOrder(
      FirebaseAuth.instance.currentUser!.uid,
      model,
    );

    Navigator.pop(context);
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.model.jerseyImage[0],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.model.jerseyTitle,
                                      style: GoogleFonts.russoOne(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Size: ${widget.selectedSize}',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quantity: ${widget.quantity}',
                                      style: GoogleFonts.robotoSlab(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${widget.model.jerseyPrice}',
                                      style: GoogleFonts.russoOne(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Khalti',
                                        style: GoogleFonts.robotoSlab(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Khalti Payment',
                                      style: GoogleFonts.robotoSlab(),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  'Pay securely with Khalti',
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
                                    'Subtotal',
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
                        onPressed: isLoading ? null : () {
                          placeOrder(
                            OrderModel(
                              id: '',
                              status: OrderStatus.PENDING,
                              jersey: widget.model,
                              quantity: widget.quantity,
                              selectedSize: widget.selectedSize,
                              fullname: _nameController.text,
                              phoneNUmber: _phoneController.text,
                              address: _addressController.text,
                              city: _cityController.text,
                              postalCode: _postalCodeController.text,
                              totalAmount: total,
                              paymentMethod: selectedPaymentMethod == "Cash on Delivery"
                                  ? PaymentMethod.CASH_ON_DELIVERY
                                  : PaymentMethod.ONLINE_PAYMENT,
                              orderDate: DateTime.now(),
                              paymentStatus: PaymentStatus.PENDING,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: selectedPaymentMethod == 'Online Payment' 
                              ? Colors.purple.shade600
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
                                        'Khalti',
                                        style: GoogleFonts.robotoSlab(
                                          color: Colors.purple.shade600,
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