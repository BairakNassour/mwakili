class MessageModel {
  final String text;
  final bool isMe;
  final String time;

  MessageModel({
    required this.text,
    required this.isMe,
    required this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      text: json['text'] ?? '',
      isMe: json['isMe'] ?? false,
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isMe': isMe,
      'time': time,
    };
  }
}