import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/Utility/app_snackbar.dart';
import '../../Presentation/Owner Screen/Screens/owner_info_screens.dart';
import 'offline_providers.dart';

class OfflineDemoScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const OfflineDemoScreen({super.key, required this.sessionId});

  @override
  ConsumerState<OfflineDemoScreen> createState() => _OfflineDemoScreenState();
}

class _OfflineDemoScreenState extends ConsumerState<OfflineDemoScreen> {
  bool _pushing = false;
  Map<String, dynamic>? _payload;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(offlineSyncDbProvider);
    final p = await db.getOwnerPayload(widget.sessionId);
    setState(() => _payload = p);
  }

  double get progress {
    // ✅ For now only Owner step = 33%
    // Later: Owner+Shop+Product => 100%
    return 0.33;
  }

  @override
  Widget build(BuildContext context) {
    final ownerName =
        (_payload?["fullName"] ?? _payload?["govtRegisteredName"] ?? "")
            .toString();
    final phone = (_payload?["ownerPhoneNumber"] ?? "").toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Offline Saved")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _payload == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Owner Details",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    _infoTile("Name", ownerName.isEmpty ? "-" : ownerName),
                    _infoTile("Phone", phone.isEmpty ? "-" : phone),

                    const SizedBox(height: 24),

                    Text(
                      "Sync Progress",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),

                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 8),
                    Text("${(progress * 100).round()}% completed"),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _pushing
                                ? null
                                : () async {
                                  setState(() => _pushing = true);

                                  final engine = ref.read(
                                    offlineSyncEngineProvider,
                                  );
                                  final err = await engine.pushOwner(
                                    widget.sessionId,
                                  );

                                  setState(() => _pushing = false);

                                  if (err == null) {
                                    AppSnackBar.success(
                                      context,
                                      "Owner synced successfully!",
                                    );
                                    return;
                                  }

                                  // ✅ show real error first
                                  AppSnackBar.error(context, err);

                                  // ✅ if missing token -> send user to OTP screen
                                  if (err.contains(
                                    "Phone verification token is required",
                                  )) {
                                    // go to OwnerInfoScreens and wait until verified
                                    final verified = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => OwnerInfoScreens(
                                              isService:
                                                  true, // pass your real values
                                              isIndividual:
                                                  true, // pass your real values
                                              // ✅ add these two params in OwnerInfoScreens
                                              fromOffline: true,
                                              offlineSessionId:
                                                  widget.sessionId,
                                            ),
                                      ),
                                    );

                                    // if user verified otp, retry push automatically
                                    if (verified == true && mounted) {
                                      setState(() => _pushing = true);
                                      final err2 = await engine.pushOwner(
                                        widget.sessionId,
                                      );
                                      setState(() => _pushing = false);

                                      if (err2 == null) {
                                        AppSnackBar.success(
                                          context,
                                          "Owner synced successfully!",
                                        );
                                      } else {
                                        AppSnackBar.error(context, err2);
                                      }
                                    }
                                  }
                                },

                        child:
                            _pushing
                                ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text("Push to API"),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
