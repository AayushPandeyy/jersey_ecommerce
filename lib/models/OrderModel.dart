// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:jersey_ecommerce/models/JerseyModel.dart';

class OrderModel {
  JerseyModel jersey;
  int quantity;
  String selectedSize;
  OrderModel({
    required this.jersey,
    required this.quantity,
    required this.selectedSize,
  });
}
