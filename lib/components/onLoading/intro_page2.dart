import 'package:casachat/utils/animations.dart';
import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Students Can Text Whichever Landlord They Please",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600
              ),
            ),
            Lottie.asset(Animations.students, fit: BoxFit.fill, height: 400),
          ],
        ),
      ),
    );
  }
}
