---
layout:	post
title:	"http architecture"
date:	2019-02-20
tags:	["http"]
image:	""
---


http architecture
===

server
---
HTTP，TCP连接，访问/提供资源，配置web服务
建立连接：
	处理新连接:新连接建立后加入连接表，等待数据，同时可以主动关闭任意连接
	客户端主机名识别：通过DNS反向解析，对访问控制以及日志记录有作用
	通过ident确定客户端用户：记录日志时使用
		client:11180 -------> server:80
		client:113   <------- server:80
			client <-send "11180,80"--- server:80
			client -send "11180,80:USERID:UNIX:zhaogq"---> server:80
接收请求
处理请求
访问资源
构造响应
发送响应
记录日志

proxy
---

cache
---

gateway
---



















































