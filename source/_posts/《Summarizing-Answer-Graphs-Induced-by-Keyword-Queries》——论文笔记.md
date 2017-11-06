title: 《Summarizing Answer Graphs Induced by Keyword Queries》——论文笔记
author: 刘凯鑫
date: 2017-11-06 13:22:43
tags:
---
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
## 2. ANSWER GRAPHS AND SUMMARIES
## 2.1 Keyword Induced Answer Graphs
**Answer graphs: **
