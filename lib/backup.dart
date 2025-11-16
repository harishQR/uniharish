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
      initialItem: Ctr.yearList.indexOf(Ctr.selectedYear.value),
    )
        : FixedExtentScrollController();
  }

  @override
  void dispose() {
    yearController.dispose();
    monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (monthScrollController.hasClients && Ctr.yearList.isNotEmpty) {
        int yearIndex = Ctr.yearList.indexOf(Ctr.selectedYear.value);
        int selectedMonthIndex = Ctr.selectedMonth.value; // 1..12

        int totalIndex = yearIndex * 13 + selectedMonthIndex;

        double offset =
            (totalIndex * monthTotalWidth) -
                (size.width / 2) +
                (monthItemWidth / 2+60) +
                20;

        monthScrollController.jumpTo(offset);
      }
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // TOP BAR
              Container(
                height: size.height * 0.09,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.grey.shade200),
                child: Row(
                  children: [
                    // YEAR SELECTOR
                    SizedBox(
                      width: 69,
                      child: ListWheelScrollView.useDelegate(
                        controller: yearController,
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.002,
                        renderChildrenOutsideViewport: true,
                        clipBehavior: Clip.none,
                        useMagnifier: true,
                        magnification: 1.0,
                        overAndUnderCenterOpacity: 1.0,
                        squeeze: 1.0,
                        onSelectedItemChanged: (index) {
                          final selectedYear = Ctr.yearList[index];
                          if (selectedYear != Ctr.selectedYear.value) {
                            Ctr.changeYear(selectedYear);

                            final offset = 13 * index * monthTotalWidth;
                            if (monthScrollController.hasClients) {
                              monthScrollController.animateTo(
                                offset,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final year = Ctr.yearList[index];
                            return Obx(() {
                              final selected = year == Ctr.selectedYear.value;
                              return Center(
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.0,
                                    color: selected ? Colors.black : Colors.grey,
                                    fontWeight:
                                    selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            });
                          },
                          childCount: Ctr.yearList.length,
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

              // LEFT SIDEBAR + CHECKBOXES
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SIDEBAR
                  Stack(
                    clipBehavior: Clip.none,
                    children: [ Container(
                      height: size.height,
                      width: size.width * 0.18,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.green],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                        ),
                      ),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Obx(
                              () => Column(
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                Ctr.dayName(
                                  Ctr.selectedYear.value,
                                  Ctr.selectedMonth.value,
                                  Ctr.selectedDate.value,
                                ),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: Ctr.daysInMonth,
                                  itemBuilder: (context, index) {
                                    final day = index + 1;

                                    return GestureDetector(
                                      onTap: () => Ctr.selectedDate.value = day,
                                      child: Obx(() {
                                        bool isSelectedDay =
                                            day == Ctr.selectedDate.value;
                                        bool isWeekHighlighted = false;

                                        if (Ctr.weekView.value) {
                                          int sel = Ctr.selectedDate.value;
                                          int start = sel - ((sel - 1) % 7);
                                          int end = start + 6;
                                          if (day >= start && day <= end) {
                                            isWeekHighlighted = true;
                                          }
                                        }

                                        bool isMonthHighlighted =
                                            Ctr.monthView.value;

                                        Color bgColor =
                                        isMonthHighlighted
                                            ? Colors.yellow.withOpacity(0.4)
                                            : isWeekHighlighted
                                            ? Colors.blue.withOpacity(0.3)
                                            : isSelectedDay &&
                                            Ctr.dayView.value
                                            ? Colors.green
                                            .withOpacity(0.4)
                                            : Colors.transparent;

                                        Color borderColor =
                                        isSelectedDay && Ctr.dayView.value
                                            ? Colors.black
                                            : Colors.transparent;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 6),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            border: Border.all(
                                                color: borderColor, width: 2),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              day.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelectedDay
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
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
                          ),
                        ),
                      ),
                    ),
                      Positioned(
                        top:62,
                        right: -18,
                        child: Icon(Icons.play_arrow,size: 30,color: Colors.green,),)
                    ],
                  ),
                  SizedBox(width: 16),
                  // DAY / WEEK / MONTH CHECKBOXES
                  Column(
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
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget circleViewButton(String type, RxBool isActive, CalendarController ctr) {
  return Obx(
        () => GestureDetector(
      onTap: () => ctr.changeView(type),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive.value ? Colors.black : Colors.grey,
            width: 2,
          ),
          color: isActive.value ? Colors.black : Colors.white,
        ),
        child: Center(
          child: Text(
            type.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: isActive.value ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// class CalendarController extends GetxController {
//   void setToday() {
//     DateTime now = DateTime.now();
//     selectedYear.value = now.year;
//     selectedMonth.value = now.month;
//     selectedDate.value = now.day;
//   }
//
//   var selectedYear = DateTime.now().year.obs;
//   var selectedMonth = DateTime.now().month.obs;
//   var selectedDate = DateTime.now().day.obs;
//   var dayView = true.obs;
//   var weekView = false.obs;
//   var monthView = false.obs;
//   void changeView(String type) {
//     if (type == "day") {
//       dayView.value = true;
//       weekView.value = false;
//       monthView.value = false;
//     } else if (type == "week") {
//       dayView.value = false;
//       weekView.value = true;
//       monthView.value = false;
//     } else if (type == "month") {
//       dayView.value = false;
//       weekView.value = false;
//       monthView.value = true;
//     }
//   }
//
//   List<int> get yearList => List.generate(20, (i) => 2020 + i);
//
//   List<String> get monthNames =>
//       List.generate(12, (i) => DateFormat('MMMM').format(DateTime(0, i + 1)));
//
//   int get daysInMonth =>
//       DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;
//
//   // FIXED: Accept year + month + date
//   String dayName(int year, int month, int day) {
//     return DateFormat('EEE').format(DateTime(year, month, day));
//   }
//
//   // Optional helpers
//   void changeYear(int year) {
//     selectedYear.value = year;
//   }
//
//   void changeMonth(int month) {
//     selectedMonth.value = month;
//   }
// }
