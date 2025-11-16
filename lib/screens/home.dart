import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/calendorcontroller.dart';
import 'package:intl/intl.dart';
import '../widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CalendarController Ctr = Get.find();

  @override
  void initState() {
    super.initState();
    Ctr.setToday();
    Ctr.monthTotalWidth = Ctr.monthItemWidth + Ctr.monthItemMargin;
    Ctr.monthScrollController = ScrollController();
    Ctr.yearController = Ctr.yearList.isNotEmpty
        ? FixedExtentScrollController(
        initialItem: Ctr.yearList.indexOf(Ctr.selectedYear.value))
        : FixedExtentScrollController();
    Ctr.dayListController = Ctr.dayScrollController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Ctr.scrollToSelectedDay();
      Ctr.scrollMonthToSelected(context);
      Ctr.scrollWeekToSelected();
    });
  }


  @override
  void dispose() {
    Ctr.yearController.dispose();
    Ctr.monthScrollController.dispose();
    Ctr.dayListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // year & month picker
            Container(
              height: size.height * 0.09,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.grey.shade200
              ,border: Border.all(color:Colors.grey.shade400 )
              ),
              child: Row(
                children: [
                  // year scroll
                  Container(
                    width: 100,
                    height: 80,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.unfold_more,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: ListWheelScrollView.useDelegate(
                                  controller: Ctr.yearController,
                                  itemExtent: 40,
                                  physics: FixedExtentScrollPhysics(),
                                  perspective: 0.01,
                                  diameterRatio: 1.2,
                                  useMagnifier: true,
                                  magnification: 1.1,
                                  onSelectedItemChanged: (index) {
                                    final year = Ctr.yearList[index];
                                    if (year != Ctr.selectedYear.value) {
                                      Ctr.changeYear(year);
                                      final offset = 13 * index * Ctr.monthTotalWidth;
                                      if (Ctr.monthScrollController.hasClients) {
                                        Ctr.monthScrollController.animateTo(offset,
                                            duration: Duration(milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      }
                                    }
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      final year = Ctr.yearList[index];
                                      return Obx(() {
                                        bool selected = year == Ctr.selectedYear.value;
                                        return Center(
                                          child: Text(
                                            year.toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: selected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color:
                                              selected ? Colors.black : Colors.grey,
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                    childCount: Ctr.yearList.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // month scroll
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (!Ctr.monthScrollController.hasClients) return true;

                            double offset = Ctr.monthScrollController.offset;
                            double arrowCenter = size.width / 2;

                            int totalItemIndex =
                            ((offset + arrowCenter - Ctr.monthItemWidth / 1 - 20) /
                                Ctr.monthTotalWidth)
                                .round();

                            int yearIndex = totalItemIndex ~/ 13;
                            int innerIndex = totalItemIndex % 13;

                            if (yearIndex >= Ctr.yearList.length)
                              yearIndex = Ctr.yearList.length - 1;
                            if (innerIndex > 12) innerIndex = 12;

                            int selectedYear = Ctr.yearList[yearIndex];
                            int selectedMonth = innerIndex == 0 ? 1 : innerIndex;

                            if (selectedMonth != Ctr.selectedMonth.value) {
                              Ctr.changeMonth(selectedMonth);
                            }
                            if (selectedYear != Ctr.selectedYear.value) {
                              Ctr.changeYear(selectedYear);
                              Ctr.yearController.animateToItem(
                                yearIndex,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            return true;
                          },
                          child: ListView.builder(
                            controller: Ctr.monthScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            physics: BouncingScrollPhysics(),
                            itemCount: Ctr.yearList.length * 13,
                            itemBuilder: (context, index) {
                              int yearBlock = index ~/ 13;
                              int innerIndex = index % 13;
                              final inlineYear = Ctr.yearList[yearBlock];
                              return Obx(() {
                                if (innerIndex == 0) {
                                  bool selected = inlineYear == Ctr.selectedYear.value;
                                  return Container(
                                    width: Ctr.monthItemWidth,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: Ctr.monthItemMargin / 2,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      inlineYear.toString(),
                                      style: TextStyle(
                                        fontSize: selected ? 18 : 16,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  );
                                } else {
                                  int monthIndex = innerIndex - 1;
                                  bool selected = (monthIndex + 1) ==
                                      Ctr.selectedMonth.value &&
                                      inlineYear == Ctr.selectedYear.value;

                                  return Container(
                                    width: Ctr.monthItemWidth,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: Ctr.monthItemMargin / 2,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      Ctr.monthNames[monthIndex].substring(0, 3),
                                      style: TextStyle(
                                        fontSize: selected ? 18 : 14,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ),
                        Positioned(
                          bottom: -25,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Icon(Icons.arrow_drop_up, size: 55, color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // calendar events
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // day column
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: size.width * 0.18,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        child: Container(
                          color: Colors.grey.shade200,
                          child: Obx(() {
                            List<DateTime> days = Ctr.weekView.value
                                ? Ctr.getDaysForWeekView()
                                : List.generate(
                              Ctr.daysInMonth,
                                  (i) => DateTime(
                                  Ctr.selectedYear.value,
                                  Ctr.selectedMonth.value,
                                  i + 1),
                            );
                            if (Ctr.weekView.value) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Ctr.scrollWeekToSelected();
                              });
                            }
                            return Column(
                              children: [
                                SizedBox(height: 8),
                                if (Ctr.weekView.value)
                                  IconButton(
                                    icon: Icon(Icons.arrow_circle_up,
                                        color: Colors.purple, size: 40),
                                    onPressed: () {
                                      Ctr.previousWeek();
                                      WidgetsBinding.instance.addPostFrameCallback(
                                              (_) => Ctr.scrollWeekToSelected());
                                    },
                                  ),
                                if (!Ctr.weekView.value)
                                  Text(
                                    Ctr.dayName(
                                      Ctr.selectedYear.value,
                                      Ctr.selectedMonth.value,
                                      Ctr.selectedDate.value,
                                    ),
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                if (!Ctr.weekView.value) SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    controller: Ctr.dayListController,
                                    itemCount: days.length,
                                    itemBuilder: (context, index) {
                                      final day = days[index];
                                      bool isCurrentMonth = Ctr.isCurrentMonth(day);
                                      return Obx(() {
                                        bool isSelectedDay = day.day == Ctr.selectedDate.value &&
                                            day.month == Ctr.selectedMonth.value &&
                                            day.year == Ctr.selectedYear.value;
                                        // Background color logic
                                        Color bgColor = Colors.transparent;
                                        if (Ctr.weekView.value) {
                                          bgColor = Colors.blue.withOpacity(0.3);
                                        } else if (Ctr.dayView.value && isSelectedDay) {
                                          bgColor = Colors.green.withOpacity(0.4); // selected day in day view
                                        } else if (Ctr.monthView.value) {
                                          if (isSelectedDay) {
                                            bgColor = Colors.orange.withOpacity(0.5); // selected day in month view
                                          } else if (isCurrentMonth) {
                                            bgColor = Colors.yellow.withOpacity(0.3); // other days in month
                                          }
                                        }
                                        return GestureDetector(
                                          onTap: () {
                                            Ctr.changeDate(day.year, day.month, day.day);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                            padding: EdgeInsets.all(12),
                                            height: 64,
                                            decoration: BoxDecoration(
                                              color: bgColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                day.day.toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isCurrentMonth ? Colors.black : Colors.purple,
                                                  fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 3),
                                if (Ctr.weekView.value)
                                  IconButton(
                                    icon: Icon(Icons.arrow_circle_down,
                                        color: Colors.purple, size: 40),
                                    onPressed: () {
                                      Ctr.nextWeek();
                                      WidgetsBinding.instance.addPostFrameCallback(
                                              (_) => Ctr.scrollWeekToSelected());
                                    },
                                  ),
                                if (Ctr.weekView.value) SizedBox(height: 100),
                              ],
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        top: 62,
                        right: -18,
                        child: Icon(Icons.play_arrow, size: 30, color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  // right side: events
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            circleViewButton("day", Ctr.dayView, Ctr),
                            SizedBox(width: 12),
                            circleViewButton("week", Ctr.weekView, Ctr),
                            SizedBox(width: 12),
                            circleViewButton("month", Ctr.monthView, Ctr),
                          ],
                        ),
                        SizedBox(height: 16),
                        Obx(() => Container(
                          width: double.infinity,
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Colors.grey.shade200,
                          child: Text(
                            Ctr.eventHeader.value,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )),
                        SizedBox(height: 8),
                        Expanded(
                          child: Obx(() {
                            final events = Ctr.dayView.value
                                ? Ctr.eventsForSelectedDay
                                : Ctr.eventsForCurrentSelection;
                            if (events.isEmpty) {
                              return Center(
                                child: Container(
                                  width: 250,
                                  height: 300,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      textWidthBasis: TextWidthBasis.parent,
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                        children: [
                                          TextSpan(text: "Events only available from "),
                                          TextSpan(
                                            text: "01/01/2025",
                                            style: TextStyle(color: Colors.purple),
                                          ),
                                          TextSpan(text: " to "),
                                          TextSpan(
                                            text: "01/01/2026",
                                            style: TextStyle(color: Colors.purple),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                String formattedDate =
                                DateFormat('dd MMM yyyy').format(event.startDate);

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                  elevation: 4,
                                  shadowColor: Colors.green,
                                  child: ListTile(
                                    onTap: () => showEventPopup(context, events, index),
                                    title: Text(
                                      event.title,
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formattedDate,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    trailing: Text(
                                      "View",
                                      style: TextStyle(
                                        color: Colors.green.shade300,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,

                                      ),
                                    ),
                                  ),
                                );

                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





