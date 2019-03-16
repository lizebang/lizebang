---
title: "Try Flutter"
slug: try-flutter
date: 2018-10-26
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - dart
tags:
  - dart
  - flutter
keywords:
  - dart
  - flutter
---

今天小小的尝试了一下 [Flutter](https://flutter.io)，过程十分艰辛，遇到了不少坑，下面总结一下。

<!--more-->

## 安装 Flutter SDK

1.下载 Flutter SDK，我下载的是 [flutter_macos_v0.9.4-beta.zip](https://storage.googleapis.com/flutter_infra/releases/beta/macos/flutter_macos_v0.9.4-beta.zip)，你可以在 [SDK archive](https://flutter.io/sdk-archive/) 页面下载其他版本。

2.下载完成以后，将其解压到想存放它到目录，我将其放在了 Home 目录下。将 fluuter 提供的命令行工具添加到 PATH 中（`~/.bash_profile` 文件中）。

```shell
export PATH=[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin:$PATH
```

可以运行 `flutter --version` 查看一下版本信息。

```shell
$ flutter --version
Flutter 0.9.4 • channel beta • https://github.com/flutter/flutter.git
Framework • revision f37c235c32 (4 weeks ago) • 2018-09-25 17:45:40 -0400
Engine • revision 74625aed32
Tools • Dart 2.1.0-dev.5.0.flutter-a2eb050044
```

3.然后运行 `flutter doctor` 根据提示完成相关配置。

在安装 libimobiledevice 时会遇到下面的问题。

```shell
configure: error: Package requirements (libusbmuxd >= 1.1.0) were not met:
Requested 'libusbmuxd >= 1.1.0' but version of libusbmuxd is 1.0.10
```

可以通过去掉 `--HEAD` 参数完成安装。

```shell
$ brew install libimobiledevice
```

## iOS 和 Android 配置

可能有部分配置过程与 `flutter doctor` 提示的操作重复。

### iOS 设置

1.安装 9.0 以上版本 Xcode 并运行 `sudo xcodebuild -license` 签署 Xcode 许可协议。

2.iOS 模拟器可以直接运行 `open -a Simulator` 来使用。

3.如果想部署到 iOS 设备，需要按下列工具。

```shell
$ brew update
$ brew install libimobiledevice
$ brew install ideviceinstaller ios-deploy cocoapods
$ pod setup
```

### Android 设置

1.下载并安装 [Android Studio](https://developer.android.com/studio/index.html)。我使用 `brew cask` 安装的。

```shell
$ brew cask install android-studio
```

2.启动 Android Studio，并按提示安装最新的 Android SDK、Android SDK Platform-Tools 以及 Android SDK Build-Tools。

**注意：**不要设置 Android Studio 的代理。

3.设置 `ANDROID_HOME`，默认路径 `ANDROID_HOME=~/Library/Android/sdk`。

4.设置模拟器，启用 [VM 加速](https://developer.android.com/studio/run/emulator-acceleration.html)。

```shell
$ brew cask install intel-haxm
```

## IDE 设置

Android Studio 和 VS Code 都可以在各自的商店安装 `Flutter` 和 `Dart` 两个插件。

## 测试

手机开启 Debug 模式并连接电脑。

国内使用请将下面设置到系统环境变量中，用以提速。

```shell
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

新建项目，并运行。

```shell
$ flutter create app
$ cd app
$ flutter run
```

然后，你就能在手机上看到如下内容。

![flutter starter app android](/images/2018/10/flutter-starter-app-android.png)

## 我遇到的两大神坑

### 神坑一

在下载 Android SDK 时，设置电子科技大学的镜像源代理。然后，此设置同时被设置到 `~/.gradle/gradle.properties` 配置文件中。被写入到配置如下：

```properties
systemProp.https.proxyPort=80
systemProp.http.proxyHost=mirrors.dormforce.net
systemProp.https.proxyHost=mirrors.dormforce.net
systemProp.http.proxyPort=80
```

在运行 `flutter run` 时会出现如下错误：

```shell
$ flutter run

Initializing gradle...                                       1.1s
Resolving dependencies...
* Error running Gradle:
Exit code 1 from: /Users/lizebang/develop/app/android/gradlew.bat app:properties:

FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring root project 'android'.
> Could not resolve all files for configuration ':classpath'.
   > Could not resolve com.android.tools.build:gradle:3.1.2.
     Required by:
         project :
      > Could not resolve com.android.tools.build:gradle:3.1.2.
         > Could not get resource 'https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/3.1.2/gradle-3.1.2.pom'.
            > Could not GET 'https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/3.1.2/gradle-3.1.2.pom'.
               > Connect to 127.0.0.1:8888 [/127.0.0.1] failed: Connection refused: connect
      > Could not resolve com.android.tools.build:gradle:3.1.2.
         > Could not get resource 'https://jcenter.bintray.com/com/android/tools/build/gradle/3.1.2/gradle-3.1.2.pom'.
            > Could not GET 'https://jcenter.bintray.com/com/android/tools/build/gradle/3.1.2/gradle-3.1.2.pom'.
               > Connect to 127.0.0.1:8888 [/127.0.0.1] failed: Connection refused: connect

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 3s

Please review your Gradle project setup in the android/ folder.
```

解决：删除代理的配置即可。当然此问题还可能由其他原因造成，可以参考 [flutter issues](https://github.com/flutter/flutter/issues/21600)。

### 神坑二

找不到 lint-gradle-api.jar

```shell
$ flutter run

Initializing gradle...                                       1.4s
Resolving dependencies...
* Error running Gradle:
ProcessException: Process "/Users/lizebang/develop/app/android/gradlew" exited abnormally:
Project evaluation failed including an error in afterEvaluate {}. Run with --stacktrace for details of the afterEvaluate {} error.

FAILURE: Build failed with an exception.

* Where:
Build file '/Users/lizebang/develop/app/android/app/build.gradle' line: 25

* What went wrong:
A problem occurred evaluating project ':app'.
> Could not resolve all files for configuration 'classpath'.
   > Could not find lint-gradle-api.jar (com.android.tools.lint:lint-gradle-api:26.1.2).
     Searched in the following locations:
         https://jcenter.bintray.com/com/android/tools/lint/lint-gradle-api/26.1.2/lint-gradle-api-26.1.2.jar

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 0s
  Command: /Users/rabbit/develop/android/flutter_app/android/gradlew app:properties

Finished with error: Please review your Gradle project setup in the android/ folder.
```

解决方法：

1.修改项目目录下的 `./android/build.gradle` 文件。

```gradle
buildscript {
    repositories {
        // google()
        // jcenter()
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.2'
    }
}

allprojects {
    repositories {
        // google()
        // jcenter()
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
    }
}

// omit something else
```

2.修改 Flutter SDK 目录下的 `./packages/flutter_tools/gradle/flutter.gradle` 文件。

```gradle
buildscript {
    repositories {
        // jcenter()
        // maven {
        //     url 'https://dl.google.com/dl/android/maven2'
        // }
        maven{
            url 'https://maven.aliyun.com/repository/jcenter'
        }
        maven{
            url 'http://maven.aliyun.com/nexus/content/groups/public'
        }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.2'
    }
}

// omit something else
```

## Reference

- [Using Flutter in China](https://github.com/flutter/flutter/wiki/Using-Flutter-in-China)
- [Could not find lint-gradle-api.jar](https://segmentfault.com/q/1010000016775662/a-1020000016788604)
