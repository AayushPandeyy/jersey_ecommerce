

import 'package:jersey_ecommerce/models/JerseyModel.dart';

class CartItemModel {
  final String id;
  final JerseyModel jersey;
  final int quantity;
  final String selectedSize;

  CartItemModel({
    required this.id,
    required this.jersey,
    required this.quantity,
    required this.selectedSize,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'jersey': jersey.toMap(),
        'quantity': quantity,
        'selectedSize': selectedSize,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        id: map['id'],
        jersey: JerseyModel.fromMap(map['jersey']),
        quantity: map['quantity'],
        selectedSize: map['selectedSize'],
      );

  CartItemModel copyWith({
    String? id,
    JerseyModel? jersey,
    int? quantity,
    String? selectedSize,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      jersey: jersey ?? this.jersey,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}