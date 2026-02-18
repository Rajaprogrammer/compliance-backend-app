import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../config/theme.dart';
import 'home_screen.dart';
import 'work_queue_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.space_dashboard_rounded, activeIcon: Icons.space_dashboard, label: 'Home'),
    _NavItem(icon: Icons.list_alt_rounded, activeIcon: Icons.list_alt, label: 'Tasks'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(context, auth, isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(_selectedIndex),
      ),
      bottomNavigationBar: _buildBottomNav(context, isDark),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider auth, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E).withOpacity(0.8) : Colors.white.withOpacity(0.8),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppTheme.primaryGradient),
                      child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ComplianceOS', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(auth.user?.role ?? 'USER', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.read<AppProvider>().toggleTheme(),
                      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () => _showProfileSheet(context, auth),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppTheme.purple.withOpacity(0.8), AppTheme.pink.withOpacity(0.8)]),
                        ),
                        child: Center(
                          child: Text((auth.user?.email ?? 'U')[0].toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const WorkQueueScreen();
      case 2: return const SettingsScreen();
      default: return const HomeScreen();
    }
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
            border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == _selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isSelected ? item.activeIcon : item.icon, color: isSelected ? AppTheme.primary : (isDark ? Colors.white54 : Colors.black45), size: 24),
                            const SizedBox(height: 4),
                            Text(item.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: isSelected ? AppTheme.primary : (isDark ? Colors.white54 : Colors.black45))),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quick task coming soon!'))),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: AppTheme.primaryGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    ).animate().scale(delay: 500.ms, duration: 300.ms);
  }

  void _showProfileSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.purple, AppTheme.pink])),
              child: Center(child: Text((auth.user?.email ?? 'U')[0].toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32))),
            ),
            const SizedBox(height: 16),
            Text(auth.user?.displayName ?? 'User', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(auth.user?.email ?? '', style: GoogleFonts.inter(color: const Color(0xFF8E8E93))),
            const SizedBox(height: 8),
            Chip(label: Text(auth.user?.role ?? 'USER'), backgroundColor: AppTheme.primary.withOpacity(0.1), labelStyle: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(context); auth.signOut(); },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
