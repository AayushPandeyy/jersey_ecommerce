import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';

class OrderModel {
  final String? id; // Added id field
  final OrderStatus status;
  final JerseyModel jersey;
  final int quantity;
  final String selectedSize;
  final String fullname;
  final String phoneNUmber;
  final String address;
  final String city;
  final String postalCode;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final DateTime orderDate;
  final PaymentStatus paymentStatus;
  
  // eSewa payment fields
  final String? khaltiTransactionId;
  final String? khaltiProductId;
  final String? khaltiRefId;
  final DateTime? paymentDate;

  OrderModel({
    required this.id, // Required id in constructor
    required this.status,
    required this.jersey,
    required this.quantity,
    required this.selectedSize,
    required this.fullname,
    required this.phoneNUmber,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.paymentStatus,
    this.khaltiTransactionId,
    this.khaltiProductId,
    this.khaltiRefId,
    this.paymentDate,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.toString(),
      'jersey': jersey.toMap(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'fullname': fullname,
      'phoneNumber': phoneNUmber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.toString(),
      'orderDate': Timestamp.fromDate(orderDate),
      'paymentStatus': paymentStatus.toString(),
      'khaltiTransactionId': khaltiTransactionId,
      'khaltiProductId': khaltiProductId,
      'khaltiRefId': khaltiRefId,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
    };
  }

  // Create from Map (Firestore data)
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '', // Get id from map
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderStatus.PENDING,
      ),
      jersey: JerseyModel.fromMap(map['jersey']),
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'] ?? '',
      fullname: map['fullname'] ?? '',
      phoneNUmber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['paymentMethod'],
        orElse: () => PaymentMethod.CASH_ON_DELIVERY,
      ),
      orderDate: map['orderDate'] is Timestamp 
          ? (map['orderDate'] as Timestamp).toDate()
          : DateTime.now(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == map['paymentStatus'],
        orElse: () => PaymentStatus.PENDING,
      ),
      khaltiTransactionId: map['khaltiTransactionId'],
      khaltiProductId: map['khaltiProductId'],
      khaltiRefId: map['khaltiRefId'],
      paymentDate: map['paymentDate'] != null 
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updating order
  OrderModel copyWith({
    String? id,
    OrderStatus? status,
    JerseyModel? jersey,
    int? quantity,
    String? selectedSize,
    String? fullname,
    String? phoneNUmber,
    String? address,
    String? city,
    String? postalCode,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    DateTime? orderDate,
    PaymentStatus? paymentStatus,
    String? khaltiTransactionId,
    String? khaltiProductId,
    String? khaltiRefId,
    DateTime? paymentDate,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      jersey: jersey ?? this.jersey,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      fullname: fullname ?? this.fullname,
      phoneNUmber: phoneNUmber ?? this.phoneNUmber,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      khaltiTransactionId: khaltiTransactionId ?? this.khaltiTransactionId,
      khaltiProductId: khaltiProductId ?? this.khaltiProductId,
      khaltiRefId: khaltiRefId ?? this.khaltiRefId,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  @override
  String toString() {
    return 'OrderModel{id: $id, status: $status, jersey: $jersey, quantity: $quantity, selectedSize: $selectedSize, fullname: $fullname, phoneNumber: $phoneNUmber, address: $address, city: $city, postalCode: $postalCode, totalAmount: $totalAmount, paymentMethod: $paymentMethod, orderDate: $orderDate, paymentStatus: $paymentStatus, khaltiTransactionId: $khaltiTransactionId, khaltiProductId: $khaltiProductId, khaltiRefId: $khaltiRefId, paymentDate: $paymentDate}';
  }
}