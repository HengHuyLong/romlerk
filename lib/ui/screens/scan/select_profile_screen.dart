import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/core/providers/user_provider.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/data/models/profile.dart';

class SelectProfileScreen extends ConsumerStatefulWidget {
  const SelectProfileScreen({super.key});

  @override
  ConsumerState<SelectProfileScreen> createState() =>
      _SelectProfileScreenState();
}

class _SelectProfileScreenState extends ConsumerState<SelectProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profilesProvider.notifier).fetchProfiles();
    });
  }

  /// Map type → avatar asset
  String _avatarForType(String type) {
    final key = type.toLowerCase();
    if (key.contains('mom')) return 'assets/images/mom_avatar.svg';
    if (key.contains('dad')) return 'assets/images/dad_avatar.svg';
    if (key.contains('grandpa')) return 'assets/images/grandpa_avatar.svg';
    if (key.contains('grandma')) return 'assets/images/grandma_avatar.svg';
    if (key.contains('son')) return 'assets/images/son_avatar.svg';
    if (key.contains('daughter')) return 'assets/images/daughter_avatar.svg';
    if (key.contains('brother')) return 'assets/images/brother_avatar.svg';
    if (key.contains('sister')) return 'assets/images/sister_avatar.svg';
    return 'assets/images/other_avatar.svg';
  }

  /// Small rectangular avatar (no border)
  Widget _buildAvatar(String type) {
    final asset = _avatarForType(type);
    return SizedBox(
      width: 48,
      height: 48,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Center(
          child: Icon(Icons.person, color: AppColors.darkGray, size: 26),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final profilesState = ref.watch(profilesProvider);

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
      body: profilesState.when(
        data: (profiles) {
          final List<Map<String, dynamic>> allProfiles = [];

          // ✅ Include main user with icon
          if (user != null) {
            allProfiles.add({
              "id": "main",
              "name": user.name ?? "Main User",
              "isMain": true,
              "type": "Main",
            });
          }

          // ✅ Add subprofiles
          for (final Profile p in profiles) {
            allProfiles.add({
              "id": p.id,
              "name": p.name,
              "isMain": false,
              "type": p.type,
            });
          }

          final bool hasSubProfiles = allProfiles.length > 1;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: allProfiles.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.darkGray.withValues(alpha: 0.15),
                  ),
                  itemBuilder: (context, index) {
                    final profile = allProfiles[index];
                    final bool isMain = profile["isMain"] as bool;
                    final String name = profile["name"];
                    final String type = profile["type"];

                    return ListTile(
                      leading: isMain
                          ? const Icon(
                              Icons.person,
                              color: AppColors.green,
                              size: 30,
                            )
                          : _buildAvatar(type),
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
                                color:
                                    AppColors.darkGray.withValues(alpha: 0.6),
                              ),
                            )
                          : Text(
                              type,
                              style: AppTypography.body.copyWith(
                                fontSize: 12,
                                color:
                                    AppColors.darkGray.withValues(alpha: 0.6),
                              ),
                            ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.darkGray,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.pop(context, {
                          "id": profile["id"],
                          "name": name,
                          "isMain": isMain,
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                    );
                  },
                ),
              ),

              // Helper text if only main user exists
              if (!hasSubProfiles)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    "Create a profile to add this document to a different profile.",
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      fontSize: 13,
                      color: AppColors.darkGray.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
        error: (err, _) => Center(
          child: Text(
            "Failed to load profiles",
            style: AppTypography.body.copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
