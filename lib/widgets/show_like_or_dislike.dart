import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:dating_app/utils/colors.dart';
import 'package:flutter/material.dart';

class ShowLikeOrDislike extends StatelessWidget {
  // Variables
  final SwiperPosition position;

  const ShowLikeOrDislike({Key? key, required this.position}) : super(key: key);

  Widget _likedUser() {
    return Positioned(
      top: 50,
      left: 20,
      child: RotationTransition(
        turns: const AlwaysStoppedAnimation(-15 / 360),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lightGrassGreenColor,
          ),
          child: const Icon(Icons.favorite,
              size: 50, color: grassGreenColor, semanticLabel: 'LIKE'),
        ),
      ),
    );
  }

  Widget _dislikedUser() {
    return Positioned(
      top: 50,
      right: 20,
      child: RotationTransition(
        turns: const AlwaysStoppedAnimation(15 / 360),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: lightRedColor,
          ),
          child: const Icon(Icons.close,
              size: 50, color: redColor, semanticLabel: 'DISLIKE'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Positioned(child: Container());

    /// Control swipe position
    switch (position) {
      case SwiperPosition.None:
        break;
      case SwiperPosition.Left:
        content = _dislikedUser();
        break;
      case SwiperPosition.Right:
        content = _likedUser();
        break;
    }
    return content;
  }
}
