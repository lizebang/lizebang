---
title: 'linux 安装 Matlab'
slug: install-matlab-on-linux
date: 2017-11-29
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - linux
tags:
  - linux
  - install
keywords:
  - linux
  - install
  - matlab
---

在 Windows 和 Mac 上安装 Matlab 比较容易, 而在 linux 上却并没那么简单了。

<!--more-->

## 安装 Matlab

将安装镜像挂载到 matlab 文件夹, 然后运行 install, 后续安装步骤同 Windows 和 Mac。

```shell
cd ~
mkdir matlab
sudo mount -t auto -o loop <path-to-MATHWORKS_R2017b.iso> matlab/
sudo ./matlab/install
```

## 创建桌面快捷方式

在 `/usr/share/applications` 目录下新建一个 `MATLAB R2017b.desktop` 文件，再使用 vim 或者 gedit 等编辑。

```shell
sudo gedit /usr/share/applications/MATLAB\ R2017b.desktop
```

```desktop
[Desktop Entry]
Type=Application
Name=MATLAB R2017b
Comment=MATLAB R2017b
Exec=/usr/local/MATLAB/R2017b/bin/matlab -desktop
Icon=/usr/local/MATLAB/R2017b/toolbox/nnet/nnresource/icons/matlab.png
StartupNotify=true
Terminal=false
Categories=Development;Matlab;
```

## 注意

若仅按上述方法创建好图标，你会发现它并不能运行。这一切都因为 ~/.matlab 的读写权限。使用上述命令, 可使其正常运行。

```shell
sudo chmod -R a+rw ~/.matlab
```

## arch 上可能遇到的问题

1.点击图标无法打开 matlab

2.doc help 出现下面错误提示

```shell
Exception in thread "XPCOMMessageLoop" java.lang.UnsatisfiedLinkError: /usr/local/MATLAB/R2017b/sys/jxbrowser/glnxa64/xulrunner/xulrunner-linux-64/libxul.so: /usr/lib/libharfbuzz.so.0: undefined symbol: FT_Get_Var_Blend_Coordinates
  at java.lang.ClassLoader$NativeLibrary.load(Native Method)
  at java.lang.ClassLoader.loadLibrary0(ClassLoader.java:1941)
  at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1824)
  at java.lang.Runtime.load0(Runtime.java:809)
  at java.lang.System.load(System.java:1086)
  at com.teamdev.jxbrowser.gecko.xpcom.impl.linux.LinuxMozillaToolkit.c(Unknown Source)
  at com.teamdev.jxbrowser.gecko.xpcom.impl.linux.LinuxMozillaToolkit.a(Unknown Source)
  at com.teamdev.jxbrowser.gecko.xpcom.MozillaToolkit.initialize(Unknown Source)
  at com.teamdev.jxbrowser.gecko.xpcom.AppShellXPCOMThread$b.run(Unknown Source)
```

上面两种错误的解决方法

```shell
cd  /usr/local/MATLAB/R2017b
cd bin/glnxa64
sudo mkdir exclude
sudo mv libfreetype* exclude
cd ../../sys/os/glnxa64
sudo mkdir exclude
sudo mv libstdc++.so.6* exclude
cd
```

## Reference

- https://blog.csdn.net/jesse_mx/article/details/53956358
- https://blog.csdn.net/fx677588/article/details/72844391
- https://stackoverflow.com/questions/45587706/matlab-r2017a-help-browser-no-css
