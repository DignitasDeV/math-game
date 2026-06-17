import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_screen_header.dart';
import '../../core/widgets/magic_scaffold.dart';
import '../../core/widgets/speech_toggle_button.dart';
import '../../models/help_topic.dart';
import '../../models/localized_text.dart';
import '../../services/audio_service.dart';
import '../../services/content_repository.dart';
import '../../services/profile_controller.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  String? _expandedTopicId;

  @override
  Widget build(BuildContext context) {
    final topicsState = ref.watch(helpTopicsProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final languageCode = activeProfile?.language.ttsCode ?? 'es-ES';
    final isCatalan = languageCode == 'ca-ES';

    return MagicScaffold(
      title: isCatalan ? 'Ajuda' : 'Ayuda',
      backgroundAssetPath: 'assets/images/backgrounds/magic_tower_screen.webp',
      child: topicsState.when(
        data: (topics) {
          if (topics.isEmpty) {
            return Center(
              child: Text(
                isCatalan
                    ? "No hi ha temes d'ajuda."
                    : 'No hay temas de ayuda.',
              ),
            );
          }

          final expandedTopicId = _expandedTopicId ?? topics.first.id;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadableSurface(
                child: AppScreenHeader(
                  icon: Icons.lightbulb_rounded,
                  title: isCatalan ? 'Ajuda' : 'Ayuda',
                  subtitle: isCatalan
                      ? 'Explicacions curtes per aprendre pas a pas.'
                      : 'Explicaciones cortas para aprender paso a paso.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: topics.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final isExpanded = topic.id == expandedTopicId;
                    return _HelpTopicCard(
                      topic: topic,
                      languageCode: languageCode,
                      isExpanded: isExpanded,
                      onTap: () {
                        if (!isExpanded) {
                          setState(() => _expandedTopicId = topic.id);
                        }
                      },
                      speechText: _speechTextForTopic(topic, languageCode),
                      voiceId: activeProfile?.ttsVoiceId,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () => playTapAndRun(
              context,
              () => ref.invalidate(helpTopicsProvider),
            ),
            child: Text(isCatalan ? 'Torna-ho a provar' : 'Reintentar'),
          ),
        ),
      ),
    );
  }

  String _speechTextForTopic(HelpTopic topic, String languageCode) {
    final exampleLabel = languageCode == 'ca-ES' ? 'Exemple' : 'Ejemplo';
    final parts = [
      topic.title.get(languageCode),
      topic.summary.get(languageCode),
      topic.body.get(languageCode),
      for (var index = 0; index < topic.examples.length; index++)
        '$exampleLabel ${index + 1}. ${topic.examples[index].get(languageCode)}',
    ];

    return parts
        .map((text) => text.trim())
        .where((text) => text.isNotEmpty)
        .map(_withSentencePause)
        .join(' ');
  }

  String _withSentencePause(String text) {
    if (RegExp(r'[.!?]$').hasMatch(text)) {
      return text;
    }

    return '$text.';
  }
}

class _ReadableSurface extends StatelessWidget {
  const _ReadableSurface({
    required this.child,
    this.borderColor,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppColors.softLilac.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleText.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  const _HelpTopicCard({
    required this.topic,
    required this.languageCode,
    required this.isExpanded,
    required this.onTap,
    required this.speechText,
    required this.voiceId,
  });

  final HelpTopic topic;
  final String languageCode;
  final bool isExpanded;
  final VoidCallback onTap;
  final String speechText;
  final String? voiceId;

  @override
  Widget build(BuildContext context) {
    final color = _colorForExample(topic.exampleType);
    final iconColor = HSLColor.fromColor(color).withLightness(0.35).toColor();
    final isNarrow =
        MediaQuery.sizeOf(context).width < AppBreakpoints.narrowWidth;

    return _ReadableSurface(
      borderColor: color.withValues(alpha: isExpanded ? 0.55 : 0.34),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => playTapAndRun(context, onTap),
          splashColor: color.withValues(alpha: 0.22),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForExample(topic.exampleType),
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.category.get(languageCode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: iconColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            topic.title.get(languageCode),
                            maxLines: isNarrow ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.cardTitle.copyWith(
                              color: AppColors.purpleText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            topic.summary.get(languageCode),
                            maxLines: isExpanded
                                ? (isNarrow ? 3 : 2)
                                : (isNarrow ? 2 : 1),
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.purpleText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: AppMotion.normal,
                      curve: AppMotion.standard,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.purpleText,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _HelpTopicBody(
                    topic: topic,
                    languageCode: languageCode,
                    color: color,
                    iconColor: iconColor,
                    speechText: speechText,
                    voiceId: voiceId,
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: AppMotion.normal,
                  reverseDuration: AppMotion.quick,
                  firstCurve: AppMotion.standard,
                  secondCurve: AppMotion.standard,
                  sizeCurve: Curves.easeInOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpTopicBody extends StatelessWidget {
  const _HelpTopicBody({
    required this.topic,
    required this.languageCode,
    required this.color,
    required this.iconColor,
    required this.speechText,
    required this.voiceId,
  });

  final HelpTopic topic;
  final String languageCode;
  final Color color;
  final Color iconColor;
  final String speechText;
  final String? voiceId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HelpExample(
            exampleType: topic.exampleType,
            color: color,
            iconColor: iconColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            topic.body.get(languageCode),
            style: AppTypography.bodyStrong.copyWith(
              color: AppColors.purpleText,
            ),
          ),
          if (topic.examples.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _HelpExamplesList(
              examples: topic.examples,
              languageCode: languageCode,
              color: color,
              iconColor: iconColor,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 50,
            child: SpeechToggleButton(
              clipKey: 'help:${topic.id}:$languageCode:${voiceId ?? 'default'}',
              text: speechText,
              languageCode: languageCode,
              voiceId: voiceId,
              sessionId: 'help-${topic.id}',
              clipId: 'help:${topic.id}',
              filled: true,
              label: languageCode == 'ca-ES' ? 'Escoltar' : 'Escuchar',
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpExamplesList extends StatelessWidget {
  const _HelpExamplesList({
    required this.examples,
    required this.languageCode,
    required this.color,
    required this.iconColor,
  });

  final List<LocalizedText> examples;
  final String languageCode;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final title = languageCode == 'ca-ES' ? 'Exemples' : 'Ejemplos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.label.copyWith(color: iconColor),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < examples.length; index++) ...[
          _HelpExampleTextCard(
            index: index,
            text: examples[index].get(languageCode),
            color: color,
            iconColor: iconColor,
          ),
          if (index < examples.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _HelpExampleTextCard extends StatelessWidget {
  const _HelpExampleTextCard({
    required this.index,
    required this.text,
    required this.color,
    required this.iconColor,
  });

  final int index;
  final String text;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: AppTypography.label.copyWith(color: iconColor),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body.copyWith(
                  color: AppColors.purpleText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpExample extends StatelessWidget {
  const _HelpExample({
    required this.exampleType,
    required this.color,
    required this.iconColor,
  });

  final String exampleType;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.58), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: switch (exampleType) {
          'numbers' => _NumberExample(iconColor: iconColor),
          'counting' => _CountingExample(iconColor: iconColor),
          'fingers' => _FingersExample(iconColor: iconColor),
          'compare' => _CompareExample(iconColor: iconColor),
          'units' => _UnitsExample(iconColor: iconColor),
          'tens' => _TensExample(iconColor: iconColor),
          'hundreds' => _HundredsExample(iconColor: iconColor),
          'place_value' => _PlaceValueExample(iconColor: iconColor),
          'addition' => _OperationExample(
              iconColor: iconColor,
              expression: '3 + 2 = 5',
            ),
          'addition_vertical' => _VerticalOperationExample(
              iconColor: iconColor,
              top: '12',
              symbol: '+',
              bottom: '7',
              result: '19',
            ),
          'subtraction' => _OperationExample(
              iconColor: iconColor,
              expression: '5 - 2 = 3',
            ),
          'subtraction_vertical' => _VerticalOperationExample(
              iconColor: iconColor,
              top: '15',
              symbol: '-',
              bottom: '4',
              result: '11',
            ),
          'multiplication' => _GroupsExample(iconColor: iconColor),
          'division' => _DivisionExample(iconColor: iconColor),
          _ => _CountingExample(iconColor: iconColor),
        },
      ),
    );
  }
}

class _NumberExample extends StatelessWidget {
  const _NumberExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        for (var value = 1; value <= 5; value++)
          Text(
            '$value',
            style: AppTypography.mathHorizontal.copyWith(
              color: iconColor,
            ),
          ),
      ],
    );
  }
}

class _CountingExample extends StatelessWidget {
  const _CountingExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (var index = 1; index <= 4; index++)
          _LabeledDot(
            label: '$index',
            icon: Icons.star_rounded,
            color: iconColor,
          ),
      ],
    );
  }
}

class _FingersExample extends StatelessWidget {
  const _FingersExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        for (var index = 1; index <= 5; index++)
          Container(
            width: 34,
            height: 82,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: iconColor.withValues(alpha: 0.45)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                '$index',
                style: AppTypography.caption.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompareExample extends StatelessWidget {
  const _CompareExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _DotGroup(count: 3, iconColor: iconColor),
        Text(
          '<',
          style: AppTypography.mathHorizontal.copyWith(color: iconColor),
        ),
        _DotGroup(count: 5, iconColor: iconColor),
      ],
    );
  }
}

class _UnitsExample extends StatelessWidget {
  const _UnitsExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return _DotGroup(count: 6, iconColor: iconColor);
  }
}

class _TensExample extends StatelessWidget {
  const _TensExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _TenBlock(iconColor: iconColor),
        _DotGroup(count: 4, iconColor: iconColor),
      ],
    );
  }
}

class _HundredsExample extends StatelessWidget {
  const _HundredsExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var index = 0; index < 10; index++)
          _TenBlock(iconColor: iconColor, unitSize: 7),
      ],
    );
  }
}

