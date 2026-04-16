import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/puzzle_controller.dart';
import '../controllers/score_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/puzzle_tile.dart';
import '../widgets/score_metric_row.dart';
import '../widgets/stat_chip.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key, required this.size});

  final int size;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PuzzleController>(
      init: PuzzleController(size: size),
      builder: (PuzzleController controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF075463),
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 10,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$size x $size Puzzle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Slide and solve in style',
                  style: TextStyle(color: Colors.teal.shade50, fontSize: 12),
                ),
              ],
            ),
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF075463), Color(0xFF0A7C8E)],
                ),
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: controller.restart,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Shuffle',
                ),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF075463), Color(0xFF0A7C8E)],
              ),
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   // colors: <Color>[Color(0xFFF2FCFF), Color(0xFFE5F5F8), Color(0xFFF8FAFB)],
              //   colors: <Color>[Color(0xFFF2FCFF), Color(0xFFF8FAFB)],

              //   // colors: <Color>[
              //   //   Color(0xFFDDF3F8),
              //   //   Color(0xFFC4E8F0),
              //   //   Color(0xFFAEDBE6),
              //   //   Color(0xFF9FD2DF),
              //   // ],
              // ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double boardSize = min(constraints.maxWidth - 24, 460);
                  return Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: <Widget>[
                            GetBuilder<PuzzleController>(
                              id: 'stats',
                              builder: (PuzzleController statsController) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        Color(0xFF0A6678),
                                        Color(0xFF118FA5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0F7E95,
                                        ).withValues(alpha: 0.34),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      StatChip(
                                        icon: Icons.swap_calls_rounded,
                                        label: 'Moves',
                                        value: '${statsController.moves}',
                                      ),
                                      const SizedBox(width: 10),
                                      StatChip(
                                        icon: Icons.timer_rounded,
                                        label: 'Time',
                                        value: statsController.timeText,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            GetBuilder<PuzzleController>(
                              id: 'board',
                              builder: (PuzzleController boardController) {
                                return SizedBox(
                                  width: boardSize,
                                  height: boardSize,
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: boardController.tiles.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: size,
                                          mainAxisSpacing: 7,
                                          crossAxisSpacing: 7,
                                        ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final int tile =
                                              boardController.tiles[index];
                                          return PuzzleTile(
                                            tile: tile,
                                            onTap: () => boardController
                                                .slideTile(index),
                                          );
                                        },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF0A7C8E),
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   colors: <Color>[Color(0xFF075463), Color(0xFF0A7C8E)],
                // ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showScoreDialog(context, controller),
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('Scores'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GetBuilder<SettingsController>(
                      builder: (SettingsController settings) {
                        return OutlinedButton.icon(
                          onPressed: settings.toggleSound,
                          icon: Icon(
                            settings.soundEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                          ),
                          label: Text(
                            settings.soundEnabled ? 'Sound On' : 'Sound Off',
                          ),
                          style: OutlinedButton.styleFrom(
                            // foregroundColor: Colors.blue, // text + icon color
                            // side: BorderSide(color: Colors.blue),
                            backgroundColor: Colors.white, // border color
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScoreDialog(BuildContext context, PuzzleController controller) {
    Get.dialog<void>(
      GetBuilder<ScoreController>(
        builder: (ScoreController scores) {
          final int? bestMoves = scores.bestMovesOf(size);
          final int? bestTime = scores.bestTimeOf(size);
          final String bestTimeText = bestTime == null
              ? '--:--'
              : '${(bestTime ~/ 60).toString().padLeft(2, '0')}:${(bestTime % 60).toString().padLeft(2, '0')}';

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF075463),
                    Color(0xFF0A7C8E),
                    Color(0xFF0AA0B5),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Premium Score Board',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ScoreMetricRow(label: 'Board', value: '$size x $size'),
                  ScoreMetricRow(
                    label: 'Current Moves',
                    value: '${controller.moves}',
                  ),
                  ScoreMetricRow(
                    label: 'Current Time',
                    value: controller.timeText,
                  ),
                  ScoreMetricRow(
                    label: 'Wins',
                    value: '${scores.winsOf(size)}',
                  ),
                  ScoreMetricRow(
                    label: 'Best Moves',
                    value: bestMoves?.toString() ?? '-',
                  ),
                  ScoreMetricRow(label: 'Best Time', value: bestTimeText),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF075463),
                      ),
                      onPressed: () => Get.back<void>(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
