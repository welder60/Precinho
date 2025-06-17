import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider_web.dart';

class LoginPageWeb extends ConsumerStatefulWidget {
  const LoginPageWeb({super.key});

  @override
  ConsumerState<LoginPageWeb> createState() => _LoginPageWebState();
}

class _LoginPageWebState extends ConsumerState<LoginPageWeb> {
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

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _signInWithGoogle() {
    ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  void _navigateToRegister() {
    // Para demonstração, vamos simular um cadastro rápido
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastro Rápido'),
        content: const Text('Para demonstração, use:\nEmail: demo@precinho.com\nSenha: 123456'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Mostrar erro se houver
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure!.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Container(
        decoration: AppTheme.primaryGradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo e título
                          const Icon(
                            Icons.shopping_cart,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          Text(
                            'Bem-vindo ao Precinho',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.paddingSmall),
                          Text(
                            'Versão Web - Demonstração',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.paddingLarge),

                          // Campo de email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              hintText: 'demo@precinho.com',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email é obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          // Campo de senha
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock),
                              hintText: '123456',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Senha é obrigatória';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingLarge),

                          // Botão de login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _signIn,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          // Divisor
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.paddingMedium,
                                ),
                                child: Text(
                                  'ou',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          // Botão do Google
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: authState.isLoading ? null : _signInWithGoogle,
                              icon: const Icon(Icons.g_mobiledata, size: 24),
                              label: const Text('Continuar com Google'),
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingLarge),

                          // Link para cadastro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Não tem uma conta? ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: _navigateToRegister,
                                child: const Text('Cadastre-se'),
                              ),
                            ],
                          ),

                          // Informações de demonstração
                          const SizedBox(height: AppTheme.paddingMedium),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppTheme.infoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Demonstração',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: AppTheme.infoColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.paddingSmall),
                                Text(
                                  'Use qualquer email/senha para testar',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.infoColor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

