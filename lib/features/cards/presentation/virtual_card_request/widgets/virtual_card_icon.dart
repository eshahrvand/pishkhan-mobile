import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class VirtualCardIcon extends StatelessWidget {
  const VirtualCardIcon({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 20, child: SvgPicture.asset(path));
  }
}
