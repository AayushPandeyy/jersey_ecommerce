import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/CartModel.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';

// New OrderItem model for individual items in an order
class CartOrderItemModel {
  final String jerseyId;
  final JerseyModel jersey;
  final int quantity;
  final String selectedSize;
  final double itemPrice;
  final double totalPrice; 

  CartOrderItemModel({
    required this.jerseyId,
    required this.jersey,
    required this.quantity,
    required this.selectedSize,
    required this.itemPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'jerseyId': jerseyId,
      'jersey': jersey.toMap(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'itemPrice': itemPrice,
      'totalPrice': totalPrice,
    };
  }

  factory CartOrderItemModel.fromMap(Map<String, dynamic> map) {
    return CartOrderItemModel(
      jerseyId: map['jerseyId'] ?? '',
      jersey: JerseyModel.fromMap(map['jersey']),
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'] ?? '',
      itemPrice: (map['itemPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  // Create from CartItemModel
  factory CartOrderItemModel.fromCartItem(CartItemModel cartItem) {
    return CartOrderItemModel(
      jerseyId: cartItem.jersey.jerseyId,
      jersey: cartItem.jersey, // Assuming CartItemModel has jersey field
      quantity: cartItem.quantity,
      selectedSize: cartItem.selectedSize,
      itemPrice: cartItem.jersey.jerseyPrice,
      totalPrice: cartItem.jersey.jerseyPrice * cartItem.quantity,
    );
  }
}

// Updated CartOrderModel for multiple items
class CartOrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final List<CartOrderItemModel> items;
  final String fullname;
  final String phoneNumber;
  final String address;
  final String city;
  final String postalCode;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final DateTime orderDate;
  final PaymentStatus paymentStatus;
  final DateTime? paymentDate;
  
  // Stripe payment details
  final String? stripePaymentIntentId;
  final String? stripeTransactionId;
  final String? stripeCustomerId;
  
  // Khalti payment details (for backward compatibility)
  final String? khaltiTransactionId;
  final String? khaltiProductId;
  final String? khaltiRefId;

  CartOrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.items,
    required this.fullname,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.paymentStatus,
    this.paymentDate,
    // Stripe parameters
    this.stripePaymentIntentId,
    this.stripeTransactionId,
    this.stripeCustomerId,
    // Khalti parameters
    this.khaltiTransactionId,
    this.khaltiProductId,
    this.khaltiRefId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'status': status.name,
      'items': items.map((item) => item.toMap()).toList(),
      'fullname': fullname,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'orderDate': Timestamp.fromDate(orderDate),
      'paymentStatus': paymentStatus.name,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      // Stripe fields
      'stripePaymentIntentId': stripePaymentIntentId,
      'stripeTransactionId': stripeTransactionId,
      'stripeCustomerId': stripeCustomerId,
      // Khalti fields
      'khaltiTransactionId': khaltiTransactionId,
      'khaltiProductId': khaltiProductId,
      'khaltiRefId': khaltiRefId,
    };
  }

  // Create from Map (Firestore data)
  factory CartOrderModel.fromMap(Map<String, dynamic> map) {
    return CartOrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.PENDING,
      ),
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartOrderItemModel.fromMap(item))
          .toList() ?? [],
      fullname: map['fullname'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.CASH_ON_DELIVERY,
      ),
      orderDate:  map['orderDate'] is Timestamp 
          ? (map['orderDate'] as Timestamp).toDate()
          : DateTime.now(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.PENDING,
      ),
      paymentDate: map['paymentDate'] != null 
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
      // Stripe fields
      stripePaymentIntentId: map['stripePaymentIntentId'],
      stripeTransactionId: map['stripeTransactionId'],
      stripeCustomerId: map['stripeCustomerId'],
      // Khalti fields
      khaltiTransactionId: map['khaltiTransactionId'],
      khaltiProductId: map['khaltiProductId'],
      khaltiRefId: map['khaltiRefId'],
    );
  }

  // Helper method to get payment details based on payment method
  Map<String, String?> getPaymentDetails() {
    if (paymentMethod == PaymentMethod.ONLINE_PAYMENT) {
      if (stripePaymentIntentId != null) {
        return {
          'provider': 'Stripe',
          'transactionId': stripeTransactionId ?? stripePaymentIntentId,
          'paymentIntentId': stripePaymentIntentId,
          'customerId': stripeCustomerId,
        };
      } else if (khaltiTransactionId != null) {
        return {
          'provider': 'Khalti',
          'transactionId': khaltiTransactionId,
          'productId': khaltiProductId,
          'refId': khaltiRefId,
        };
      }
    }
    return {
      'provider': 'Cash on Delivery',
      'transactionId': null,
    };
  }

  // Copy with method for updates
  CartOrderModel copyWith({
    String? id,
    String? userId,
    OrderStatus? status,
    List<CartOrderItemModel>? items,
    String? fullname,
    String? phoneNumber,
    String? address,
    String? city,
    String? postalCode,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    DateTime? orderDate,
    PaymentStatus? paymentStatus,
    DateTime? paymentDate,
    String? stripePaymentIntentId,
    String? stripeTransactionId,
    String? stripeCustomerId,
    String? khaltiTransactionId,
    String? khaltiProductId,
    String? khaltiRefId,
  }) {
    return CartOrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      items: items ?? this.items,
      fullname: fullname ?? this.fullname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeTransactionId: stripeTransactionId ?? this.stripeTransactionId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      khaltiTransactionId: khaltiTransactionId ?? this.khaltiTransactionId,
      khaltiProductId: khaltiProductId ?? this.khaltiProductId,
      khaltiRefId: khaltiRefId ?? this.khaltiRefId,
    );
  }
}