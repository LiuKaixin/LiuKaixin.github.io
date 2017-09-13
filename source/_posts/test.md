title: 《RDF Keyword-based Query Technology Meets a Real-World Dataset》——论文笔记
tags:
  - keyword
  - RDF
  - SPARQL
  - 2017年8月
categories:
  - 论文笔记
  - ''
author: LiuKaixin
date: 2017-08-15 16:12:00
---
**nucleus**

# ABSTRACT
本文介绍了一个工业项目，其通过将RDF技术和关键词搜索结合，开发出一种便于利用碳氢化合物对大型数据库进行数据访问的工具。该工具的特色是通过RDF schema和RDF数据，无需用户介入将关键词转化为SPARQL查询。工具还提供了一系列接口，如specify keywords, as well as filters and unit measures, and presents the results with the help of a table and a graph方便用户使用。

# 1. INTRODUCTION
首先分析现有的网络上的关键词搜索技术，总结其成功的原因：
 1. 简单易用的用户接口 
 2. 有效的文档检索机制
 3. 符合用户期望的排序算法

对比来看，数据库管理系统提供了复杂的查询语言，一些数据库应用虽然创建了用户接口，让用户填一些空进行查询，隐藏查询语言的复杂性，但并不友好。我们提供关键词搜索接口，通过把关键词转换为查询语言，将用户从精准填空中解放出来。

关于关系型数据库的关键词查询出现了一段时间，现在也出现了关于RDF数据上的关键词查询。RDF不区分数据和元数据，因此关键词可能和类的名字、属性的描述或者数据的值匹配。RDF管理系统有时和提供推理层会以surpass/relational 视图对RDF数据产生推导数据，因此关键词也可能匹配推导数据。

本文贡献：
+ 定义RDF数据上关键词查询的答案。
+ 通过利用RDF的schema和RDF数据集将关键词查询转换为SPARQL查询。
+ 通过自动补全功能和filter、 unit measures的帮助允许用户精确关键字。
+ 进行实验验证了工具的性能。

# 2. Related Work
**Keyword-based query processing. ** 分为以下几类：
+ schema-based：使用conceptual schema编译查询。
+ graph-based：直接在图上操作。
+ parttern-based：从RDF数据中挖掘pattern替代conceptual schema。
+ fully automatic：在关键词查询时无需依靠用户干预。

