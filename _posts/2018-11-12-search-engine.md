---
layout:	post
title:	"search engine"
date:	2018-11-12
tags:	["search"]
image:	""
---


search engine
===

搜索引擎
---
将服务器存储内容与用户检索内容匹配，并相应匹配结果

爬虫
---
将网页爬取到本地服务器。

1. 获取原始文档:Nutch,jsoup,heritrix
2. 创建文档对象
	数据结构: Document{DocId, Field{fileName:fileName}, Filed{fileContent:fileContent}, Filed{fileTitle:fileTitle}}
3. 分析文档
	提取单词、将字母转为小写、去除标点符号、去除停用词
	每个单词为一个Term:Term{Field, word},注意：不同的field的相同单词属于不同term

索引 -- 反转列表(inverted list)
---
进行快速查找,目的高效

	wordId --- word --- file frequency --- inverted list(DocId ,frequercy, pos)
	每个单词对应一个反转列表:在多少文档(url 文件名 引用)出现,是什么文档,出现次数,位置信息。
	存储结构：hash存储，B+树存储
	数据结构:文档ID到实际文档(Document Mananger), 每个单词属性(Term Dictionary), 存储文档属性
	Term Dictionary:索引中单词与文档都为整形ID而不是字符串，ID与字符串映射由Term Dictionary维护;多少文档出现document frequency;文档中出现概率 = 文档总数/多少文档出现,为排序提供依据
	创建索引:首先进行文档解析，不同文档对应不同解析器。
			自然语言处理算法(分词(tokenzation), 词干提取(stemming)，识别词性(part-of-speech tagging), n-gram模型创建，识别文档中命名体)
	索引生成程序:
		IndexFile* indexGenerator() {
			while((file = filesStore->next()) != NULL){
				filesScaner->scanToIndexMemory(file)
				if (filesScaner->indexMemorySize() >= MAX_INDEX_MEMORY)
					filesScaner->syncToInvertedBlock()
			}
			return filesScaner->mergeAllBlocks()
		}
	更新:
		IndexFile* staticIndex = indexGenerator();
		IndexFile* dynamicIndex;
		while(true) {
			if (filesStore->count() > MAX_FILES_NUM) {
				dynamicIndex = indexGenerator()
			}
			sleep(24 * 60 * 60)
			if (dynamicIndex->size() > MAX_DYNAMIC_SIZE)
				update(staticIndex, dynamicIndex)
		}
	删除:
		deleteSrcFile(fileName){
			g_deleteList->add(fileName)
			if (deleteList->count() > MAX_DELETE_LIST)
				g_indexFile = regenerateIndex()
		}
	搜索:
		search() {
			result_list = m_indexFile->find(keyWord)
			return sort(result_list - g_deleteList)
		}

	由此，GOOGLE推出了分布式计算框架MapReduce:将一个大任务分割多个小任务，下发给mapper计算中间结果，中间结果反馈给reducer程序继续处理，得到最终结果。

搜索
---
	解析为树形结构:AND(TERM(word1), TERM(word2))
	TERM将词组转为对应的反转列表
	AND将反转列表转为分数列表，并对分数列表中文档id集合求交集，生成新的分数列表。每个文档分数 = 各个输入的分数列表乘积
	OR文档集合做并集
	NEAR(term1, term2),term1与term2相邻的文档
	WINDOW(4,term1,term2),term1与term2相邻不超过4个的单词
	WEIGHTED_SUM对分数加权和操作

	multiple representation model:分别处理title，url,body
		WEIGHTED_SUM(0.1, AND(url(iphone6), url(售价)),
					0.2, AND(title(iphone6),url(售价)),
					0.7, AND(body(iphone6), url(售价)))
	Sequential Dependency Model:将不同方法生成解析树，最后加权求和
		bag of words 匹配，即 AND(“iphone 6”， 售价);
		N-gram 匹配，即 NEAR(“Iphone 6”， 售价)
		短窗口匹配，即 WINDOW(8, “iphone 6”, 售价)
		WEIGHTED_SUM(0.7, AND(“iphone 6”， 售价), 0.2, NEAR("Iphone 6”， 售价), 0.1 WINDOW(8, “iphone 6”, 售价) )

排序
---
	score(doc, query)=f(IRscore(doc,query),PageRank(doc))
		IRscore在文档中query在doc中的检索得分
			tf-idf(term frequency–inverse document frequency)
			单词-文档组合都对应一个tf-idf:tf:该文档中该单词出现数量，df：含有该单词的文档数量，idf：一个文档含有该单词概率倒数，消除常用词干扰
			tf-idf=tf*totalDocCount/df,为避免文档中刻意罗列关键词，还需引入PageRank

		PageRank文档级别得分:对网页重要程度进行打分，A链接指向B，A链接重要，B链接的重要程度也会增加.
