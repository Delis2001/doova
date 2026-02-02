import 'package:doova/r.dart';
import 'package:doova/views/intro/get_started.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreenDefault extends StatefulWidget {
  const IntroScreenDefault({super.key});

  @override
  State<IntroScreenDefault> createState() => _IntroScreenDefaultState();
}

class _IntroScreenDefaultState extends State<IntroScreenDefault> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(builder: (context, constraints) {
         final screenHeight = constraints.maxHeight;
         final screenWidth = constraints.maxWidth;
        return   SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  buildPage(
                    imagePath:AssetsManager.introImage,
                    title: 'Manage your tasks',
                    description:
                        'You can easily manage all of your daily tasks in Doova for free',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  buildPage(
                    imagePath: AssetsManager.introImage2,
                    title: 'Create daily routine',
                    description:
                        'In Doova you can create your personalized routine to stay productive',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  buildPage(
                    imagePath: AssetsManager.introImage3,
                    title: 'Organize your tasks',
                    description:
                        'You can organize your daily tasks by adding your tasks into separate categories',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const StartScreen(),
                      ));
                    },
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_pageController.page == 2) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ));
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xff6F24E9),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      },)
    );
  }

  Widget buildPage({
    required String imagePath,
    required String title,
    required String description,
    required double screenWidth,
    required double screenHeight,
  }) {
    return SingleChildScrollView(
      child: ConstrainedBox(
         constraints: BoxConstraints(minHeight: screenHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: screenHeight * 0.35,
                width: screenWidth * 0.7,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.05),
              SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  dotHeight: screenHeight * 0.01,
                  dotWidth: screenWidth * 0.06,
                  activeDotColor: const Color(0xff6F24E9),
                  dotColor: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                title,
                textAlign: TextAlign.center,
                style:Theme.of(context).textTheme.titleLarge!.copyWith(fontSize:screenWidth * 0.06,)
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                description,
                textAlign: TextAlign.center,
                style:Theme.of(context).textTheme.titleMedium!.copyWith(fontSize:screenWidth * 0.045,)
              ),
              SizedBox(height: screenHeight * 0.06),
            ],
          ),
        ),
      ),
    );
  }
}