BANKS and [BLINKS](http://blog.csdn.net/u013319237/article/details/76050381)是早期的graph-based工具。schema-based工具基于candidate networks （CNs）探索外键将关键词转化为SQL。例子有：DISCOVER，DBXplorer。

SPARK是早期的pattern-based RDF graph-based tool。[21]提出想法：利用类的层级从原始图中生成summary graphs，[26]负责实现。[24]挖掘tree pattern。[27]提出挖掘等价的structure patterns to summarize 知识图。[7]基于张量计算对RDF关键词查询。

QUICK[25]是一个RDF schema-based tool，需要用户介入。

本文的工具是schema-based并且fully automatic。从早期的graph-based工具中借鉴了生成由RDF schema引发的图的斯坦纳树来减少equijoins的想法。我们引入了新概念*nucleus*，其包含一个类，一个属性列表，一个属性值列表。nucleus 一定程度上和tuple相似。然后Steiner tree把那些包含关键词的nucleus连接起来。

和QUICK比较相似，但我们的RDF数据有rich schema并且低歧义，所以我们是全自动的转换。

**Triplification of the relational database. **因为关系数据库经常是normalized不可直接映射到RDF，我们首先创造了定义了unnormalized关系视图，然后利用R2RML映射。
设计良好RDF schema帮助了关键词到SPARQL的转化，首先，RDF数据集具有已知模式的假设不应被视为缺点。实际上，大部分的LOD数据集确实有一个已知的模式（词汇或本体）[17]。此外，在像我们这样的企业环境中，RDF数据集通常是关系数据库的三元组化。第二，即使不能改变（关系或RDF）模式，也可以添加一个在视图的帮助下定义的概念层，这些概念层隐藏规范化，在关系情况下，或设计不当的RDF模式，这两种情况都会导致处理基于关键字的查询时的歧义。

**Benchmarks. **他人所用的数据集及查询。
# 3. BASIC DEFINITIONS
## 3.1 RDF Essentials 
IRI(Internationalized Resource Identifier)：表示一个资源。
literal：一个基础值，如字符串，数字等
blank node：local identifier，可以被新的IRI替代。

本文中**IRI**代表所有的IRI的集合，**L**代表所有的literal的集合。

(s,p,o): s-IRI/ a blank node. p-IRI, o-IRI,a blank node or a literal.

RDF 三元组和RDF图等价。

RDF Schema 不提供实际的应用程序专用的类和属性，而是提供了描述应用程序专用的类和属性的框架。
RDF Schema 中的类与面向对象编程语言中的类非常相似。这就使得资源能够作为类的实例和类的子类来被定义。
介绍了[RDF Schema 及其一系列属性](https://www.w3.org/TR/rdf-schema/#ch_domain)

An RDF schema is a set S of RDF triples that use the RDF-S vocabulary to declare classes, properties, property domains and ranges, and sub-class and sub-property axioms.

A simple RDF schema is a RDF schema that contains only class declarations, object and datatype property declarations and subclass axioms (and no sub-property axioms).

我们引入一个labelled graph, $D_s$ 被称为RDF schema diagram：
+ the nodes of DS are the classes declared in S;
+ there is an edge from class c to class d labelled with subClassOf iff c is declared as a subclass of d in S, and there is an edge from class c to class d labelled with p iff p is declared in S as an object property with domain c and range d.

RDF 数据集T follows RDF schema S的条件：
1. $S\subseteq T$
2. T中的所有类和属性在S中都被定义
3. T中的三元组除了那些在S中的都满足S中声明的限制。

## 3.2 Keyword-Based Queries
T: an RDF dataset.	
$G_T$: $G_T$ is the corresponding RDF graph.	
S: an RDF schema.	
K: A keyword-based query--- a set of literals.	
match $\mathbf L \times \mathbf L \rightarrow [0,1]$:literal之间的相似函数。	
$\sigma \in (0,1]$: similarity threshold.		
MM[K,S]:metadata matches between K and metadata descriptions of the classes and properties in S.	
$$MM[K,T]=\{ (k,(r,p,v)) \in K\times T/ (r,p,v)\in S \wedge match(k,v)\le \sigma\}$$	
VM[K,T]: property value matches between K and property values of T.	
$$VM[K,T]=\{ (k,(r,p,v)) \in K\times T/ (r,p,v)\notin S \wedge match(k,v)\le \sigma\}$$		
$M[K,T]=MM[K,T]\cup VM[K,T]$: matches between K and T.

{% qnimg EDBT_2017/keywords_matched.png %}

答案的顺序：Given a directed graph G, let |G| denote the number of nodes and edges of G and #c(G) denote the number of connected components of G, when the direction of the edges of G is disregarded. We define a partial order “<” for graphs such that, given two graphs G and G’,	
$$G<G^{'} iff (\#c(G)+|G|)<(\#c(G^{'})+|G^{'}|) \,or\, (\#c(G)+|G|)=(\#c(G^{'})+|G^{'}|)\, and\, \#c(G)<\#c(G^{'})$$	

{% qnimg EDBT_2017/fig1.jpg %}

# 4. TRANSLATION OF KEYWORD QUERIES TO SPARQL QUERIES
## 4.1 Overview of the Translation Algorithm
转化算法接受关键词查询K，RDF数据集T，输出一个SPARQL查询。	
$G_T$: RDF graph。
$D_S$: RDF schema diagram。

Given a set of metadata matches MM[K,T] and a set of property value matches VM[K,T], we define two functions that group all keywords that match the same class or property:
{% qnimg EDBT_2017/4.1.jpg %}
{% qnimg EDBT_2017/4.1nucleus.jpg %}


N covers the set of keywords $K_n=K_0\cup K_1\cup...\cup K_m\cup K_{m+1}\cup ...\cup K_{m+n}$	
Given a set of nucleuses $\mathbf N =\{N_1,...,N_m\}$, we also say that **N** covers $K_{N1}\cup ...\cup K_{Nm}$. 	
$\mathbf{N_C}$ : the set of classes of the nucleuses in **N**.

算法共有两个启发式：scoring and minimization。	

scoring：尝试捕捉用户意图，将关键词列表转换成查询。
+ consider how good a match is, say "city" matches "Cities" better than "Sin City".
+ assigns a higher score to metadata matches.
+ assigns a higher score to nucleuses that cover a larger number of keywords.

