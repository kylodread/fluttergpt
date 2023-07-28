import 'package:dart_openai/openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class ChatGPT {
  static final ChatGPT _instance = ChatGPT._();

  factory ChatGPT() => _getInstance();

  static ChatGPT get instance => _getInstance();

  ChatGPT._();

  static ChatGPT _getInstance() {
    return _instance;
  }

  static GetStorage storage = GetStorage();

  static String chatGptToken =
      dotenv.env['OPENAI_CHATGPT_TOKEN'] ?? ''; // token
  static String defaultModel = 'gpt-3.5-turbo';
  static List defaultRoles = [
    'system',
    'user',
    'assistant'
  ]; // generating | error

  static List chatModelList = [
    {
      "type": "chat",
      "name": "AI צ'אט",
      "desc": "צ'אט בשפת הטבע, במצב שיח מתמשך",
      "isContinuous": true,
      "content": "\nהוראות:"
          "\nאתה צ'אטGPT. על התשובה לכל שאלה להיות כמה שיותר קצרה. אם אתה יוצר רשימה, אל תכלול יותר מדי פריטים."
          " אם יש אפשרות, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "האם תוכל לכתוב שיר?",
        "האם תוכל לכתוב בדיחה?",
        "עזר לי לתכנן טיול",
      ],
    },
    {
      "type": "translationLanguage",
      "name": "תרגם שפה",
      "desc": "תרגם שפה A לשפה B",
      "isContinuous": false,
      "content": '\nהוראות:\n'
          'אני רוצה שתעזוב בתפקידו של מתרגם. תזהה את השפה, תתרגם אותה לשפה שצוינה ותענה לי. אנא אל תשתמש במבנה המבריק בתרגום, אלא תרגם באופן טבעי, חלק ואותנטי, ובשימוש בביטויים יפים ואלגנטיים. אני אציין את הפורמט "תרגם A ל-B". אם הפורמט שציינתי שגוי, בבקשה הסבר שהפורמט "תרגם A ל-B" ישמש. נא לענות רק על חלק התרגום, אל תכתוב את ההסבר.'
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "תרגם אהבה לסינית",
        "תרגם חמוד לסינית",
        "תרגם איך אתה לסינית",
      ],

    },
    {
     "type": "frontEndHelper",
      "name": "עוזר פרונט-אנד",
      "desc": "התנהג כמו עוזר פרונט-אנד",
      "isContinuous": false,
      "content": '\nהוראות:\n'
          "אני רוצה שתהיה מומחה בפיתוח פרונט-אנד. אני אספק לך מידע ספציפי על בעיות קוד פרונט-אנד עם JavaScript, Node, וכו', והעבודה שלך היא להגיע עם תרגיל לפתרון הבעיה בשבילי. זה עשוי לכלול הצעת קוד, אסטרטגיות לחשיבה לוגית על קוד."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "אזכור מערך ב-JavaScript",
      ],

    },
    
    {
     "type": "positionInterviewer",
      "name": "התנהג כמו ראש ראיון",
      "desc":
          "ראיין AI. כמועמד, הAI ישאל אותך שאלות ראיון עבור התפקיד",
      "isContinuous": false,
      "content": "\nהוראות:"
          "\nאני רוצה שתתנהג כמו ראש ראיון. אני יהיה המועמד ואתה תשאל לי שאלות ראיון עבור התפקיד position. אני רוצה שתענה רק כמו ראש ראיון. אל תכתוב את כל השיחה בבת אחת. אני רוצה שתרקוד איתי את הראיון. תשאל אותי את השאלות אחת אחת כמו שראש ראיון עושה ותחכה לתשובות שלי."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "שלום, אני מהנדס פיתוח פרונט-אנד",
        "שלום, אני מתחזק רכבים",
        "שלום, אני עובד כמנהל כספים",
      ],

    },
    
    {
     "type": "excelSheet",
      "name": "התנהג כדיין אקסל",
      "desc":
          "פועל כדיין אקסל במבנה טקסט. תגיב רק לגיליון אקסל עם 10 שורות במבנה טקסט ומספרי השורות ואותיות התאים כעמודות (A עד L)",
      "isContinuous": false,
      "content": "\nהוראות:"
          "\nאני רוצה שתתנהג כמו גיליון אקסל במבנה טקסט. אתה תגיב לי רק לגיליון אקסל עם 10 שורות במבנה טקסט ומספרי השורות ואותיות התאים כעמודות (A עד L). הכותרת של עמודת הטור הראשון צריכה להיות ריקה כדי לייחס למספר השורה. אני אגיד לך מה לכתוב בתוך התאים ואתה תגיב רק עם התוצאה של הגיליון אקסל כטקסט, ושום דבר אחר. אל תכתוב הסברים. אני אכתוב נוסחאות ואתה תבצע אותן ואתה תגיב רק עם התוצאה של הגיליון אקסל כטקסט."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "הגב לי על הגיליון הריק",
      ],

    },
    {
      "type": "spokenEnglishTeacher",
      "name": "התנהג כמורה ומשפר באנגלית",
      "desc":
          "שוחח עם הAI באנגלית, הAI ישיב לך באנגלית כדי לשפר את דקדוקך ואת יכולת הדיבור באנגלית",
      "isContinuous": false,
      "content": "\nהוראות:"
          "\nאני רוצה שתתנהג כמו מורה ומשפר באנגלית. אני אדבר אליך באנגלית ואתה תשיב לי באנגלית כדי לשפר את יכולת הדיבור באנגלית שלי. אני רוצה שתענה בצורה נקייה, בגבול של 100 מילים. אני רוצה ממך לתקן במחמירות את הטעויות בדקדוק, השגיאות כתיב והשגיאות עובדתיות שלי. אני רוצה שתשאל שאלה בתשובתך. זכור, אני רוצה ממך לתקן במחמירות את הטעויות בדקדוק, השגיאות כתיב והשגיאות עובדתיות שלי."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "כעת בוא נתחיל בתרגול",
      ],

    },
    {
     "type": "travelGuide",
      "name": "התנהג כמדריך תיירות",
      "desc":
          "רשום את המיקום שלך והAI ימליץ על אטרקציות בסביבתך",
      "isContinuous": false,
      "content": "\nהוראות:"
          "\nאני רוצה שתתנהג כמדריך תיירות. אני אכתוב לך את המיקום שלי ואתה תמליץ לי על מקום לבקר בסביבת המיקום שלי. במקרים מסוימים, אני גם יכול לספק לך את סוג המקומות שאני רוצה לבקר בהם. אתה גם תמליץ לי על מקומות מאותו הסוג שנמצאים קרוב למיקום הראשון שלי."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "אני נמצא באיסטנבול/ביאוגלו ורוצה לבקר במוזיאונים בלבד.",
      ],

    },
    {
      "type": "storyteller",
      "name": "התנהג כספורן",
      "desc":
          "הAI יביא סיפורים מעניינים שמובילים, מדהימים ומקנים משובבים לקהל",
      "isContinuous": false,
      "content": "\nהוראות:"
          "\nאני רוצה שתתנהג כספורן. אתה תביא סיפורים מהנים שמובילים, מדהימים ומקנים משובבים לקהל. יכול להיות סיפורי ילדים, סיפורים להוראה או כל סוג אחר של סיפורים שיש בהם פוטנציאל ללכוד את תשומת הלב והדמיון של הקהל. בהתאם לקהל היעד, תוכל לבחור נושאים או נושאים מסוימים לסשן הסיפורות שלך. לדוגמה, אם זה ילדים, אז תוכל לדבר על בעלי חיים; אם זה מבוגרים, סיפורים המבוססים על היסטוריה עשויים להיות יעילים יותר וכו'."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        "אני זקוק לסיפור מעניין על סבלנות.",
      ],

    },
    {
     "type": "legalAdvisor",
      "name": "התנהג כיועץ משפטי",
      "desc":
          "הAI כיועץ המשפטי שלך. אתה צריך לתאר מצב משפטי והAI יספק לך עצה על איך להתמודד עם זה",
      "isContinuous": false,
      "content": "\nהוראות:"
          "\nאני רוצה שתתנהג כיועץ המשפטי שלי. אני אתאר מצב משפטי ואתה תספק לי עצה על איך להתמודד עם זה. אתה צריך להשיב רק עם העצה שלך ושום דבר אחר. אל תכתוב הסברים."
          " אם אפשר, אנא הצג את זה בתבנית חברותית של Markdown."
          '\n',
      "tips": [
        'אני יוצר ציורים פורטרט סוריאליסטיים',
      ],

    },
  ];

  static Future<void> setOpenAIKey(String key) async {
    await storage.write('OpenAIKey', key);
    await initChatGPT();
  }

  static String getCacheOpenAIKey() {
    String? key = storage.read('OpenAIKey');
    if (key != null && key != '' && key != chatGptToken) {
      return key;
    }
    return '';
  }

  static Future<void> setOpenAIBaseUrl(String url) async {
    await storage.write('OpenAIBaseUrl', url);
    await initChatGPT();
  }

  static String getCacheOpenAIBaseUrl() {
    String? key = storage.read('OpenAIBaseUrl');
    return (key ?? "").isEmpty ? "" : key!;
  }

  static Set chatModelTypeList =
      chatModelList.map((map) => map['type']).toSet();

  /// 实现通过type获取信息
  static getAiInfoByType(String chatType) {
    return chatModelList.firstWhere(
      (item) => item['type'] == chatType,
      orElse: () => null,
    );
  }

  static Future<void> initChatGPT() async {
    String cacheKey = getCacheOpenAIKey();
    String cacheUrl = getCacheOpenAIBaseUrl();
    var apiKey = cacheKey != '' ? cacheKey : chatGptToken;
    OpenAI.apiKey = apiKey;
    if (apiKey != chatGptToken) {
      OpenAI.baseUrl =
          cacheUrl.isNotEmpty ? cacheUrl : "https://api.openai.com";
    }
  }

  static getRoleFromString(String role) {
    if (role == "system") return OpenAIChatMessageRole.system;
    if (role == "user") return OpenAIChatMessageRole.user;
    if (role == "assistant") return OpenAIChatMessageRole.assistant;
    return "unknown";
  }

  static convertListToModel(List messages) {
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages = [];
    for (var element in messages) {
      modelMessages.add(OpenAIChatCompletionChoiceMessageModel(
        role: getRoleFromString(element["role"]),
        content: element["content"],
      ));
    }
    return modelMessages;
  }

  static List filterMessageParams(List messages) {
    List newMessages = [];
    for (var v in messages) {
      if (defaultRoles.contains(v['role'])) {
        newMessages.add({
          "role": v["role"],
          "content": v["content"],
        });
      }
    }
    return newMessages;
  }

  static Future<bool> checkRelation(
    List beforeMessages,
    Map message, {
    String model = '',
  }) async {
    beforeMessages = filterMessageParams(beforeMessages);
    String text = "\nInstructions:"
        "\nCheck whether the problem is related to the given conversation. If yes, return true. If no, return false. Please return only true or false. The answer length is 5."
        "\nquestion：$message}"
        "\nconversation：$beforeMessages"
        "\n";
    OpenAIChatCompletionModel chatCompletion = await sendMessage(
      [
        {
          "role": 'user',
          "content": text,
        }
      ],
      model: model,
    );
    debugPrint('---text $text---');
    String content = chatCompletion.choices.first.message.content ?? '';
    bool hasRelation = content.toLowerCase().contains('true');
    debugPrint('---检查问题前后关联度 $hasRelation---');
    return hasRelation;
  }

  static Future<OpenAIChatCompletionModel> sendMessage(
    List messages, {
    String model = '',
  }) async {
    messages = filterMessageParams(messages);
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages =
        convertListToModel(messages);
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: model != '' ? model : defaultModel,
      messages: modelMessages,
    );
    return chatCompletion;
  }

  static Future sendMessageOnStream(
    List messages, {
    String model = '',
    Function? onProgress,
  }) async {
    messages = filterMessageParams(messages);
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages =
        convertListToModel(messages);

    Stream<OpenAIStreamChatCompletionModel> chatStream =
        OpenAI.instance.chat.createStream(
      model: defaultModel,
      messages: modelMessages,
    );
    print(chatStream);

    chatStream.listen((chatStreamEvent) {
      print('---chatStreamEvent---');
      print('$chatStreamEvent');
      print('---chatStreamEvent end---');
      if (onProgress != null) {
        onProgress(chatStreamEvent);
      }
    });
  }

  static Future<OpenAIImageModel> genImage(String imageDesc) async {
    debugPrint('---genImage starting: $imageDesc---');
    OpenAIImageModel image = await OpenAI.instance.image.create(
      prompt: imageDesc,
      n: 1,
      size: OpenAIImageSize.size1024,
      responseFormat: OpenAIImageResponseFormat.url,
    );
    debugPrint('---genImage success: $image---');
    return image;
  }
}
