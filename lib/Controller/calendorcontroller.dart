import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/eventmodel.dart';

class CalendarController extends GetxController {
  late ScrollController dayListController;
  late FixedExtentScrollController yearController;
  late ScrollController monthScrollController;
  final double monthItemWidth = 90;
  final double monthItemMargin = 12;
  late double monthTotalWidth;

  // selected date
  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedDate = DateTime.now().day.obs;

  // views
  var dayView = true.obs;
  var weekView = false.obs;
  var monthView = false.obs;

  // scroll controller for day list
  late ScrollController dayScrollController;

  // event data
  var eventHeader = "".obs;
  var eventsForCurrentSelection = <Event>[].obs;

  // all events (mock)
  List<Event> allEvents = MockEvents.generateMockEvents();

  @override
  void onInit() {
    super.onInit();
    dayScrollController = ScrollController();
    updateEventData();
  }
  void scrollMonthToSelected(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!monthScrollController.hasClients || yearList.isEmpty) return;
    int yearIndex = yearList.indexOf(selectedYear.value);
    int selectedMonthIndex = selectedMonth.value;
    int totalIndex = yearIndex * 13 + selectedMonthIndex;
    double offset =
        (totalIndex * monthTotalWidth) - (size.width / 2) + (monthItemWidth / 2) + 100;
    monthScrollController.jumpTo(offset);
  }
  void scrollWeekToSelected() {
    if (!dayListController.hasClients || !weekView.value) return;
    final days = getDaysForWeekView();
    final selectedIndex = days.indexWhere((d) =>
    d.day == selectedDate.value &&
        d.month == selectedMonth.value &&
        d.year == selectedYear.value);
    if (selectedIndex == -1) return;
    final itemHeight = 64 + 8;
    double offset = selectedIndex * itemHeight.toDouble() - itemHeight;
    if (offset < 0) offset = 0;
    dayListController.jumpTo(offset);
  }


  //  view / date changes
  void changeView(String type) {
    dayView.value = type == "day";
    weekView.value = type == "week";
    monthView.value = type == "month";
    updateEventData();
  }

  void changeDate(int year, int month, int day) {
    selectedYear.value = year;
    selectedMonth.value = month;
    selectedDate.value = day;
    scrollToSelectedDay();
    updateEventData();
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    // ensure date is valid
    if (selectedDate.value > daysInMonth) selectedDate.value = daysInMonth;
    updateEventData();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    // ensure date is valid
    if (selectedDate.value > daysInMonth) selectedDate.value = daysInMonth;
    updateEventData();
  }

  void setToday() {
    DateTime now = DateTime.now();
    selectedYear.value = now.year;
    selectedMonth.value = now.month;
    selectedDate.value = now.day;
    scrollToSelectedDay();
    updateEventData();
  }

  //  event filtering
  void updateEventData() {
    DateTime selected =
    DateTime(selectedYear.value, selectedMonth.value, selectedDate.value);

    if (dayView.value) {
      eventHeader.value = DateFormat('dd MMM yyyy').format(selected);
      eventsForCurrentSelection.value = eventsForSelectedDay;
    } else if (weekView.value) {
      DateTime startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      eventHeader.value =
      "${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM yyyy').format(endOfWeek)}";

      eventsForCurrentSelection.value = allEvents
          .where((e) => !(e.endDate.isBefore(startOfWeek) || e.startDate.isAfter(endOfWeek)))
          .toList();
    } else if (monthView.value) {
      DateTime firstDay = DateTime(selected.year, selected.month, 1);
      DateTime lastDay = DateTime(selected.year, selected.month + 1, 0);

      eventHeader.value = DateFormat('MMMM yyyy').format(selected);

      eventsForCurrentSelection.value = allEvents
          .where((e) => !(e.endDate.isBefore(firstDay) || e.startDate.isAfter(lastDay)))
          .toList();
    }
  }

  List<Event> get eventsForSelectedDay {
    DateTime selected =
    DateTime(selectedYear.value, selectedMonth.value, selectedDate.value);

    return allEvents.where((e) {
      return !selected.isBefore(e.startDate) && !selected.isAfter(e.endDate);
    }).toList();
  }

  //  week navigation
  void previousWeek() {
    DateTime current = DateTime(selectedYear.value, selectedMonth.value, selectedDate.value);
    DateTime newDate = current.subtract(Duration(days: 7));
    selectedYear.value = newDate.year;
    selectedMonth.value = newDate.month;
    selectedDate.value = newDate.day;
    updateEventData();
    scrollToSelectedDay();
  }

  void nextWeek() {
    DateTime current = DateTime(selectedYear.value, selectedMonth.value, selectedDate.value);
    DateTime newDate = current.add(Duration(days: 7));
    selectedYear.value = newDate.year;
    selectedMonth.value = newDate.month;
    selectedDate.value = newDate.day;
    updateEventData();
    scrollToSelectedDay();
  }

  // helper methods :
  List<int> get yearList => List.generate(20, (i) => 2020 + i);

  List<String> get monthNames =>
      List.generate(12, (i) => DateFormat('MMMM').format(DateTime(0, i + 1)));

  int get daysInMonth => DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;

  String dayName(int year, int month, int day) {
    return DateFormat('EEE').format(DateTime(year, month, day));
  }

  //  scroll to selected day
  void scrollToSelectedDay() {
    if (!dayScrollController.hasClients) return;

    double containerHeight = 64;
    double topMargin = 4;
    double arrowHeight = 55;
    double arrowOffset = arrowHeight / 2;

    double offset =
        (selectedDate.value - 1) * (containerHeight + topMargin * 2) - arrowOffset + (containerHeight / 2);

    if (offset < 0) offset = 0;

    dayScrollController.jumpTo(offset);
  }

  //  week view helper
  List<DateTime> getDaysForWeekView() {
    DateTime selected = DateTime(selectedYear.value, selectedMonth.value, selectedDate.value);
    DateTime startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  bool isCurrentMonth(DateTime day) {
    return day.month == selectedMonth.value;
  }
}

//  event popup
void showEventPopup(BuildContext context, List<Event> events, int index) {
  final selectedDate = events[index].startDate;

  final dayEvents = events.where((e) {
    DateTime eventStart = e.startDate;
    DateTime eventEnd = e.endDate;
    return !selectedDate.isBefore(eventStart) && !selectedDate.isAfter(eventEnd);
  }).toList();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: dayEvents.length > 1 ? 400 : 250,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Events on ${DateFormat('dd MMM yyyy').format(selectedDate)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: dayEvents.length,
                itemBuilder: (context, i) {
                  final event = dayEvents[i];
                  // check if event spans multiple days
                  final isMultiDay = event.startDate.day != event.endDate.day ||
                      event.startDate.month != event.endDate.month ||
                      event.startDate.year != event.endDate.year;
                  final duration = isMultiDay
                      ? "${DateFormat('dd MMM yyyy').format(event.startDate)} - ${DateFormat('dd MMM yyyy').format(event.endDate)}"
                      : "${DateFormat('h:mm a').format(event.startDate)} - ${DateFormat('h:mm a').format(event.endDate)}";
                  return Card(
                    color: Colors.white,
                    shadowColor: Colors.green,
                    elevation: 8,
                    child: ListTile(
                      title: Text(
                        event.title,
                        style: TextStyle(
                            color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(duration,
                              style: TextStyle(
                                  color: Colors.black, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(event.description, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
