import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../plane_game.dart';

class Particle extends PositionComponent with HasGameRef<PlaneGame> {
  final Vector2 velocity;
  final double lifeTime;
  late double _timer;
  final Paint paint = Paint()..color = Colors.red;

  Particle({
    required Vector2 position,
    required this.velocity,
    this.lifeTime = 0.5,
  }) : super(position: position, size: Vector2(4, 4), anchor: Anchor.center) {
    _timer = lifeTime;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
    _timer -= dt;
    if (_timer <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    paint.color = paint.color.withAlpha((255 * (_timer / lifeTime)).toInt());
    canvas.drawRect(size.toRect(), paint);
  }
}
