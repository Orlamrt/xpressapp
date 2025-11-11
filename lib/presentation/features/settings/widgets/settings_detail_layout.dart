import 'package:flutter/material.dart';

import '../../../shared/widgets/xpressatec_header_appbar.dart';

class SettingsDetailLayout extends StatelessWidget {
  const SettingsDetailLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.expandChild = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool expandChild;

  static BoxDecoration cardDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.35),
        width: 1.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                if (expandChild)
                  Expanded(child: child)
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: child,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
