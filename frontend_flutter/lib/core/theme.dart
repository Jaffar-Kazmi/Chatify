import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSizes {
  static const extraSmall = 11.0;
  static const small = 12.0;
  static const standard = 14.0;
  static const standardUp = 16.0;
  static const medium = 20.0;
  static const large = 28.0;
  static const extraLarge = 32.0;
}

class AppColors {
  static const Color primary = Color(0xFF54ACBF);        // Vibrant Teal
  static const Color primaryLight = Color(0xFFA7EBF2);   // Light Cyan
  static const Color primaryDark = Color(0xFF26658C);    // Deep Blue
  static const Color accent = Color(0xFF023859);         // Dark Navy
  static const Color darkest = Color(0xFF011C40);        // Deepest Navy

  // Background Colors
  static const Color background = Color(0xFF011C40);     // Deepest navy
  static const Color surface = Color(0xFF023859);        // Dark navy
  static const Color surfaceLight = Color(0xFF26658C);   // Deep blue
  static const Color surfaceHover = Color(0xFF3A7BA3);   // Lighter blue

  // Text Colors
  static const Color textPrimary = Color(0xFFA7EBF2);    // Light cyan
  static const Color textSecondary = Color(0xFF54ACBF);  // Vibrant teal
  static const Color textTertiary = Color(0xFF4A9AAC);   // Muted teal
  static const Color textMuted = Color(0xFF3A7BA3);      // Soft blue

  // Message Colors
  static const Color messageSent = Color(0xFF54ACBF);      // Teal for sent
  static const Color messageReceived = Color(0xFF26658C); // Deep blue for received
  static const Color messageInput = Color(0xFF023859);     // Dark navy input

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF54ACBF);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFA7EBF2),  // Light cyan
    Color(0xFF54ACBF),  // Vibrant teal
  ];

  static const List<Color> accentGradient = [
    Color(0xFF54ACBF),  // Vibrant teal
    Color(0xFF26658C),  // Deep blue
  ];

  static const List<Color> deepGradient = [
    Color(0xFF26658C),  // Deep blue
    Color(0xFF023859),  // Dark navy
  ];

  // Border & Divider
  static const Color border = Color(0xFF26658C);
  static const Color divider = Color(0xFF023859);
}

// Backward compatibility - maps old DefaultColors to new AppColors
class DefaultColors {
  static const Color greyText = AppColors.textSecondary;
  static const Color whiteText = AppColors.textPrimary;
  static const Color senderMessage = AppColors.messageSent;
  static const Color receiverMessage = AppColors.messageReceived;
  static const Color sentMessageInput = AppColors.messageInput;
  static const Color messageListPage = AppColors.primary;
  static const Color buttonColor = AppColors.surfaceLight;
  static const Color dailyQuestionColor = AppColors.info;
  static const Color headerColor = AppColors.textPrimary;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.darkest,
        onSecondary: AppColors.darkest,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.messageInput,
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: FontSizes.standardUp,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: FontSizes.standard,
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.darkest,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: FontSizes.standard,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: FontSizes.standard,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: FontSizes.standard,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.darkest,
        elevation: 4,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        deleteIconColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: FontSizes.small,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Text Theme
      textTheme: TextTheme(
        // Display styles
        displayLarge: GoogleFonts.inter(
          fontSize: FontSizes.extraLarge,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -1,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: FontSizes.large,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),

        // Headline styles
        headlineLarge: GoogleFonts.inter(
          fontSize: FontSizes.large,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: FontSizes.standardUp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        titleLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.large,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.medium,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standardUp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Body styles (backward compatible)
        bodyLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standardUp,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standard,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standardUp,
          color: AppColors.textSecondary,
          height: 1.4,
        ),

        // Label styles
        labelLarge: GoogleFonts.inter(
          fontSize: FontSizes.standard,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: FontSizes.small,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: FontSizes.extraSmall,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }

  // Custom gradient decoration helpers
  static BoxDecoration get primaryGradientDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
    );
  }

  static BoxDecoration get accentGradientDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: AppColors.accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
    );
  }

  static BoxDecoration get deepGradientDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: AppColors.deepGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
    );
  }

  // Glass morphism effect helper
  static BoxDecoration get glassMorphismDecoration {
    return BoxDecoration(
      color: AppColors.surface.withOpacity(0.7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.border.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // Message bubble decorations
  static BoxDecoration get sentMessageDecoration {
    return BoxDecoration(
      color: AppColors.messageSent,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      ),
    );
  }

  static BoxDecoration get receivedMessageDecoration {
    return BoxDecoration(
      color: AppColors.messageReceived,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(16),
      ),
    );
  }
}