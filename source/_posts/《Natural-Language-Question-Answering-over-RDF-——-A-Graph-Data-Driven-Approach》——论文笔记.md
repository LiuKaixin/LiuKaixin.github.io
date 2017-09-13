title: >-
  《Natural Language Question Answering over RDF ——  A Graph Data Driven
  Approach》——论文笔记
author: 刘凯鑫
tags:
  - RDF
  - QA
  - 2017年8月
categories:
  - 论文笔记
  - ''
date: 2017-08-24 11:15:00
---
# ABSTRACT
RDF Q/A允许用户对RDF知识库用自然语言提问。为回答该提问，需要两步：理解问题和执行查询。现有工作大都集中在解决自然语言的歧义，通常做法是the joint disambiguation，使搜索空间指数增长。本文从图数据驱动的角度解决该问题，提出使用语义查询图为自然语言的查询意图建模，将问题归约成子图匹配问题。更重要的是，我们通过查询的匹配情况，解决自然语言问题的多义性。实验结果验证算法。
# 1. INTRODUCTION
背景：用户需从知识库中获取知识，RDF格式成为标准，SPARQL查询对用户不友好，需要RDF Q/A系统。
# 1.1 Motivation
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/fig1.png %}
现在RDF Q/A系统主要分两个阶段：question understanding和query evaluation。第一阶段把自然语言问题N转化成SPARQLs，这也是目前大部分工作的研究重点。第二阶段执行第一阶段得到的SPARQls。如图1所示，(a)是RDF数据集，(b)是目前解决方法的两个步骤，可以看到由于多义性，有些短语对应多个实体。如果同时考虑这些短语则增加了响应时间。	
本文并不在第一阶段解决多义性问题，而是放到第二阶段，能够避免问题理解阶段的高昂的消歧处理，从而加速整个系统。本方法中最关键的问题在于如何定义RDF图G中的子图和自然语言问题N的匹配，以及如何找到匹配。
## 1.2 Our Approach
虽然本方法仍有“question understanding”和“query evaluation”，但并不与现在的SPARQL generation-and-evaluation相同，本方法是graph data-driven，其大概的框架如图1(c)。	
在question understanding阶段，我们把问题iN翻译为semantic query graph $Q^{S}$。该步允许多义。	
在query evaluation阶段，我们在图G上找$Q^{S}$的匹配的子图。我们基于语义相似性定义了匹配的分数。	
将消歧放在query evaluation阶段不仅提高了精度也加速了整个查询应答时间。
贡献：
1. 为问题提出了系统的框架。并从graph data-driven的角度，将消歧放在了query evaluation阶段。
2. 离线处理：提出图挖掘算法，将短语匹配到top-k个可能的谓词，形成paraphrase dictionary D。
3. 在线处理：两个阶段，首先将问题N转换为semantic query graph $Q^{S}$，然后把RDF Q/A归约成$Q^{S}$在图G上的子图匹配问题。在找到匹配时解决了多义问题，如果没有匹配发现则消歧的花费就被节省了。
4. 实验

# 2. FRAMEWORK
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/table1.png 
%}
本问题有两个关键的挑战，一是如何以结构化的方式表示问题N中的查询意图。二是如何处理问题N中的短语的多义性。
为解决第一个挑战，我们从N中抽出semantic relations，并基于此建立了semantic query graph $Q^{S}$为问题N中的问题意图建模。
> Definition 1. **(Semantic Relation).** A semantic relation is a triple <rel, arg1, arg2>, where rel is a relation phrase in the paraphrase dictionary D, arg1 and arg2 are the two argument phrases.	
Definition 2. **(Semantic Query Graph)** A semantic query graph is denoted as $Q^S$, in which each vertex $v_i$ is associated with an argument and each edge $\bar{v_iv_j}$ is associated with a relation phrase, $1\le i,j\le |V(Q^{S})|$.	

{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/fig2.png %}

针对第二个挑战，我们提出了数据驱动的方法：对于N中一个短语到实体的映射，如果能找到包含该实体的子图且匹配N中的查询意图，那该映射是正确的；否则是错误的。
## 2.1 Offline
建立了paraphrase dictionary D——记录语义相等的关系短语和谓词。一些现有的系统如Patty和ReVerb还未每个关系短语提供了其支持的实体对，如表2。
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/table2.png %}
方法思路：对每个关系短语$rel_i$，$Sup(rel_i)$表示一系列该谓词支持的实体对。我们假设这些实体对也出现在RDF图中。频繁出现的谓词连接$Sup(rel_i)$中的实体对和关系短语$rel_i$等价。基于该想法我们提出一个找语义相等的关系短语和谓词的图挖掘算法。
## 2.2 Online
1) *Question Understanding. *目的在于为问题N构建一个语义查询图$Q^{S}$。首先用Stanford Parser得到N的依赖树Y，然后基于paraphrase dictionary D抽取Y中的语义关系。基本的思路是找到一个Y的包含rel的所有词的最小子树。该子树被称为Y中的rel的一个嵌入，并且基于一些语言规则我们得到有联系的两个参数，形成$< rel,arg1,arg2 >$，最后连接这些关系得到查询图$Q^{S}$。
2) * Query Evaluation. *找到与$Q^{S}$匹配的子图。匹配按照子图同态定义。	

