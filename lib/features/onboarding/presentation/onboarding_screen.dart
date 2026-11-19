import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/bootstrap.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/brand.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() =>
      ref.read(onboardingCompletedProvider.notifier).complete();

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = [
      (l10n.onboarding1Title, l10n.onboarding1Body, BrandArt.onboardingWelcome),
      (l10n.onboarding2Title, l10n.onboarding2Body, BrandArt.onboardingPrivacy),
      (l10n.onboarding3Title, l10n.onboarding3Body, BrandArt.onboardingActions),
    ];
    final last = _page == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xs),
                child: ExcludeSemantics(
                  // Hidden on the last page; keep it out of TalkBack too.
                  excluding: last,
                  child: AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: last ? null : _finish,
                      child: Text(l10n.onboardingSkip),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (title, body, art) = pages[i];
                  // The illustration takes up to half the height and scales
                  // down; the text below scrolls rather than overflowing on
                  // small screens or with large text.
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: (constraints.maxHeight * 0.5).clamp(
                                96.0,
                                300.0,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: BrandIllustration(art, size: 300),
                              ),
                            ),
                            const Gap(Spacing.md),
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Gap(Spacing.sm),
                            Text(
                              body,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(Spacing.lg),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _PageIndicator(count: _pageCount, index: _page),
            const Gap(Spacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                  const Gap(Spacing.xs),
                  Expanded(
                    child: Text(
                      l10n.onboardingPrivacy,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(Spacing.md),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.lg,
              ),
              child: PopShadow.pill(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    key: const ValueKey('onboarding_next'),
                    onPressed: _next,
                    child: Text(
                      last
                          ? l10n.onboardingGetStarted
                          : l10n.onboardingContinue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == index ? scheme.primary : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(5),
                border: i == index
                    ? Border.all(color: scheme.outline, width: 1.5)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
