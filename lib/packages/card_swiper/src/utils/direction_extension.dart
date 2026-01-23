import 'package:flutter/widgets.dart';

import '../direction/card_swiper_direction.dart';

extension DirectionExtension on CardSwiperDirection {
  Axis get axis {
    if (this == CardSwiperDirection.left || this == CardSwiperDirection.right) {
      return Axis.horizontal;
    } else if (this == CardSwiperDirection.top ||
        this == CardSwiperDirection.bottom) {
      return Axis.vertical;
    } else if (this == CardSwiperDirection.none) {
      throw Exception('Direction is none');
    } else {
      if ((angle >= 45 && angle <= 135) || (angle >= 225 && angle <= 315)) {
        return Axis.vertical;
      } else {
        return Axis.horizontal;
      }
    }
  }
}
