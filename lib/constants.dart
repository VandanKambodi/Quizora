import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BRAND
const Color qPrimary = Color(0xFF34B0CC);
const Color qPrimaryLight = Color(0xFF6ED3E6);
const Color qPrimaryDark = Color(0xFF1E8FA6);

/// NEUTRALS
const Color qBlack = Color(0xFF121212);
const Color qWhite = Color(0xFFFFFFFF);
const Color qGrey = Color(0xFF9CA3AF);
const Color qBg = Color(0xFFF9FBFC);

/// TEXT
const Color qTextPrimary = Color(0xFF1F2937);
const Color qTextSecondary = Color(0xFF6B7280);

/// STYLES
TextStyle qTitleStyle = GoogleFonts.poppins(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: qPrimary,
);

TextStyle qSubTitleStyle = GoogleFonts.poppins(
  fontSize: 16,
  color: qTextSecondary,
);

TextStyle qButtonStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: qWhite,
);
