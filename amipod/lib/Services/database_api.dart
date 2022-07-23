import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseAPI {
  FirebaseFirestore db = FirebaseFirestore.instance;

  void getConnectionsInfo() {}
  void setUser(String id, Map<String, dynamic> value) {
    print('made it to the firebase call');
    db.collection('users').doc(id).set(value, SetOptions(merge: true));
  }
}
