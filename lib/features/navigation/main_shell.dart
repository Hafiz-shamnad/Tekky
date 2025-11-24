import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(child: child),

      // Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Feed',
              onTap: () => context.go('/feed'),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore_rounded,
              label: 'Explore',
              onTap: () => context.go('/explore'),
            ),
            _buildNavItem(
              context: context,
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.emoji_events_outlined,
              selectedIcon: Icons.emoji_events_rounded,
              label: 'Contests',
              onTap: () => context.go('/contests'),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              currentIndex: currentIndex,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),

      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/feed')) {
      return FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      );
    } else if (location.startsWith('/explore')) {
      return FloatingActionButton(
        onPressed: () => context.push('/add-idea'),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      );
    } else {
      return null;
    }
  }
}

int _calculateSelectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;

  if (location.startsWith('/feed')) return 0;
  if (location.startsWith('/explore')) return 1;
  if (location.startsWith('/contests')) return 2;
  if (location.startsWith('/profile')) return 3;

  return 0;
}
