import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette for NexTalk
  static const Color primary = Color(0xFF6366F1); // Indigo Primary
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFEC4899); // Pink Accent
  static const Color secondary = Color(0xFF14B8A6); // Teal Accent

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBubbleSender = Color(0xFF6366F1);
  static const Color lightBubbleReceiver = Color(0xFFF1F5F9);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBubbleSender = Color(0xFF4F46E5);
  static const Color darkBubbleReceiver = Color(0xFF334155);

  // Status & Read Receipts
  static const Color onlineIndicator = Color(0xFF22C55E);
  static const Color offlineIndicator = Color(0xFF94A3B8);
  static const Color readTick = Color(0xFF38BDF8); // Blue tick
  static const Color unreadTick = Color(0xFF94A3B8); // Single/Double gray tick
}
