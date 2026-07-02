/// Canonical API route paths (prefix with [ApiClient.baseUrl]).
class ApiConstants {
  ApiConstants._();

  static const String apiV1 = '/api/v1';

  // Auth
  static const String authSignup = '$apiV1/auth/signup';
  static const String authLogin = '$apiV1/auth/login';
  static const String authMe = '$apiV1/auth/me';

  // Profile
  static const String profile = '$apiV1/profile';
  static const String profileUpdate = '$apiV1/profile/update';
  static const String profileSettings = '$apiV1/profile/settings';
  static const String profileAchievements = '$apiV1/profile/achievements';
  static const String profileDashboard = '$apiV1/profile/dashboard';

  // Resources
  static const String resources = '$apiV1/resources';

  // Projects
  static const String projects = '$apiV1/projects';

  // Coding
  static const String codingTopics = '$apiV1/coding/topics';
  static const String codingQuestions = '$apiV1/coding/questions';
  static const String codingDailyChallenge = '$apiV1/coding/daily-challenge';
  static const String codingDailyComplete = '$apiV1/coding/daily-challenge/complete';

  // Interviews
  static const String interviews = '$apiV1/interviews';
  static const String interviewsHistory = '$apiV1/interviews/history';
  static const String interviewsStart = '$apiV1/interviews/start';
  static const String interviewsSubmitAnswer = '$apiV1/interviews/submit-answer';
  static const String interviewsReport = '$apiV1/interviews/report';

  // Leaderboards
  static const String leaderboardWeekly = '$apiV1/leaderboards/weekly';
  static const String leaderboardMonthly = '$apiV1/leaderboards/monthly';
  static const String leaderboardFriends = '$apiV1/leaderboards/friends';

  // Recommendations
  static const String recommendationsDaily = '$apiV1/recommendations/daily';
  static const String recommendationsWeekly = '$apiV1/recommendations/weekly';
  static const String recommendationsLearningPath = '$apiV1/recommendations/learning-path';
  static const String recommendationsNextMission = '$apiV1/recommendations/next-mission';
  static const String recommendationsWeakSkills = '$apiV1/recommendations/weak-skills';
  static const String recommendationsStrongSkills = '$apiV1/recommendations/strong-skills';
  static const String recommendationsResources = '$apiV1/recommendations/resources';

  // Gamification
  static const String gamificationXp = '$apiV1/gamification/xp';
  static const String gamificationCoins = '$apiV1/gamification/coins';
  static const String gamificationStreak = '$apiV1/gamification/streak';
  static const String gamificationLevel = '$apiV1/gamification/level';
  static const String gamificationAchievements = '$apiV1/gamification/achievements';
  static const String gamificationStatistics = '$apiV1/gamification/statistics';
  static const String gamificationProgress = '$apiV1/gamification/progress';
  static const String gamificationClaimReward = '$apiV1/gamification/claim-reward';

  // Tutor / AI Coach
  static const String tutorChatStart = '$apiV1/tutor/chat/start';
  static const String tutorChatContinue = '$apiV1/tutor/chat/continue';
  static const String tutorDailyAdvice = '$apiV1/tutor/daily-advice';

  // Career
  static const String careerRoadmap = '$apiV1/career/roadmap';
  static const String careerReadiness = '$apiV1/career/readiness-score';

  // Aggregation / Search
  static const String aggregationSearch = '$apiV1/aggregation/search';

  // Beta
  static const String betaFeedback = '$apiV1/beta/feedback';
  static const String betaAppVersion = '$apiV1/beta/app-version';
}
