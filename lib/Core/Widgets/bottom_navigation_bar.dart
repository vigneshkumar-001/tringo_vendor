import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Presentation/About Me/Screen/employee_about_me.dart';
import '../../Presentation/Employee History/Screen/employee_history.dart';
import '../../Presentation/Home Screen/home_screen.dart';
import '../../Presentation/Menu/Screen/menu_screen.dart';
import '../../Presentation/No Data Screen/Screen/no_data_screen.dart';
import '../../Presentation/Register Screen/Screen/register_screen.dart';
import '../Const/app_color.dart';
import '../Const/app_images.dart';

class CommonBottomNavigation extends StatefulWidget {
  final int initialIndex;
  final int? initialAboutMeTab;
  const CommonBottomNavigation({
    super.key,
    this.initialIndex = 0,
    this.initialAboutMeTab,
  });

  @override
  CommonBottomNavigationState createState() => CommonBottomNavigationState();
}

class CommonBottomNavigationState extends State<CommonBottomNavigation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;
    _prevIndex = _selectedIndex;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _updateSlideAnimation();
  }

  //  Build the page on demand so it always sees latest businessType
  ///new///
  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return EmployeeHistory();
      case 2:
        return RegisterScreen();
      case 3:
        return EmployeeAboutMe();

      case 4:
        return const NoDataScreens();

      default:
        return const SizedBox.shrink();
    }
  }

  void _updateSlideAnimation() {
    _slideAnimation = Tween<Offset>(
      begin:
          _selectedIndex > _prevIndex
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animation_controller_forward();
  }

  void _animation_controller_forward() {
    _animationController.forward(from: 0.0);
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _prevIndex = _selectedIndex;
      _selectedIndex = index;

      _slideAnimation = Tween<Offset>(
        begin:
            _selectedIndex > _prevIndex
                ? const Offset(1.0, 0.0)
                : const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _animationController.reset();
      _animation_controller_forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build current/previous from _pageForIndex so they reflect latest session
    final Widget current = KeyedSubtree(
      key: ValueKey('page-$_selectedIndex'),
      child: _pageForIndex(_selectedIndex),
    );

    final Widget? previous =
        (_selectedIndex == _prevIndex)
            ? null
            : KeyedSubtree(
              key: ValueKey('page-$_prevIndex'),
              child: _pageForIndex(_prevIndex),
            );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            if (previous != null) previous,
            (_selectedIndex == _prevIndex)
                ? current
                : SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: current,
                  ),
                ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: AppColor.white,
              type: BottomNavigationBarType.fixed,
              elevation: 1,
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              selectedItemColor: AppColor.black,
              unselectedItemColor: AppColor.darkGrey,
              selectedLabelStyle: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.homeImage, height: 26),
                  activeIcon: Image.asset(AppImages.homeDark, height: 30),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.historyImage, height: 26),
                  activeIcon: Image.asset(
                    AppImages.employeeHistoryDark,
                    height: 30,
                  ),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.registerImage, height: 26),
                  activeIcon: Image.asset(AppImages.historyDark, height: 30),
                  label: 'Register',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.aboutMeImage, height: 26),
                  activeIcon: Image.asset(AppImages.settingDark, height: 30),
                  label: 'About Me',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(AppImages.menuImage, height: 26),
                  activeIcon: Image.asset(
                    AppImages.moreDarkImage,
                    height: 30,
                    color: AppColor.black,
                  ),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
