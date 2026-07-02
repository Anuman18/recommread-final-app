import '../../features/onboarding/onboarding_provider.dart';

/// Converts camelCase career enum names to snake_case API slugs.
String careerToSlug(String careerName) {
  return careerName.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (m) => '_${m.group(0)!.toLowerCase()}',
  );
}

String readingGoalToSlug(ReadingGoal goal) => careerToSlug(goal.name);

/// Parses backend career_slug or legacy reading_goal into [ReadingGoal].
ReadingGoal parseReadingGoal(String goalStr) {
  final normalized = goalStr.replaceAll('_', '').toLowerCase();
  for (final val in ReadingGoal.values) {
    if (val.name.toLowerCase() == normalized || val.name == goalStr) {
      return val;
    }
  }
  return ReadingGoal.aiEngineer;
}

ReadingLevel parseReadingLevel(String levelStr) {
  switch (levelStr.toLowerCase()) {
    case 'beginner':
      return ReadingLevel.beginner;
    case 'advanced':
      return ReadingLevel.advanced;
    default:
      return ReadingLevel.intermediate;
  }
}

String readingLevelToApi(ReadingLevel level) {
  switch (level) {
    case ReadingLevel.beginner:
      return 'beginner';
    case ReadingLevel.advanced:
      return 'advanced';
    case ReadingLevel.intermediate:
      return 'intermediate';
  }
}
