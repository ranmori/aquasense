
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/app_text_field.dart';

/// Create Account screen.
///
/// Layout (top → bottom):
///   • Teal back-arrow  (top-left, teal circle)
///   • AquaSense logo   (centred)
///   • Title + subtitle (centred)
///   • Email / Password fields
///   • Terms checkbox
///   • "Create Account" primary button
///   • "Sign up with Google" outlined button
///   • "Already have an account? Sign in" link
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;

  /// Primary CTA is enabled only when both fields are filled and terms accepted.
  bool get _canSubmit =>
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _agreedToTerms;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submit(AuthProvider auth) async {
    if (!_canSubmit) return;
    final success = await auth.createAccount(
      email:    _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.emailVerified);
    }
  }

  /// Placeholder — wire up google_sign_in package when ready.
  void _signUpWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-up coming soon')),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // ── Teal back button (top-left) ──────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _TealBackButton(
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── AquaSense logo (centred) ─────────────────────────
                  const Center(child: AppLogo(size: 100)),
                  const SizedBox(height: 24),

                  // ── Title + subtitle (centred) ───────────────────────
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign up to get started on the platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Email field ──────────────────────────────────────
                  const _FieldLabel('Email'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),

                  // ── Password field ───────────────────────────────────
                  const _FieldLabel('Password'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint: '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // ── Terms checkbox ───────────────────────────────────
                  _TermsCheckbox(
                    value: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val),
                  ),
                  const SizedBox(height: 24),

                  // ── Primary CTA ──────────────────────────────────────
                  AppButton(
                    label: 'Create Account',
                    enabled: _canSubmit,
                    isLoading: auth.status == AuthStatus.loading,
                    onPressed: () => _submit(auth),
                  ),
                  const SizedBox(height: 14),

                  // ── Google sign-up ───────────────────────────────────
                  _GoogleButton(onTap: _signUpWithGoogle),
                  const SizedBox(height: 24),

                  // ── Sign-in link ─────────────────────────────────────
                  _SignInLink(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Teal circular back button — matches the design's mint/teal arrow circle.
class _TealBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TealBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          // Mint/teal tint matching the design's back-button circle
          color: Color(0xFFB2F5EA),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: AppColors.teal,
          size: 20,
        ),
      ),
    );
  }
}

/// Simple bold field label above a text field.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}

/// Checkbox row: "I agree to the terms of service and privacy policy"
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Custom checkbox square
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.teal.withValues(alpha: 0.12)
                  : AppColors.white,
              border: Border.all(
                color: value ? AppColors.teal : AppColors.borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: AppColors.teal)
                : null,
          ),
          const SizedBox(width: 10),

          // Rich text with tappable terms links
          Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              children: [
                TextSpan(
                  text: 'terms of service',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'privacy policy',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined "Sign up with Google" button.
/// Uses the official Google brand colours for the four-colour 'G' logo.
class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Google 'G' logo (four-colour) ──────────────────────────
            _GoogleGLogo(size: 22),
            const SizedBox(width: 12),
            const Text(
              'Sign up with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the official four-colour Google 'G' using a [CustomPainter].
/// No image asset required — purely vector.
class _GoogleGLogo extends StatelessWidget {
  final double size;
  const _GoogleGLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    // ── Red (top-left arc) ───────────────────────────────────────────────
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      _deg(-210), _deg(120), true, paint,
    );

    // ── Blue (top-right + right arc) ────────────────────────────────────
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      _deg(-90), _deg(95), true, paint,
    );

    // ── Yellow (bottom-left arc) ─────────────────────────────────────────
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      _deg(150), _deg(60), true, paint,
    );

    // ── Green (bottom-right arc) ─────────────────────────────────────────
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      _deg(5), _deg(145), true, paint,
    );

    // ── White centre circle (cuts out middle) ────────────────────────────
    paint.color = AppColors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.60, paint);

    // ── Blue horizontal bar (the crossbar of the G) ──────────────────────
    paint.color = const Color(0xFF4285F4);
    final barTop    = cy - r * 0.13;
    final barBottom = cy + r * 0.13;
    canvas.drawRect(
      Rect.fromLTRB(cx, barTop, cx + r, barBottom),
      paint,
    );
  }

  /// Converts degrees to radians for [canvas.drawArc].
  double _deg(double degrees) => degrees * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Already have an account? Sign in" footer link.
class _SignInLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?  ',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn),
          child: const Text(
            'Sign in',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
