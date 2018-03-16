---
title: "Hugo 支持 LaTeX"
date: 2017-12-16
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- hugo
tags:
- hugo
keywords:
- hugo
- latex
---

Hugo 不支持 LaTeX, 这时我们可以使用 MathJAX 和 Mmark 来让 Hugo 支持 LaTeX.

<!--more-->

# 使用 MathJAX

官网介绍 : [https://gohugo.io/content-management/formats#mathjax-with-hugo](https://gohugo.io/content-management/formats#mathjax-with-hugo)

创建文件 footer.html 放置在 layouts/partials/ 目录中.

footer.html 包含一下内容 :

``` html
{{ if .Params.markup }}
<script type="text/javascript" async
src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
MathJax.Hub.Config({
    tex2jax: {
        inlineMath: [['$','$'], ['\\(','\\)']],
        processEscapes: true
        }
        });
        MathJax.Hub.Queue(function() {
            var i, text, code, codes = document.getElementsByTagName('code');
            for (i = 0; i < codes.length;) {
              code = codes[i];
              if (code.parentNode.tagName !== 'PRE' &&
                  code.childElementCount === 0) {
                text = code.textContent;
                if (/^\\\((.|\s)+\\\)$/.test(text) ||
                    /^\$(.|\s)+\$$/.test(text) ||
                    /^\\begin\{([^}]+)\}(.|\s)+\\end\{[^}]+\}$/.test(text)) {
                  code.outerHTML = code.innerHTML;
                  continue;
                }
              }
              i++;
            }});
            </script>
            {{ end }}
```

由于 MathJax 语法与 LaTeX 不完全相同, 所以请仔细 MathJax 命令

使用 Mmark
官网 : [https://gohugo.io/content-management/formats#mmark](https://gohugo.io/content-management/formats#mmark)

有两种方法使用 Mmark :

1. 直接创建以 .mmark 为扩展名的文件

2. 在 markdown 内容前面添加属性 markup: mmark

## 注意

可以使用 `<p> code <p/>` 代替 `$$ code $$` 来防止降价渲染器处理数学代码.