import 'package:flutter/material.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';

class SelectProfileScreen extends StatelessWidget {
  const SelectProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> profiles = [
      //TODO Fetch real profiles from storage
      {"name": "Heng HuyLong", "isMain": true},
      {"name": "RithySal", "isMain": false},
      {"name": "Heak Sokleapvoleak", "isMain": false},
      {"name": "Heng Huymeng", "isMain": false},
    ];

    // Sort main profile to appear first
    profiles.sort((a, b) => (b["isMain"] ? 1 : 0) - (a["isMain"] ? 1 : 0));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
        title: Text(
          "Select a profile",
          style: AppTypography.bodyBold.copyWith(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: profiles.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.darkGray.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final profile = profiles[index];
          final bool isMain = profile["isMain"] as bool;
          final String name = profile["name"];

          return ListTile(
            leading: Icon(
              isMain ? Icons.person : Icons.group,
              color: isMain ? AppColors.green : AppColors.darkGray,
              size: 26,
            ),
            title: Text(
              name,
              style: AppTypography.bodyBold.copyWith(
                fontSize: 15,
                color: AppColors.black,
              ),
            ),
            subtitle: isMain
                ? Text(
                    "Main profile",
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: AppColors.darkGray.withValues(alpha: 0.6),
                    ),
                  )
                : null,
            trailing: const Icon(Icons.add, color: AppColors.green),
            onTap: () {
              Navigator.pop(context, name);
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          );
        },
      ),
    );
  }
}
