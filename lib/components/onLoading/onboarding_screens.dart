import 'package:casachat/screens/login.dart';
import 'package:casachat/utils/colors.dart';
import 'package:casachat/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingPage extends StatefulWidget {
  final Widget introPage1;
  final Widget introPage2;
  final Widget introPage3;

  const OnBoardingPage({
    Key? key,
    required this.introPage1,
    required this.introPage2,
    required this.introPage3,
  }) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  bool _hasSeenIntro = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setHasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);
  }

  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              widget.introPage1,
              widget.introPage2,
              widget.introPage3,
            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                ),
                if (onLastPage)
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      width: 120,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      await _setHasSeenIntro();
                      Helpers.permanentNavigator(
                        context,
                        LoginPage(),
                      );
                    },
                  )
                else
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      width: 120,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubicEmphasized,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
