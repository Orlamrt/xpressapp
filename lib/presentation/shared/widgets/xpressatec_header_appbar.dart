import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class XpressatecHeaderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const XpressatecHeaderAppBar({
    super.key,
    this.showMenu = false,
    this.onMenuTap,
    this.showBack = false,
  });

  final bool showMenu;
  final VoidCallback? onMenuTap;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      foregroundColor: color,
      toolbarHeight: preferredSize.height,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: color),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : (showMenu
              ? Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(Icons.menu, color: color),
                      onPressed: onMenuTap ?? () {
                        final scaffoldState = Scaffold.maybeOf(context);
                        if (scaffoldState != null && scaffoldState.hasDrawer) {
                          scaffoldState.openDrawer();
                        }
                      },
                    );
                  },
                )
              : null),
      title: SvgPicture.asset(
        'assets/images/imagen.svg',
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }
}
