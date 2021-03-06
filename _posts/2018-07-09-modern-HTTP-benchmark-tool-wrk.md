---
layout:  post
title:   "Modern HTTP benchmarking tool -- wrk"
date:    2018-07-09
tags:    ["feature photo"]
image:   "https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_title.jpg"
---

Modern HTTP benchmarking tool -- wrk
===

1.概念简介
---

系统性能描述是系统或组件在给定约束中实现的指定功能的程度，诸如速度、正确性、内存使用等。  性能测试报告中，对系统性能的描述应该是多方面的，如：执行效率、稳定性、兼容行、可靠性、可扩展性容量等，执行效率通过并发用户数、响应时间、吞吐量、成功率、资源消耗综合体现。

性能测试: `负载测试、压力测试、并发测试、容量测试，通过不同测试手段，获得或验证性能指标，性能测试会在不同负载情况下进行`

#### 1) 并发测试

`当测试多用户并发访问同一个应用、模块、数据时是否产生隐藏的并发问题，如内存泄漏、线程锁、资源争用问题`

#### 2) 负载测试

`模拟在超负荷环境中运行,通过不断加载(如逐渐增加模拟用户的数量)或其它加载方式来观察不同负载下系统的响应时间和数据吞吐量系统占用的资源(如CPU内存)等,以检验系统的行为和特性,以发现系统可能存在的性能瓶颈、内存泄漏、不能实时同步等问题，是一种测试方法`

#### 3) 压力测试

`高负载(大数据量大量并发用户等)下的测试,查看应用系统在峰值使用情况下操作行为,从而有效地发现系统的某项功能隐患系统是否具有良好的容错能力和可恢复能力。压力测试分为高负载下的长时间(如24小时以上)的稳定性压力测试和极限负载情况下导致系统崩溃的破坏性压力测试`

#### 4) 容量测试

`通过测试预先分析出反映软件系统应用特征的某项指标的极限值（如最大并发用户数），系统在其极限状态下没有出现任何软件故障或还能保持主要功能正常运行。容量测试是面向数据的,并且它的目的是显示系统可以处理目标内确定的数据容量。可以视为破坏性压力测试的一种副产品`

2.HTTP性能测试指标
---

#### 1) 并发数
+ 广义并发：一个时间内操作事务的虚拟用户。线程并发量是压测时间段内虚拟用户总数，这也是并发原始值
+ 狭义并发：单位时间内向系统发起请求的虚拟用户。单位时间内，并发数可能会动态变化
+ 并发量计算公式：

        C=nL/T

        C：并发
        n：压测时间段内所有的请求数
        L：平均响应时间
        T：压测总时长
        L（平均响应时间）≠ T（总时长）/ n（总请求）

#### 2) 响应时间 `从发起到完成请求所经过的时间`
+ 如：(网络传输、应用服务处理、数据库服务处理时间)

#### 3) 吞吐量 `每秒钟完成的事务或请求数`
+ 如：(字节/秒、请求数/秒、页面数/秒)

+ 吞吐量计算公式：

        公式1： 吞吐量=并发数/平均响应时间
        公式2： 吞吐量=请求总数/总时长

3.需求
---
支持POST

支持SSL

吞吐量基本的信息

报表等

4.压测软件，走过的坑
---

|             |  并发量 | https  |  POST  | 报告完善度 | 可扩展性 |
| --------    | :-----: | :----: | :----: |   :----:   |  :----:  |
| http_load   | 中      |   Y    |   N    |    中      |    中    | select
| webbench    | 高      |   Y    |   N    |    中      |    中    | fork
| ab          | 高      |   Y    |   Y    |    中      |    中    | unknown
| siege       | 低      |   Y    |   Y    |    中      |    中    | multi thread
| wrk/wrk2    | 高      |   Y    |   Y    |    中      |    高    | epoll

[^_^]: ab单线程,cpu利用不够充分，操作简便易用，报表丰富，并发量高，但无法达到2w+

[^_^]: curl-loader每个均拥有自己的源IP,信息量过少，实时输出成功失败数；但在模拟user时，会构建虚拟网卡，在这个过程中，导致虚拟机无法访问外网，操作不够简便

[^_^]: siege并发量为线程数，并发量过大时，线程间切换会影响并发性能

[^_^]: wrk2存在延迟计算异常的情况，而且wrk2增加校准测试时间，统计详细请求频率等功能对于我门来说意义不大，反而增加了程序复杂度去实现了几个对我们来说没有意义的功能,并且该软件不够稳定。

其他:很多极简软件，https都不支持的就不提及了

5.wrk特点（github上万关注）
---
特点：高扩展，高并发，高可用

+ 高扩展：除了我们的需求外，构建请求时访问lua脚本，可扩展性强，在此基础上可以处理json实现多并发以及并发混合测试。

+ 高并发：其次wrk同时支持epoll,select,evport,kqueue等多路复用方法，使其支持成千上万的并发，前提是你的cpu足够强大。

+ 高可用：即使是在并发量超高情况下，也不会出现无法使用的情况。

