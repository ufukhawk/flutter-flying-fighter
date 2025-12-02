import 'package:flutter/material.dart';
import '../plane_game.dart';

class Hud extends StatelessWidget {
  final PlaneGame game;

  const Hud({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: game.lives,
                builder: (context, value, child) {
                  return Text(
                    'Lives: $value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (context, value, child) {
                  return Text(
                    'Score: $value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: game.level,
                builder: (context, value, child) {
                  return Text(
                    'Level: $value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            onPressed: () {
              game.pauseGame();
            },
            icon: const Icon(
              Icons.pause_circle,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ],
    );
  }
}
