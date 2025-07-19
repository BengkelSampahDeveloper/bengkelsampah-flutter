import 'package:bengkelsampah_app/widgets/paint_arc.dart';
import 'package:flutter/material.dart';

class LogoAndSpinner extends StatefulWidget {
  final String imageAssets;
  final bool reverse;
  final Color arcColor;
  final Duration spinSpeed;

  const LogoAndSpinner({
    Key? key,
    required this.imageAssets,
    this.reverse = false,
    this.spinSpeed = const Duration(seconds: 2),
    this.arcColor = Colors.blueAccent,
  }) : super(key: key);

  @override
  State<LogoAndSpinner> createState() => _LogoandSpinnerState();
}

class _LogoandSpinnerState extends State<LogoAndSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animationRotation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.spinSpeed);
    animationRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );
    _controller.repeat(reverse: widget.reverse);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(widget.imageAssets),
            ),
            RotationTransition(turns: animationRotation, child: buildRing()),
          ],
        ),
      ),
    );
  }

  Widget buildRing() {
    return Stack(
      children: [
        CustomPaint(
          painter: PaintArc(start: 2, sweep: 5, color: widget.arcColor),
        ),
        CustomPaint(
          painter: PaintArc(
            start: 18,
            sweep: 5,
            color: widget.arcColor,
          ),
        ),
      ],
    );
  }
}
