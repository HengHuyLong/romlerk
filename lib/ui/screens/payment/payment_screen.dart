// lib/ui/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/core/providers/documents_provider.dart';
import 'package:romlerk/core/providers/profiles_provider.dart';
import 'package:romlerk/core/providers/slot_provider.dart';
import 'package:romlerk/ui/screens/payment/payment_confirm_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _totalDocs() {
    final mainDocs = ref.watch(documentsProvider).value ?? [];
    final profiles = ref.watch(profilesProvider).value ?? [];

    int total = mainDocs.length;
    for (final p in profiles) {
      final subDocs = ref.watch(documentsProviderForProfile(p.id)).value ?? [];
      total += subDocs.length;
    }
    return total;
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToConfirmScreen({
    required String planName,
    required String planPrice,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentConfirmScreen(
          planName: planName,
          planPrice: planPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxSlots = ref.watch(slotProvider)['maxSlots'] ?? 3;
    final used = _totalDocs();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/bg_texture.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Plans & Upgrades',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.darkGray.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.folder_open_rounded,
                              color: AppColors.green),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your document slots',
                            style: AppTypography.body.copyWith(
                              color: AppColors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '$used/$maxSlots',
                          style: AppTypography.bodyBold.copyWith(
                            color:
                                used >= maxSlots ? Colors.red : AppColors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.darkGray.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        _HeaderTab(
                          title: 'Buy Slots',
                          selected: _currentPage == 0,
                          onTap: () => _goToPage(0),
                        ),
                        _HeaderTab(
                          title: 'Family Mode',
                          selected: _currentPage == 1,
                          onTap: () => _goToPage(1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _BuySlotsPage(onSelect: (slots, price, name) {
                        _goToConfirmScreen(
                          planName: name,
                          planPrice: price,
                        );
                      }),
                      _FamilyPlanPage(onSubscribe: () {
                        _goToConfirmScreen(
                          planName: 'Family Mode',
                          planPrice: '\$1.50 / month',
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  const _HeaderTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.bodyBold.copyWith(
              color: selected ? AppColors.green : AppColors.black,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Page 1: Buy Slots (unchanged)
// ────────────────────────────────────────────────────────────────
class _BuySlotsPage extends StatelessWidget {
  const _BuySlotsPage({required this.onSelect});
  final void Function(String slots, String price, String name) onSelect;

  @override
  Widget build(BuildContext context) {
    final offers = [
      {
        'slots': '+5 Document Slots',
        'price': '\$0.99',
        'name': '5 Extra Documents'
      },
      {
        'slots': '+10 Document Slots',
        'price': '\$1.49',
        'name': '10 Extra Documents'
      },
      {
        'slots': '+20 Document Slots',
        'price': '\$2.59',
        'name': '20 Extra Documents'
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        const SizedBox(height: 4),
        Text(
          'Purchase Extra Slots',
          style: AppTypography.bodyBold.copyWith(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add more document storage slots to your account anytime.',
          style: AppTypography.body.copyWith(
            fontSize: 13,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 16),
        ...offers.map((offer) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.darkGray.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      color: AppColors.green,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['slots']!,
                          style: AppTypography.bodyBold.copyWith(
                            fontSize: 15,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instantly unlock more document space',
                          style: AppTypography.body.copyWith(
                            fontSize: 12.5,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        offer['price']!,
                        style: AppTypography.bodyBold.copyWith(
                          fontSize: 15,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () => onSelect(
                          offer['slots']!,
                          offer['price']!,
                          offer['name']!,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          minimumSize: const Size(78, 34),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Buy',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Extra slots will be added to your account after successful payment.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              fontSize: 12.5,
              color: AppColors.darkGray.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Redesigned Page 2: Family Mode with Pattern Header
// ────────────────────────────────────────────────────────────────
class _FamilyPlanPage extends StatelessWidget {
  const _FamilyPlanPage({required this.onSubscribe});
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final features = [
      'Include everything in Free',
      'Manage multiple family members’ documents in one account',
      'Shared access with others',
      '+10 extra storage slots',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _PlanCard(
          color: AppColors.green,
          bannerText: 'Family Mode',
          headerIcon: Icons.family_restroom_rounded,
          priceText: '\$1.50 / month',
          subline: 'Up to 5 family members',
          buttonText: 'Subscribe',
          features: features,
          onPressed: onSubscribe,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Plan Card with Textured Gradient Header
// ────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.color,
    required this.bannerText,
    required this.headerIcon,
    required this.priceText,
    required this.subline,
    required this.buttonText,
    required this.onPressed,
    this.features,
  });

  final Color color;
  final String bannerText;
  final IconData headerIcon;
  final String priceText;
  final String subline;
  final String buttonText;
  final VoidCallback onPressed;
  final List<String>? features;

  @override
  Widget build(BuildContext context) {
    final darker = Color.lerp(color, Colors.black, 0.15)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.darkGray.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Header with pattern background
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.85),
                      color.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/bg_texture.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(headerIcon, size: 36, color: darker),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bannerText,
                        style: AppTypography.bodyBold.copyWith(
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subline,
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    priceText,
                    style: AppTypography.bodyBold.copyWith(
                      fontSize: 18,
                      color: AppColors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (features != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features!
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: AppColors.green,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.black,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
