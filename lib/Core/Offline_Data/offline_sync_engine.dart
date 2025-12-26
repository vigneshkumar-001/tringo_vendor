import '../../Api/DataSource/api_data_source.dart';
import '../Utility/app_prefs.dart';
import 'offline_sync_db.dart';

class OfflineSyncEngine {
  final OfflineSyncDb db;
  final ApiDataSource api;
  OfflineSyncEngine({required this.db, required this.api});


  Future<String> enqueueOwnerOnly({
    required Map<String, dynamic> ownerPayload,
  }) async {
    final sessionId = await db.createSession();
    await db.addOwnerStep(sessionId: sessionId, payload: ownerPayload);
    return sessionId;
  }
  Future<String?> pushOwner(String sessionId) async {
    final payload = await db.getOwnerPayload(sessionId);
    if (payload == null) return "Offline payload not found.";
    final res = await api.ownerInfoRegister(
      businessType: payload["businessType"] ?? "",
      ownershipType: payload["ownershipType"] ?? "",
      govtRegisteredName: payload["govtRegisteredName"] ?? "",
      preferredLanguage: payload["preferredLanguage"] ?? "",
      gender: payload["gender"] ?? "",
      dateOfBirth: payload["dateOfBirth"] ?? "",
      fullName: payload["fullName"] ?? "",
      ownerNameTamil: payload["ownerNameTamil"] ?? "",
      email: payload["email"] ?? "",
      ownerPhoneNumber: (payload["ownerPhoneNumber"] ?? "").toString().replaceAll("+91", ""),
    );

    return res.fold(
          (failure) => failure.message, // ✅ exact API error message
          (response) async {
        final id = response.data?.id ?? "";
        if (id.isNotEmpty) {
          await AppPrefs.setBusinessProfileId(id);
        }
        return null; // ✅ success (no error)
      },
    );
  }
}
