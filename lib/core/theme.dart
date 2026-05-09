import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color secondaryBlue = Color(0xFF1D4ED8);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color softGreen = Color(0xFFF0FDF4);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color neutralBorder = Color(0xFFDCE3EA);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);

  // Priority colors
  static const Color critical = Color(0xFFDC2626);
  static const Color high = Color(0xFFF59E0B);
  static const Color medium = Color(0xFF3B82F6);
  static const Color low = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryBlue,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textDark,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.neutralBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textDark),
        hintStyle: TextStyle(color: AppColors.textDark.withValues(alpha: 0.5)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutralBorder,
        thickness: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softGreen,
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}

/*class AppTheme {
  // 1. لوحة الألوان المستخرجة من التصميم
  static const Color primaryGreen = Color(0xFF1B9E4F); // الأخضر الأساسي
  static const Color secondaryGreen = Color(
    0xFFE1F9EB,
  ); // الأخضر الفاتح (الخلفيات)

  static const Color accentBlue = Color(
    0xFF2E5BFF,
  ); // الأزرق (البطاقات العلوية)
  static const Color errorRed = Color(0xFFFF5C5C); // الأحمر (زر الرفض/الشكاوى)
  static const Color pendingOrange = Color(0xFFFFB038);
  // البرتقالي (قيد الانتظار)
  static const Color backgroundLight = Color(0xFFF8F9FB); // خلفية التطبيق
  static const Color cardBorder = Color(0xFFE0E5EC); // حدود البطاقات
  static const Color darkBg = Color(0xFF121212); // رمادي فحمي عميق
  static Color darkSurface = Color(0xFF1E1E1E); // أفتح قليلاً للبطاقات
  static Color darkBorder = Color(0xFF333333);
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,

      // إعدادات الخطوط (يفضل استخدام خط Cairo)
      fontFamily: 'Cairo',

      // تصميم البطاقات (Cards)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(backgroundColor: Color(0xFF1B9E4F)),
      // تصميم الأزرار (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      // تصميم حقول الإدخال (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),

      // تصميم النصوص
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        titleMedium: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Cairo',

      cardTheme: _cardTheme(darkSurface, darkBorder),
      elevatedButtonTheme: _buttonTheme(primaryGreen, Colors.white),
      inputDecorationTheme: _inputTheme(
        const Color(0xFF252525),
        darkBorder,
        primaryGreen,
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        titleMedium: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
      ),
    );
  }

  // --- دوال مساعدة (Helper Functions) لتوحيد التصميم ---

  static CardThemeData _cardTheme(Color color, Color borderColor) {
    return CardThemeData(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1),
      ),
    );
  }

  static ElevatedButtonThemeData _buttonTheme(Color bg, Color text) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    );
  }

  static InputDecorationTheme _inputTheme(
    Color fill,
    Color border,
    Color focus,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: focus, width: 2),
      ),
    );
  }
}*/
