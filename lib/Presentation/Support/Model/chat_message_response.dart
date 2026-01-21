class ChatMessageResponse {
  final bool status;
  final ChatMessageResponseData data;

  ChatMessageResponse({required this.status, required this.data});

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      status: json['status'] ?? false,
      data: ChatMessageResponseData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
}

class ChatMessageResponseData {
  final Ticket ticket;
  final List<Message> messages;

  ChatMessageResponseData({required this.ticket, required this.messages});

  factory ChatMessageResponseData.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponseData(
      ticket: Ticket.fromJson(json['ticket'] ?? {}),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => Message.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ticket': ticket.toJson(),
    'messages': messages.map((e) => e.toJson()).toList(),
  };
}

class Ticket {
  final String id;
  final String subject;
  final String status;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}

class Message {
  final String id;
  final String message;
  final List<Attachment> attachments;
  final String senderRole;
  final String senderUserId;
  final DateTime createdAt;
  final bool isInternal;

  Message({
    required this.id,
    required this.message,
    required this.attachments,
    required this.senderRole,
    required this.senderUserId,
    required this.createdAt,
    required this.isInternal,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => Attachment.fromJson(e))
          .toList(),
      senderRole: json['senderRole'] ?? '',
      senderUserId: json['senderUserId'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isInternal: json['isInternal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'senderRole': senderRole,
    'senderUserId': senderUserId,
    'createdAt': createdAt.toIso8601String(),
    'isInternal': isInternal,
  };
}

class Attachment {
  final String url;

  Attachment({required this.url});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() => {'url': url};
}
