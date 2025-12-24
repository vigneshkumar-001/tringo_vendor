class AppVersionResponse {
  final bool status;
  final AppVersionData? data;

  AppVersionResponse({required this.status, this.data});

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) {
    return AppVersionResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? AppVersionData.fromJson(json['data']) : null,
    );
  }
}

class AppVersionData {
  final String appId;
  final String platform;
  final String currentVersion;
  final String minVersion;
  final bool forceUpdate;
  final StoreLinks store;
  final String? message;

  AppVersionData({
    required this.appId,
    required this.platform,
    required this.currentVersion,
    required this.minVersion,
    required this.forceUpdate,
    required this.store,
    this.message,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      appId: json['appId'] ?? '',
      platform: json['platform'] ?? '',
      currentVersion: json['currentVersion'] ?? '',
      minVersion: json['minVersion'] ?? '',
      forceUpdate: json['forceUpdate'] ?? false,
      store: StoreLinks.fromJson(json['store'] ?? {}),
      message: json['message'],
    );
  }
}

class StoreLinks {
  final String android;
  final String ios;

  StoreLinks({required this.android, required this.ios});

  factory StoreLinks.fromJson(Map<String, dynamic> json) {
    return StoreLinks(android: json['android'] ?? '', ios: json['ios'] ?? '');
  }
}
