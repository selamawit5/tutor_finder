import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/utils/initials.dart';
import 'package:tutor_finder/features/tutors/domain/ai_suggestion_service.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';

/// "Ask AI to Match a Tutor" box shown on the Find Tutors screen.
///
/// The suggestion lives in [aiSuggestionProvider]; this widget only owns the
/// text controller, so it is a [ConsumerStatefulWidget] without `setState`.
class AiSuggestionBox extends ConsumerStatefulWidget {
  const AiSuggestionBox({super.key});

  @override
  ConsumerState<AiSuggestionBox> createState() => _AiSuggestionBoxState();
}

class _AiSuggestionBoxState extends ConsumerState<AiSuggestionBox> {
  final _problemController = TextEditingController();

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  void _suggest() {
    if (_problemController.text.trim().isEmpty ||
        ref.read(aiSuggestionProvider).isLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(aiSuggestionProvider.notifier).suggest(_problemController.text);
  }

  void _clear() {
    _problemController.clear();
    ref.read(aiSuggestionProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = ref.watch(aiSuggestionProvider);
    final isLoading = suggestion.isLoading;
    final result = suggestion.hasError ? null : suggestion.value;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ask AI to Match a Tutor',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Describe what you are stuck on and we will suggest a subject '
              'and tutors who teach it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _problemController,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _problemController,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _suggest(),
                      decoration: InputDecoration(
                        hintText:
                            "Describe your problem (e.g., Newton's laws in "
                            'physics)',
                        suffixIcon:
                            value.text.isEmpty &&
                                result == null &&
                                !suggestion.hasError
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                onPressed: _clear,
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: hasText && !isLoading ? _suggest : null,
                      icon: isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        isLoading ? 'Finding tutors...' : 'Get AI Suggestion',
                      ),
                    ),
                  ],
                );
              },
            ),
            if (suggestion.hasError && !isLoading) ...[
              const SizedBox(height: 12),
              _SuggestionError(
                onRetry: () => ref.read(aiSuggestionProvider.notifier).retry(),
              ),
            ] else if (result != null && !isLoading) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _SuggestionResult(result: result),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionResult extends StatelessWidget {
  const _SuggestionResult({required this.result});

  final AiSuggestionResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subjectName = result.subjectName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(Icons.auto_awesome, size: 18, color: colors.primary),
              label: const Text('AI Suggestion'),
            ),
            if (subjectName != null)
              Chip(
                avatar: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(subjectName),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(result.reason, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          'Not a real assistant yet: suggestions are based on keywords.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (result.suggestedTutors.isEmpty)
          Text(
            'No tutors teach this subject yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tutor in result.suggestedTutors)
                ActionChip(
                  avatar: CircleAvatar(child: Text(initialsOf(tutor.name))),
                  label: Text(
                    '${tutor.name} · ★ ${tutor.ratingAverage.toStringAsFixed(1)}',
                  ),
                  tooltip: 'View ${tutor.name}',
                  onPressed: () => context.push('/tutors/${tutor.userId}'),
                ),
            ],
          ),
      ],
    );
  }
}

class _SuggestionError extends StatelessWidget {
  const _SuggestionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Could not get a suggestion. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: colors.onErrorContainer,
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
