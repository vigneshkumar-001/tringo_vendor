import 'dart:convert';

enum SyncSessionStatus { pending, syncing, failed, completed }
enum SyncStepStatus { pending, success, failed }
enum SyncStepType { owner, shop, product }

String enumName(Object e) => e.toString().split('.').last;

SyncStepStatus stepStatusFrom(String s) => SyncStepStatus.values.firstWhere(
      (e) => enumName(e) == s,
  orElse: () => SyncStepStatus.pending,
);

SyncStepType stepTypeFrom(String s) => SyncStepType.values.firstWhere(
      (e) => enumName(e) == s,
  orElse: () => SyncStepType.owner,
);

class SyncStep {
  final String id;
  final String sessionId;
  final SyncStepType type;
  SyncStepStatus status;
  Map<String, dynamic> payload;
  Map<String, dynamic>? result;
  String? errorMessage;

  SyncStep({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.status,
    required this.payload,
    this.result,
    this.errorMessage,
  });

  String get payloadJson => jsonEncode(payload);
  String? get resultJson => result == null ? null : jsonEncode(result);
}
