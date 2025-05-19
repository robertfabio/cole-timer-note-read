import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de cores aconchegantes com fundo branco
  static const Color primaryColorLight = Color(0xFFE4A951); // Amarelo aconchegante
  static const Color secondaryColorLight = Color(0xFFE78F8E); // Rosa suave
  static const Color accentColorLight = Color(0xFF81B29A); // Verde menta
  static const Color neutralColorLight = Color(0xFFF7F5F2); // Bege muito claro
  
  static const Color primaryColorDark = Color(0xFFEAB76A); // Amarelo mais suave para tema escuro
  static const Color secondaryColorDark = Color(0xFFEA9E9E); // Rosa suave para tema escuro
  static const Color accentColorDark = Color(0xFF92C5AD); // Verde menta para tema escuro
  static const Color neutralColorDark = Color(0xFF2A2926); // Cinza escuro com tom quente
  
  static const Color backgroundColorLight = Color(0xFFFFFFFF); // Branco puro
  static const Color backgroundColorDark = Color(0xFF1D1C1A); // Quase preto com tom quente
  static const Color surfaceColorLight = Color(0xFFFFFFFF); // Branco
  static const Color surfaceColorDark = Color(0xFF242321); // Cinza escuro com tom quente
  static const Color errorColor = Color(0xFFE57373); // Vermelho suave

  static ThemeData getLightTheme() {
    return _getTheme(
      brightness: Brightness.light,
      primaryColor: primaryColorLight,
      secondaryColor: secondaryColorLight,
      accentColor: accentColorLight,
      neutralColor: neutralColorLight,
      backgroundColor: backgroundColorLight,
      surfaceColor: surfaceColorLight,
    );
  }

  static ThemeData getDarkTheme() {
    return _getTheme(
      brightness: Brightness.dark,
      primaryColor: primaryColorDark,
      secondaryColor: secondaryColorDark,
      accentColor: accentColorDark,
      neutralColor: neutralColorDark,
      backgroundColor: backgroundColorDark, 
      surfaceColor: surfaceColorDark,
    );
  }

  static ThemeData _getTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
    required Color neutralColor,
    required Color backgroundColor,
    required Color surfaceColor,
  }) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      background: backgroundColor,
      onBackground: isDark ? Colors.white : Colors.black87,
      surface: surfaceColor,
      onSurface: isDark ? Colors.white : Colors.black87,
      surfaceVariant: neutralColor,
      onSurfaceVariant: isDark ? Colors.white70 : Colors.black54,
      outline: isDark ? Colors.white30 : Colors.black26,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Color(0xFF28272A) : Colors.white,
        shadowColor: isDark ? Colors.black12 : Colors.black12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.white60 : Colors.black45,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withOpacity(0.15),
        backgroundColor: surfaceColor,
        labelTextStyle: MaterialStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(MaterialState.selected) 
                ? FontWeight.w600 
                : FontWeight.normal,
            color: states.contains(MaterialState.selected)
                ? primaryColor
                : isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(MaterialState.selected)
                ? primaryColor
                : isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.black12 : neutralColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neutralColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: _getTextTheme(brightness),
      fontFamily: 'Montserrat',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static TextTheme _getTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseTextColor = isDark ? Colors.white : Colors.black87;
    
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseTextColor,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
        letterSpacing: -0.25,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseTextColor,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        color: baseTextColor,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        color: baseTextColor,
        letterSpacing: 0.15,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseTextColor,
        letterSpacing: 0.1,
      ),
    );
  }
} 