import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppAssets {
  AppAssets._();

  /// Images
  static const String _imgPrefix = 'assets/images';
  static const String imgAppLogo = '$_imgPrefix/app_logo.jpg';
  static const String imgTitleLogo = '$_imgPrefix/app_title_logo.png';
  static const String imgBgApp = '$_imgPrefix/bg_app.jpg';
  static const String imgAppTitle = '$_imgPrefix/app_title.png';
  static const String imgBgScaffold = '$_imgPrefix/img_bg_scaffold.jpg';
  static const String imgBirthday = '$_imgPrefix/img_birthday.svg';

  static const String imgIntro1 = '$_imgPrefix/img_intro_page_1.png';
  static const String imgIntro2 = '$_imgPrefix/img_intro_page_2.jpg';
  static const String imgIntro3 = '$_imgPrefix/img_intro_page_3.jpg';
  static const String imgIntro4 = '$_imgPrefix/img_intro_page_4.jpeg';

  static const String bgWaves = '$_imgPrefix/bg_waves.svg';

  /// Icons
  static const String _iconPrefix = 'assets/icons';

  static const IconData backArrow = CupertinoIcons.arrow_left;
  static const IconData frontArrow = Icons.keyboard_arrow_right_rounded;
  static const IconData more = Icons.more_horiz_rounded;
  static const IconData home = CupertinoIcons.house_fill;
  static const String shop = '$_iconPrefix/ic_shop.svg';
  static const String icHearts = '$_iconPrefix/ic_heart.png';
  static const String icFilter = '$_iconPrefix/ic_filter.svg';
  static const String icGoogle = '$_iconPrefix/ic_google.svg';
  static const String cake = '$_iconPrefix/ic_birthday.png';
  static const String icWhatsapp = '$_iconPrefix/ic_whatsapp.svg';
  static const String edit = '$_iconPrefix/ic_edit.png';
  static const String forward = '$_iconPrefix/ic_forward.svg';
  static const String backword = '$_iconPrefix/ic_backword.svg';
  static const String svgIndianFlag = '$_iconPrefix/ic_indian_flag.svg';
  static const String bgCircleStroke = '$_iconPrefix/bg_circle_gap_stroke.svg';

  /// Animations
  static const String _animPrefix = 'assets/anim';
  static const String animLoader1 = '$_animPrefix/loader_spinner.json';
  static const String animWomen = '$_animPrefix/anim_1.json';
  static const String animMan = '$_animPrefix/anim_2.json';
}
