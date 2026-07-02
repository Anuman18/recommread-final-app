import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/career_utils.dart';
import '../../models/book_model.dart';
import '../../features/profile/profile_provider.dart';
import '../../core/widgets/animated_button.dart';
import 'widgets/search_empty_state.dart';
import 'widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _barCtrl;
  late final Animation<double> _barFade;
  late final Animation<Offset> _barSlide;

  List<Book> _results = [];
  String _query = '';
  bool _showResults = false;
  bool _isSearchLoading = false;
  String? _searchError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _barFade = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOut);
    _barSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic));

    _barCtrl.forward();
    _queryCtrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _barCtrl.dispose();
    _queryCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _queryCtrl.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (q.isEmpty) {
      setState(() {
        _query = '';
        _showResults = false;
        _results = [];
        _isSearchLoading = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _query = _queryCtrl.text;
      _showResults = true;
      _isSearchLoading = true;
      _searchError = null;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final careerSlug = readingGoalToSlug(ref.read(profileProvider).readingGoal);
        final encodedQuery = Uri.encodeComponent(q);
        final resultsJson = await apiClient.get(
          '${ApiConstants.aggregationSearch}?career=$careerSlug&query=$encodedQuery',
        );
        final results = (resultsJson['results'] as List? ?? [])
            .asMap()
            .entries
            .map((e) => Book.fromSearchResult(
                  Map<String, dynamic>.from(e.value),
                  index: e.key,
                ))
            .toList();
        if (mounted) {
          setState(() {
            _results = results;
            _isSearchLoading = false;
          });
        }
      } on ApiException catch (e) {
        if (mounted) {
          setState(() {
            _searchError = e.message;
            _isSearchLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _searchError = 'Search failed. Please try again.';
            _isSearchLoading = false;
          });
        }
      }
    });
  }

  void _setQuery(String q) {
    _queryCtrl.text = q;
    _queryCtrl.selection =
        TextSelection.collapsed(offset: q.length);
    _focusNode.requestFocus();
  }

  void _clearQuery() {
    _queryCtrl.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Animated Search Bar ──────────────────────────────────
              FadeTransition(
                opacity: _barFade,
                child: SlideTransition(
                  position: _barSlide,
                  child: _SearchBarRow(
                    controller: _queryCtrl,
                    focusNode: _focusNode,
                    onClear: _clearQuery,
                    hasText: _query.isNotEmpty,
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _showResults
                      ? _isSearchLoading
                          ? const Center(
                              key: ValueKey('loading'),
                              child: CircularProgressIndicator(color: AppColors.gold),
                            )
                          : _searchError != null
                              ? _buildErrorState()
                              : _results.isEmpty
                                  ? _buildNoResultsState()
                                  : _ResultsList(
                                      key: const ValueKey('results'),
                                      results: _results,
                                      query: _query,
                                    )
                      : SearchEmptyState(
                          key: const ValueKey('empty'),
                          onSearchTap: _setQuery,
                          onGenreTap: _setQuery,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 40),
            const SizedBox(height: 16),
            Text(
              _searchError ?? 'An error occurred during search.',
              style: GoogleFonts.inter(color: AppColors.textSecondaryDark, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: AnimatedButton(
                height: 40,
                onPressed: _onQueryChanged,
                child: Text(
                  'Retry Search',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkBg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      key: const ValueKey('no-results'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textSecondaryDark, size: 40),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_query"',
              style: GoogleFonts.inter(color: AppColors.textSecondaryDark, fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check spelling or try searching another term.',
              style: GoogleFonts.inter(color: AppColors.textTertiaryDark, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar row ─────────────────────────────────────────────────────────

class _SearchBarRow extends StatelessWidget {
  const _SearchBarRow({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.hasText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      onTapOutside: (_) => focusNode.unfocus(),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textPrimaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search books, authors, genres...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textTertiaryDark,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      cursorColor: AppColors.gold,
                    ),
                  ),
                  // Clear / voice toggle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: hasText
                        ? IconButton(
                            key: const ValueKey('clear'),
                            icon: const Icon(Icons.close_rounded,
                                size: 18,
                                color: AppColors.textTertiaryDark),
                            onPressed: onClear,
                          )
                        : IconButton(
                            key: const ValueKey('voice'),
                            icon: const Icon(Icons.mic_rounded,
                                size: 18, color: AppColors.gold),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Results list ───────────────────────────────────────────────────────────

class _ResultsList extends StatefulWidget {
  const _ResultsList({super.key, required this.results, required this.query});
  final List<Book> results;
  final String query;

  @override
  State<_ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<_ResultsList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late List<Animation<double>> _itemAnims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buildAnims();
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_ResultsList old) {
    super.didUpdateWidget(old);
    if (old.results != widget.results) {
      _ctrl.reset();
      _buildAnims();
      _ctrl.forward();
    }
  }

  void _buildAnims() {
    _itemAnims = List.generate(
      widget.results.length.clamp(0, 10),
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(
          i * 0.07,
          (i * 0.07 + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      )),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return _NoResults(query: widget.query);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.results.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              '${widget.results.length} result${widget.results.length != 1 ? "s" : ""} for "${widget.query}"',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textTertiaryDark,
              ),
            ),
          );
        }
        final book = widget.results[i - 1];
        final animIdx = (i - 1).clamp(0, _itemAnims.length - 1);
        return AnimatedBuilder(
          animation: _itemAnims[animIdx],
          builder: (_, child) => Opacity(
            opacity: _itemAnims[animIdx].value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _itemAnims[animIdx].value)),
              child: child,
            ),
          ),
          child: SearchResultTile(
            book: book,
            index: i,
            queryHighlight: widget.query,
          ),
        );
      },
    );
  }
}

// ── No results state ───────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          Text(
            'No results for',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"$query"',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try a different title, author or genre.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
