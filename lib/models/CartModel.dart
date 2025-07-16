

class CartItemModel {
  final String id;
  final String jerseyId;
  final String jerseyTitle;
  final String jerseyImage;
  final double jerseyPrice;
  final int quantity;
  final String selectedSize;
  
  CartItemModel({
    required this.id,
    required this.jerseyId,
    required this.jerseyTitle,
    required this.jerseyImage,
    required this.jerseyPrice,
    required this.quantity,
    required this.selectedSize,
  });
  
  Map<String, dynamic> toMap() => {
        'id': id,
        'jerseyId': jerseyId,
        'jerseyTitle': jerseyTitle,
        'jerseyImage': jerseyImage,
        'jerseyPrice': jerseyPrice,
        'quantity': quantity,
        'selectedSize': selectedSize,
      };
      
  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        id: map['id'],
        jerseyId: map['jerseyId'],
        jerseyTitle: map['jerseyTitle'],
        jerseyImage: map['jerseyImage'],
        jerseyPrice: map['jerseyPrice'].toDouble(),
        quantity: map['quantity'],
        selectedSize: map['selectedSize'],
      );
  
  CartItemModel copyWith({
    String? id,
    String? jerseyId,
    String? jerseyTitle,
    String? jerseyImage,
    double? jerseyPrice,
    int? quantity,
    String? selectedSize,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      jerseyId: jerseyId ?? this.jerseyId,
      jerseyTitle: jerseyTitle ?? this.jerseyTitle,
      jerseyImage: jerseyImage ?? this.jerseyImage,
      jerseyPrice: jerseyPrice ?? this.jerseyPrice,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}