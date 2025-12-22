import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';

import '../Const/app_color.dart';
import '../Const/app_images.dart';

class FilterPopupScreen extends StatefulWidget {
  const FilterPopupScreen({
    super.key,
    this.initialSelectedCategories,
    this.initialDateRange,
  });

  // ✅ pass values from EmployeeHistory
  final Set<String>? initialSelectedCategories;
  final DateTimeRange? initialDateRange;

  @override
  State<FilterPopupScreen> createState() => _FilterPopupScreenState();
}

class _FilterPopupScreenState extends State<FilterPopupScreen> {
  final TextEditingController _controller = TextEditingController();

  // ✅ date range text visible
  final TextEditingController _dateText = TextEditingController();

  final DraggableScrollableController _drag = DraggableScrollableController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _dateRange = FocusNode();

  bool _isFocused = false;

  // ✅ only one selected range (not list) = simpler and clean
  DateTimeRange? _selectedRange;
  final _df = DateFormat('dd MMM yyyy');

  final List<String> allCategories = ['Premium', 'Premium Pro', 'Freemium'];
  late final Set<String> selectedCategories;

  String selectedDistance = 'Up to Rs.5000';
  String? surpriseOffer = 'Yes';

  @override
  void initState() {
    super.initState();

    // ✅ set initial categories
    selectedCategories = {...?widget.initialSelectedCategories};
    if (selectedCategories.isEmpty) {
      selectedCategories.add('Premium'); // default (your old behavior)
    }

    // ✅ set initial date range
    _selectedRange = widget.initialDateRange;
    _syncDateText();

    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 80), () {
          if (_drag.isAttached) {
            _drag.animateTo(
              0.9,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        if (_drag.isAttached) {
          _drag.animateTo(
            0.7,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  void _syncDateText() {
    if (_selectedRange == null) {
      _dateText.text = "";
    } else {
      _dateText.text =
      "${_df.format(_selectedRange!.start)}  →  ${_df.format(_selectedRange!.end)}";
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _drag.dispose();
    _searchFocus.dispose();
    _dateRange.dispose();
    _controller.dispose();
    _dateText.dispose();
    super.dispose();
  }

  // ✅ Build Result for EmployeeHistory
  Map<String, dynamic> _buildResult() {
    // plan mapping
    String plan = 'all';
    if (selectedCategories.isNotEmpty) {
      final first = selectedCategories.first.toLowerCase();
      if (first.contains('freemium')) plan = 'freemium';
      if (first.contains('premium pro')) plan = 'premiumPro';
      if (first == 'premium') plan = 'premium';
    }

    // date range mapping
    String? dateFrom;
    String? dateTo;
    if (_selectedRange != null) {
      dateFrom = DateFormat('yyyy-MM-dd').format(_selectedRange!.start);
      dateTo = DateFormat('yyyy-MM-dd').format(_selectedRange!.end);
    }

    return {
      "filters": {"plan": plan},
      "dateFrom": dateFrom,
      "dateTo": dateTo,
    };
  }

  Future<void> _pickDateRange() async {
    _dateRange.unfocus();

    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 1)),
          ),
    );

    if (picked == null) return;

    setState(() {
      _selectedRange = picked;
    });

    _syncDateText();
  }

  void _resetAndReturn() {
    setState(() {
      selectedCategories.clear();
      _selectedRange = null;
      _controller.clear();
      _dateText.clear();
      selectedDistance = 'Up to Rs.5000';
      surpriseOffer = null;
    });

    Navigator.pop(context, {"reset": true});
  }

  void clearCategories() {
    setState(() => selectedCategories.clear());
  }

  void clearDateRange() {
    setState(() {
      _selectedRange = null;
      _dateText.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      controller: _drag,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      snap: true,
      snapSizes: const [0.6, 0.8, 0.96],
      builder: (BuildContext context, ScrollController scrollController) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: kb),
          child: Material(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SafeArea(
              top: false,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Filter',
                        style: AppTextStyles.mulish(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _resetAndReturn,
                        child: Text(
                          'Clear All',
                          style: AppTextStyles.mulish(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColor.lightRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, _buildResult()),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.lowLightRed,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                          child: Image.asset(AppImages.closeImage, height: 9),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Categories header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      GestureDetector(
                        onTap: clearCategories,
                        child: Text(
                          'Clear All',
                          style: AppTextStyles.mulish(
                            color: AppColor.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search categories
                  Focus(
                    onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: _isFocused ? AppColor.blue : AppColor.lightGray1,
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppImages.searchImage, height: 17),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              focusNode: _searchFocus,
                              controller: _controller,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                hintText: 'Search Categories',
                                border: InputBorder.none,
                                hintStyle: AppTextStyles.mulish(
                                  color: AppColor.lightGray,
                                  fontSize: 14,
                                ),
                                suffixIcon: _controller.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {});
                                  },
                                )
                                    : null,
                              ),
                              style: AppTextStyles.mulish(fontSize: 14, color: AppColor.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allCategories.map((category) {
                      final isSelected = selectedCategories.contains(category);

                      final searchText = _controller.text.trim().toLowerCase();
                      if (searchText.isNotEmpty && !category.toLowerCase().contains(searchText)) {
                        return const SizedBox.shrink();
                      }

                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(category),
                            if (isSelected) const SizedBox(width: 8),
                            if (isSelected) Icon(Icons.close, size: 16, color: AppColor.blue),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            if (isSelected) {
                              selectedCategories.remove(category);
                            } else {
                              selectedCategories.add(category);
                            }
                          });
                        },
                        selectedColor: AppColor.white,
                        backgroundColor: AppColor.white,
                        showCheckmark: false,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isSelected ? Colors.blue : AppColor.borderGray,
                          ),
                        ),
                        labelStyle: AppTextStyles.mulish(
                          color: isSelected ? AppColor.blue : AppColor.lightGray2,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Date header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: AppTextStyles.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      GestureDetector(
                        onTap: clearDateRange,
                        child: Text(
                          'Clear All',
                          style: AppTextStyles.mulish(
                            color: AppColor.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ✅ Date Range field shows selected value
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: AppColor.lightGray1, width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(AppImages.dob, height: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _dateText,
                            focusNode: _dateRange,
                            readOnly: true,
                            onTap: _pickDateRange,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              hintText: 'Date Range',
                              border: InputBorder.none,
                              hintStyle: AppTextStyles.mulish(
                                color: AppColor.lightGray,
                                fontSize: 14,
                              ),
                            ),
                            style: AppTextStyles.mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Apply / Reset
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetAndReturn,
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, _buildResult()),
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tringo_vendor_new/Core/Utility/app_textstyles.dart';
//
// import '../Const/app_color.dart';
// import '../Const/app_images.dart';
//
// class FilterPopupScreen extends StatefulWidget {
//   const FilterPopupScreen({super.key});
//
//   @override
//   State<FilterPopupScreen> createState() => _FilterPopupScreenState();
// }
//
// class _FilterPopupScreenState extends State<FilterPopupScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final DraggableScrollableController _drag = DraggableScrollableController();
//   final FocusNode _searchFocus = FocusNode();
//   final FocusNode _dateRange = FocusNode();
//   bool _isFocused = false; // add this in your State
//
//   final List<DateTimeRange> _selectedRanges = [];
//   final _df = DateFormat('dd MMM yyyy');
//
//   Future<void> _pickDateRange() async {
//     _dateRange.unfocus();
//
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       initialDateRange: DateTimeRange(
//         start: now,
//         end: now.add(const Duration(days: 1)),
//       ),
//     );
//
//     if (picked == null) return;
//
//     setState(() => _selectedRanges.add(picked));
//   }
//
//
//   void clearAllFilters(ScrollController sc) {
//     setState(() {
//       // selections
//       selectedCategories.clear();
//       surpriseOffer = null;
//       selectedDistance = 'Up to Rs.5000'; // reset to your default label
//
//       // search
//       _controller.clear();
//     });
//
//     // hide keyboard
//     _searchFocus.unfocus();
//
//     // scroll content to top (optional)
//     if (sc.hasClients) {
//       sc.animateTo(
//         0,
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//       );
//     }
//
//     // snap sheet back to mid (optional)
//     if (_drag.isAttached) {
//       _drag.animateTo(
//         0.6, // your initial snap
//         duration: const Duration(milliseconds: 220),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // focus => grow the SHEET itself (top moves up)
//     _searchFocus.addListener(() {
//       if (_searchFocus.hasFocus) {
//         Future.delayed(const Duration(milliseconds: 80), () {
//           if (_drag.isAttached) {
//             _drag.animateTo(
//               0.9,
//               duration: const Duration(milliseconds: 260),
//               curve: Curves.easeOut,
//             );
//           }
//         });
//       } else {
//         // optional: snap back to mid
//         if (_drag.isAttached) {
//           _drag.animateTo(
//             0.7,
//             duration: const Duration(milliseconds: 220),
//             curve: Curves.easeOutCubic,
//           );
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _drag.dispose();
//     _searchFocus.dispose();
//     _dateRange.dispose();
//     _controller.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }
//
//
//   final List<String> allCategories = ['Premium', 'Premium Pro', 'Freemium'];
//
//   final Set<String> selectedCategories = {'Premium'};
//   String selectedDistance = 'Up to Rs.5000';
//   String? surpriseOffer = 'Yes';
//
//   void clearAll() {
//     setState(() {
//       selectedCategories.clear();
//       surpriseOffer = null;
//     });
//   }
//
//   void clearSurpriseOffer() {
//     setState(() {
//       _selectedRanges.clear(); //  remove all tables
//     });
//   }
//
//   void clearCategories() {
//     setState(() => selectedCategories.clear());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final kb = MediaQuery.of(context).viewInsets.bottom;
//     return DraggableScrollableSheet(
//       controller: _drag,
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.96,
//       snap: true,
//       snapSizes: const [0.6, 0.8, 0.96],
//       builder: (BuildContext context, ScrollController scrollController) {
//         return AnimatedPadding(
//           duration: Duration(milliseconds: 150),
//           padding: EdgeInsets.only(bottom: kb), // lift above keyboard
//           child: Material(
//             color: AppColor.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             child: SafeArea(
//               top: false,
//               child: ListView(
//                 controller: scrollController,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'Filter',
//                             style: AppTextStyles.mulish(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w800,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           Spacer(),
//                           Text(
//                             'Clear All',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                               color: AppColor.lightRed,
//                             ),
//                           ),
//                           SizedBox(width: 15),
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             // onTap: () => clearAllFilters(scrollController),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.lowLightRed,
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 17,
//                                   vertical: 10,
//                                 ),
//                                 child: Image.asset(
//                                   AppImages.closeImage,
//                                   height: 9,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 30),
//                       Text(
//                         'Collection Amount',
//                         style: AppTextStyles.mulish(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Stack(
//                         alignment: Alignment.centerLeft,
//                         children: [
//                           Container(
//                             height: 40,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppColor.textWhite.withOpacity(0.1),
//                                   AppColor.textWhite,
//                                   AppColor.textWhite,
//                                   AppColor.textWhite.withOpacity(0.1),
//                                 ],
//                                 begin: Alignment.topRight,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(30),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColor.black.withOpacity(0.1),
//                                   blurRadius: 0,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Positioned(
//                             top: 7,
//                             left: 5,
//                             child: Container(
//                               height: 30,
//                               width: 180,
//                               decoration: BoxDecoration(
//                                 color: AppColor.blue,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   selectedDistance,
//                                   style: AppTextStyles.mulish(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: AppColor.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           Positioned(
//                             left: 165,
//                             top: 11,
//                             child: Container(
//                               width: 10,
//                               height: 22,
//                               decoration: BoxDecoration(
//                                 color: AppColor.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 6,
//                                     offset: Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 30),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Categories',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.w800,
//                               fontSize: 16,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: clearCategories,
//                             child: Text(
//                               'Clear All',
//                               style: AppTextStyles.mulish(
//                                 color: AppColor.blue,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       Focus(
//                         onFocusChange: (hasFocus) {
//                           setState(() => _isFocused = hasFocus);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 0,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.white,
//                             borderRadius: BorderRadius.circular(40),
//                             border: Border.all(
//                               color:
//                                   _isFocused
//                                       ? AppColor.blue
//                                       : AppColor
//                                           .lightGray1, // 💙 Change color on focus
//                               width: 2.5,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 6,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Image.asset(AppImages.searchImage, height: 17),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: TextField(
//                                   focusNode: _searchFocus,
//                                   controller: _controller,
//                                   onChanged: (_) => setState(() {}),
//                                   textAlignVertical:
//                                       TextAlignVertical
//                                           .center, // CENTER VERTICAL ALIGN
//                                   decoration: InputDecoration(
//                                     isCollapsed:
//                                         true, //  Important for tight vertical fit
//                                     contentPadding: EdgeInsets.symmetric(
//                                       vertical: 12, // Tune this as needed
//                                       horizontal: 10,
//                                     ),
//                                     hintText: 'Search Categories',
//                                     border: InputBorder.none,
//                                     hintStyle: AppTextStyles.mulish(
//                                       color: AppColor.lightGray,
//                                       fontSize: 14,
//                                     ),
//                                     suffixIcon:
//                                         _controller.text.isNotEmpty
//                                             ? IconButton(
//                                               icon: Icon(Icons.clear, size: 18),
//                                               onPressed: () {
//                                                 _controller.clear();
//                                                 setState(() {});
//                                               },
//                                             )
//                                             : null,
//                                   ),
//                                   style: AppTextStyles.mulish(
//                                     fontSize: 14,
//                                     color: AppColor.black,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: 12),
//
//                       Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children:
//                             allCategories.map((category) {
//                               final isSelected = selectedCategories.contains(
//                                 category,
//                               );
//                               return ChoiceChip(
//                                 label: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(category),
//                                     if (isSelected) SizedBox(width: 8),
//                                     if (isSelected)
//                                       Icon(
//                                         Icons.close,
//                                         size: 16,
//                                         color: AppColor.blue,
//                                       ),
//                                   ],
//                                 ),
//                                 selected: isSelected,
//                                 onSelected: (_) {
//                                   setState(() {
//                                     if (isSelected) {
//                                       selectedCategories.remove(category);
//                                     } else {
//                                       selectedCategories.add(category);
//                                     }
//                                   });
//                                 },
//                                 selectedColor: AppColor.white,
//                                 backgroundColor: AppColor.white,
//                                 showCheckmark: false,
//                                 shape: StadiumBorder(
//                                   side: BorderSide(
//                                     color:
//                                         isSelected
//                                             ? Colors.blue
//                                             : AppColor.borderGray,
//                                   ),
//                                 ),
//                                 labelStyle: AppTextStyles.mulish(
//                                   color:
//                                       isSelected
//                                           ? AppColor.blue
//                                           : AppColor.lightGray2,
//                                   fontWeight:
//                                       isSelected
//                                           ? FontWeight.w700
//                                           : FontWeight.w400,
//                                 ),
//                               );
//                             }).toList(),
//                       ),
//                       const SizedBox(height: 24),
//
//                       // Surprise Offers
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Date',
//                             style: AppTextStyles.mulish(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: clearSurpriseOffer,
//                             child: Text(
//                               'Clear All',
//                               style: AppTextStyles.mulish(
//                                 color: AppColor.blue,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12),
//                       Focus(
//                         onFocusChange: (hasFocus) {
//                           setState(() => _isFocused = hasFocus);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 0,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColor.white,
//                             borderRadius: BorderRadius.circular(40),
//                             border: Border.all(
//                               color:
//                                   _isFocused
//                                       ? AppColor.blue
//                                       : AppColor
//                                           .lightGray1, // 💙 Change color on focus
//                               width: 2.5,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 6,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Image.asset(AppImages.dob, height: 20),
//                               SizedBox(width: 0),
//                               Expanded(
//                                 child: Expanded(
//                                   child: TextField(
//                                     focusNode: _dateRange,
//                                     readOnly: true,
//                                     onTap: _pickDateRange,
//                                     decoration: InputDecoration(
//                                       isCollapsed: true,
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                             vertical: 12,
//                                             horizontal: 10,
//                                           ),
//                                       hintText: 'Date Range',
//                                       border: InputBorder.none,
//                                       hintStyle: AppTextStyles.mulish(
//                                         color: AppColor.lightGray,
//                                         fontSize: 14,
//                                       ),
//                                       //  suffixIcon optional; chip-la close irukkum
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children: List.generate(_selectedRanges.length, (i) {
//                           final r = _selectedRanges[i];
//                           return Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: AppColor.blue),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   '${_df.format(r.start)} to ${_df.format(r.end)}',
//                                   style: AppTextStyles.mulish(
//                                     color: AppColor.blue,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 GestureDetector(
//                                   onTap: () => setState(() => _selectedRanges.removeAt(i)),
//                                   child: Icon(Icons.close, size: 18, color: AppColor.blue),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }),
//                       )
//
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
