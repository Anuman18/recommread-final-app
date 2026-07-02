import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class DailyMission {
  final String id;
  final String title;
  final String difficulty; // Beginner / Intermediate / Advanced
  final int timeMin;
  final int xpReward;
  final int coinsReward;
  final double progress; // 0.0 – 1.0
  final bool isPrimary;
  final String icon;

  const DailyMission({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.timeMin,
    required this.xpReward,
    required this.coinsReward,
    required this.progress,
    this.isPrimary = false,
    this.icon = '📚',
  });

  factory DailyMission.fromJson(Map<String, dynamic> j) => DailyMission(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        difficulty: j['difficulty'] ?? 'Intermediate',
        timeMin: j['time_min'] ?? 20,
        xpReward: j['xp_reward'] ?? 150,
        coinsReward: j['coins_reward'] ?? 10,
        progress: (j['progress'] ?? 0.0).toDouble(),
        isPrimary: j['is_primary'] ?? false,
        icon: j['icon'] ?? '📚',
      );
}

class LearningResource {
  final String id;
  final String title;
  final String source;
  final String type; // docs / video / course / practice / project / blog / paper / book
  final String difficulty;
  final int timeMin;
  final int xp;
  final String url;
  final bool isBookmarked;
  final String? thumbnailColor; // hex fallback if no image
  final String icon;

  const LearningResource({
    required this.id,
    required this.title,
    required this.source,
    required this.type,
    required this.difficulty,
    required this.timeMin,
    required this.xp,
    required this.url,
    this.isBookmarked = false,
    this.thumbnailColor,
    this.icon = '📖',
  });

  factory LearningResource.fromJson(Map<String, dynamic> j) => LearningResource(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        source: j['source'] ?? '',
        type: j['type'] ?? 'course',
        difficulty: j['difficulty'] ?? 'Intermediate',
        timeMin: j['time_min'] ?? 30,
        xp: j['xp'] ?? 100,
        url: j['url'] ?? '',
        isBookmarked: j['is_bookmarked'] ?? false,
        thumbnailColor: j['thumbnail_color'],
        icon: j['icon'] ?? '📖',
      );
}

class SkillData {
  final String name;
  final int level;
  final int xp;
  final double progress; // 0.0 – 1.0 within current level
  final double weeklyGrowth; // percentage growth this week
  final String icon;

  const SkillData({
    required this.name,
    required this.level,
    required this.xp,
    required this.progress,
    required this.weeklyGrowth,
    this.icon = '⚡',
  });

  factory SkillData.fromJson(Map<String, dynamic> j) => SkillData(
        name: j['name'] ?? '',
        level: j['level'] ?? 1,
        xp: j['xp'] ?? 0,
        progress: (j['progress'] ?? 0.0).toDouble(),
        weeklyGrowth: (j['weekly_growth'] ?? 0.0).toDouble(),
        icon: j['icon'] ?? '⚡',
      );
}

class WeeklyStats {
  final double learningHours;
  final int completedMissions;
  final int codingQuestions;
  final int projects;
  final int xpEarned;

  const WeeklyStats({
    this.learningHours = 0,
    this.completedMissions = 0,
    this.codingQuestions = 0,
    this.projects = 0,
    this.xpEarned = 0,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> j) => WeeklyStats(
        learningHours: (j['learning_hours'] ?? 0).toDouble(),
        completedMissions: j['completed_missions'] ?? 0,
        codingQuestions: j['coding_questions'] ?? 0,
        projects: j['projects'] ?? 0,
        xpEarned: j['xp_earned'] ?? 0,
      );
}

class Milestone {
  final String id;
  final String title;
  final String emoji;
  final int current;
  final int target;
  final String status; // locked / in_progress / completed

  const Milestone({
    required this.id,
    required this.title,
    required this.emoji,
    required this.current,
    required this.target,
    required this.status,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0.0, 1.0);

  factory Milestone.fromJson(Map<String, dynamic> j) => Milestone(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        emoji: j['emoji'] ?? '🎯',
        current: j['current'] ?? 0,
        target: j['target'] ?? 10,
        status: j['status'] ?? 'in_progress',
      );
}

class AiRecommendation {
  final String message;
  final String type; // warn / encourage / suggest / celebrate
  final String icon;
  final String? ctaLabel;

