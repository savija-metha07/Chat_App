import 'package:chatapp/models/messageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class ChatScreen extends StatefulWidget {
    const ChatScreen({Key? key,required this.toMobileNumber}) : super(key: key);

  final String toMobileNumber;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Query senderQuery;
  late Query receiverQuery;
  late var combinedStream;


   @override
  void initState() {
    super.initState();

   

  }
 

 Stream<List<DocumentSnapshot>> _getMessagesStream() {
    var sentMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: '+919379440478')
        .where('to', isEqualTo:  widget.toMobileNumber.toString())
        .snapshots();

    var receivedMessagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: widget.toMobileNumber.toString())
        .where('to', isEqualTo: '+919379440478')
        .snapshots();

    return sentMessagesStream.asyncMap((sentSnapshot) async {
      var sentDocs = sentSnapshot.docs;
      var receivedSnapshot = await receivedMessagesStream.first;
      var receivedDocs = receivedSnapshot.docs;
      var allDocs = [...sentDocs, ...receivedDocs];
      allDocs.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
      return allDocs;
    });
  }

  int addNum(int a, int b){
    return a+b;

  }
  

  Stream<List<QueryDocumentSnapshot>> _getMessagesStream2() {
    var sentMessagesStream = FirebaseFirestore.instance
        .collection('messages')
       .where('from', isEqualTo: '+919379440478')
        .where('to', isEqualTo:  widget.toMobileNumber.toString())
        .snapshots();

    var receivedMessagesStream = FirebaseFirestore.instance
        .collection('messages')
       .where('from', isEqualTo: widget.toMobileNumber.toString())
        .where('to', isEqualTo: '+919379440478')
        .snapshots();

    return StreamZip([sentMessagesStream, receivedMessagesStream]).map((snapshots) {
      var allDocs = <QueryDocumentSnapshot>[];
      for (var snapshot in snapshots) {
        allDocs.addAll(snapshot.docs);
      }
      allDocs.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
      return allDocs;
    });
  }
  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final messageData = Message(
      id: '',
      from: '+919379440478',
      to: widget.toMobileNumber.toString(),
      // from:  widget.toMobileNumber.toString(),
      // to: '+919379440478',
      msg: message,
      uqnm: addNum(int.parse(widget.toMobileNumber.toString().substring(1)), int.parse('+919379440478'.substring(1))).toString(),
      timestamp: Timestamp.now(),
    );

    FirebaseFirestore.instance.collection('messages').add(messageData.toMap());
    _controller.clear();
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('uqnm', isEqualTo: addNum(int.parse(widget.toMobileNumber.toString().substring(1)), int.parse('+919379440478'.substring(1))).toString(),)
                .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context,  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No messages found.'));
          } else {
             final messages = snapshot.data!.docs.map((doc) {
                  return Message.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.from== '+919379440478';

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.msg,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      
                    );
                  },
                );
              }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