首先，$Q^{S}$的点，被映射到RDF图中的一些实体或类，并赋予一个置信度，保存在有序列表$C_{v_i}$。关系短语$rel_{\overline{v_iv_j}}$被映射到候选谓词的列表$C_{\overline{v_iv_j}}$中。列表以置信度排序。本步中并没有解决多义问题。
其次，

> Definition 3.**(Match)** Consider a semantic query graph $Q^{S}$ with n vertices $\{v_1,...,v_n\}$. Each vertex $v_i$ has a condidate list $C_{v_i},i=1,...,n.$ Each edge $\overline{v_iv_j}$ also has a candidate list of $C_{\overline{v_iv_j}}, where $1\le i\ne j\le n.$ A subgraph M containing n vertices $\{u_1,...,u_n\}$ in RDF graph G is a match of $Q^{S}$ if and only if the following conditions hold: 
1. if $v_i$ is mapping to an entity $u_i$, i=1,...,n, $u_i$ must be in list $C_{v_i}$;
2. if $v_i$ is mapping to a class $c_i$, i=1,...,n, $u_i$ is an entity whose type is $c_i$ (i.e., there is a triple <$u_i$ rdf:type $c_i$> in RDF graph) and $c_i$ must be in $C_{v_i}$;
3. $\forall \overline{v_iv_j}\in Q^S; \, \overrightarrow{u_iu_j}\in G \lor  \overrightarrow{u_ju_i}\in G$. Furthermore, the predicate $P_{ij}$ associated with $\overrightarrow{u_iu_j}$ (or $\overrightarrow{u_ju_i}$ is in $C_{\overline{v_iv_j}},\, 1\le i,j\le n$.

每个和$Q^S$匹配的子图都有一个得分，由边和点的概率决定。我们的目标是找到top-k个匹配的子图，在4.2.2节中解决。
# 3. OFFLINE
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/fig3.png %}
语义关系抽取依赖于词典D，图3是词典的一个示例。本文并不讨论如何抽取短语及其对应的实体对，假设已经给定。	
在offline中的任务是找到语义相等的关系短语和RDF中的相应谓词，即构建如图3的词典D。假设已有词典$T=\{rel_1,...,rel_n\}$，每个$rel_i$都是一个关系短语，并有一个出现在RDF图中的实体对集合，即$Sup(rel_i)=\{(v^1_i,V^{'1}_i),...,(v^m_i,V^{'m}_i),\}$。对于每个$rel_i$目标是找到RDF图中的top-k个语义相等的谓词（路径）。
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/fig4.png %}
方法：给定一个关系短语$rel_i$及$Sup(rel_i)=\{(v^1_i,V^{'1}_i),...,(v^m_i,V^{'m}_i),\}$，对$(v^j_i,V^{'j}_i),j = 1,...,m$，我们在RDF图中找到两点间的简单路径：$Path(v^j_i,V^{'j}_i)$，如图4。则$PS(rel_i)=\bigcup_{j=1,...,m}Path(v^j_i,V^{'j}_i)$.	为了效率，我们设定了路径的阈值，然后使用双向的BFS搜索找到$Path(v^j_i,V^{'j}_i)$。	
但是这样的方法会带来噪音，解决方法：采用了tf-idf度量。

> Definition 4. Given a predicate path L, the tf-value of L in $PS(rel_i)$ is defined as follows:	
$$tf(L,PS(rel_i))=|\{Path(v^j_i,V^{'j}_i)| L\in Path(v^j_i,V^{'j}_i)\}|$$
The idf-value of L over the whole relation phrase dictionary $T=\{rel_1,...,rel_n\}$ is defined as follows:
$$idf(L,T)=log \frac{|T|}{|\{rel_i\in T|L \in PS(rel_i)\}|+1}$$
The tf-idf value of L is defined as follows:
$$tf-idf(L,PS(rel_i),T)=tf(L,PS(rel_i))\times idf(L,T)$$

关系短语和谓词（路径）的置信度定义为：
$$\delta (rel,L)=tf-idf(L,PS(rel_i),T) \tag{1}$$
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/alg1.png %}
算法1展示了为每个关系短语找top-k谓词路径的细节。注意tf-idf is a probability value to evaluate the mapping (from relation phrase to predicate/predicate paths) confidence.	
维护D只需要为新引入的谓词重新挖掘映射，或删除被移除数据集的谓词的映射。
> Theorem 1. The time complexity of Algorithm 1 is $O(|T|\times |V|^2\times d^2)$, where |T| is the number of relation phrases in T, |V| is the number of vertices in RDF graph G, and d is the maximal vertex degree.

