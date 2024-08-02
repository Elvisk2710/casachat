import 'package:casachat/utils/animations.dart';
import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({Key? key}) : super(key: key);
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
              "Landlords \nHave To Wait To Be Texted By Students",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600
              ),
            ),
            Lottie.asset(Animations.landlord, fit: BoxFit.fill, height: 400),
          ],
        ),
      ),
    );
  }
}
