import 'package:get/get.dart';

class SettingsController extends GetxController {
  bool soundEnabled = true;

  void toggleSound() {
    soundEnabled = !soundEnabled;
    update();
  }
}