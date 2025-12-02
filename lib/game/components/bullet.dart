import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../plane_game.dart';
import 'enemy.dart';

import 'package:flutter/material.dart';

class Bullet extends PositionComponent
    with HasGameRef<PlaneGame>, CollisionCallbacks {
  final double speed = 400;
  final Paint _paint = Paint()..color = Colors.yellow;

  Bullet({required Vector2 position})
    : super(position: position, size: Vector2(10, 20), anchor: Anchor.center);

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
    position.y -= speed * dt;

    if (position.y < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
      other.takeDamage();
    }
  }
}
