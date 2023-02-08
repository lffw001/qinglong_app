import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/utils/codeeditor_theme.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

var themeProvider = ChangeNotifierProvider((ref) => ThemeViewModel());

Color whiteColor = const Color(0xfff1f1f1);

int modeDark = 2;
int modeLight = 0;
int modeWhite = 1;

Color _primaryColor = const Color(0xFF20b54f);
// Color _primaryColor = Colors.redAccent;

class ThemeViewModel extends ChangeNotifier {
  late ThemeData currentTheme;

  int _themeMode = modeLight;

  Color primaryColor = _primaryColor;

  ThemeColors themeColor = LightThemeColors();

  ThemeViewModel() {
    if (SpUtil.getBool(spThemeFollowSystem, defValue: false)) {
      changeThemeWithSystemStatus();
    } else {
      _themeMode = SpUtil.getInt(spThemeStyle, defValue: SpUtil.getInt(spVIP, defValue: typeNormal) != typeNormal ? modeWhite : modeLight);
    }

    changeThemeReal(_themeMode, false);
  }

  void changeThemeWithSystemStatus([bool must = true]) {
    if (SpUtil.getBool(spThemeFollowSystem, defValue: false) == false) return;
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    int theme;
    if (brightness == Brightness.dark) {
      theme = modeDark;
    } else {
      theme = SpUtil.getInt(spVIP, defValue: typeNormal) != typeNormal ? modeWhite : modeLight;
    }
    if (!must && _themeMode == theme) return;
    changeThemeReal(theme);
  }

  void changeTheme(int themeMode) {
    if (_themeMode == themeMode) return;
    changeThemeReal(themeMode);
  }

  void changeThemeReal(int themeMode, [bool notify = true]) {
    _themeMode = themeMode;
    SpUtil.putInt(spThemeStyle, _themeMode);
    if (_themeMode == modeLight) {
      currentTheme = getLightTheme();
      themeColor = LightThemeColors();
    } else if (_themeMode == modeDark) {
      currentTheme = getDartTheme();
      themeColor = DartThemeColors();
    } else {
      currentTheme = getWhiteTheme();
      themeColor = WhiteThemeColors();
    }
    if (Platform.isAndroid) {
      SystemUiOverlayStyle style;
      if (_themeMode == modeDark) {
        style = const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.black);
      } else {
        style = const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.white);
      }
      SystemChrome.setSystemUIOverlayStyle(style);
    }
    if (notify) {
      notifyListeners();
    }
  }

  get themeMode => _themeMode;

  ThemeData getWhiteTheme() {
    return ThemeData.light().copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      splashColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        secondary: _primaryColor,
        primary: _primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
        backgroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xffffffff),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xffBBBBBB),
        ),
        labelStyle: TextStyle(
          color: _primaryColor,
          fontSize: 14,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: whiteColor,
        titleTextStyle: const TextStyle(
          color: Color(0xff333333),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        toolbarTextStyle: TextStyle(
          color: _primaryColor,
        ),
        iconTheme: IconThemeData(
          color: _primaryColor,
        ),
        actionsIconTheme: IconThemeData(
          color: _primaryColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _primaryColor,
        backgroundColor: const Color(0xBBF9F9F9),
        elevation: 0,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _primaryColor,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryColor,
      ),
      tabBarTheme: TabBarTheme(
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
        labelColor: _primaryColor,
        unselectedLabelColor: const Color(0xff999999),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      hintColor: const Color(0xffBBBBBB),
      toggleableActiveColor: _primaryColor,
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.transparent;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
      ),
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
      ),
    );
  }

  ThemeData getLightTheme() {
    return ThemeData.light().copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      splashColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        secondary: _primaryColor,
        primary: _primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
        backgroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xffffffff),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xffBBBBBB),
        ),
        labelStyle: TextStyle(
          color: _primaryColor,
          fontSize: 14,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 8,
          bottom: 8,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        toolbarTextStyle: TextStyle(
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _primaryColor,
        backgroundColor: const Color(0xBBF9F9F9),
        elevation: 0,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _primaryColor,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryColor,
      ),
      tabBarTheme: TabBarTheme(
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
        labelColor: _primaryColor,
        unselectedLabelColor: const Color(0xff999999),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      hintColor: const Color(0xffBBBBBB),
      toggleableActiveColor: _primaryColor,
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.transparent;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
      ),
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
      ),
    );
  }

  ThemeData getDartTheme() {
    return ThemeData.dark().copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashColor: Colors.transparent,
      dividerColor: const Color(0xff242424),
      canvasColor: const Color(0xff242424),
      dividerTheme: const DividerThemeData(
        color: Color(0xff242424),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
        backgroundColor: Colors.white,
      ),
      brightness: Brightness.dark,
      primaryColor: const Color(0xffffffff),
      scaffoldBackgroundColor: const Color(0xff111111),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: const Color(0xff111111),
        titleTextStyle: const TextStyle(
          color: Color(0xffffffff),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        toolbarTextStyle: TextStyle(
          color: _primaryColor,
        ),
        iconTheme: IconThemeData(
          color: _primaryColor,
        ),
        actionsIconTheme: IconThemeData(
          color: _primaryColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _primaryColor,
        backgroundColor: const Color(0x991B1B1B),
        elevation: 0,
      ),
      hintColor: const Color(0xffBBBBBB),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xffBBBBBB),
        ),
        labelStyle: TextStyle(
          color: _primaryColor,
          fontSize: 14,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff999999), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff999999), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff999999), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelStyle: TextStyle(
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
        ),
        labelColor: Color(0xffffffff),
        unselectedLabelColor: Color(0xff999999),
      ),
      colorScheme: ColorScheme.light(
        secondary: _primaryColor,
        primary: _primaryColor,
      ),
      toggleableActiveColor: _primaryColor,
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.transparent;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return Colors.white;
          },
        ),
      ),
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xffffffff),
        scaffoldBackgroundColor: Colors.black,
      ),
    );
  }
}

