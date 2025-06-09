import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void setWindowBehavior({bool? isForLogin}) async {
  bool isLogin = isForLogin ?? false;
  if (!isLogin) {
    await windowManager.setSize(const Size(1280, 720), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
  } else {
    await windowManager.setSize(const Size(700, 350), animate: true);
    await windowManager.center();
    await windowManager.setSkipTaskbar(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }
}

