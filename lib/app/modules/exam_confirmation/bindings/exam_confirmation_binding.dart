import 'package:get/get.dart';

import '../controllers/exam_confirmation_controller.dart';

class ExamConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamConfirmationController>(
      () => ExamConfirmationController(),
    );
  }
}