abstract class ThemeColors {
  Color settingBgColor();

  Color bg2Color();

  Color blackAndWhite();

  Color codeBgColor();

  Color pinedAndWhite();

  Color settingBordorColor();

  Color titleColor();

  Color title2Color();

  Color hintColor();

  Color descColor();

  Color filterColor();

  Color tabBarColor();

  Color pinColor();

  Color searchBgColor();

  Color buttonBgColor();

  Color segmentedUnCheckBg();

  Color otherFuncBg();

  Map<String, TextStyle> codeEditorTheme();

  List<Color> appBarBg();
}

class LightThemeColors extends ThemeColors {
  @override
  Color titleColor() {
    return const Color(0xff1A1A1A);
  }

  @override
  Color pinColor() {
    return whiteColor;
  }

  @override
  Map<String, TextStyle> codeEditorTheme() {
    return qinglongLightTheme;
  }

  @override
  Color descColor() {
    return const Color(0xffB3B3B3);
  }

  @override
  Color settingBgColor() {
    return Colors.white;
  }

  @override
  Color buttonBgColor() {
    return _primaryColor;
  }

  @override
  Color settingBordorColor() {
    return Colors.white;
  }

  @override
  Color tabBarColor() {
    return const Color(0xffF7F7F7);
  }

  @override
  List<Color> appBarBg() {
    return [
      const Color(0xff5DD16F),
      const Color(0xff099657),
    ];
  }

  @override
  Color blackAndWhite() {
    return Colors.white;
  }

  @override
  Color filterColor() {
    return const Color(0xff666666);
  }

  @override
  Color title2Color() {
    return const Color(0xff1A1A1A);
  }

  @override
  Color hintColor() {
    return const Color(0xffBBBBBB);
  }

  @override
  Color bg2Color() {
    return whiteColor;
  }

  @override
  Color segmentedUnCheckBg() {
    return const Color(0xffF0F0F0);
  }

  @override
  Color pinedAndWhite() {
    return Colors.white;
  }

  @override
  Color searchBgColor() {
    return whiteColor;
  }

  @override
  Color otherFuncBg() {
    return Colors.white;
  }

  @override
  Color codeBgColor() {
    return const Color(0xffffffff);
  }
}

class WhiteThemeColors extends ThemeColors {
  @override
  Color titleColor() {
    return const Color(0xff1A1A1A);
  }

  @override
  Color codeBgColor() {
    return const Color(0xffffffff);
  }

  @override
  Color pinColor() {
    return whiteColor;
  }

  @override
  Color searchBgColor() {
    return whiteColor;
  }

  @override
  Color otherFuncBg() {
    return Colors.white;
  }

  @override
  Map<String, TextStyle> codeEditorTheme() {
    return qinglongLightTheme;
  }

  @override
  Color descColor() {
    return const Color(0xffB3B3B3);
  }

  @override
  Color pinedAndWhite() {
    return Colors.white;
  }

  @override
  Color settingBgColor() {
    return Colors.white;
  }

  @override
  Color buttonBgColor() {
    return _primaryColor;
  }

  @override
  Color settingBordorColor() {
    return Colors.white;
  }

  @override
  Color tabBarColor() {
    return const Color(0xffF7F7F7);
  }

  @override
  List<Color> appBarBg() {
    return [
      const Color(0xff5DD16F),
      const Color(0xff099657),
    ];
  }

  @override
  Color blackAndWhite() {
    return Colors.white;
  }

  @override
  Color filterColor() {
    return const Color(0xff666666);
  }

  @override
  Color title2Color() {
    return const Color(0xff1A1A1A);
  }

  @override
  Color hintColor() {
    return const Color(0xffBBBBBB);
  }

  @override
  Color bg2Color() {
    return whiteColor;
  }

  @override
  Color segmentedUnCheckBg() {
    return Color(0xffF0F0F0);
  }
}

class DartThemeColors extends ThemeColors {
  @override
  Color hintColor() {
    return const Color(0xffBBBBBB);
  }

  @override
  Color title2Color() {
    return const Color(0xffffffff);
  }

  @override
  Color filterColor() {
    return const Color(0xffffffff);
  }

  @override
  Color pinedAndWhite() {
    return pinColor();
  }

  @override
  Color blackAndWhite() {
    return const Color(0xff111111);
  }

  @override
  Color titleColor() {
    return Colors.white;
  }

  @override
  Color pinColor() {
    return const Color(0xff202020);
  }

  @override
  Map<String, TextStyle> codeEditorTheme() {
    return qinglongDarkTheme;
  }

  @override
  Color descColor() {
    return const Color(0xffB3B3B3);
  }

  @override
  Color settingBgColor() {
    return const Color(0xff111111);
  }

  @override
  Color buttonBgColor() {
    return const Color(0xff333333);
  }

  @override
  Color settingBordorColor() {
    return const Color(0xff333333);
  }

  @override
  Color tabBarColor() {
    return const Color(0xff111111);
  }

  @override
  List<Color> appBarBg() {
    return [const Color(0xff111111)];
  }

  @override
  Color searchBgColor() {
    return const Color(0xff111111);
  }

  @override
  Color bg2Color() {
    return const Color(0xff111111);
  }

  @override
  Color otherFuncBg() {
    return Colors.transparent;
  }

  @override
  Color segmentedUnCheckBg() {
    return const Color(0xff333333);
  }

  @override
  Color codeBgColor() {
    return Color(0xff000000);
  }
}
