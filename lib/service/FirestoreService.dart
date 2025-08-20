import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/CartModel.dart';
import 'package:jersey_ecommerce/models/CartOrderModel.dart';
import 'package:jersey_ecommerce/models/OrderModel.dart';
import 'package:uuid/uuid.dart';
import '../models/JerseyModel.dart';
import 'package:http/http.dart' as http;

class FirestoreService {
   final cloudinary = CloudinaryPublic('dn9pqt2zt', 'gsnkt4sz');
  Stream<List<Map<String, dynamic>>> getUserDataByEmail(String email) {
    return FirebaseFirestore.instance
        .collection('Users') // The name of your collection
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final user = doc.data();
            return user;
          }).toList();
        });
  }

  Future<void> updateUserByEmail(
    String email,
    Map<String, dynamic> updatedData,
  ) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.update(updatedData);
    }
  }

  Future<void> addUserToDatabase(
    String uid,
    email,
    fullname,
    phoneNumber,
  ) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      'uid': uid,
      "email": email,
      "fullname": fullname,
      "phoneNumber": phoneNumber,
      "role":"customer"
    });
  }

  Stream<List<JerseyModel>> getJerseysStream() {
    return FirebaseFirestore.instance
        .collection('Jersey')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JerseyModel.fromMap(doc.data()))
              .toList(),
        );
  }

Future<void> addJersey(JerseyModel jersey, List<File?> imageFiles) async {
    try {
      final List<String> imageUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        if (file != null) {
          // Upload to Cloudinary
          final response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              file.path,
              folder: 'jerseys', // Optional: organize images in folders
              publicId: '${jersey.jerseyTitle.replaceAll(' ', '_')}_$i', // Optional: custom public ID
            ),
          );

          // Get the secure URL from Cloudinary response
          imageUrls.add(response.secureUrl);
        }
      }

      // Create a unique document reference
      final docRef = FirebaseFirestore.instance.collection('Jersey').doc();

      // Update jersey object with Firebase ID and image URLs
      final updatedJersey = jersey.copyWith(
        
        jerseyImage: imageUrls,
      );

      await docRef.set(updatedJersey.toMap());
    } catch (e) {
      throw Exception('Failed to add jersey: $e');
    }
  }

  String _extractPublicIdFromUrl(String url) {

    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    final uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final publicId = publicIdParts.join('/');
      return publicId.replaceAll(RegExp(r'\.[^.]*), '''),"");
    }
    
    return '';
  }

  Future<void> _deleteFromCloudinary(String imageUrl) async {
    try {
      const String cloudName = 'dn9pqt2zt';
      const String apiKey = '627241771152492';
      const String apiSecret = '9vtOnXBW2RM6o0RCjPnV8-U0t5k';
      
      final publicId = _extractPublicIdFromUrl(imageUrl);
      if (publicId.isEmpty) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      
      // You'll need to add crypto package for this
      final signature = _generateSignature(stringToSign);

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');
      
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode != 200) {
        print('Failed to delete image from Cloudinary: ${response.body}');
      }
    } catch (e) {
      print('Error deleting image from Cloudinary: $e');
      // Don't throw error here to avoid blocking the main operation
    }
  }

String _generateSignature(String stringToSign) {
  const String apiSecret = '9vtOnXBW2RM6o0RCjPnV8-U0t5k'; 
  
  var key = utf8.encode(apiSecret);
  var bytes = utf8.encode(stringToSign);
  var hmacSha1 = Hmac(sha1, key);
  var digest = hmacSha1.convert(bytes);
  return digest.toString();
}

  // Updated update method
