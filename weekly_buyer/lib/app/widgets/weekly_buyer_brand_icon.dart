import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeeklyBuyerBrandIcon extends StatelessWidget {
  const WeeklyBuyerBrandIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/weekly_buyer.svg',
      width: size,
      height: size,
      semanticsLabel: 'Weekly Buyer brand icon',
    );
  }
}