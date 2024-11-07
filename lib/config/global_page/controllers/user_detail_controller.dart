import 'package:get/get.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/data/user.dart';

class UserDetailController extends GetxController {
  UserDetailController({required this.tag});

  final String tag;

  late final User user;

  bool loading = true;

  @override
  void onInit() {
    super.onInit();

    GlobalData.userPageCount++;
  }

  @override
  void onClose() {
    super.onClose();

    GlobalData.userPageCount--;
  }

  void fetchData(int id) async{
    user = await GlobalFunction.getFutureUserByID(id);

    loading = false;
    update();
  }
}