Future updateJersey(String id, JerseyModel updatedJersey) async {
  try {
    // Get current jersey data to access existing images
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Jersey')
        .where("jerseyId", isEqualTo: id)
        .get();
        
    if (docSnapshot.docs.isEmpty) {
      throw Exception('Jersey not found');
    }

    final currentJersey = JerseyModel.fromMap(docSnapshot.docs.first.data());
    
    // Preserve existing images and only update text fields
    final jerseyToUpdate = updatedJersey.copyWith(
      jerseyImage: currentJersey.jerseyImage, // Keep existing images
    );

    // Get the document reference from the query result and update it
    final docRef = docSnapshot.docs.first.reference;
    await docRef.update(jerseyToUpdate.toMap());
  } catch (e) {
    throw Exception('Failed to update jersey: $e');
  }
}

  // Updated delete method
  Future<void> deleteJersey(String id) async {
    try {
      // Get jersey data to access image URLs
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Jersey')
          .where("jerseyId", isEqualTo: id)
          .get();
      
      if (docSnapshot.docs.isNotEmpty) {
        final jersey = JerseyModel.fromMap(docSnapshot.docs.first.data());
        
        // Delete images from Cloudinary
        for (String imageUrl in jersey.jerseyImage) {
          await _deleteFromCloudinary(imageUrl);
        }
      }

      // Delete the document from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Jersey')
          .where("jerseyId", isEqualTo: id)
          .get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete jersey: $e');
    }
  }


  Stream<JerseyModel?> getJerseyById(String id) {
    return FirebaseFirestore.instance
        .collection('Jersey')
        .where("jerseyId", isEqualTo: id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return JerseyModel.fromMap(snapshot.docs.first.data());
          }
          return null;
        });
  }



