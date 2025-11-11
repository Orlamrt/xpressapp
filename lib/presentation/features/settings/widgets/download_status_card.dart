import 'package:flutter/material.dart';

class DownloadStatusCard extends StatelessWidget {
  const DownloadStatusCard({
    super.key,
    required this.bannerIcon,
    required this.bannerIconColor,
    required this.bannerBackgroundColor,
    required this.bannerMessage,
    required this.buttonLabel,
    required this.buttonEnabled,
    this.onPressed,
    this.buttonIcon = Icons.download,
    this.additionalChildren = const [],
    this.buttonBackgroundColor,
    this.buttonForegroundColor,
  });

  final IconData bannerIcon;
  final Color bannerIconColor;
  final Color bannerBackgroundColor;
  final String bannerMessage;
  final String buttonLabel;
  final bool buttonEnabled;
  final VoidCallback? onPressed;
  final IconData buttonIcon;
  final List<Widget> additionalChildren;
  final Color? buttonBackgroundColor;
  final Color? buttonForegroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
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
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBanner(
            icon: bannerIcon,
            background: bannerBackgroundColor,
            iconColor: bannerIconColor,
            text: bannerMessage,
          ),
          if (additionalChildren.isNotEmpty) ...[
            const SizedBox(height: 24),
            ..._spacedChildren(additionalChildren),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: buttonEnabled ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: buttonBackgroundColor ?? Colors.lightBlue,
              foregroundColor: buttonForegroundColor ?? Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: Icon(buttonIcon),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  List<Widget> _spacedChildren(List<Widget> children) {
    if (children.length <= 1) {
      return children;
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        spacedChildren.add(const SizedBox(height: 16));
      }
      spacedChildren.add(children[i]);
    }
    return spacedChildren;
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
