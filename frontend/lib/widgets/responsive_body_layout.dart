import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ResponsiveBodyLayout extends StatelessWidget {
  final Widget child;
  final bool showSidebars;

  const ResponsiveBodyLayout({
    Key? key,
    required this.child,
    this.showSidebars = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        if (!showSidebars) {
          return child;
        }

        if (isDesktop) {
          // 3-Column Layout for Desktop
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Sidebar
              SizedBox(
                width: constraints.maxWidth * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSidebar('📢', 'Quảng cáo'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Center Content
              Expanded(
                child: child,
              ),
              const SizedBox(width: 16),
              // Right Sidebar
              SizedBox(
                width: constraints.maxWidth * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSidebar('🎁', 'Ưu đãi đặc biệt'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile Layout - Content with sidebars stacked
          return SingleChildScrollView(
            child: Column(
              children: [
                child,
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSidebar('📢', 'Quảng cáo'),
                      const SizedBox(height: 12),
                      _buildSidebar('🎁', 'Ưu đãi đặc biệt'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSidebar(String icon, String label) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;
        final containerHeight = isCompact ? 80.0 : 100.0;
        final fontSize = isCompact ? 28.0 : 36.0;

        return Container(
          height: containerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
