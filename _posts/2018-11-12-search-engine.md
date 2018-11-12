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

索引
---
进行快速查找,目的高效

1. 反转列表(inverted list):

	每个单词:在多少文档(url 文件名 引用)出现,是什么文档,出现次数,位置信息。
	数据结构:文档ID到实际文档(Document Mananger), 每个单词属性(Term Dictionary), 存储文档属性
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
	分布式计算框架MapReduce:将一个大任务分割多个小任务，下发给mapper计算中间结果，中间结果反馈给reducer程序继续处理，得到最终结果。
	Term Dictionary:索引中单词与文档都为整形ID而不是字符串，ID与字符串映射由Term Dictionary维护;多少文档出现document frequency;文档中出现概率 = 文档总数/多少文档出现,为排序提供依据
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

	
