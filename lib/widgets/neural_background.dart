import 'dart:math';
import 'package:flutter/material.dart';

class NeuralBackground extends StatefulWidget {
  const NeuralBackground({super.key});

  @override
  State<NeuralBackground> createState() => _NeuralBackgroundState();
}

class _NeuralBackgroundState extends State<NeuralBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Node> _nodes = [];
  final int _nodeCount = 40;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize nodes with random positions and velocities
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < _nodeCount; i++) {
        _nodes.add(Node(
          position: Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height),
          velocity: Offset((_random.nextDouble() - 0.5) * 0.5, (_random.nextDouble() - 0.5) * 0.5),
        ));
      }
    });
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
          painter: NeuralPainter(nodes: _nodes, progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Node {
  Offset position;
  Offset velocity;

  Node({required this.position, required this.velocity});

  void update(Size size) {
    position += velocity;

    if (position.dx < 0 || position.dx > size.width) velocity = Offset(-velocity.dx, velocity.dy);
    if (position.dy < 0 || position.dy > size.height) velocity = Offset(velocity.dx, -velocity.dy);
  }
}

class NeuralPainter extends CustomPainter {
  final List<Node> nodes;
  final double progress;

  NeuralPainter({required this.nodes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00963F).withOpacity(0.15)
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0xFF00963F).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      nodes[i].update(size);
      
      // Draw node
      canvas.drawCircle(nodes[i].position, 2, dotPaint);

      // Draw lines between nearby nodes
      for (int j = i + 1; j < nodes.length; j++) {
        final distance = (nodes[i].position - nodes[j].position).distance;
        if (distance < 150) {
          paint.color = const Color(0xFF00963F).withOpacity(0.15 * (1 - distance / 150));
          canvas.drawLine(nodes[i].position, nodes[j].position, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
