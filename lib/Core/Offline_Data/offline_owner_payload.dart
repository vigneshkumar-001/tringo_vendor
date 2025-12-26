import 'package:intl/intl.dart';

class OfflineOwnerPayload {
  final String businessType; // SERVICES / SELLING_PRODUCTS
  final String ownershipType; // INDIVIDUAL / COMPANY
  final String govtRegisteredName;
  final String preferredLanguage;
  final String gender; // MALE/FEMALE/OTHERS or backend format
  final String dateOfBirth; // yyyy-MM-dd
  final String fullName;
  final String ownerNameTamil;
  final String email;
  final String ownerPhoneNumber; // +91xxxxxxxxxx
  final String phoneVerificationToken; // OTP token

  const OfflineOwnerPayload({
    required this.businessType,
    required this.ownershipType,
    required this.govtRegisteredName,
    required this.preferredLanguage,
    required this.gender,
    required this.dateOfBirth,
    required this.fullName,
    required this.ownerNameTamil,
    required this.email,
    required this.ownerPhoneNumber,
    required this.phoneVerificationToken,
  });

  factory OfflineOwnerPayload.fromMap(Map<String, dynamic> m) {
    return OfflineOwnerPayload(
      businessType: (m['businessType'] ?? '').toString(),
      ownershipType: (m['ownershipType'] ?? '').toString(),
      govtRegisteredName: (m['govtRegisteredName'] ?? '').toString(),
      preferredLanguage: (m['preferredLanguage'] ?? '').toString(),
      gender: (m['gender'] ?? '').toString(),
      dateOfBirth: (m['dateOfBirth'] ?? '').toString(),
      fullName: (m['fullName'] ?? '').toString(),
      ownerNameTamil: (m['ownerNameTamil'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      ownerPhoneNumber: (m['ownerPhoneNumber'] ?? '').toString(),
      phoneVerificationToken: (m['phoneVerificationToken'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    "businessType": businessType,
    "ownershipType": ownershipType,
    "govtRegisteredName": govtRegisteredName,
    "preferredLanguage": preferredLanguage,
    "gender": gender,
    "dateOfBirth": dateOfBirth,
    "fullName": fullName,
    "ownerNameTamil": ownerNameTamil,
    "email": email,
    "ownerPhoneNumber": ownerPhoneNumber,
    "phoneVerificationToken": phoneVerificationToken,
  };

  /// For UI: +91xxxx -> xxxxx
  String get phone10 => ownerPhoneNumber.replaceAll('+91', '').trim();

  /// For UI: yyyy-MM-dd -> dd-MM-yyyy
  String get dobUi {
    try {
      final d = DateFormat('yyyy-MM-dd').parseStrict(dateOfBirth);
      return DateFormat('dd-MM-yyyy').format(d);
    } catch (_) {
      return '';
    }
  }

  /// For UI: "MALE" -> "Male"
  String get genderUi {
    final g = gender.toLowerCase().trim();
    if (g == 'male') return 'Male';
    if (g == 'female') return 'Female';
    return 'Others';
  }
}
