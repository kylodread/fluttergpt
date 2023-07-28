import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:aichat/components/HideKeyboard.dart';
import 'package:aichat/page/AppOpenPage.dart';
import 'package:aichat/stores/AIChatStore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aichat/utils/Chatgpt.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize ChatGPT
  await ChatGPT.initChatGPT();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AIChatStore(),
      child: const MyApp(),
    ),
  );

  // Configure EasyLoading
  configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HideKeyboard(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
        ),
        locale: Locale('he'), // Set default locale to Hebrew
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('he'), // Hebrew
          Locale('en'), // Add other locales if needed
        ],
        home: const SplashPage(),
      ),
    );
  }
}

Future<void> configLoading() async {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.none
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..displayDuration = const Duration(milliseconds: 1000)
    ..userInteractions = false;
}
