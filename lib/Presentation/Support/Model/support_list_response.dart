enum SupportStatus { pending, resolved, closed, unknown,OPEN }

SupportStatus supportStatusFromString(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return SupportStatus.pending;
    case 'RESOLVED':
      return SupportStatus.resolved;
    case 'CLOSED':
      return SupportStatus.closed;
    case 'OPEN':
      return SupportStatus.OPEN;
    default:
      return SupportStatus.unknown;
  }
}

String supportStatusToString(SupportStatus status) {
  switch (status) {
    case SupportStatus.pending:
      return 'PENDING';
    case SupportStatus.resolved:
      return 'RESOLVED';
    case SupportStatus.closed:
      return 'CLOSED';
    case SupportStatus.OPEN:
      return 'OPEN';
    case SupportStatus.unknown:
      return 'UNKNOWN';
  }
}

class SupportListResponse {
  bool status;
  List<SupportTicket> data;

  SupportListResponse({required this.status, required this.data});

  factory SupportListResponse.fromJson(Map<String, dynamic> json) {
    return SupportListResponse(
      status: json['status'] ?? false,
      data: List<SupportTicket>.from(
        (json['data'] ?? []).map((x) => SupportTicket.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.map((x) => x.toJson()).toList(),
  };
}

class SupportTicket {
  String id;
  String subject;
  SupportStatus status;
  String updatedAt;
  String createdAt;
  String lastMessageAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      status: supportStatusFromString(json['status'] ?? 'UNKNOWN'),
      createdAt : json['createdAt'] ?? '',
      updatedAt : json['updatedAt'] ?? '',
      lastMessageAt : json['lastMessageAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'status': supportStatusToString(status),
    'updatedAt': updatedAt ,
    'lastMessageAt': lastMessageAt ,
    'createdAt': createdAt ,
  };
}


// class SupportListResponse {
//   bool status;
//   List<SupportTicket> data;
//
//   SupportListResponse({required this.status, required this.data});
//
//   factory SupportListResponse.fromJson(Map<String, dynamic> json) {
//     return SupportListResponse(
//       status: json['status'],
//       data: List<SupportTicket>.from(
//           json['data'].map((x) => SupportTicket.fromJson(x))),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'status': status,
//     'data': data.map((x) => x.toJson()).toList(),
//   };
// }
//
// class SupportTicket {
//   String id;
//   String subject;
//   String status;
//   DateTime updatedAt;
//   DateTime lastMessageAt;
//
//   SupportTicket({
//     required this.id,
//     required this.subject,
//     required this.status,
//     required this.updatedAt,
//     required this.lastMessageAt,
//   });
//
//   factory SupportTicket.fromJson(Map<String, dynamic> json) {
//     return SupportTicket(
//       id: json['id'],
//       subject: json['subject'],
//       status: json['status'],
//       updatedAt: DateTime.parse(json['updatedAt']),
//       lastMessageAt: DateTime.parse(json['lastMessageAt']),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'subject': subject,
//     'status': status,
//     'updatedAt': updatedAt.toIso8601String(),
//     'lastMessageAt': lastMessageAt.toIso8601String(),
//   };
// }
