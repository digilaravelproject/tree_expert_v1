// import 'dart:convert';
//
// import 'package:tree_expert/core/constent/api_constants.dart';
// import 'package:tree_expert/core/network/api_services.dart';
// import 'package:tree_expert/features/_init/data/model/intro_item_model.dart';
// import 'package:tree_expert/db/shared_pref_manager.dart';
// import 'package:get/get.dart';
//
// abstract class InitDataSource {
//   Future<List<IntroScreenModel>> getIntroScreens();
// }
//
// class InitDataSourceImpl extends InitDataSource {
//   final apiService = Get.find<ApiServices>();
//
//   @override
//   Future<List<IntroScreenModel>> getIntroScreens() async {
//     final response = await apiService.callGet(ApiConstants.appData);
//     if (response.status == false) {
//       throw Exception(response.message);
//     }
//     final data = InitAppModel.fromMap(response.data);
//     await SharedPrefManager().saveSettings(jsonEncode(response.data));
//     return data.introScreens;
//   }
// }
