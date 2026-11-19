import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';

const _artSize = 260.0;

class _MiniShot extends StatelessWidget {
  const _MiniShot({required this.color, this.width = 64});

  static const _lines = 3;

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: width * 1.6,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.statusColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: width * 0.55,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          for (var i = 0; i < _lines; i++)
            Container(
              margin: const EdgeInsets.only(top: 5),
              height: 4,
              width: width * (i.isEven ? 0.7 : 0.5),
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

/// Scattered screenshots on the left, an ordered folder on the right.
class OrganizeIllustration extends StatelessWidget {
  const OrganizeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const colors = [
      Color(0xFFEC4899),
      AppColors.secondary,
      Color(0xFFF97316),
      AppColors.primary,
    ];
    return ExcludeSemantics(
      child: SizedBox(
        width: _artSize,
        height: _artSize,
        child: Stack(
          children: [
            for (final (i, c) in colors.indexed)
              Positioned(
                left: 6.0 + i * 16,
                top: 30.0 + (i.isEven ? 0 : 50) + i * 12,
                child: Transform.rotate(
                  angle: (i.isEven ? -1 : 1) * 0.18 * (i + 1) / 2,
                  child: _MiniShot(color: c, width: 52),
                ),
              ),
            Positioned(
              left: 112,
              top: 112,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: scheme.primary,
                size: 32,
              ),
            ),
            Positioned(
              right: 0,
              top: 40,
              child: Container(
                width: 104,
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: Column(
                  children: [
                    for (final c in colors)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 7, backgroundColor: c),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: scheme.outline,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A screenshot with highlighted recognised text beneath a search bar.
class SearchIllustration extends StatelessWidget {
  const SearchIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget line(double w, {bool hit = false}) => Container(
      margin: const EdgeInsets.only(top: 8),
      height: 10,
      width: w,
      decoration: BoxDecoration(
        color: hit ? AppColors.warning.withValues(alpha: 0.55) : scheme.outline,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return ExcludeSemantics(
      child: SizedBox(
        width: _artSize,
        height: _artSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 170,
              height: 230,
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                border: Border.all(color: context.statusColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  line(120),
                  line(90, hit: true),
                  line(130),
                  line(70),
                  line(110, hit: true),
                  line(80),
                ],
              ),
            ),
            Positioned(
              top: 6,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: scheme.onPrimary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'deadline 15 Dec',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A screenshot radiating into reminders, calendar entries, links and a
/// wishlist.
class ActionIllustration extends StatelessWidget {
  const ActionIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const items = [
      (Icons.alarm, AppColors.warning),
      (Icons.event_available, AppColors.primary),
      (Icons.link, AppColors.secondary),
      (Icons.favorite, Color(0xFFEC4899)),
    ];
    const radius = 100.0;
    return ExcludeSemantics(
      child: SizedBox(
        width: _artSize,
        height: _artSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline, width: 1.5),
              ),
            ),
            const _MiniShot(color: AppColors.primary, width: 70),
            for (final (i, (icon, color)) in items.indexed)
              Transform.translate(
                offset: Offset(
                  radius * math.cos(-math.pi / 4 + i * math.pi / 2),
                  radius * math.sin(-math.pi / 4 + i * math.pi / 2),
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
