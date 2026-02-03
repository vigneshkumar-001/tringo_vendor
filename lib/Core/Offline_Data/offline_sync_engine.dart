import 'dart:io';

import 'package:tringo_vendor_new/Core/Const/app_logger.dart';

import '../../Api/DataSource/api_data_source.dart';
import '../Utility/app_prefs.dart';
import 'offline_db/offline_sync_db.dart';
import 'offline_sync_models.dart';

class OfflineSyncEngine {
  final OfflineSyncDb db;
  final ApiDataSource api;

  OfflineSyncEngine({required this.db, required this.api});

  /// ✅ Create a brand new offline session (for a new shop flow)
  Future<String> startNewSession() async {
    final newId = await db.createSession();
    await AppPrefs.setOfflineSessionId(newId);
    return newId;
  }

  /// ✅ Get current session id (if needed by UI)
  Future<String?> currentSessionId() async {
    final sid = await AppPrefs.getOfflineSessionId();
    if (sid == null) return null;
    final s = sid.trim();
    return s.isEmpty ? null : s;
  }

  Future<String> _getOrCreateSession() async {
    final existing = await AppPrefs.getOfflineSessionId();
    if (existing != null && existing.trim().isNotEmpty) return existing.trim();

    final newId = await db.createSession();
    await AppPrefs.setOfflineSessionId(newId);
    return newId;
  }

  Future<String> enqueueOwner({
    required Map<String, dynamic> ownerPayload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.owner,
      payload: ownerPayload,
    );
    return sid;
  }

  Future<String> enqueueShop({
    required Map<String, dynamic> shopPayload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.shop,
      payload: shopPayload,
    );
    return sid;
  }

  Future<String> enqueuePhotos({
    required Map<String, dynamic> photosPayload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.photos,
      payload: photosPayload,
    );
    return sid;
  }

  Future<String> enqueueKeywords({
    required Map<String, dynamic> keywordsPayload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.keywords,
      payload: keywordsPayload,
    );
    return sid;
  }

  // PRODUCT
  Future<String> enqueueProductInfo({
    required Map<String, dynamic> payload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.productInfo,
      payload: payload,
    );
    return sid;
  }

