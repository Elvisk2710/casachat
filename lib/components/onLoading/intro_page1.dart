import 'package:casachat/utils/animations.dart';
import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({Key? key}) : super(key: key);
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
              "Direct Chat, Perfect Match: Your Dream Rental Awaits",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600
              ),
            ),
            Lottie.asset(Animations.chats, fit: BoxFit.fill, height: 400),
          ],
        ),
      ),
    );
  }
}
