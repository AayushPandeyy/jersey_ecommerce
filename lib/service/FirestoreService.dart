import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> addOrder(String userId, JerseyModel jersey, int quantity,String size) async {
    await FirebaseFirestore.instance.collection('Orders').add({
      'userId': userId,
      'jerseyTitle': jersey.jerseyTitle,
      'jerseyDescription': jersey.jerseyDescription,
      'jerseyImage': jersey.jerseyImage,
      'jerseyPrice': jersey.jerseyPrice,
      'size': size,                                 
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
