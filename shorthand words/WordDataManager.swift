//
//  WordDataManager.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import Foundation

// 数据管理器
class WordDataManager: ObservableObject {
    // 移除wordsData，直接使用localWordsData
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var mindMaps: [MindMapData] = []
    private var localWordsData: LocalWordsData?
    
    // 计算属性：获取所有词语的数量（从JSON metadata中读取）
    var allWordsCount: Int {
        return localWordsData?.metadata.totalWords ?? 0
    }
    
    func getFirstWordDetail() -> WordDetail? {
        // 返回核心词，如果没有核心词则返回第一个单词
        guard let localData = localWordsData else { return nil }
        
        // 查找与核心词匹配的WordDetail
        let coreWordDetail = localData.allWords.first { $0.english.lowercased() == localData.coreWord.english.lowercased() }
        
        return coreWordDetail ?? localData.allWords.first
    }
    
    func getWordDetail(for englishWord: String) -> WordDetail? {
        return localWordsData?.allWords.first { $0.english.lowercased() == englishWord.lowercased() }
    }
    
    func getWordDetail(by word: String) -> WordDetail? {
        return localWordsData?.allWords.first { $0.english.lowercased() == word.lowercased() }
    }
    
    func getHomePageWords() -> [WordDetail] {
        guard let localData = localWordsData else { return [] }
        
        var homePageWordDetails: [WordDetail] = []
        
        for homePageWord in localData.homePageWords {
            if let wordDetail = localData.allWords.first(where: { $0.english.lowercased() == homePageWord.lowercased() }) {
                // 只添加非空的单词
                if !wordDetail.english.isEmpty {
                    homePageWordDetails.append(wordDetail)
                }
            }
        }
        
        return homePageWordDetails
    }
    
    init() {
        loadWordsData()
    }
    
    private func loadWordsData() {
        guard let url = Bundle.main.url(forResource: "local_words_data", withExtension: "json") else {
            errorMessage = "找不到local_words_data.json文件"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let localWordsData = try JSONDecoder().decode(LocalWordsData.self, from: data)
            
            // 保存原始数据
            self.localWordsData = localWordsData
            
            // 转换数据格式
            // 直接使用localWordsData，不需要转换
            
            // 生成思维图数据
            generateMindMapFromLocalData()
            
            self.isLoading = false
        } catch {
            errorMessage = "加载数据失败: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // 移除convertToWordData方法，直接使用WordDetail
    
    // 移除getWordData方法，使用getWordDetail方法
    
    // 思维图相关功能
    private func generateMindMapFromLocalData() {
        guard let localData = localWordsData else { return }
        
        // 将所有单词转换为思维图格式
        let mindMapWords = localData.allWords.map { wordDetail in
            MindMapWord(
                english: wordDetail.english,
                chinese: wordDetail.chinese,
                backgroundColor: "F8F8F8"
            )
        }
        
        // 创建一个思维图数据
        let mindMapData = MindMapData(
            id: 1,
            title: localData.metadata.description,
            words: mindMapWords
        )
        
        self.mindMaps = [mindMapData]
    }
    
    // 获取指定ID的思维图数据
    func getMindMap(by id: Int) -> MindMapData? {
        return mindMaps.first { $0.id == id }
    }
}