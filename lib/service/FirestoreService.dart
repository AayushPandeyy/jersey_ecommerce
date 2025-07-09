import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentMethod.dart';
import 'package:jersey_ecommerce/models/OrderModel.dart';
import '../models/JerseyModel.dart';

class FirestoreService {

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

  Future<void> addUserToDatabase(
      String uid, email, fullname, phoneNumber) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      'uid': uid,
      "email": email,
      "fullname": fullname,
      "phoneNumber": phoneNumber,

    });
  }
  Stream<List<JerseyModel>> getJerseysStream() {
    return FirebaseFirestore.instance
        .collection('Jersey')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JerseyModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<void> addJersey(JerseyModel jersey) async {
    await FirebaseFirestore.instance
        .collection('Jersey')
        .add(jersey.toMap());
  }
  Future<void> updateJersey(String id, JerseyModel jersey) async {
    await FirebaseFirestore.instance
        .collection('Jersey')
        .doc(id)
        .update(jersey.toMap());
  }
  Future<void> deleteJersey(String id) async {
    await FirebaseFirestore.instance
        .collection('Jersey')
        .doc(id)
        .delete();
  }

  Future<JerseyModel?> getJerseyById(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Jersey')
        .doc(id)
        .get();
    if (doc.exists) {
      return JerseyModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

Future<void> addOrder(String userId, OrderModel order) async {
  await FirebaseFirestore.instance.collection('Orders').add({
    'userId': userId,
    'jersey': {
      'jerseyTitle': order.jersey.jerseyTitle,
      'jerseyDescription': order.jersey.jerseyDescription,
      'jerseyImage': order.jersey.jerseyImage,
      'jerseyPrice': order.jersey.jerseyPrice,
      'rating': order.jersey.rating,
      // Add other jersey fields if needed
    },
    'selectedSize': order.selectedSize, // Renamed to match getter in fetch
    'quantity': order.quantity,
    'fullname': order.fullname,
    'phoneNumber': order.phoneNUmber,  // Fixed typo: phoneNUmber → phoneNumber
    'address': order.address,
    'city': order.city,
    'postalCode': order.postalCode,
    'status': order.status.name,
    'paymentMethod': order.paymentMethod.name,
    'totalAmount':order.totalAmount,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Stream<List<OrderModel>> getUserOrders(String userId) {
  return FirebaseFirestore.instance
      .collection('Orders')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final data = doc.data();

      final jerseyModel = JerseyModel(
        jerseyTitle: data['jersey']['jerseyTitle'] ?? '',
        jerseyDescription: data['jersey']['jerseyDescription'] ?? '',
        jerseyPrice: (data['jersey']['jerseyPrice'] ?? 0).toDouble(),
        jerseyImage: List<String>.from(data['jersey']['jerseyImage'] ?? []),
        rating: (data['jersey']['rating'] ?? 0.0).toDouble(),
      );

      final status = OrderStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (data['status'] ?? '').toLowerCase(),
        orElse: () => OrderStatus.PENDING,
      );

      final paymentMethod = PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == (data['paymentMethod'] ?? '').toLowerCase(),
        orElse: () => PaymentMethod.CASH_ON_DELIVERY,
      );

      return OrderModel(
        id: doc.id,
        jersey: jerseyModel,
        quantity: data['quantity'] ?? 1,
        selectedSize: data['size'] ?? 'M',
        fullname: data['fullname'] ?? '',
        phoneNUmber: data['phoneNumber'] ?? '',
        address: data['address'] ?? '',
        city: data['city'] ?? '',
        postalCode: data['postalCode'] ?? '',
        totalAmount: (data['totalAmount'] ?? 0).toDouble(),
        status: status,
        paymentMethod: paymentMethod,
      );
    }).toList();
  });
}

Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
  try {
    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderId)
        .update({'status': newStatus.name});
  } catch (e) {
    throw Exception('Failed to update order status: $e');
  }
}


}


