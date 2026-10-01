import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const logo = TextStyle(
    fontFamily: 'Syne',
    fontSize: 21,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    height: 1.05,
  );

  static const title = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1,
  );

  static const sectionTitle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const body = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );
}
