---
title: '使用 Hugo + Github Pages 搭建个人博客'
slug: hugo-github-pages-personal-website
date: 2017-11-02
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - hugo
tags:
  - hugo
keywords:
  - hugo
  - github pages
  - blog
---

Hugo 是一个快速灵活的静态网站生成器。Github Pages 是面向用户、组织和项目开放的公共静态页面搭建托管服务，站点可以被免费托管在 Github 上。

<!--more-->

## 安装 hugo

我在这里只介绍 Mac 的安装方法，直接使用 brew install hugo 进行安装。hugo 在 Windows 和 Linux 都有不同的安装方法，hugo 还可以使用源码安装，具体详见官网介绍。

## 搭建博客

1.使用命令 `hugo new site [site name]` 就可以创建一个文件夹，进入这个文件夹，我们可以看到 hugo 已经帮我们创建好了目录。其中有这么三个目录：

```shell
hugo new site lizebang
cd lizebang
```

`content`：我们可以将 md 文件放在这里面

`static`：我们可以将背景、头像等存到这里面

`theme`：我们可以将喜欢的主题放到这里面

2.我选着的主题是 `hugo-tranquilpeak-theme`，克隆到 theme 文件夹。为了方便，可以使用示例提供的配置文件（一般在主题 `exampleSite` 目录下）再加以修改。

```shell
git clone https://github.com/kakawait/hugo-tranquilpeak-theme.git themes/hugo-tranquilpeak-theme
cp themes/hugo-tranquilpeak-theme/exampleSite/config.toml .
```

3.此命令可以在 [http://localhost:1313/](http://localhost:1313/) 预览博客的效果。

```shell
hugo server
```

4.此命令会生成一个名为 public 的文件夹，这就是我们要部署到 GitHub 上到文件。

```shell
hugo
```

注意：3 和 4 两条命令都需要在博客根目录下才能运行。

### 警告

config.toml 中一定要设置 canonifyURLs = true，并将 baseURL = "your-blog-url" 设置好，否则你将会遇到诸如 CSS 无法载入等问题。

## 部署到 Github

创建一个名为 (your-github-usrname).github.io 的 repository。然后，将仓库克隆到本地，将 public 中的文件复制到仓库中提交到 master 分支。

最后，访问 `https://<your-github-usrname>.github.io/` 就可以了。

## Reference

- https://gohugo.io/getting-started/installing/
- https://gohugo.io/content-management/urls/#canonicalization
- https://gohugo.io/hosting-and-deployment/hosting-on-github/