# 4. ONLINE
## 4.1 Question Understanding
本节讨论如何识别问题N中的语义关系，并基于关系建立语义查询图$Q^S$代表N中的查询意图。
为抽取句子关系短语，建立依赖树。
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/fig5.png %}
图5展示了问题N的依赖树表示为Y。
> Definition 5. Let us consider a dependency tree Y of a natural language question N and a relation phrase rel. We say that rel occurs in Y if and only if there exists a connected subtree y (of Y) satisfying the following conditions:
1. Each node in y contains one word in rel and y includes all words in rel.
2. We cannot find a subtree $y^{'}$ of Y, where $y^{'}$ also satisfies the first condition and y is a subtree of $y^{'}$.
In this case, y is an embedding of relation phrase rel in Y.

给定问题N的依赖树Y和关系短语词典$T=\{rel_1,...,rel_n\}$，我们需要T中那个关系短语在Y中出现。
### 4.1.1 Finding Relation Phrase Embeddings 
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/alg2.png %}
>Theorem 2. The time complexity of Algorithm 2 is $O(|Y|^2)$.

### 4.1.2 Finding Associated Arguments 
通常参数的识别依赖subject-relations、object-like relations，如下：
1. subject-like relations: sbj, nsubj, nsubjpass, csubj, csubj-pass, xsubj, poss;
2. object-like relations: obj,pobj, dobj, iobj

假设关于短语rel的嵌入子树为y。通过检查y中的每个节点w及其子节点是否出现以上的subject-like（object-like）关系，出现则把子节点加入到arg1（arg2）。	
如果arg1/arg2仍是空，我们有以下启发式规则：
+ Rule 1: Extend the embedding t with some light words, such as prepositions, auxiliaries. Recognize subject/object-like relations for the newly added tree node.
+ Rule 2: If the root node of t has subject/object-like relations with its parent node in Y, add the root node to arg1.
+ Rule 3: if the parent of the root node of t has subject-like relations with its child, add the child to arg1.
+ Rule 4: If one of arg1/arg2 is empty, add the nearest wh-word (such as what, who and which) or the first noun phrase in t to arg1/arg2. 	

如果arg1/arg2仍然是空，则放弃关系短语rel。
### 4.1.3 Building Semantic Query Graph
把语义关系<rel,arg1,arg2>表示为边，如果两个关系的参数相同，则边相连。
## 4.2 Query Evaluation
### 4.2.1 Phrases Mapping
讨论如何将关系短语和参数映射到候选的谓词（路径）和实体。	
**Mapping edges of $Q^S$.** $Q^S$中边$\overline{v_iv_j}$对应关系短语$rel_{\overline{v_iv_j}}$。按照paraphrase dictionary D，$rel_{\overline{v_iv_j}}$映射到列表$C_{\overline{v_iv_j}}$，列表中是谓词P或谓词路径L。$\delta(rel,L)$置信度。	
**Mapping Vertices of $Q^S$.**  $Q^S$中点v对应参数arg。如果arg是wh-word，则它可映射到RDF中所有实体和类，否则返回一个对应的实体或类的列表。本文使用现成的工具DBpedia Lookup。$\delta(arg,c)$置信度。	
**Graph Data-driven Disambiguation.** graph data-driven solution.
### 4.2.2 Finding top-k Subgraph Matches
> Definition 6. Given a semantic query graph $Q^S$ with n vertices $\{v_1,...,v_n)\}$, a subgraph M containing n vertices $\{u_1,...,u_n\}$ in RDF graph G is a match of $Q^S$. The match score is defined as follows:	
$$Score(M)=
log( \prod_{v_i\in V(Q^S)} \delta (arg_i,u_i) \times \prod_{\overline{v_iv_j}\in E(Q^S)} \delta (rel_{\overline{v_iv_j}},P_{ij})  )\\
=\sum_{v_i\in V(Q^S)} log( \delta (arg_i,u_i))+\sum_{\overline{v_iv_j}\in E(Q^S)} log( \delta (rel_{\overline{v_iv_j}},P_{ij})  ) \tag{2}$$
where $arg_i$ is the argument of vertex $v_i$, and $u_i$ is an entity or a class in RDF graph G, and $rel_{\overline{v_iv_j}}$ is the relation phrase of edge $\overline{v_iv_j}$ and $P_{ij}$ is a predicate of edge $\overrightarrow{u_iu_j}$ or $\overrightarrow{u_ju_i}$

给定语义查询图$Q^S$，我们目标是找到$Q^S$的所有匹配中分数top-k的。这是个NP-hard问题。
> Lemma 1. Finding Top-1 subgraph match of $Q^S$ over RDF graph G is an NP-hard problem.
Lemma 2. Finding Top-k subgraph match of $Q^S$ over RDF graph G is at least as hard as finding Top-1 subgraph match of $Q^S$ over G.
Theorem 3.  Finding Top-k subgraph match of $Q^S$ over RDF graph G is an NP-hard problem.

因为他是NP-hard问题，所以我们设计启发式规则减少搜索空间。第一个利用neighborhood-based pruning减少$C_{v_i}$和$C_{\overline{v_iv_j}}$。第二个是基于top-k匹配的分阈值及早停止搜索。
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/alg3.png %}
# 5. TIME COMPLEXITY ANLYSIS
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/table3.png %}
# 6. EXPERIMENTS
{% qnimg Natural%20Language%20Question%20Answering%20over%20RDF%20——%20%20A%20Graph%20Data%20Driven%20Approach/table4-5.png %}