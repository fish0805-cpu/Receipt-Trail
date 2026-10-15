import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WarmPageBackground extends StatelessWidget {
  const WarmPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7EC), AppPalette.paper, Color(0xFFE7F3EC)],
          ),
        ),
        child: child,
      );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppPalette.forest,
          borderRadius: BorderRadius.circular(size * .3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220E4D3D),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Icon(
          Icons.receipt_long_rounded,
          color: const Color(0xFFFFF8E8),
          size: size * .5,
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip.elevated(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppPalette.forest,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppPalette.ink,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide.none,
    );
  }
}
