import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../plane_game.dart';
import 'player.dart';

class EnemyBullet extends PositionComponent with HasGameRef<PlaneGame>, CollisionCallbacks {
  final double speed = 300;
  final Paint _paint = Paint()..color = Colors.yellow;

  EnemyBullet({required Vector2 position})
    : super(position: position, size: Vector2(8, 16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
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
      other.takeDamage();
    }
  }
}

