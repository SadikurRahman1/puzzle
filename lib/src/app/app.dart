import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/score_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/sound_controller.dart';
import '../controllers/rating_controller.dart';
import '../screens/splash_page.dart';

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slide Master Puzzle',
      initialBinding: AppBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C7A8B)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ScoreController>(ScoreController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<SoundController>(SoundController(), permanent: true);
    Get.put<RatingController>(RatingController(), permanent: true);
  }
}