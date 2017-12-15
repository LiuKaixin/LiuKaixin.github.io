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
*这个文章看样子是改了好多其他人的算法，我觉得可以好好看看他是怎么改别人的，学习一波。。。。然后改了他的*
# ABSTRCT
图上的关键词搜索是找到一个包含所有关键词的子结构，之前的工作都是找最小连通图（connected minimal trees），而现在发现找子图比找子树对用户来说更有用。子树中的关键词节点（content nodes）彼此间可能并不紧连，另外，在找子树时会遍历整个图而不仅是关键词节点。	
An r-clique is a group of content nodes that cover all the input keywords and the distance between each two nodes is less than or equal to r.
# 1. INTRODUCTION
 > [keyword search in databases.](http://www.morganclaypool.com/doi/pdf/10.2200/S00231ED1V01Y200912DTM001)是联通子树（这是一本书，我没看。。。）。李国良的文章[Ease: Efficient and adaptive keyword search on unstructured, semi-structured and structured data](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.184.8489&rep=rep1&type=pdf) 的答案是半径不大于r的斯坦纳树。
 
 关键词搜索在结构化数据上$\uparrow$。结构化数据$\rightarrow$图。
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
4. 提出一个找2-approximation r-cliques的近似算法，能在多项式时间内以升序找到所有的r-clique。
5. 为了找到某个r-clique中的节点的关系，提出在图中找连接r-clique中节点的斯坦纳树。

# 2. RELATED WORD
基于树的算法
+ Keyword searching and browsing in databases using banks.——基于后向搜索产生斯坦纳树的算法。
+ Keyword searching and browsing in databases using banks.——动归寻找斯坦纳树的算法。
+ Keyword proximity search in complex data graphs.——多项式内寻找生成斯坦纳树。
+ Bidirectional expansion for keyword search on graph databases.——生成不同根的子树。
+ Blinks: ranked keyword searches on graphs.——使用更有效地索引。

基于图的算法
+ Ease: Efficient and adaptive keyword search on unstructured, semi-structured and structured data.——寻找包含所有关键词的r-radius的斯坦纳图。但如果一些高排名的子图被包含在其他大图中，该方法会遗漏。另外还产生重复和冗余的结果。
+ Querying communities in relational databases.——寻找多中心的子图（communities），每个content节点到每个中心点距离存在小于$R_max$的路径。排序方式：中心点到所有content节点的路径长度的最小值。
+ 本方法解决了community方法的三个问题：
	- r-cliques保证所有content nodes紧邻。
    - 只搜索content nodes提高运行效率。
    - 通过生成斯坦纳树减少不相干的节点。

本方法来源：
Minimum-diameter covering problems.——与文中Multiple Choice Cover问题很相关。
Finding a team of experts in social networks.——上文算法中的一个应用。
两者都是找单个答案。本文找top-k，用所有点对间的距离作为得分函数。
本方法和Finding a team of experts in social networks.中的图模式匹配问题相似。
# 3. PROBELM STATEMENT
本文中只考虑**有权无向图**，但很容易应用到有向图中（在判断r的时候再当成无向图）。
{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/def1_2.png%}

> Problem 1. Given a distance threshold r, a graph G and a set of input keywords, find an r-clique in G whose weight is minimum.
> Theorem 1. Problem1是NP-hard的。

# 4. BRANCH AND BOUND ALGORITHM
分支定界法：基于系统的枚举并使用距离限制r，并不排序。
{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/alg1.png%}
先构造关键词的倒排列表，然后把第一个关键词的所有节点加入rList，然后依次加入其它关键词的候选节点，检查是否能和rList中保存的结构成为r-clique，如果可以则加入。
为加速算法，预存了所有点对之间的距离。算法复杂度为$O(l^2|C_{max}|^{l+1})$。l代表关键词数量，$C_{max}$为$C_i$的最大size。
# 5. POLYNOMIAL DELAY ALGORITHM
分支定界法慢而且不排序。
## 5.1 Main Procedure
本算法改编自 E. Lawler. A procedure for computing the k best solutions to discrete optimization problems and its application to the shortest path problem（这个文章是J. Yen. Finding the k shortest loopless paths in a
network.的后延）.
Lawler的算法：搜索空间先被划分为互补相交的子空间，然后子空间的答案被生成当前全局最优的答案。然后得到最优答案的子空间接着被划分。。。有两个关键问题：怎么划分子空间（和[13](http://ieeexplore.ieee.org/document/4812449/#full-text-section)相似）&如何在子空间中找最佳答案。
{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/alg2.png%}
**如果一个节点只包含一个关键词，则生成无重复的答案。（为什么？）如果包含多个关键词，则需要进行剪枝。**


{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/table1.png%}
如果最佳答案是${v_1,v_2,v_3,v_4}$，则如table1去划分子空间，然后分别在四个子空间找到最优答案，然后对包含四个中最优答案的子空间再次进行划分，如此循环~
## 5.2 Finding Best Answer from a Search Space
{%qnimg Keyword%20search%20in%20graphs%20Finding%20r-cliques/alg3.png%}
对搜索空间中的每个点都计算其到其他关键字节点集合的最短距离$d(s^i_j,k)$，以及集合中对应的节点$n(s^i_j,k)$（3-6初始化，7-16计算），然后对每个点判断是否符合r-clique的定义，如果符合，则加入到候选集合中，最后取出top-k。
算法复杂度$O(l^2|S_{max}|^2)$



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