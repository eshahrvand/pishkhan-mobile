import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthFieldIcon extends StatelessWidget {
  const AuthFieldIcon(this.asset, {super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 44,
      child: Center(child: SvgPicture.asset(asset, width: 20, height: 20)),
    );
  }
}
