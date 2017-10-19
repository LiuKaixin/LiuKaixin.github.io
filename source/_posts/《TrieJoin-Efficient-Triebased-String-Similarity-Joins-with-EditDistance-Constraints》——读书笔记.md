title: >-
  《TrieJoin: Efficient Triebased String Similarity Joins with EditDistance
  Constraints》——读书笔记
author: 刘凯鑫
date: 2017-10-18 18:48:52
tags:
---
*虽然师兄说，看PPT就行了，但是我粗略一看PPT感觉说的貌似太简略了，还是得看一下论文。。。应该是水平太低所以看PPT没有深入理解吧，希望这次看论文能快点！（有选择的看）*
# ABSTRACT
主要工作：使用编辑距离研究字符串相似。
现有方法使用filter-and-refine框架，缺点如下：
1. 对长度小于30的短字符串效果不好。
2. 巨大的索引。
3. 数据集更新的成本很大。

本文使用trie-join框架，能用小的索引生成结果。使用trie结构索引字符串，并使用trie剪枝找到相似子串。并且支持数据集的动态更新。
# 1.INTRODUCTION
similarity join简介。
相似函数：jaccard similarity，cosine similarity，**edit distance**。
举例之前工作，并指明缺点（见摘要）。
本方法解决了之前的所有问题。
贡献：
1. We propose a trie-based framework for efficient string similarity joins with edit-distance constraints.
2. We devise efficient trie-join-based algorithms and develop pruning techniques to achieve high performance.
3. We extend our method to support dynamic update of data sets efficiently.

# 2.TRIE-BASED FRAMEWORK
## 2.1 Problem Formulation
如果两个字符串编辑距离小于阈值，则两个字符串相似。
> **Definition 1 (String Similarity Joins).** Given two sets of strings R and S, and an edit-distance threshold $\tau$, a similarity join finds all similar string pairs $<r,s>\in R\times S$ such that $ED(r,s)\le \tau$

## 2.2 Prefix Pruning
naive solution：计算所有字符串对的编辑距离。
使用动态规划提早终止编辑距离的计算。
string $r=r_1,r_2...r_n$, $s=s_1,s_2...s_m$,
matrix D(i,j): the edit distance between the prefix $r_1,r_2...r_i$ and $s_1,s_2...s_j$
D(0,j)=j for $0\le j\le n$, and 
D(i,j)=min(D(i-1,j)+1,D(i,j-1)+1,D(i-1,j-1)+$\theta$) where $\theta=0$ if $r_i=s_j$; otherwise $\theta=1$
D(i,j) is an active entry if $D(i,j)\le \tau$
{% qnimg TrieJoin%20Efficient%20Triebased%20String%20Similarity%20Joins%20with%20EditDistance%20Constraints/fig1.png %}
如图没有active entries时，结束搜索。
## 2.3 Our Observation
### Observation 1 - Subtrie Pruning:
通过前缀可以剪枝掉很多字符串。
> **Lemma 1 (Subtrie Pruning).** Given a trie T and a string s, if node n is not an active node for every prefix of s, then n's descendants will not be similar to s.

Trie-Search: 首先为R内的所有字符串构建trie树，然后基于subtrie pruning对S中的每个字符串计算active-node set $A_s$。
### Observation 2 - Dual Subtrie Pruning:
Subtrie Pruning只利用了R中的trie结构。
对R和S中的字符串构建了一个大的Trie，同时对R和S进行subtrie pruning。

> **Lemma 2 (Dual Subtrie Pruning).** Given two trie nodes u and v, if u is not an active node for every ancestor of v, and v is not an avtive node for every ancestor of u, the strings under u and v connot be similar to each other.

但利用dual trie pruning，不能直接在树中搜索找到相似对。

# 3. TRIE-BASED ALGORITHMS
为便于表示，关注自连接，即R=S。
## 3.1 Trie-Traverse Algorithm
**Algorithm Description：**
首先为S中的字符串构建trie索引，然后先序遍历，对于每个节点，计算其active-node set，到达叶子结点，则和active-node set中的叶子结点构成相似对。
**Computing Active-Node Sets: **利用其父节点的active-node set $A_p$，计算本节点active-node set $A_n$，$A_n$中的每个点都能在$A_p$中找到父节点。
> **Lemma 3.** Given a node n, let p denote n's parent, for each node $n^{'}\in A_n$, there must exist a node $p^{'}\in A_p$, such that $p^{'}$ is an ancestor of $n^{'}$.

因为从$A_p$计算$A_n$的复杂度为$O(\tau \cdot |A_n|)$，所以Trie-Traverse的时间复杂度为$O(\tau \cdot |A_T|)$
{% qnimg TrieJoin%20Efficient%20Triebased%20String%20Similarity%20Joins%20with%20EditDistance%20Constraints/fig4.png %}
## 3.2 Trie-Dynamic Algorithm
利用active nodes的对称性：if u is an active node of v, then v must be an active node of u。减少冗余的计算。
Trie-Dynamic: 动态的构建trie结构，每次插入新的节点，计算在当前trie结构上新节点的active-node set，并基于对称性更新其他节点的active-node set。
时间复杂度下降为1/2，但需要维护所有点的active-node set 使得空间复杂度升高。
{% qnimg TrieJoin%20Efficient%20Triebased%20String%20Similarity%20Joins%20with%20EditDistance%20Constraints/fig5.png %}
## 3.3 Trie-PathStack Algorithm
Trie-Traverse：内存占用更小但有一些冗余的active-node计算。
Trie-Dynamic：避免了重复计算但使用了更多的内存。
Trie-PathStack解决了上述问题。
首先，维护一个"virtual partial" subtrie保存所有访问过的节点。对于每个未访问的节点，首先设置为已访问，然后计算"virtual partial" subtrie中的active-node set。
然后，先序遍历trie节点，并用栈保存需要被更新的节点。在先序遍历时，用栈保存从根到当前节点路径上的所有节点，访问当前节点时，其父节点一定在栈顶，利用父节点active-node set计算当前节点的active-node set，计算后只需更新栈中最多$\tau$个节点。
*主要是对Trie-Tranverse的改进，不是对整个图进行遍历，而是对已访问的部分进行遍历，然后利用栈保存路径。（这里不太懂，为啥要保存路径呢。。。）*
{% qnimg TrieJoin%20Efficient%20Triebased%20String%20Similarity%20Joins%20with%20EditDistance%20Constraints/fig6.png %}
# 4. PRUNING TECHNIQUES
**Length Pruning:** 长度相差大于$\tau$直接剪枝。
**Single-branch Pruning: **在同一个分支上，如果其叶子节点相同，则父节点可被剪枝。
**Count Pruning: **如果两个点只能生成一个字符串，则可以删掉一个字符串。
{% qnimg TrieJoin%20Efficient%20Triebased%20String%20Similarity%20Joins%20with%20EditDistance%20Constraints/fig7.png %}
# 5. INCREMENTAL SIMILARITY JOINS
> **Definition 2 (Incremental Similarity Joins).** Given a set of strings S, a new string set $\Delta S$, and an edit-distance threshold $\tau$, an incremental similarity join finds all similar string pairs $(r\in \Delta S, s\in S\cup \Delta S)$ such that $ED(r,s)\le \tau.$

{% qnimg TrieJoin%20Efficient%20Triebased%20String%20Similarity%20Joins%20with%20EditDistance%20Constraints/fig8.png %}














