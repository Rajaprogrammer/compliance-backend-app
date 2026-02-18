import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isForgot = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      Helpers.showSnackBar(context, 'Please enter your email', isError: true);
      return;
    }

    if (_isForgot) {
      final success = await auth.resetPassword(email);
      if (mounted) {
        if (success) {
          Helpers.showSnackBar(context, 'Password reset email sent!', isSuccess: true);
          setState(() => _isForgot = false);
        } else if (auth.error != null) {
          Helpers.showSnackBar(context, auth.error!, isError: true);
        }
      }
      return;
    }

    if (password.isEmpty || password.length < 6) {
      Helpers.showSnackBar(context, 'Password must be at least 6 characters', isError: true);
      return;
    }

    bool success;
    if (_isSignUp) {
      success = await auth.signUp(email, password);
      if (mounted && success) {
        Helpers.showSnackBar(context, 'Account created successfully!', isSuccess: true);
      }
    } else {
      success = await auth.signIn(email, password);
    }

    if (mounted && !success && auth.error != null) {
      Helpers.showSnackBar(context, auth.error!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF000000), const Color(0xFF1C1C1E)]
                    : [const Color(0xFFF2F2F7), const Color(0xFFE5E5EA)],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.3),
                    AppTheme.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.8, 0.8)),
          
          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.25),
                    AppTheme.accent.withOpacity(0),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 1200.ms, delay: 200.ms),
          
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Theme toggle in corner
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => app.toggleTheme(),
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      
                      const SizedBox(height: 20),
                      
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 40),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'ComplianceOS',
                        style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Tasks · Calendar · Compliance',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.gray),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                      
                      const SizedBox(height: 48),

                      // Auth Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isForgot ? 'Reset Password' : (_isSignUp ? 'Create Account' : 'Welcome Back'),
                                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isForgot 
                                      ? 'Enter your email to receive a reset link' 
                                      : (_isSignUp ? 'Start managing compliance today' : 'Sign in to continue'),
                                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.gray),
                                ),
                                const SizedBox(height: 28),

                                // Email field
                                Text('Email', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black54)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: _isForgot ? TextInputAction.done : TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: 'your@email.com',
                                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                    filled: true,
                                    fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7),
                                  ),
                                ),
                                
                                const SizedBox(height: 20),

                                // Password field
                                if (!_isForgot) ...[
                                  Text('Password', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black54)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleSubmit(),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      filled: true,
                                      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                ],

                                // Submit button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: auth.isLoading
                                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                        : Text(
                                            _isForgot ? 'Send Reset Link' : (_isSignUp ? 'Create Account' : 'Sign In'),
                                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: 20),

                                // Toggle buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!_isForgot)
                                      TextButton(
                                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                                        child: Text(
                                          _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.primary),
                                        ),
                                      ),
                                  ],
                                ),
                                
                                Center(
                                  child: TextButton(
                                    onPressed: () => setState(() => _isForgot = !_isForgot),
                                    child: Text(
                                      _isForgot ? 'Back to Sign In' : 'Forgot Password?',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.gray),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 700.ms, delay: 300.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Timezone: Asia/Kolkata · Date format: DD-MM-YYYY',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.gray),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
