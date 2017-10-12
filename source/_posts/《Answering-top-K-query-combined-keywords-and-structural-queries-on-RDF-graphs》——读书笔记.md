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
本节提出一个frequent star pattern-based index。从G中挖掘出一些常见的星型模式，并为每个星型模式建立一个节点的倒排列表。选择星型的原因是在SPARQL查询常包含星型子查询。
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig6.png %}
如表2，每个实体的谓词以字典序存储，如图6，sequential pattern和star pattern一一对应，使用现有的sequential pattern挖掘算法，如PrefixSpan来挖掘星型模式。

我们不能为每个星型模式建立目录，因此我们我们定义了discriminative ratio。L(S)={v|S occurs in v's adjacent edge seuence}即返回符合星型模式S的所有点v。
> **Definition 4.1. **Given a star S, its discriminative ratio is defined as follows:	
$\gamma (S)=\frac{|L(S)|}{|\cap_{S^{'}\subset S} \,\,L(S^{'})|}$

如果$\gamma (S)$越大，则说明如果保存S的子集作为目录元素的话，就没必要保存S作为目录元素。因此设定$\gamma (S)\le \gamma_{max}$。但对于只有一条边的星型查询，我们始终将其放入目录中。

> **Theorem 4.1. ** Let F denote all selected index elements (i.e., frequent star patterns). Given a SPARQL query Q, a vertex v in graph G can be pruned (there exists no subgraph match of Q containing v) if the following equation holds.	
$v\notin \cup_{S\in F \land S \in Q}L(S)$,
where $S\in F$ means that S is a selected star pattern and $S\in Q$ is a star pattern included in Q.
定义剪枝策略，如果该点不在查询的子结构中，则剪枝。

## 4.2 Candidate generation
先依据Theorem 4.1剪枝掉不可能的点，然后根据变量的predicate sequence在索引找中找到候选点。
> **Definition 4.2. Dummy Vertex.** Given a SPARQL query Q, a vertex v in graph G is called a dummy vertex if the following equation holds.	
$v\notin \cup_{S\in F \land S \in Q}L(S)$,
where F denotes all selected frequent star patterns, $S\in F$ means that S is a selected star pattern and $S\in Q$ is a star pattern included in Q.

搜索时，如果v不是dummy vertex，则执行子图同态算法找到包含v的SPARQL查询的匹配结果。
# 5. Top-k results computation
## 5.1 Graph exploration
目的是找到图中与关键词节点相联系的节点并计算距离。
> **Definition 5.1 Distance between a Vertex and Keyword.** Given a vertex v in RDF graph G and a keyword $w_i$, the distance between v and keyword $w_i$ (denoted as $d(v,w_i)$) is the minimum distance between v and a vertexin $V_i$, where $V_i$ includes all literal vertices containing keyword $w_i$ in G.

{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/alg1.png %}
对每个关键词遍历，然后对于关键词k所在的优先队列使用bfs，搜索邻居，并更新相关变量。
>**Theorem 5.1.** When a queue head (v,p,|p|) is poped from queue $PQ_i$, the following equation holds.
$d(v,w_i)=d[v][i]=|p|$

>**Definition 5.2. Seen by a Keyword.** When queue head (v,p,|p|) is popped from queue $PQ_i$, the distance between v and keyword $w_i$ has been computed. We then say that vertex is *seen* by keyword $w_i$. 
**Definition 5.3. Fully Seen Vertex, Partially Seen Vertex, and Unseen Vertex.

## 5.2. Generatinon of SPARQl matches
找到fully seen vertex v，下一步是计算包含v的SPARQL匹配。
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/alg2.png %}
如算法2所示，我们使用基于DFS的状态转移算法，从fully seen vertex v开始进行匹配处理，对于已经处理过的节点v，因为包含该点的答案都已经得到，所以在处理其他节点时，跳过该点，如图8。
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig8.png %}
> **Definition 5.4.** Given a SPARQL query graph Q with m vertices $u_1,...u_m$, a state is a (partial) match of query graph Q.

{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig7.png %}

