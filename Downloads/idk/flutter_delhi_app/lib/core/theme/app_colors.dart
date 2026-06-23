import 'package:flutter/material.dart';

class AppColors {
  // ── LIGHT MODE ────────────────────────────────────────────────
  // Surfaces (named for the materials they reference)
  static const marble      = Color(0xFFF9F4EC); // Makrana marble — page background
  static const sandXlt     = Color(0xFFF5ECD8); // Sandstone dust — card fills, inputs
  static const sandLt      = Color(0xFFE8C89A); // Bleached sandstone — borders
  static const sandstone   = Color(0xFFC4956A); // Agra sandstone — accents, focus

  // Primary action (Lal Qila red)
  static const lal         = Color(0xFF8B1A1A); // App bars, hero, primary CTA
  static const lalLt       = Color(0xFFC0392B); // Alerts, destructive, live dot

  // Accent metals
  static const gold        = Color(0xFFB8892A); // Pietra dura border, AI badge
  static const goldLt      = Color(0xFFD4A843); // Gold in light (hover)

  // Inlay gemstones (pietra dura reference)
  static const malachite   = Color(0xFF1A5C4A); // Success, complete, new features
  static const malachiteLt = Color(0xFF2E8B6E); // Malachite hover
  static const lazuli      = Color(0xFF1A3A6B); // Delhi HC, informational, links
  static const lazuliLt    = Color(0xFF2D5FA8); // Lazuli hover

  // Text
  static const ink         = Color(0xFF1C1410); // Primary text — carbon ink on vellum
  static const dust        = Color(0xFF7A6E62); // Secondary — stone dust
  static const stone       = Color(0xFF4A3F35); // Tertiary — dark quarried stone

  // ── DARK MODE (Lapis Lazuli) ─────────────────────────────────────────────────
  // Surfaces (blue-black night)
  static const darkGround   = Color(0xFF080C14); // Deepest background
  static const darkSurface  = Color(0xFF0D1520); // App bars, hero, elevated panels
  static const darkRaised   = Color(0xFF121D2E); // Cards, inputs, raised elements
  static const darkBorder   = Color(0xFF1E2F45); // Standard borders
  static const darkBorder2  = Color(0xFF2A4160); // Emphasis borders, focus tops

  // Primary action (Lapis Lazuli)
  static const darkLal      = Color(0xFFC0392B); // Alert dot, danger (kept as red)
  static const darkLalDim   = Color(0xFF2D6BB5); // CTA fill (Lapis)

  // Accent metals
  static const darkGold     = Color(0xFFD4A843); // Stat values, active accents
  static const darkGoldDim  = Color(0xFF8B6A22); // Top border on cards (dimmed)

  // Inlay stones
  static const darkMalachite = Color(0xFF2EBF8E); // Success, complete
  static const darkMalDim    = Color(0xFF1A5C4A); // Malachite fill
  static const darkLazuli    = Color(0xFF4D8FD4); // Informational (lapis light)
  static const darkLazDim    = Color(0xFF1A3A6B); // Lazuli fill

  // Lapis glows
  static const darkSandGlow  = Color(0xFF7AB3E0); // Primary text glow (warm white replaced by lapis glow)
  static const darkSandDim   = Color(0xFF2A4160); // Muted accent
  static const darkSandstone = Color(0xFF2D6BB5); // Same as darkLalDim

  // Text
  static const darkTextPri   = Color(0xFFC8DCF0); // Primary text — blue-white
  static const darkTextSec   = Color(0xFF7A9CBE); // Secondary text
  static const darkTextDim   = Color(0xFF3A5270); // Dimmed / placeholder text

  // Additional colors for motifs
  static const darkLapis     = Color(0xFF2D6BB5); // Lapis base
  static const darkLapisLt   = Color(0xFF4D8FD4); // Lapis light
  static const darkLapisDim  = Color(0xFF1A3A6B); // Lapis dim
  static const malLt         = Color(0xFF2E8B6E); // Malachite light
}
