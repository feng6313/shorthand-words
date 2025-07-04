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
    @Published var isOnlineMode = false
    private var localWordsData: LocalWordsData?
    private let cloudManager = CloudDataManager()
    private let cacheManager = DataCacheManager()
    private var currentGroupId = "out_001" // 默认组ID
    
    // 计算属性：获取所有词语的数量（排除空数据）
    var allWordsCount: Int {
        guard let localData = localWordsData else { return 0 }
        // 统计非空单词的数量
        return localData.allWords.filter { !$0.english.isEmpty }.count
    }
    
    func getFirstWordDetail() -> WordDetail? {
        // 返回第8个位置的单词作为核心词
        guard let localData = localWordsData else { return nil }
        
        // 获取第8个位置的单词（索引为7）
        let nonEmptyWords = localData.allWords.filter { !$0.english.isEmpty }
        if nonEmptyWords.count >= 8 {
            return nonEmptyWords[7] // 第8个单词
        }
        
        // 如果没有第8个单词，返回第一个非空单词
        return nonEmptyWords.first
    }
    
    // 获取核心单词的中文翻译
    func getCoreWordChinese() -> String {
        guard let localData = localWordsData else { return "" }
        return localData.coreWord.chinese
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
        
        // 根据JSON中的home_page_words字段获取对应的WordDetail
        for englishWord in localData.homePageWords {
            if let wordDetail = localData.allWords.first(where: { $0.english.lowercased() == englishWord.lowercased() }) {
                homePageWordDetails.append(wordDetail)
            }
        }
        
        return homePageWordDetails
    }
    
    init() {
        NSLog("📱 WordDataManager: 初始化，默认组ID: \(currentGroupId)")
        loadWordsData()
    }
    
    // 设置当前组ID
    func setCurrentGroup(_ groupId: String) {
        currentGroupId = groupId
        loadWordsData()
    }
    
    // 获取当前组ID
    func getCurrentGroupId() -> String {
        return currentGroupId
    }
    
    private func loadWordsData() {
        NSLog("📱 WordDataManager: 开始loadWordsData，组ID: \(currentGroupId)")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 首先尝试从云端加载
                NSLog("📱 WordDataManager: 尝试从云端加载数据")
                let wordsData = try await loadFromCloud()
                await MainActor.run {
                    NSLog("📱 WordDataManager: 云端数据加载成功，单词数量: \(wordsData.allWords.count)")
                    self.localWordsData = wordsData
                    self.isOnlineMode = true
                    self.generateMindMapFromLocalData()
                    self.isLoading = false
                    self.errorMessage = nil // 清除错误信息
                }
                
                // 缓存数据到本地
                cacheManager.cacheWordData(wordsData, for: currentGroupId)
                NSLog("📱 WordDataManager: 数据已缓存")
                
            } catch {
                NSLog("📱 WordDataManager: 云端加载失败: \(error.localizedDescription)")
                // 云端加载失败，尝试从缓存加载
                await MainActor.run {
                    if let cachedData = cacheManager.loadCachedWordData(for: currentGroupId) {
                        NSLog("📱 WordDataManager: 使用缓存数据，单词数量: \(cachedData.allWords.count)")
                        self.localWordsData = cachedData
                        self.isOnlineMode = false
                        self.generateMindMapFromLocalData()
                        self.isLoading = false
                        self.errorMessage = "已切换到离线模式"
                    } else {
                        NSLog("📱 WordDataManager: 无缓存数据可用")
                        // 无缓存数据，设置错误信息
                        self.errorMessage = "无法加载数据：网络连接失败且无本地缓存"
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    // 从云端加载数据
    private func loadFromCloud() async throws -> LocalWordsData {
        NSLog("📱 WordDataManager: 开始加载数据组 \(currentGroupId)")
        do {
            let wordsData = try await cloudManager.loadWordData(groupId: currentGroupId)
            NSLog("📱 WordDataManager: 云端数据加载成功")
            return wordsData
        } catch {
            NSLog("📱 WordDataManager: 云端加载失败 - \(error.localizedDescription)")
            throw error
        }
    }
    

    
    // 手动刷新数据
    func refreshData() {
        loadWordsData()
    }
    
    // 清除缓存
    func clearCache() {
        cacheManager.clearAllCache()
    }
    
    // 获取思维图图片URL
    func getMindMapImageURL() -> String {
        return cloudManager.getMindMapImageURL(groupId: currentGroupId)
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