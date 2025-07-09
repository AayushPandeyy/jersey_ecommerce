// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/models/JerseyModel.dart';

class OrderModel {
  JerseyModel jersey;
  int quantity;
  String selectedSize;
  String fullname;
  String phoneNUmber;
  String address;
  String city;
  String postalCode;
  double totalAmount;
  OrderStatus status;
  PaymentMethod paymentMethod;
  OrderModel({
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
