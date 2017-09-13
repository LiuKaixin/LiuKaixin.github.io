title: 《Scalable Keyword Search on Large RDF Data》——论文笔记
author: 刘凯鑫
tags:
  - 2017年8月
  - Keyword
  - RDF
categories:
  - 论文笔记
  - ''
date: 2017-08-20 13:10:00
---
# Abstract
目前关键词搜索的两种方法：一、依赖建立距离矩阵来剪枝搜索空间，二、为RDF图建立摘要。本文指出现有技术面对真实数据集时的不足，并且提出一个新的摘要算法，能够更有效的剪枝并得到正确的答案。
# 1 Introduction
+ 动机：RDF数据急速增长。关键词搜索对大规模数据十分有用，目前对于RDF数据的解决方法的局限：
	- 返回不正确的答案。
    - 难以处理大规模RDF数据。	
+ 目标：设计一个能处理大规模RDF数据集的scalable and exact soluton。
+ 贡献：
	- identify and address limitations in the existing methods for keyword search in RDF data. 并基于后向搜索提出一个正确的baseline解法。
    - develop efficient algorithms to summarize the structure of RDF data, based on the types in RDF graohs. 和之前的方法相比more scalable剪枝也更有意义，并且得到的摘要是轻量级的而且可更新。
    - experiments on both benchmark and large real RDF datasets.
    
# 2 Preliminaries
将RDF数据集看做RDF图G=(V,E)其中
+ $V=\{V_E,V_T,V_W\}$
	- $V_E$: the set of entity vertices.
	- $V_T$: the set of type vertices.    
	- $V_W$: the set of keyword vertices.    
+ $E=\{E_R,E_A,E_T\}$
	- $E_R$: the set of entity-entity edges.
	- $E_A$: the set of entity-keyword edges.
	- $E_T$: the set of entity-type edges.
    
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig1.png %}	
图1中主要结构被entity-entity edge即$E_R$捕获，因此将entity vertex和关于他的type vertex和keyword vertex看做一个点，我们得到RDF图G的压缩视图，表示为$G_c=\{V^{'}_E,E_R\}$。其中$|V^{'}_E| \equiv |V_E|$，$v^{'}\in V^{'}_E$包含$v\in V_E$和与之联系的类型和关键词节点。

## 2.1 Problem statement
关键词查询问题即RDF图中寻找包含所有关键词的子图。	
为便于表示，假设每个节点只包含一个关键词。（但对于包含多个和不包含的也能处理）		
对在$G=\{V,E\}$上的查询$q=\{w_1,w_2,...,w_m\}$，点集$\{r,v_1,...,v_m\}$在以下条件成立时被称为 qualified candidate:
+ root answer node $r\in V$能够到达任一点$v_i\in V,\, i\in [1,m]$
+ $w(v_i)=w_i$

A(q): the answer for q	
C(q): the set of all qualified candidates in G with respect to q.	
$$A(q)= arg min_{g\in C(q)}s(g), \, and \, s(g)=\sum_{r,v_i\in g, i=1..m}d(r,v_i)\tag{1}$$
其中$d(r,v_i)$是从r到$v_i$的距离（不考虑边方向）。

该定义还有一个top-k版本，其中对每个$g\in C(q)$的得分s(g)进行升序排列，得到前k个答案。
# 3 Related work
许多技术假设图能够在内存中处理，如[14](http://dl.acm.org/citation.cfm?id=1247516) [17](http://dl.acm.org/citation.cfm?id=1247516)为所有的点对保存了距离矩阵。另外这些工作不考虑如何处理更新。本文中我们将后向搜索应用于大RDF图并经过严密的证明，不依赖于距离矩阵。	
关于摘要大图来支持关键词搜索的技术来自于[9]，作者假设块之间的边是有权重的，块被当做supernode，块之间的边被当做superedges，它们组成摘要图。然后循环此过程。该方法针对通用图，并不能拓展到RDF图中。	
[23]研究了RDF图上的关键词搜索，和本文一样，其调整了[14]中的问题定义。该方法从RDF数据集中摘要出schema，在schema中应用后巷搜索得到最有可能的关系，然后将关系转化为SPARQL中的pattern进行检索。
[23]中摘要算法的局限：将同一类型的所有实体归结到一个点，丢失了太多信息，以至于产生错误结果。另外该方法不支持更新。	
[18]中通过对异质关系编码为图，支持结构化，半结构化和非结构化的关键词查询。同样的，他也需要距离矩阵。
[11](https://link.springer.com/chapter/10.1007/978-3-642-25073-6_13) [12](http://dl.acm.org/citation.cfm?id=1376708)研究了排序函数。我们则是调整了RDF[23]和通用图[14]中的排序函数。
# 4 The Baseline Method
baseline基于“backward search”的启发式。	
“backward search”：图中对应关键词查询的所有节点同时开始，迭代地想邻居节点拓展，直到候选答案生成。*termination condition*用来判断搜索过程是否完成。	
[23]中的termination condition是当m个节点第一次遇到节点r时返回答案并停止搜索，但该方法并不正确。		
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig5.png%}		
**Counter example. **对于图a来说，第二轮迭代得到$g=\{r=v_4,v_1,v_2,v_6,v_7\}\, \, s(g)=8$，但第四轮迭代中$g^{'}=\{r=v_3,v_1,v_2,v_6,v_7\}\, \, s(g^{'})=6$。	
**The correct termination.** 如算法1.
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/alg1.png%}		
*Data structure. * 	
$q=\{w_1,...w_m\}$: query	
 G=\{V,E\}: a (condensed) RDF graph	
 $W_i$: vertices in V containing the keyword $w_i$
 $\{a_1,...a_m\}$: m empty priority queues, one for each query keyword.
 M: 集合中每个元素对应目前探索到的独一无二的node，记录他们能够到达那个关键词以及距离。对于fig5(a)，$M[v_3]=\{(v_1,1),(v_2,1),nil,(v_7,1)\}$	
