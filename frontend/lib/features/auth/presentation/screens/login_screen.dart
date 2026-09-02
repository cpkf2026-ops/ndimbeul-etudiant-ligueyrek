import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/brand_illustration.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getString(AppConstants.keyRememberedEmail);
    if (remembered == null || !mounted) return;
    setState(() {
      _emailController.text = remembered;
      _rememberMe = true;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final failure = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (failure != null) {
      if (failure is AccountNotFoundFailure) {
        context.showSnack(failure.message, isError: true);
        context.push(RoutePaths.register, extra: _emailController.text.trim());
        return;
      }
      context.showSnack(failure.message, isError: true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(
        AppConstants.keyRememberedEmail,
        _emailController.text.trim(),
      );
    } else {
      await prefs.remove(AppConstants.keyRememberedEmail);
    }
    if (!mounted) return;
    final user = ref.read(authProvider).valueOrNull;
    context.go((user?.role.isAdmin ?? false) ? RoutePaths.admin : RoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _LoginCentered(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            isSubmitting: _isSubmitting,
            onSubmit: _submit,
            rememberMe: _rememberMe,
            onRememberMeChanged: (value) => setState(() => _rememberMe = value),
          ),
          desktop: _LoginSplit(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            isSubmitting: _isSubmitting,
            onSubmit: _submit,
            rememberMe: _rememberMe,
            onRememberMeChanged: (value) => setState(() => _rememberMe = value),
          ),
        ),
      ),
    );
  }
}

/// Mobile / tablette — carte unique centrée, défilable.
class _LoginCentered extends StatelessWidget {
  const _LoginCentered({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BrandMark()
                  .animate()
                  .fadeIn(duration: 380.ms)
                  .slideY(begin: -0.15, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 28),
              const _Heading()
                  .animate(delay: 90.ms)
                  .fadeIn(duration: 380.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: _LoginFormBody(
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  isSubmitting: isSubmitting,
                  onSubmit: onSubmit,
                  rememberMe: rememberMe,
                  onRememberMeChanged: onRememberMeChanged,
                ),
              ).animate(delay: 170.ms).fadeIn(duration: 380.ms).slideY(
                    begin: 0.12,
                    end: 0,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 24),
              const _RegisterLink()
                  .animate(delay: 240.ms)
                  .fadeIn(duration: 380.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop / grand écran — panneau de marque à gauche (illustration +
/// accroche, occupe toute la hauteur), formulaire centré à droite. Corrige
/// le vide visuel laissé par une simple carte flottante sur un grand écran.
class _LoginSplit extends StatelessWidget {
  const _LoginSplit({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(light: true)
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 380.ms)
                      .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                  Center(
                    child: BrandIllustration(
                      variant: BrandIllustrationVariant.hero,
                      size: 260,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTypography.heroTitle(
                        straight: 'Trouvez votre',
                        accent: 'université idéale.',
                        fontSize: 30,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 360,
                        child: Text(
                          'Orientation, bourses, logement et emploi — tout '
                          'Sénégal Études, guidé par l\'IA.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Heading()
                        .animate()
                        .fadeIn(duration: 380.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 28),
                    _LoginFormBody(
                      formKey: formKey,
                      emailController: emailController,
                      passwordController: passwordController,
                      isSubmitting: isSubmitting,
                      onSubmit: onSubmit,
                      rememberMe: rememberMe,
                      onRememberMeChanged: onRememberMeChanged,
                    ).animate(delay: 90.ms).fadeIn(duration: 380.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 24),
                    const _RegisterLink()
                        .animate(delay: 170.ms)
                        .fadeIn(duration: 380.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.accentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.school_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          AppConstants.appName,
          style: TextStyle(
            color: light ? Colors.white : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bon retour 👋', style: context.textTheme.displayMedium),
        const SizedBox(height: 6),
        Text(
          'Connectez-vous pour continuer votre parcours.',
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _LoginFormBody extends StatelessWidget {
  const _LoginFormBody({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFormField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          AuthFormField(
            label: 'Mot de passe',
            controller: passwordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onRememberMeChanged(!rememberMe),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) => onRememberMeChanged(value ?? false),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Se souvenir de moi',
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push(RoutePaths.forgotPassword),
                child: const Text('Mot de passe oublié ?'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Se connecter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Pas encore de compte ? ', style: context.textTheme.bodyMedium),
        GestureDetector(
          onTap: () => context.push(RoutePaths.register),
          child: Text(
            'Créer un compte',
            style: context.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
