import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Nota Theme Configuration.
/// Strict two-tone Ink (#17120D) on Paper (#EAE3D3) theme.
/// Disables Material 3 elevation and surface tinting.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.ink,
        onPrimary: AppColors.paper,
        secondary: AppColors.ink,
        onSecondary: AppColors.paper,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        error: AppColors.ink,
        onError: AppColors.paper,
      ),
      fontFamily: AppTypography.fontInter,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTypography.headlineMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: AppColors.paper,
        modalBarrierColor: AppColors.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.cardEdge, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.hlFill,
        selectionHandleColor: AppColors.ink,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppColors.cardEdge, width: 1),
        ),
        titleTextStyle: AppTypography.titleMedium,
        contentTextStyle: AppTypography.bodyMedium,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: AppTypography.fontInter,
          color: AppColors.paper,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
        elevation: 0,
      ),
    );
  }
}
