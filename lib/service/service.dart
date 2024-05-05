import 'package:chatapp/models/messageModel.dart';
import 'package:chatapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Services{

  Future<void> addUserToFirestore(User user) async {
  try {
    // Get a reference to the Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Add the user to Firestore
    await users.doc(user.id).set(user.toMap());

    print('User added successfully to Firestore!');
  } catch (e) {
    print('Error adding user to Firestore: $e');
  }
}

  Future<List<Message>> getMessages(String currentUser, String otherUser) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('messages')
      .where('from', isEqualTo: currentUser)
      .where('to', isEqualTo: otherUser)
      .get();

  QuerySnapshot otherUserMessages = await FirebaseFirestore.instance
      .collection('messages')
      .where('from', isEqualTo: otherUser)
      .where('to', isEqualTo: currentUser)
      .get();

  List<Message> allMessages = [];

  querySnapshot.docs.forEach((doc) {
    allMessages.add(Message.fromMap(doc.data() as Map<String, dynamic>, doc.id));
  });

  otherUserMessages.docs.forEach((doc) {
    allMessages.add(Message.fromMap(doc.data() as Map<String, dynamic>, doc.id));
  });

  // Sort messages by timestamp
  allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  return allMessages;
}



}