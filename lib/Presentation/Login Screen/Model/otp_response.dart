  class OtpResponse {
    final bool status;
    final int code;
    final OtpData? data;

    OtpResponse({
      required this.status,
      required this.code,
      this.data,
    });

    factory OtpResponse.fromJson(Map<String, dynamic> json) {
      return OtpResponse(
        status: json['status'] ?? false,
        code: json['code'] ?? 0,
        data: json['data'] != null ? OtpData.fromJson(json['data']) : null,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'status': status,
        'code': code,
        'data': data?.toJson(),
      };
    }
  }

  class OtpData {
    final String accessToken;
    final String refreshToken;
    final String role;
    final String sessionToken;
    final bool isNewOwner;

    // ✅ NEW FIELD
    final bool vendorApproved;

    OtpData({
      required this.accessToken,
      required this.refreshToken,
      required this.role,
      required this.sessionToken,
      required this.isNewOwner,
      required this.vendorApproved,
    });

    factory OtpData.fromJson(Map<String, dynamic> json) {
      return OtpData(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        role: json['role'] ?? '',
        sessionToken: json['sessionToken'] ?? '',
        isNewOwner: json['isNewOwner'] ?? false,

        // ✅ read from API
        vendorApproved: json['vendorApproved'] ?? false,
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'role': role,
        'sessionToken': sessionToken,
        'isNewOwner': isNewOwner,

        // ✅ send back if needed
        'vendorApproved': vendorApproved,
      };
    }
  }