6.wrk使用
---

	Usage: wrk <options> <url>                            
	  Options:                                            
		-c, --connections <N>  Connections to keep open   
		-d, --duration    <T>  Duration of test           
		-i, --interval    <T>  Request sampling interval  
		-t, --threads     <N>  Number of threads to use   
														  
		-s, --script      <S>  Load Lua script file       
		-j, --json        <S>  Load json data for script  
		-H, --header      <H>  Add header to request      
			--latency          Print latency statistics   
		-v, --version          Print version details      
														  
	  Numeric arguments may include a SI unit (1k, 1M, 1G)
	  Time arguments may include a time unit (2s, 2m, 2h)

      wrk -i2 -t2 -c100 -d5M https://www.baidu.com --latency
      在5M内，由2个线程并发100去访问baidu网站，并在最后将每两秒的rps依次输出，并绘制成图表。

![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_param.png)
![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_result.png)
![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_latency.png)
![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_rps_chart.png)
![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_latency_chart.png)
![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk_result_chart.png)

7.wrk架构
---
#### 1) 整体架构:

由与cpu核心数量一致的线程数构成(保证了wrk在高负载情况下的cpu充分使用)，所有线程平均分配并发数，并对应一个eventloop，将所需要监控的event添加到epoll中，由epoll监控event的状态，当event状态变化后，由event loop作为载体取出，并调用相关函数对数据做处理。		
![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk-architecture-structure.png)

#### 2) ae模块 支持跨平台的多路复用，优先使用epoll,evport,kqueue,如果平台下不存在以上I/O事件通知机制，则采用select

#### 3) lua模块

![alt](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/wrk-lua.png)

wrk的全局属性

    wrk = {
      scheme  = "http",
      host    = "localhost",
      port    = nil,
      method  = "GET",
      path    = "/",
      headers = {},
      body    = nil,
      thread  = <userdata>,
    } 

wrk的全局方法

    -- 生成整个request的string，例如：返回
    -- GET / HTTP/1.1
    -- Host: tool.lu
    function wrk.format(method, path, headers, body)

    -- 获取域名的IP和端口，返回table，例如：返回 `{127.0.0.1:80}`
    function wrk.lookup(host, service)

    -- 判断addr是否能连接，例如：`127.0.0.1:80`，返回 true 或 false
    function wrk.connect(addr)

Setup阶段

    function setup(thread)

    -- thread提供了1个属性，3个方法
    -- thread.addr 设置请求需要打到的ip
    -- thread:get(name) 获取线程全局变量
    -- thread:set(name, value) 设置线程全局变量
    -- thread:stop() 终止线程

Running阶段

    function init(args)
    -- 每个线程仅调用1次，args 用于获取命令行中传入的参数, 例如 --env=pre

    function delay()
    -- 每个线程调用多次，发送下一个请求之前的延迟, 单位为ms

    function request()
    -- 每个线程调用多次，返回http请求

    function response(status, headers, body)
    -- 每个线程调用多次，返回http响应

Done阶段
可以用于自定义结果报表，整个过程中只执行一次

    function done(summary, latency, requests)

    latency.min              -- minimum value seen
    latency.max              -- maximum value seen
    latency.mean             -- average value seen
    latency.stdev            -- standard deviation
    latency:percentile(99.0) -- 99th percentile value
    latency(i)               -- raw value and count

    summary = {
      duration = N,  -- run duration in microseconds
      requests = N,  -- total completed requests
      bytes    = N,  -- total bytes received
      errors   = {
        connect = N, -- total socket connection errors
        read    = N, -- total socket read errors
        write   = N, -- total socket write errors
        status  = N, -- total HTTP status codes > 399
        timeout = N  -- total request timeouts
      }
    }

`通过编写lua脚本,解析json request (HTTP METHOD, URL, BASE64，POST DATA)，打乱request排序，当connection每次连接，都会依次获取打乱后的request `

#### 4) 日志统计模块

完成时统计：`请求量，数据量，错误类型，错误状态`

+ `在完成全部测试后，由线程结构累计统计`

实时统计：`延时响应时间，实时RPS`

+ `在各个工作线程中，会有timer定时器，定时统计最大值、最小值、计算统计时间间隔内的请求量`

计算统计：`整体RPS，Transfer Rate，stdev`

+ `通过现有数据再加工完成的统计`

#### 5) html日志展示模块

`通过将模板取到内存，${}使用该格式作为HTML中要替换的变量，完成匹配替换，重新写入log.html文件中，即可完成日志的生成工作`

8.wrk架构优势
---
##### 1) 阻塞 I/O（blocking IO）
在IO执行的两个阶段都被block

![blockingIO](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/blockingIO.png)

##### 2) 非阻塞 I/O（nonblocking IO）
用户进程需要不断的主动询问kernel数据

![nonblockingIO](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/nonblockingIO.png)

##### 3) I/O 多路复用（IO multiplexing）
通过一种机制一个进程能同时等待多个文件描述符，而这些文件描述符（套接字描述符）其中的任意一个进入读就绪状态,函数就可以返回

![IOmultiplexing](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/IOmultiplexing.png)

##### 4) 异步 I/O（asynchronous IO）
通过信号通知操作完成，不存在阻塞状态

![asynchronousIO](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/asynchronousIO.png)

##### 5) I/O比较
![IOModel](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/IOModel.png)

##### 6) 各类异步I/O差异
![selectPollEpoll](https://raw.githubusercontent.com/zhaoguangqiang/zhaoguangqiang.github.io/master/_posts/img/selectPollEpoll.png)
