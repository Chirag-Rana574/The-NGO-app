import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../shared/widgets/jaali_background.dart';
import '../shared/widgets/single_arch.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl, _cardCtrl;
  late Animation<double> _logoBounce, _cardFade;
  late Animation<Offset> _cardSlide;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true; // true = sign in, false = sign up
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _isPhoneLogin = false;
  bool _codeSent = false;
  String _verificationId = '';

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..forward();
    _logoBounce = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);

    _cardCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    );
    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.04), end: Offset.zero,
    ).animate(_cardFade);

    Future.delayed(const Duration(milliseconds: 300), _cardCtrl.forward);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _cardCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleEmailSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final authService = ref.read(firebaseAuthServiceProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await authService.signInWithEmail(email, password);
        if (mounted) {
          _showNotification('Welcome back!');
          context.go('/home');
        }
      } else {
        await authService.signUpWithEmail(email, password);
        if (mounted) {
          _showNotification('Account created! You are now signed in.');
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        _showNotification(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhoneSubmit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showNotification('Phone number is required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final authService = ref.read(firebaseAuthServiceProvider);

    try {
      await authService.verifyPhoneNumber(
        phoneNumber: phone,
        codeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _showNotification('OTP sent successfully!');
        },
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          _showNotification(e.message ?? 'Verification failed', isError: true);
        },
        verificationCompleted: (credential) async {
          // Auto retrieval
          final result = await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted && result.user != null) {
            _showNotification('Welcome back!');
            context.go('/home');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showNotification(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  Future<void> _handleVerifyOTP() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length < 6) {
      _showNotification('Enter the 6-digit OTP code', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final authService = ref.read(firebaseAuthServiceProvider);

    try {
      final user = await authService.signInWithOTP(_verificationId, code);
      if (mounted && user != null) {
        _showNotification('Welcome back!');
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showNotification(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.signInWithGoogle();
      
      if (mounted && user != null) {
        _showNotification('Welcome, ${user.displayName ?? "User"}!');
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showNotification(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showNotification('Enter your email address first', isError: true);
      return;
    }
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.resetPassword(email);
      if (mounted) {
        _showNotification('Password reset email sent to $email');
      }
    } catch (e) {
      if (mounted) {
        _showNotification(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.surface;
    final cardFill     = context.raised;
    final borderTop    = context.border2;
    final borderColor  = context.border;
    final isDark       = context.isDark;

    return Scaffold(
      backgroundColor: context.ground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HERO SECTION ──────────────────────────────────
            Stack(
              children: [
                JaaliBackground(
                  opacity: isDark ? 0.12 : 0.07,
                  child: Container(
                    width: double.infinity,
                    color: surfaceColor,
                    padding: const EdgeInsets.fromLTRB(16, 80, 16, 36),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _logoBounce,
                          child: const Text('⚖️', style: TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: 20),
                        Text('Legal Assistant Pro',
                          style: AppTextStyles.display(
                            color: context.sandGlow,
                          ).copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text('Premium Workspace for Indian Advocates',
                          style: AppTextStyles.body(
                            color: isDark ? context.textSec : context.border.withValues(alpha: 0.7),
                          ).copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(bottom: -1, left: 0, right: 0, child: const SingleArch(width: 120, height: 18)),
              ],
            ),

            // ── CARD & FORM SECTION ───────────────────────────
            FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      Form(
                        key: _formKey,
                        child: _isPhoneLogin
                            ? _buildPhoneForm(context)
                            : _buildEmailForm(context),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(children: [
                        Expanded(child: Divider(color: borderColor, thickness: 0.5)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or continue with',
                            style: AppTextStyles.bodySmall(
                              color: context.textDim,
                            )),
                        ),
                        Expanded(child: Divider(color: borderColor, thickness: 0.5)),
                      ]),
                      const SizedBox(height: 24),
                      
                      _GoogleButton(
                        fillColor: cardFill,
                        borderTop: borderTop,
                        borderColor: borderColor,
                        onTap: _handleGoogleSignIn,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      OutlinedButton(
                        onPressed: () {
                          context.go('/home');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          )
                        ),
                        child: Text('Continue as Guest', style: AppTextStyles.body(color: context.textPri)),
                      ),
                      
                      const SizedBox(height: 36),
                      Text('Secure · Firebase Auth · Enterprise Grade v2.0',
                        style: AppTextStyles.bodySmall(
                          color: context.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLogin ? 'Sign In' : 'Create Account',
          style: AppTextStyles.chatTitle(color: context.textPri),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Enter your credentials to access your workspace.'
              : 'Create a new account to get started.',
          style: AppTextStyles.bodySmall(color: context.textSec),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: context.textPri),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Enter a valid email address';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined, color: context.textDim),
            hintText: 'Email address',
            hintStyle: TextStyle(color: context.textDim),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lal, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.border),
              borderRadius: BorderRadius.circular(4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: context.textPri),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (!_isLogin && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: context.textDim),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: context.textDim,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            hintText: 'Password',
            hintStyle: TextStyle(color: context.textDim),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.lal, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.border),
              borderRadius: BorderRadius.circular(4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        if (_isLogin) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: Text('Forgot password?', style: TextStyle(color: AppColors.lazuli, fontSize: 13)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleEmailSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 2,
          ),
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _isLogin = !_isLogin;
              _passwordController.clear();
            }),
            child: Text(
              _isLogin ? "Don't have an account? Sign up" : 'Already have an account? Sign in',
              style: TextStyle(color: AppColors.lazuli, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _isPhoneLogin = true;
              _codeSent = false;
              _phoneController.clear();
              _codeController.clear();
            }),
            child: Text(
              'Sign In with Phone number',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Sign In',
          style: AppTextStyles.chatTitle(color: context.textPri),
        ),
        const SizedBox(height: 8),
        Text(
          _codeSent
              ? 'Enter the 6-digit OTP code sent to your phone.'
              : 'Enter your phone number (with country code, e.g., +91).',
          style: AppTextStyles.bodySmall(color: context.textSec),
        ),
        const SizedBox(height: 16),
        if (!_codeSent)
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: context.textPri),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined, color: context.textDim),
              hintText: '+919999988888',
              hintStyle: TextStyle(color: context.textDim),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lal, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.border),
                borderRadius: BorderRadius.circular(4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        else
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: context.textPri),
            maxLength: 6,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.sms_outlined, color: context.textDim),
              hintText: 'Enter 6-digit OTP',
              hintStyle: TextStyle(color: context.textDim),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lal, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.border),
                borderRadius: BorderRadius.circular(4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : (_codeSent ? _handleVerifyOTP : _handlePhoneSubmit),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _codeSent ? 'Verify OTP' : 'Send Verification Code',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _isPhoneLogin = false;
              _codeSent = false;
              _phoneController.clear();
              _codeController.clear();
            }),
            child: Text(
              'Back to Email Sign In',
              style: TextStyle(color: AppColors.lazuli, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final Color fillColor;
  final Color borderTop;
  final Color borderColor;
  final VoidCallback onTap;
  final bool isLoading;

  const _GoogleButton({
    required this.fillColor,
    required this.borderTop,
    required this.borderColor,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(height: 3, color: borderTop),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.g_mobiledata, size: 32),
                  const SizedBox(width: 8),
                  Text('Sign in with Google', style: AppTextStyles.body(color: context.textPri)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
