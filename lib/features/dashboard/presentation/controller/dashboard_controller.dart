import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/features/dashboard/data/model/btm_nav_model.dart';
import 'package:tree_expert/features/profile/presentation/page/profile_page.dart';
import 'package:tree_expert/features/trees/presentation/page/tree_list_page.dart';

import '../page/home_page.dart';

class DashboardController extends GetxController {
  var currentPage = 0.obs;

  var pageController = PageController();

  var screenList = <Widget>[
    HomePage(),
    TreeDetailsPage(),
    VolunteerPage(),
    ProfilePage(),
  ];

  changePage(int index) {
    pageController.jumpToPage(index);
  }

  List<BtmNavModel> navList(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return [
      BtmNavModel(
        title: "Home",
        icon: CupertinoIcons.home,
        selectedIcon: CupertinoIcons.house_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "Geo Tags",
        icon: Icons.my_location_rounded,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "Trees",
        icon: CupertinoIcons.heart,
        selectedIcon: CupertinoIcons.heart_fill,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
      BtmNavModel(
        title: "Profile",
        icon: CupertinoIcons.person_alt_circle,
        selectedColor: theme.primary,
        unselectedColor: theme.onSurfaceVariant,
      ),
    ];
  }
}

class VolunteerPage extends StatelessWidget {
  const VolunteerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
