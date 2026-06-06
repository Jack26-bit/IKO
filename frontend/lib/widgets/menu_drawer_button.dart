import 'package:flutter/material.dart';

import '../core/theme.dart';

class MenuDrawerButton extends StatelessWidget {
  final double size;

  const MenuDrawerButton({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: IkoTheme.surfaceContainerLowest,
        ),
        child: Icon(
          Icons.menu,
          size: size * 0.55,
          color: IkoTheme.primary,
        ),
      ),
    );
  }
}
