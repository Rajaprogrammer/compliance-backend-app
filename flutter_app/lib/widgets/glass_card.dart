import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class GlassCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showAccentBar;

  const GlassCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.accentColor,
    this.padding,
    this.margin,
    this.onTap,
    this.showAccentBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E).withOpacity(0.8)]
                  : [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
            ),
            border: Border.all(
              color: accentColor?.withOpacity(0.3) ?? 
                     (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (accentColor ?? AppTheme.primary).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) _buildHeader(context, isDark),
                  Padding(
                    padding: padding ?? const EdgeInsets.all(16),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          if (accentColor != null && showAccentBar)
            Container(
              width: 4,
              height: 28,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
