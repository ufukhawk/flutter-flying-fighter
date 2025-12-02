import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/plane_game.dart';
import 'game/overlays/hud.dart';
import 'game/overlays/pause_menu.dart';
import 'game/overlays/game_over_menu.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<PlaneGame>(
          game: PlaneGame(),
          overlayBuilderMap: {
            'Hud': (BuildContext context, PlaneGame game) {
              return Hud(game: game);
            },
            'PauseMenu': (BuildContext context, PlaneGame game) {
              return PauseMenu(game: game);
            },
            'GameOver': (BuildContext context, PlaneGame game) {
              return GameOverMenu(game: game);
            },
          },
          initialActiveOverlays: const ['Hud'],
        ),
      ),
    );
  }
}
