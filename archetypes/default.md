---
slug: "{{ replace .File.ContentBaseName "-" " " | urlize }}"
author: "Tobia Cavalli"
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: "{{ now.Format "2006-01-02" }}"
# lastmod: ""
summary: ""
description: ""
tags: []
# lead: ""
# math: false
# toc: false
draft: true
---
