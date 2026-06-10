import 'package:flutter/material.dart';

class AppColors {
  // 主色调 - 深绿
  static const Color primaryDark = Color(0xFF1B3A28);
  static const Color primary = Color(0xFF2D5E3A);
  static const Color primaryLight = Color(0xFF4A6B52);
  
  // 背景色
  static const Color bgLight = Color(0xFFF5F3EE);
  static const Color bgLighter = Color(0xFFF8FAF3);
  static const Color bgGreen = Color(0xFFE9EFE5);
  static const Color bgMap = Color(0xFFDCE8D7);
  
  // 强调色
  static const Color accent = Color(0xFF72D350);
  static const Color accentLime = Color(0xFFD7F05B);
  
  // 文字色
  static const Color textDark = Color(0xFF1B3A28);
  static const Color textMedium = Color(0xFF4A6B52);
  static const Color textLight = Color(0xFFDDEBD8);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // 状态色
  static const Color warning = Color(0xFFB45309);
  static const Color info = Color(0xFF315F6A);
  static const Color danger = Color(0xFF7A3D22);
  
  // 边框色
  static const Color border = Color(0xFF1B3A28);
  static const Color borderLight = Color(0xFFD7E2D1);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
    height: 1.35,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
  );
  
  static const TextStyle mono = TextStyle(
    fontFamily: 'Geist Mono',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  
  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'Geist Mono',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );
  
  static const TextStyle chipLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );
}

class StatusBarWidget extends StatelessWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 17, color: AppColors.textDark),
              const SizedBox(width: 6),
              Icon(Icons.wifi, size: 17, color: AppColors.textDark),
              const SizedBox(width: 6),
              Container(
                width: 28,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.textDark,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w800),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
      ],
    );
  }
}
