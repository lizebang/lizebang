---
title: 'Python 的正确打开方式'
slug: python-quick-start
date: 2019-01-26
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - python
tags:
  - python
keywords:
  - python
---

安装环境为 macOS，依赖 Homebrew。`pyenv + pyenv-virtualenv + pipenv + vscode`

<!--more-->

## brew 安装 Python

此处安装的 Python 只是提供给 brew 的其他应用使用，并非我们开发使用的环境。

```shell
brew install python python@2
```

安装完后配置 pip 源，用以加速。

```shell
vim ~/.config/pip/pip.conf

[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```

## brew 安装 pyenv

我们使用 pyenv 来管理 Python 的版本。

```shell
brew install pyenv
```

安装完后进行配置，在 `.bash_profile` 中添加两条配置。

```shell
vim ~/.bash_profile

export PYENV_ROOT=~/.pyenv
eval "$(pyenv init -)"
```

下面介绍了几个常用的 pyenv 命令。

1.列出全部可以安装的版本

```shell
pyenv install -l
```

2.安装指定 Python 版本

```shell
pyenv install 3.6.8
```

3.显示所有本地安装的版本

```shell
pyenv versions
```

4.设置全局 Python 版本

```shell
pyenv global system
```

5.设置当前目录的 Python 版本

```shell
pyenv local 3.6.8
```

6.设置当前 Shell 的 Python 版本

```shell
pyenv shell 3.6.8
```

Python 版本选择的优先级：`shell -> local -> system`

## brew 安装 pyenv-virtualenv

我们使用 pyenv-virtualenv 来管理 Python 项目环境。

```shell
brew install pyenv-virtualenv
```

安装完后进行配置，在 `.bash_profile` 中添加两条配置。

```shell
vim ~/.bash_profile

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "$(pyenv virtualenv-init -)"
```

下面介绍了几个常用的 pyenv-virtualenv 命令。

1.创建虚拟环境

```shell
pyenv virtualenv 3.6.8 <name>
```

2.列举全部虚拟环境

```shell
pyenv virtualenvs
```

3.激活虚拟环境

```shell
pyenv activate <name>
```

4.反激活当前虚拟环境

```shell
pyenv deactivate
```

5.删除虚拟环境

```shell
pyenv uninstall <name>
```

## brew 安装 pipenv

我们使用 pipenv 来管理 Python 项目。

```shell
brew install pipenv
```

安装完后进行配置，在 `.bash_profile` 中添加两条配置。

```shell
vim ~/.bash_profile

export PIPENV_VERBOSITY=-1
alias prpy="pipenv run python"
alias prpi="pipenv run pip"
```

下面介绍了几个常用的 pipenv 命令。

1.创建虚拟环境

```shell
pipenv --python 3.6.8
```

2.安装依赖

```shell
pipenv install <name>
```

3.运行文件

```shell
pipenv run python <file> # prpy <file>
```

## 使用 vscode

[Visual Studio IntelliCode](https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode) + [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

**1.设置 User Settings**

```json
	// python
	"python.jediEnabled": false,
	"python.linting.flake8Enabled": true,
```

**2.创建虚拟环境**

```shell
pyenv virtualenv 3.6.8 <name>
```

**3.设置 Workspace Settings**

```json
{
	"python.pythonPath": "~/.pyenv/versions/<name>/bin/python"
}
```

**4.安装依赖**

```shell
prpi install <name>
```
