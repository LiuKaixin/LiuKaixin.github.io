title: hexo博客编写
author: 刘凯鑫
tags: []
categories:
  - 关于博客
date: 2017-09-27 17:24:00
---
需参考网站：https://github.com/zhaoqingqing/zhaoqingqing.github.io

昨儿晚上和今天下午都在搞我的博客，本来想搞多终端同步，结果莫名其妙的hexo-admin的deploy功能不能使用了，然后重装了好几次，都没有成功，心里很烦躁。现在冷静下来之后决定用命令去deploy，然后得空去学习js，看看这些东西怎么操作吧。

博客的编写发布主要参考 https://righere.github.io/2016/10/10/install-hexo/
首先把hexo分支git clone到本地，然后npm install安装hexo。
编辑blog还是用hexo-admin
然后使用git add .   git commit -m "改了啥"， git push origin hexo将本地仓库同步到远程
发布使用命令hexo d -g。

其他终端先pull，之后进行接下来的操作。心好累，弄了半天还是没有什么结果。先暂且这么用着吧。

10月8日  数学公式有问题，按照http://xudongyang.coding.me/math-in-hexo/ 修改。