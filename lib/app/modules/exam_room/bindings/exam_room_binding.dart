import 'package:get/get.dart';

import '../controllers/exam_room_controller.dart';

class ExamRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamRoomController>(
      () => ExamRoomController(),
    );
  }
}
