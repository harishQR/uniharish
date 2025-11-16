import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/calendorcontroller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CalendarController Ctr = Get.find();
  late ScrollController dayListController;
  late FixedExtentScrollController yearController;
  late ScrollController monthScrollController;

  final double monthItemWidth = 90;
  final double monthItemMargin = 12;
  late double monthTotalWidth;

  @override
  void initState() {
    super.initState();

    Ctr.setToday();

    monthTotalWidth = monthItemWidth + monthItemMargin;
    monthScrollController = ScrollController();
    yearController = Ctr.yearList.isNotEmpty
        ? FixedExtentScrollController(
        initialItem: Ctr.yearList.indexOf(Ctr.selectedYear.value))
        : FixedExtentScrollController();

    dayListController = Ctr.dayScrollController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Ctr.scrollToSelectedDay();
      scrollMonthToSelected();
    });
  }

  void scrollMonthToSelected() {
    final size = MediaQuery.of(context).size;
    if (monthScrollController.hasClients && Ctr.yearList.isNotEmpty) {
      int yearIndex = Ctr.yearList.indexOf(Ctr.selectedYear.value);
      int selectedMonthIndex = Ctr.selectedMonth.value; // 1..12
      int totalIndex = yearIndex * 13 + selectedMonthIndex;

      double offset =
          (totalIndex * monthTotalWidth) - (size.width / 2) + (monthItemWidth / 2) + 60;

      monthScrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    monthScrollController.dispose();
    dayListController.dispose();
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
            // TOP BAR: YEAR + MONTH SELECTORS
            Container(
              height: size.height * 0.09,
              padding:  EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Row(
                children: [
                  // YEAR SELECTOR
                  Container(
                    width: 69,
                    height: 80, // limit height so it doesn't cross SafeArea
                    child: ClipRect(
                      child: ListWheelScrollView.useDelegate(
                        controller: yearController,
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.002,
                        clipBehavior: Clip.hardEdge, // enforce clipping
                        useMagnifier: true,
                        magnification: 1.0,
                        onSelectedItemChanged: (index) {
                          final year = Ctr.yearList[index];
                          if (year != Ctr.selectedYear.value) {
                            Ctr.changeYear(year);
                            final offset = 13 * index * monthTotalWidth;
                            if (monthScrollController.hasClients) {
                              monthScrollController.animateTo(offset,
                                  duration: const Duration(milliseconds: 300),
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
                                    color: selected ? Colors.black : Colors.grey,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            });
                          },
                          childCount: Ctr.yearList.length,
                        ),
                      ),
                    ),
                  ),


                  // MONTH SELECTOR
                  Expanded(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (!monthScrollController.hasClients) return true;

                            double offset = monthScrollController.offset;
                            double arrowCenter = size.width / 2;

                            int totalItemIndex =
                            ((offset + arrowCenter - monthItemWidth / 1-20) /
                                monthTotalWidth)
                                .round();

                            int yearIndex = totalItemIndex ~/ 13;
                            int innerIndex = totalItemIndex % 13;

                            if (yearIndex >= Ctr.yearList.length) {
                              yearIndex = Ctr.yearList.length - 1;
                            }
                            if (innerIndex > 12) innerIndex = 12;

                            int selectedYear = Ctr.yearList[yearIndex];
                            int selectedMonth =
                            innerIndex == 0 ? 1 : innerIndex; // 0 = inline year

                            if (selectedMonth != Ctr.selectedMonth.value) {
                              Ctr.changeMonth(selectedMonth);
                            }
                            if (selectedYear != Ctr.selectedYear.value) {
                              Ctr.changeYear(selectedYear);

                              yearController.animateToItem(
                                yearIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }

                            return true;
                          },
                          child: ListView.builder(
                            controller: monthScrollController,
                            scrollDirection: Axis.horizontal,
                            padding:  EdgeInsets.symmetric(horizontal: 40),
                            physics:  BouncingScrollPhysics(),
                            itemCount: Ctr.yearList.length * 13,
                            itemBuilder: (context, index) {
                              int yearBlock = index ~/ 13;
                              int innerIndex = index % 13;
                              final inlineYear = Ctr.yearList[yearBlock];
                              return Obx(() {
                                if (innerIndex == 0) {
                                  bool selected =
                                      inlineYear == Ctr.selectedYear.value;
                                  return Container(
                                    width: monthItemWidth,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: monthItemMargin / 2,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      inlineYear.toString(),
                                      style: TextStyle(
                                        fontSize: selected ? 18 : 16,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selected
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                } else {
                                  int monthIndex = innerIndex - 1;

                                  bool selected = (monthIndex + 1) ==
                                      Ctr.selectedMonth.value &&
                                      inlineYear == Ctr.selectedYear.value;

                                  return Container(
                                    width: monthItemWidth,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: monthItemMargin / 2,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      Ctr.monthNames[monthIndex],
                                      style: TextStyle(
                                        fontSize: selected ? 18 : 16,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selected
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ),

                        // ARROW IN CENTER
                        Positioned(
                          bottom: -23,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: Icon(
                              Icons.arrow_drop_up,
                              size: 55,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT: SIDEBAR + DAY LIST + CHECKBOXES
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SIDEBAR: Days List
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: size.width * 0.18,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.green],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                topLeft: Radius.circular(5))),
                        child: Container(
                          color: Colors.grey.shade100,
                          child: Obx(() => Column(
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                Ctr.dayName(
                                    Ctr.selectedYear.value,
                                    Ctr.selectedMonth.value,
                                    Ctr.selectedDate.value),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  controller: dayListController,
                                  itemCount: Ctr.daysInMonth,
                                  itemBuilder: (context, index) {
                                    final day = index + 1; // day number

                                    return GestureDetector(
                                      onTap: () => Ctr.selectedDate.value = day,
                                      child: Obx(() {
                                        // Define the selected day here
                                        bool isSelectedDay = day == Ctr.selectedDate.value;

                                        bool isWeekHighlighted = false;
                                        if (Ctr.weekView.value) {
                                          int sel = Ctr.selectedDate.value;
                                          int start = sel - ((sel - 1) % 7);
                                          int end = start + 6;
                                          if (day >= start && day <= end) {
                                            isWeekHighlighted = true;
                                          }
                                        }

                                        bool isMonthHighlighted = Ctr.monthView.value;

                                        Color bgColor = isMonthHighlighted
                                            ? Colors.yellow.withOpacity(0.4)
                                            : isWeekHighlighted
                                            ? Colors.blue.withOpacity(0.3)
                                            : isSelectedDay && Ctr.dayView.value
                                            ? Colors.green.withOpacity(0.4)
                                            : Colors.transparent;

                                        Color borderColor =
                                        isSelectedDay && Ctr.dayView.value ? Colors.black : Colors.transparent;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                          padding: const EdgeInsets.all(12),
                                          height: 64, // important for correct scroll-to-position
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            border: Border.all(color: borderColor, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              day.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )),
                        ),
                      ),
                      Positioned(
                        top: 62,
                        right: -18,
                        child: Icon(Icons.play_arrow, size: 30, color: Colors.green),
                      )
                    ],
                  ),

                  const SizedBox(width: 16),

                  // DAY / WEEK / MONTH CHECKBOXES
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          circleViewButton("day", Ctr.dayView, Ctr),
                          const SizedBox(width: 12),
                          circleViewButton("week", Ctr.weekView, Ctr),
                          const SizedBox(width: 12),
                          circleViewButton("month", Ctr.monthView, Ctr),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget circleViewButton(String type, RxBool isActive, CalendarController ctr) {
  return Obx(() => GestureDetector(
    onTap: () => ctr.changeView(type),
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isActive.value ? Colors.black : Colors.grey, width: 2),
        color: isActive.value ? Colors.black : Colors.white,
      ),
      child: Center(
          child: Text(type.substring(0, 1).toUpperCase(),
              style: TextStyle(
                  color: isActive.value ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold))),
    ),
  ));
}
