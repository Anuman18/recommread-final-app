import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LibrarySkeleton extends StatefulWidget {
  const LibrarySkeleton({super.key, required this.tabIndex});
  final int tabIndex;

  @override
  State<LibrarySkeleton> createState() => _LibrarySkeletonState();
}

class _LibrarySkeletonState extends State<LibrarySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        final gradient = LinearGradient(
          begin: Alignment(_shimmerAnim.value - 1.0, 0.0),
          end: Alignment(_shimmerAnim.value + 1.0, 0.0),
          colors: const [
            AppColors.darkCard,
            AppColors.darkElevated,
            AppColors.darkCard,
          ],
        );

        if (widget.tabIndex == 0) {
          return _buildContinueReadingSkeleton(gradient);
        } else if (widget.tabIndex == 1) {
          return _buildSavedBooksSkeleton(gradient);
        } else {
          return _buildCompletedBooksSkeleton(gradient);
        }
      },
    );
  }

  Widget _buildContinueReadingSkeleton(LinearGradient gradient) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.darkBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 16,
                      width: 160,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedBooksSkeleton(LinearGradient gradient) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 14,
                width: 100,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: 60,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 12,
                    width: 35,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedBooksSkeleton(LinearGradient gradient) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 75,
                height: 108,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 14,
                      width: 140,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 12,
                      width: 110,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 24,
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