class _PlaceValueExample extends StatelessWidget {
  const _PlaceValueExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '17 = 10 + 7',
        style: AppTypography.mathHorizontal.copyWith(color: iconColor),
      ),
    );
  }
}

class _OperationExample extends StatelessWidget {
  const _OperationExample({
    required this.iconColor,
    required this.expression,
  });

  final Color iconColor;
  final String expression;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        expression,
        style: AppTypography.mathHorizontal.copyWith(color: iconColor),
      ),
    );
  }
}

class _VerticalOperationExample extends StatelessWidget {
  const _VerticalOperationExample({
    required this.iconColor,
    required this.top,
    required this.symbol,
    required this.bottom,
    required this.result,
  });

  final Color iconColor;
  final String top;
  final String symbol;
  final String bottom;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Text(
      '  $top\n$symbol $bottom\n---\n $result',
      textAlign: TextAlign.right,
      style: AppTypography.mathVertical.copyWith(
        color: iconColor,
      ),
    );
  }
}

class _GroupsExample extends StatelessWidget {
  const _GroupsExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (var group = 0; group < 3; group++)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: iconColor.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _DotGroup(count: 2, iconColor: iconColor),
          ),
      ],
    );
  }
}

class _DivisionExample extends StatelessWidget {
  const _DivisionExample({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (var box = 0; box < 3; box++)
          Container(
            width: 74,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              border: Border.all(color: iconColor.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _DotGroup(count: 2, iconColor: iconColor),
          ),
      ],
    );
  }
}

