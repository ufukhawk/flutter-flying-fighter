import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/timer.dart';
import 'dart:math';
import '../plane_game.dart';
import 'player.dart';
import 'particle.dart';
import 'enemy_bullet.dart';

import 'package:flutter/material.dart';

class Enemy extends PositionComponent
    with HasGameRef<PlaneGame>, CollisionCallbacks {
  final double speed = 200;
  final Paint _paint = Paint()..color = Colors.red;
  final double horizontalSpeed = 100;
  final bool canShoot;
  late Timer shootTimer;
  double direction = 1;

  Enemy({required Vector2 position, this.canShoot = false})
    : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    if (canShoot) {
      shootTimer = Timer(
        1.5 + Random().nextDouble(),
        onTick: shoot,
        repeat: true,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final path = Path();
    path.moveTo(size.x / 2, size.y);
    path.lineTo(0, 0);
    path.lineTo(size.x / 2, size.y / 4);
    path.lineTo(size.x, 0);
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    position.x += horizontalSpeed * direction * dt;
    if (position.x <= size.x / 2 || position.x >= gameRef.size.x - size.x / 2) {
      direction *= -1;
    }
    if (canShoot) {
      shootTimer.update(dt);
    }
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  void shoot() {
    gameRef.add(
      EnemyBullet(
        position: position.clone()..y += size.y / 2,
      ),
    );
  }

  void takeDamage() {
    final random = Random();
    for (int i = 0; i < 10; i++) {
      final velocity = Vector2(
        (random.nextDouble() - 0.5) * 300,
        (random.nextDouble() - 0.5) * 300,
      );
      gameRef.add(Particle(position: position.clone(), velocity: velocity));
    }
    gameRef.increaseScore();
    removeFromParent();
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
