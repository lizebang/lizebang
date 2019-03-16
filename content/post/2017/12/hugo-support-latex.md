---
title: "Hugo 支持 LaTeX"
slug: hugo-support-latex
date: 2017-12-16
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - tool
tags:
  - tool
keywords:
  - hugo
  - latex
---

Hugo 不支持 LaTeX，这时我们可以使用 MathJAX 和 Mmark 来让 Hugo 支持 LaTeX。

<!--more-->

## 使用 MathJAX

创建文件 footer.html 放置在 layouts/partials/ 目录中。

footer.html 包含一下内容，以下内容来自 https://raw.githubusercontent.com/laozhu/hugo-nuo/master/layouts/partials/footer.html

```html
<script
	async
	src="//cdn.bootcss.com/mathjax/2.7.2/MathJax.js?config=TeX-AMS-MML_HTMLorMML"
></script>
<script type="text/x-mathjax-config">
	MathJax.Hub.Config({
	  tex2jax: {
	    inlineMath: [['$','$'], ['\\(','\\)']],
	    displayMath: [['$$','$$'], ['\\[','\\]']],
	    processEscapes: true,
	    processEnvironments: true,
	    skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
	    TeX: { equationNumbers: { autoNumber: "AMS" },
	    extensions: ["AMSmath.js", "AMSsymbols.js"] }
	  }
	});
</script>
<script type="text/x-mathjax-config">
	// Fix <code> tags after MathJax finishes running. This is a
	// hack to overcome a shortcoming of Markdown. Discussion at
	// https://github.com/mojombo/jekyll/issues/199
	MathJax.Hub.Queue(() => {
	  MathJax.Hub.getAllJax().map(v => v.SourceElement().parentNode.className += ' has-jax');
	});
</script>
```

由于 MathJax 语法与 LaTeX 不完全相同，所以请仔细 MathJax 命令。

### 注意

可以使用 `<p> code <p/>` 代替 `$$ code $$` 来防止降价渲染器处理数学代码。

## Reference

- https://gohugo.io/content-management/formats#mathjax-with-hugo
- https://github.com/laozhu/hugo-nuo
- https://gohugo.io/content-management/formats#mmark