class _DotGroup extends StatelessWidget {
  const _DotGroup({
    required this.count,
    required this.iconColor,
  });

  final int count;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (var index = 0; index < count; index++)
          Icon(Icons.star_rounded, color: iconColor, size: 22),
      ],
    );
  }
}

class _LabeledDot extends StatelessWidget {
  const _LabeledDot({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 34),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TenBlock extends StatelessWidget {
  const _TenBlock({
    required this.iconColor,
    this.unitSize = 12,
  });

  final Color iconColor;
  final double unitSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 5; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 0; col < 2; col++)
                Container(
                  width: unitSize,
                  height: unitSize,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

Color _colorForExample(String exampleType) {
  return switch (exampleType) {
    'addition' || 'addition_vertical' => AppColors.softMint,
    'subtraction' || 'subtraction_vertical' => AppColors.gentleError,
    'multiplication' => AppColors.skyBlue,
    'division' => AppColors.starGold,
    'units' || 'tens' || 'hundreds' || 'place_value' => AppColors.softLilac,
    _ => AppColors.magicPink,
  };
}

IconData _iconForExample(String exampleType) {
  return switch (exampleType) {
    'addition' || 'addition_vertical' => Icons.add_rounded,
    'subtraction' || 'subtraction_vertical' => Icons.remove_rounded,
    'multiplication' => Icons.close_rounded,
    'division' => Icons.call_split,
    'units' || 'tens' || 'hundreds' || 'place_value' => Icons.apps,
    'compare' => Icons.compare_arrows,
    'fingers' => Icons.touch_app,
    _ => Icons.format_list_numbered,
  };
}
