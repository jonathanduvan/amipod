import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dipity/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseAPI {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<Set<List<QueryDocumentSnapshot<Object?>>>> getConnectionsInfo(
      List ids) {
    // List partitions = []; // this is an array of arrays

    // for (var i = 0; i < ids.length; i += 10) {
    //   // this aggregates and transforms the array into 10 elements
    //   // for each partition
    //   List partition = ids.sublist(i, i + 10);
    //   partitions.add(
    //       db.collection('users').where(FieldPath.documentId, whereIn: ids).get().then((QuerySnapshot value) => {value.docs},
    //         onError: (e) => {print(e)}));
    // }

    // Now make the query for each partition and map-reduce to
    // obtain a unified list of results

    return db
        .collection('users')
        // .where(FieldPath.documentId, whereIn: ids)
        .get()
        .then((QuerySnapshot value) => {value.docs},
            onError: (e) => {print(e)});
  }

  String cleanId(String rawId) {
    String newId = rawId.replaceAll(RegExp(r'/'), '^DIPITY^');
    return newId;
  }

  String appId(String dbId) {
    String newId = dbId.replaceAll('^DIPITY^', '/');
    return newId;
  }

  void setUnchartedMode(String id, Map<String, dynamic> mode) async {
    String finalId = cleanId(id);
    await db
        .collection('users')
        .doc(finalId)
        .set(mode, SetOptions(merge: true));
  }

  void setUser(
    String id,
    Map<String, dynamic> value,
  ) async {
    print('made it to the firebase call');
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    Map<String, dynamic> historicValue = {
      "position": value['position'],
      "location": value['location']
    };

    value['last_update'] = date.toString();

    // final Future<DocumentSnapshot<Map<String, dynamic>>> ref = db.collection("users").doc(id).get();
    // final DocumentSnapshot<Map<String, dynamic>> snapShot = await ref;

    String finalId = cleanId(id);
    await db
        .collection('users')
        .doc(finalId)
        .set(value, SetOptions(merge: true));

    print('okay we set the user');

    // QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection('users').doc(id).collection('locations_history').limit(1).get();
    String dateId = date.toString();
    //doesnt exist
    await db
        .collection('users')
        .doc(finalId)
        .collection('locations_history')
        .doc(dateId)
        .set(historicValue, SetOptions(merge: true));
  }

  deleteUser(String id) {
    String finalId = cleanId(id);
    db.collection('users').doc(finalId).delete();
  }

  autherizeUser(String smsCode, String verificationId, int? resendToken,
      BuildContext context, Function onUserAuthorized) async {
    // Update the UI - wait for the user to enter the SMS code

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    try {
      print('awaitng credential');
      await auth.signInWithCredential(
        credential,
      );
      onUserAuthorized();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Invalid Code. Please type in the correct code or ask for a new one.',
                style: TextStyle(color: backgroundColor)),
            backgroundColor: Colors.amber,
          ),
        );
      } else {
        print('on the error now');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error authenticating number. Please wait and ask for a new code.',
                style: TextStyle(color: backgroundColor)),
            backgroundColor: Colors.amber,
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  Future verifyPhoneNumber(String phone, Function onCodeSent,
      Function onUserAuthorized, BuildContext context) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        print('verification complete!');
        onUserAuthorized();
      },
      verificationFailed: (FirebaseAuthException e) {
        print('OK SICK THE ERROR GOES IN HERE');
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Invalid phone number. Please go back and type in a correct US number'),
              backgroundColor: Colors.white70,
            ),
          );
        } else if (e.code == '') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error authenticating your number.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                    'Error authenticating your number, please try again later.')),
          );
        }
        // TODO: handle other errors
      },
      codeSent: (String verificationId, int? resendToken) {
        // Sign the user in (or link) with the credential
        // await auth.signInWithCredential(credential);
        onCodeSent(phone, verificationId, resendToken, autherizeUser);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> isUncharted(String id) async {
    String finalId = cleanId(id);
    DocumentSnapshot<Map<String, dynamic>> userInfo =
        await db.collection('users').doc(finalId).get();

    try {
      bool uncharted = userInfo.get('uncharted');
      return uncharted;
    } catch (error) {
      print('error looking for value');
      return false;
    }
  }

  // Check to see if user is the contact's contact list in the db
  Future<Set<Map<String, dynamic>?>> checkContact(
      String userId, String contactId) {
    String finalUserId = cleanId(userId);
    String finalContactId = cleanId(contactId);

    DocumentReference<Map<String, dynamic>> contactDoc = db
        .collection('users')
        .doc(finalContactId)
        .collection('contacts')
        .doc(finalUserId);
    return contactDoc
        .get()
        .then((value) => {value.data()}, onError: (e) => {print(e)});
  }

  updateContact(
      String userId, String connId, Map<String, dynamic> value) async {
    String finalUserId = cleanId(userId);
    String finalBlockId = cleanId(connId);

    await db
        .collection('users')
        .doc(finalUserId)
        .collection('contacts')
        .doc(finalBlockId)
        .set(value, SetOptions(merge: true));
  }

  block(String userId, String blockId) async {
    Map<String, dynamic> blockedVal = {
      "blocked": true,
    };

    String finalUserId = cleanId(userId);
    String finalBlockId = cleanId(blockId);

    await db
        .collection('users')
        .doc(finalUserId)
        .collection('contacts')
        .doc(finalBlockId)
        .set(blockedVal, SetOptions(merge: true));
  }

  unblock(String userId, String blockId) async {
    Map<String, dynamic> blockedVal = {
      "blocked": false,
    };
    String finalUserId = cleanId(userId);
    String finalBlockId = cleanId(blockId);
    await db
        .collection('users')
        .doc(finalUserId)
        .collection('contacts')
        .doc(finalBlockId)
        .set(blockedVal, SetOptions(merge: true));
  }
}
