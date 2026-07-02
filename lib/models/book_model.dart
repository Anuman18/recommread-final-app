import 'dart:convert';
import 'package:flutter/material.dart';

// ── Book ───────────────────────────────────────────────────────────────────

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.rating,
    required this.description,
    required this.coverColors,
    required this.coverEmoji,
    required this.totalPages,
    this.readPages = 0,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String author;
  final String genre;
  final double rating;
  final String description;
  final List<Color> coverColors;
  final String coverEmoji;
  final int totalPages;
  final int readPages;
  final List<String> tags;

  double get progress =>
      totalPages > 0 ? (readPages / totalPages).clamp(0.0, 1.0) : 0.0;

  String get progressLabel => '$readPages / $totalPages pages';

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    double? rating,
    String? description,
    List<Color>? coverColors,
    String? coverEmoji,
    int? totalPages,
    int? readPages,
    List<String>? tags,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      coverColors: coverColors ?? this.coverColors,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      totalPages: totalPages ?? this.totalPages,
      readPages: readPages ?? this.readPages,
      tags: tags ?? this.tags,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final List<Color> colors = [];
    final String coverColorsStr = json['cover_colors'] ?? '#1565C0,#0D47A1';
    final parts = coverColorsStr.split(',');
    for (final p in parts) {
      if (p.trim().startsWith('#')) {
        final cleanHex = p.trim().replaceAll('#', '');
        colors.add(Color(int.parse('FF$cleanHex', radix: 16)));
      } else {
        colors.add(const Color(0xFF1565C0));
      }
    }
    if (colors.isEmpty) {
      colors.add(const Color(0xFF1565C0));
      colors.add(const Color(0xFF0D47A1));
    }

    final List<String> tagList = [];
    final String tagsStr = json['tags'] ?? '';
    if (tagsStr.isNotEmpty) {
      tagList.addAll(tagsStr.split(',').map((t) => t.trim()));
    }

    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      description: json['description'] ?? '',
      coverColors: colors,
      coverEmoji: json['cover_emoji'] ?? '📖',
      totalPages: json['total_pages'] ?? 300,
      readPages: json['read_pages'] ?? 0,
      tags: tagList,
    );
  }

  int get xpReward => totalPages * 12;

  List<String> get skillsUnlocked {
    final g = genre.toLowerCase();
    if (g.contains('growth') || g.contains('productivity')) {
      return ['Productivity', 'Psychology'];
    } else if (g.contains('business') || g.contains('entrepreneur')) {
      return ['Business', 'Leadership'];
    } else if (g.contains('finance') || g.contains('invest')) {
      return ['Finance', 'Critical Thinking'];
    } else if (g.contains('tech') || g.contains('program') || g.contains('science')) {
      return ['Programming', 'AI'];
    } else if (g.contains('psychology')) {
      return ['Psychology', 'Critical Thinking'];
    } else if (g.contains('communication') || g.contains('write')) {
      return ['Communication', 'Psychology'];
    } else {
      return ['Productivity', 'Critical Thinking'];
    }
  }

  String get difficulty {
    if (totalPages < 200) return 'Beginner';
    if (totalPages < 350) return 'Intermediate';
    return 'Advanced';
  }

  String get estimatedTimeHours {
    final double hrs = totalPages * 1.5 / 60;
    return '${hrs.toStringAsFixed(1)} hrs';
  }

  String get whyItMatters {
    return 'Mastering the concepts in "$title" directly unlocks your ${skillsUnlocked.join(" & ")} attributes, accelerating your identity progression.';
  }
}

// ── ReadingPath ────────────────────────────────────────────────────────────

class ReadingPath {
  const ReadingPath({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    required this.steps,
    required this.totalBooks,
    required this.estimatedWeeks,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  final List<PathStep> steps;
  final int totalBooks;
  final int estimatedWeeks;

  factory ReadingPath.fromJson(Map<String, dynamic> json) {
    final List<Color> colors = [];
    final String coverColorsStr = json['gradient_colors'] ?? '#E2B96F,#BF8E3D';
    final parts = coverColorsStr.split(',');
    for (final p in parts) {
      if (p.trim().startsWith('#')) {
        final cleanHex = p.trim().replaceAll('#', '');
        colors.add(Color(int.parse('FF$cleanHex', radix: 16)));
      } else {
        colors.add(const Color(0xFFE2B96F));
      }
    }
    if (colors.isEmpty) {
      colors.add(const Color(0xFFE2B96F));
      colors.add(const Color(0xFFBF8E3D));
    }

    final List<PathStep> stepList = [];
    final stepsRaw = json['steps'];
    if (stepsRaw != null) {
      try {
        final List<dynamic> decoded = stepsRaw is String ? jsonDecode(stepsRaw) : stepsRaw;
        for (final item in decoded) {
          stepList.add(PathStep.fromJson(Map<String, dynamic>.from(item)));
        }
      } catch (_) {}
    }

    return ReadingPath(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      emoji: json['emoji'] ?? '🧭',
      gradientColors: colors,
      steps: stepList,
      totalBooks: json['total_books'] ?? 0,
      estimatedWeeks: json['estimated_weeks'] ?? 0,
    );
  }
}

class PathStep {
  const PathStep({
    required this.title,
    required this.bookTitle,
    required this.isCompleted,
    this.isCurrent = false,
  });

  final String title;
  final String bookTitle;
  final bool isCompleted;
  final bool isCurrent;

  factory PathStep.fromJson(Map<String, dynamic> json) {
    return PathStep(
      title: json['title'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
    );
  }
}

// ── Category ───────────────────────────────────────────────────────────────

class Category {
  const Category({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String label;
  final String emoji;
  final Color color;
}