Future<CartOrderModel> createOrder({
  required String userId,
  required List<CartItemModel> cartItems,
  required String fullname,
  required String phoneNumber,
  required String address,
  required String city,
  required String postalCode,
  required PaymentMethod paymentMethod,
  OrderStatus status = OrderStatus.PENDING,
  PaymentStatus paymentStatus = PaymentStatus.PENDING,
  // Stripe parameters
  String? stripePaymentIntentId,
  String? stripeTransactionId,
  String? stripeCustomerId,
  // Khalti parameters (for backward compatibility)
  String? khaltiTransactionId,
  String? khaltiProductId,
  String? khaltiRefId,
}) async {
  try {
    // Convert cart items to order items
    List<CartOrderItemModel> orderItems = cartItems
        .map((cartItem) => CartOrderItemModel.fromCartItem(cartItem))
        .toList();

    // Calculate subtotal from items
    double subtotal = orderItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    // Add delivery fee
    double deliveryFee = 150.0;
    double totalAmount = subtotal + deliveryFee;

    // Get a reference to create the document with auto-generated ID
    DocumentReference orderRef = FirebaseFirestore.instance.collection('Orders').doc();

    // Create the order model
    CartOrderModel order = CartOrderModel(
      id: orderRef.id,
      userId: userId,
      status: status,
      items: orderItems,
      fullname: fullname,
      phoneNumber: phoneNumber,
      address: address,
      city: city,
      postalCode: postalCode,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      orderDate: DateTime.now(),
      paymentStatus: paymentStatus,
      // Stripe parameters
      stripePaymentIntentId: stripePaymentIntentId,
      stripeTransactionId: stripeTransactionId,
      stripeCustomerId: stripeCustomerId,
      // Khalti parameters (kept for backward compatibility)
      khaltiTransactionId: khaltiTransactionId,
      khaltiProductId: khaltiProductId,
      khaltiRefId: khaltiRefId,
      paymentDate: paymentStatus == PaymentStatus.PAID 
          ? DateTime.now() 
          : null,
    );

    // Save to Firestore
    await orderRef.set(order.toMap());

    print('Order created successfully with ID: ${order.id}');
    return order;

  } catch (e) {
    print('Error creating order: $e');
    rethrow;
  }
}
// Fixed getUserOrders method
Stream<List<CartOrderModel>> getUserOrders(String userId) {
  return FirebaseFirestore.instance
      .collection('Orders')
      .where('userId', isEqualTo: userId)
      .orderBy('orderDate', descending: true) // Fixed: changed from 'timestamp' to 'orderDate'
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();

          // Check if this is legacy format (single jersey) or new format (items array)
          final items = data['items'] as List<dynamic>?;
          List<CartOrderItemModel> orderItems;

          if (items != null && items.isNotEmpty) {
            // New format: items array exists
            orderItems = items.map((item) {
              final jerseyModel = JerseyModel(
                jerseyId: item['jersey']['jerseyId'] ?? item['jerseyId'] ?? '',
                jerseyTitle: item['jersey']['jerseyTitle'] ?? '',
                jerseyDescription: item['jersey']['jerseyDescription'] ?? '',
                jerseyPrice: (item['jersey']['jerseyPrice'] ?? 0).toDouble(),
                jerseyImage: List<String>.from(item['jersey']['jerseyImage'] ?? []),
                rating: (item['jersey']['rating'] ?? 0.0).toDouble(),
                stock: (item['jersey']['stock'] ?? 0).toInt(), // Fixed: added stock parsing
              );

              return CartOrderItemModel(
                jerseyId: item['jerseyId'] ?? item['jersey']['jerseyId'] ?? '',
                jersey: jerseyModel,
                quantity: item['quantity'] ?? 1,
                selectedSize: item['selectedSize'] ?? item['size'] ?? 'M',
                itemPrice: (item['itemPrice'] ?? item['jersey']['jerseyPrice'] ?? 0).toDouble(),
                totalPrice: (item['totalPrice'] ?? (item['quantity'] ?? 1) * (item['itemPrice'] ?? item['jersey']['jerseyPrice'] ?? 0)).toDouble(),
              );
            }).toList();
          } else {
            // Legacy format: single jersey data
            final jerseyModel = JerseyModel(
              jerseyId: data['jersey']['jerseyId'] ?? doc.id,
              jerseyTitle: data['jersey']['jerseyTitle'] ?? '',
              jerseyDescription: data['jersey']['jerseyDescription'] ?? '',
              jerseyPrice: (data['jersey']['jerseyPrice'] ?? 0).toDouble(),
              jerseyImage: List<String>.from(data['jersey']['jerseyImage'] ?? []),
              rating: (data['jersey']['rating'] ?? 0.0).toDouble(),
              stock: (data['jersey']['stock'] ?? 0).toInt(), // Fixed: added stock parsing
            );

            final quantity = data['quantity'] ?? 1;
            final itemPrice = jerseyModel.jerseyPrice;
            
            orderItems = [
              CartOrderItemModel(
                jerseyId: jerseyModel.jerseyId,
                jersey: jerseyModel,
                quantity: quantity,
                selectedSize: data['selectedSize'] ?? data['size'] ?? 'M', // Fixed: added selectedSize fallback
                itemPrice: itemPrice,
                totalPrice: itemPrice * quantity,
              )
            ];
          }

          // Fixed: enum parsing to handle both string formats
          final status = OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (data['status'] ?? '').toString().split('.').last.toLowerCase(),
            orElse: () => OrderStatus.PENDING,
          );

          final paymentMethod = PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (data['paymentMethod'] ?? '').toString().split('.').last.toLowerCase(),
            orElse: () => PaymentMethod.CASH_ON_DELIVERY,
          );

          final paymentStatus = PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (data['paymentStatus'] ?? '').toString().split('.').last.toLowerCase(),
            orElse: () => PaymentStatus.PENDING,
          );

          // Fixed: improved date parsing
          DateTime orderDate;
          if (data['orderDate'] is Timestamp) {
            orderDate = (data['orderDate'] as Timestamp).toDate();
          } else if (data['orderDate'] is String) {
            try {
              orderDate = DateTime.parse(data['orderDate']);
            } catch (e) {
              orderDate = DateTime.now();
            }
          } else {
            orderDate = DateTime.now();
          }

          return CartOrderModel(
            id: doc.id,
            userId: data['userId'] ?? userId,
            status: status,
            items: orderItems,
            fullname: data['fullname'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            address: data['address'] ?? '',
            city: data['city'] ?? '',
            postalCode: data['postalCode'] ?? '',
            totalAmount: (data['totalAmount'] ?? 0).toDouble(),
            paymentMethod: paymentMethod,
            orderDate: orderDate,
            paymentStatus: paymentStatus,
            khaltiTransactionId: data['khaltiTransactionId'],
            khaltiProductId: data['khaltiProductId'],
            khaltiRefId: data['khaltiRefId'],
            paymentDate: data['paymentDate'] != null 
                ? (data['paymentDate'] as Timestamp).toDate()
                : null,
          );
        }).toList();
      });
}

  Stream<List<CartOrderModel>> getOrdersStream() {
    return FirebaseFirestore.instance
      .collection('Orders')
      .orderBy('orderDate', descending: true) // Fixed: changed from 'timestamp' to 'orderDate'
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();

          // Check if this is legacy format (single jersey) or new format (items array)
          final items = data['items'] as List<dynamic>?;
          List<CartOrderItemModel> orderItems;

          if (items != null && items.isNotEmpty) {
            // New format: items array exists
            orderItems = items.map((item) {
              final jerseyModel = JerseyModel(
                jerseyId: item['jersey']['jerseyId'] ?? item['jerseyId'] ?? '',
                jerseyTitle: item['jersey']['jerseyTitle'] ?? '',
                jerseyDescription: item['jersey']['jerseyDescription'] ?? '',
                jerseyPrice: (item['jersey']['jerseyPrice'] ?? 0).toDouble(),
                jerseyImage: List<String>.from(item['jersey']['jerseyImage'] ?? []),
                rating: (item['jersey']['rating'] ?? 0.0).toDouble(),
                stock: (item['jersey']['stock'] ?? 0).toInt(), // Fixed: added stock parsing
              );

              return CartOrderItemModel(
                jerseyId: item['jerseyId'] ?? item['jersey']['jerseyId'] ?? '',
                jersey: jerseyModel,
                quantity: item['quantity'] ?? 1,
                selectedSize: item['selectedSize'] ?? item['size'] ?? 'M',
                itemPrice: (item['itemPrice'] ?? item['jersey']['jerseyPrice'] ?? 0).toDouble(),
                totalPrice: (item['totalPrice'] ?? (item['quantity'] ?? 1) * (item['itemPrice'] ?? item['jersey']['jerseyPrice'] ?? 0)).toDouble(),
              );
            }).toList();
          } else {
            // Legacy format: single jersey data
            final jerseyModel = JerseyModel(
              jerseyId: data['jersey']['jerseyId'] ?? doc.id,
              jerseyTitle: data['jersey']['jerseyTitle'] ?? '',
              jerseyDescription: data['jersey']['jerseyDescription'] ?? '',
              jerseyPrice: (data['jersey']['jerseyPrice'] ?? 0).toDouble(),
              jerseyImage: List<String>.from(data['jersey']['jerseyImage'] ?? []),
              rating: (data['jersey']['rating'] ?? 0.0).toDouble(),
              stock: (data['jersey']['stock'] ?? 0).toInt(), // Fixed: added stock parsing
            );

            final quantity = data['quantity'] ?? 1;
            final itemPrice = jerseyModel.jerseyPrice;
            
            orderItems = [
              CartOrderItemModel(
                jerseyId: jerseyModel.jerseyId,
                jersey: jerseyModel,
                quantity: quantity,
                selectedSize: data['selectedSize'] ?? data['size'] ?? 'M', // Fixed: added selectedSize fallback
                itemPrice: itemPrice,
                totalPrice: itemPrice * quantity,
              )
            ];
          }

          // Fixed: enum parsing to handle both string formats
          final status = OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (data['status'] ?? '').toString().split('.').last.toLowerCase(),
            orElse: () => OrderStatus.PENDING,
          );

          final paymentMethod = PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (data['paymentMethod'] ?? '').toString().split('.').last.toLowerCase(),
            orElse: () => PaymentMethod.CASH_ON_DELIVERY,
          );

          final paymentStatus = PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (data['paymentStatus'] ?? '').toString().split('.').last.toLowerCase(),
            orElse: () => PaymentStatus.PENDING,
          );

          // Fixed: improved date parsing
          DateTime orderDate;
          if (data['orderDate'] is Timestamp) {
            orderDate = (data['orderDate'] as Timestamp).toDate();
          } else if (data['orderDate'] is String) {
            try {
              orderDate = DateTime.parse(data['orderDate']);
            } catch (e) {
              orderDate = DateTime.now();
            }
          } else {
            orderDate = DateTime.now();
          }

          return CartOrderModel(
            id: doc.id,
            userId: data['userId'] ?? FirebaseAuth.instance.currentUser?.uid ?? '',
            status: status,
            items: orderItems,
            fullname: data['fullname'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            address: data['address'] ?? '',
            city: data['city'] ?? '',
            postalCode: data['postalCode'] ?? '',
            totalAmount: (data['totalAmount'] ?? 0).toDouble(),
            paymentMethod: paymentMethod,
            orderDate: orderDate,
            paymentStatus: paymentStatus,
            khaltiTransactionId: data['khaltiTransactionId'],
            khaltiProductId: data['khaltiProductId'],
            khaltiRefId: data['khaltiRefId'],
            paymentDate: data['paymentDate'] != null 
                ? (data['paymentDate'] as Timestamp).toDate()
                : null,
          );
        }).toList();
      });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(orderId).update(
        {'status': newStatus.name},
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updateOrderPaymentStatus(String orderId, PaymentStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(orderId).update(
        {'paymentStatus': newStatus.name},
      );
    } catch (e) {
      throw Exception('Failed to update order payment status: $e');
    }
  }


  Future<void> addJerseyToFavorites(
    String jerseyId,
    Map<String, dynamic> jerseyData,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final favoritesRef = FirebaseFirestore.instance
          .collection('Favorites')
          .doc(user.uid)
          .collection('Jerseys')
          .doc(jerseyId);

      await favoritesRef.set(jerseyData);
      print("Jersey added to favorites.");
    } catch (e) {
      print("Failed to add jersey to favorites: $e");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Return an empty stream if not logged in
      return const Stream.empty();
    }

    final favoritesRef = FirebaseFirestore.instance
        .collection('Favorites')
        .doc(user.uid)
        .collection('Jerseys');

    return favoritesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'jerseyId': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Future<void> removeJerseyFromFavorites(String jerseyId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final favoritesRef = FirebaseFirestore.instance
        .collection('Favorites')
        .doc(user.uid)
        .collection('Jerseys')
        .doc(jerseyId);

    await favoritesRef.delete();
    print("Jersey removed from favorites.");
  }

  Future<bool> isJerseyFavorited(String jerseyId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await FirebaseFirestore.instance
        .collection('Favorites')
        .doc(user.uid)
        .collection('Jerseys')
        .doc(jerseyId)
        .get();

    return doc.exists;
  }

  Stream<List<JerseyModel>> searchJerseysStream(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    // Fetch a broader subset, e.g., all jerseys or jerseys where jerseyTitle starts with first letter
    // Here, we just fetch all jerseys - be careful if you have huge data.
    return FirebaseFirestore.instance.collection('Jersey').snapshots().map((
      snapshot,
    ) {
      // Map docs to models
      final allJerseys = snapshot.docs.map((doc) {
        return JerseyModel.fromJson(doc.data());
      }).toList();

      // Filter locally in the app for partial contains match (case-insensitive)
      final lowerQuery = query.toLowerCase();
      return allJerseys.where((jersey) {
        final title = jersey.jerseyTitle.toLowerCase();
        return title.contains(lowerQuery);
      }).toList();
    });
  }

  // Alternative search method using multiple fields
  Stream<List<JerseyModel>> searchJerseysAdvancedStream(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    final lowercaseQuery = query.toLowerCase();

    return FirebaseFirestore.instance.collection('Jersey').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return JerseyModel.fromJson(data);
          })
          .where((jersey) {
            final title = jersey.jerseyTitle.toLowerCase();
            final description = jersey.jerseyDescription.toLowerCase();

            return title.contains(lowercaseQuery) ||
                description.contains(lowercaseQuery);
          })
          .toList();
    });
  }

  Future<void> updateJerseyStock(String jerseyId, int newStock) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Jersey')
        .where("jerseyId", isEqualTo: jerseyId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Jersey not found');
    }

    final docRef = querySnapshot.docs.first.reference;
    await docRef.update({'stock': newStock});
  } catch (e) {
    throw Exception('Failed to update jersey stock: $e');
  }
}


