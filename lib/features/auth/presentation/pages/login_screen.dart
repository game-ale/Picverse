import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/utils/validators.dart';
import 'package:picverse/core/widgets/primary_button.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_event.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_state.dart';
import 'package:picverse/features/auth/presentation/widgets/auth_gradient_background.dart';
import 'package:picverse/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.error &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.primaryLight,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glowPurpleStrong,
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      l10n.text('welcomeBack'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.text('signInContinue'),
                      style: TextStyle(fontSize: 14, color: AppColors.grey400),
                    ),

                    const SizedBox(height: 36),

                    // Auth card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.cardDarkBorder),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthTextField(
                              controller: _emailController,
                              hintText: l10n.text('emailAddress'),
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              hintText: l10n.text('password'),
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: Validators.password,
                            ),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                                child: TextButton(
                                onPressed: () =>
                                    context.push('/reset-password'),
                                child: Text(
                                  l10n.text('forgotPassword'),
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return PrimaryButton(
                                  text: l10n.text('signIn'),
                                  isLoading: state.status == AuthStatus.loading,
                                  onPressed: _onLogin,
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.cardDarkBorder,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    l10n.text('or'),
                                    style: TextStyle(
                                      color: AppColors.grey500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.cardDarkBorder,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Google sign in
                            OutlinedButton.icon(
                              onPressed: () => context.read<AuthBloc>().add(
                                AuthGoogleSignInRequested(),
                              ),
                              icon: const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 24,
                              ),
                              label: Text(l10n.text('continueWithGoogle')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                side: const BorderSide(
                                  color: AppColors.cardDarkBorder,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.text('dontHaveAccount'),
                          style: TextStyle(
                            color: AppColors.grey400,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            l10n.text('createAccount'),
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