对于nucleus N=(C,PL,PVL)：	
$score(N)=(\alpha s_C+\beta s_p+(1-\alpha -\beta)s_V$	
$s_C=meta_sim((K_0,c))$	
$s_P=\sum_{(K_i,p_i)\in PL}meta \\_ sim((K_i,p_i))$	
$s_V=\sum_{(K_j,p_j)\in PVL}value \\_ sim((K_j,p_j))$	


minimization：尝试生成minimal 答案，共两步。
1. 实现一个贪婪算法，对由最高分值的nucleuses排序，生成nucleus集合**N**。
	+ N covers a large subset of K
    + All nodes in $\mathbf{N_C}$ are in the same connected component of $D_S$	
如果只由N中的nucleus产生答案，查询的得到的connected components可能和$N_C$中的类一样多。
2. 使用$D_S$中的一些边连接$C_N$中的classes强制一个答案只有一个connected component。这和产生以$N_C$中类为节点的斯坦纳树ST等价。然后，该算法使用ST的边来产生SPARQL查询Q的子句，使得Q的任何答案确实具有单个连接的分量。

{% qnimg EDBT_2017/fig2.jpg %}		
上图是算法的详细介绍，共有六步：
1. 去除K中stop words，对剩下部分与T进行匹配，得到MM[K,T]和VM[K,T]。第一步建立了辅助表加速了匹配过程。
	+ ClassTable：为S中的类存储IRI，label,description and other property values。
    + PropertyTable：存储属性元数据。
    + JoinTable：存储S中domains和ranges。
    + ValueTable：存储T中distinct property value pair.
2. 使用MM[K,T]和VM[K,T]计算得到a set M of nucleuses.
3. 为M中的每个nucleus计算得分。
4. 对应minimization启发式的第一步。把M中最大的核$N_0$从M中取出，放入N。$H_0$为$N_0$的RDF schema上的连通分量。从M中取出所有类不属于$H_0$的核。（为了保证第五步的正确性。）
5. 实现minimization启发式的第二步。计算覆盖了$N_C$的最小斯坦纳树ST的分时。图中没有写出的详细步骤：首先计算a new labelled directed graph $G_N$ 。其点来自$N_C$，边来自RDF schema diagram $D_S$。然后为$G_N$计算一个最小的有向的spanning tree TN。如果不存在，则计算无向图TN。TN通过将其边替换为$D_S$中对应的路径，得到覆盖$N_C$中节点的$D_S$的斯坦纳树ST。
6. 合成查询Q使得：
  + Q返回T的子集。
  + Q的WHERE子句包含与N中的核的属性值对的元素相对应的过滤器。
  + Q的WHERE子句包含与ST中边缘相对应的equijoin子句。

使用引理证明算法的正确性：
> **Lemma**: Let T be an RDF dataset, S be the RDF schema of T and K be a keyword-based query. Let Q be the SPARQL query the translation algorithm outputs for K,T and S. Then, any result of Q is an answer for K over T with a single connected component.

## 4.2 An Example the Translation Process
本节阐述算法如何为关键词查询K合成SPARQL查询。
流程和上一小节一致，不过举了个例子进行详细说明，此处略。
## 4.3 User Interface
1. 提供自动补全功能，基于之前的关键词，RDF schema字典和资源标识符的标签。如fig3a
2. 利用斯坦纳树和表来展现结果，用户可以选择添加表中的属性。如fig3b，fig3c。
3. 对比较符号如“<”或预留单词“between”，可以生成简单的过滤器。
{% qnimg EDBT_2017/fig3.jpg %}
# 5. EXPERIMENTS
## 5.1 Experimetn setup
电脑配置及运行环境~
## 5.2 Experments with the Industrial Dataset
数据一开始被存储在传统的关系型数据库中，对于metadata matches十分有帮助。我们发现需要得到额外的元数据，如表中那些列是键，那些包含对象的扩展名等，这些对于关键词匹配和如何向用户展现对象等十分重要。操作流程如下：		
 1. 在关系数据库这边，我们定义了一些列视图来denormalize表。
 2. 创建了一个XML文档对RDF schema中所有别的类和属性进行定义。
 3. 利用该XML文档构建了一个模型生成R2RML声明，帮助关系数据映射到三元组，以及生成4.1节中的辅助表。
 
（然后贴出部分RFD schema的图，并进行解释）

数据集属性较多（558个），关于属性的值大部分都是文字，适合关键词查询。
{% qnimg EDBT_2017/table1.jpg %}
{% qnimg EDBT_2017/table2.jpg %}
## 5.3 Experiments with Mondial and IMDb
M:32/50
IMDb:36/50
然后说了一堆， 这个是缺乏关键词语义，关键词描述不准确云云。。
# 6. CONCLUSIONS
总结了一堆功能，这是一个产品的说明并不像一篇科研论文，最后也是强调鲁棒性。。。