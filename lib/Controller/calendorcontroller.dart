import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarController extends GetxController {
  // -------------------------------
  // SELECTED VALUES
  // -------------------------------
  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedDate = DateTime.now().day.obs;

  var dayView = true.obs;
  var weekView = false.obs;
  var monthView = false.obs;

  // -------------------------------
  // SCROLL CONTROLLERS
  // -------------------------------
  late ScrollController dayScrollController;

  // -------------------------------
  // INITIALIZATION
  // -------------------------------
  @override
  void onInit() {
    super.onInit();
    dayScrollController = ScrollController();
    // Scroll to today after first frame
    Future.delayed(Duration(milliseconds: 50), scrollToSelectedDay);
  }

  // -------------------------------
  // SET TODAY
  // -------------------------------
  void setToday() {
    DateTime now = DateTime.now();
    selectedYear.value = now.year;
    selectedMonth.value = now.month;
    selectedDate.value = now.day;

    scrollToSelectedDay();
  }

  // -------------------------------
  // VIEWS CHANGER
  // -------------------------------
  void changeView(String type) {
    dayView.value = type == "day";
    weekView.value = type == "week";
    monthView.value = type == "month";
  }

  // -------------------------------
  // YEAR + MONTH HELPERS
  // -------------------------------
  List<int> get yearList => List.generate(20, (i) => 2020 + i);

  List<String> get monthNames =>
      List.generate(12, (i) => DateFormat('MMMM').format(DateTime(0, i + 1)));

  void changeYear(int year) {
    selectedYear.value = year;
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
  }

  // -------------------------------
  // DAYS IN SELECTED MONTH
  // -------------------------------
  int get daysInMonth =>
      DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;

  // -------------------------------
  // DAY NAME (Mon, Tue, etc.)
  // -------------------------------
  String dayName(int year, int month, int day) {
    return DateFormat('EEE').format(DateTime(year, month, day));
  }

  // -------------------------------
  // AUTO SCROLL TO SELECTED DAY
  // -------------------------------
  void scrollToSelectedDay() {
    if (!dayScrollController.hasClients) return;

    // Each day item total height (padding + margin + container height)
    double containerHeight = 64; // adjust this to match your Container's height
    double topMargin = 4; // vertical margin
    double arrowHeight = 55; // size of arrow
    double arrowOffset = arrowHeight / 2; // center arrow

    // Total offset = day index * (containerHeight + margin)
    double offset = (selectedDate.value - 1) * (containerHeight + topMargin * 2) - arrowOffset + (containerHeight / 2);

    if (offset < 0) offset = 0;

    dayScrollController.jumpTo(offset);
  }

}
