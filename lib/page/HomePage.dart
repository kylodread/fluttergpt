import 'package:aichat/components/MyLimit.dart';
import 'package:aichat/components/QuestionInput.dart';
import 'package:aichat/page/ChatHistoryPage.dart';
import 'package:aichat/page/ChatPage.dart';
import 'package:aichat/page/SettingPage.dart';
import 'package:aichat/utils/Chatgpt.dart';
import 'package:aichat/utils/Config.dart';
import 'package:aichat/utils/InterstitialAdCreator.dart';
import 'package:aichat/utils/Time.dart';
import 'package:aichat/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aichat/stores/AIChatStore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aichat/utils/AdCommon.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController questionController = TextEditingController();

  InterstitialAdCreator? _interstitialAdCreator;

  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;
  double _adWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _adWidth = MediaQuery.of(context).size.width;

    _loadAd();
  }

  void _loadAd() async {
    if (!Config.isAdShow()) {
      return;
    }
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      _adWidth.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: homeBannerAd,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('BannerAd loaded: $homeBannerAd');
          _bannerAdLoaded = true;
          setState(() {});
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('BannerAd load fail: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();

    _interstitialAdCreator = getInterstitialAdInstance(taskAdId);
  }

  Widget _renderBottomInputWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        handleClickInput();
      },
      child: const QuestionInput(
        chat: {},
        autofocus: false,
        enabled: false,
      ),
    );
  }

  Widget _renderBannerAdWidget() {
    if (_bannerAd != null && _bannerAdLoaded) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return Container();
    }
  }

  Future _handleClickModel(Function callback) async {
    if (!Config.isAdShow()) {
      callback();
      return;
    }

    EasyLoading.show(status: 'loading...');

    _interstitialAdCreator?.showInterstitialAd(
      failCallback: () {
        callback();
        EasyLoading.dismiss();
      },
      openCallback: () {
        callback();
        EasyLoading.dismiss();
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _interstitialAdCreator?.dispose();
  }

  void handleClickInput() async {
    final store = Provider.of<AIChatStore>(context, listen: false);
    store.fixChatList();
    Utils.jumpPage(
      context,
      ChatPage(
        chatType: 'chat',
        autofocus: true,
        chatId: const Uuid().v4(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AIChatStore>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SizedBox(width: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              clipBehavior: Clip.antiAlias,
              child: const Image(
                width: 39,
                height: 39,
                image: AssetImage('images/logo2.png'),
              ),
            ),
            //const SizedBox(width: 8),
            //Text(
             // Config.appName,
             // style: const TextStyle(
              //  color: Color.fromRGBO(54, 54, 54, 1.0),
             //   fontSize: 18,
             //   height: 1,
            //  ),
          //  ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (Config.isAdShow() &&store.apiCount < Config.appUserAdCount) const MyLimit(),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 32,
            color: const Color.fromRGBO(98, 98, 98, 1.0),
            onPressed: () {
              // ChatGPT.genImage('Robot avatar, cute');
              Utils.jumpPage(context, const SettingPage());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _renderBannerAdWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (store.homeHistoryList.length > 0)
                      _renderTitle(
                        'הִיסטוֹרִיָה',
                        rightContent: SizedBox(
                          width: 45,
                          child: GestureDetector(
                            onTap: () {
                              Utils.jumpPage(context, const ChatHistoryPage());
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'את כל',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 18 / 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 13,
                                  child: const Image(
                                    image: AssetImage('images/arrow_icon.png'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (store.homeHistoryList.length > 0)
                      _renderChatListWidget(
                        store.homeHistoryList,
                      ),
                    _renderTitle('ChatAI בעברית'),
                    _renderChatModelListWidget(),
                  ],
                ),
              ),
            ),
            _renderBottomInputWidget(),
          ],
        ),
      ),
    );
  }

  Widget _renderTitle(
    String text, {
    Widget? rightContent,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Color.fromRGBO(1, 2, 6, 1),
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (rightContent != null) rightContent,
        ],
      ),
    );
  }

  Widget _renderChatModelListWidget() {
    List<Widget> list = [];
    for (var i = 0; i < ChatGPT.chatModelList.length; i++) {
      list.add(
        _genChatModelItemWidget(ChatGPT.chatModelList[i]),
      );
    }
    list.add(
      const SizedBox(height: 10),
    );
    return Column(
      children: list,
    );
  }

  Widget _genChatModelItemWidget(Map chatModel) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        _handleClickModel(() {
          final store = Provider.of<AIChatStore>(context, listen: false);
          store.fixChatList();
          Utils.jumpPage(
            context,
            ChatPage(
              chatId: const Uuid().v4(),
              autofocus: true,
              chatType: chatModel['type'],
            ),
          );
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(229, 245, 244, 1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatModel['name'],
                            softWrap: true,
                            style: const TextStyle(
                              color: Color.fromRGBO(117, 221, 132, 1),
                              fontSize: 18,
                              height: 24 / 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chatModel['desc'],
                            softWrap: true,
                            style: const TextStyle(
                              color: Color.fromRGBO(144, 152, 154, 1),
                              fontSize: 16,
                              height: 22 / 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: const Image(
                        image: AssetImage('images/arrow_icon.png'),
                        width: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _renderChatListWidget(List chatList) {
    List<Widget> list = [];
    for (var i = 0; i < chatList.length; i++) {
      list.add(
        _genChatItemWidget(chatList[i]),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          ...list,
        ],
      ),
    );
  }

  Widget _genChatItemWidget(Map chat) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        final store = Provider.of<AIChatStore>(context, listen: false);
        store.fixChatList();
        Utils.jumpPage(
          context,
          ChatPage(
            chatId: chat['id'],
            autofocus: false,
            chatType: chat['ai']['type'],
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat['updatedTime'] != null)
                      Text(
                        TimeUtils().formatTime(
                          chat['updatedTime'],
                          format: 'dd/MM/yyyy HH:mm',
                        ),
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 24 / 16,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      chat['messages'][0]['content'],
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        height: 24 / 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 22,
                ),
                color: const Color.fromARGB(255, 145, 145, 145),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, chat['id']);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 2,
            color: Color.fromRGBO(166, 166, 166, 1.0),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String chatId,
  ) async {
    final store = Provider.of<AIChatStore>(context, listen: false);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('לאשר את המחיקה?'),
          actions: <Widget>[
            TextButton(
              child: const Text('לְבַטֵל'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('לְאַשֵׁר'),
              onPressed: () async {
                await store.deleteChatById(chatId);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}