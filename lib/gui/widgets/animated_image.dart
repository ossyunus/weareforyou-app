import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedImage extends StatelessWidget {
  String theImage;
  double theWidth;
  AnimatedImage(this.theImage, this.theWidth);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: 1300.ms)],
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
         theImage,
          width: theWidth,
        ),
      ),
    );
  }
}