  const AiRecommendation({
    required this.message,
    required this.type,
    this.icon = '🤖',
    this.ctaLabel,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> j) => AiRecommendation(
        message: j['message'] ?? '',
        type: j['type'] ?? 'suggest',
        icon: j['icon'] ?? '🤖',
        ctaLabel: j['cta_label'],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CAREER-SPECIFIC FALLBACK DATA
// ─────────────────────────────────────────────────────────────────────────────

Map<String, List<DailyMission>> _missionsByCareer = {
  'aiEngineer': [
    const DailyMission(id: 'm1', title: 'Complete NumPy Fundamentals', difficulty: 'Beginner', timeMin: 25, xpReward: 200, coinsReward: 15, progress: 0.45, isPrimary: true, icon: '🧮'),
    const DailyMission(id: 'm2', title: 'Implement a Linear Regression Model', difficulty: 'Intermediate', timeMin: 40, xpReward: 350, coinsReward: 25, progress: 0.0, icon: '📈'),
    const DailyMission(id: 'm3', title: 'Read: "Attention Is All You Need" Paper', difficulty: 'Advanced', timeMin: 35, xpReward: 500, coinsReward: 40, progress: 0.2, icon: '📄'),
  ],
  'dataScientist': [
    const DailyMission(id: 'm1', title: 'Complete Pandas Data Wrangling', difficulty: 'Beginner', timeMin: 30, xpReward: 200, coinsReward: 15, progress: 0.6, isPrimary: true, icon: '🐼'),
    const DailyMission(id: 'm2', title: 'Solve 3 SQL Problems on LeetCode', difficulty: 'Intermediate', timeMin: 45, xpReward: 300, coinsReward: 20, progress: 0.0, icon: '🗃️'),
    const DailyMission(id: 'm3', title: 'Build a Seaborn Visualization Dashboard', difficulty: 'Intermediate', timeMin: 50, xpReward: 400, coinsReward: 30, progress: 0.1, icon: '📊'),
  ],
  'softwareEngineer': [
    const DailyMission(id: 'm1', title: 'Solve 5 LeetCode Medium Problems', difficulty: 'Intermediate', timeMin: 60, xpReward: 400, coinsReward: 30, progress: 0.4, isPrimary: true, icon: '💻'),
    const DailyMission(id: 'm2', title: 'Study System Design: URL Shortener', difficulty: 'Advanced', timeMin: 45, xpReward: 350, coinsReward: 25, progress: 0.0, icon: '🏗️'),
    const DailyMission(id: 'm3', title: 'Read: Clean Code Chapter 4', difficulty: 'Beginner', timeMin: 20, xpReward: 150, coinsReward: 10, progress: 0.3, icon: '📖'),
  ],
  'fullStackDeveloper': [
    const DailyMission(id: 'm1', title: 'Build a REST API with Node.js & Express', difficulty: 'Intermediate', timeMin: 60, xpReward: 400, coinsReward: 30, progress: 0.5, isPrimary: true, icon: '⚙️'),
    const DailyMission(id: 'm2', title: 'Complete React Hooks Tutorial', difficulty: 'Beginner', timeMin: 35, xpReward: 200, coinsReward: 15, progress: 0.0, icon: '⚛️'),
    const DailyMission(id: 'm3', title: 'Deploy App to Vercel', difficulty: 'Intermediate', timeMin: 25, xpReward: 250, coinsReward: 18, progress: 0.0, icon: '🚀'),
  ],
  'backendEngineer': [
    const DailyMission(id: 'm1', title: 'Design a Microservices Architecture', difficulty: 'Advanced', timeMin: 60, xpReward: 500, coinsReward: 40, progress: 0.3, isPrimary: true, icon: '🔧'),
    const DailyMission(id: 'm2', title: 'Implement Redis Caching Layer', difficulty: 'Intermediate', timeMin: 45, xpReward: 350, coinsReward: 25, progress: 0.0, icon: '🔴'),
    const DailyMission(id: 'm3', title: 'Solve 3 Database Optimization Problems', difficulty: 'Intermediate', timeMin: 40, xpReward: 300, coinsReward: 20, progress: 0.0, icon: '🗄️'),
  ],
  'frontendEngineer': [
    const DailyMission(id: 'm1', title: 'Build Responsive CSS Grid Layout', difficulty: 'Beginner', timeMin: 30, xpReward: 200, coinsReward: 15, progress: 0.7, isPrimary: true, icon: '🎨'),
    const DailyMission(id: 'm2', title: 'Implement Infinite Scroll with React', difficulty: 'Intermediate', timeMin: 45, xpReward: 350, coinsReward: 25, progress: 0.0, icon: '♾️'),
    const DailyMission(id: 'm3', title: 'Audit Page Performance with Lighthouse', difficulty: 'Intermediate', timeMin: 25, xpReward: 250, coinsReward: 18, progress: 0.0, icon: '⚡'),
  ],
  'uxDesigner': [
    const DailyMission(id: 'm1', title: 'Complete Figma Auto Layout Tutorial', difficulty: 'Beginner', timeMin: 30, xpReward: 200, coinsReward: 15, progress: 0.4, isPrimary: true, icon: '✏️'),
    const DailyMission(id: 'm2', title: 'Conduct 2 User Research Interviews', difficulty: 'Intermediate', timeMin: 60, xpReward: 400, coinsReward: 30, progress: 0.0, icon: '🎙️'),
    const DailyMission(id: 'm3', title: 'Design a Mobile Onboarding Flow', difficulty: 'Intermediate', timeMin: 50, xpReward: 350, coinsReward: 25, progress: 0.0, icon: '📱'),
  ],
  'productManager': [
    const DailyMission(id: 'm1', title: 'Write a PRD for a Feature', difficulty: 'Intermediate', timeMin: 45, xpReward: 350, coinsReward: 25, progress: 0.5, isPrimary: true, icon: '📋'),
    const DailyMission(id: 'm2', title: 'Analyze Product Metrics Dashboard', difficulty: 'Beginner', timeMin: 30, xpReward: 200, coinsReward: 15, progress: 0.0, icon: '📊'),
    const DailyMission(id: 'm3', title: 'Study: Shape Up Methodology', difficulty: 'Advanced', timeMin: 40, xpReward: 300, coinsReward: 20, progress: 0.0, icon: '📐'),
  ],
  'cyberSecurityEngineer': [
    const DailyMission(id: 'm1', title: 'Complete TryHackMe Room: Linux Basics', difficulty: 'Beginner', timeMin: 45, xpReward: 300, coinsReward: 20, progress: 0.55, isPrimary: true, icon: '🔐'),
    const DailyMission(id: 'm2', title: 'Practice SQL Injection on DVWA', difficulty: 'Intermediate', timeMin: 60, xpReward: 450, coinsReward: 35, progress: 0.0, icon: '💉'),
    const DailyMission(id: 'm3', title: 'Study: OWASP Top 10 Vulnerabilities', difficulty: 'Intermediate', timeMin: 35, xpReward: 300, coinsReward: 20, progress: 0.0, icon: '🛡️'),
  ],
  'devOpsEngineer': [
    const DailyMission(id: 'm1', title: 'Set Up Docker Compose for an App', difficulty: 'Intermediate', timeMin: 50, xpReward: 400, coinsReward: 30, progress: 0.4, isPrimary: true, icon: '🐳'),
    const DailyMission(id: 'm2', title: 'Write a GitHub Actions CI/CD Pipeline', difficulty: 'Intermediate', timeMin: 60, xpReward: 450, coinsReward: 35, progress: 0.0, icon: '⚙️'),
    const DailyMission(id: 'm3', title: 'Deploy App to Kubernetes Cluster', difficulty: 'Advanced', timeMin: 60, xpReward: 550, coinsReward: 45, progress: 0.0, icon: '☸️'),
  ],
  'cloudEngineer': [
    const DailyMission(id: 'm1', title: 'Complete AWS S3 + CloudFront Setup', difficulty: 'Intermediate', timeMin: 45, xpReward: 350, coinsReward: 25, progress: 0.5, isPrimary: true, icon: '☁️'),
    const DailyMission(id: 'm2', title: 'Write Terraform Infrastructure Module', difficulty: 'Advanced', timeMin: 60, xpReward: 500, coinsReward: 40, progress: 0.0, icon: '🏗️'),
    const DailyMission(id: 'm3', title: 'Optimize Cloud Costs — Cost Explorer', difficulty: 'Intermediate', timeMin: 30, xpReward: 250, coinsReward: 18, progress: 0.0, icon: '💰'),
  ],
  'startupFounder': [
    const DailyMission(id: 'm1', title: 'Create Your MVP Feature List', difficulty: 'Beginner', timeMin: 30, xpReward: 200, coinsReward: 15, progress: 0.6, isPrimary: true, icon: '🚀'),
    const DailyMission(id: 'm2', title: 'Do 5 Customer Discovery Interviews', difficulty: 'Intermediate', timeMin: 90, xpReward: 500, coinsReward: 40, progress: 0.0, icon: '🎙️'),
    const DailyMission(id: 'm3', title: 'Build a Landing Page in 2 Hours', difficulty: 'Intermediate', timeMin: 120, xpReward: 450, coinsReward: 35, progress: 0.0, icon: '🌐'),
  ],
  'iasOfficer': [
    const DailyMission(id: 'm1', title: 'Read The Hindu — Editorial Analysis', difficulty: 'Beginner', timeMin: 30, xpReward: 150, coinsReward: 10, progress: 0.5, isPrimary: true, icon: '📰'),
    const DailyMission(id: 'm2', title: 'Practice 20 CSAT Math Questions', difficulty: 'Intermediate', timeMin: 45, xpReward: 300, coinsReward: 20, progress: 0.0, icon: '🧮'),
    const DailyMission(id: 'm3', title: 'Write an Essay on Economic Policy', difficulty: 'Advanced', timeMin: 60, xpReward: 400, coinsReward: 30, progress: 0.0, icon: '✍️'),
  ],
  'doctor': [
    const DailyMission(id: 'm1', title: 'Revise Anatomy: Upper Limb', difficulty: 'Intermediate', timeMin: 45, xpReward: 300, coinsReward: 20, progress: 0.4, isPrimary: true, icon: '🦴'),
    const DailyMission(id: 'm2', title: 'Solve 20 NEET MCQs — Biochemistry', difficulty: 'Intermediate', timeMin: 30, xpReward: 250, coinsReward: 18, progress: 0.0, icon: '🧪'),
    const DailyMission(id: 'm3', title: 'Watch Clinical Case: Cardiac Failure', difficulty: 'Advanced', timeMin: 40, xpReward: 350, coinsReward: 25, progress: 0.0, icon: '❤️'),
  ],
};

List<LearningResource> _resourcesByCareer(String career) {
  final map = <String, List<LearningResource>>{
    'aiEngineer': [
      const LearningResource(id: 'r1', title: 'NumPy Official Documentation', source: 'numpy.org', type: 'docs', difficulty: 'Beginner', timeMin: 20, xp: 100, url: 'https://numpy.org/doc/', icon: '📄', thumbnailColor: '#6C8EFF'),
      const LearningResource(id: 'r2', title: 'Machine Learning Crash Course', source: 'Google', type: 'course', difficulty: 'Beginner', timeMin: 60, xp: 300, url: 'https://developers.google.com/machine-learning/crash-course', icon: '🎓', thumbnailColor: '#FF7043'),
      const LearningResource(id: 'r3', title: '3Blue1Brown — Neural Networks Series', source: 'YouTube', type: 'video', difficulty: 'Intermediate', timeMin: 45, xp: 250, url: 'https://youtube.com', icon: '▶️', thumbnailColor: '#FF0000'),
      const LearningResource(id: 'r4', title: 'Kaggle: Titanic ML from Disaster', source: 'Kaggle', type: 'practice', difficulty: 'Beginner', timeMin: 90, xp: 400, url: 'https://kaggle.com', icon: '🏆', thumbnailColor: '#20BEFF'),
      const LearningResource(id: 'r5', title: 'Build an Image Classifier with PyTorch', source: 'PyTorch', type: 'project', difficulty: 'Intermediate', timeMin: 120, xp: 600, url: 'https://pytorch.org', icon: '🔥', thumbnailColor: '#EE4C2C'),
      const LearningResource(id: 'r6', title: 'Towards Data Science — LLM Guide', source: 'Medium', type: 'blog', difficulty: 'Advanced', timeMin: 15, xp: 80, url: 'https://medium.com', icon: '📝', thumbnailColor: '#12100E'),
    ],
    'dataScientist': [
      const LearningResource(id: 'r1', title: 'Pandas Official Documentation', source: 'pandas.pydata.org', type: 'docs', difficulty: 'Beginner', timeMin: 20, xp: 100, url: 'https://pandas.pydata.org', icon: '📄', thumbnailColor: '#130754'),
      const LearningResource(id: 'r2', title: 'Statistics for Data Science (Coursera)', source: 'Coursera', type: 'course', difficulty: 'Intermediate', timeMin: 60, xp: 350, url: 'https://coursera.org', icon: '🎓', thumbnailColor: '#0056D2'),
      const LearningResource(id: 'r3', title: 'StatQuest: Statistics Videos', source: 'YouTube', type: 'video', difficulty: 'Beginner', timeMin: 30, xp: 200, url: 'https://youtube.com', icon: '▶️', thumbnailColor: '#FF0000'),
      const LearningResource(id: 'r4', title: 'LeetCode — SQL Practice', source: 'LeetCode', type: 'practice', difficulty: 'Intermediate', timeMin: 60, xp: 350, url: 'https://leetcode.com', icon: '🧩', thumbnailColor: '#FFA116'),
      const LearningResource(id: 'r5', title: 'Exploratory Data Analysis Project', source: 'Kaggle', type: 'project', difficulty: 'Intermediate', timeMin: 120, xp: 500, url: 'https://kaggle.com', icon: '🔬', thumbnailColor: '#20BEFF'),
      const LearningResource(id: 'r6', title: 'Towards AI — Data Science Trends', source: 'Medium', type: 'blog', difficulty: 'Beginner', timeMin: 10, xp: 60, url: 'https://medium.com', icon: '📝', thumbnailColor: '#12100E'),
    ],
    'fullStackDeveloper': [
      const LearningResource(id: 'r1', title: 'MDN Web Docs — JavaScript', source: 'MDN', type: 'docs', difficulty: 'Beginner', timeMin: 20, xp: 100, url: 'https://developer.mozilla.org', icon: '📄', thumbnailColor: '#00D9FF'),
      const LearningResource(id: 'r2', title: 'Full Stack Open 2024 (Helsinki)', source: 'University of Helsinki', type: 'course', difficulty: 'Intermediate', timeMin: 90, xp: 500, url: 'https://fullstackopen.com', icon: '🎓', thumbnailColor: '#003580'),
      const LearningResource(id: 'r3', title: 'Fireship — Next.js in 100 Seconds', source: 'YouTube', type: 'video', difficulty: 'Beginner', timeMin: 15, xp: 80, url: 'https://youtube.com', icon: '▶️', thumbnailColor: '#FF0000'),
      const LearningResource(id: 'r4', title: 'Build a SaaS Product with Next.js', source: 'GitHub', type: 'project', difficulty: 'Advanced', timeMin: 240, xp: 900, url: 'https://github.com', icon: '🚀', thumbnailColor: '#181717'),
      const LearningResource(id: 'r5', title: 'Frontend Practice Challenges', source: 'Frontend Mentor', type: 'practice', difficulty: 'Intermediate', timeMin: 60, xp: 300, url: 'https://frontendmentor.io', icon: '🎯', thumbnailColor: '#302267'),
      const LearningResource(id: 'r6', title: 'Dev.to — React Performance Tips', source: 'Dev.to', type: 'blog', difficulty: 'Intermediate', timeMin: 12, xp: 70, url: 'https://dev.to', icon: '📝', thumbnailColor: '#08090A'),
    ],
  };

  // Default fallback for careers not explicitly mapped
  return map[career] ?? map['aiEngineer']!;
}

List<SkillData> _skillsByCareer(String career) {
  final map = <String, List<SkillData>>{
    'aiEngineer': [
      const SkillData(name: 'Python', level: 3, xp: 2400, progress: 0.8, weeklyGrowth: 12, icon: '🐍'),
      const SkillData(name: 'Machine Learning', level: 2, xp: 1100, progress: 0.55, weeklyGrowth: 8, icon: '🤖'),
      const SkillData(name: 'Deep Learning', level: 1, xp: 450, progress: 0.45, weeklyGrowth: 15, icon: '🧠'),
      const SkillData(name: 'Statistics', level: 2, xp: 900, progress: 0.3, weeklyGrowth: 5, icon: '📊'),
      const SkillData(name: 'SQL', level: 2, xp: 800, progress: 0.4, weeklyGrowth: 3, icon: '🗄️'),
      const SkillData(name: 'Projects', level: 1, xp: 200, progress: 0.2, weeklyGrowth: 20, icon: '🛠️'),
    ],
    'dataScientist': [
      const SkillData(name: 'Python', level: 3, xp: 2200, progress: 0.73, weeklyGrowth: 10, icon: '🐍'),
      const SkillData(name: 'Statistics', level: 3, xp: 2100, progress: 0.7, weeklyGrowth: 7, icon: '📊'),
      const SkillData(name: 'SQL', level: 2, xp: 1300, progress: 0.65, weeklyGrowth: 9, icon: '🗄️'),
      const SkillData(name: 'Pandas', level: 2, xp: 950, progress: 0.47, weeklyGrowth: 12, icon: '🐼'),
      const SkillData(name: 'Visualization', level: 2, xp: 700, progress: 0.35, weeklyGrowth: 6, icon: '📉'),
      const SkillData(name: 'Projects', level: 1, xp: 300, progress: 0.3, weeklyGrowth: 18, icon: '🔬'),
    ],
    'softwareEngineer': [
      const SkillData(name: 'DSA', level: 3, xp: 2600, progress: 0.86, weeklyGrowth: 10, icon: '🌳'),
      const SkillData(name: 'System Design', level: 2, xp: 1100, progress: 0.55, weeklyGrowth: 7, icon: '🏗️'),
      const SkillData(name: 'Java / Python', level: 3, xp: 2000, progress: 0.66, weeklyGrowth: 5, icon: '☕'),
      const SkillData(name: 'Databases', level: 2, xp: 850, progress: 0.42, weeklyGrowth: 4, icon: '🗄️'),
      const SkillData(name: 'Communication', level: 2, xp: 600, progress: 0.3, weeklyGrowth: 2, icon: '💬'),
      const SkillData(name: 'Interview Skills', level: 2, xp: 700, progress: 0.35, weeklyGrowth: 8, icon: '🎤'),
    ],
    'fullStackDeveloper': [
      const SkillData(name: 'JavaScript', level: 3, xp: 2300, progress: 0.76, weeklyGrowth: 11, icon: '⚡'),
      const SkillData(name: 'React', level: 2, xp: 1400, progress: 0.7, weeklyGrowth: 14, icon: '⚛️'),
      const SkillData(name: 'Node.js', level: 2, xp: 1100, progress: 0.55, weeklyGrowth: 8, icon: '🟢'),
      const SkillData(name: 'Databases', level: 2, xp: 800, progress: 0.4, weeklyGrowth: 5, icon: '🗄️'),
      const SkillData(name: 'CSS / Design', level: 3, xp: 2000, progress: 0.66, weeklyGrowth: 6, icon: '🎨'),
      const SkillData(name: 'Deployment', level: 1, xp: 350, progress: 0.35, weeklyGrowth: 20, icon: '🚀'),
    ],
  };
  return map[career] ?? map['aiEngineer']!;
}

List<Milestone> _milestonesByCareer(String career) {
  return [
    const Milestone(id: 'ms1', title: 'Reach Level 5', emoji: '⭐', current: 3, target: 5, status: 'in_progress'),
    const Milestone(id: 'ms2', title: 'Complete Roadmap Phase 1', emoji: '🗺️', current: 4, target: 7, status: 'in_progress'),
    const Milestone(id: 'ms3', title: 'Finish First Project', emoji: '🛠️', current: 0, target: 1, status: 'locked'),
  ];
}

List<AiRecommendation> _aiRecsByCareer(String career) {
  final map = <String, List<AiRecommendation>>{
    'aiEngineer': [
      const AiRecommendation(message: 'You are weak in Statistics. Strengthen your math foundations before tackling Deep Learning.', type: 'warn', icon: '⚠️', ctaLabel: 'Start Statistics Module'),
      const AiRecommendation(message: 'Complete today\'s NumPy mission — you are 45% through. Finishing it unlocks the Pandas track.', type: 'encourage', icon: '🔥', ctaLabel: 'Continue Mission'),
      const AiRecommendation(message: 'This Kaggle project will massively improve your portfolio for AI Engineer roles.', type: 'suggest', icon: '💡', ctaLabel: 'View Project'),
    ],
    'dataScientist': [
      const AiRecommendation(message: 'Your SQL skill is progressing slower than expected. Spend 20 minutes daily on LeetCode SQL.', type: 'warn', icon: '⚠️', ctaLabel: 'Practice SQL'),
      const AiRecommendation(message: 'Excellent consistency this week! You are in the top 15% of Data Scientist learners.', type: 'celebrate', icon: '🎉', ctaLabel: null),
      const AiRecommendation(message: 'Watch this Hindi tutorial on Pandas — it explains data cleaning in a very practical way.', type: 'suggest', icon: '💡', ctaLabel: 'Watch Tutorial'),
    ],
    'fullStackDeveloper': [
      const AiRecommendation(message: 'You have not touched backend code this week. Balance your learning across frontend and Node.js.', type: 'warn', icon: '⚠️', ctaLabel: 'Start Backend Track'),
      const AiRecommendation(message: 'Deploy your portfolio project today — it will give you 900 XP and interview leverage.', type: 'encourage', icon: '🚀', ctaLabel: 'View Deployment Guide'),
      const AiRecommendation(message: 'This Next.js project template will fast-track your practical experience by 3 weeks.', type: 'suggest', icon: '💡', ctaLabel: 'Open Project'),
    ],
  };
  return map[career] ??
      [
        const AiRecommendation(message: 'Stay consistent — even 30 minutes a day compounds into mastery over months.', type: 'encourage', icon: '🔥'),
        const AiRecommendation(message: 'Complete today\'s primary mission to unlock the next level on your roadmap.', type: 'suggest', icon: '💡'),
        const AiRecommendation(message: 'Your weekly learning hours are below target. Try to add one extra study session this weekend.', type: 'warn', icon: '⚠️'),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class HomeState {
  final List<DailyMission> missions;
  final LearningResource? continueResource;
  final List<LearningResource> learningResources;
  final List<SkillData> skills;
  final WeeklyStats weeklyStats;
  final List<Milestone> milestones;
  final List<AiRecommendation> aiRecommendations;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.missions = const [],
    this.continueResource,
    this.learningResources = const [],
    this.skills = const [],
    this.weeklyStats = const WeeklyStats(),
    this.milestones = const [],
    this.aiRecommendations = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  HomeState copyWith({
    List<DailyMission>? missions,
    LearningResource? continueResource,
    bool clearContinueResource = false,
    List<LearningResource>? learningResources,
    List<SkillData>? skills,
    WeeklyStats? weeklyStats,
    List<Milestone>? milestones,
    List<AiRecommendation>? aiRecommendations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      missions: missions ?? this.missions,
      continueResource: clearContinueResource ? null : (continueResource ?? this.continueResource),
      learningResources: learningResources ?? this.learningResources,
      skills: skills ?? this.skills,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      milestones: milestones ?? this.milestones,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData({String career = 'aiEngineer'}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Try to load from backend
      final careerSlug = career.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      List<DailyMission> missions;
      List<LearningResource> resources;
      List<SkillData> skills;
      WeeklyStats weeklyStats;
      List<Milestone> milestones;
      List<AiRecommendation> aiRecs;

      try {
        final missionsJson = await apiClient.get('/home/missions?career=$careerSlug');
        missions = (missionsJson as List)
            .map((m) => DailyMission.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      } catch (_) {
        missions = _missionsByCareer[career] ?? _missionsByCareer['aiEngineer']!;
      }

      try {
        final resourcesJson = await apiClient.get('/home/resources?career=$careerSlug');
        resources = (resourcesJson as List)
            .map((r) => LearningResource.fromJson(Map<String, dynamic>.from(r)))
            .toList();
      } catch (_) {
        resources = _resourcesByCareer(career);
      }

      try {
        final skillsJson = await apiClient.get('/home/skills?career=$careerSlug');
        skills = (skillsJson as List)
            .map((s) => SkillData.fromJson(Map<String, dynamic>.from(s)))
            .toList();
      } catch (_) {
        skills = _skillsByCareer(career);
      }

      try {
        final statsJson = await apiClient.get('/home/weekly-stats');
        weeklyStats = WeeklyStats.fromJson(Map<String, dynamic>.from(statsJson));
      } catch (_) {
        weeklyStats = const WeeklyStats(
          learningHours: 4.5,
          completedMissions: 7,
          codingQuestions: 12,
          projects: 1,
          xpEarned: 2450,
        );
      }

      try {
        final msJson = await apiClient.get('/home/milestones?career=$careerSlug');
        milestones = (msJson as List)
            .map((m) => Milestone.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      } catch (_) {
        milestones = _milestonesByCareer(career);
      }

      try {
        final aiJson = await apiClient.get('/home/ai-recommendations?career=$careerSlug');
        aiRecs = (aiJson as List)
            .map((r) => AiRecommendation.fromJson(Map<String, dynamic>.from(r)))
            .toList();
      } catch (_) {
        aiRecs = _aiRecsByCareer(career);
      }

      // The "continue learning" resource is first in-progress resource
      final continueResource = resources.firstWhere(
        (r) => true, // all resources are valid; first one is shown
        orElse: () => resources.first,
      );

      state = HomeState(
        missions: missions,
        continueResource: resources.isNotEmpty ? continueResource : null,
        learningResources: resources,
        skills: skills,
        weeklyStats: weeklyStats,
        milestones: milestones,
        aiRecommendations: aiRecs,
        isLoading: false,
      );
    } on ApiException catch (e) {
      // Load all fallback data even on API error
      _loadFallback(career, e.message);
    } catch (_) {
      _loadFallback(career, null);
    }
  }

  void _loadFallback(String career, String? errorMessage) {
    final resources = _resourcesByCareer(career);
    state = HomeState(
      missions: _missionsByCareer[career] ?? _missionsByCareer['aiEngineer']!,
      continueResource: resources.isNotEmpty ? resources.first : null,
      learningResources: resources,
      skills: _skillsByCareer(career),
      weeklyStats: const WeeklyStats(
        learningHours: 4.5,
        completedMissions: 7,
        codingQuestions: 12,
        projects: 1,
        xpEarned: 2450,
      ),
      milestones: _milestonesByCareer(career),
      aiRecommendations: _aiRecsByCareer(career),
      isLoading: false,
      errorMessage: errorMessage,
    );
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
