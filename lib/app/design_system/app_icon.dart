import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIconKey { target }

class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.icon,
    required this.semanticLabel,
    this.size = 24,
    this.color,
    super.key,
  }) : assert(size == 16 || size == 20 || size == 24);

  final AppIconKey icon;
  final String semanticLabel;
  final double size;
  final Color? color;

  static const _assets = <AppIconKey, String>{
    AppIconKey.target: 'assets/icons/lucide/target.svg',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assets[icon];
    if (asset == null) {
      throw StateError('Missing Lucide allowlist asset for $icon');
    }
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter: ColorFilter.mode(
        color ?? IconTheme.of(context).color ?? Colors.black,
        BlendMode.srcIn,
      ),
    );
  }
}
