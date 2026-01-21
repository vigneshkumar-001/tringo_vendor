
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
import 'package:tringo_vendor_new/Presentation/Support/Screen/support_chat_screen.dart';



import '../../../../../Core/Utility/app_loader.dart';

import '../../../../../Core/Widgets/common_container.dart';
import '../../../Core/Const/app_color.dart';
import '../../../Core/Const/app_images.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../Model/support_list_response.dart';
import '../controller/support_notifier.dart';
import 'create_support.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.microtask(() async {
      ref.read(supportNotifier.notifier).supportList(context: context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifier);
    final supportListResponse = state.supportListResponse;

    // 1️⃣ Loading state
    if (state.isLoading && supportListResponse == null) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    // 2️⃣ Error state
    if (!state.isLoading && state.error != null) {
      return Scaffold(
        body: Center(
          child: NoDataScreen(
            onRefresh: () async {
              await ref
                  .read(supportNotifier.notifier)
                  .supportList(context: context);
            },
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }

    // 3️⃣ Empty support list
    if (supportListResponse?.data.isEmpty ?? true) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Centered No Data message
              Expanded(
                child: Center(
                  child: NoDataScreen(
                    onRefresh: () async {
                      await ref
                          .read(supportNotifier.notifier)
                          .supportList(context: context);
                    },
                    showBottomButton: false, // We handle button manually
                  ),
                ),
              ),

              // Button at the bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CommonContainer.button(
                  buttonColor: AppColor.darkBlue,
                  imagePath: AppImages.rightStickArrow,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateSupport()),
                    );

                    // 2️⃣ Refresh support list AFTER returning
                    await ref.read(supportNotifier.notifier).supportList(context: context);
                  },
                  text: const Text('Create Ticket'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4️⃣ Normal list
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(supportNotifier.notifier)
                .supportList(context: context);
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Column(
                children: [
                  // Header
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CommonContainer.topLeftArrow(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        'Support',
                        style:AppTextStyles.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mildBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Support List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: supportListResponse!.data.length,
                    itemBuilder: (context, index) {
                      final ticket = supportListResponse.data[index];

                      // Map status to color and image
                      Color containerColor;
                      Color imageTextColor;
                      String imageAsset;
                      String statusText;

                      switch (ticket.status) {
                        case SupportStatus.pending:
                          containerColor = AppColor.yellow.withOpacity(0.2);
                          imageTextColor = AppColor.yellow;
                          imageAsset = AppImages.orangeClock;
                          statusText = 'Pending';
                          break;
                        case SupportStatus.resolved:
                          containerColor = AppColor.green.withOpacity(0.2);
                          imageTextColor = AppColor.green;
                          imageAsset = AppImages.greenTick;
                          statusText = 'Solved';
                          break;
                        case SupportStatus.closed:
                          containerColor = AppColor.gray84.withOpacity(0.2);
                          imageTextColor = AppColor.gray84;
                          imageAsset = AppImages.closeImage;
                          statusText = 'Closed';
                          break;
                        case SupportStatus.OPEN:
                          containerColor = AppColor.blue.withOpacity(0.2);
                          imageTextColor = AppColor.blue;
                          imageAsset = AppImages.timing;
                          statusText = 'Opened';
                          break;
                        default:
                          containerColor = AppColor.blue.withOpacity(0.2);
                          imageTextColor = AppColor.blue;
                          imageAsset = AppImages.timing;
                          statusText = 'Unknown';
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CommonContainer.supportBox(
                          imageTextColor: imageTextColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SupportChatScreen(id: ticket.id),
                              ),
                            );
                          },
                          containerColor: containerColor,
                          image: imageAsset,
                          imageText: statusText,
                          mainText: ticket.subject,
                          timingText: 'Created on ${ticket.createdAt}',
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 50),
                  CommonContainer.button(
                    buttonColor: AppColor.darkBlue,
                    imagePath: AppImages.rightStickArrow,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateSupport()),
                      );
                    },
                    text: const Text('Create Ticket'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