## 5.3. Top-k computation
把所有节点计算后，然后取出top-k的答案，太低效，本节设计了early-stop strategy。
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig9.png %}
> **Definition 5.5. Fully Seen Match, Partially Seen Match and Unseen Match.** Given a subgraph match M of SPARQl query Q, if all vertices in M are fully seen vertices, M is called a fully seen match; if M is not a fully seen match and M contains at least one fully seen vertex, it is called a partially seen match. If a match M does not contain any fully seen vertex, it is valled an unseen match.


early-stop strategy：只计算fully seen mateches 的成本，以k-th小的成本作为阈值$\delta$并且计算partially seen matches和unseen matches的下限$\theta_1$和$\theta_2$，当且仅当$\delta <\theta_1 \land\delta <\theta_2$时，提前停止。否则，继续下一轮迭代。
### **Fully Seen Match.** 
按照Definition 2.5计算成本，并维护阈值$\delta$。
### **Partially Seen Match.** 
按以下方式计算下界。
> **Theorem 5.2.** Given a partially seen match M of SPARQL query Q, v is a partially seen or an unseen vertex in the match. The following equation holds.
$Cost(M)=\sum_{1\le i\le n}d(v,w_i)\ge \sum_{d[v] [w_i]\ne null\land 1\le i\le n}d[v] [w_i] +\sum_{d[v][w_i]= null\land 1\le i\le n}|p_i|$
where $[v][w_i]$is the i-th dimension of v's vector corresponding to keyword $w_i$, and $|p_i|$ corresponds to the current queue head $(v,p_i,|p_i|)$ in queue $PQ_i$

依据Theorem 5.2，a partially seen match M的下界为：
> **Definition 5.6** Given a match M of SPARQL query Q, the lower bound of a partially seen match M is defined as follows.
$lb(M)=MIN_{v\in M} (\sum_{d[v] [w_i]\ne null\land 1\le i\le n}d[v] [w_i] +\sum_{d[v][w_i]= null\land 1\le i\le n}|p_i|)$

所有partially seen matches的下界为：
> **Definition 5.7** The lower bound $\theta_1$ for all partially seen matches is as follows.
$\theta_1=MIN_{M\in PS}(lb(M))$
where PS denotes all partially seen matches.

在迭代过程中，一些partially seen matches变成了fully seen matches，阈值$\delta$和$\theta_1$也随之更新。
### Unseen Match.
包含两种点：Partially seen Vertex、 Unseen Vertex.
>**Theorem 5.3.** For an unseen vertex v, if threshold $\delta\ne \infty$, the following equation holds.
$\delta \le \Sigma_{1\le i\le n}d(v,w_i)$

按照Theorem 5.3，unseen match的下限没必要考虑unseen matches。
>**Definition 5.8. ** The lower bound $\theta_2$ for all unseen matches is as follows.
$\theta_2=MIN_{v\in PSet}(\sum_{d[v] [w_i]\ne null\land 1\le i\le n}d[v] [w_i] +\sum_{d[v][w_i]= null\land 1\le i\le n}|p_i|),$
where PSet contains all partially seen vertices, $d[v][w_i]$ is the i-th dimension of v's vector corresponding to keyword $w_i$ and $|p_i|$ corresponds to the current queue head $(v, p_i, |p_i|)$ in queue $PQ_i$.

### Early-stop Strategy.
在每次迭代中，都检查$\delta\le \theta_1 \land \delta \le \theta_2$.如果条件成立，则算法停止。
# 6. Distance-based optimization
算法1使用后向搜索遍历RDF图，为加快搜索，我们提出了pivot-based distance index. 离线时选中一些点作为pivots，预先计算根在pivot的路径，搜索时如果遇到pivot，则利用预存的距离信息，减少搜索空间。
## 6.1 Pivot-based search for top-k results of SK queries

>**Definition 6.1.** Given a shortest path tree T rooted at vertex r (denoted as T(r)), pivot p, and vertex v, if the shortest path between r and v crosses pivot p, we say that v is covered by p in T.
**Theorem 6.1.** if v is covered by p in the shortest path tree T(r), d(r,v)=d(r,p)+d(p,v) where d(r,v) denotes the shortest path distance between r and v.

如图10，T(015)中的点001被pivotcover，d(015,001)=d(015,017)+d(017,001)=2.222.
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/fig10.png %}

