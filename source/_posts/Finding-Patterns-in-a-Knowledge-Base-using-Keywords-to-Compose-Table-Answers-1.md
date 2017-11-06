title: >-
  《Finding Patterns in a Knowledge Base using Keywords to Compose Table
  Answers》——论文笔记
author: 刘凯鑫
date: 2017-10-28 12:49:35
tags:
---
# ABSTRACT
represent each relevant **answer as a table**  which aggregates a set of entities or joins of entities within the asme table scheme or **pattern**.

A **pattern** is an aggregation of subtrees which contain all keywords in the texts and have the same structure and types on node/edges.

为关键字查询提供答案表（感觉就是top-k）。每个答案是有相同pattern的一群实体。
基于路径的索引。两种查询处理算法，一种针对结果数较少的查询，一种针对结果较多的查询。
# 1. INTRODUCTION


