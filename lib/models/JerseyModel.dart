// ignore_for_file: public_member_api_docs, sort_constructors_first
class JerseyModel {
  String jerseyTitle;
  String jerseyDescription;
  List<String> jerseyImage;
  double jerseyPrice;
  double rating; // Added rating field

  JerseyModel({
    required this.jerseyTitle,
    required this.jerseyDescription,
    required this.jerseyImage,
    required this.jerseyPrice,
    required this.rating, // Added rating to constructor
  });

  factory JerseyModel.fromJson(Map<String, dynamic> json) {
    return JerseyModel(
      jerseyTitle: json['jerseyTitle'] as String,
      jerseyDescription: json['jerseyDescription'] as String,
      jerseyImage: List<String>.from(json['jerseyImage'] as List),
      jerseyPrice: (json['jerseyPrice'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(), // Parse rating
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jerseyTitle': jerseyTitle,
      'jerseyDescription': jerseyDescription,
      'jerseyImage': jerseyImage,
      'jerseyPrice': jerseyPrice,
      'rating': rating, 
    };
  }

  // fromMap function
  factory JerseyModel.fromMap(Map<String, dynamic> map) {
    return JerseyModel(
      jerseyTitle: map['jerseyTitle'] as String,
      jerseyDescription: map['jerseyDescription'] as String,
      jerseyImage: List<String>.from(map['jerseyImage'] as List),
      jerseyPrice: (map['jerseyPrice'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
    );
  }

  // toMap function
  Map<String, dynamic> toMap() {
    return {
      'jerseyTitle': jerseyTitle,
      'jerseyDescription': jerseyDescription,
      'jerseyImage': jerseyImage,
      'jerseyPrice': jerseyPrice,
      'rating': rating,
    };
  }
}
