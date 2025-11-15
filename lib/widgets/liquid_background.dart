import 'package:flutter/material.dart';

class LiquidBackground extends StatefulWidget {
  const LiquidBackground({super.key});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 23),
    )..repeat(reverse: true);

    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation1,
          child: const SizedBox(
            height: 400,
            width: 400,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF5DB075), Color(0x005DB075)],
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                -150 + (_animation1.value * 80),
                -100 + (_animation1.value * 50),
              ),
              child: child,
            );
          },
        ),
        AnimatedBuilder(
          animation: _animation2,
          child: const SizedBox(
            height: 500,
            width: 500,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF66a681), Color(0x0066a681)],
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: Offset(
                  -200 + (_animation2.value * 100),
                  -150 - (_animation2.value * 60),
                ),
                child: child,
              ),
            );
          },
        ),
      ],
    );
  }
}
