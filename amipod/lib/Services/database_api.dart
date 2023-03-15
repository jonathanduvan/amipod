import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseAPI {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Set<List<QueryDocumentSnapshot<Object?>>>> getConnectionsInfo(
      List ids) {
    return db.collection('users').get().then(
        (QuerySnapshot value) => {value.docs},
        onError: (e) => {print(e)});
  }

  void setUser(String id, Map<String, dynamic> value) {
    print('made it to the firebase call');
    db.collection('users').doc(id).set(value, SetOptions(merge: true));
  }
}
