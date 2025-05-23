import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedTitle extends StatelessWidget {
  String theTitle;
  TextStyle theStyle;
  AnimatedTitle(this.theTitle, this.theStyle);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [FadeEffect(),ScaleEffect()],
      child: Container(
        alignment: Alignment.center,
        child: Text(theTitle, style: theStyle, textAlign: TextAlign.center,),
      ),
    );
  }
}
