import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  
  const ConfettiAnimation({
    super.key,
    required this.onComplete,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Konfeti parçacıklarını oluştur
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        color: _getRandomColor(),
        x: _random.nextDouble(),
        y: -0.1,
        velocityX: (_random.nextDouble() - 0.5) * 2,
        velocityY: _random.nextDouble() * 2 + 2,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFA500),
      const Color(0xFFFFE57F),
      const Color(0xFF2E6CB5),
      const Color(0xFF1A5490),
      Colors.white,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final x = size.width * particle.x + particle.velocityX * progress * 100;
      final y = particle.y * size.height + particle.velocityY * progress * 100;
      
      // Yerçekimi efekti
      final gravity = progress * progress * 50;

      canvas.save();
      canvas.translate(x, y + gravity);
      canvas.rotate((particle.rotation + particle.rotationSpeed * progress) * pi / 180);
      
      // Konfeti şekli (dikdörtgen)
      canvas.drawRect(
        const Rect.fromLTWH(-4, -8, 8, 16),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}