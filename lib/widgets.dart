import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'Controller/calendorcontroller.dart';
import"package:flutter/material.dart";
// circle view button
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
            color: isActive.value ? Colors.blue : Colors.grey,
            width: 2,
          ),
          color: isActive.value ? Colors.blue : Colors.white,
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
