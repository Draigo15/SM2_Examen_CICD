import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/reading_content_provider.dart';
import '../providers/reading_chapters_provider.dart';
import '../providers/lives_provider.dart';
import '../models/reading_chapter.dart';
import '../widgets/highlighted_text.dart';
import '../l10n/app_localizations.dart';

class ReadingContentScreen extends StatefulWidget {
  final ReadingChapter chapter;

  const ReadingContentScreen({super.key, required this.chapter});

  @override
  State<ReadingContentScreen> createState() => _ReadingContentScreenState();
}

class _ReadingContentScreenState extends State<ReadingContentScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    final provider = Provider.of<ReadingContentProvider>(
      context,
      listen: false,
    );
    await provider.fetchContent(widget.chapter.id);
  }

  void _scrollToTop() {
    // Use a small delay to ensure the scroll controller is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contentProvider = Provider.of<ReadingContentProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (contentProvider.isQuizMode) {
          return await _showExitQuizDialog(context);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.chapter.title), elevation: 0),
        body: Consumer<ReadingContentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? l10n.unknownError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadContent,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (provider.content == null) {
              return const Center(child: Text('No content available'));
            }

            // Show loading indicator while quiz is being loaded
            if (provider.isLoadingQuiz) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.loading, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            // Show quiz mode or reading mode
            if (provider.isQuizMode) {
              return _buildQuizView(provider);
            } else {
              return _buildReadingView(provider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildReadingView(ReadingContentProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Page indicator - Redesigned
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${l10n.page} ${provider.currentPage + 1}/${provider.totalPages}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(provider.content!.level),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.content!.level.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (provider.currentPage + 1) / provider.totalPages,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        // Reading content - Redesigned
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content card with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surfaceContainerHighest.withOpacity(
                          0.3,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.content!.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Divider
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.5),
                              theme.colorScheme.primary.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Highlighted text content with improved styling
                      HighlightedText(
                        text: provider.currentPageContent,
                        highlightedWords: provider.currentPageHighlightedWords,
                        textStyle: TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          letterSpacing: 0.3,
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Previous button
              if (provider.currentPage > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      provider.previousPage();
                      _scrollToTop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.previous),
                  ),
                ),
              if (provider.currentPage > 0) const SizedBox(width: 16),
              // Next/Start Quiz button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onNextOrStartQuiz(provider),
                  icon: Icon(
                    provider.isLastPage ? Icons.quiz : Icons.arrow_forward,
                  ),
                  label: Text(provider.isLastPage ? l10n.startQuiz : l10n.next),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizView(ReadingContentProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final question = provider.currentQuestion;
    final livesProvider = Provider.of<LivesProvider>(context, listen: false);

    // Show quiz result view if quiz is completed
    if (provider.isQuizCompleted && mounted) {
      return _buildQuizResultView(provider);
    }

    if (question == null) {
      return const Center(child: Text('No questions available'));
    }

    return Column(
      children: [
        // Beautiful Quiz progress header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Question counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${l10n.question} ${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  // Lives display
                  Consumer<LivesProvider>(
                    builder: (context, livesProvider, child) {
                      return Row(
                        children: List.generate(livesProvider.currentLives, (
                          index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 24,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value:
                      (provider.currentQuestionIndex + 1) /
                      provider.totalQuestions,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surfaceContainerHighest.withOpacity(
                          0.5,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question icon and text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.quiz,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              question.questionText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Options - Beautiful cards with enhanced feedback
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected =
                      provider.userAnswers[provider.currentQuestionIndex] ==
                          index ||
                      provider.selectedAnswerIndex == index;
                  final isCorrect =
                      question != null && index == question.correctAnswer;
                  final showCorrectAnswer = provider.showCorrectAnswer;

                  // Determine card color based on state
                  Color borderColor;
                  Color? backgroundColor;
                  LinearGradient? gradient;
                  List<BoxShadow> boxShadows;

                  if (showCorrectAnswer && isCorrect) {
                    // Highlight correct answer
                    borderColor = Colors.green;
                    gradient = LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.green.withOpacity(0.1),
                      ],
                    );
                    boxShadows = [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ];
                  } else if (isSelected &&
                      provider.hasAttemptedOnce &&
                      !isCorrect) {
                    // Wrong answer
                    borderColor = Colors.red;
                    gradient = LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.2),
                        Colors.red.withOpacity(0.1),
                      ],
                    );
                    boxShadows = [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ];
                  } else if (isSelected) {
                    // Selected but not yet evaluated
                    borderColor = theme.colorScheme.primary;
                    gradient = LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.primary.withOpacity(0.1),
                      ],
                    );
                    boxShadows = [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ];
                  } else {
                    // Default state
                    borderColor = Colors.grey.shade300;
                    backgroundColor = Colors.white;
                    gradient = null;
                    boxShadows = [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ];
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Semantics(
                      label:
                          'Opción ${String.fromCharCode(65 + index)}: ${option}',
                      hint: isCorrect ? 'Respuesta correcta' : '',
                      button: true,
                      enabled: true,
                      selected: isSelected,
                      child: InkWell(
                        onTap: () =>
                            _onAnswerSelected(index, provider, livesProvider),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            color: backgroundColor,
                            border: Border.all(
                              color: borderColor,
                              width: isSelected ? 3 : 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadows,
                          ),
                          child: Row(
                            children: [
                              // Option letter with icon for correct/incorrect
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (showCorrectAnswer && isCorrect) ||
                                                    (isSelected && isCorrect)
                                                ? Colors.green
                                                : (provider.hasAttemptedOnce &&
                                                      !isCorrect)
                                                ? Colors.red
                                                : theme.colorScheme.primary
                                          : Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(
                                          65 + index,
                                        ), // A, B, C, D
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (showCorrectAnswer && isCorrect)
                                    Positioned(
                                      right: -5,
                                      bottom: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? (showCorrectAnswer && isCorrect) ||
                                                  (isSelected && isCorrect)
                                              ? Colors.green
                                              : (provider.hasAttemptedOnce &&
                                                    !isCorrect)
                                              ? Colors.red
                                              : theme.colorScheme.primary
                                        : Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Hint - Only shown after first wrong attempt
                if (provider.showHint && question.hasExplanation)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade100,
                                  Colors.amber.shade50,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.amber.shade700,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber.shade900,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hint',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        question.hint,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.amber.shade900,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Navigation buttons
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      if (provider.currentQuestionIndex > 0)
                        Semantics(
                          label: l10n.previous,
                          hint: 'Volver a la pregunta anterior',
                          button: true,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.previousQuestion();
                              HapticFeedback.lightImpact();
                              SemanticsService.announce(
                                'Pregunta anterior',
                                TextDirection.ltr,
                              );
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: Text(l10n.previous),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 100), // Placeholder for alignment
                      // Skip button (only if not last question)
                      if (!provider.isLastQuestion)
                        Semantics(
                          label: l10n.next,
                          hint: 'Saltar a la siguiente pregunta',
                          button: true,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.nextQuestion();
                              HapticFeedback.lightImpact();
                              SemanticsService.announce(
                                'Siguiente pregunta',
                                TextDirection.ltr,
                              );
                            },
                            icon: const Icon(Icons.skip_next),
                            label: Text(l10n.next),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'BASIC':
        return Colors.green.shade100;
      case 'INTERMEDIATE':
        return Colors.orange.shade100;
      case 'ADVANCED':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Future<void> _onNextOrStartQuiz(ReadingContentProvider provider) async {
    if (provider.isLastPage) {
      final l10n = AppLocalizations.of(context)!;
      await provider.startQuiz();

      // Check if there was an error loading quiz
      if (provider.errorMessage != null) {
        if (mounted) {
          final snackBar = SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () => _onNextOrStartQuiz(provider),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          SemanticsService.announce(provider.errorMessage!, TextDirection.ltr);
        }
      }
    } else {
      provider.nextPage();
      _scrollToTop();
    }
  }

  /// Handle answer selection with enhanced feedback and life loss logic
  Future<void> _onAnswerSelected(
    int answerIndex,
    ReadingContentProvider provider,
    LivesProvider livesProvider,
  ) async {
    // Show visual feedback immediately before server response
    provider.setSelectedAnswer(answerIndex);

    // Haptic feedback for selection
    HapticFeedback.mediumImpact();

    final result = await provider.submitAnswer(answerIndex);

    if (result == 'correct') {
      // Correct answer - show success animation
      _showFeedbackAnimation(true);

      // Play success sound
      await AudioPlayer().play(AssetSource('sounds/correct_answer.mp3'));

      // Announce for screen readers
      SemanticsService.announce('¡Respuesta correcta!', TextDirection.ltr);

      await Future.delayed(const Duration(milliseconds: 1000));

      if (provider.isLastQuestion) {
        // Last question - submit quiz
        await _submitQuiz(provider);
      } else {
        // Move to next question with transition
        provider.nextQuestion();
      }
    } else if (result == 'wrong_first_attempt') {
      // First wrong attempt - vibrate and show hint with animation
      _showFeedbackAnimation(false);

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }

      // Play error sound
      await AudioPlayer().play(AssetSource('sounds/wrong_answer.mp3'));

      // Announce for screen readers
      SemanticsService.announce(
        'Respuesta incorrecta. Intenta de nuevo.',
        TextDirection.ltr,
      );

      // Hint is automatically shown by provider with animation
    } else if (result == 'wrong_second_attempt') {
      // Second wrong attempt - stronger feedback
      _showFeedbackAnimation(false);

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 200, 100, 200]);
      }

      // Play error sound
      await AudioPlayer().play(AssetSource('sounds/wrong_answer.mp3'));

      // Announce for screen readers
      SemanticsService.announce(
        'Respuesta incorrecta. Se mostrará la respuesta correcta.',
        TextDirection.ltr,
      );

      // Show life lost animation
      await _showLifeLostAnimation();

      // Consume a life
      final lifeConsumed = await livesProvider.consumeLife();

      // Check if out of lives
      if (livesProvider.currentLives <= 0) {
        // Save progress and return to reading screen
        await _handleNoLivesRemaining(provider);
        return;
      }

      // Show correct answer before moving on
      if (mounted) {
        provider.displayCorrectAnswer();
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // Move to next question
      if (provider.isLastQuestion) {
        await _submitQuiz(provider);
      } else {
        provider.nextQuestion();
      }
    }
  }

  /// Show life lost animation
  Future<void> _showLifeLostAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(179),
      builder: (context) => const LifeLostAnimationDialog(),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.of(context).pop();
  }

  /// Shows a feedback animation for correct or incorrect answers
  void _showFeedbackAnimation(bool isCorrect) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withAlpha(204)
                    : Colors.red.withAlpha(204),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);

    Future.delayed(const Duration(milliseconds: 800), () {
      overlay.remove();
    });
  }

  /// Handle no lives remaining - save progress and go back
  Future<void> _handleNoLivesRemaining(ReadingContentProvider provider) async {
    final l10n = AppLocalizations.of(context)!;

    // Save progress
    await provider.submitQuiz();

    if (!mounted) return;

    // Show dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.heart_broken, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('No Lives Remaining', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve run out of lives! Your progress has been saved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Come back tomorrow to continue!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to chapters
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Reading'),
          ),
        ],
      ),
    );
  }

  /// Build quiz result view with improved UI and feedback
  Widget _buildQuizResultView(ReadingContentProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final score = provider.score;
    final total = provider.totalQuestions;
    final percentage = (score / total) * 100;

    // Determine result message and color based on score
    String resultMessage;
    Color resultColor;
    IconData resultIcon;

    if (percentage >= 80) {
      resultMessage = "¡Excelente!";
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
    } else if (percentage >= 60) {
      resultMessage = "¡Buen trabajo!";
      resultColor = Colors.blue;
      resultIcon = Icons.thumb_up;
    } else {
      resultMessage = "¡Sigue practicando!";
      resultColor = Colors.orange;
      resultIcon = Icons.refresh;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(resultIcon, size: 80, color: resultColor),
            const SizedBox(height: 20),
            Text(
              resultMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: resultColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${l10n.score}: $score/$total',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: resultColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    provider.resetQuiz();
                  },
                  icon: const Icon(Icons.book),
                  label: Text("Volver a la lectura"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (percentage < 80)
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.resetQuizAndRetry();
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(l10n.tryAgain),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resultColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuiz(ReadingContentProvider provider) async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await provider.submitQuiz();

    // Log integration test result
    debugPrint(
      'INTEGRATION TEST: submitQuiz - ${result['success'] ? 'SUCCESS' : 'FAILURE'}',
    );
    if (!result['success'] && result['error'] != null) {
      debugPrint('INTEGRATION TEST ERROR: ${result['error']}');
    }

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (!result['success']) {
      if (mounted) {
        final errorMessage = result['error'] ?? l10n.unknownError;
        final snackBar = SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        SemanticsService.announce(errorMessage, TextDirection.ltr);
      }
      return;
    }

    final score = result['score'] as int;
    final passed = result['passed'] as bool;

    if (passed) {
      // Capture provider before async gap
      final chaptersProvider = Provider.of<ReadingChaptersProvider>(
        context,
        listen: false,
      );

      // Mark chapter as completed
      await chaptersProvider.completeChapter(widget.chapter.id, score);

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(score);
      }
    } else {
      // Capture provider before async gap
      final livesProvider = Provider.of<LivesProvider>(context, listen: false);

      // Consume a life and show retry dialog
      await livesProvider.consumeLife();

      if (mounted) {
        _showRetryDialog(score);
      }
    }
  }

  void _showSuccessDialog(int score) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 8),
            Text(l10n.congratulations),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chapterCompleted),
            const SizedBox(height: 16),
            Text(
              '${l10n.score}: $score/10',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to chapters screen
            },
            child: Text(l10n.backToChapters),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(int score) {
    final l10n = AppLocalizations.of(context)!;
    final livesProvider = Provider.of<LivesProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 32),
            const SizedBox(width: 8),
            Text(l10n.tryAgain),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.scoreNotEnough),
            const SizedBox(height: 16),
            Text(
              '${l10n.score}: $score/10',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.livesRemaining}: ${livesProvider.currentLives}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to chapters screen
            },
            child: Text(l10n.backToChapters),
          ),
          if (livesProvider.currentLives > 0)
            ElevatedButton(
              onPressed: () {
                final contentProvider = Provider.of<ReadingContentProvider>(
                  context,
                  listen: false,
                );
                contentProvider.resetQuiz();
                Navigator.pop(context); // Close dialog
              },
              child: Text(l10n.retry),
            ),
        ],
      ),
    );
  }

  Future<bool> _showExitQuizDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitQuiz),
        content: Text(l10n.exitQuizConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.exit),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

extension _ExpandedWidget on Widget {
  Widget get expand => Expanded(child: this);
}

/// Life Lost Animation Dialog Widget
class LifeLostAnimationDialog extends StatefulWidget {
  const LifeLostAnimationDialog({super.key});

  @override
  State<LifeLostAnimationDialog> createState() =>
      _LifeLostAnimationDialogState();
}

class _LifeLostAnimationDialogState extends State<LifeLostAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 0.2,
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.red.withOpacity(1 - value),
                            size: 80,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '-1 Life',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
