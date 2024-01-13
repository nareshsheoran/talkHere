import 'package:flutter/material.dart';
import 'package:whats_app/data_All/app_color.dart';
import 'package:whats_app/data_All/font_sizes.dart';

Widget appButton(width, text, AppColor, AppColor_) {
  return Container(
    child: Center(
        child: Text(text,
            style: TextStyle(
                color: AppColor_,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.font20))),
    width: width,
    height: AppFontSize.font50,
    decoration: BoxDecoration(
        color: AppColor,
        borderRadius: BorderRadius.circular(AppFontSize.font18)),
  );
}
