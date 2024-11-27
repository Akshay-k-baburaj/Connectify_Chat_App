import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? fileUrl;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.fileUrl,
  });

  // convert to map
  Map<String, dynamic> toMap() {
    return fileUrl == null
        ? {
            'senderID': senderID,
            'senderEmail': senderEmail,
            'receiverID': receiverID,
            'message': message,
            'timestamp': timestamp,
          }
        : fileUrl!.isEmpty
            ? {
                'senderID': senderID,
                'senderEmail': senderEmail,
                'receiverID': receiverID,
                'message': message,
                'timestamp': timestamp,
              }
            : {
                'senderID': senderID,
                'senderEmail': senderEmail,
                'receiverID': receiverID,
                'message': message,
                'timestamp': timestamp,
                'fileUrl': fileUrl
              };
  }
}
