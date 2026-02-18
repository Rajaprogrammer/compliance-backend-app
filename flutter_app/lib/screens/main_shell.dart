import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../config/theme.dart';
import 'create_task_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/work_queue_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/clients_tab.dart';
import 'tabs/studio_tab.dart';
import 'tabs/ops_tab.dart';
import 'tabs/help_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  List<_NavItem> _getNavItems(AuthProvider auth) {
    return [
      const _NavItem(icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard, label: 'Home', key: 'home'),
      const _NavItem(icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt, label: 'Tasks', key: 'work'),
      const _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendar', key: 'calendar'),
      if (auth.canAccessClients)
        const _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Clients', key: 'clients'),
      const _NavItem(icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note, label: 'Studio', key: 'studio'),
      if (auth.canAccessOps)
        const _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Ops', key: 'ops'),
      const _NavItem(icon: Icons.help_outline, activeIcon: Icons.help, label: 'Help', key: 'help'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navItems = _getNavItems(auth);

    if (_selectedIndex >= navItems.length) _selectedIndex = 0;

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(context, auth, app, isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildBody(navItems[_selectedIndex].key, auth),
      ),
      bottomNavigationBar: _buildBottomNav(navItems, isDark),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider auth, AppProvider app, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E).withOpacity(0.85) : Colors.white.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppTheme.primaryGradient),
                      child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ComplianceOS', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(auth.role,
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  auth.email,
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.gray),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => app.toggleTheme(), // persisted in SharedPreferences (AppProvider)
                      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      tooltip: isDark ? 'Light mode' : 'Dark mode',
                    ),
                    GestureDetector(
                      onTap: () => _showProfileSheet(context, auth),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppTheme.purple.withOpacity(0.8), AppTheme.pink.withOpacity(0.8)]),
                        ),
                        child: Center(
                          child: Text(
                            (auth.email.isNotEmpty ? auth.email[0] : 'U').toUpperCase(),
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
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

  Widget _buildBody(String key, AuthProvider auth) {
    switch (key) {
      case 'home':
        return const HomeTab();
      case 'work':
        return const WorkQueueTab();
      case 'calendar':
        return const CalendarTab();
      case 'clients':
        return const ClientsTab();
      case 'studio':
        return const StudioTab();
      case 'ops':
        return const OpsTab();
      case 'help':
        return const HelpTab();
      default:
        return const HomeTab();
    }
  }

  Widget _buildBottomNav(List<_NavItem> items, bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E).withOpacity(0.92) : Colors.white.withOpacity(0.92),
            border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == _selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? AppTheme.primary : (isDark ? Colors.white54 : Colors.black45),
                              size: 22,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? AppTheme.primary : (isDark ? Colors.white54 : Colors.black45),
                              ),
                            ),
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

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showCreateChooser(),
      elevation: 4,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: AppTheme.primaryGradient,
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    ).animate().scale(delay: 400.ms, duration: 300.ms);
  }

  void _showCreateChooser() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_task_rounded),
                  title: const Text('Create task / series'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen(oneOnly: false)));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flash_on_rounded),
                  title: const Text('Quick: create ONE task'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen(oneOnly: true)));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileSheet(BuildContext context, AuthProvider auth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.purple, AppTheme.pink])),
              child: Center(
                child: Text(
                  (auth.email.isNotEmpty ? auth.email[0] : 'U').toUpperCase(),
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(auth.displayName.isNotEmpty ? auth.displayName : 'User', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(auth.email, style: GoogleFonts.inter(color: AppTheme.gray)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(auth.role, style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  auth.signOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, padding: const EdgeInsets.symmetric(vertical: 14)),
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
  final String key;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.key});
}
