import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Core Colors ---
  static const Color primaryGold = Color(0xFFCBA052); // Vàng ánh kim pha nâu
  static const Color primaryGoldDark = Color(0xFF9E7729); // Nâu ánh kim
  static const Color primaryGoldLight = Color(0xFFEFDD90); // Vàng kim nhạt (phông báo/badge)

  static const Color bgCream = Color(0xFFFAF8F5); // Màu nền kem sáng
  static const Color bgCreamDarker = Color(0xFFF0EBE1); // Nền kem đậm hơn chút

  static const Color cardWhite = Color(0xFFFFFFFF); // Nền thẻ
  static const Color dividerColor = Color(0xFFEBE5DF); // Đường viền/ngăn cách thẻ

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF2A2420); // Chữ chính (Đen nâu)
  static const Color textSecondary = Color(0xFF888075); // Chữ phụ (Xám nâu)
  static const Color textGold = Color(0xFF8B5E34); // Chữ mầu vàng đất (dành cho badge)

  // --- Gradients ---
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFEED58F), Color(0xFFCBA052), Color(0xFF9E7729)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAF8F5), Color(0xFFF3EEDC)], // Nền ombre nhẹ
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgCream,
      colorScheme: const ColorScheme.light(
        primary: primaryGold,
        onPrimary: Colors.white,
        secondary: primaryGoldDark,
        onSecondary: Colors.white,
        surface: cardWhite,
        onSurface: textPrimary,
      ),
      
      // Google Font: Nunito có nét mềm mại, hỗ trợ tiếng Việt tốt
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w500),
        bodySmall: GoogleFonts.nunito(color: textSecondary, fontWeight: FontWeight.w500),
        labelLarge: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w600),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        // Force status bar icons màu tối — đọc được trên nền sáng + nền video
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.nunito(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryGoldDark,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0, // Nổi bằng shadow nhạt hoặc viền
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: dividerColor, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: dividerColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 24,
      ),
      
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }
}
