import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Enam ekspresi Chiko. Nama enum = nama file di assets/chiko/.
enum ChikoMood { santai, senang, rayakan, khawatir, kaget, tidur }

/// Chiko versi sementara (sebelum animasi Rive):
/// - bergerak naik-turun pelan seperti bernapas,
/// - "memantul" saat disentuh,
/// - berganti ekspresi dengan transisi halus.
class Chiko extends StatefulWidget {
  const Chiko({super.key, this.mood = ChikoMood.santai, this.size = 120, this.onTap, this.animate = true});

  final ChikoMood mood;

  /// Tinggi gambar. Lebarnya otomatis mengikuti proporsi (690:820).
  final double size;
  final VoidCallback? onTap;
  final bool animate;

  @override
  State<Chiko> createState() => _ChikoState();
}

class _ChikoState extends State<Chiko> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _idle.repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounce.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.size * 690 / 820;
    return Semantics(
      label: 'Chiko, ekspresi ${widget.mood.name}',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_idle, _bounce]),
          builder: (context, child) {
            final bob = math.sin(_idle.value * 2 * math.pi) * widget.size * 0.012;
            final t = _bounce.value;
            final squash = math.sin(t * math.pi * 2) * (1 - t) * 0.10;
            return Transform.translate(
              offset: Offset(0, bob),
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.diagonal3Values(1 + squash, 1 - squash, 1),
                child: child,
              ),
            );
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: SvgPicture.asset(
              'assets/chiko/chiko_${widget.mood.name}.svg',
              key: ValueKey(widget.mood),
              width: width,
              height: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}
