import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    cardTheme: _buildCardTheme(),
    bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.dark),
    appBarTheme: _buildAppBarTheme(Brightness.dark),
    inputDecorationTheme: _buildInputTheme(Brightness.dark),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    textTheme: _buildTextTheme(Brightness.light),
    cardTheme: _buildCardTheme(),
    bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.light),
    appBarTheme: _buildAppBarTheme(Brightness.light),
    inputDecorationTheme: _buildInputTheme(Brightness.light),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark 
        ? AppColors.textPrimaryDark 
        : AppColors.textPrimaryLight;
    
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  static CardTheme _buildCardTheme() => CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    ),
    margin: EdgeInsets.zero,
  );

  static BottomNavigationBarThemeData _buildBottomNavTheme(
    Brightness brightness,
  ) => BottomNavigationBarThemeData(
    backgroundColor: brightness == Brightness.dark 
        ? AppColors.darkSurface 
        : AppColors.lightSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: brightness == Brightness.dark 
        ? AppColors.textSecondaryDark 
        : AppColors.textSecondaryLight,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  );

  static AppBarTheme _buildAppBarTheme(Brightness brightness) => AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: brightness == Brightness.dark 
        ? AppColors.textPrimaryDark 
        : AppColors.textPrimaryLight,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: brightness == Brightness.dark 
          ? AppColors.textPrimaryDark 
          : AppColors.textPrimaryLight,
    ),
  );

  static InputDecorationTheme _buildInputTheme(Brightness brightness) {
    final fillColor = brightness == Brightness.dark 
        ? AppColors.glassDark 
        : AppColors.glassLight;
    final borderColor = brightness == Brightness.dark 
        ? AppColors.glassBorderDark 
        : AppColors.glassBorderLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() => 
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
  );

  static TextButtonThemeData _buildTextButtonTheme() => TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    ),
  );
}
