import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({
    super.key,
    required this.activeIndex,
    required this.onCenterTap,
    this.onHomeTap,
    this.onHistoryTap,
    this.onChatTap,
    this.onProfileTap,
  });

  final int activeIndex;
  final VoidCallback onCenterTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: 84,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: Color(0xFFEAE7E3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    asset: AppAssets.beranda,
                    label: 'Beranda',
                    active: activeIndex == 0,
                    onTap: onHomeTap,
                  ),
                  NavItem(
                    asset: AppAssets.history,
                    label: 'History',
                    active: activeIndex == 1,
                    onTap: onHistoryTap,
                  ),
                  const SizedBox(width: 62),
                  NavItem(
                    asset: AppAssets.chat,
                    label: 'Chat',
                    active: activeIndex == 3,
                    onTap: onChatTap,
                  ),
                  NavItem(
                    asset: AppAssets.profil,
                    label: 'Profil',
                    active: activeIndex == 4,
                    onTap: onProfileTap,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: onCenterTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orange,
                  ),
                  child: Icon(
                    activeIndex == 2 ? Icons.navigation_rounded : Icons.add_rounded,
                    color: AppColors.white,
                    size: activeIndex == 2 ? 24 : 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.asset,
    required this.label,
    required this.active,
    this.onTap,
  });

  final String asset;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: active ? 1 : 0.7,
              child: Image.asset(
                asset,
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? AppColors.orange : AppColors.gray,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
