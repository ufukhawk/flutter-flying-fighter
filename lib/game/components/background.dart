import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../plane_game.dart';

class Background extends PositionComponent with HasGameRef<PlaneGame> {
  final List<_MapObject> _objects = [];
  final List<_Cloud> _clouds = [];
  final Random _random = Random();
  double _spawnTimer = 0;

  Background() : super(priority: -1); // Render behind everything

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    // Initial spawn
    for (int i = 0; i < 20; i++) {
      _spawnObject(y: _random.nextDouble() * size.y);
    }
    for (int i = 0; i < 5; i++) {
      _spawnCloud(y: _random.nextDouble() * size.y);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Scroll objects
    for (var obj in _objects) {
      obj.y += 100 * dt; // Terrain speed
    }
    _objects.removeWhere((obj) => obj.y > size.y + 100);

    // Scroll clouds
    for (var cloud in _clouds) {
      cloud.y += 150 * dt; // Cloud speed
    }
    _clouds.removeWhere((cloud) => cloud.y > size.y + 100);

    // Spawn new objects
    _spawnTimer += dt;
    if (_spawnTimer > 0.5) {
      _spawnObject(y: -100);
      if (_random.nextDouble() < 0.3) {
        _spawnCloud(y: -100);
      }
      _spawnTimer = 0;
    }
  }

  void _spawnObject({required double y}) {
    final type = _random.nextInt(3); // 0: House, 1: Forest, 2: Lake
    final x = _random.nextDouble() * size.x;
    _objects.add(_MapObject(x: x, y: y, type: type, random: _random));
  }

  void _spawnCloud({required double y}) {
    final x = _random.nextDouble() * size.x;
    _clouds.add(_Cloud(x: x, y: y, random: _random));
  }

  @override
  void render(Canvas canvas) {
    // Draw base land
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF4CAF50),
    ); // Green land

    // Draw objects
    for (var obj in _objects) {
      obj.render(canvas);
    }

    // Draw clouds
    for (var cloud in _clouds) {
      cloud.render(canvas);
    }
  }
}

class _MapObject {
  double x;
  double y;
  final int type;
  final Paint _paint;
  final double _size;

  _MapObject({
    required this.x,
    required this.y,
    required this.type,
    required Random random,
  }) : _size = 30 + random.nextDouble() * 40,
       _paint = Paint() {
    if (type == 0)
      _paint.color = Colors.brown; // House
    else if (type == 1)
      _paint.color = const Color(0xFF1B5E20); // Forest
    else
      _paint.color = Colors.blue; // Lake
  }

  void render(Canvas canvas) {
    if (type == 0) {
      // House (Square roof from top)
      canvas.drawRect(Rect.fromLTWH(x, y, _size, _size), _paint);
      // Add a slight border or detail to make it look like a roof
      canvas.drawRect(
        Rect.fromLTWH(x + 2, y + 2, _size - 4, _size - 4),
        Paint()..color = _paint.color.withOpacity(0.7),
      );
    } else if (type == 1) {
      // Forest (Circle)
      canvas.drawCircle(Offset(x, y), _size / 2, _paint);
    } else {
      // Lake (Oval)
      canvas.drawOval(Rect.fromLTWH(x, y, _size * 1.5, _size), _paint);
    }
  }
}

class _Cloud {
  double x;
  double y;
  final double _size;
  final Paint _paint = Paint()..color = Colors.white.withOpacity(0.7);

  _Cloud({required this.x, required this.y, required Random random})
    : _size = 50 + random.nextDouble() * 50;

  void render(Canvas canvas) {
    canvas.drawCircle(Offset(x, y), _size / 2, _paint);
    canvas.drawCircle(
      Offset(x + _size * 0.5, y + _size * 0.2),
      _size / 3,
      _paint,
    );
    canvas.drawCircle(
      Offset(x - _size * 0.5, y + _size * 0.2),
      _size / 3,
      _paint,
    );
  }
}
