import 'package:flutter/material.dart';
import '../constants.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> slides = [
    {
      "title": "Create Quizzes",
      "desc":
          "Empower teachers to design and deploy complex quizzes in minutes.",
      "icon": Icons.draw_rounded,
    },
    {
      "title": "Attempt Live",
      "desc":
          "Engage students with a real-time, interactive examination interface.",
      "icon": Icons.bolt_rounded,
    },
    {
      "title": "Track Progress",
      "desc": "Instant analytics and detailed feedback for every performance.",
      "icon": Icons.analytics_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: TextButton(
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    "Skip",
                    style: qSubTitleStyle.copyWith(
                      color: qPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// ANIMATED ICON CONTAINER
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: qWhite,
                            boxShadow: [
                              BoxShadow(
                                color: qPrimary.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Icon(
                            slides[i]['icon'],
                            size: 100,
                            color: qPrimary,
                          ),
                        ),

                        const SizedBox(height: 60),

                        Text(
                          slides[i]['title'],
                          style: qTitleStyle.copyWith(fontSize: 28),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            slides[i]['desc'],
                            textAlign: TextAlign.center,
                            style: qSubTitleStyle.copyWith(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              child: Column(
                children: [
                  /// DOT INDICATORS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == i ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentIndex == i
                                  ? qPrimary
                                  : qPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: qPrimary,
                      foregroundColor: qWhite,
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      if (_currentIndex == slides.length - 1) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentIndex == slides.length - 1
                          ? "GET STARTED"
                          : "NEXT",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
