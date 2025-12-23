import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';

import '../../../../Core/Const/app_color.dart';
import '../../../../Core/Const/app_images.dart';
import '../../../../Core/Utility/app_textstyles.dart';
import '../../../../Core/Utility/sortby_popup_screen.dart';
import '../../../No Data Screen/Screen/no_data_screen.dart';

class HeaterEarnings extends StatefulWidget {
  const HeaterEarnings({super.key});

  @override
  State<HeaterEarnings> createState() => _HeaterEarningsState();
}

class _HeaterEarningsState extends State<HeaterEarnings> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return NoDataScreen(showTopBackArrow: false,showBottomButton: false,);
    //   Scaffold(
    //   body: SafeArea(
    //     child: SingleChildScrollView(
    //       child:
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               'Earnings',
    //               style: AppTextStyles.mulish(
    //                 fontWeight: FontWeight.w700,
    //                 fontSize: 24,
    //                 color: AppColor.darkBlue,
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             Container(
    //               width: double.infinity,
    //               decoration: BoxDecoration(
    //                 color: AppColor.iceGray,
    //                 borderRadius: BorderRadius.circular(15),
    //               ),
    //               child: Padding(
    //                 padding: const EdgeInsets.symmetric(
    //                   horizontal: 0,
    //                   vertical: 40,
    //                 ),
    //                 child: Column(
    //                   children: [
    //                     Text(
    //                       '₹3000',
    //                       style: AppTextStyles.mulish(
    //                         fontWeight: FontWeight.w800,
    //                         fontSize: 42,
    //                         color: AppColor.blueGradient1,
    //                       ),
    //                     ),
    //                     SizedBox(height: 3),
    //                     Text(
    //                       'Total Credited Amount',
    //                       style: AppTextStyles.mulish(
    //                         fontWeight: FontWeight.w700,
    //                         fontSize: 14,
    //                         color: AppColor.lightGray3,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             SingleChildScrollView(
    //               scrollDirection: Axis.horizontal,
    //               physics: BouncingScrollPhysics(),
    //               padding: EdgeInsets.symmetric(horizontal: 0),
    //               child: Row(
    //                 children: [
    //                   GestureDetector(
    //                     onTap: () {
    //                       setState(() {
    //                         _showSearch = true;
    //                       });
    //                     },
    //                     child: AnimatedSwitcher(
    //                       duration: const Duration(milliseconds: 300),
    //                       child:
    //                           _showSearch
    //                               ? Container(
    //                                 key: const ValueKey('searchField'),
    //                                 width: 260,
    //                                 padding: const EdgeInsets.symmetric(
    //                                   horizontal: 16,
    //                                 ),
    //                                 decoration: BoxDecoration(
    //                                   border: Border.all(
    //                                     color: AppColor.darkBlue,
    //                                   ),
    //                                   borderRadius: BorderRadius.circular(25),
    //                                   color: AppColor.white,
    //                                 ),
    //                                 child: Row(
    //                                   children: [
    //                                     Image.asset(
    //                                       AppImages.searchImage,
    //                                       height: 14,
    //                                     ),
    //                                     SizedBox(width: 8),
    //                                     Expanded(
    //                                       child: TextField(
    //                                         controller: _searchController,
    //                                         autofocus: true,
    //                                         decoration: const InputDecoration(
    //                                           hintText: 'Search...',
    //                                           border: InputBorder.none,
    //                                         ),
    //                                         onChanged: (value) {
    //                                           // 🔍 filter logic here
    //                                         },
    //                                       ),
    //                                     ),
    //                                     InkWell(
    //                                       onTap: () {
    //                                         setState(() {
    //                                           _searchController.clear();
    //                                           _showSearch = false;
    //                                         });
    //                                       },
    //                                       child: const Icon(
    //                                         Icons.close,
    //                                         size: 18,
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               )
    //                               : Container(
    //                                 key: const ValueKey('searchButton'),
    //                                 decoration: BoxDecoration(
    //                                   border: Border.all(
    //                                     color: AppColor.darkBlue,
    //                                   ),
    //                                   borderRadius: BorderRadius.circular(25),
    //                                 ),
    //                                 padding: const EdgeInsets.only(
    //                                   left: 18,
    //                                   top: 8,
    //                                   bottom: 8,
    //                                   right: 150,
    //                                 ),
    //                                 child: Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.start,
    //                                   children: [
    //                                     Image.asset(
    //                                       AppImages.searchImage,
    //                                       height: 14,
    //                                     ),
    //                                     SizedBox(width: 10),
    //                                     Text(
    //                                       'Search',
    //                                       style: AppTextStyles.mulish(
    //                                         color: AppColor.darkBlue,
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                     ),
    //                   ),
    //
    //                   SizedBox(width: 10),
    //                   GestureDetector(
    //                     onTap: () {
    //                       showModalBottomSheet(
    //                         backgroundColor: Colors.transparent,
    //                         context: context,
    //                         isScrollControlled: true,
    //                         showDragHandle: true,
    //                         shape: const RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.vertical(
    //                             top: Radius.circular(20),
    //                           ),
    //                         ),
    //                         builder: (_) => SortbyPopupScreen(),
    //                       );
    //                     },
    //                     child: Container(
    //                       decoration: BoxDecoration(
    //                         border: Border.all(color: AppColor.lightGray2),
    //                         borderRadius: BorderRadius.circular(25),
    //                       ),
    //                       child: Padding(
    //                         padding: const EdgeInsets.symmetric(
    //                           horizontal: 17,
    //                           vertical: 9,
    //                         ),
    //                         child: Row(
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             Text(
    //                               'Sort By',
    //                               style: AppTextStyles.mulish(
    //                                 color: AppColor.lightGray2,
    //                               ),
    //                             ),
    //                             SizedBox(width: 10),
    //                             Image.asset(
    //                               AppImages.drapDownImage,
    //                               height: 19,
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             Center(
    //               child: Text(
    //                 'Today',
    //                 style: AppTextStyles.mulish(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w600,
    //                   color: AppColor.lightGray2,
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             Container(
    //               decoration: BoxDecoration(
    //                 color: AppColor.ivoryGreen,
    //                 borderRadius: BorderRadius.circular(15),
    //               ),
    //               padding: const EdgeInsets.all(20),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Text(
    //                             '₹3000 Credited',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 18,
    //                               fontWeight: FontWeight.w700,
    //                               color: AppColor.darkBlue,
    //                             ),
    //                           ),
    //                           SizedBox(height: 3),
    //                           Text(
    //                             'November Pay',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 12,
    //                               fontWeight: FontWeight.w500,
    //                               color: AppColor.gray84,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       Spacer(),
    //                       Column(
    //                         crossAxisAlignment: CrossAxisAlignment.end,
    //                         children: [
    //                           Text(
    //                             'to Bank Ac No',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 12,
    //                               fontWeight: FontWeight.w500,
    //                               color: AppColor.lightGray2,
    //                             ),
    //                           ),
    //                           SizedBox(height: 3),
    //                           Text(
    //                             '****9780',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 16,
    //                               fontWeight: FontWeight.w500,
    //                               color: AppColor.gray84,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //
    //                   SizedBox(height: 14),
    //
    //                   DottedBorder(
    //                     color: AppColor.black.withOpacity(0.2),
    //                     dashPattern: const [3, 2],
    //                     borderType: BorderType.RRect,
    //                     radius: Radius.circular(18),
    //                     padding: EdgeInsets.all(10),
    //                     child: Row(
    //                       children: [
    //                         Image.asset(
    //                           AppImages.downloadImage,
    //                           height: 18,
    //                           width: 17,
    //                         ),
    //                         SizedBox(width: 8),
    //                         Expanded(
    //                           child: Text(
    //                             'Download Receipt',
    //                             maxLines: 1,
    //                             overflow: TextOverflow.ellipsis,
    //                             style: AppTextStyles.mulish(
    //                               fontWeight: FontWeight.w700,
    //                               fontSize: 12,
    //                               color: AppColor.darkBlue,
    //                             ),
    //                           ),
    //                         ),
    //                         SizedBox(width: 10),
    //                         Text(
    //                           '10.40 PM',
    //                           style: AppTextStyles.mulish(
    //                             fontWeight: FontWeight.w400,
    //                             fontSize: 12,
    //                             color: AppColor.lightGray3,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             Center(
    //               child: Text(
    //                 '1 Nov 2025',
    //                 style: AppTextStyles.mulish(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w600,
    //                   color: AppColor.lightGray2,
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             Container(
    //               decoration: BoxDecoration(
    //                 color: AppColor.iceGray,
    //                 borderRadius: BorderRadius.circular(15),
    //               ),
    //               padding: const EdgeInsets.all(20),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Text(
    //                             '₹55,000 Credited',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 18,
    //                               fontWeight: FontWeight.w700,
    //                               color: AppColor.darkBlue,
    //                             ),
    //                           ),
    //                           SizedBox(height: 3),
    //                           Text(
    //                             'October Pay',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 12,
    //                               fontWeight: FontWeight.w500,
    //                               color: AppColor.gray84,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       Spacer(),
    //                       Column(
    //                         crossAxisAlignment: CrossAxisAlignment.end,
    //                         children: [
    //                           Text(
    //                             'to Bank Ac No',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 12,
    //                               fontWeight: FontWeight.w500,
    //                               color: AppColor.lightGray2,
    //                             ),
    //                           ),
    //                           SizedBox(height: 3),
    //                           Text(
    //                             '****9780',
    //                             style: AppTextStyles.mulish(
    //                               fontSize: 16,
    //                               fontWeight: FontWeight.w500,
    //                               color: AppColor.gray84,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //
    //                   SizedBox(height: 14),
    //
    //                   DottedBorder(
    //                     color: AppColor.black.withOpacity(0.2),
    //                     dashPattern: const [3, 2],
    //                     borderType: BorderType.RRect,
    //                     radius: Radius.circular(18),
    //                     padding: EdgeInsets.all(10),
    //                     child: Row(
    //                       children: [
    //                         Image.asset(
    //                           AppImages.downloadImage,
    //                           height: 18,
    //                           width: 17,
    //                         ),
    //                         SizedBox(width: 8),
    //                         Expanded(
    //                           child: Text(
    //                             'Download Receipt',
    //                             maxLines: 1,
    //                             overflow: TextOverflow.ellipsis,
    //                             style: AppTextStyles.mulish(
    //                               fontWeight: FontWeight.w700,
    //                               fontSize: 12,
    //                               color: AppColor.darkBlue,
    //                             ),
    //                           ),
    //                         ),
    //                         SizedBox(width: 10),
    //                         Text(
    //                           '10.40 PM',
    //                           style: AppTextStyles.mulish(
    //                             fontWeight: FontWeight.w400,
    //                             fontSize: 12,
    //                             color: AppColor.lightGray3,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
