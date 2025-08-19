import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/CartOrderModel.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';

class OrderDetailPage extends StatelessWidget {
  final CartOrderModel order;
  
  const OrderDetailPage({super.key, required this.order});

  Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.SHIPPED:
        return Colors.purple;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }

  String getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return 'PENDING';
      case OrderStatus.SHIPPED:
        return 'SHIPPED';
      case OrderStatus.DELIVERED:
        return 'DELIVERED';
      case OrderStatus.CANCELLED:
        return 'CANCELLED';
    }
  }

  String getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.CASH_ON_DELIVERY:
        return 'Cash on Delivery';
      case PaymentMethod.ONLINE_PAYMENT:
        return 'Online Payment';
    }
  }

  List<Map<String, dynamic>> getOrderSteps(OrderStatus currentStatus) {
    final steps = [
      {
        'title': 'Order Placed',
        'subtitle': 'Your order has been placed successfully',
        'status': OrderStatus.PENDING,
      },
      {
        'title': 'SHIPPED',
        'subtitle': 'Your order is on the way',
        'status': OrderStatus.SHIPPED,
      },
      {
        'title': 'DELIVERED',
        'subtitle': 'Your order has been DELIVERED',
        'status': OrderStatus.DELIVERED,
      },
    ];

    return steps;
  }

  bool isStepCompleted(OrderStatus stepStatus, OrderStatus currentStatus) {
    final statusOrder = [
      OrderStatus.PENDING,
      OrderStatus.SHIPPED,
      OrderStatus.DELIVERED,
    ];

    final stepIndex = statusOrder.indexOf(stepStatus);
    final currentIndex = statusOrder.indexOf(currentStatus);

    return stepIndex <= currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final deliveryFee = 150.0;
    final subtotal = order.totalAmount - deliveryFee;
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Order Details',
            style: GoogleFonts.marcellus(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: getStatusColor(order.status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      order.status == OrderStatus.DELIVERED
                          ? Icons.check_circle
                          : order.status == OrderStatus.CANCELLED
                              ? Icons.cancel
                              : Icons.access_time,
                      color: getStatusColor(order.status),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getStatusText(order.status),
                          style: GoogleFonts.marcellus(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(order.status),
                          ),
                        ),
                        Text(
                          order.status == OrderStatus.DELIVERED
                              ? 'Your order has been DELIVERED successfully'
                              : order.status == OrderStatus.CANCELLED
                                  ? 'Your order has been CANCELLED'
                                  : 'Your order is being processed',
                          style: GoogleFonts.robotoSlab(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Order Tracking (only show if not CANCELLED)
              if (order.status != OrderStatus.CANCELLED) ...[
                Text(
                  'Order Tracking',
                  style: GoogleFonts.marcellus(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...getOrderSteps(order.status).map((step) {
                  final isCompleted = isStepCompleted(step['status'], order.status);
                  final isActive = step['status'] == order.status;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isCompleted 
                                    ? getStatusColor(order.status)
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCompleted ? Icons.check : Icons.circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            if (step != getOrderSteps(order.status).last)
                              Container(
                                width: 2,
                                height: 40,
                                color: isCompleted 
                                    ? getStatusColor(order.status)
                                    : Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'],
                                style: GoogleFonts.marcellus(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted ? Colors.black : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['subtitle'],
                                style: GoogleFonts.robotoSlab(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 24),
              ],

              // Product Details - Updated to handle multiple items
              Text(
                'Product Details',
                style: GoogleFonts.marcellus(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Display all items in the order
              ...order.items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.jersey.jerseyImage[0],
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
                            item.jersey.jerseyTitle,
                            style: GoogleFonts.marcellus(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                item.jersey.rating.toString(),
                                style: GoogleFonts.robotoSlab(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Size: ${item.selectedSize}',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${item.quantity}',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${item.itemPrice.toStringAsFixed(0)} x ${item.quantity}',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: Rs. ${item.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.marcellus(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),

              const SizedBox(height: 24),

              // Shipping Information - Updated field name
              Text(
                'Shipping Information',
                style: GoogleFonts.marcellus(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          order.fullname,
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          order.phoneNumber, // Fixed field name
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${order.address}\n${order.city}, ${order.postalCode}',
                            style: GoogleFonts.robotoSlab(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Information
              Text(
                'Payment Information',
                style: GoogleFonts.marcellus(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                        Text(
                          getPaymentMethodText(order.paymentMethod),
                          style: GoogleFonts.robotoSlab(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Status',
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                        Text(
                          order.paymentStatus.name,
                          style: GoogleFonts.robotoSlab(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: order.paymentStatus == PaymentStatus.PAID
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    
                    // Show Khalti payment details if available
                    if (order.khaltiTransactionId != null) ...[
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaction ID',
                            style: GoogleFonts.robotoSlab(fontSize: 16),
                          ),
                          Text(
                            order.khaltiTransactionId!,
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items',
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                        Text(
                          '${order.items.length}',
                          style: GoogleFonts.robotoSlab(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: GoogleFonts.marcellus(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.marcellus(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (order.status == OrderStatus.PENDING) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Cancel Order',
                            style: GoogleFonts.marcellus(),
                          ),
                          content: Text(
                            'Are you sure you want to cancel this order?',
                            style: GoogleFonts.robotoSlab(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'No',
                                style: GoogleFonts.robotoSlab(),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Update to use CartOrderModel's updateOrderStatus method
                                await FirestoreService().updateOrderStatus(order.id!, OrderStatus.CANCELLED);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Yes, Cancel',
                                style: GoogleFonts.robotoSlab(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel Order',
                      style: GoogleFonts.marcellus(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] 
            ],
          ),
        ),
      ),
    );
  }
}