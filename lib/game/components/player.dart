import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/timer.dart';
import '../plane_game.dart';
import 'bullet.dart';
import 'power_up.dart';
import 'particle.dart';

import 'package:flutter/material.dart';

class Player extends PositionComponent
    with HasGameRef<PlaneGame>, CollisionCallbacks {
  PowerUpType? currentPowerUp;
  late Timer powerUpTimer;
  final Paint _paint = Paint()..color = Colors.blue;
  final Paint _shieldPaint = Paint()
    ..color = Colors.cyan.withOpacity(0.3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  late Timer _shootTimer;
  Vector2? targetPosition;
  bool hasShield = false;
  late Timer shieldTimer;

  Player() : super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
    add(RectangleHitbox());
    powerUpTimer = Timer(
      5,
      onTick: () {
        currentPowerUp = null;
      },
    );
    _shootTimer = Timer(0.5, onTick: shoot, repeat: true);
    shieldTimer = Timer(
      10,
      onTick: () {
        hasShield = false;
      },
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final path = Path();
    path.moveTo(size.x / 2, 0);
    path.lineTo(size.x, size.y);
    path.lineTo(size.x / 2, size.y - 10);
    path.lineTo(0, size.y);
    path.close();
    canvas.drawPath(path, _paint);
    if (hasShield) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.8,
        _shieldPaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    powerUpTimer.update(dt);
    _shootTimer.update(dt);
    if (hasShield) {
      shieldTimer.update(dt);
    }
    if (targetPosition != null) {
      final double speed = 800.0;
      final Vector2 direction = (targetPosition! - position).normalized();
      final double distance = position.distanceTo(targetPosition!);
      if (distance > 5) {
        position.add(direction * speed * dt);
        position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);
      }
    }
    final particleOffset = Vector2(0, size.y * 0.75);
    gameRef.add(
      Particle(
        position: position + particleOffset,
        velocity: Vector2(0, 100),
        lifeTime: 0.2,
      )..paint.color = Colors.orange,
    );
  }

  void shoot() {
    if (currentPowerUp == PowerUpType.multiShot) {
      gameRef.add(Bullet(position: position.clone()..y -= size.y / 2));
      gameRef.add(
        Bullet(
          position: position.clone()
            ..y -= size.y / 2
            ..x -= 20,
        ),
      );
      gameRef.add(
        Bullet(
          position: position.clone()
            ..y -= size.y / 2
            ..x += 20,
        ),
      );
    } else {
      gameRef.add(Bullet(position: position.clone()..y -= size.y / 2));
    }
  }

  void activatePowerUp(PowerUpType type) {
    if (type == PowerUpType.shield) {
      hasShield = true;
      shieldTimer.reset();
      shieldTimer.start();
    } else if (type == PowerUpType.heart) {
      gameRef.increaseLives();
    } else {
      currentPowerUp = type;
      powerUpTimer.reset();
      powerUpTimer.start();
    }
  }

  void takeDamage() {
    if (hasShield) {
      hasShield = false;
      shieldTimer.stop();
    } else {
      gameRef.decreaseLives();
    }
  }

  void levelUp(int newLevel) {
    if (newLevel == 2) {
      _paint.color = Colors.purple;
    }
    if (newLevel == 3) {
      _paint.color = Colors.cyan;
    }
    if (newLevel > 3) {
      _paint.color = Colors.white;
    }
    _shootTimer.limit = max(0.1, 0.5 - (newLevel - 1) * 0.1);
  }

  void resetToLevel1() {
    _paint.color = Colors.blue;
    _shootTimer.limit = 0.5;
    currentPowerUp = null;
    hasShield = false;
  }
}
