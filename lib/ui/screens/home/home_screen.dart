// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/models/base_document.dart';
import 'package:romlerk/data/models/national_id_model.dart';
import 'package:romlerk/ui/widgets/custom_app_bar.dart';
import 'package:romlerk/ui/widgets/custom_bottom_nav.dart';
import 'package:romlerk/ui/widgets/custom_drawer.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/core/providers/user_provider.dart';
import 'package:romlerk/core/providers/navigation_provider.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/ui/widgets/national_id_card_widget.dart';
import 'package:romlerk/data/models/birth_certificate_model.dart'; // 🆕
import 'package:romlerk/ui/widgets/birth_certificate_card_widget.dart'; // 🆕
import 'package:romlerk/data/models/driver_license_model.dart';
import 'package:romlerk/ui/widgets/driver_license_card_widget.dart';
import 'package:romlerk/ui/screens/documents/document_detail_screen.dart';
import '../documents/documents_screen.dart';
import '../scan/scan_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    final documentsAsync = ref.watch(documentsProvider);
    final user = ref.watch(userProvider);
    final username = (user?.name?.isNotEmpty ?? false) ? user!.name! : "User";

    final List<Widget> pages = [
      _HomeContent(documentsAsync: documentsAsync, username: username),
      const DocumentsScreen(),
      const ScanScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: selectedIndex == 3 ? null : const CustomAppBar(),
      endDrawer: const CustomDrawer(),
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  final AsyncValue<List<BaseDocument>> documentsAsync;
  final String username;

  const _HomeContent({required this.documentsAsync, required this.username});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  String selectedCategory = "All";
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> categories = [
    {"label": "All", "icon": Icons.folder_open},
    {"label": "National ID", "icon": Icons.badge_outlined},
    {"label": "Birth Certificate", "icon": Icons.document_scanner_outlined},
    {"label": "Passport", "icon": Icons.flight_outlined},
    {"label": "License", "icon": Icons.directions_car_outlined},
  ];

  // ✅ Updated refresh logic with a temporary "Refreshing..." state
  Future<void> _refreshDocuments() async {
    if (mounted) setState(() => _isRefreshing = true);
    try {
      // 1️⃣ Force refresh profiles
      await ref.read(profilesProvider.notifier).fetchProfiles();

      // 2️⃣ Invalidate all document providers
      ref.invalidate(documentsProvider);
      ref.invalidate(documentsProviderForProfile('main'));

      // 3️⃣ Refetch sub-profile documents
      final profiles = ref.read(profilesProvider).maybeWhen(
            data: (list) => list,
            orElse: () => const [],
          );

      for (final p in profiles) {
        ref.invalidate(documentsProviderForProfile(p.id));
        await ref.read(documentsProviderForProfile(p.id).future);
      }
    } catch (e) {
      debugPrint("❌ Error refreshing documents: $e");
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.username;
    final profilesAsync = ref.watch(profilesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryBar(),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshDocuments,
                color: AppColors.green,
                backgroundColor: AppColors.white,
                strokeWidth: 2.5,
                child: _isRefreshing
                    ? _buildRefreshingView() // ✅ show temporary loader
                    : profilesAsync.when(
                        data: (profiles) {
                          Future.microtask(() {
                            for (final p in profiles) {
                              ref.read(documentsProviderForProfile(p.id));
                            }
                          });

                          final allProfiles = [
                            {"id": "main", "name": username, "isMain": true},
                            ...profiles.map((p) => {
                                  "id": p.id,
                                  "name": p.name,
                                  "isMain": false,
                                }),
                          ];

                          bool hasAnyDocument = false;

                          final profileWidgets = allProfiles.map((profile) {
                            final profileId = profile["id"] as String;
                            final profileName = profile["name"] as String;
                            final isMain = profile["isMain"] as bool;
                            final docsForProfileAsync = ref
                                .watch(documentsProviderForProfile(profileId));

                            if (docsForProfileAsync.isLoading) {
                              return const SizedBox.shrink();
                            }

                            if (docsForProfileAsync.hasError) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "Failed to load $profileName's documents",
                                  style: AppTypography.body
                                      .copyWith(color: Colors.red),
                                ),
                              );
                            }

                            final docs = docsForProfileAsync.value ?? [];
                            final filteredDocs = selectedCategory == "All"
                                ? docs
                                : docs.where((doc) {
                                    if (selectedCategory == "National ID" &&
                                        doc is NationalId) {
                                      return true;
                                    }
                                    if (selectedCategory ==
                                            "Birth Certificate" &&
                                        doc is BirthCertificate) {
                                      return true;
                                    }
                                    if (selectedCategory == "License" &&
                                        doc is DriverLicense) {
                                      return true;
                                    }
                                    return doc.runtimeType
                                        .toString()
                                        .toLowerCase()
                                        .contains(selectedCategory
                                            .toLowerCase()
                                            .replaceAll(" ", "_"));
                                  }).toList();

                            if (filteredDocs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            hasAnyDocument = true;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, bottom: 6),
                                    child: Text(
                                      isMain
                                          ? "My Documents"
                                          : "$profileName's Documents",
                                      style: AppTypography.bodyBold.copyWith(
                                        color: AppColors.darkGray,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: filteredDocs.map((doc) {
                                      if (doc is NationalId) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Material(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              elevation: 2,
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                splashColor: AppColors.green
                                                    .withValues(alpha: 0.25),
                                                highlightColor: AppColors.green
                                                    .withValues(alpha: 0.1),
                                                onTap: () async {
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100));
                                                  if (!mounted) return;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DocumentDetailScreen(
                                                              document: doc),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    fit: BoxFit.scaleDown,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                        maxWidth: 390,
                                                        maxHeight: 300,
                                                      ),
                                                      child:
                                                          NationalIdCardWidget(
                                                              id: doc),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, top: 6, bottom: 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "National ID",
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.darkGray,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    doc.expiryDate != null &&
                                                            doc.expiryDate!
                                                                .isNotEmpty
                                                        ? "Expires: ${doc.expiryDate}"
                                                        : "No expiry",
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      color: AppColors.green,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      if (doc is BirthCertificate) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Material(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              elevation: 2,
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                splashColor: AppColors.green
                                                    .withValues(alpha: 0.25),
                                                highlightColor: AppColors.green
                                                    .withValues(alpha: 0.1),
                                                onTap: () async {
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100));
                                                  if (!mounted) return;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DocumentDetailScreen(
                                                              document: doc),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width: 360,
                                                    height:
                                                        400, // ✅ Smaller fixed preview
                                                    child: AbsorbPointer(
                                                      // 🧩 disable gestures & scroll inside
                                                      absorbing:
                                                          true, // disable all touch/scroll interactions
                                                      child:
                                                          BirthCertificateCardWidget(
                                                              cert: doc),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, top: 6, bottom: 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Birth Certificate",
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.darkGray,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Permanent Document",
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      color: AppColors.darkGray,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      // ===== 🆕 Driver License =====
                                      if (doc is DriverLicense) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Material(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              elevation: 2,
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                splashColor: AppColors.green
                                                    .withValues(alpha: 0.25),
                                                highlightColor: AppColors.green
                                                    .withValues(alpha: 0.1),
                                                onTap: () async {
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100));
                                                  if (!mounted) return;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DocumentDetailScreen(
                                                              document: doc),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    fit: BoxFit.scaleDown,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                        maxWidth: 390,
                                                        maxHeight: 300,
                                                      ),
                                                      child:
                                                          DriverLicenseCardWidget(
                                                              license: doc),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, top: 6, bottom: 12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Driver License",
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.darkGray,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    doc.dateOfExpiry != null &&
                                                            doc.dateOfExpiry!
                                                                .isNotEmpty
                                                        ? "Expires: ${doc.dateOfExpiry}"
                                                        : "No expiry",
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      color: AppColors.green,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList();

                          if (!hasAnyDocument) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.65,
                                  child: _emptyState(context),
                                ),
                              ],
                            );
                          }

                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              ...profileWidgets,
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: _buildAddMoreButton(context),
                              ),
                            ],
                          );
                        },
                        loading: () => _buildRefreshingView(),
                        error: (err, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                "Failed to load profiles",
                                style: AppTypography.body.copyWith(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Please check your connection or try again.",
                                style: AppTypography.body.copyWith(
                                  color: AppColors.darkGray,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _refreshDocuments,
                                icon: const Icon(Icons.refresh,
                                    size: 18, color: Colors.white),
                                label: const Text(
                                  "Retry",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Simple refreshing loader widget
  Widget _buildRefreshingView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.green),
                const SizedBox(height: 12),
                Text(
                  "Refreshing documents...",
                  style: AppTypography.body.copyWith(
                    color: AppColors.darkGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 64, color: AppColors.darkGray.withAlpha(90)),
          const SizedBox(height: 12),
          Text(
            "No documents yet",
            style: AppTypography.bodyBold.copyWith(
              color: AppColors.darkGray,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add your first document to get started",
            style: AppTypography.body.copyWith(
              color: AppColors.darkGray.withAlpha(150),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          _AnimatedAddDocumentButton(
            onPressed: () {
              ref.read(navIndexProvider.notifier).state = 2;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.green.withValues(alpha: 0.25),
          highlightColor: AppColors.green.withValues(alpha: 0.1),
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            if (!mounted) return;
            ref.read(navIndexProvider.notifier).state = 2;
          },
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkGray.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline,
                    size: 36, color: AppColors.green.withAlpha(150)),
                const SizedBox(height: 8),
                Text(
                  "Add More Document",
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: AppColors.green.withAlpha(180),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          const Icon(Icons.search, size: 20, color: AppColors.darkGray),
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
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        separatorBuilder: (_, __) => const SizedBox(width: 28),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat["label"] == selectedCategory;
          return AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.05 : 1.0,
            curve: Curves.easeOut,
            child: _CategoryTab(
              icon: cat["icon"] as IconData,
              label: cat["label"] as String,
              selected: isSelected,
              onTap: () => setState(() => selectedCategory = cat["label"]),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedAddDocumentButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedAddDocumentButton({required this.onPressed});

  @override
  State<_AnimatedAddDocumentButton> createState() =>
      _AnimatedAddDocumentButtonState();
}

class _AnimatedAddDocumentButtonState
    extends State<_AnimatedAddDocumentButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.93);
  void _onTapUp(_) {
    setState(() => _scale = 1.0);
    Future.delayed(const Duration(milliseconds: 120), widget.onPressed);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withAlpha(60),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            "Add Document",
            style: AppTypography.body.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                key: ValueKey(selected),
                size: 22,
                color: selected ? AppColors.green : AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.body.copyWith(
                fontSize: 11,
                color: selected ? AppColors.green : AppColors.darkGray,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 3,
              width: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
