import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores principais
  // Verde suave para a ação principal
  static const Color primaryColor = Color(0xFF79B38C);
  static const Color primaryLightColor = Color(0xFF79B38C);
  static const Color primaryDarkColor = Color(0xFF56996C);

  // Cor de destaque e ações secundárias
  static const Color secondaryColor = Color(0xFF55C18A);
  static const Color secondaryLightColor = Color(0xFF55C18A);
  static const Color secondaryDarkColor = Color(0xFF3BA26E);

  // Cores de status
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Cores neutras
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFF5F5F5);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Cores de texto
  static const Color textPrimaryColor = Color(0xFF222222);
  static const Color textSecondaryColor = Color(0xFF555555);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF);

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLightColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryLightColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: textOnPrimaryColor,
        onSecondary: textOnPrimaryColor,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: textOnPrimaryColor,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimaryColor,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textOnPrimaryColor,
        ),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: textOnPrimaryColor,
        elevation: 4,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textDisabledColor),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryLightColor,
        labelStyle: const TextStyle(color: textPrimaryColor),
        secondaryLabelStyle: const TextStyle(color: textOnPrimaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),

      // Tipografia baseada em Poppins
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: textPrimaryColor, fontSize: 32),
        displayMedium: const TextStyle(fontWeight: FontWeight.bold, color: textPrimaryColor, fontSize: 28),
        displaySmall: const TextStyle(fontWeight: FontWeight.bold, color: textPrimaryColor, fontSize: 24),
        headlineLarge: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryColor, fontSize: 22),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryColor, fontSize: 20),
        headlineSmall: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryColor, fontSize: 18),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryColor, fontSize: 16),
        titleMedium: const TextStyle(fontWeight: FontWeight.w500, color: textPrimaryColor, fontSize: 14),
        titleSmall: const TextStyle(fontWeight: FontWeight.w500, color: textPrimaryColor, fontSize: 12),
        bodyLarge: const TextStyle(fontWeight: FontWeight.normal, color: textPrimaryColor, fontSize: 16),
        bodyMedium: const TextStyle(fontWeight: FontWeight.normal, color: textPrimaryColor, fontSize: 14),
        bodySmall: const TextStyle(fontWeight: FontWeight.normal, color: textSecondaryColor, fontSize: 12),
        labelLarge: const TextStyle(fontWeight: FontWeight.w500, color: textPrimaryColor, fontSize: 14),
        labelMedium: const TextStyle(fontWeight: FontWeight.w500, color: textPrimaryColor, fontSize: 12),
        labelSmall: const TextStyle(fontWeight: FontWeight.w500, color: textSecondaryColor, fontSize: 10),
      ),
    );
  }

  // Tema escuro (para futuras implementações)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Implementar tema escuro se necessário
    );
  }

  // Estilos personalizados
  static const TextStyle priceTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle discountTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: errorColor,
  );

  static const TextStyle ratingTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: warningColor,
  );

  static const TextStyle distanceTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  // Decorações personalizadas
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration primaryGradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor, primaryLightColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Espaçamentos padrão
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Altura padrão para cards de preços de produto
  static const double productCardHeight = 120.0;
}

