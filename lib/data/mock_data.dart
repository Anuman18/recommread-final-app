import 'package:flutter/material.dart';
import '../models/book_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BOOKS
// ─────────────────────────────────────────────────────────────────────────────

final List<Book> kAllBooks = [
  const Book(
    id: 'b1',
    title: 'Atomic Habits',
    author: 'James Clear',
    genre: 'Self Growth',
    rating: 4.9,
    description:
        'An easy & proven way to build good habits & break bad ones. Transform your life with tiny changes.',
    coverColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    coverEmoji: '⚛️',
    totalPages: 320,
    readPages: 187,
    tags: ['Habits', 'Productivity', 'Self-help'],
  ),
  const Book(
    id: 'b2',
    title: 'Deep Work',
    author: 'Cal Newport',
    genre: 'Productivity',
    rating: 4.7,
    description:
        'Rules for focused success in a distracted world. Master the art of concentrated effort.',
    coverColors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    coverEmoji: '🎯',
    totalPages: 296,
    readPages: 0,
    tags: ['Focus', 'Work', 'Productivity'],
  ),
  const Book(
    id: 'b3',
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    genre: 'Finance',
    rating: 4.8,
    description:
        'Timeless lessons on wealth, greed, and happiness. A fresh perspective on how people think about money.',
    coverColors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    coverEmoji: '💰',
    totalPages: 256,
    readPages: 0,
    tags: ['Finance', 'Psychology', 'Wealth'],
  ),
  const Book(
    id: 'b4',
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    genre: 'Psychology',
    rating: 4.6,
    description:
        'A ground-breaking tour of the mind and explains the two systems that drive the way we think.',
    coverColors: [Color(0xFFBF360C), Color(0xFFE64A19)],
    coverEmoji: '🧠',
    totalPages: 499,
    readPages: 0,
    tags: ['Psychology', 'Behavioral Economics', 'Decision Making'],
  ),
  const Book(
    id: 'b5',
    title: 'Zero to One',
    author: 'Peter Thiel',
    genre: 'Business',
    rating: 4.5,
    description:
        'Notes on startups, or how to build the future. Essential reading for entrepreneurs.',
    coverColors: [Color(0xFF006064), Color(0xFF00838F)],
    coverEmoji: '🚀',
    totalPages: 224,
    readPages: 0,
    tags: ['Startups', 'Business', 'Innovation'],
  ),
  const Book(
    id: 'b6',
    title: 'Sapiens',
    author: 'Yuval Noah Harari',
    genre: 'History',
    rating: 4.7,
    description:
        'A brief history of humankind from Stone Age to the modern era. Breathtaking in scope.',
    coverColors: [Color(0xFF37474F), Color(0xFF455A64)],
    coverEmoji: '🌍',
    totalPages: 443,
    readPages: 0,
    tags: ['History', 'Anthropology', 'Evolution'],
  ),
  const Book(
    id: 'b7',
    title: 'The Lean Startup',
    author: 'Eric Ries',
    genre: 'Business',
    rating: 4.4,
    description:
        'How today\'s entrepreneurs use continuous innovation to create radically successful businesses.',
    coverColors: [Color(0xFFE65100), Color(0xFFBF360C)],
    coverEmoji: '📊',
    totalPages: 336,
    readPages: 0,
    tags: ['Startups', 'Innovation', 'Business'],
  ),
  const Book(
    id: 'b8',
    title: 'Man\'s Search for Meaning',
    author: 'Viktor Frankl',
    genre: 'Philosophy',
    rating: 4.9,
    description:
        'A powerful meditation on finding purpose in even the most brutal circumstances.',
    coverColors: [Color(0xFF880E4F), Color(0xFFAD1457)],
    coverEmoji: '✨',
    totalPages: 165,
    readPages: 0,
    tags: ['Philosophy', 'Psychology', 'Memoir'],
  ),
  const Book(
    id: 'b9',
    title: 'The Pragmatic Programmer',
    author: 'David Thomas',
    genre: 'Technology',
    rating: 4.8,
    description:
        'Your journey to mastery. Timeless wisdom for software developers at every level.',
    coverColors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
    coverEmoji: '💻',
    totalPages: 352,
    readPages: 0,
    tags: ['Programming', 'Career', 'Technology'],
  ),
  const Book(
    id: 'b10',
    title: 'Good to Great',
    author: 'Jim Collins',
    genre: 'Business',
    rating: 4.5,
    description:
        'Why some companies make the leap and others don\'t. A landmark study of enduring excellence.',
    coverColors: [Color(0xFF1A237E), Color(0xFF283593)],
    coverEmoji: '📈',
    totalPages: 300,
    readPages: 0,
    tags: ['Leadership', 'Management', 'Business'],
  ),
  const Book(
    id: 'b11',
    title: 'Dune',
    author: 'Frank Herbert',
    genre: 'Sci-Fi',
    rating: 4.8,
    description:
        'The greatest science fiction novel of all time. An epic of politics, religion and ecology.',
    coverColors: [Color(0xFF827717), Color(0xFFF9A825)],
    coverEmoji: '🏜️',
    totalPages: 688,
    readPages: 0,
    tags: ['Sci-Fi', 'Fantasy', 'Epic'],
  ),
  const Book(
    id: 'b12',
    title: 'The Intelligent Investor',
    author: 'Benjamin Graham',
    genre: 'Finance',
    rating: 4.7,
    description:
        'The definitive book on value investing. A book of practical counsel.',
    coverColors: [Color(0xFF33691E), Color(0xFF558B2F)],
    coverEmoji: '📉',
    totalPages: 640,
    readPages: 0,
    tags: ['Investing', 'Finance', 'Value'],
  ),
  const Book(
    id: 'b13',
    title: 'Meditations',
    author: 'Marcus Aurelius',
    genre: 'Philosophy',
    rating: 4.9,
    description:
        'Personal writings of the Roman Emperor. Timeless Stoic wisdom for modern life.',
    coverColors: [Color(0xFF3E2723), Color(0xFF4E342E)],
    coverEmoji: '🏛️',
    totalPages: 254,
    readPages: 0,
    tags: ['Stoicism', 'Philosophy', 'Classics'],
  ),
  const Book(
    id: 'b14',
    title: 'Never Split the Difference',
    author: 'Chris Voss',
    genre: 'Business',
    rating: 4.8,
    description:
        'Negotiating as if your life depended on it. FBI negotiator reveals the secrets to high-stakes talks.',
    coverColors: [Color(0xFF01579B), Color(0xFF0277BD)],
    coverEmoji: '🤝',
    totalPages: 288,
    readPages: 0,
    tags: ['Negotiation', 'Communication', 'Business'],
  ),
  const Book(
    id: 'b15',
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    genre: 'Fiction',
    rating: 4.6,
    description:
        'A magical fable about following your dream. One of the best-selling books in history.',
    coverColors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
    coverEmoji: '⚗️',
    totalPages: 208,
    readPages: 0,
    tags: ['Fiction', 'Inspirational', 'Journey'],
  ),
  const Book(
    id: 'b16',
    title: 'Outliers',
    author: 'Malcolm Gladwell',
    genre: 'Self Growth',
    rating: 4.5,
    description:
        'The story of success. Why some people succeed and others don\'t.',
    coverColors: [Color(0xFF4527A0), Color(0xFF512DA8)],
    coverEmoji: '⭐',
    totalPages: 336,
    readPages: 0,
    tags: ['Success', 'Psychology', 'Sociology'],
  ),
  const Book(
    id: 'b17',
    title: 'AI Superpowers',
    author: 'Kai-Fu Lee',
    genre: 'Technology',
    rating: 4.6,
    description:
        'China, Silicon Valley, and the New World Order. The definitive book on the AI race.',
    coverColors: [Color(0xFF006064), Color(0xFF004D40)],
    coverEmoji: '🤖',
    totalPages: 272,
    readPages: 0,
    tags: ['AI', 'Technology', 'Future'],
  ),
  const Book(
    id: 'b18',
    title: 'Rich Dad Poor Dad',
    author: 'Robert Kiyosaki',
    genre: 'Finance',
    rating: 4.4,
    description:
        'What the rich teach their kids about money that the poor and middle class do not.',
    coverColors: [Color(0xFFB71C1C), Color(0xFFC62828)],
    coverEmoji: '💵',
    totalPages: 336,
    readPages: 0,
    tags: ['Finance', 'Wealth', 'Mindset'],
  ),
  const Book(
    id: 'b19',
    title: 'The 48 Laws of Power',
    author: 'Robert Greene',
    genre: 'Psychology',
    rating: 4.3,
    description:
        'A morally ambiguous manual on how to gain and keep power in any situation.',
    coverColors: [Color(0xFF212121), Color(0xFF424242)],
    coverEmoji: '👑',
    totalPages: 480,
    readPages: 0,
    tags: ['Power', 'Psychology', 'Strategy'],
  ),
  const Book(
    id: 'b20',
    title: 'Designing Data-Intensive Apps',
    author: 'Martin Kleppmann',
    genre: 'Technology',
    rating: 4.9,
    description:
        'The big ideas behind reliable, scalable, and maintainable systems.',
    coverColors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
    coverEmoji: '🗄️',
    totalPages: 616,
    readPages: 0,
    tags: ['Engineering', 'Architecture', 'Databases'],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// CURRENT READING
// ─────────────────────────────────────────────────────────────────────────────

Book get kCurrentBook => kAllBooks.first; // Atomic Habits

// ─────────────────────────────────────────────────────────────────────────────
// AI PICKS  (today's personalized picks)
// ─────────────────────────────────────────────────────────────────────────────

List<Book> get kAiPicks => [
      kAllBooks[1], // Deep Work
      kAllBooks[2], // Psychology of Money
      kAllBooks[7], // Man's Search for Meaning
      kAllBooks[12], // Meditations
      kAllBooks[5], // Sapiens
    ];

// ─────────────────────────────────────────────────────────────────────────────
// TRENDING
// ─────────────────────────────────────────────────────────────────────────────

List<Book> get kTrending => [
      kAllBooks[2], // Psychology of Money
      kAllBooks[0], // Atomic Habits
      kAllBooks[13], // Never Split the Difference
      kAllBooks[5], // Sapiens
      kAllBooks[16], // AI Superpowers
      kAllBooks[3], // Thinking Fast and Slow
    ];

// ─────────────────────────────────────────────────────────────────────────────
// RECENTLY VIEWED
// ─────────────────────────────────────────────────────────────────────────────

List<Book> get kRecentlyViewed => [
      kAllBooks[4], // Zero to One
      kAllBooks[15], // Outliers
      kAllBooks[14], // The Alchemist
      kAllBooks[9], // Good to Great
    ];

// ─────────────────────────────────────────────────────────────────────────────
// READING PATHS
// ─────────────────────────────────────────────────────────────────────────────

final List<ReadingPath> kReadingPaths = [
  const ReadingPath(
    id: 'rp1',
    title: 'AI Engineer',
    subtitle: '5 books · 12 weeks',
    emoji: '🤖',
    gradientColors: [Color(0xFF006064), Color(0xFF004D40)],
    totalBooks: 5,
    estimatedWeeks: 12,
    steps: [
      PathStep(
        title: 'Python Fundamentals',
        bookTitle: 'Python Crash Course',
        isCompleted: true,
      ),
      PathStep(
        title: 'Algorithms & Data Structures',
        bookTitle: 'Introduction to Algorithms',
        isCompleted: true,
      ),
      PathStep(
        title: 'Machine Learning',
        bookTitle: 'Hands-On Machine Learning',
        isCompleted: false,
        isCurrent: true,
      ),
      PathStep(
        title: 'Deep Learning',
        bookTitle: 'Deep Learning by Goodfellow',
        isCompleted: false,
      ),
      PathStep(
        title: 'Large Language Models',
        bookTitle: 'Building LLM Applications',
        isCompleted: false,
      ),
    ],
  ),
  const ReadingPath(
    id: 'rp2',
    title: 'Startup Founder',
    subtitle: '5 books · 10 weeks',
    emoji: '🚀',
    gradientColors: [Color(0xFFE65100), Color(0xFFBF360C)],
    totalBooks: 5,
    estimatedWeeks: 10,
    steps: [
      PathStep(
        title: 'Validate the Idea',
        bookTitle: 'The Mom Test',
        isCompleted: false,
        isCurrent: true,
      ),
      PathStep(
        title: 'Build Fast',
        bookTitle: 'The Lean Startup',
        isCompleted: false,
      ),
      PathStep(
        title: 'Find Product-Market Fit',
        bookTitle: 'Zero to One',
        isCompleted: false,
      ),
      PathStep(
        title: 'Scale the Business',
        bookTitle: 'Blitzscaling',
        isCompleted: false,
      ),
      PathStep(
        title: 'Raise Funding',
        bookTitle: 'Venture Deals',
        isCompleted: false,
      ),
    ],
  ),
  const ReadingPath(
    id: 'rp3',
    title: 'Mindful Leader',
    subtitle: '4 books · 8 weeks',
    emoji: '🧘',
    gradientColors: [Color(0xFF4527A0), Color(0xFF6A1B9A)],
    totalBooks: 4,
    estimatedWeeks: 8,
    steps: [
      PathStep(
        title: 'Know Yourself',
        bookTitle: 'Meditations',
        isCompleted: true,
      ),
      PathStep(
        title: 'Build Habits',
        bookTitle: 'Atomic Habits',
        isCompleted: false,
        isCurrent: true,
      ),
      PathStep(
        title: 'Deep Focus',
        bookTitle: 'Deep Work',
        isCompleted: false,
      ),
      PathStep(
        title: 'Lead Others',
        bookTitle: 'Good to Great',
        isCompleted: false,
      ),
    ],
  ),
  const ReadingPath(
    id: 'rp4',
    title: 'Quant Trader',
    subtitle: '5 books · 14 weeks',
    emoji: '📈',
    gradientColors: [Color(0xFF1A237E), Color(0xFF283593)],
    totalBooks: 5,
    estimatedWeeks: 14,
    steps: [
      PathStep(
        title: 'Money Mindset',
        bookTitle: 'The Psychology of Money',
        isCompleted: false,
        isCurrent: true,
      ),
      PathStep(
        title: 'Value Investing',
        bookTitle: 'The Intelligent Investor',
        isCompleted: false,
      ),
      PathStep(
        title: 'Statistical Thinking',
        bookTitle: 'Thinking, Fast and Slow',
        isCompleted: false,
      ),
      PathStep(
        title: 'Algorithmic Trading',
        bookTitle: 'Advances in Financial ML',
        isCompleted: false,
      ),
      PathStep(
        title: 'Risk Management',
        bookTitle: 'The Black Swan',
        isCompleted: false,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORIES
// ─────────────────────────────────────────────────────────────────────────────

final List<Category> kCategories = [
  const Category(
    id: 'c1',
    label: 'Business',
    emoji: '💼',
    color: Color(0xFF1565C0),
  ),
  const Category(
    id: 'c2',
    label: 'Finance',
    emoji: '💰',
    color: Color(0xFF2E7D32),
  ),
  const Category(
    id: 'c3',
    label: 'Psychology',
    emoji: '🧠',
    color: Color(0xFF6A1B9A),
  ),
  const Category(
    id: 'c4',
    label: 'Self Growth',
    emoji: '🌱',
    color: Color(0xFF00695C),
  ),
  const Category(
    id: 'c5',
    label: 'Technology',
    emoji: '💻',
    color: Color(0xFF00838F),
  ),
  const Category(
    id: 'c6',
    label: 'History',
    emoji: '🏛️',
    color: Color(0xFF4E342E),
  ),
  const Category(
    id: 'c7',
    label: 'Fiction',
    emoji: '📖',
    color: Color(0xFFAD1457),
  ),
  const Category(
    id: 'c8',
    label: 'Philosophy',
    emoji: '✨',
    color: Color(0xFF37474F),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH HELPERS
// ─────────────────────────────────────────────────────────────────────────────

const List<String> kRecentSearches = [
  'Atomic Habits',
  'Deep Work',
  'Psychology of Money',
  'Sapiens',
];

const List<String> kTrendingSearches = [
  '🔥 Best seller 2024',
  '🤖 AI & Machine Learning',
  '💰 Personal Finance',
  '🧠 Behavioral Psychology',
  '🚀 Startup Books',
];

List<Book> searchBooks(String query) {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase().trim();
  return kAllBooks.where((b) {
    return b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        b.genre.toLowerCase().contains(q) ||
        b.tags.any((t) => t.toLowerCase().contains(q));
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOK DETAILS HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Book? findBookById(String id) {
  try {
    return kAllBooks.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
}

List<Book> getRelatedBooks(Book book, {int limit = 6}) {
  return kAllBooks
      .where((b) => b.id != book.id && b.genre == book.genre)
      .take(limit)
      .toList();
}

List<Book> getSimilarAuthorBooks(Book book, {int limit = 6}) {
  // Same author first, then same genre
  final sameAuthor = kAllBooks
      .where((b) => b.id != book.id && b.author == book.author)
      .toList();
  if (sameAuthor.length >= limit) return sameAuthor.take(limit).toList();
  final extra = kAllBooks
      .where((b) =>
          b.id != book.id &&
          b.author != book.author &&
          b.genre == book.genre)
      .take(limit - sameAuthor.length)
      .toList();
  return [...sameAuthor, ...extra];
}

String getAiRecommendationReason(Book book) {
  final reasons = {
    'Self Growth':
        'Based on your reading goal of self-improvement and your 14-day streak, RecommRead AI identified this as a high-impact read. Readers with your profile finish this in 8 days on average and report a 4.8× improvement in daily productivity.',
    'Finance':
        'Your interest in financial independence aligns perfectly with this title. RecommRead AI detected patterns from your reading history suggesting a strong match. 92% of users who read this after your last book rated it 5 stars.',
    'Psychology':
        'RecommRead AI analyzed your genre preferences and found this book complements your recent reads with minimal overlap. Cognitive science readers like you rank this in their top 3 most impactful reads.',
    'Business':
        'Based on your "Business" reading goal and time preference, this book delivers the highest insight-per-hour ratio in its category. RecommRead AI recommends it as your next strategic read.',
    'Technology':
        'Your technical reading pattern and AI path enrollment make this a top-5 recommendation. RecommRead AI projects this will elevate your understanding and connect directly to your AI Engineer learning path.',
    'Philosophy':
        'RecommRead AI matched your reflective reading style with this title. Deep readers with your profile find it transformative — often re-reading key chapters multiple times.',
    'Productivity':
        'After analyzing your 30 min/day reading commitment and productivity interest, RecommRead AI selected this as the highest ROI book for your current focus level.',
    'Sci-Fi':
        'RecommRead AI noticed you haven\'t explored Sci-Fi recently. Readers who alternate between non-fiction and Sci-Fi show 23% better retention — this title is the perfect counterbalance.',
    'History':
        'RecommRead AI found a strong correlation between your philosophical interests and historical narratives. This book bridges both in a uniquely compelling way.',
    'Fiction':
        'RecommRead AI selected this to give your analytical mind a creative break. Fiction readers in your cohort report significantly better focus after story-driven reads.',
  };
  return reasons[book.genre] ??
      'RecommRead AI selected this based on your unique reading fingerprint — a combination of your goal, genre preferences, reading pace, and completion history.';
}

/// Estimated reading hours based on avg 40 pages/hour.
String getReadingTime(Book book) {
  final hours = (book.totalPages / 40).ceil();
  if (hours < 2) return '~1 hr';
  return '~$hours hrs';
}
