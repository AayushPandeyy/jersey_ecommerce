import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';

class OrderModel {
  final String? id; // Firestore document ID
  final JerseyModel jersey;
  final int quantity;
  final String selectedSize;
  final String fullname;
  final String phoneNUmber;
  final String address;
  final String city;
  final String postalCode;
  final double totalAmount;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final DateTime orderDate;
  final PaymentStatus paymentStatus;

  OrderModel({
    this.id, // <-- new field
    required this.orderDate,
    required this.jersey,
    required this.quantity,
    required this.selectedSize,
    required this.fullname,
    required this.phoneNUmber,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  // copyWith method for creating updated instances
  OrderModel copyWith({
    String? id,
    JerseyModel? jersey,
    int? quantity,
    String? selectedSize,
    String? fullname,
    String? phoneNUmber,
    String? address,
    String? city,
    String? postalCode,
    double? totalAmount,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? orderDate,
    PaymentStatus? paymentStatus,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      jersey: jersey ?? this.jersey,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      fullname: fullname ?? this.fullname,
      phoneNUmber: phoneNUmber ?? this.phoneNUmber,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  // Optional: Add toMap method for Firestore serialization
  Map<String, dynamic> toMap() {
    return {
      'orderDate': orderDate.toIso8601String(),
      'jersey': jersey.toMap(), // Assuming JerseyModel has a toMap method
      'quantity': quantity,
      'selectedSize': selectedSize,
      'fullname': fullname,
      'phoneNUmber': phoneNUmber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
    };
  }

  // Optional: Add fromMap method for Firestore deserialization
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      orderDate: DateTime.parse(map['orderDate']),
      jersey: JerseyModel.fromMap(map['jersey']), // Assuming JerseyModel has a fromMap method
      quantity: map['quantity'],
      selectedSize: map['selectedSize'],
      fullname: map['fullname'],
      phoneNUmber: map['phoneNUmber'],
      address: map['address'],
      city: map['city'],
      postalCode: map['postalCode'],
      totalAmount: map['totalAmount'].toDouble(),
      status: OrderStatus.values.firstWhere((e) => e.name == map['status']),
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == map['paymentMethod']),
      paymentStatus: PaymentStatus.values.firstWhere((e) => e.name == map['paymentStatus']),
    );
  }

  // Optional: Add toString method for debugging
  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, paymentStatus: $paymentStatus, totalAmount: $totalAmount)';
  }
}