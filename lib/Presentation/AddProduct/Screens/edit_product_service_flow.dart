import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Core/Utility/app_prefs.dart';
import '../../AddProduct/Controller/product_notifier.dart';
import '../../AddProduct/Controller/service_info_notifier.dart';
import '../../AddProduct/Model/product_response.dart' as product_model;
import '../../AddProduct/Model/service_info_response.dart' as service_model;
import 'add_product_list.dart';
import 'product_category_screens.dart';

class EditProductServiceFlow extends ConsumerStatefulWidget {
  final bool isService;
  final String shopId;
  final String businessProfileId;
  final String itemId; // productId / serviceId

  final String? initialCategoryName;
  final String? initialSubCategoryName;
  final String? initialName;
  final int? initialPrice;
  final String? initialDescription;
  final String? initialOfferLabel;
  final String? initialOfferValue;
  final bool? initialDoorDelivery;
  final List<String> initialImageUrls;
  final List<Map<String, String>> initialFeatures;
  final List<String> initialKeywords;

  final String? initialCategorySlug;
  final String? initialSubCategorySlug;

  const EditProductServiceFlow({
    super.key,
    required this.isService,
    required this.shopId,
    required this.businessProfileId,
    required this.itemId,
    this.initialCategoryName,
    this.initialSubCategoryName,
    this.initialName,
    this.initialPrice,
    this.initialDescription,
    this.initialOfferLabel,
    this.initialOfferValue,
    this.initialDoorDelivery,
    this.initialImageUrls = const [],
    this.initialFeatures = const [],
    this.initialKeywords = const [],
    this.initialCategorySlug,
    this.initialSubCategorySlug,
  });

  @override
  ConsumerState<EditProductServiceFlow> createState() =>
      _EditProductServiceFlowState();
}

class _EditProductServiceFlowState extends ConsumerState<EditProductServiceFlow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppPrefs.setShopId(widget.shopId);
      await AppPrefs.setBusinessProfileId(widget.businessProfileId);
      if (widget.isService) {
        await AppPrefs.setServiceId(widget.itemId);
      } else {
        await AppPrefs.setProductId(widget.itemId);
      }

      if (!mounted) return;
      final updatedBasic = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProductCategoryScreens(
                page: 'AboutMeScreens',
                isService: widget.isService,
                shopId: widget.shopId,
                productId: widget.itemId,
                allowOfferEdit: true,
                initialCategoryName: widget.initialCategoryName,
                initialSubCategoryName: widget.initialSubCategoryName,
                initialProductName: widget.initialName,
                initialPrice: widget.initialPrice,
                initialDescription: widget.initialDescription,
                initialOfferLabel: widget.initialOfferLabel,
                initialOfferValue: widget.initialOfferValue,
                initialDoorDelivery: (widget.initialDoorDelivery ?? false)
                    ? 'Yes'
                    : 'No',
                initialCategorySlug: widget.initialCategorySlug,
                initialSubCategorySlug: widget.initialSubCategorySlug,
              ),
        ),
      );

      if (updatedBasic != true || !mounted) {
        Navigator.pop(context, false);
        return;
      }

      final details = _getLatestDetails();
      final updatedRest = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => AddProductList(
                isService: widget.isService,
                categorySlug: widget.initialCategorySlug,
                isEditFlow: true,
                initialImageUrls: details.imageUrls,
                initialFeatures: details.features,
                initialKeywords: details.keywords,
              ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, updatedRest == true);
    });
  }

  _EditDetails _getLatestDetails() {
    if (widget.isService) {
      final service = ref.read(serviceInfoNotifierProvider).serviceInfoResponse;
      final service_model.ServiceItem? data = service?.data;
      return _EditDetails.merge(
        primary: _EditDetails.fromService(data),
        fallback: _EditDetails(
          imageUrls: widget.initialImageUrls,
          features: widget.initialFeatures,
          keywords: widget.initialKeywords,
        ),
      );
    }

    final product = ref.read(productNotifierProvider).productResponse;
    final product_model.ProductData? data = product?.data;
    return _EditDetails.merge(
      primary: _EditDetails.fromProduct(data),
      fallback: _EditDetails(
        imageUrls: widget.initialImageUrls,
        features: widget.initialFeatures,
        keywords: widget.initialKeywords,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

class _EditDetails {
  final List<String> imageUrls;
  final List<Map<String, String>> features;
  final List<String> keywords;

  const _EditDetails({
    required this.imageUrls,
    required this.features,
    required this.keywords,
  });

  static _EditDetails merge({
    required _EditDetails primary,
    required _EditDetails fallback,
  }) {
    return _EditDetails(
      imageUrls: primary.imageUrls.isNotEmpty ? primary.imageUrls : fallback.imageUrls,
      features: primary.features.isNotEmpty ? primary.features : fallback.features,
      keywords: primary.keywords.isNotEmpty ? primary.keywords : fallback.keywords,
    );
  }

  factory _EditDetails.fromProduct(product_model.ProductData? data) {
    final keywords = data?.keywords ?? const <String>[];
    final features =
        (data?.features ?? const <product_model.Feature>[])
            .map((e) => {"label": e.label, "value": e.value})
            .toList();

    final media = data?.media ?? const [];
    final imageUrls =
        media
            .map((e) {
              if (e is Map) return (e["url"] ?? "").toString();
              return "";
            })
            .where((e) => e.trim().isNotEmpty)
            .cast<String>()
            .toList();

    return _EditDetails(imageUrls: imageUrls, features: features, keywords: keywords);
  }

  factory _EditDetails.fromService(service_model.ServiceItem? data) {
    final keywords = data?.keywords ?? const <String>[];
    final features =
        (data?.features ?? const <service_model.ServiceFeature>[])
            .map((e) => {"label": e.label, "value": e.value})
            .toList();
    final imageUrls =
        (data?.media ?? const <service_model.ServiceMedia>[])
            .map((e) => e.url)
            .where((e) => e.trim().isNotEmpty)
            .toList();
    return _EditDetails(imageUrls: imageUrls, features: features, keywords: keywords);
  }
}