*The algorithm. *(图片中是不是line10,11写错了？）	
第一轮迭代算是初始化$a_i$和M。$W_i$中每个v和其邻居u放入$a_i$中，并新建$M[u]$或更新$M[u]$的相应值。
第二轮迭代首先pop$a_i$的堆顶值，然后添加 $(v,p=\{v,...,u\},d(p))\}$中u的每个邻居$u^{'}$。将 $(v,p=\{v,...,u^{'}\},d(p)+1)\}$压入$a_i$然后更新$M[u^{'}]$。	
如果$M[u]$没有nil，则该条被标记为候选答案，u为候选根节点。将M[u]中的最短路径表示为g，我们有：
> **Lemma 1 ** $g=\{r=u,v_{l_1},...,v_{l_m}\}$ is a condidate answer with $s(g)=\Sigma^m_{i=1}d(u,v_{l_i})$.

两种情况：(i) an unseen vertex, i.e., $v\notin M$, will become the answer root(Lemma 2); (ii) a seen but not fully expanded vertex $v\in M$ will become the answer root(Lemma 3).	
$V_t$: the set of vertices that are not fully explored.
$(v_1,p_1,d(p_1)),...(v_m,p_m,d(p_m))$: the top entries from $a_1...a_m$.
> **Lemma 2** Denote the best possible candidate answer as $g_1$, and a vertex $v\notin M$ as the answer root of $g_1$. Then it must have $s(g_1)>\Sigma^m_{i=1}d(p_i)$.	
>**Lemma 3** Suppose the best possible candidate answer using such an $v(v\in M\, and \, v\in V_t)$ as the answer root is $g_2$ then	
$$
s(g_2)>\sum^m_{i=1}f(v_{b_i})d_i + (1-f(v_{b_i}))d(p_i) 
\tag{2}$$
where $f(v_{b_i})=1$ if $M[v][b_i]\neq nil$, and $f(v_{b_i})=0$ otherwise.

**The termination condition.** 对于情况(i)，我们简单的让$s(g_1)=\Sigma ^m_{i=1}d(p_i)$;对于情况(ii)，we find a vertex with the smallest possible $s(g_2)$ value w.r.t. the RHS of (2), and simply denote its best possible score as $s(g_2)$.	
Denote the kth smallest candidate answer identified in the algorithm as g, our search can safely terminate when $s(g)\le min(s(g_1),s(g_2))=s(g_2)$. 

>**Theorem 1** The Backward method finds the top-k answers A(q,k) for any top-k keyword query q on RDF graph.

# 5 Type-Based Summarization
Backward方法对大的RDF图不适用，因为Backward为完成搜索，会构建无数的搜索路径。为了减少Backward算法的输入规模，只在有希望的子图上应用。我们提出了一个type-based摘要方法，即先在摘要图上进行关键词搜索，剪枝掉大部分无用的结果，然后再应用Backward。	
**The intuition.** 首先对RDF图分区，被查询的关键词首先由分区连接。挑战在于如何对不会产生top-k跨区答案进行剪枝。要做到这个我们需要对跨越分区的后向搜索的路径距离进行校正。但维护所有路径的距离成本太高，因此我们提取一个可更新的摘要图，使得任何后向搜索可以被有效地估计。	
The key observation: 紧邻的相同类型邻居节点一般共享相似的结构——和其他类型的节点的连接，如fig6。	
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig6.png%}	
我们基于以上观察构建一个typed-based summary。
## 5.1 Outline and preliminaries
首先将RDF图划分为多个小的区，然后定义摘要了分区的type-baseed structures。摘要保存所有分区的不同结构。通常关键词搜索在两方面受益于摘要：	
+ we can obtain the upper and lower bounds for the distance traversed in any backward expansion without constructing the actual path (Section 6).
+ we can efficiently retrieve every partition from the data by collaboratively using SPARQL query and any RDF store without explicity storing the partition (Section 15).

两个定义：	
**Homomorphism across partitions. ** 如图6(a)所示，邻近的类型节点是生成induced partitions的好的源头。图6(a)是图6(b)的子集。We consider discovering such embeddings between the induced partitions, so that one template can be reused to bookkeep multiple structures.	
>**Definition 1** A graph homomorphism f from a graph $G=\{V,E\}$ to a graph $G^{'}=\{V^{'},E^{'}\}$, writtern as $f: G\rightarrow G^{'}$, is a mapping function $f: V\rightarrow V^{'}$ such that(i) f(x)=x indicates that x and f(x) have the same type; (ii) $(u,v)\in E$ implies $(f(u),f(v)) \in E^{'}$ and they have the same label. When such an f exists, we say G is homomorphic to $G^{'}$.	

**Cores for indeividual partitions.** A *core* is a graph that is only homomorphic to itself, but not to any one of its proper subgraphs.	
**Definition 2** A core c of a graph G is a graph with the following properties: there exists a homomorphism from c to G; there exists a homomorphism from G to c; and c is minimal with these properties.
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig7.png%}	
## 5.2 Partition
摘要过程开始于将数据分成较小的，语义相似的，边不相交的子图。鉴于我们观察到相同类型的节点共享相似的类型邻居，我们基于类型用环绕相同类型节点的子图对G划分。算法使用RDF的condensed视图。	
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/alg2.png%}	
$\{T_1,...,T_n\}$: n distinct number of types.	
$V_i$vertices whose type is $T_i$.	
h(v,$\alpha$)(the $\alpha$-neighborhood of v): the subgraph from G obtained by expanding v with $\alpha$ hops.	拓展时的边不在P中，且是有向图，所以h(v,$\alpha$)是v $\alpha$跳邻居节点的子集。	
P：初始化为空，然后每个h(v,$\alpha$)都是一个新的划分。	
> **Lemma 4** Partitions in P are edge disjoint and the union of all partitions in P cover the entire graph G.