{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/alg3.png %}
7-17行和18-20行与算法1的对比。
## 6.2 Pivot selection
>**Definition 6.2.** Given a shortest path tree T(v) rooted at v and a set of pivots PV, the covered ratio is 
$$cr(T(v))=\frac{|\{v^{'}|v^{'}\,\, is\,\,covered\,\, by\,\, p\,\, in\,\, T\,\,and\, \,p\,\, \in\, \,PV\}|}{|V(G)|}$$
**Theorem 6.2.** Given a constant M, finding a pivot set PV to maximize $(\sum_{v\in V(G)}cr(T(v)))$ is a NP-hard problem, where |PV|=M and T(v) denotes the shortest path tree rooted at v.

因此使用一些启发式选择pivots——a high-degree strategy.
## 6.3 Further optimization
后期大部分路径都被计算出来，没必要再去load pivot的最短路径树，因此提供了一个终止loading的条件。
$Cost_{update}=Count_{update}\times Cost_{CPU}$
where $Cost_{CPU}$ is the average CPU cost of a distance update operation.
$Cost_{I/O}$ is the average I/O cost of a distance update operation.
1) if $Cost_{update}\le Cost_{I/O}$，continue to load pivot's shortest path tree.
2) if $Cost_{update}> Cost_{I/O}$，end loading pivot's shortest path tree.
其中$Cost_{CPU}$和$Cost_{I/O}$是常数。
# 7. Experiments
数据集：DBLP,Yago,DBPedia.
Baseline:
	(Effectiveness)BANKS,BANKS,Annotated SPARQL.（分别对应三个数据集）
    (Efficiency) exhaustive computing（第一节有提到）, Basic Search(Algorithm 1), Pivot-based Search(Algorithm 3)
## 7.1 Datasets and setup
Our experiments were conducted on a machine with a 2.4 Ghz Core 2 Duo processor and 80G RAM memory.
## 7.2 Effectiveness study
### 7.2.1 Case Study
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/table3.png %}
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/table4-5.png %}
### 7.2.2. NDCG@k over Yago and DBLP
NDCG——the normalized discounted cumulative gain。
### 7.2.3. MAP over Yago and DBLP
MAP——the mean average precision.
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/table9-10.png %}
## 7.3. Efficiency study
### 7.3.1. Pruning effect of the structure index.
{% qnimg Answering%20top-K%20query%20combined%20keywords%20and%20structural%20queries%20on%20RDF%20graphs/table11-13.png %}
### 7.3.2. Evaluation of pivot selection methods
### 7.3.3. Evaluation of pivot numbers
### 7.3.4. Offline performance
### 7.3.5. Online performance
# 8. Related work
+ SPARQL查询。一些把RDF存储在RDBMS，用join操作回应SPARQL查询。RDF-3x和Hexastore为主谓宾分别创建索引。gStore和AmbER在RDF图中利用子图匹配应答SPARQL，和VF2应答SPARQL查询类似。
+ 关键词查询。
	- 将关键词转换为SPARQL，然后利用SPARQL查询引擎。
    - 找到包含所有关键词的子结构，如tree，clique，或其他。
+ 挖掘常用pattern建立索引。gIndex，gSpan，GADDI。
+ keyword和SPARQL的混合查询。Elbassuoni假定每个三元组都有相联系的文字段落，利用关键词条件扩展SPARQL中的三元组。$CE^2$假定每个资源都有联系的文档，他用关键词条件扩展SPARQL中的变量。但本方法适用范围最广。
+ 其他。[38]中作者为结构化查询中掺杂关键词查询定义了新的查询语言。Bhagdev和Bikakis尝试使用语义进行关键词查询，邹蕾将自然语言转换成SPARQL查询（读过）。
# 9. Conclusions
In this paper, we proposed a new kind of query (the SK query) that integrates SPARQL and keywords. To handle this kind
of query, we first introduced a basic method based on backward search. However, this basic solution faces several performance is- sues. Hence, we built a structural index and a distance-based in- dex. Our structural index is based on frequent star patterns in the RDF data, and our distance-based index is based on the shortest path trees of selected pivots in the RDF graph. Using the indices, we propose an advanced strategy to deal with SK queries. Finally, using three real RDF datasets, we demonstrated that our method can outperform the baseline both with respect to effectiveness and efficiency.





