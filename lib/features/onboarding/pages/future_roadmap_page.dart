import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class FutureRoadmapPage extends ConsumerWidget {
  const FutureRoadmapPage({super.key});

  List<String> _getStepsForGoal(ReadingGoal goal) {
    switch (goal) {
      case ReadingGoal.aiEngineer:
        return ['You', 'Python Core', 'Data Structures', 'Machine Learning', 'Deep Learning', 'LLMs & Agents', 'AI Engineer'];
      case ReadingGoal.dataScientist:
        return ['You', 'Statistics', 'SQL & R', 'Pandas & NumPy', 'ML Algorithms', 'Data Visualization', 'Data Scientist'];
      case ReadingGoal.softwareEngineer:
        return ['You', 'Coding Basics', 'DSA Fundamentals', 'System Design', 'Web Architecture', 'Database Scale', 'Software Engineer'];
      case ReadingGoal.fullStackDeveloper:
        return ['You', 'HTML & CSS', 'JavaScript & React', 'Node.js & APIs', 'Databases', 'Deployment & Cloud', 'Full Stack Developer'];
      case ReadingGoal.backendEngineer:
        return ['You', 'Server Programming', 'REST APIs', 'Databases & ORM', 'System Design', 'Performance & Scale', 'Backend Engineer'];
      case ReadingGoal.frontendEngineer:
        return ['You', 'HTML & CSS', 'JavaScript', 'React or Vue', 'State Management', 'Web Performance', 'Frontend Engineer'];
      case ReadingGoal.uxDesigner:
        return ['You', 'Visual Design', 'Wireframing', 'Figma Mastery', 'User Research', 'Design Systems', 'UX Designer'];
      case ReadingGoal.productManager:
        return ['You', 'UX Principles', 'Agile & Backlog', 'Data Analytics', 'Roadmapping', 'Stakeholder Alignment', 'Product Manager'];
      case ReadingGoal.cyberSecurityEngineer:
        return ['You', 'Networking Basics', 'Linux & CLI', 'Ethical Hacking', 'SIEM & Threat Intel', 'Penetration Testing', 'Cyber Security Engineer'];
      case ReadingGoal.devOpsEngineer:
        return ['You', 'Linux & Bash', 'Docker & Containers', 'CI/CD Pipelines', 'Kubernetes', 'Monitoring & SRE', 'DevOps Engineer'];
      case ReadingGoal.cloudEngineer:
        return ['You', 'Cloud Basics', 'AWS or GCP or Azure', 'Infrastructure as Code', 'Serverless & Containers', 'Cost Optimization', 'Cloud Engineer'];
      case ReadingGoal.startupFounder:
        return ['You', 'Ideation & MVP', 'Customer Dev', 'Product Market Fit', 'Team Building', 'Growth & Scaling', 'Startup Founder'];
      case ReadingGoal.entrepreneur:
        return ['You', 'Business Model', 'Sales & Pitching', 'Finance & Cashflow', 'Marketing Strategy', 'Operations Scale', 'Entrepreneur'];
      case ReadingGoal.digitalMarketer:
        return ['You', 'Marketing Basics', 'SEO & SEM', 'Social Media Growth', 'Analytics & Funnels', 'Performance Marketing', 'Digital Marketer'];
      case ReadingGoal.contentCreator:
        return ['You', 'Niche & Audience', 'Content Strategy', 'Video & Script', 'Growth Hacking', 'Monetization', 'Content Creator'];
      case ReadingGoal.iasOfficer:
        return ['You', 'Current Affairs', 'Polity & History', 'Ethics & Aptitude', 'Essay Strategy', 'Interview Drill', 'IAS Officer'];
      case ReadingGoal.doctor:
        return ['You', 'Biology Basics', 'Organic Chemistry', 'Anatomy Drill', 'Clinical Logic', 'Residency Mastery', 'Doctor'];
      case ReadingGoal.lawyer:
        return ['You', 'Legal Fundamentals', 'Constitutional Law', 'Criminal & Civil Law', 'Legal Writing', 'Moot Court & Advocacy', 'Lawyer'];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final goal = state.goal ?? ReadingGoal.aiEngineer;
    final steps = _getStepsForGoal(goal);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.15),
                  AppColors.darkSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Personalized Roadmap',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildMetricRow('Target Identity', 'Future ${goal.label}'),
                _buildMetricRow('Estimated Time', '12 Months'),
                _buildMetricRow('Commitment', '${state.dailyTime?.label ?? "30 min"} / day'),
                _buildMetricRow('Key Skills Required', 'Productivity, Critical Thinking, ${goal.label}'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Visual Pathway Title
          Text(
            'Transformation Pathway',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 20),

          // Steps list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, i) {
              final isLast = i == steps.length - 1;
              final isFirst = i == 0;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dot & Line indicator
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFirst
                              ? AppColors.textSecondaryDark
                              : isLast
                                  ? AppColors.gold
                                  : AppColors.darkSurface,
                          border: Border.all(
                            color: isLast ? AppColors.gold : AppColors.darkBorder,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isFirst
                                ? Icons.person
                                : isLast
                                    ? Icons.stars
                                    : Icons.circle,
                            size: 12,
                            color: isLast ? AppColors.darkBg : Colors.white,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: AppColors.darkBorder,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Step label
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        steps[i],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isLast || isFirst ? FontWeight.w800 : FontWeight.w500,
                          color: isLast
                              ? AppColors.gold
                              : isFirst
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
