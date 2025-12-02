import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/enemy.dart';
import 'components/enemy_bullet.dart';
import 'components/power_up.dart';
import 'components/background.dart';

class PlaneGame extends FlameGame with HasCollisionDetection, PanDetector {
  late Player player;
  late Timer interval;
  final ValueNotifier<int> lives = ValueNotifier<int>(3);
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> level = ValueNotifier<int>(1);
  double baseSpawnInterval = 1.5;

  @override
  Future<void> onLoad() async {
    add(Background());
    player = Player();
    add(player);
    interval = Timer(baseSpawnInterval, onTick: spawnEnemy, repeat: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }

  void spawnEnemy() {
    final random = Random();
    final int enemyCount = min(5, 1 + (level.value ~/ 2));
    for (int i = 0; i < enemyCount; i++) {
      final x = random.nextDouble() * (size.x - 40);
      final bool shouldShoot = level.value >= 10 && random.nextDouble() < 0.3;
      add(Enemy(position: Vector2(x, -50.0 * i), canShoot: shouldShoot));
    }
    if (level.value >= 5) {
      if (random.nextDouble() < 0.15) {
        final px = random.nextDouble() * (size.x - 30);
        PowerUpType powerUpType;
        if (level.value >= 10) {
          final availableTypes = [
            PowerUpType.rapidFire,
            PowerUpType.multiShot,
            PowerUpType.shield,
            PowerUpType.heart,
          ];
          powerUpType = availableTypes[random.nextInt(availableTypes.length)];
        } else {
          final availableTypes = [PowerUpType.rapidFire, PowerUpType.multiShot];
          powerUpType = availableTypes[random.nextInt(availableTypes.length)];
        }
        add(PowerUp(position: Vector2(px, 0), type: powerUpType));
      }
    } else {
      if (random.nextDouble() < 0.2) {
        final px = random.nextDouble() * (size.x - 30);
        final availableTypes = [PowerUpType.rapidFire, PowerUpType.multiShot];
        add(
          PowerUp(
            position: Vector2(px, 0),
            type: availableTypes[random.nextInt(availableTypes.length)],
          ),
        );
      }
    }
  }

  void decreaseLives() {
    lives.value--;
    if (lives.value <= 0) {
      pauseEngine();
      overlays.add('GameOver');
    }
  }

  void increaseLives() {
    if (lives.value < 10) {
      lives.value++;
    }
  }

  void increaseScore() {
    score.value += 10;
    if (score.value >= level.value * 100) {
      level.value++;
      player.levelUp(level.value);
      updateSpawnSpeed();
    }
  }

  void updateSpawnSpeed() {
    final double newInterval = max(
      0.3,
      baseSpawnInterval - (level.value - 1) * 0.15,
    );
    interval.limit = newInterval;
  }

  void pauseGame() {
    pauseEngine();
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    resumeEngine();
  }

  void restartGame() {
    overlays.remove('GameOver');
    overlays.remove('PauseMenu');
    lives.value = 3;
    score.value = 0;
    level.value = 1;
    interval.limit = baseSpawnInterval;
    children.whereType<Enemy>().toList().forEach(
      (enemy) => enemy.removeFromParent(),
    );
    children.whereType<PowerUp>().toList().forEach(
      (powerUp) => powerUp.removeFromParent(),
    );
    children.whereType<EnemyBullet>().toList().forEach(
      (bullet) => bullet.removeFromParent(),
    );
    player.position = Vector2(size.x / 2, size.y - 100);
    player.resetToLevel1();
    resumeEngine();
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.targetPosition = info.eventPosition.global;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.targetPosition = info.eventPosition.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.targetPosition = null;
  }

  @override
  void onPanCancel() {
    player.targetPosition = null;
  }
}
