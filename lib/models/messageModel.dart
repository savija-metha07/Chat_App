import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String from;
  final String to;
  final String msg;
  final String uqnm;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.from,
    required this.to,
    required this.msg,
    required this.uqnm,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      from: map['from'],
      to: map['to'],
      msg: map['msg'],
      uqnm: map['uqnm'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'msg': msg,
      'uqnm':uqnm,
      'timestamp': timestamp,
    };
  }
}
