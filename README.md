http://codenamekylo.co.za/

developerkylo@gmail.com

---------------------------------------------------

INSTRUCTIONS!!!
---------------
change "env.example" to ".env"

Update the OpenAI api key in the ".env" file to YOUR new OPEN AI KEY

run 'flutter pub get' in terminal.
---------------
SETUP!!!!

Where to change:

App Name: IOS: fluttergpt\ios\Runner\Info.plist                               (10,10:<string>ChatAi In Hebrew</string>)
          Android: fluttergpt\android\app\src\main\AndroidManifest.xml        (9,24: android:label="ChatAi - In Hebrew">)

App Icon: IOS: fluttergpt\ios\Runner\Assets.xcassets\AppIcon.appiconset (Replace these files)
          Android: fluttergpt\android\app\src\main\res  (Replace these files)

OPEN AI KEY: fluttergpt\.env (change from env.example to .env)
                fluttergpt\env.example (change to .env)

AD Unit ID: Android: fluttergpt\android\app\src\main\AndroidManifest.xml (12,28:android:value="ca-app-pub-000000000000~00000000"/>)
            IOS: fluttergpt\ios\Runner\Info.plist (56,10:<string>ca-app-pub-000000000000~000000000</string>)
                 fluttergpt\lib\utils\AdCommon.dart (All The Ad Units)


## ChatGPT Application with flutter

ChatGPT has released version 4.0, but it is not fully open. Currently, AI Chat uses the `gpt-3.5-turbo` model.

### Software version

- Whether to configure infinite number of versions through `isInfiniteNumberVersion` in `lib/utils/Config.dart`

At present, Android supports running on a real machine, and IOS has only been run on an emulator. IOS packaging requires a developer account.

### Install

#### `flutter`

- `3.*` version, AI Chat uses version 3.7.7 when compiling.

#### `ChatGPT Token` (required)

- Configure the token obtained from the openai background to the `chatGptToken` variable of the `lib/utils/Chatgpt.dart` file.

#### `admob` (ad version)

- The admob ad is docked, the main branch contains admob, you need to apply for the corresponding ad ID in the admob background, and fill it in the `lib/utils/AdCommon.dart` file. These include splash ads, interstitial ads, interstitial rewarded ads, and banner ads.
- Configure admob's `APPLICATION_ID` to `android/app/src/main/AndroidManifest.xml`

```
<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="****" />
```

- Also configure admob's `APPLICATION_ID` to `ios/Runner/Info.plist`

```
<key>GADApplicationIdentifier</key>
<string>****</string>
```

#### Android packaging and compilation configuration

- To package and compile, you need to generate the corresponding key first. Here you can go to Google to see the packaging steps.

- Replace generated jks file to `android/app/build_config/build.jks`

> Edit the packaging configuration `signingConfigs` in the `android/app/build.gradle` file, and replace the corresponding file path and password.

```
signingConfigs {
     release {
         storeFile file("./build_config/build.jks")
         storePassword "123456"
         keyAlias "appKey"
         keyPassword "123456"
     }
}
```
