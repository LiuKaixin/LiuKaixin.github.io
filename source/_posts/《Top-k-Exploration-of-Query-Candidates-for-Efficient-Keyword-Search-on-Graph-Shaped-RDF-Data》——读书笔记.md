title: >-
  《Top-k Exploration of Query Candidates for Efficient Keyword Search on
  Graph-Shaped (RDF) Data》——读书笔记
author: 刘凯鑫
tags: []
categories: []
date: 2017-09-25 09:55:00
---
*首先，初步确定一下本周的规划，今明两天读本篇论文，以及回顾之前的论文（按照师兄说的方式进行泛读），然后周三周四学习斯坦福的课程。周五将没有整理的论文整理完全，周六日搞定本篇和上篇论文。*
# Abstract
从关键词中计算出queries之后，让用户选择合适的，然后送入数据库引擎进行查询。另外对于queries的计算，提出了找top-k子图的新型算法。

# 1. Introduction
提出关键词这样的搜索一直以来都是研究的重点。	
Labelled query model：不需要用户对结构有任何的了解，只是单纯的将关键词和“labels”联系起来。	
现在关键词搜索的主要思路：将关键词映射到data elements（很多使用精确匹配），搜索连接关键词的elements的子图（如Blinks中的distinct root assumption），基于得分函数（被提出了很多，从路径长度到IR中的复杂度量）输出top-k个子图（需要计算每个选项的上限和下限）。任务可分为四个：
1. keyword mapping.
2. graph exploration.
3. scoring.
4. top-k computation.
本方法结合了语法和语义相似度，因此IR概念支持模糊匹配。本文贡献如下：
+ **Keyword Search through Query Computation ** 将关键词转化为结构化查询的元素（而不是答案的一部分），让用户选top-k个查询中的一个（而不是直接把top-k个答案给出）。
+ **Algorithms for Subgraph Exploration** 当前的方法通常将关键词映射到节点，算法计算出树形的答案。但关键词也可能映射到边，所以答案结构也不一定是树。
+ **Efficient and Complete Top-k through Graph Summarization** 很难簿记计算top-k所需的信息，现在的方法不能确保结果是真正的top-k。因此我们引入了复杂的数据结构保存所有候选的得分。为了效率，利用摘要图进行剪枝。
# 2. Problem Definition
**Data**
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/Definition1.png %}
**Queries**
用户的查询$Q_U$就是关键词集合，系统的查询$Q_S$是conjunctive queries.
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/Definition2.png %}
**Answers**
就是把查询中的distinguished variables 替换成子图中的节点。
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/Definition3.png %}











