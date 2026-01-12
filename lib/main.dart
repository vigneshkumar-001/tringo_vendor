import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Core/Const/app_color.dart';

import 'Core/Const/app_images.dart';
import 'Core/Utility/app_textstyles.dart';
import 'Core/Widgets/app_go_routes.dart';
import 'Core/Widgets/common_container.dart';
import 'dummy_screen.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: AppColor.white),
        );
      },
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 160),
          child: Column(
            children: [
              Image.asset(AppImages.noDataGif),
              SizedBox(height: 30),
              Text(
                'No Internet Connection',
                style: AppTextStyles.mulish(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColor.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final routerRefreshProvider = Provider<ChangeNotifier>((ref) {
  final notifier = ValueNotifier<int>(0);

  // whenever internetStatusProvider changes, refresh go_router
  ref.listen(internetStatusProvider, (_, __) {
    notifier.value++;
  });

  ref.onDispose(notifier.dispose);
  return notifier;
});
