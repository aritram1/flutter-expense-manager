// file : message.dart
class FinPlanMessage {
  final String content;
  final String sender;
  final DateTime receivedAt;
  final String id;

  const FinPlanMessage({
    required this.content,
    required this.sender,
    required this.receivedAt,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'sender': sender,
      'receivedAt': receivedAt.toIso8601String(), // Convert DateTime to String
      'id': id,
    };
  }
}