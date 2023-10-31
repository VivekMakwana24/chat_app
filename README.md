**A Chat App Flutter project.**

```bash
├───android                             <-- Android related code
├───assets                              <-- Here we add our icons/image/fonts
│   ├───fonts
│   └───image
├───ios                                 <-- iOS related code
├───lib
│   ├───core                            <-- Core files of apps 
│   │   ├───db                          <-- Core files of apps 
│   │   ├───di
│   │   │   └───api                     <-- API configs
│   │   │       ├───interceptor         <-- API interceptors
│   │   │       ├───repo                <-- repositories for API calls
│   │   │       ├───response            <-- response parser fo API calls
│   │   │       │   ├───api_base        <-- base response parser fo API calls
│   │   │       │   └───base            <-- common response parser fo API calls
│   │   │       └───service             <-- services for API calls
│   │   └───navigation                  <-- navigation service related configs
│   ├───fcm                             <-- Fcm service related configs
│   ├───model                           <-- PODO models of API calls
│   ├───ui                              <-- App UI
│   │   ├───auth                        <-- App UI module
│   │   │   ├───login
│   │   │   │   └───store               <-- store for API call using Mobx structure
│   │   │   └───sign_up
│   │   └───home
│   ├───util                            <-- Utils/Helper class
│   ├───values                          <-- Common values, dummy data, App theme,style configs
│   │   └───extensions                  <-- extension methods
│   └───widget
│       └───credit_card_form            <-- common credit card validator
├───test                                <-- Widget, Unit, Integration test
└───web                                 <-- Web configs & web files
    └───icons                           <-- icons for web
```


## Environment

**Flutter version** : 2.2.1

**Flutter channel** : Stable

**iOS**
- iOS 11+

**Android**
- Android 5.0+
    - minSdkVersion 21
- targetSdkVersion 30

## Code Style
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## Assets, Fonts

**If added some assets or fonts**

- Use [AssetsRefGenerator](https://github.com/AndrewShen812/AssetsRefGenerator) **(lib/res.dart)**

## Models

**models for api results**

- Use [QuickType](https://app.quicktype.io/)

#### Architecture

|Working status|Category|Description|
|:---:|---|---|
| ✅ | Base | Using [Mobx](https://pub.dev/packages/mobx) + [build_runner](https://pub.dev/packages/build_runner)  
| ✅ | Networking | Using [dio](https://pub.dev/packages/dio) 
| ✅ | Data | Using [json serializable](https://pub.dev/packages/json_serializable) 
| ✅ | Session Management | Using [Hive](https://pub.dev/packages/hive)