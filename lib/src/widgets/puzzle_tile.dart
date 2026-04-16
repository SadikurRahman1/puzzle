import 'package:flutter/material.dart';

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({super.key, required this.tile, required this.onTap});

  final int tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = tile == 0;
    final BorderRadius borderRadius = BorderRadius.circular(14);
    const List<Color> gradientColors = <Color>[Color(0xFF0A6E80), Color(0xFF12AFC5)];
    const Color glowColor = Color(0xFF28C4DC);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isEmpty
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
          color: isEmpty ? const Color(0xFFD8E8ED) : null,
          borderRadius: borderRadius,
          boxShadow: isEmpty
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : <BoxShadow>[
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 0.4,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
          border: Border.all(
            color: isEmpty ? const Color(0xFFBFD2D9) : Colors.white.withValues(alpha: 0.25),
            width: 1.1,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: <Widget>[
              if (!isEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.34),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 170),
                  child: isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          '$tile',
                          key: ValueKey<int>(tile),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 25,
                            letterSpacing: 0.3,
                            shadows: <Shadow>[
                              Shadow(
                                color: Color(0x55000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}