---
layout:	post
title:	"www development history"
date:	2018-12-05
tags:	["http"]
image:	""
---

WWW Development History
===

1991年8月6日，第一个网站诞生. CERN的Tim Berners-Lee上线全球第一个web网站

1992年11月，已经有了26台服务器在线

1993年4月22日，Mosaic网页浏览器诞生

1993年4月30日，CERN允许万维网被任何人免费使用

1994年2月，Jerry万维网目录指南

1994年4月，中国接入互联网

1995年8月，已经有18957在线站点。

1995年8月9日，网景IPO

1995年8月24日，IE浏览器发布

1995年9月4日， eBay上线

1996年8月，在线站点达到 342081 个

1998年9月，谷歌诞生

2000年2月7日，八家网站包括雅虎、CNN、亚马逊在内遭受黑客攻击而瘫痪。

2000年8月，网站数量已达2000万

互联网 or 万维网?
===

互联网：全球互相连接的计算机网络系统

万维网：基于互联网的超链接和统一资源标志符连接的全球收集的文件和其他资源

万维网的基本构成
===

1. URI标识互联网资源的字符串
2. HTML网页标记语言
3. HTTP超文本传输协议

HTTP是什么?
===
HyperText Transfer Protocol

一种用于分布式、协作式和超媒体信息系统的应用层协议。HTTP是万维网的数据通信的基础。

设计HTTP最初的目的是为了提供一种发布和接收HTML页面的方法。

通过HTTP或者HTTPS协议请求的资源由统一资源标识符（Uniform Resource Identifiers，URI）来标识。

HTTP构成
===

MIME标识媒体类型

URI统一资源标识符

URL统一资源定位符：协议，服务器，资源名

URN：ietf:rfc:2141,名称作为唯一标识，不关心资源的网络位置

资源、报文、连接
===

url
---
url出现前的黑暗岁月

web与url出现之前，访问ftp://ftp.zhaogq.com中pub目录下的龙泽.avi
登陆ftp,访问pub目录，下载
url出现后
ftp://ftp.zhaogq.com/pub/龙泽.avi登陆即可下载文件
第一代web出现后
无需登陆操作即可http访问avi了
到如今
早已经可以在线播放

url语法
---
<scheme>://<user>:<password>@<host>:<port>/<path>;<params>?<query>#frag

* 相对url: 
	* 资源中显示提供：HTML<base>标签
	* 封装资源的基础url：相对HTML的url
	* 无基础的url：可能是损坏的url

	相对url转绝对url
	解析相对url--->方案非空-->url绝对的
	|------------->方案空,继承基础方案--->用户密码主机端口组件不为空--->构造url
	                |------->用户密码主机端口组件为空,继承基础组件-->检查路径组件--->'./'移除拼接
								                                        |----->'/'拼接
																		|----->路径空，继承。检查路径参数查询

* url字符集
	* url的字符集意义
	* encodeUrl:url完整编码，除数字 + 字母 + "-_.!~*'()'" + ",/?:@&=+$#"
	* encodeUrlComponent:部分编码，encodeUrl基础上增加了对",/?:@&=+$#"的编码

Http报文
---
* 报文流动性
	报文都是从上游(发送者)流向下游(接收者)，流入是指agent->server的request报文，流出是指server->agent的response报文
* HTTP报文的组成
* 请求与响应报文的区别
	* 起始行
	* 首部
	* 报文主体
	* request报文
	<method> <request-URL> <version>
	<headers>

	<entity-body>
	* response报文
	<version> <status> <reason-phrase>
	<headers>

	<entity-body>

* 请求报文的各种功能
	GET			请求指定的页面信息，并返回实体主体。
	HEAD		类似于get请求，只不过返回的响应中没有具体的内容，用于获取报头
	POST		向指定资源提交数据进行处理请求（例如提交表单或者上传文件）。数据被包含在请求体中。POST请求可能会导致新的资源的建立和/或已有资源的修改。
	PUT			从客户端向服务器传送的数据取代指定的文档的内容。
	DELETE		请求服务器删除指定的页面。
	CONNECT		HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器。
	OPTIONS		允许客户端查看服务器的性能。
	TRACE		回显服务器收到的请求，主要用于测试或诊断。
	PATCH		实体中包含一个表，表中说明与该URI所表示的原内容的区别。
	MOVE		请求服务器将指定的页面移至另一个网络地址。
	COPY		请求服务器将指定的页面拷贝至另一个网络地址。
	LINK		请求服务器建立链接关系。
	UNLINK		断开链接关系。
	WRAPPED		允许客户端发送经过封装的请求。
	Extension-mothed	在不改动协议的前提下，可增加另外的方法。

* 响应报文的状态码
	1**		信息，服务器收到请求，需要请求者继续执行操作
	2**		成功，操作被成功接收并处理
	3**		重定向，需要进一步的操作以完成请求
	4**		客户端错误，请求包含语法错误或无法完成请求
	5**		服务器错误，服务器在处理请求的过程中发生了错误

	100-continue:
	200-ok
	403-forbidden
	404-not found
	502-bad gateway
	504-gateway timeout


* 各种HTTP首部的作用
	通用首部:通用信息首部:Connection, Date, Transfer-Encoding，通用缓存首部：Cache-Control,Pragma
	请求首部:请求信息首部:Client-ip,Host,UA-CPU,UA-OS,User-Agent;Accept:Accept,Accept-Charset,Accept-Encoding
		条件请求首部：Expect，If-Match，If-Modified-Since，Range;安全条件请求：cookie;代理请求首部:Max-Forward，Proxy-Connection
	响应首部
		相应信息首部:Age,Server;协商首部:Accept-Range;安全相应首部:Set-Cookie
	实体首部：内容首部:Content-Length,Content-MD5,Content-Encoding;实体缓存首部:ETag,Expires,Last-Modified
	实体首部
