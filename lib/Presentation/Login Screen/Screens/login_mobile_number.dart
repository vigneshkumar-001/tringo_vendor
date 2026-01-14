import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/sim_token.dart';
import '../../../../Core/Widgets/caller_id_role_helper.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';

import '../../../Core/Utility/app_textstyles.dart';
import '../../../Core/Widgets/app_go_routes.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../Mobile Nomber Verify/Controller/mobile_verify_notifier.dart';
import '../controller/login_notifier.dart';

class LoginMobileNumber extends ConsumerStatefulWidget {
  final String loginNumber;
  final String simToken;
  const LoginMobileNumber({
    super.key,
    required this.loginNumber,
    required this.simToken,
  });

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber>
    with WidgetsBindingObserver {
  bool isWhatsappChecked = false;
  String errorText = '';
  bool _isFormatting = false;

  final TextEditingController mobileNumberController = TextEditingController();
  String? _lastRawPhone;

  ProviderSubscription<LoginState>? _sub;

  String _selectedDialCode = '+91';
  String _selectedFlag = '🇮🇳';

  static const MethodChannel _native = MethodChannel('sim_info');

  bool _openingSystemRole = false;
  bool _askedOnce = false;

  // ✅ to avoid multiple triggers
  bool _waitingWhatsapp = false;
  bool _whatsappLoginTriggered = false;

  // ✅ NEW: last attempt SIM1 eligibility + token store
  bool _sim1EligibleForLastAttempt = false;
  String _simTokenForLastAttempt = '';

  Future<void> _ensurePhonePermission() async {
    try {
      final hasPermission = await MobileNumber.hasPhonePermission;
      if (!hasPermission) {
        await MobileNumber.requestPhonePermission;
      }
      final after = await MobileNumber.hasPhonePermission;
      debugPrint('PHONE PERMISSION AFTER REQUEST: $after');
    } catch (e, st) {
      debugPrint('❌ Error requesting phone permission: $e');
      debugPrint('$st');
    }
  }

  Future<bool> _isDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return true;
      final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
      debugPrint("✅ isDefaultCallerIdApp => $ok");
      return ok ?? false;
    } catch (e) {
      debugPrint('❌ isDefaultCallerIdApp error: $e');
      return false;
    }
  }

  Future<void> _requestDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return;
      debugPrint("🔥 calling requestDefaultCallerIdApp...");
      await _native.invokeMethod('requestDefaultCallerIdApp');
      debugPrint("✅ requestDefaultCallerIdApp invoked");
    } catch (e) {
      debugPrint('❌ requestDefaultCallerIdApp error: $e');
    }
  }

  Future<void> _maybeShowSystemCallerIdPopupOnce() async {
    if (!mounted) return;
    if (!Platform.isAndroid) return;
    if (_openingSystemRole) return;
    if (_askedOnce) return;

    final ok = await _isDefaultCallerIdApp();
    if (ok) return;

    _askedOnce = true;
    _openingSystemRole = true;

    await _requestDefaultCallerIdApp();

    await Future.delayed(const Duration(milliseconds: 300));
    _openingSystemRole = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensurePhonePermission();

      final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
      if (!overlayOk) {
        await CallerIdRoleHelper.requestOverlayPermission();
      }

      await CallerIdRoleHelper.maybeAskOnce(ref: ref);
    });

    _sub = ref.listenManual<LoginState>(loginNotifierProvider, (
      prev,
      next,
    ) async {
      if (!mounted) return;

      // ✅ error
      if (prev?.error != next.error && next.error != null) {
        AppSnackBar.error(context, next.error!);
        return;
      }

      // ✅ WhatsApp verify response (FIXED: SIM token only if SIM1 eligible)
      if (prev?.whatsappResponse != next.whatsappResponse &&
          next.whatsappResponse != null) {
        final resp = next.whatsappResponse!;
        final hasWhatsapp = resp.data.hasWhatsapp == true;

        _waitingWhatsapp = false;

        if (!hasWhatsapp) {
          if (mounted) setState(() => isWhatsappChecked = false);
          AppSnackBar.error(
            context,
            'This number is not registered on WhatsApp. Please use a WhatsApp number.',
          );
          return;
        }

        // ✅ WhatsApp OK -> now do loginNewUser (only once)
        if (_whatsappLoginTriggered) return;
        _whatsappLoginTriggered = true;

        if (mounted) setState(() => isWhatsappChecked = true);

        final raw = _lastRawPhone;
        if (raw == null || raw.isEmpty) {
          _whatsappLoginTriggered = false;
          return;
        }

        // ✅ IMPORTANT: SIM token ONLY IF last attempt was SIM1 eligible
        final String simTokenToSend =
            _sim1EligibleForLastAttempt ? _simTokenForLastAttempt : '';

        // ✅ clear stale state so otpLoginResponse listener triggers cleanly
        ref.read(loginNotifierProvider.notifier).resetState();

        await ref
            .read(loginNotifierProvider.notifier)
            .loginNewUser(phoneNumber: raw, simToken: simTokenToSend);

        _whatsappLoginTriggered = false;
        return;
      }

      // ✅ OTP login response navigation (your existing)
      if (prev?.otpLoginResponse != next.otpLoginResponse &&
          next.otpLoginResponse != null) {
        await _ensurePhonePermission();
        if (!mounted) return;

        final otpLoginResponse = next.otpLoginResponse!;

        if (_allowDirectHome == true &&
            otpLoginResponse.data?.simVerified == true) {
          if (otpLoginResponse.data?.isNewOwner == true) {
            context.go(AppRoutes.privacyPolicyPath);
          } else {
            context.go(AppRoutes.heaterHomeScreenPath);
          }
        } else {
          context.pushNamed(AppRoutes.otp, extra: _lastRawPhone ?? '');
        }

        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });
  }

  bool numberMatch = false;
  bool loaded = false;
  bool anySimHasNumber = false;
  List<SimCard> sims = [];
  int? matchedSlotIndex;
  bool _simVerifyTriggered = false;
  bool _allowDirectHome = false;

  String _normalizeNumber(String num) {
    var n = num.replaceAll(RegExp(r'\D'), '');
    if (n.length > 10) {
      n = n.substring(n.length - 10);
    }
    return n;
  }

  int _uiIndexFromSlot(int? slotIndex, int listIndex) {
    if (slotIndex == null) return listIndex.clamp(0, 1);
    if (slotIndex == 0 || slotIndex == 1) return slotIndex;
    if (slotIndex == 2) return 1;
    if (slotIndex <= 0) return 0;
    return 1;
  }

  Future<void> _triggerSimVerifyDirect({
    required String phone,
    required String simToken,
  }) async {
    if (_simVerifyTriggered) return;
    _simVerifyTriggered = true;

    final notifier = ref.read(mobileVerifyProvider.notifier);

    await notifier.mobileVerify(
      contact: phone.trim(),
      simToken: simToken,
      purpose: 'LOGIN',
    );

    if (!mounted) return;

    final state = ref.read(mobileVerifyProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
      _simVerifyTriggered = false;
      return;
    }

    final simResponse = state.simVerifyResponse;
    if (simResponse != null && simResponse.data.simVerified == true) {
      if (simResponse.data.isNewOwner == true) {
        context.go(AppRoutes.privacyPolicyPath);
      } else {
        context.go(AppRoutes.heaterHomeScreenPath);
      }
    } else {
      context.pushNamed(AppRoutes.otp, extra: phone);
    }
  }

  Future<void> loadSimInfoFor(String enteredPhone) async {
    try {
      var hasPermission = await MobileNumber.hasPhonePermission;

      if (!hasPermission) {
        await MobileNumber.requestPhonePermission;
        hasPermission = await MobileNumber.hasPhonePermission;
      }

      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          loaded = true;
          anySimHasNumber = false;
          numberMatch = false;
          matchedSlotIndex = null;
        });
        return;
      }

      final simCards = await MobileNumber.getSimCards;
      sims = simCards ?? [];
      matchedSlotIndex = null;

      bool localAnySimHasNumber = false;
      final loginNorm = _normalizeNumber(enteredPhone.trim());

      for (int i = 0; i < sims.length; i++) {
        final sim = sims[i];
        final raw = (sim.number ?? '').trim();
        final norm = _normalizeNumber(raw);
        final uiIndex = _uiIndexFromSlot(sim.slotIndex, i);

        if (norm.isNotEmpty) {
          localAnySimHasNumber = true;
          if (norm == loginNorm) {
            matchedSlotIndex = uiIndex; // 0=SIM1, 1=SIM2
          }
        }
      }

      if (!mounted) return;
      setState(() {
        anySimHasNumber = localAnySimHasNumber;
        numberMatch = matchedSlotIndex != null;
        loaded = true;
      });
    } catch (e, st) {
      debugPrint("❌ SIM Load Error: $e");
      debugPrint("$st");
      if (!mounted) return;
      setState(() => loaded = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 400));
      final ok = await _isDefaultCallerIdApp();
      debugPrint("🔁 resumed default ok? $ok");
      if (ok) _askedOnce = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.close();
    mobileNumberController.dispose();
    super.dispose();
  }

  void _formatPhoneNumber(String value) {
    setState(() => errorText = '');
    if (_isFormatting) return;
    _isFormatting = true;

    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 4 || i == 7) formatted += ' ';
      formatted += digitsOnly[i];
    }

    mobileNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _isFormatting = false;
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedDialCode = '+${country.phoneCode}';
          _selectedFlag = country.flagEmoji;
        });
      },
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        bottomSheetHeight: 500,
      ),
    );
  }

  Widget _whatsappCheckboxTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10),
      child: ListTile(
        dense: true,
        minLeadingWidth: 0,
        horizontalTitleGap: 10,
        leading: Image.asset(AppImages.whatsAppBlack, height: 20),
        title: Text(
          'Get Instant Updates',
          style: AppTextStyles.mulish(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColor.darkBlue,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              'From Tringo on your',
              style: AppTextStyles.mulish(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColor.darkGrey,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'whatsapp',
              style: AppTextStyles.mulish(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColor.gray84,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              isWhatsappChecked = !isWhatsappChecked;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isWhatsappChecked ? AppColor.green : AppColor.darkGrey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  isWhatsappChecked
                      ? Image.asset(
                        AppImages.tickImage,
                        height: 12,
                        color: AppColor.green,
                      )
                      : const SizedBox(width: 12, height: 12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    final simState = ref.watch(mobileVerifyProvider);

    final bool isBusy = state.isLoading || simState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              fit: BoxFit.cover,
              height: double.infinity,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 50),
                          child: Image.asset(
                            AppImages.logo,
                            height: 88,
                            width: 85,
                          ),
                        ),
                        const SizedBox(height: 81),
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Login',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'With',
                                    style: AppTextStyles.mulish(
                                      fontSize: 24,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Your Mobile Number',
                                style: AppTextStyles.mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color:
                                    mobileNumberController.text.isNotEmpty
                                        ? AppColor.skyBlue
                                        : AppColor.black,
                                width:
                                    mobileNumberController.text.isNotEmpty
                                        ? 2
                                        : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _showCountryPicker,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedFlag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedDialCode,
                                        style: AppTextStyles.mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColor.gray84,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Image.asset(
                                        AppImages.drapDownImage,
                                        height: 14,
                                        color: AppColor.darkGrey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 2,
                                  height: 35,
                                  color: AppColor.white3,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: TextFormField(
                                    controller: mobileNumberController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 12,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                    onChanged: _formatPhoneNumber,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Enter Mobile Number',
                                      hintStyle: AppTextStyles.mulish(
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.borderLightGrey,
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      suffixIcon:
                                          mobileNumberController.text.isNotEmpty
                                              ? GestureDetector(
                                                onTap: () {
                                                  mobileNumberController
                                                      .clear();
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 18,
                                                      ),
                                                  child: Image.asset(
                                                    AppImages.closeImage,
                                                    width: 6,
                                                    height: 6,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _whatsappCheckboxTile(),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: CommonContainer.button2(
                            width: double.infinity,
                            loader: isBusy ? const ThreeDotsLoader() : null,
                            onTap:
                                isBusy
                                    ? null
                                    : () async {
                                      final formatted =
                                          mobileNumberController.text.trim();
                                      final rawPhone = formatted.replaceAll(
                                        ' ',
                                        '',
                                      );

                                      if (rawPhone.isEmpty) {
                                        AppSnackBar.info(
                                          context,
                                          'Please enter phone number',
                                        );
                                        return;
                                      }
                                      if (rawPhone.length != 10) {
                                        AppSnackBar.info(
                                          context,
                                          'Please enter a valid 10-digit number',
                                        );
                                        return;
                                      }

                                      _lastRawPhone = rawPhone;

                                      // 1) SIM check
                                      await loadSimInfoFor(rawPhone);

                                      // ✅ decide SIM1 eligibility for THIS attempt
                                      _sim1EligibleForLastAttempt =
                                          (numberMatch &&
                                              matchedSlotIndex == 0);

                                      // ✅ token ONLY if SIM1 eligible
                                      final fullPhone =
                                          '$_selectedDialCode$rawPhone';
                                      _simTokenForLastAttempt =
                                          _sim1EligibleForLastAttempt
                                              ? generateSimToken(fullPhone)
                                              : '';

                                      // 2) SIM1 direct verify
                                      if (_sim1EligibleForLastAttempt) {
                                        _allowDirectHome = true;

                                        await _triggerSimVerifyDirect(
                                          phone: rawPhone,
                                          simToken: _simTokenForLastAttempt,
                                        );
                                        return;
                                      }

                                      _allowDirectHome = false;

                                      // 3) Non-SIM1: Checkbox ON => WhatsApp verify first
                                      if (isWhatsappChecked) {
                                        _waitingWhatsapp = true;

                                        await notifier.verifyWhatsappNumber(
                                          contact: rawPhone,
                                          purpose: 'owner',
                                        );
                                        return; // whatsappResponse listener will continue
                                      }

                                      // 4) Checkbox OFF => direct loginNewUser (NO sim token)
                                      notifier.resetState();
                                      await notifier.loginNewUser(
                                        phoneNumber: rawPhone,
                                        simToken:
                                            '', // ✅ IMPORTANT: NO token for non-SIM1
                                      );
                                    },
                            text: 'Verify Now',
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppImages.loginScreenBottom,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber>
//     with WidgetsBindingObserver {
//   bool isWhatsappChecked = false;
//   String errorText = '';
//   bool _isFormatting = false;
//
//   final TextEditingController mobileNumberController = TextEditingController();
//   String? _lastRawPhone;
//
//   ProviderSubscription<LoginState>? _sub;
//
//   String _selectedDialCode = '+91';
//   String _selectedFlag = '🇮🇳';
//
//   static const MethodChannel _native = MethodChannel('sim_info');
//
//   bool _openingSystemRole = false;
//   bool _askedOnce = false;
//
//   // ✅ to avoid multiple triggers
//   bool _waitingWhatsapp = false;
//   bool _whatsappLoginTriggered = false;
//
//   // ✅ last attempt SIM1 eligibility + token store
//   bool _sim1EligibleForLastAttempt = false;
//   String _simTokenForLastAttempt = '';
//
//   // SIM info
//   bool numberMatch = false;
//   bool loaded = false;
//   bool anySimHasNumber = false;
//   List<SimCard> sims = [];
//   int? matchedSlotIndex;
//
//   bool _simVerifyTriggered = false;
//   bool _allowDirectHome = false;
//
//   Future<void> _ensurePhonePermission() async {
//     try {
//       final hasPermission = await MobileNumber.hasPhonePermission;
//       if (!hasPermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//       final after = await MobileNumber.hasPhonePermission;
//       debugPrint('PHONE PERMISSION AFTER REQUEST: $after');
//     } catch (e, st) {
//       debugPrint('❌ Error requesting phone permission: $e');
//       debugPrint('$st');
//     }
//   }
//
//   Future<bool> _isDefaultCallerIdApp() async {
//     try {
//       if (!Platform.isAndroid) return true;
//       final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
//       debugPrint("✅ isDefaultCallerIdApp => $ok");
//       return ok ?? false;
//     } catch (e) {
//       debugPrint('❌ isDefaultCallerIdApp error: $e');
//       return false;
//     }
//   }
//
//   Future<void> _requestDefaultCallerIdApp() async {
//     try {
//       if (!Platform.isAndroid) return;
//       debugPrint("🔥 calling requestDefaultCallerIdApp...");
//       await _native.invokeMethod('requestDefaultCallerIdApp');
//       debugPrint("✅ requestDefaultCallerIdApp invoked");
//     } catch (e) {
//       debugPrint('❌ requestDefaultCallerIdApp error: $e');
//     }
//   }
//
//   Future<void> _maybeShowSystemCallerIdPopupOnce() async {
//     if (!mounted) return;
//     if (!Platform.isAndroid) return;
//     if (_openingSystemRole) return;
//     if (_askedOnce) return;
//
//     final ok = await _isDefaultCallerIdApp();
//     if (ok) return;
//
//     _askedOnce = true;
//     _openingSystemRole = true;
//
//     await _requestDefaultCallerIdApp();
//
//     await Future.delayed(const Duration(milliseconds: 300));
//     _openingSystemRole = false;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _ensurePhonePermission();
//
//       final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
//       if (!overlayOk) {
//         await CallerIdRoleHelper.requestOverlayPermission();
//       }
//
//       await CallerIdRoleHelper.maybeAskOnce(ref: ref);
//     });
//
//     _sub = ref.listenManual<LoginState>(loginNotifierProvider, (
//       prev,
//       next,
//     ) async {
//       if (!mounted) return;
//
//       // ✅ error
//       if (prev?.error != next.error && next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         return;
//       }
//
//       // ✅ WhatsApp verify response (FIXED: SIM token only if SIM1 eligible)
//       if (prev?.whatsappResponse != next.whatsappResponse &&
//           next.whatsappResponse != null) {
//         final resp = next.whatsappResponse!;
//         final hasWhatsapp = resp.data.hasWhatsapp == true;
//
//         _waitingWhatsapp = false;
//
//         if (!hasWhatsapp) {
//           if (mounted) setState(() => isWhatsappChecked = false);
//           AppSnackBar.error(
//             context,
//             'This number is not registered on WhatsApp. Please use a WhatsApp number.',
//           );
//           return;
//         }
//
//         // ✅ WhatsApp OK -> now do loginNewUser (only once)
//         if (_whatsappLoginTriggered) return;
//         _whatsappLoginTriggered = true;
//
//         if (mounted) setState(() => isWhatsappChecked = true);
//
//         final raw = _lastRawPhone;
//         if (raw == null || raw.isEmpty) {
//           _whatsappLoginTriggered = false;
//           return;
//         }
//
//         // ✅ IMPORTANT: SIM token ONLY IF last attempt was SIM1 eligible
//         final String simTokenToSend =
//             _sim1EligibleForLastAttempt ? _simTokenForLastAttempt : '';
//
//         // ✅ clear stale state so otpLoginResponse listener triggers cleanly
//         ref.read(loginNotifierProvider.notifier).resetState();
//
//         await ref
//             .read(loginNotifierProvider.notifier)
//             .loginNewUser(phoneNumber: raw, simToken: simTokenToSend);
//
//         _whatsappLoginTriggered = false;
//         return;
//       }
//
//       // ✅ OTP login response navigation (your existing)
//       if (prev?.otpLoginResponse != next.otpLoginResponse &&
//           next.otpLoginResponse != null) {
//         await _ensurePhonePermission();
//         if (!mounted) return;
//
//         final otpLoginResponse = next.otpLoginResponse!;
//
//         if (_allowDirectHome == true &&
//             otpLoginResponse.data?.simVerified == true) {
//           if (otpLoginResponse.data?.isNewOwner == true) {
//             context.go(AppRoutes.privacyPolicyPath);
//           } else {
//             context.go(AppRoutes.heaterHomeScreenPath);
//           }
//         } else {
//           context.pushNamed(AppRoutes.otp, extra: _lastRawPhone ?? '');
//         }
//
//         ref.read(loginNotifierProvider.notifier).resetState();
//       }
//     });
//   }
//
//   String _normalizeNumber(String num) {
//     var n = num.replaceAll(RegExp(r'\D'), '');
//     if (n.length > 10) n = n.substring(n.length - 10);
//     return n;
//   }
//
//   int _uiIndexFromSlot(int? slotIndex, int listIndex) {
//     if (slotIndex == null) return listIndex.clamp(0, 1);
//     if (slotIndex == 0 || slotIndex == 1) return slotIndex;
//     if (slotIndex == 2) return 1;
//     if (slotIndex <= 0) return 0;
//     return 1;
//   }
//
//   Future<void> _triggerSimVerifyDirect({
//     required String phone,
//     required String simToken,
//   }) async {
//     if (_simVerifyTriggered) return;
//     _simVerifyTriggered = true;
//
//     final notifier = ref.read(mobileVerifyProvider.notifier);
//
//     await notifier.mobileVerify(
//       contact: phone.trim(),
//       simToken: simToken,
//       purpose: 'LOGIN',
//     );
//
//     if (!mounted) return;
//
//     final state = ref.read(mobileVerifyProvider);
//
//     if (state.error != null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(state.error!)));
//       _simVerifyTriggered = false;
//       return;
//     }
//
//     final simResponse = state.simVerifyResponse;
//     if (simResponse != null && simResponse.data.simVerified == true) {
//       if (simResponse.data.isNewOwner == true) {
//         context.go(AppRoutes.privacyPolicyPath);
//       } else {
//         context.go(AppRoutes.heaterHomeScreen);
//       }
//     } else {
//       // SIM verify failed -> OTP
//       context.pushNamed(AppRoutes.otp, extra: phone);
//     }
//   }
//
//   Future<void> loadSimInfoFor(String enteredPhone) async {
//     try {
//       var hasPermission = await MobileNumber.hasPhonePermission;
//
//       if (!hasPermission) {
//         await MobileNumber.requestPhonePermission;
//         hasPermission = await MobileNumber.hasPhonePermission;
//       }
//
//       if (!hasPermission) {
//         if (!mounted) return;
//         setState(() {
//           loaded = true;
//           anySimHasNumber = false;
//           numberMatch = false;
//           matchedSlotIndex = null;
//         });
//         return;
//       }
//
//       final simCards = await MobileNumber.getSimCards;
//       sims = simCards ?? [];
//       matchedSlotIndex = null;
//
//       bool localAnySimHasNumber = false;
//       final loginNorm = _normalizeNumber(enteredPhone.trim());
//
//       for (int i = 0; i < sims.length; i++) {
//         final sim = sims[i];
//         final raw = (sim.number ?? '').trim();
//         final norm = _normalizeNumber(raw);
//         final uiIndex = _uiIndexFromSlot(sim.slotIndex, i);
//
//         if (norm.isNotEmpty) {
//           localAnySimHasNumber = true;
//           if (norm == loginNorm) {
//             matchedSlotIndex = uiIndex; // 0=SIM1, 1=SIM2
//           }
//         }
//       }
//
//       if (!mounted) return;
//       setState(() {
//         anySimHasNumber = localAnySimHasNumber;
//         numberMatch = matchedSlotIndex != null;
//         loaded = true;
//       });
//     } catch (e, st) {
//       debugPrint("❌ SIM Load Error: $e");
//       debugPrint("$st");
//       if (!mounted) return;
//       setState(() => loaded = true);
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed) {
//       await Future.delayed(const Duration(milliseconds: 400));
//       final ok = await _isDefaultCallerIdApp();
//       debugPrint("🔁 resumed default ok? $ok");
//       if (ok) _askedOnce = true;
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _sub?.close();
//     mobileNumberController.dispose();
//     super.dispose();
//   }
//
//   void _formatPhoneNumber(String value) {
//     setState(() => errorText = '');
//     if (_isFormatting) return;
//     _isFormatting = true;
//
//     String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
//     if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);
//
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 4 || i == 7) formatted += ' ';
//       formatted += digitsOnly[i];
//     }
//
//     mobileNumberController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//
//     _isFormatting = false;
//   }
//
//   void _showCountryPicker() {
//     showCountryPicker(
//       context: context,
//       showPhoneCode: true,
//       onSelect: (Country country) {
//         setState(() {
//           _selectedDialCode = '+${country.phoneCode}';
//           _selectedFlag = country.flagEmoji;
//         });
//       },
//       countryListTheme: const CountryListThemeData(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//         bottomSheetHeight: 500,
//       ),
//     );
//   }
//
//   Widget _whatsappCheckboxTile() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 25, right: 10),
//       child: ListTile(
//         dense: true,
//         minLeadingWidth: 0,
//         horizontalTitleGap: 10,
//         leading: Image.asset(AppImages.whatsAppBlack, height: 20),
//         title: Text(
//           'Get Instant Updates',
//           style: AppTextStyles.mulish(
//             fontSize: 12,
//             fontWeight: FontWeight.w800,
//             color: AppColor.darkBlue,
//           ),
//         ),
//         subtitle: Row(
//           children: [
//             Text(
//               'From Tringo on your',
//               style: AppTextStyles.mulish(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//                 color: AppColor.darkGrey,
//               ),
//             ),
//             const SizedBox(width: 5),
//             Text(
//               'whatsapp',
//               style: AppTextStyles.mulish(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 color: AppColor.gray84,
//               ),
//             ),
//           ],
//         ),
//         trailing: GestureDetector(
//           onTap: () => setState(() => isWhatsappChecked = !isWhatsappChecked),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: isWhatsappChecked ? AppColor.green : AppColor.darkGrey,
//                 width: 2,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child:
//                   isWhatsappChecked
//                       ? Image.asset(
//                         AppImages.tickImage,
//                         height: 12,
//                         color: AppColor.green,
//                       )
//                       : const SizedBox(width: 12, height: 12),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//     final simState = ref.watch(mobileVerifyProvider);
//
//     final bool isBusy = state.isLoading || simState.isLoading;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               height: double.infinity,
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 50),
//                           child: Image.asset(
//                             AppImages.logo,
//                             height: 88,
//                             width: 85,
//                           ),
//                         ),
//                         const SizedBox(height: 81),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Login',
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w800,
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     'With',
//                                     style: AppTextStyles.mulish(
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 'Your Mobile Number',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 35),
//
//                         // input
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//                               borderRadius: BorderRadius.circular(17),
//                               border: Border.all(
//                                 color:
//                                     mobileNumberController.text.isNotEmpty
//                                         ? AppColor.skyBlue
//                                         : AppColor.black,
//                                 width:
//                                     mobileNumberController.text.isNotEmpty
//                                         ? 2
//                                         : 1.5,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: _showCountryPicker,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         _selectedFlag,
//                                         style: const TextStyle(fontSize: 20),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         _selectedDialCode,
//                                         style: AppTextStyles.mulish(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 14,
//                                           color: AppColor.gray84,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Image.asset(
//                                         AppImages.drapDownImage,
//                                         height: 14,
//                                         color: AppColor.darkGrey,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   width: 2,
//                                   height: 35,
//                                   color: AppColor.white3,
//                                 ),
//                                 const SizedBox(width: 9),
//                                 Expanded(
//                                   child: TextFormField(
//                                     controller: mobileNumberController,
//                                     keyboardType: TextInputType.phone,
//                                     maxLength: 12,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 20,
//                                     ),
//                                     onChanged: _formatPhoneNumber,
//                                     decoration: InputDecoration(
//                                       counterText: '',
//                                       hintText: 'Enter Mobile Number',
//                                       hintStyle: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.borderLightGrey,
//                                         fontSize: 16,
//                                       ),
//                                       border: InputBorder.none,
//                                       suffixIcon:
//                                           mobileNumberController.text.isNotEmpty
//                                               ? GestureDetector(
//                                                 onTap: () {
//                                                   mobileNumberController
//                                                       .clear();
//                                                   setState(() {});
//                                                 },
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.symmetric(
//                                                         vertical: 18,
//                                                       ),
//                                                   child: Image.asset(
//                                                     AppImages.closeImage,
//                                                     width: 6,
//                                                     height: 6,
//                                                     fit: BoxFit.contain,
//                                                   ),
//                                                 ),
//                                               )
//                                               : null,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//                         _whatsappCheckboxTile(),
//                         const SizedBox(height: 20),
//
//                         // button
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: CommonContainer.button2(
//                             width: double.infinity,
//                             loader: isBusy ? const ThreeDotsLoader() : null,
//                             onTap:
//                                 isBusy
//                                     ? null
//                                     : () async {
//                                       final formatted =
//                                           mobileNumberController.text.trim();
//                                       final rawPhone = formatted.replaceAll(
//                                         ' ',
//                                         '',
//                                       );
//
//                                       if (rawPhone.isEmpty) {
//                                         AppSnackBar.info(
//                                           context,
//                                           'Please enter phone number',
//                                         );
//                                         return;
//                                       }
//                                       if (rawPhone.length != 10) {
//                                         AppSnackBar.info(
//                                           context,
//                                           'Please enter a valid 10-digit number',
//                                         );
//                                         return;
//                                       }
//
//                                       _lastRawPhone = rawPhone;
//
//                                       _simVerifyTriggered =
//                                           false; // ✅ allow next attempts
//                                       _allowDirectHome =
//                                           false; // ✅ reset per attempt
//
//                                       // 1) SIM check
//                                       await loadSimInfoFor(rawPhone);
//
//                                       // decide SIM1 eligibility
//                                       _sim1EligibleForLastAttempt =
//                                           (numberMatch &&
//                                               matchedSlotIndex == 0);
//
//                                       // token only if SIM1 eligible
//                                       final fullPhone =
//                                           '$_selectedDialCode$rawPhone';
//                                       _simTokenForLastAttempt =
//                                           _sim1EligibleForLastAttempt
//                                               ? generateSimToken(fullPhone)
//                                               : '';
//
//                                       // 2) SIM1 direct verify
//                                       if (_sim1EligibleForLastAttempt) {
//                                         _allowDirectHome = true;
//
//                                         await _triggerSimVerifyDirect(
//                                           phone: rawPhone,
//                                           simToken: _simTokenForLastAttempt,
//                                         );
//                                         return;
//                                       }
//
//                                       _allowDirectHome = false;
//
//                                       // 3) Non-SIM1: WhatsApp ON => verify whatsapp first
//                                       if (isWhatsappChecked) {
//                                         _waitingWhatsapp = true;
//                                         await notifier.verifyWhatsappNumber(
//                                           contact: rawPhone,
//                                           purpose: 'owner',
//                                         );
//                                         return;
//                                       }
//
//                                       // 4) Non-SIM1: WhatsApp OFF => direct loginNewUser => listener pushes OTP
//                                       await notifier.loginNewUser(
//                                         phoneNumber: rawPhone,
//                                         simToken:
//                                             '', // ✅ no sim token for non-SIM1
//                                       );
//                                     },
//                             text: 'Verify Now',
//                           ),
//                         ),
//
//                         const SizedBox(height: 50),
//                       ],
//                     ),
//                   ),
//                   Image.asset(
//                     AppImages.loginScreenBottom,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

///old code///
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile_number/mobile_number.dart';
// import 'package:country_picker/country_picker.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
//
// import '../../../../../Core/Utility/app_loader.dart';
// import '../../../../Core/Utility/app_snackbar.dart';
// import '../../../../Core/Utility/network_util.dart';
// import '../../../../Core/Utility/sim_token.dart';
// import '../../../../Core/Widgets/caller_id_role_helper.dart';
// import '../../../../Core/Widgets/common_container.dart';
// import '../../../Core/Const/app_color.dart';
// import '../../../Core/Const/app_images.dart';
// import '../../../Core/Widgets/app_go_routes.dart';
// import '../Controller/login_notifier.dart';
//
// class LoginMobileNumber extends ConsumerStatefulWidget {
//   const LoginMobileNumber({super.key});
//
//   @override
//   ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
// }
//
// class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber>
//     with WidgetsBindingObserver {
//   bool isWhatsappChecked = false;
//   String errorText = '';
//   bool _isFormatting = false;
//
//   final TextEditingController mobileNumberController = TextEditingController();
//   String? _lastRawPhone;
//
//   ProviderSubscription<LoginState>? _sub;
//
//   String _selectedDialCode = '+91';
//   String _selectedFlag = '🇮🇳';
//
//   static const MethodChannel _native = MethodChannel('sim_info');
//
//   bool _openingSystemRole = false;
//   bool _askedOnce = false;
//
//   Future<void> _ensurePhonePermission() async {
//     try {
//       final hasPermission = await MobileNumber.hasPhonePermission;
//       if (!hasPermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//       final after = await MobileNumber.hasPhonePermission;
//       debugPrint('PHONE PERMISSION AFTER REQUEST: $after');
//     } catch (e, st) {
//       debugPrint('❌ Error requesting phone permission: $e');
//       debugPrint('$st');
//     }
//   }
//
//   Future<bool> _isDefaultCallerIdApp() async {
//     try {
//       if (!Platform.isAndroid) return true;
//       final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
//       debugPrint("✅ isDefaultCallerIdApp => $ok");
//       return ok ?? false;
//     } catch (e) {
//       debugPrint('❌ isDefaultCallerIdApp error: $e');
//       return false;
//     }
//   }
//
//   Future<void> _requestDefaultCallerIdApp() async {
//     try {
//       if (!Platform.isAndroid) return;
//       debugPrint("🔥 calling requestDefaultCallerIdApp...");
//       await _native.invokeMethod('requestDefaultCallerIdApp');
//       debugPrint("✅ requestDefaultCallerIdApp invoked");
//     } catch (e) {
//       debugPrint('❌ requestDefaultCallerIdApp error: $e');
//     }
//   }
//
//   Future<void> _maybeShowSystemCallerIdPopupOnce() async {
//     if (!mounted) return;
//     if (!Platform.isAndroid) return;
//     if (_openingSystemRole) return;
//     if (_askedOnce) return;
//
//     final ok = await _isDefaultCallerIdApp();
//     if (ok) return;
//
//     _askedOnce = true;
//     _openingSystemRole = true;
//
//     await _requestDefaultCallerIdApp();
//
//     await Future.delayed(const Duration(milliseconds: 300));
//     _openingSystemRole = false;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _ensurePhonePermission();
//
//       final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
//       if (!overlayOk) {
//         await CallerIdRoleHelper.requestOverlayPermission();
//       }
//
//       await CallerIdRoleHelper.maybeAskOnce(ref: ref);
//     });
//
//     // ✅ Only WhatsApp response listener (NO loginResponse listener)
//     _sub = ref.listenManual<LoginState>(loginNotifierProvider, (prev, next) async {
//       if (!mounted) return;
//
//       if (prev?.error != next.error && next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         return;
//       }
//
//       if (prev?.whatsappResponse != next.whatsappResponse &&
//           next.whatsappResponse != null) {
//         final resp = next.whatsappResponse!;
//         final hasWhatsapp = resp.data.hasWhatsapp;
//
//         if (!hasWhatsapp) {
//           if (mounted) setState(() => isWhatsappChecked = false);
//           AppSnackBar.error(
//             context,
//             'This number is not registered on WhatsApp. Please use a WhatsApp number.',
//           );
//           return;
//         }
//
//         if (mounted) setState(() => isWhatsappChecked = true);
//
//         final raw = _lastRawPhone;
//         if (raw == null) return;
//
//         final fullPhone = '$_selectedDialCode$raw';
//         final simToken = generateSimToken(fullPhone);
//
//         // context.pushNamed(
//         //   AppRoutes.mobileNumberVerify,
//         //   extra: {'phone': raw, 'simToken': simToken},
//         // );
//         context.pushNamed(AppRoutes.otp, extra: raw);
//         ref.read(loginNotifierProvider.notifier).resetState();
//       }
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed) {
//       await Future.delayed(const Duration(milliseconds: 400));
//       final ok = await _isDefaultCallerIdApp();
//       debugPrint("🔁 resumed default ok? $ok");
//       if (ok) _askedOnce = true;
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _sub?.close();
//     mobileNumberController.dispose();
//     super.dispose();
//   }
//
//   void _formatPhoneNumber(String value) {
//     setState(() => errorText = '');
//     if (_isFormatting) return;
//     _isFormatting = true;
//
//     String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
//     if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);
//
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 4 || i == 7) formatted += ' ';
//       formatted += digitsOnly[i];
//     }
//
//     mobileNumberController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//
//     _isFormatting = false;
//   }
//
//   void _showCountryPicker() {
//     showCountryPicker(
//       context: context,
//       showPhoneCode: true,
//       onSelect: (Country country) {
//         setState(() {
//           _selectedDialCode = '+${country.phoneCode}';
//           _selectedFlag = country.flagEmoji;
//         });
//       },
//       countryListTheme: const CountryListThemeData(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//         bottomSheetHeight: 500,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               height: double.infinity,
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 50),
//                           child: Image.asset(
//                             AppImages.logo,
//                             height: 88,
//                             width: 85,
//                           ),
//                         ),
//                         const SizedBox(height: 81),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Login',
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w800,
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     'With',
//                                     style: AppTextStyles.mulish(
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 'Your Mobile Number',
//                                 style: AppTextStyles.mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 35),
//
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//                               borderRadius: BorderRadius.circular(17),
//                               border: Border.all(
//                                 color: mobileNumberController.text.isNotEmpty
//                                     ? AppColor.skyBlue
//                                     : AppColor.black,
//                                 width: mobileNumberController.text.isNotEmpty ? 2 : 1.5,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: _showCountryPicker,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(_selectedFlag, style: const TextStyle(fontSize: 20)),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         _selectedDialCode,
//                                         style: AppTextStyles.mulish(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 14,
//                                           color: AppColor.gray84,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Image.asset(
//                                         AppImages.drapDownImage,
//                                         height: 14,
//                                         color: AppColor.darkGrey,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(width: 2, height: 35, color: AppColor.white3),
//                                 const SizedBox(width: 9),
//                                 Expanded(
//                                   child: TextFormField(
//                                     controller: mobileNumberController,
//                                     keyboardType: TextInputType.phone,
//                                     maxLength: 12,
//                                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                                     style: AppTextStyles.mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 20,
//                                     ),
//                                     onChanged: _formatPhoneNumber,
//                                     decoration: InputDecoration(
//                                       counterText: '',
//                                       hintText: 'Enter Mobile Number',
//                                       hintStyle: AppTextStyles.mulish(
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.borderLightGrey,
//                                         fontSize: 16,
//                                       ),
//                                       border: InputBorder.none,
//                                       suffixIcon: mobileNumberController.text.isNotEmpty
//                                           ? GestureDetector(
//                                         onTap: () {
//                                           mobileNumberController.clear();
//                                           setState(() {});
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(vertical: 18),
//                                           child: Image.asset(
//                                             AppImages.closeImage,
//                                             width: 6,
//                                             height: 6,
//                                             fit: BoxFit.contain,
//                                           ),
//                                         ),
//                                       )
//                                           : null,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 35),
//
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: CommonContainer.button2(
//                             width: double.infinity,
//                             loader: state.isLoading ? const ThreeDotsLoader() : null,
//                             onTap: state.isLoading
//                                 ? null
//                                 : () async {
//                               final hasInternet = await NetworkUtil.hasInternet();
//                               if (!hasInternet) {
//                                 AppSnackBar.error(
//                                   context,
//                                   "You're offline. Check your network connection",
//                                 );
//                                 return;
//                               }
//
//                               final formatted = mobileNumberController.text.trim();
//                               final rawPhone = formatted.replaceAll(' ', '');
//
//                               if (rawPhone.isEmpty) {
//                                 AppSnackBar.info(context, 'Please enter phone number');
//                                 return;
//                               }
//                               if (rawPhone.length != 10) {
//                                 AppSnackBar.info(
//                                   context,
//                                   'Please enter a valid 10-digit number',
//                                 );
//                                 return;
//                               }
//
//                               _lastRawPhone = rawPhone;
//
//                               await notifier.verifyWhatsappNumber(
//                                 contact: rawPhone,
//                                 purpose: 'customer',
//                               );
//                             },
//                             text: 'Verify Now',
//                           ),
//                         ),
//
//                         const SizedBox(height: 50),
//                       ],
//                     ),
//                   ),
//                   Image.asset(
//                     AppImages.loginScreenBottom,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
