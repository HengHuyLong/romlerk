import 'package:flutter/material.dart';

/// Global text styles — headings use Merriweather, body uses MerriweatherSans.
/// Khmer uses NotoSansKhmer; switch per widget when needed.
class AppTypography {
  // Headings (Merriweather)
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Merriweather',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 28,
    height: 1.3,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Merriweather',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 22,
    height: 1.35,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Merriweather',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 18,
    height: 1.35,
  );

  // Body (Merriweather Sans)
  static const TextStyle body = TextStyle(
    fontFamily: 'MerriweatherSans',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14.5,
    height: 1.5,
  );
  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'MerriweatherSans',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 14.5,
    height: 1.5,
  );

  // Khmer body (Noto Sans Khmer)
  static const TextStyle bodyKh = TextStyle(
    fontFamily: 'NotoSansKhmer',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14.5,
    height: 1.5,
  );
  static const TextStyle bodyKhBold = TextStyle(
    fontFamily: 'NotoSansKhmer',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 14.5,
    height: 1.5,
  );
}
