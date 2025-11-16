import 'package:get/get.dart';
import '../Controller/calendorcontroller.dart';

class Intialbindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(() => CalendarController(),fenix: true);
  }
}