我们遍历类型的顺序不同可能会影响分区P的最终结果。但无论怎样，同种类型的节点总是基于其$\alpha$-neighborhoods生成一系列划分。如图8。
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig8.png%}	
## 5.3 Summarization
摘要算法从P的分区集合中识别出一系列templates。这些templates是partitions 的摘要。另外摘要算法保证P中的每个分区都与某个templates同态。该特性是的查询优化器：
1. 不用频繁访问RDF数据的前提下有效地在后向拓展时估计路径长度。
2. 通过查询RDF数据来有效地重构感兴趣的分区，而不显式地存储和索引分区。

{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/alg3.png%}	
给定一个分区P，算法3检索出所有的不同的结构并将其保存在S中。
**Improving efficiency and reducing |S|.**
算法3的两个问题：(1)在3,5,7行需要判断同态，这是NP-hard问题。(2) 尽量减少|S|的大小，以便能够放入内存中处理。	
对$h(v,\alpha)$的边建立一个covering tree，即$h_t(v,\alpha)$。并用$h_t(v,\alpha)$代替$h(v,\alpha)$。	
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig9.png%}	
**Example 2. **图9中，$h(v_1,2)$$中$v_4$节点在不同边中被访问了三次，所以有三个拷贝。	
该方法的优点：
+ 降低S中不同结构的数量，如图9所示，两个在数据层面不同的结构，在类型层面共享一个结构。
+ 对于通用图来说，检测子图同态十分耗时。但能在多项式时间内检测类型层面的结构。

