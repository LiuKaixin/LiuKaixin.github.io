title: '《Keyword Search in Graphs: Finding r-cliques》——读书笔记'
author: 刘凯鑫
tags:
  - Keyword
  - 2017年9月
categories:
  - 论文笔记
date: 2017-08-24 11:18:00
---
*冷静一下重新去看这个论文，现在还不是提速的时候。慢慢来*
# ABSTRCT
图上的关键词搜索是找到一个包含所有关键词的子结构，之前的工作都是找最小连通图（connected minimal trees），而现在发现找子图比找子树对用户来说更有用。子树中的关键词节点（content nodes）彼此间可能并不紧连，另外，在找子树时会遍历整个图而不仅是关键词节点。	
An r-clique is a group of content nodes that cover all the input keywords and the distance between each two nodes is less than or equal to r.
# 1. INTRODUCTION
 > [keyword search in databases.](http://www.morganclaypool.com/doi/pdf/10.2200/S00231ED1V01Y200912DTM001)是联通子树（这是一本书，我没看。。。）。李国良的文章[Ease: Efficient and adaptive keyword search on unstructured, semi-structured and structured data](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.184.8489&rep=rep1&type=pdf) 的答案是半径不大于r的斯坦纳树。
 
以前基于树或图的方法存在的问题：
1. 一些关键词节点（content nodes）相距太远。
2. 对所有的节点遍历，时间和空间复杂度都很高。

使用r-cliques的优点：
1. 所有关键词节点相距很近。
2. 无需遍历所有节点。

举例说明：
{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/fig1.png%}
{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/fig2.png%}
关键词：James, John, Jack。 r=10。
图2(a)中的答案比图2(c)中的更加合理，因为三个点在同一个组织。另外三边之和也是图2(a)更小。但是对于用文献[13](http://dl.acm.org/citation.cfm?id=1547515)生成的两者的斯坦纳树，结果相反。

本文贡献：
1. 提出一个新的图关键词搜索的模型。
2. 证明找到有最小权重的r-clique是NP-hard问题。
3. 基于Branch和Bound的算法找到所有的r-cliques。
4. 提出一个找2个近似度的r-cliques的近似算法，能在多项式时间内以升序找到所有的r-clique。
5. 为了找到某个r-clique中的节点的关系，提出在图中找连接r-clique中节点的斯坦纳树。

>[Exact Top-k Nearest Keyword Search in Large Networks](http://dl.acm.org/citation.cfm?id=2749447)
There are other keyword search problems that are of some different characteristics. The general idea of keyword search is to find a subgraph in a given graph that contains the query keywords. 
The subgraph can be of the form of a tree in some cases. 
+ BANKS in [5] converts a relational database into a graph and answers to keyword queries are directed subtrees in the graph. Given a directed graph, the keyword search in [16] returns top ranked subtrees in the graph that cover the query keywords. 
+ Blinks [18] also considers directed graph and given a keyword query, an answer is a subtree in the graph that covers the keywords and the root of the subtree can reach all the keywords. Top-k results are top k subtrees with different roots. 
+ The graph type of r-clique is introduced in [21] as the form of expected answers. An r-clique is a set of vertices in the given graph which covers the given query keywords and the distance between any pair of the vertices in this set is no longer than r. Both exact and approximate algorithms have been proposed in [21]. Querying the neighbors of a vertex in a compressed social network is considered in [24]

>[Efficient processing of keyword queries over graph databases for finding effective answers](http://www.sciencedirect.com/science/article/pii/S0306457314000727#b0155)一篇较新的关于树形的文章。
+ the minimal Steiner tree semantics.将答案树的权重定义为边的和，所以问题就转化成optimal group Steiner tree problem.有些人用启发式的规则得到l倍近似的结果（l是关键词数目）；有人用dp...但这些方法并不能有效的在大图上得出top-k Steiner tree-stuctured answers.
+ distinct root semantics.答案树的权重为根节点到关键词节点的最短路径之和，每个根节点只有权重最小的答案树被作为候选。因此，对于n个点的图，至多有n个答案，所以比斯坦纳树更高效（这里没懂）。
+ 之前的工作限制着包含一个关键词的节点个数有且只有一个，本文中答案树包含一个关键词的节点可能有多个。


> [Survey on Keyword Search over XML Documents](http://dl.acm.org/citation.cfm?id=3022863)  该文第3章提出对于XML关键词搜索基于图的方法。
1. Subtree based Semantics for **Directed** Graphs.
	+ the minimal Steiner tree semantics. [Keyword proximity search in complex data graphs.](http://delivery.acm.org/10.1145/1380000/1376708/p927-golenberg.pdf?ip=166.111.134.52&id=1376708&acc=ACTIVE%20SERVICE&key=BF85BBA5741FDC6E%2E587F3204F5B62A59%2E4D4702B0C3E38B35%2E4D4702B0C3E38B35&CFID=882572412&CFTOKEN=29985573&__acm__=1505267509_337f555665e22704b8e4b8b45b2f64af)
    + the distinct root semantics. [BLINKS: ranked keyword searches on graphs](http://dl.acm.org/citation.cfm?id=1247516)
2. Subgraph based Semantics for **Undirected** Graphs. (方法的优劣暂且不论，其应用在无向图，但RDF是有向图)
	+ r-radius semantics. [EASE: Efficient and adaptive keyword search on unstructured, semi-structured and structured data.](http://dl.acm.org/citation.cfm?id=1376706)（2008）
    + r-clique semantics. [Keyword search in graphs: finding r-cliques](http://dl.acm.org/citation.cfm?id=2021025)（2011）
    + minimum cost connected tree. [Finding top-k min-cost connected trees in database.](http://ieeexplore.ieee.org/abstract/document/4221732/)（2007）
3. Bi-directed Tree based Semantics for Directed Graphs
BANKS和[Bidirectional expansion for keyword search on graph databases](http://dl.acm.org/citation.cfm?id=1083652)（2005）返回有前向边或后向边的子树。[Finding and approximating top-k answers in keyword proximity search](http://dl.acm.org/citation.cfm?id=1142377)返回混合了前向边和后向边的子树。（2006）