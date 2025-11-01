import 'package:get/get.dart';

import '../modules/config/bindings/config_binding.dart';
import '../modules/config/views/config_view.dart';
import '../modules/exam_confirmation/bindings/exam_confirmation_binding.dart';
import '../modules/exam_confirmation/views/exam_confirmation_view.dart';
import '../modules/exam_room/bindings/exam_room_binding.dart';
import '../modules/exam_room/views/exam_room_view.dart';
import '../modules/feedback/bindings/feedback_binding.dart';
import '../modules/feedback/views/feedback_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/review/bindings/review_binding.dart';
import '../modules/review/views/review_view.dart';
import '../modules/student_confirmation/bindings/student_confirmation_binding.dart';
import '../modules/student_confirmation/views/student_confirmation_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.CONFIG,
      page: () => const ConfigView(),
      binding: ConfigBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_CONFIRMATION,
      page: () => const StudentConfirmationView(),
      binding: StudentConfirmationBinding(),
    ),
    GetPage(
      name: _Paths.EXAM_CONFIRMATION,
      page: () => const ExamConfirmationView(),
      binding: ExamConfirmationBinding(),
    ),
    GetPage(
      name: _Paths.EXAM_ROOM,
      page: () => const ExamRoomView(),
      binding: ExamRoomBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK,
      page: () => const FeedbackView(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: _Paths.REVIEW,
      page: () => const ReviewView(),
      binding: ReviewBinding(),
    ),
  ];
}
