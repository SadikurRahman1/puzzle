import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingController extends GetxController {
  static const String _kOpenCount = 'rating_open_count';
  static const String _kRated = 'rating_done';
  static const int _promptStartAfterOpens = 3;

  Future<void> registerAppOpenAndMaybePrompt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadyRated = prefs.getBool(_kRated) ?? false;
    if (alreadyRated) {
      return;
    }

    final int openCount = (prefs.getInt(_kOpenCount) ?? 0) + 1;
    await prefs.setInt(_kOpenCount, openCount);

    final bool shouldPrompt = openCount >= _promptStartAfterOpens && openCount % 3 == 0;
    if (!shouldPrompt) {
      return;
    }

    // Delay slightly so prompt appears after navigation and first frame draw.
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!Get.isRegistered<RatingController>()) {
      return;
    }

    _showPremiumRatingDialog();
  }

  void _showPremiumRatingDialog() {
    if (Get.isDialogOpen ?? false) {
      return;
    }

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF075463), Color(0xFF0A7C8E), Color(0xFF0AA0B5)],
            ),
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
                child: const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 34),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enjoying the Puzzle?',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please rate us on Play Store to support future premium updates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFE1F7FC), height: 1.35),
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
                      onPressed: () => Get.back<void>(),
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
                        unawaited(_rateNow());
                      },
                      child: const Text('Rate Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _rateNow() async {
    final InAppReview inAppReview = InAppReview.instance;
    try {
      final bool available = await inAppReview.isAvailable();
      if (available) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing();
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRated, true);
    } catch (_) {
      // Keep app flow stable even if rating API fails.
    }

    if (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
  }
}