import 'package:flutter/material.dart';
import '../constants.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({super.key});

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  final PageController _controller = PageController();
  int index = 0;

  final List<Map<String, dynamic>> slides = [
    {
      "title": "Create Quizzes",
      "desc": "Teachers can easily create and upload quizzes",
      "icon": Icons.create,
    },
    {
      "title": "Attempt Live",
      "desc": "Students can attempt quizzes in real-time",
      "icon": Icons.quiz,
    },
    {
      "title": "Track Progress",
      "desc": "View results and performance instantly",
      "icon": Icons.bar_chart,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      body: Column(
        children: [
          /// SLIDES
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => index = i),
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// ICON
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: qPrimary.withOpacity(0.1),
                        ),
                        child: Icon(
                          slides[i]['icon'],
                          size: 100,
                          color: qPrimary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// TITLE
                      Text(slides[i]['title'], style: qTitleStyle),

                      const SizedBox(height: 15),

                      /// DESC
                      Text(
                        slides[i]['desc'],
                        textAlign: TextAlign.center,
                        style: qSubTitleStyle,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// DOT INDICATORS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(5),
                height: 8,
                width: index == i ? 24 : 8,
                decoration: BoxDecoration(
                  color: index == i ? qPrimary : qGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.all(30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: qPrimary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed:
                  () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text(
                "GET STARTED",
                style: TextStyle(
                  color: qWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
