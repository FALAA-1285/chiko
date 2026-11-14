import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palet warna app. Diambil dari warna Chiko: kuning celemek, oranye paruh,
/// pink pipi, dan garis hitam tebal.
class AppColors {
  AppColors._();

  static const cream = Color(0xFFFFF8E7);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1A);
  static const inkSoft = Color(0xFF4A4234);
  static const muted = Color(0xFF6B6355);
  static const line = Color(0xFFD9D0BC);
  static const darkCard = Color(0xFF2A2A2A);
  static const darkMuted = Color(0xFFCFC8B8);

  static const yellow = Color(0xFFFFD12F);
  static const yellowSoft = Color(0xFFFFF0B3);
  static const orange = Color(0xFFF9A11B);
  static const pink = Color(0xFFF7A6AE);

  // Kategori tugas & jadwal
  static const kuliahSoft = Color(0xFFE4EDFF);
  static const kuliahInk = Color(0xFF2F4F99);
  static const kuliahDot = Color(0xFF3D6FD9);
  static const kerjaSoft = Color(0xFFEEE8FF);
  static const kerjaInk = Color(0xFF5B3FC4);
  static const kerjaDot = Color(0xFF7B5BE6);
  static const pribadiSoft = Color(0xFFFDE7EA);
  static const pribadiInk = Color(0xFFA8344F);
  static const pribadiDot = Color(0xFFE0607E);

  // Uang
  static const incomeSoft = Color(0xFFDDF3E8);
  static const incomeInk = Color(0xFF1A7A50);
  static const incomeOnDark = Color(0xFF7FDCAE);
  static const expenseSoft = Color(0xFFFDE3E1);
  static const expenseInk = Color(0xFFC03535);
  static const expenseOnDark = Color(0xFFFF9C94);
  static const transferSoft = Color(0xFFF1ECE0);

  static const danger = Color(0xFFD94848);
  static const urgentCard = Color(0xFFFFF1EF);
}

/// Dua keluarga huruf: Fredoka untuk judul, Nunito untuk teks.
/// Keduanya dibundel di assets/fonts (lihat pubspec.yaml), jadi tidak butuh internet.
class AppText {
  AppText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
  }) =>
      TextStyle(fontFamily: 'Fredoka', fontSize: size, fontWeight: weight, color: color, height: 1.15);

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
  }) =>
      TextStyle(fontFamily: 'Nunito', fontSize: size, fontWeight: weight, color: color, height: height);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.yellow,
      primary: AppColors.ink,
      onPrimary: AppColors.white,
      secondary: AppColors.yellow,
      surface: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.cream,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1.5,
      space: 1,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'Nunito',
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppColors.ink, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.ink : AppColors.white,
      ),
      checkColor: const WidgetStatePropertyAll(AppColors.yellow),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppText.body(14, weight: FontWeight.w700, color: AppColors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.ink, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.ink, width: 2.5),
      ),
      hintStyle: AppText.body(14, color: AppColors.muted),
    ),
  );
}
