import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App-wide "friendly & fresh" theme, shared by Customer, Store Admin and
/// Store Worker screens so the whole app looks consistent.
///
/// Screens should use these styles (e.g. Theme.of(context).textTheme.titleLarge)
/// instead of hard-coding colours, fonts, or corner sizes.
class AppTheme {
  AppTheme._();

  /// Corner radius used for buttons, cards, inputs and sheets.
  static const double radius = 16;

  static ThemeData get light {
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    const buttonSize = Size.fromHeight(54);
    const buttonText = TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkGreen,
        primary: AppColors.darkGreen,
        secondary: AppColors.orange,
        tertiary: AppColors.green,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.softWhite,

      // Text sizes are slightly larger than Material defaults
      // to stay readable for older users.
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.softWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
          minimumSize: buttonSize,
          shape: roundedShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          minimumSize: buttonSize,
          shape: roundedShape,
          side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          textStyle: buttonText,
        ),
      ),

      // White cards with a soft shadow, e.g. product cards, order cards.
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: roundedShape,
        margin: EdgeInsets.zero,
      ),

      // Text fields: white, rounded, green border when focused.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.greenTint,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.greenTint,
      ),

      // Dropdown menus
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),

      // Sheets that slide up from the bottom (Store Worker confirmations).
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Progress bars, e.g. packing progress.
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkGreen,
        linearTrackColor: AppColors.greenTint,
      ),
    );
  }
}
