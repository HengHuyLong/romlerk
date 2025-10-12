import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/core/providers/user_provider.dart';
import 'package:romlerk/core/providers/navigation_provider.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/ui/screens/documents/document_detail_screen.dart';
import 'package:romlerk/ui/screens/documents/profiles/create_profile_screen.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  bool _expanded = true;

  final Map<String, bool> _expandedProfiles = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    if (_expanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  void _toggleSubProfile(String id) {
    setState(() {
      _expandedProfiles[id] = !(_expandedProfiles[id] ?? true);
    });
  }

  void _navigateToScan(BuildContext context) {
    ref.read(navIndexProvider.notifier).state = 2; // 2 = Scan tab
  }

  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(documentsProvider);
    final profilesState = ref.watch(profilesProvider);
    final user = ref.watch(userProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // ✅ Refresh both main and sub profiles
          await ref.read(documentsProvider.notifier).refresh();
          await ref.read(profilesProvider.notifier).fetchProfiles();

          // ✅ Refresh all sub-profile document caches properly
          final profiles = ref.read(profilesProvider).value ?? [];
          for (final p in profiles) {
            ref.invalidate(documentsProviderForProfile(p.id));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreateProfileScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.darkGray.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: const Icon(Icons.person_add_alt_1_outlined,
                    size: 18, color: AppColors.green),
                label: Text(
                  "Create Profile",
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.darkGray.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 20, color: AppColors.darkGray),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Search document",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.darkGray.withValues(alpha: 0.15)),
              const SizedBox(height: 8),

              // ✅ Main profile section
              documentsState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      "Failed to load documents\n$err",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ),
                data: (documents) {
                  final userName = user?.name?.isNotEmpty == true
                      ? "${user!.name}'s Documents"
                      : "User's Documents";

                  final allDocs = [...documents, "add_more"];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _toggleExpansion,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _expanded ? 0.25 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 28,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizeTransition(
                        sizeFactor: _sizeAnimation,
                        child: FadeTransition(
                          opacity: _sizeAnimation,
                          child: _buildGrid(allDocs),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Divider(color: AppColors.darkGray.withValues(alpha: 0.15)),

              // ✅ Sub-profile section
              profilesState.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Failed to load profiles: $err",
                    style: AppTypography.body.copyWith(color: Colors.red),
                  ),
                ),
                data: (profiles) {
                  if (profiles.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No sub-profiles found",
                          style: AppTypography.body.copyWith(
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    );
                  }

                  final avatarMap = {
                    'Mom': 'assets/images/mom_avatar.svg',
                    'Dad': 'assets/images/dad_avatar.svg',
                    'Grandpa': 'assets/images/grandpa_avatar.svg',
                    'Grandma': 'assets/images/grandma_avatar.svg',
                    'Son': 'assets/images/son_avatar.svg',
                    'Daughter': 'assets/images/daughter_avatar.svg',
                    'Brother': 'assets/images/brother_avatar.svg',
                    'Sister': 'assets/images/sister_avatar.svg',
                    'Other': 'assets/images/other_avatar.svg',
                  };

                  return Column(
                    children: profiles.map((profile) {
                      final isExpanded = _expandedProfiles[profile.id] ?? true;
                      final avatarPath =
                          avatarMap[profile.type] ?? avatarMap['Other']!;
                      final docsAsync =
                          ref.watch(documentsProviderForProfile(profile.id));

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _toggleSubProfile(profile.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          "${profile.name}'s Documents",
                                          style: AppTypography.body.copyWith(
                                            color: AppColors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 28,
                                          width: 28,
                                          child: SvgPicture.asset(
                                            avatarPath,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          profile.type,
                                          style: AppTypography.body.copyWith(
                                            color: AppColors.green,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // TODO: navigate to edit profile
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.green,
                                    ),
                                    splashRadius: 20,
                                  ),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.25 : 0.0,
                                    duration: const Duration(milliseconds: 250),
                                    child: const Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      size: 28,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: docsAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.green,
                                  ),
                                ),
                              ),
                              error: (err, _) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Failed to load ${profile.name}'s documents",
                                  style: AppTypography.body.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              data: (docs) {
                                final allDocs = [...docs, "add_more"];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: _buildGrid(allDocs),
                                );
                              },
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List allDocs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allDocs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 30,
        crossAxisSpacing: 14,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final item = allDocs[index];
        if (item == "add_more") {
          return _buildAddMoreCard(context);
        } else {
          return _buildDocumentItem(context, item);
        }
      },
    );
  }

  Widget _buildDocumentItem(BuildContext context, dynamic doc) {
    final type = (doc.toJson()['type'] ?? '').toString();
    final title = switch (type) {
      'national_id' => 'ID Card',
      'passport' => 'Passport',
      'driver_license' => 'Driver License',
      _ => 'Unknown Document',
    };

    String expiryText = "No expiry";
    Color expiryColor = AppColors.darkGray;

    final expiryRaw = doc.toJson()['expiryDate'];
    if (expiryRaw != null && expiryRaw.toString().isNotEmpty) {
      try {
        final expiryDate = DateTime.tryParse(expiryRaw.toString());
        if (expiryDate != null) {
          final now = DateTime.now();
          final isExpired = expiryDate.isBefore(now);
          expiryColor = isExpired ? Colors.red : AppColors.green;
          expiryText = DateFormat('dd MMM yyyy').format(expiryDate);
        }
      } catch (_) {
        expiryText = "Invalid date";
        expiryColor = Colors.red;
      }
    }

    final thumbAsset =
        type == 'national_id' ? 'assets/images/idCardThumbnail.png' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentDetailScreen(document: doc),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            height: 110,
            child: thumbAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      thumbAsset,
                      fit: BoxFit.contain,
                    ),
                  )
                : Container(
                    color: AppColors.darkGray.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(Icons.insert_drive_file_outlined,
                          size: 30, color: AppColors.darkGray),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.bodyBold.copyWith(
            fontSize: 13,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          expiryText,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 11,
            color: expiryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreCard(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: GestureDetector(
            onTap: () => _navigateToScan(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              height: 110,
              child: const Center(
                child: Icon(Icons.add, size: 36, color: AppColors.green),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Add More",
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 12,
            color: AppColors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
