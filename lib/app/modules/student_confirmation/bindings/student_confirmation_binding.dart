import 'package:get/get.dart';

import '../controllers/student_confirmation_controller.dart';

class StudentConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentConfirmationController>(
      () => StudentConfirmationController(),
    );
  }
}
