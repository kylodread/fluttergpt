// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:async';

import 'package:aichat/utils/Chatgpt.dart';
import 'package:aichat/utils/Config.dart';
import 'package:aichat/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sp_util/sp_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aichat/stores/AIChatStore.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  bool isCopying = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // TODO: Switch from background to foreground, the interface is visible.
        break;
      case AppLifecycleState.paused:

        /// TODO: Switch from foreground to background, the interface is not visible.
        break;
      case AppLifecycleState.inactive:

        /// TODO: Handle this case.
        break;
      case AppLifecycleState.detached:

        /// TODO: Handle this case.
        break;
    }
  }

  Timer? longPressTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white,
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                height: 60,
                child: Row(
                  children: [
                    SizedBox(width: 24),
                    Image(
                      width: 18,
                      image: AssetImage('images/back_icon.png'),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "הגדרות",
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 24),
                  ],
                ),
              ),
            ),
            // Logo in the top-right corner
             Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: GestureDetector(
                   onLongPressStart: (details) {
                      longPressTimer = Timer(const Duration(seconds: 1), () {
                        _showPopupWindow();
                      });
                    },
                    onLongPressEnd: (details) {
                      longPressTimer?.cancel();
                    },
                  child: const Image(
                    width: 40,
                    image: AssetImage('images/logo2.png'), // Replace with your logo image path
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Container(
        color: const Color(0xffffffff),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  renderItemWidget(
                    'images/privacy_policy_icon.png',
                    Colors.red,
                    32,
                    'מדיניות הפרטיות',
                    () {
                      const url = 'https://gdigits.com/privacy-policy/';
                      _copyToClipboardAndShowToast(url);
                      Utils.launchURL(Uri.parse(url));
                    },
                  ),
                  renderItemWidget(
                    'images/email_icon.png',
                    Colors.purpleAccent,
                    26,
                    'מָשׁוֹב',
                    () {
                      String recipientEmail = Config.contactEmail;
                      String subject = "${Config.appName} - feedback";
                      const String body = '';
                      final url = 'mailto:$recipientEmail?subject=$subject&body=$body';
                      Utils.launchURL(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                        onLaunchFail: () {
                          Clipboard.setData(ClipboardData(text: recipientEmail));
                          EasyLoading.showToast(
                            'כתובת האימייל הועתקה',
                            dismissOnTap: true,
                          );
                        },
                      );
                    },
                  ),
                  renderItemWidget(
                    'images/key_icon.png',
                    Colors.lightGreen,
                    26,
                    'התאם אישית את מפתח OpenAI',
                    () async {
                      // ignore: await_only_futures
                      String cacheKey = await ChatGPT.getCacheOpenAIKey();
                      _textEditingController.text = cacheKey;
                      _showCustomOpenAIKeyDialog();
                    },
                  ),

                  /// Empty storage
                  if (Config.isDebug)
                    renderItemWidget(
                      'images/debug_icon.png',
                      Colors.indigo,
                      22,
                      'איתור באגים: נקה אחסון',
                      () {
                        ChatGPT.storage.erase();
                        final store = Provider.of<AIChatStore>(context, listen: false);
                        store.syncStorage();
                        SpUtil.clear();
                        EasyLoading.showToast('ברור הצלחה באחסון!');
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget renderItemWidget(
    String iconPath,
    Color iconBgColor,
    double iconSize,
    String title,
    GestureTapCallback back, {
    String rightIconSrc = 'images/arrow_icon.png',
  }) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: back,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: Image(
                          image: AssetImage(iconPath),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                if (rightIconSrc != '')
                  Row(
                    children: [
                      Image(
                        image: AssetImage(rightIconSrc),
                        width: 18,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(
            height: 1,
          ),
        ],
      ),
    );
  }

  void _showPopupWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You found an Easter Egg'),
          content: const Text('CodeNameKylo was here!   http://codenamekylo.co.za'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
              ),
          ],
        );
      },
    );
  }

  void _copyToClipboardAndShowToast(String url) {
    Clipboard.setData(ClipboardData(text: url));
    EasyLoading.showToast(
      'מדיניות הפרטיות הועתקה. אנא הדבק את הקישור בדפדפן',
      dismissOnTap: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showCustomOpenAIKeyDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Cמפתח OpenAI מותאם אישית'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'אנא הזן את המפתח שלך'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  if (isCopying) {
                    return;
                  }
                  isCopying = true;
                  await Clipboard.setData(
                    const ClipboardData(
                      text: 'https://platform.openai.com/',
                    ),
                  );
                  EasyLoading.showToast(
                    'העתק בהצלחה!',
                    dismissOnTap: true,
                  );
                  isCopying = false;
                },
                child: const SingleChildScrollView(
                  child: Wrap(
                    children: [
                      Text(
                        '* לא מומלץ',
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color.fromRGBO(220, 0, 0, 1.0),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '* אפליקציית CHAT AI לא אוספת מפתח זה.',
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color.fromRGBO(126, 126, 126, 1.0),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '* המפתח שאנו מספקים עשוי לדווח על שגיאה, ויש ליצור מפתחות מותאמים אישית בכתובת https://platform.openai.com/ .',
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color.fromRGBO(126, 126, 126, 1.0),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '* לחץ על העתק כתובת אתר',
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color.fromRGBO(126, 126, 126, 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('לְבַטֵל'),
              onPressed: () {
                _textEditingController.clear();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('לְאַשֵׁר'),
              onPressed: () async {
                await ChatGPT.setOpenAIKey(_textEditingController.text);
                _textEditingController.clear();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(true);
                EasyLoading.showToast(
                  'מוּצלָח!',
                  dismissOnTap: true,
                );
              },
            ),
          ],
        );
      },
    );
  }
}