import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class VirtualCardIcon extends StatelessWidget {
  const VirtualCardIcon({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 20, child: AvpImage(image: path));
  }
}
