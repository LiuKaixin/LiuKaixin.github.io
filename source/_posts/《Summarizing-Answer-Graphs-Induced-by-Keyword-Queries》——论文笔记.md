title: 《Summarizing Answer Graphs Induced by Keyword Queries》——论文笔记
author: 刘凯鑫
date: 2017-11-06 13:22:43
tags:
---
*小结：指出关键词和结构化查询各自的缺点。然后对关键词查出的答案进行摘要总结，将同一类型的答案归为一个摘要图。返回给用户使其得到graph queries。和ICDE09的文章有点儿像。其指出和ICDE09相比不需要schema。（我觉得这是在耍赖。。他对搜好的答案进行摘要感觉结果小多了肯定不需要schema。。。）
在得到答案后ICDE09，是将其转为SPARQL，供用户选择
本文则是直接进行摘要，让用户进行选择，然后自己构建SPARQL
（虽然没仔细看算法，但这个VLDB应该厉害在自己定义了个新的问题，并且对这个问题进行了较为全面的考虑和处理？）*

# ABSTRACT
通过keyword query对answer graphs进行摘要。
1. 对answer graph提出summary graph的概念。保留关键词的关系，对关键词节点间的路径进行摘要。
2. coverage ratio——衡量摘要的信息损失。
3. 由上一条，定义一系列摘要问题。
	1. 摘要问题的复杂度从PTIME到NP-complete。
    2. 提出exact和出去发誓摘要算法。
4. 实验。


# 1. INTRODUCTION
关键词查询得到太多的查询图，需要对其进行摘要，以便更好地使用。两个应用：
**Enhance Search with Structure.** keyword queryand graph query's usability-expressivity tradeoff.
{% qnimg Summarizing%20Answer%20Graphs%20Induced%20by%20Keyword%20Queries/fig1.png%}
对关键词查询产生的answer table构建出结构化查询，让用户选择。
**Improve Result Understanding and Query Refinement.** 
举例：三个查询结果可以摘要为两个图。
{% qnimg Summarizing%20Answer%20Graphs%20Induced%20by%20Keyword%20Queries/fig2.png%}
本文贡献：
1. 定义summary graph——捕捉Q中关键词和答案图之间的关系。
2. 两个指标：摘要图大小，coverage ratio$\alpha$——衡量摘要图中关键词对占答案图中的比例。
	1. $\alpha$-summarization problem：找符合$\alpha$的最小的摘要图。
    2. K summarization problem：找K summary graph。
3. 对于1-summarization，有精确解法。对于$\alpha$-summarization和K summarization 有启发式算法。

**Related work** 暂略。
# 2. ANSWER GRAPHS AND SUMMARIES
## 2.1 Keyword Induced Answer Graphs
**Answer graphs: **
Q的答案图是联通的无向图。
$card(G)$答案图中包含的答案数量。
$|G|$答案图中边和点的数量。

## 2.2 Answer Graph Sumarization
**Summary graph.** 同样是无向图。

# 3. QUALITY MEASUREMENT
## 3.1 Coverage Measurement
**Keywords coverage. **对于答案图的并集，关键词节点$v_{k_i}$到$v_{k_j}$和摘要图Gs中$v_{s_i}$到$v_{s_j}$的路径标签一致，则覆盖了该关键词对。
**Coverage ratio. **定义M是被摘要图Gs覆盖的关键词对数量。
$$\alpha=\frac{2\cdot M}{|Q|\cdot(|Q|-1)}$$
## 3.2 Conciseness Measurement
**Summarization size.** Gs中所有的点和边的和
## 3.3 Summarization Problems
**Minimum $\alpha$-Summarization.** 找到规模最小的$\alpha$-summary graph。（MSUM）
**Theorem 1: **MSUM is NP-complete (for decision version) and APX-hard (as an optimization problem).
PSUM: $\alpha$为1
**Theorem 2: **给定Q和G，PSUM时间复杂度$O(|Q|^2)|G|+|G|^2$
**K Summarization.** 找到概要图集合Gs，使得
1. 集合中每个摘要图都是1-summary graph。
2. 摘要图对应的原始答案集合是答案图集合不相交的K划分。
3. 大小为最小，即集合中每个摘要图大小最小。
# 4. COMPUTING $\alpha$ SUMMARIZATION
## 4.1 Computing 1-Summary Graphs
**Dominance relation.** 
{% qnimg Summarizing%20Answer%20Graphs%20Induced%20by%20Keyword%20Queries/fig4.png%}








