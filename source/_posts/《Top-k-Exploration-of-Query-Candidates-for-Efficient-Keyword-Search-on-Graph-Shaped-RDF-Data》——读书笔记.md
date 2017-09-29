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
**Problem**		
主要考虑conjunctive queries的计算。
# 3. Overview of the Approach
首先举例几个关键词，指出他们之间的连接需要推断关键词之间的连接。以往的工作使用图的schema来推断。本文的方法如下：	
**Query Computation** 
1. keyword通过映射得到keyword elements。
2. 通过图的搜索将keyword elements连接起来找到connecting element。
3. connecting element与keyword elements之间的路径构成了matching subgraph。
4. 对于每个子图，通过graph elements到query elements的映射得到conjunctive query。
**Preprocessing**	
预处理得到keyword index，用于keyword-to-element映射。
为了图搜索，建立graph index——原始图的摘要。
the augmented index 可以推导query中谓词、常量和结构。
**Running Example**

{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/fig1.png %}
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/fig2.png %}
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/fig3.png %}
# 4. Indexing Graph Data
## A. The Keyword Index
关键词可能指C-vertices，E-vertices，V-vertices或 edges，但在构建索引时忽略E-vertices因为用户不太可能直接输入E-vertex的URI。
keyword index 就是一个keyword-element映射，但是对于V-vertex和A-edge所存储的结构比较特殊。
为了识别不予数据元素的标签严格匹配的关键词，keyword-element 实现为一个倒排列表。首先对labels进行分析得到其terms，然后利用WordNet得到terms的同义词，上位词和下位词。所以语义相似的graph element会被检出，并用Levenshtein距离度量keywords到terms的语法相似性。
## B. The Graph Schema Index
用作搜索连接keyword elements的子结构。
之前的文章在全图进行搜索，本文旨在从边推出查询结构，从点推出常量（变量）。
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/Definition4.png %}
A-edges和V-vertices并不会有助于连接keyword elements，除非他们就是keyword elements。
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/Definition5.png %}

构建$G^{'}_K$需要利用来自映射的数据结构，即[V-vertex, A-edge, $(C-vertex_1,...,C-vertex_n)$]和(A-edge, C-vertex)。为了关键词能够匹配V-vertex，将A-edge$(C-vertex_i,V-vertex)$加入$G^{'}$;为了关键词能够匹配A-edge，将A-edge$(C-vertex_i,Value)$加入$G^{'}$.
# 5. Scoring
介绍了一些得分函数，如PageRank（为节点打分），最短路径（为路径打分），TF/IDF（为keyword element打分）。
对于图来说，其由路径构成，其成本函数如下：
$$C_G=\sum_{p_i\in P}C_{p_i}$$
而路径由其elements组成：
$$C_{p_i}=\sum_{n\in p_i}c(n)$$
**Path Length** 假设用户所需的实体紧密相连。其得分函数为$C_1=\sum_{p_i\in P}\sum_{n\in p_i}1$
**Popularity Score** 计算摘要图中element的popularity，越流行则在路径中贡献越小。
$C_2=\sum_{p_i\in P}\sum_{n\in p_i}c(n)$，其中对于点v，$c(v)=1-\frac{|v_{agg}|}{|V|}$，对于边e，$c(e)=1-\frac{|e_{agg}|}{|E|}$。
|V|：摘要图中点的总数。
$v_{agg}$：graph index 中聚集在一个C-vertex的E-vertex的数量。
|E|：摘要图中边的总数。
$e_{agg}$：摘要途中聚集在一个R-edge的R-edge的数量。
**Keyword Matching Score** 
$C_2=\sum_{p_i\in P}\sum_{n\in p_i}\frac{c(n)}{S_m(n)}$
$S_m(n)$代表element n的得分，对于Keyword element，范围是[0,1]，其他元素则一律设置为1。其从语法语义两方面考虑，得分越高则路径的成本越小。

前两个可以离线计算，因为element在不同路径的话，会计算多次，所以其更倾向于Keyword elements紧密连接的子图。

# 6. Computation of Queries

对于查询计算，有五个任务：
1. mapping of keywords to data elements.
2. augmentation of the summary graph.
3. exploration of the graph to find subgraphs connecting the keyword elements.
4. top-k processing.
5. generation of the query for the top-k subgraphs
前两个已经解决，本节解决3-5.
## A. Algorithms for Graph Exploration
首先定义最小匹配子图：
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/Definition6.png %}
一个条件定义包含所有关键词，另一个确保联通。
与现有的搜索算法进行对比。
**Backward Search** 从Keyword elements出发迭代地沿入边访问elements直到找到一个connecting element，即answer root。
**Bidirectional Search** 该方法认为从一些顶点可以通过跟随传出而不是传入边缘来更快地达到答案根。故使用启发式激活因子来估计边缘将到达answer root的可能性。这些因子是从一般图形拓扑和已经探索的元素得出的。虽然其在很多情况下表现很好，但最差性能无法保证。
**Searching with Distance Information** 通过存储在索引中的附加连接信息保证最差性能是m-optimal。在每次迭代中，通过该信息可确定能够达到keyword element的elements以及最短的距离，从而有目标的进行搜索。不过构建这些信息十分费力。

因为关键词也有可能对应边，所以查询出的结果不再是树，而是图。成本来自于两方面：query-independent，query-specific。索引技术只能解决query-independent的成本。
## B. Search for Minimal Matching Subgraph
{%qnimg Top-k%20Exploration%20of%20Query%20Candidates%20for%20Efficient%20Keyword%20Search%20on%20Graph-Shaped%20%28RDF%29%20Data/alg1.png %}
**Input and Data Structures** 











