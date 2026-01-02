import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Core/Offline_Data/provider/offline_providers.dart';
import 'package:tringo_vendor_new/Core/Utility/call_helper.dart';

import '../../Const/app_color.dart';
import '../../Const/app_images.dart';
import '../../Utility/app_textstyles.dart';
import '../../Widgets/common_container.dart';
import '../offline_sync_models.dart';

class OfflineShopPreviewScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const OfflineShopPreviewScreen({super.key, required this.sessionId});

  @override
  ConsumerState<OfflineShopPreviewScreen> createState() =>
      _OfflineShopPreviewScreenState();
}

class _OfflineShopPreviewScreenState
    extends ConsumerState<OfflineShopPreviewScreen> {
  bool _loading = true;

  Map<String, dynamic>? _owner;
  Map<String, dynamic>? _shop;
  Map<String, dynamic>? _photos;

  Map<String, dynamic>? _productInfo;
  Map<String, dynamic>? _productImages;

  Map<String, dynamic>? _serviceInfo;
  Map<String, dynamic>? _serviceImages;

  final PageController _photoController = PageController();
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = ref.read(offlineSyncDbProvider);

    final owner = await db.getPayload(widget.sessionId, SyncStepType.owner);
    final shop = await db.getPayload(widget.sessionId, SyncStepType.shop);
    final photos = await db.getPayload(widget.sessionId, SyncStepType.photos);

    final productInfo = await db.getPayload(
      widget.sessionId,
      SyncStepType.productInfo,
    );
    final productImages = await db.getPayload(
      widget.sessionId,
      SyncStepType.productImages,
    );

    final serviceInfo = await db.getPayload(
      widget.sessionId,
      SyncStepType.serviceInfo,
    );
    final serviceImages = await db.getPayload(
      widget.sessionId,
      SyncStepType.serviceImages,
    );

    if (!mounted) return;
    setState(() {
      _owner = owner;
      _shop = shop;
      _photos = photos;

      _productInfo = productInfo;
      _productImages = productImages;

      _serviceInfo = serviceInfo;
      _serviceImages = serviceImages;

      _loading = false;
    });
  }

  // ---------- helpers ----------
  String _shopName() => (_shop?["englishName"] ?? "-").toString();

  String _shopCategory() =>
      (_shop?["category"] ?? _shop?["subCategory"] ?? "").toString();

  String _shopAddress() {
    final en = (_shop?["addressEn"] ?? "").toString().trim();
    if (en.isNotEmpty) return en;
    final ta = (_shop?["addressTa"] ?? "").toString().trim();
    if (ta.isNotEmpty) return ta;
    return "-";
  }

  String _ownerPhone() => (_owner?["ownerPhoneNumber"] ?? "").toString();

  List<String> _shopPhotoPaths() {
    final items = ((_photos?["items"] as List?) ?? []);
    return items
        .map((e) => e is Map ? (e["localPath"] ?? "").toString() : "")
        .where((p) => p.trim().isNotEmpty)
        .toList();
  }

  // ✅ OFFLINE product title + images + price
  String _productName() =>
      (_productInfo?["englishName"] ?? _productInfo?["title"] ?? "-")
          .toString();

  dynamic _productPrice() => _productInfo?["price"];

  List<String> _productImagePaths() {
    final list = ((_productImages?["imagePaths"] as List?) ?? []);
    return list
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  // ✅ OFFLINE service title + images
  String _serviceName() =>
      (_serviceInfo?["title"] ?? _serviceInfo?["englishName"] ?? "-")
          .toString();

  List<String> _serviceImagePaths() {
    final list = ((_serviceImages?["imagePaths"] as List?) ?? []);
    return list
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  Widget _localImage(
    String path, {
    double? w,
    double? h,
    BoxFit fit = BoxFit.cover,
    BorderRadius? radius,
  }) {
    final f = File(path);
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(14),
      child: Image.file(
        f,
        width: w,
        height: h,
        fit: fit,
        errorBuilder:
            (_, __, ___) => Container(
              width: w,
              height: h,
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image),
            ),
      ),
    );
  }

  void _openGallery(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => OfflineGalleryViewer(
              images: images,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  Widget _dots(int count, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopPhotos = _shopPhotoPaths();

    final hasProduct = _productInfo != null;
    final hasService = _serviceInfo != null;

    final productImages = _productImagePaths();
    final serviceImages = _serviceImagePaths();

    return Scaffold(
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              AppColor.scaffoldColor,
                              AppColor.leftArrow,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  CommonContainer.topLeftArrow(
                                    onTap: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                  // CommonContainer.gradientContainer(
                                  //   text: _shopCategory(),
                                  //   textColor: AppColor.skyBlue,
                                  //   fontWeight: FontWeight.w700,
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      CommonContainer.doorDelivery(
                                        text: 'Door Delivery',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        textColor: AppColor.skyBlue,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    _shopName(),
                                    style: AppTextStyles.mulish(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.locationImage,
                                        height: 15,
                                        color: AppColor.darkGrey,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          _shopAddress(),
                                          style: AppTextStyles.mulish(
                                            color: AppColor.darkGrey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 27),

                                // ✅ Call/Map/Message row
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: CommonContainer.callNowButton(
                                      callOnTap:
                                          () => CallHelper.openDialer(
                                            context: context,
                                            rawPhone: _ownerPhone(),
                                          ),
                                      callImage: AppImages.callImage,
                                      callText: 'Call Now',
                                      whatsAppIcon: true,
                                      whatsAppOnTap: () {},
                                      messageOnTap: () {},
                                      MessageIcon: true,
                                      mapText: 'Map',
                                      mapOnTap: () {},
                                      mapImage: AppImages.locationImage,
                                      callIconSize: 21,
                                      callTextSize: 16,
                                      mapIconSize: 21,
                                      mapTextSize: 16,
                                      messagesIconSize: 23,
                                      whatsAppIconSize: 23,
                                      fireIconSize: 23,
                                      callNowPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 12,
                                          ),
                                      mapBoxPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      iconContainerPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 13,
                                          ),
                                      messageContainer: true,
                                      mapBox: true,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ✅ SHOP PHOTO GALLERY (OFFLINE)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: AspectRatio(
                                      aspectRatio: 15 / 8,
                                      child:
                                          shopPhotos.isEmpty
                                              ? Container(
                                                color: Colors.black12,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.storefront,
                                                ),
                                              )
                                              : GestureDetector(
                                                onTap:
                                                    () => _openGallery(
                                                      shopPhotos,
                                                      _photoIndex,
                                                    ),
                                                child: PageView.builder(
                                                  controller: _photoController,
                                                  itemCount: shopPhotos.length,
                                                  onPageChanged: (i) {
                                                    setState(
                                                      () => _photoIndex = i,
                                                    );
                                                  },
                                                  itemBuilder: (_, i) {
                                                    return _localImage(
                                                      shopPhotos[i],
                                                      fit: BoxFit.cover,
                                                      radius:
                                                          BorderRadius.circular(
                                                            0,
                                                          ),
                                                    );
                                                  },
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (shopPhotos.length > 1)
                                  _dots(shopPhotos.length, _photoIndex),

                                const SizedBox(height: 18),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ------------------- OFFLINE PRODUCTS / SERVICES -------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasProduct) ...[
                              Row(
                                children: [
                                  Image.asset(
                                    AppImages.fireImage,
                                    height: 35,
                                    color: AppColor.darkBlue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Offer Products',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _OfflineProductCard(
                                name: _productName(),
                                price: _productPrice(),
                                imagePath:
                                    productImages.isEmpty
                                        ? null
                                        : productImages[0],
                                onTapImages:
                                    () => _openGallery(productImages, 0),
                              ),

                              const SizedBox(height: 10),
                            ],

                            if (hasService) ...[
                              Row(
                                children: [
                                  Image.asset(
                                    AppImages.fireImage,
                                    height: 35,
                                    color: AppColor.darkBlue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Offer Services',
                                    style: AppTextStyles.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _OfflineServiceCard(
                                title: _serviceName(),
                                imagePath:
                                    serviceImages.isEmpty
                                        ? null
                                        : serviceImages[0],
                                onTapImages:
                                    () => _openGallery(serviceImages, 0),
                              ),

                              const SizedBox(height: 10),
                            ],

                            const SizedBox(height: 30),

                            CommonContainer.attractCustomerCard(
                              title: 'Attract More Customers',
                              description:
                                  'Unlock premium to attract more customers',
                              onTap: () {},
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.scaffoldColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Close Preview',
                  style: AppTextStyles.mulish(
                    color: AppColor.scaffoldColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Fullscreen gallery viewer (OFFLINE)
class OfflineGalleryViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const OfflineGalleryViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: images.length,
              itemBuilder: (_, i) {
                final path = images[i];
                return InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                          ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineProductCard extends StatelessWidget {
  final String name;
  final dynamic price;
  final String? imagePath;
  final VoidCallback? onTapImages;

  const _OfflineProductCard({
    required this.name,
    required this.price,
    required this.imagePath,
    this.onTapImages,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapImages,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child:
                  imagePath == null
                      ? Container(
                        width: 74,
                        height: 74,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image),
                      )
                      : Image.file(
                        File(imagePath!),
                        width: 120,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 74,
                              height: 74,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image),
                            ),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹${price ?? "-"}",
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

class _OfflineServiceCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final VoidCallback? onTapImages;

  const _OfflineServiceCard({
    required this.title,
    required this.imagePath,
    this.onTapImages,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapImages,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child:
                  imagePath == null
                      ? Container(
                        width: 74,
                        height: 74,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image),
                      )
                      : Image.file(
                        File(imagePath!),
                        width: 100,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 74,
                              height: 74,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image),
                            ),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