Stream<List<CartItemModel>> getCartItems(String userId) {
  return FirebaseFirestore.instance
      .collection('Cart')
      .doc(userId)
      .collection('CartItems')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => CartItemModel.fromMap(doc.data())).toList());
}

  Future<void> addToCart(String userId, CartItemModel cartItem) async {
  final cartRef = FirebaseFirestore.instance
      .collection('Cart')
      .doc(userId)
      .collection('CartItems');

  // Check if the item already exists (same jerseyId + size)
  final existing = await cartRef
      .where('jerseyId', isEqualTo: cartItem.jersey.jerseyId)
      .where('selectedSize', isEqualTo: cartItem.selectedSize)
      .get();

  if (existing.docs.isNotEmpty) {
    // Update quantity if already in cart
    final docId = existing.docs.first.id;
    final currentQty = existing.docs.first['quantity'] as int;

    await cartRef.doc(docId).update({
      'quantity': currentQty + cartItem.quantity,
    });
  } else {
    // Add new item
    final newDoc = cartRef.doc();
    await newDoc.set(cartItem.copyWith(id: newDoc.id).toMap());
  }
}

  Future<void> deleteFromCart(String itemId,String userId) async {
    
    await FirebaseFirestore.instance
        .collection('Cart')
        .doc(userId)
        .collection('CartItems')
        .doc(itemId)
        .delete();
  }
    Future<void> clearCart(String userId) async {

    
    final batch = FirebaseFirestore.instance.batch();
    final cartRef = FirebaseFirestore.instance
        .collection('Carts')
        .doc(userId)
        .collection('CartItems');
    
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

}
