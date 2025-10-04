import 'package:flutter/material.dart';
import 'package:romlerk/ui/screens/auth/auth_welcome_screen.dart';
import 'package:romlerk/ui/screens/onboarding/onboarding_screen2.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _scrollController = ScrollController();
  bool _isAtBottom = false;
  double _contentOpacity = 0.0; // for fade-in

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScroll);

    // Delay content appearance until after Hero animation (~1.8s)
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _contentOpacity = 1.0;
        });
      }
    });
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final atBottom = offset >= (max - 16);
    if (atBottom != _isAtBottom) {
      setState(() => _isAtBottom = atBottom);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 80),

                // Welcome with Hero
                Hero(
                  tag: 'welcomeText', // matches splash
                  child: Text(
                    'Welcome',
                    style: AppTypography.h1.copyWith(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Fade-in for all other content
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _contentOpacity,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        // Onboarding photo
                        Center(
                          child: Hero(
                            tag: 'onboardingImage',
                            child: Image.asset(
                              AppAssets.splashBg,
                              width: MediaQuery.of(context).size.width * 0.4,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Captions row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Simple',
                                  style: AppTypography.bodyBold
                                      .copyWith(color: AppColors.black),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'All Your Documents in One Place',
                                  style: AppTypography.bodyBold
                                      .copyWith(color: AppColors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Organize',
                                  style: AppTypography.bodyBold
                                      .copyWith(color: AppColors.black),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Scrollable section with paragraph + Next
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'នៅក្នុងប្រទេសកម្ពុជាមនុស្សជាច្រើននៅតែប្រឈមនឹងបញ្ហានៅពេលនិយាយអំពីការតាមដានឯកសារសំខាន់ៗដូចជាអត្តសញ្ញាណប័ណ្ណ លិខិតឆ្លងដែន ប័ណ្ណបើកបរ និងសំបុត្រកំណើត។ នៅក្នុងប្រទេសកម្ពុជាមនុស្សជាច្រើននៅតែប្រឈមនឹងបញ្ហានៅពេលនិយាយអំពីការតាមដានឯកសារសំខាន់ៗដូចជាអត្តសញ្ញាណប័ណ្ណ លិខិតឆ្លងដែន ប័ណ្ណបើកបរ និងសំបុត្រកំណើតនៅក្នុងប្រទេសកម្ពុជាមនុស្សជាច្រើននៅតែប្រឈមនឹងបញ្ហានៅពេលនិយាយអំពីការតាមដានឯកសារសំខាន់ៗដូចជាអត្តសញ្ញាណប័ណ្ណ លិខិតឆ្លងដែន ប័ណ្ណបើកបរ និងសំបុត្រកំណើតនៅក្នុងប្រទេសកម្ពុជាមនុស្សជាច្រើននៅតែប្រឈមនឹងបញ្ហានៅពេលនិយាយអំពីការតាមដានឯកសារសំខាន់ៗដូចជាអត្តសញ្ញាណប័ណ្ណ លិខិតឆ្លងដែន ប័ណ្ណបើកបរ និងសំបុត្រកំណើតនៅក្នុងប្រទេសកម្ពុជាមនុស្សជាច្រើននៅតែប្រឈមនឹងបញ្ហានៅពេលនិយាយអំពីការតាមដានឯកសារសំខាន់ៗដូចជាអត្តសញ្ញាណប័ណ្ណ លិខិតឆ្លងដែន ប័ណ្ណបើកបរ និងសំបុត្រកំណើតនៅក្នុងប្រទេសកម្ពុជាមនុស្សជាច្រើននៅតែប្រឈមនឹងបញ្ហានៅពេលនិយាយអំពីការតាមដានឯកសារសំខាន់ៗដូចជាអត្តសញ្ញាណប័ណ្ណ លិខិតឆ្លងដែន ប័ណ្ណបើកបរ និងសំបុត្រកំណើត...',
                                    style: AppTypography.bodyKh.copyWith(
                                      color: AppColors.black,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),

                                  const SizedBox(height: 24),

                                  // Next button at bottom-right
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: AnimatedOpacity(
                                      opacity: _isAtBottom ? 1.0 : 0.0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: IgnorePointer(
                                        ignoring: !_isAtBottom,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const OnboardingScreen2(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.green,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            textStyle: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          child: const Text('Next'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Logo top-left
            Positioned(
              top: -50,
              left: -20,
              child: Image.asset(
                AppAssets.logo,
                width: 200,
              ),
            ),

            // Skip to Sign up top-right
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthWelcomeScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text('Skip to Sign up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
