import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
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
  });
}