## 5.4 Auxiliary indexing structures
为了帮助关键词搜索，我们维护了三个辅助列表。	
a portal node：node that isincluded in more than one partitions. *portal index* for each partition $h(v,\alpha)$, 我们赋予其唯一id并和portal列表联系。	
$\sigma (v_i)$: 表示$h_t(v,\alpha)$中的所有$v_i$。$\Sigma=\{\sigma (v_1),\sigma(v_2),...\}$：表示一个分区中所有的一对多的映射。如图9中，$h(v_1,2)$$\Sigma \leftarrow \{\sigma (v_4)=\{T_4\}\}$. *partition index*: to map the partition root v of $h(v,\alpha)$ to its $\Sigma$.	
*summary index*: 将partitions中的节点映射到S中的摘要节点。sid: S中的每个摘要的id，nid: S中每个节点的id。
为了获得每个$h_t(v,\alpha)$到S中的summary的映射，需要建立日志保存建立S时的发现的所有同态。等S建立完成后我们遍历日志找到所有从数据到summary的映射。过程如图10.
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig10.png%}	
# 6 Keyword search with summary
搜索算法，摘要层和数据层的两级后向搜索。只有摘要层中被识别的connected partitions包含所有关键词，并且其分数在top-k，才会进入数据层执行后向搜索。路径长度计算是后向搜索和剪枝的核心，但摘要层并不能拿到准确的路径长度，因此首先展示如何估计路径长度，然后介绍算法。
## 6.1 Bound the shortest path length
通过summary index，分区根节点v到分区内任一节点u的最短距离可计算，所以由三角形不等式得：$|d(v,v_1)-d(v,v_2)|\le d(v_1)-d(v_2)\le |d(v,v_1)+d(v,v_2)|$。另外，另一个下界可用根节点v所在分区的同态的摘要图得到，即Lemma 5：

> **Lemma 5** Given two graphs g and h, if $f:g\rightarrow h$, then $\forall v_1,v_2\in g$ and their homomorphic mappings $f(v_1),f(v_2)\in h,\, d(v_1,v_2)\le d(f(v_1),f(v_2))$.

