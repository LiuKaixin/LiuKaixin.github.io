title: >-
  《Answering top-K query combined keywords and structural queries on RDF
  graphs》——读书笔记
author: 刘凯鑫
tags:
  - 2017年9月
categories:
  - 论文笔记
  - ''
date: 2017-09-04 20:36:00
---
# ABSTRACT
虽然SPARQL是RDF图上优越的查询语言，但一些查询意图仍无法使用SPARQL句法表达。关键词搜索虽然能够直观表示信息的需求，但表达准确度较低。为了综合两者的优点，提出了混合查询SK query，并使用基于结构化索引的新型查询算法加速查询。为了更进一步提高SK查询的效率还使用了基于距离的优化技术。
# 1. Introduction
目前RDF图十分流行，图1是Yago知识图谱的一个例子。
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig1.png %}
SPARQL基于子图匹配，是查询RDF数据的标准方法。但是由于用户不了解RDF的schema，所以查询的实体和谓词并不能和数据库中対映。
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig2-3.png %}
关键词查询是说明信息需求更直观的方法，但也常得到一些无意义的答案。
因此本文结合两者的优点提出SK query，其结果是最接近所有关键词的k个SPARQL结果。我们假设关系的强度依赖于路径长度，另外不同的谓词也应该有不同的权重。	
该问题的另一个挑战是搜索效率，穷举法的流程如下：	
1. 用现有技术找出所有匹配的子图。
2. 计算匹配子图和包含关键词的点间的最短路径。
3. 找到路径最短的作为答案。

但该方法太低效，我们为SPARQL查询Q设计了一个下限以尽早结束搜索，另外为结构化剪枝提出一个星型索引。提出一个基于距离的优化加速最短路径距离的计算——选择一些中心点，并使最短路径树以这些点为根；如果搜索到了中心点p，则可以使用根在p的最短路径减少搜索空间。	
本文贡献：
1. 提出一个新的查询模式——SK query，结合了SPARQL和关键词，并提供了解决方法。
2. 提出星型索引并实现最短路径树（基于距离的优化）以减少搜索空间和提高查询性能。
3. 实验。

# 2. Background
##  2.1 Preliminaries
> **Definition 2.1. ** An RDF data graph G is denoted as < V(G), E(G), L>, where (1) $V(G)= V_L \cup V_E \cup V_C$ is the set of vertices in RDF graph G ($V_L,\, V_E,\, V_C$ denote literal, entity and class vertices); (2) E(G) is the set of edges in G; and (3) L is a finite set of edge labels, i.e. predicates.
**Definition 2.2. ** An SK query is a pair < Q,q>, where Q is a SPARQL query graph, and q is a set of keywords $\{w_1,w_2,...,w_n\}$.

对于SK query < Q,q>，查询结果是$< M,\{ v_1,v_2,...,v_n\} \>$, 其中M是Q的子图匹配，$v_i$是包含关键词$w_i$的literal vertex。
>**Definition 2.3.** Given a result $r=< M,\{v_1,v_2,...,v_n\}>$, the cost of r is defined as follows:	
$$Cost(r) =Cost_{content}(r)+Cost_{structure}(r)$$.
**Definition 2.4.** Given a result $$r=< M,\{v_1,v_2,...,v_n\}>$$, the content cost of r is defined as follows:	
$$Cost_{content}(r)=\sum^{i=n}_{i=1}C(v_i,w_i)$$, 
where $C(v_i,w_i)$ is the matching cost between $v_i$ and keyword $w_i$.

结构成本只考虑SPARQL查询中的变量——理由: 用户更感兴趣。（我感觉这并不科研）


>**Definition 2.5.** Given a result $$r=< M,\{v_1,v_2,...,v_n\}>$$, the distance between match M and vertex $$v_i$$ is defined as follows:	
$$d(M,v_i)=MIN_{v\in M}\{d(v,v_i)\}$$
其中v是M中和SPARQL查询中某个变量相关的点$ d( v, v_i ) $是v和G中$v_i $的最短距离。结果r的结构成本：	
$Cost_{content}(r)=\sum^{i=n}_{i=1} C(v_i,w_i) $

(**Problem Definition**) Given an SK query &lt;Q,q&gt; and parameter k, our problem is to find the k results that have the k-smallest costs.

## 2.2 Predicate salience 
本文使用最短路径距离评估关系强度。一般的最短路径距离不区分谓词，把"type"、"label"等和普通谓词同等看待不合理。因此引入了predicate salience：	$$ps(p)=\frac{|V(p)|}{|V(G)|}$$
# 3. Overview
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig5.png %}
**Keyword Mapping.** 离线时，为每个关键词建立倒排列表。在线时，根据倒排列表获取关键词对应的节点。对于关键词节点，在给定查询上的常用度量是TF/IDF成本。参考文献中有很多成本函数，我们选择其中一种计算包含关键字的节点的成本。
本文中主要关心如何找到SPARQL的匹配以及和关键词之间的关系。我们使用现有的IR引擎分析给定的关键词，并执行不精确匹配得到一些语法或语义相似的元素。
**Candidate Generation. **如果找到能到达所有关键词的节点，则需要使用子图同态检查SPARQL的子图匹配是否包含该点。此步采用“filter-and-refine”策略，首先找到一些没有在任何Q的子图匹配中出现的dummy节点，如果搜索到dummy节点则不执行子图同态。
本文提出一种frequent star pattern-based structural index。基于该索引可以为SPARQL查询的变量提供候选列表。
**Top-k Results Computation. **基于图搜索，循环地计算关键词节点与邻居的距离，找到一个能达到所有关键词的节点，如果不是dummy vertex，则使用SPARQL matching算法。

# 4. Candidate generation based on the structural index
## 4.1 Structural index
本节提出一个frequent star pattern-based index。从G中挖掘出一些常见的星型模式，并为每个星型模式建立一个节点的倒排列表。选择星型的原因是在SPARQL查询常包含星型子查询。星型模式的挖掘使用现有的sequential pattern挖掘算法，如PrefixSpan。	
我们不能为每个星型模式建立目录，因此我们我们定义了discriminative ratio。
> **Definition 4.1. **Given a star S, its discriminative ratio is defined as follows:	
$\gamma (S)=\frac{|L(S)|}{|\cap_{S^{'}\subset S} \,\,L(S^{'})|}$

如果$\gamma (S)$越大，则说明如果保存S的子集作为目录元素的话，就没必要保存S作为目录元素。因此设定$\gamma (S)\le \gamma_{max}$。但对于只有一条边的星型查询，我们始终将其放入目录中。

> **Theorem 4.1. ** Let F denote all selected index elements (i.e., frequent star patterns). Given a SPARQL query Q, a vertex v in graph G can be pruned (there exists no subgraph match of Q containing v) if the following equation holds.	
$v\notin \cup_{S\in F \land S \in Q}L(S)$,