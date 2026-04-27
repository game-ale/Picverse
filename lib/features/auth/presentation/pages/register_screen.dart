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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms & Conditions'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Back button + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardDarkBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                    Text(
                      l10n.text('createAccount'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 6),
                    Text(
                      l10n.text('joinAndShare'),
                      style: TextStyle(fontSize: 14, color: AppColors.grey400),
                    ),

                  const SizedBox(height: 32),

                  // Form card
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
                            controller: _usernameController,
                            hintText: l10n.text('username'),
                            prefixIcon: Icons.person_outline,
                            validator: Validators.username,
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            hintText: l10n.text('confirmPassword'),
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirm,
                            onToggleObscure: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return l10n.text('passwordsDoNotMatch');
                              }
                              return Validators.password(value);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Terms checkbox
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (v) => setState(
                                    () => _agreedToTerms = v ?? false,
                                  ),
                                  activeColor: AppColors.primaryPurple,
                                  side: const BorderSide(
                                    color: AppColors.cardDarkBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.text('agreeTerms'),
                                  style: TextStyle(
                                    color: AppColors.grey400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return PrimaryButton(
                                text: l10n.text('createAccount'),
                                isLoading: state.status == AuthStatus.loading,
                                onPressed: _onRegister,
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppColors.cardDarkBorder),
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
                                child: Divider(color: AppColors.cardDarkBorder),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google
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

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.text('alreadyHaveAccount'),
                        style: TextStyle(
                          color: AppColors.grey400,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          l10n.text('signIn'),
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