{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig11.jpg%}	
如图11，从h到s没有直接的同态，因此不能直接应用Lemma 5。定义映射函数Join。输入：图g，$\{V^{'}_{t_1},V^{'}_{t_2},...\}$。输出：新图$g^{'}=Join(g(V,E),\{V^{'}_{t_1},V^{'}_{t_2},...\})$。其中$V^{'}_{t_i}$中的点都属于类型$t_i$。函数流程：
1. 用g初始化$g^{'}$；
2. 将$g^{'}$中的$V^{'}_{t_i}$合并至类型为$t_i$的点$v^{'}_{i}$，点集$V^{'}_{t_i}$中的所有边也赋于$v^{'}_{i}$；
3. 对所有类型重复步骤2。

**Example 3. **以图9为例，$Join(h_t(v_1,2),\{\Sigma(T_4)\})$重建了$h(v_1,2)$，因此两者同态。另外，$Join(h_t(v_5,2),\{\Sigma(T_4)\})$没有重建$h(v_5,2)$，但等于$h(v_1,2)$也和$h(v_5,2)$同态。

> **Lemma 6** For a partition h and its covering tree $h_t$, there is a homomorphism from h to $Join(h_t,\Sigma)$.
**Lemma 7** For a partition h, its covering tree $h_t$ and its summary s that has $f_2:h_t\rightarrow s$, there is a homomorphism from $Join(h_t,\Sigma)$ to $Join(s,f_2(|Sigma))$.

如图11b，由Lemmas 6,7和同态的可传递性，h is homomorphic to $Join(s,f_2(\Sigma))$。其中$f_2$是summary index的一部分，将数据中的节点映射到摘要中的节点。最后，给定h中任意两点，其最短路径可有Lemmas 5,6,7和最短路径算法在$Join(s,f_2(\Sigma))$中找到最短路的一个下限。实际应用中，我们从summary和三角不等式中找一个更高的下限。
## 6.2 The algorithm
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/alg4.png%}	
**Data structures. **
$q=\{w_1,...w_m\}$: query	
 G=\{V,E\}: a (condensed) RDF graph	
 $W_i$: vertices in V containing the keyword $w_i$
 $\{a_1,...a_m\}$: m empty priority queues, one for each query keyword.
 M: 集合中每个元素对应目前探索到的独一无二的node，记录他们能够到达那个关键词以及历经的分区。M中每个条目是四元组$(u,S,d_l,d_u)$。u是后向搜索中包含关键$w_i$的第一个节点。S存储搜索过程中路径的一系列partitions及其portal（exit node），因此S是(portal, partition root)的集合。
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig12.png%}	
**The algorithm. **
+ *In the first iteration. *对于每个来自$W_i$的点u，我们从summary index对u所述的分区根节点v检索。并将检索结果插入M和$a_i$中。
+ *In the j-th iteration.* 从所有的$a_i$中pop出最小的条，即$(v,(u,S,d_l,d_u))$(line 10). v是当前分区的根节点。S中最后的对是$(l,v_l)$：路径在$v_l$点离开根为$v_l$的分区并进入现分区。$\mathcal{L}=\{\mathcal{l}^{'}_1,\mathcal{l}^{'}_2,...\}$表示根节点为v的分区的portals。对于每个$l^{'}$按照6.1节的方法计算$d(l,l^{'})$或$d(u,l^{'})$的上下限。然后第14行更新，其中$v_r$是与$l^{'}$相连的下一个分区的根节点。M只有在两种情况下停止更新：(i)S的路径产生了环。(ii)$d_l+d^{'}_l$比当前第i个列表中第k大的上限还要大。	如果M[v]的所有条目非空，则以v为根节点的分区是候选答案。将m个关键词对应的列表组合起来就是联通子图。	然后我们拿到所选分区的实际数据（如何拿到在第7节），进行二级搜索。
+ *Termination condition. *Lemma 8,9.	

> **Lemma 8** Denote an entry in the priority queue as $(v,(u,S,d_l,d_u))$, then for any $v^{'}$ in the partition rooted at v and the length of any path starting from u and using the portals in S is $d(u,v^{'}\le d_l$.	
**Lemm 9** Denote the top entry in the priority queue $a_i$ as $(v,(u,S,d_l,d_u))$, then for any explored path p from $w_i$ in the queue $a_i$, the length of p, written as d(p), has $d(p)\le d_l$.	
**Lemma 10** let $g_1$ be a possible unexplored candidate answer rooted at a vertex in a partition h, with $h\in P_t$,	
$$s(g_1)>\sum^m_{i=1}{d}^i_l\tag{3}$$
**Lemma 11** Denote the bset possible unexplored candidate answer as $g_2$, which is rooted at a vertex in the partition h where $h\in P-P_t$, then	
$$s(g_2)>\sum^m_{i=1}f(t_i)\hat{d}^i_l+(1-f(t_i))d^i_l, \tag{4}$$	
where $f(t_i)=1\, if \, t_i\neq nil\, otherwise \, f(t_i)=0.$

**The termination condition.** 在未探索分区最有可能的答案是$s(g_1)$，如(3)式。在所有探索分区的最有可能的答案是$s(g_2)$，如(4)式。将得分升序排名第k的答案表示为g，则算法停止条件是$s(g)\le min (s(g_1),s(g_2))$.	
> **Theorem 2** Summ finds the top-k answers A(q,k) for any top-k keyword search query q on an RDF graph.	

# 7 Accessing data and update
在对摘要图搜索完成后，我们需要从实体数据中检索出所选择分区，一个常用的方法是将三元组按分区存储并编上分区的id，但这样更新比较麻烦，并需要独立的存储。我们将RDF数据存储在RDF中，并通过构建的SPARQL查询动态的检索出该分区的数据。	
> **Theorem 3** Homomorphism Throrem [1]. Let $q$ and $q^{'}$ be relational queries over the same data D. Then $q^{'}(D)\subseteq q(D)$ iff there exists a homomorphism mapping $f: q\rightarrow q^{'}$.

因为$c\rightarrow h_t \rightarrow h$因此用c作为SPARQL查询的pattern并结合Theorem 3可以抽取h。
两个关键问题：
+ 从$h_t$的集合到c通常有多对一的映射，使得若用c为query pattern会导致a low selectivity. 为解决此问题，我们在query pattern中从目标分区到相应变量间绑定了常量。
+ 在构建S的过程中，并不保存每个c，而是当c是s的子树时将c插入到$s\in S$中。为了从s中构建SPARQL，首先找到根节点，然后拓展到叶子。

# 8 Experiments
**Datasets**	
{% qnimg Scalable%20Keyword%20Search%20on%20Large%20RDF%20Data/fig14-15.png%}