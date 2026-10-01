class ChatMessageModel {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String message;
  final String messageType;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      chatRoomId: int.parse(json['chat_room_id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      message: json['message'],
      messageType: json['message_type'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