  Future<String> enqueueProductImages({
    required Map<String, dynamic> payload,
  }) async {
    AppLogger.log.i("🔥 enqueueProductImages called");
    final sid = await _getOrCreateSession();
    AppLogger.log.i("🔥 sessionId: $sid");
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.productImages,
      payload: payload,
    );
    AppLogger.log.i("✅ upsertStep done for productImages");
    return sid;
  }

  Future<String> enqueueProductKeywords({
    required Map<String, dynamic> payload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.productKeywords,
      payload: payload,
    );
    return sid;
  }

  // SERVICE
  Future<String> enqueueServiceInfo({
    required Map<String, dynamic> payload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.serviceInfo,
      payload: payload,
    );
    return sid;
  }

  Future<String> enqueueServiceImages({
    required Map<String, dynamic> payload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.serviceImages,
      payload: payload,
    );
    return sid;
  }

  Future<String> enqueueServiceKeywords({
    required Map<String, dynamic> payload,
  }) async {
    final sid = await _getOrCreateSession();
    await db.upsertStep(
      sessionId: sid,
      type: SyncStepType.serviceKeywords,
      payload: payload,
    );
    return sid;
  }

  // ============================
  // ✅ PUSH METHODS (UNCHANGED)
  // ============================

  Future<String?> pushProductImages(String sessionId) async {
    final raw = await db.getPayload(sessionId, SyncStepType.productImages);
    if (raw == null) return "Offline product images payload not found.";

    final List<dynamic> localPaths = (raw["imagePaths"] as List?) ?? [];
    final List<dynamic> features = (raw["features"] as List?) ?? [];

    final List<String> uploadedUrls = [];
    for (final p in localPaths) {
      final path = (p ?? "").toString().trim();
      if (path.isEmpty) continue;

      final f = File(path);
      if (!await f.exists()) continue;

      final uploadRes = await api.userProfileUpload(imageFile: f);
      final url = uploadRes.fold<String>(
        (failure) => "",
        (success) => (success.message ?? "").toString(),
      );

      if (url.trim().isNotEmpty) uploadedUrls.add(url.trim());
    }

    if (uploadedUrls.isEmpty) {
      await db.markFailed(
        sessionId: sessionId,
        type: SyncStepType.productImages,
        errorMessage:
            "No product images uploaded (files missing or upload failed).",
      );
      return "No product images uploaded.";
    }

    final normalizedFeatures =
        features
            .whereType<Map>()
            .map((e) => Map<String, String>.from(e))
            .toList();

    final result = await api.updateProducts(
      images: uploadedUrls,
      features: normalizedFeatures,
    );

    return result.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.productImages,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.productImages,
          result: {"status": response.status},
        );
        return null;
      },
    );
  }

  Future<String?> pushServiceImages(String sessionId) async {
    final raw = await db.getPayload(sessionId, SyncStepType.serviceImages);
    if (raw == null) return "Offline service images payload not found.";

    final List<dynamic> localPaths = (raw["imagePaths"] as List?) ?? [];
    final List<dynamic> features = (raw["features"] as List?) ?? [];

    final List<String> uploadedUrls = [];
    for (final p in localPaths) {
      final path = (p ?? "").toString().trim();
      if (path.isEmpty) continue;

      final f = File(path);
      if (!await f.exists()) continue;

      final uploadRes = await api.serviceImageUpload(imageFile: f);
      final url = uploadRes.fold<String>(
        (failure) => "",
        (success) => (success.message ?? "").toString(),
      );

      if (url.trim().isNotEmpty) uploadedUrls.add(url.trim());
    }

    if (uploadedUrls.isEmpty) {
      await db.markFailed(
        sessionId: sessionId,
        type: SyncStepType.serviceImages,
        errorMessage:
            "No service images uploaded (files missing or upload failed).",
      );
      return "No service images uploaded.";
    }

    final normalizedFeatures =
        features
            .whereType<Map>()
            .map((e) => Map<String, String>.from(e))
            .toList();

    final result = await api.serviceList(
      images: uploadedUrls,
      features: normalizedFeatures,
    );

    return result.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.serviceImages,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.serviceImages,
          result: {"status": response.status},
        );
        return null;
      },
    );
  }

  Future<String?> pushProductInfo(String sessionId) async {
    final payload = await db.getPayload(sessionId, SyncStepType.productInfo);
    if (payload == null) return "Offline product payload not found.";

    final res = await api.addProduct(
      apiProductId: (payload["productId"] ?? "").toString(),
      apiShopId: (payload["shopId"] ?? "").toString(),
      category: (payload["category"] ?? "").toString(),
      subCategory: (payload["subCategory"] ?? "").toString(),
      englishName: (payload["englishName"] ?? "").toString(),
      description: (payload["description"] ?? "").toString(),
      offerLabel: (payload["offerLabel"] ?? "").toString(),
      offerValue: (payload["offerValue"] ?? "").toString(),
      price: payload["price"],
      doorDelivery: _toBool(payload["doorDelivery"]),
    );

    return await res.fold<Future<String?>>(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.productInfo,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        final pid = (response.data.id ?? "").toString();
        if (pid.isNotEmpty) await AppPrefs.setProductId(pid);
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.productInfo,
        );
        return null;
      },
    );
  }

  Future<String?> pushServiceInfo(String sessionId) async {
    final payload = await db.getPayload(sessionId, SyncStepType.serviceInfo);
    if (payload == null) return "Offline service info payload not found.";

    String apiShopId = (payload["apiShopId"] ?? "").toString().trim();
    if (apiShopId.isEmpty) {
      apiShopId = (await AppPrefs.getSopId())?.trim() ?? "";
    }
    if (apiShopId.isEmpty)
      return "Shop not synced yet. Please sync Shop first.";

    final String apiServiceId = (payload["serviceId"] ?? "").toString().trim();

    final List<dynamic> tagsRaw = (payload["tags"] as List?) ?? [];
    final List<String> tags = tagsRaw.map((e) => e.toString()).toList();

    final res = await api.serviceInfo(
      apiServiceId: apiServiceId,
      title: (payload["title"] ?? "").toString(),
      tamilName: (payload["tamilName"] ?? "").toString(),
      apiShopId: apiShopId,
      description: (payload["description"] ?? "").toString(),
      startsAt:
          (payload["startsAt"] is num)
              ? (payload["startsAt"] as num).toInt()
              : int.tryParse("${payload["startsAt"] ?? 0}") ?? 0,
      offerLabel: (payload["offerLabel"] ?? "").toString(),
      offerValue: (payload["offerValue"] ?? "").toString(),
      durationMinutes:
          (payload["durationMinutes"] is num)
              ? (payload["durationMinutes"] as num).toInt()
              : int.tryParse("${payload["durationMinutes"] ?? 0}") ?? 0,
      categoryId: (payload["categoryId"] ?? "").toString(),
      subCategory: (payload["subCategory"] ?? "").toString(),
      tags: tags,
    );

    return await res.fold<Future<String?>>(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.serviceInfo,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        final sid = (response.data.id ?? "").toString();
        if (sid.isNotEmpty) await AppPrefs.setServiceId(sid);

        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.serviceInfo,
          result: {"status": response.status, "serviceId": sid},
        );
        return null;
      },
    );
  }

  Future<String?> pushProductKeywords(String sessionId) async {
    final payload = await db.getPayload(
      sessionId,
      SyncStepType.productKeywords,
    );
    if (payload == null) return "Offline product keywords payload not found.";

    final keywords =
        (payload["keywords"] as List? ?? []).map((e) => e.toString()).toList();
    final res = await api.updateSearchKeyWords(keywords: keywords);

    return res.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.productKeywords,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.productKeywords,
        );
        return null;
      },
    );
  }

  Future<String?> pushServiceKeywords(String sessionId) async {
    final payload = await db.getPayload(
      sessionId,
      SyncStepType.serviceKeywords,
    );
    if (payload == null) return "Offline service keywords payload not found.";

    final keywords =
        (payload["keywords"] as List? ?? []).map((e) => e.toString()).toList();
    final res = await api.serviceSearchKeyWords(keywords: keywords);

    return res.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.serviceKeywords,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.serviceKeywords,
          result: {"status": response.status},
        );
        return null;
      },
    );
  }

  Future<String?> pushKeywords(String sessionId) async {
    final payload = await db.getPayload(sessionId, SyncStepType.keywords);
    if (payload == null) return "Offline keywords payload not found.";

    final List<dynamic> list = (payload["keywords"] ?? []) as List<dynamic>;
    final keywords = list.map((e) => e.toString()).toList();

    final res = await api.searchKeywords(keywords: keywords);

    return res.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.keywords,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.keywords,
          result: {
            "status": response.status,
            "savedCount": response.data.length,
          },
        );
        return null;
      },
    );
  }

  Future<String?> pushOwner(String sessionId) async {
    final payload = await db.getPayload(sessionId, SyncStepType.owner);
    if (payload == null) return "Offline owner payload not found.";

    final res = await api.ownerInfoRegister(
      businessType: (payload["businessType"] ?? "").toString(),
      ownershipType: (payload["ownershipType"] ?? "").toString(),
      govtRegisteredName: (payload["govtRegisteredName"] ?? "").toString(),
      preferredLanguage: (payload["preferredLanguage"] ?? "").toString(),
      gender: (payload["gender"] ?? "").toString(),
      dateOfBirth: (payload["dateOfBirth"] ?? "").toString(),
      fullName: (payload["fullName"] ?? "").toString(),
      ownerNameTamil: (payload["ownerNameTamil"] ?? "").toString(),
      email: (payload["email"] ?? "").toString(),
      ownerPhoneNumber: (payload["ownerPhoneNumber"] ?? "")
          .toString()
          .replaceAll("+91", ""),
    );

    return res.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.owner,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        final id = response.data?.id ?? "";
        if (id.isNotEmpty) await AppPrefs.setBusinessProfileId(id);
        await db.markSuccess(sessionId: sessionId, type: SyncStepType.owner);
        return null;
      },
    );
  }

  Future<String?> pushShop(String sessionId) async {
    final raw = await db.getPayload(sessionId, SyncStepType.shop);
    if (raw == null) return "Offline shop payload not found.";

    final payload = Map<String, dynamic>.from(raw);

    final prefBpId = (await AppPrefs.getBusinessProfileId())?.trim() ?? "";
    if (prefBpId.isEmpty)
      return "Owner not synced yet. Please sync Owner first.";

    final type = (payload["type"] ?? "").toString().trim();

    String ownerImageUrl = "";
    final imagePath = (payload["ownerImageLocalPath"] ?? "").toString().trim();

    if (type == "service" && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final uploadResult = await api.userProfileUpload(imageFile: file);
        ownerImageUrl = uploadResult.fold<String>(
          (failure) => "",
          (success) => (success.message ?? "").toString(),
        );
      }
    }

    final res = await api.shopInfoRegister(
      apiShopId: (payload["apiShopId"] ?? "").toString(),
      businessProfileId: prefBpId,
      category: (payload["category"] ?? "").toString(),
      subCategory: (payload["subCategory"] ?? "").toString(),
      englishName: (payload["englishName"] ?? "").toString(),
      tamilName: (payload["tamilName"] ?? "").toString(),
      descriptionEn: (payload["descriptionEn"] ?? "").toString(),
      descriptionTa: (payload["descriptionTa"] ?? "").toString(),
      addressEn: (payload["addressEn"] ?? "").toString(),
      addressTa: (payload["addressTa"] ?? "").toString(),
      gpsLatitude: _toDouble(payload["gpsLatitude"]),
      gpsLongitude: _toDouble(payload["gpsLongitude"]),
      primaryPhone: (payload["primaryPhone"] ?? "").toString(),
      alternatePhone: (payload["alternatePhone"] ?? "").toString(),
      contactEmail: (payload["contactEmail"] ?? "").toString(),
      doorDelivery: _toBool(payload["doorDelivery"]),
      weeklyHours: (payload["weeklyHours"] ?? "").toString(),
      ownerImageUrl: ownerImageUrl,
    );

    return res.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.shop,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        final shopId = response.data?.id ?? "";
        if (shopId.isNotEmpty) await AppPrefs.setShopId(shopId);
        await db.markSuccess(sessionId: sessionId, type: SyncStepType.shop);
        return null;
      },
    );
  }

  Future<String?> pushPhotos(String sessionId) async {
    final raw = await db.getPayload(sessionId, SyncStepType.photos);
    if (raw == null) return "Offline photos payload not found.";

    final apiShopId = (await AppPrefs.getSopId())?.trim() ?? "";
    if (apiShopId.isEmpty)
      return "Shop not synced yet. Please sync Shop first.";

    final List itemsRaw = (raw["items"] as List?) ?? [];
    if (itemsRaw.isEmpty) return "No photos saved offline.";

    final List<Map<String, String>> items = [];

    for (final it in itemsRaw) {
      final m = Map<String, dynamic>.from(it as Map);
      final type = (m["type"] ?? "").toString().trim();
      final url = (m["url"] ?? "").toString().trim();
      final localPath = (m["localPath"] ?? "").toString().trim();

      if (localPath.isNotEmpty) {
        final f = File(localPath);
        if (await f.exists()) {
          final up = await api.userProfileUpload(imageFile: f);
          final uploadedUrl = up.fold<String>(
            (failure) => "",
            (success) => (success.message ?? "").toString(),
          );
          if (uploadedUrl.trim().isNotEmpty)
            items.add({"type": type, "url": uploadedUrl.trim()});
          continue;
        }
      }

      if (url.isNotEmpty) items.add({"type": type, "url": url});
    }

    if (items.isEmpty) return "No valid photos found to upload.";

    final res = await api.shopPhotoUpload(items: items, apiShopId: apiShopId);

    return res.fold(
      (failure) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.photos,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (response) async {
        await db.markSuccess(sessionId: sessionId, type: SyncStepType.photos);
        return null;
      },
    );
  }

  // ==========================================
  // ✅ ORIGINAL SYNC (UNCHANGED)
  // ==========================================

  Future<String?> syncSessionResume(String sessionId) async {
    final ordered = <SyncStepType>[
      SyncStepType.owner,
      SyncStepType.shop,
      SyncStepType.photos,
      SyncStepType.productInfo,
      SyncStepType.productImages,
      SyncStepType.productKeywords,
      SyncStepType.serviceInfo,
      SyncStepType.serviceImages,
      SyncStepType.serviceKeywords,
      SyncStepType.keywords,
    ];

    for (final step in ordered) {
      final status = await db.getStepStatus(sessionId, step);
      if (status == null) continue;
      if (status == enumName(SyncStepStatus.success)) continue;

      final err = await _pushOne(sessionId, step);
      if (err != null) return err;
    }

    await AppPrefs.clearOfflineSessionId();
    return null;
  }

  Future<String?> _pushOne(String sessionId, SyncStepType step) async {
    switch (step) {
      case SyncStepType.owner:
        return await pushOwner(sessionId);
      case SyncStepType.shop:
        return await pushShop(sessionId);
      case SyncStepType.photos:
        return await pushPhotos(sessionId);

      case SyncStepType.productInfo:
        return await pushProductInfo(sessionId);
      case SyncStepType.productImages:
        return await pushProductImages(sessionId);
      case SyncStepType.productKeywords:
        return await pushProductKeywords(sessionId);

      case SyncStepType.serviceInfo:
        return await pushServiceInfo(sessionId);
      case SyncStepType.serviceImages:
        return await pushServiceImages(sessionId);
      case SyncStepType.serviceKeywords:
        return await pushServiceKeywords(sessionId);

      case SyncStepType.keywords:
        return await pushKeywords(sessionId);
    }
  }

  // ==========================================
  // ✅ NEW: SYNC WITH REAL PROGRESS (%)
  // ==========================================

  Future<String?> syncSessionResumeWithProgress(
    String sessionId, {
    required void Function(double percent) onProgress,
  }) async {
    final ordered = <SyncStepType>[
      SyncStepType.owner,
      SyncStepType.shop,
      SyncStepType.photos,
      SyncStepType.productInfo,
      SyncStepType.productImages,
      SyncStepType.productKeywords,
      SyncStepType.serviceInfo,
      SyncStepType.serviceImages,
      SyncStepType.serviceKeywords,
      SyncStepType.keywords,
    ];

    // steps that exist in this session
    final activeSteps = <SyncStepType>[];
    for (final s in ordered) {
      final st = await db.getStepStatus(sessionId, s);
      if (st != null) activeSteps.add(s);
    }

    final total = activeSteps.length;
    if (total == 0) {
      onProgress(100);
      return null;
    }

    int done = 0;

    void emit(double inner01) {
      final p = ((done + inner01) / total) * 100;
      onProgress(p.clamp(0, 99));
    }

    emit(0);

    for (final step in activeSteps) {
      final status = await db.getStepStatus(sessionId, step);

      if (status == enumName(SyncStepStatus.success)) {
        done++;
        emit(0);
        continue;
      }

      final err = await _pushOneWithProgress(
        sessionId,
        step,
        onInnerProgress: emit,
      );

      if (err != null) return err;

      done++;
      emit(0);
    }

    onProgress(100);
    await AppPrefs.clearOfflineSessionId();
    return null;
  }

  Future<String?> _pushOneWithProgress(
    String sessionId,
    SyncStepType step, {
    required void Function(double inner01) onInnerProgress,
  }) async {
    onInnerProgress(0);

    switch (step) {
      case SyncStepType.productImages:
        return await pushProductImagesWithProgress(sessionId, onInnerProgress);

      case SyncStepType.serviceImages:
        return await pushServiceImagesWithProgress(sessionId, onInnerProgress);

      default:
        final err = await _pushOne(sessionId, step);
        onInnerProgress(1);
        return err;
    }
  }

  Future<String?> pushProductImagesWithProgress(
    String sessionId,
    void Function(double inner01) onProgress,
  ) async {
    final raw = await db.getPayload(sessionId, SyncStepType.productImages);
    if (raw == null) return "Offline product images payload not found.";

    final List paths = (raw["imagePaths"] as List?) ?? [];
    final List features = (raw["features"] as List?) ?? [];

    final files =
        paths
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
    final total = files.length;

    int done = 0;
    final uploadedUrls = <String>[];

    for (final path in files) {
      final f = File(path);
      if (await f.exists()) {
        final res = await api.userProfileUpload(imageFile: f);
        final url = res.fold((_) => "", (s) => (s.message ?? "").toString());
        if (url.trim().isNotEmpty) uploadedUrls.add(url.trim());
      }

      done++;
      if (total > 0) onProgress(done / total);
    }

    if (uploadedUrls.isEmpty) {
      await db.markFailed(
        sessionId: sessionId,
        type: SyncStepType.productImages,
        errorMessage: "No product images uploaded.",
      );
      return "No product images uploaded.";
    }

    final normalized =
        features
            .whereType<Map>()
            .map((e) => Map<String, String>.from(e))
            .toList();

    final result = await api.updateProducts(
      images: uploadedUrls,
      features: normalized,
    );

    return result.fold(
      (f) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.productImages,
          errorMessage: f.message,
        );
        return f.message;
      },
      (_) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.productImages,
        );
        onProgress(1);
        return null;
      },
    );
  }

  Future<String?> pushServiceImagesWithProgress(
    String sessionId,
    void Function(double inner01) onProgress,
  ) async {
    final raw = await db.getPayload(sessionId, SyncStepType.serviceImages);
    if (raw == null) return "Offline service images payload not found.";

    final List paths = (raw["imagePaths"] as List?) ?? [];
    final List features = (raw["features"] as List?) ?? [];

    final files =
        paths
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
    final total = files.length;

    int done = 0;
    final uploadedUrls = <String>[];

    for (final path in files) {
      final f = File(path);
      if (await f.exists()) {
        final res = await api.serviceImageUpload(imageFile: f);
        final url = res.fold((_) => "", (s) => (s.message ?? "").toString());
        if (url.trim().isNotEmpty) uploadedUrls.add(url.trim());
      }

      done++;
      if (total > 0) onProgress(done / total);
    }

    if (uploadedUrls.isEmpty) {
      await db.markFailed(
        sessionId: sessionId,
        type: SyncStepType.serviceImages,
        errorMessage: "No service images uploaded.",
      );
      return "No service images uploaded.";
    }

    final normalized =
        features
            .whereType<Map>()
            .map((e) => Map<String, String>.from(e))
            .toList();

    final result = await api.serviceList(
      images: uploadedUrls,
      features: normalized,
    );

    return result.fold(
      (f) async {
        await db.markFailed(
          sessionId: sessionId,
          type: SyncStepType.serviceImages,
          errorMessage: f.message,
        );
        return f.message;
      },
      (_) async {
        await db.markSuccess(
          sessionId: sessionId,
          type: SyncStepType.serviceImages,
        );
        onProgress(1);
        return null;
      },
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse("${v ?? ""}") ?? 0.0;
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = (v ?? "").toString().trim().toLowerCase();
  return s == "true" || s == "1" || s == "yes";
}
