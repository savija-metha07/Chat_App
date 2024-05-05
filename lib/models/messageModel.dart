import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String from;
  final String to;
  final String msg;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.from,
    required this.to,
    required this.msg,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      from: map['from'],
      to: map['to'],
      msg: map['msg'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'msg': msg,
      'timestamp': timestamp,
    };
  }
}
