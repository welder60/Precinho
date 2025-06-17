import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: AppTheme.primaryGradientDecoration,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo da aplicação
              Icon(
                Icons.shopping_cart,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              
              // Nome da aplicação
              Text(
                'Precinho',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              
              // Slogan
              Text(
                'Encontre os melhores preços',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              
              // Indicador de carregamento
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

