import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../plane_game.dart';
import 'player.dart';

import 'package:flutter/material.dart';

enum PowerUpType { rapidFire, multiShot, shield, heart }

class PowerUp extends PositionComponent
    with HasGameRef<PlaneGame>, CollisionCallbacks {
  final double speed = 150;
  final PowerUpType type;
  late Paint _paint;

  PowerUp({required Vector2 position, required this.type})
    : super(position: position, size: Vector2(30, 30), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    switch (type) {
      case PowerUpType.rapidFire:
        _paint = Paint()..color = Colors.orange;
        break;
      case PowerUpType.multiShot:
        _paint = Paint()..color = Colors.green;
        break;
      case PowerUpType.shield:
        _paint = Paint()..color = Colors.cyan;
        break;
      case PowerUpType.heart:
        _paint = Paint()..color = Colors.red;
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (type == PowerUpType.shield) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 3, innerPaint);
    } else if (type == PowerUpType.heart) {
      final path = Path();
      final centerX = size.x / 2;
      final centerY = size.y / 2;
      path.moveTo(centerX, centerY + size.y / 4);
      path.cubicTo(
        centerX - size.x / 2,
        centerY - size.y / 4,
        centerX - size.x / 4,
        centerY - size.y / 2,
        centerX,
        centerY - size.y / 6,
      );
      path.cubicTo(
        centerX + size.x / 4,
        centerY - size.y / 2,
        centerX + size.x / 2,
        centerY - size.y / 4,
        centerX,
        centerY + size.y / 4,
      );
      path.close();
      canvas.drawPath(path, _paint);
    } else {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      removeFromParent();
      other.activatePowerUp(type);
    }
  }
}
