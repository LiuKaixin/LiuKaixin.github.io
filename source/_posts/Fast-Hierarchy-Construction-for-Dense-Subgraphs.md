title: Fast Hierarchy Construction for Dense Subgraphs
author: 刘凯鑫
date: 2017-11-28 19:36:22
tags:
---
学习建立索引的方法。
2017/11/30 哇给跪了。。。第二章的定义都是什么鬼？！
2017/12/15 放弃了
# ABSTRACT
意义：在稠密子图上建立hierarchy，Peeling算法（k-core,k-truss, nucleus decomposition）对找到稠密子图很有效，但稠密结构的分层表示和k-core, k-truss的正确计算，都被忽略了。
工作：对不同问题定义进行调研，然后提出有效和通用的算法构造k-core, k-truss或nucleus decomposition的层次结构。
Our algorithms leverage the disjoint-set forest data structure to efficiently construct the hierarchy during traversal. 为避免遍历，在peeling访问邻居时，构建子图，并考虑与之前子图的关系。

# 1. INTRODUCTION
真实世界的图是稀疏的，但节点的邻居是稠密的，其聚类系数和传递性也很高。在各种应用中关于稠密子图发现有着众多的文献。举例社交网络，股票市场，DNA等。
peeling algorithms —— k-core, k-truss, nucleus decomposition.
Hierarchy是复杂网络的中心组织原则，对于将图的communities联系起来和洞察一些图的现象十分有用。
peeling algorithms 可支持稠密图的Hierarchy发现。
## 1.1 Problem, Misconception and Challenges
Problem:
1. undirected unattributed graphs.
2. tree -- hierarchy of dense subgraphs.
3. node -- subgraph, edge -- containment relation, root -- entire graph.
4. aim -- find hierarchy using peeling algorithms.

Misconception in the literature:
Recent studies on peeling algorithms has interestingly overlooked the connectivity condition of k-cores and k-trusses.

Challenges:
cost of traversals and hierarchy construction.
k-core, k-truss, nucleus decompositions需要在遍历图之后进行。层次结构需要在得到k-core, k-truss, nucleus decomposition之后。但在整个图上一次遍历时，对嵌套结构进行遍历并不容易。
## 1.2 Contributions
1. Thorough literature review.指出现有文献在k-core和k-truss定义上的误解，并指出缺少hierarchy的理解，它的成本和peeling过程相当。
2. Hierarchy construction by disjoint-set forest: 使用不相交的森林数据结构跟踪出现在层次结构树中相同节点中不相交的子结构。通过特定的顺序处理子图，将不相交集的森林结合到层次树中。
3. Avoiding traversal: 构建层次结构时不用遍历。在peeling过程中，在访问邻居时构建子图，并记录和之前子图的关系。对记录的关系应用轻量的post-processing得到hierarchy。
4. Experimental evaluation:
{%qnimg Fast%20Hierarchy%20Construction%20for%20Dense%20Subgraphs/table1.png%}
# 2. PERLIMINARIES
## 2.1 Nucleus decomposition
{%qnimg Fast%20Hierarchy%20Construction%20for%20Dense%20Subgraphs/table2.png%}
G——an undirected and simple graph.
$K_r$——an r-clique.
{%qnimg Fast%20Hierarchy%20Construction%20for%20Dense%20Subgraphs/def1.png%}
这个定义感觉挺厉害的，是一般情况下(r=1，s=2)节点的度和连通性的generalization。
{%qnimg Fast%20Hierarchy%20Construction%20for%20Dense%20Subgraphs/def2.png%}
举例：若r=2，s=3：则每个边至少在k个三角形中，而且每个边被三角形联通。

For an r-clique $K_r$ u, $w_s(u)$ denotes the $K_s$-degree of u. For a subgraph $H\subset G, w_{r,s}(H)$ is defined as the minimum $K_s$-degreee of a $K_r$ in H, i.e., $w_{r,s}(H)= min\{w_s(u): u\in H\}$.
{%qnimg Fast%20Hierarchy%20Construction%20for%20Dense%20Subgraphs/def3.png%}
[^_^]:**这里的$k=w_{r,s}(H^u)$而且$\lambda_s(u)=w_{r,s}(H^u)$，然后k是$k_s$的数量，$\lambda_s(u)$是k-(r,s)的数量，但是**
{%qnimg Fast%20Hierarchy%20Construction%20for%20Dense%20Subgraphs/cor1.png%}

















