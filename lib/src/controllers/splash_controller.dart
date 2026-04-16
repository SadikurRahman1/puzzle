import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/model/version_status.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'rating_controller.dart';
import '../screens/home_page.dart';

class SplashController extends GetxController {
  static const String _androidPackageId = 'com.sadik.slidemaster';

  @override
  void onInit() {
    super.onInit();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!_isActive) {
      return;
    }

    final VersionStatus? status = await _readVersionStatus().timeout(
      const Duration(seconds: 1),
      onTimeout: () => null,
    );
    if (!_isActive) {
      return;
    }

    if (status != null && status.canUpdate) {
      _showPremiumUpdateDialog(status);
      return;
    }

    _goHome();
  }

  Future<VersionStatus?> _readVersionStatus() async {
    try {
      final NewVersionPlus updater = NewVersionPlus(androidId: _androidPackageId);
      return await updater.getVersionStatus();
    } catch (_) {
      return null;
    }
  }

  bool get _isActive => Get.isRegistered<SplashController>();

  void _goHome() {
    if (!_isActive) {
      return;
    }
    Get.offAll(() => const HomePage());
    unawaited(Get.find<RatingController>().registerAppOpenAndMaybePrompt());
  }

  void _showPremiumUpdateDialog(VersionStatus status) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF075463), Color(0xFF0A7C8E), Color(0xFF0AA0B5)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.system_update_alt_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                'New Premium Update',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'A new version is available on Play Store.\nCurrent: ${status.localVersion}  ->  Latest: ${status.storeVersion}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE1F7FC), height: 1.35),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () {
                        Get.back<void>();
                        _goHome();
                      },
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF075463),
                      ),
                      onPressed: () {
                        unawaited(_openStore(status.appStoreLink));
                      },
                      child: const Text('Update Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _openStore(String storeLink) async {
    final Uri uri = Uri.parse(storeLink);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fall through and continue into the app when external store launch fails.
    }

    if (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
    _goHome();
  }
}