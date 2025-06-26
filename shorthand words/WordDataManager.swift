//
//  WordDataManager.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import Foundation

// JSON数据结构
struct LocalWordsData: Codable {
    let metadata: Metadata
    let coreWord: CoreWord
    let homePageWords: [String]
    let allWords: [WordDetail]
    
    enum CodingKeys: String, CodingKey {
        case metadata
        case coreWord = "core_word"
        case homePageWords = "home_page_words"
        case allWords = "all_words"
    }
}

struct Metadata: Codable {
    let version: String
    let totalWords: Int
    let coreWordPosition: Int
    let createdDate: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case version
        case totalWords = "total_words"
        case coreWordPosition = "core_word_position"
        case createdDate = "created_date"
        case description
    }
}

struct CoreWord: Codable {
    let english: String
    let phonetic: String
    let chinese: String
    let highlight: Highlight
}

struct WordDetail: Codable {
    let id: Int
    let english: String
    let phonetic: String
    let chinese: String
    let phrases: [Phrase]
    let examples: [Example]
    let highlight: Highlight
}

struct Phrase: Codable {
    let english: String
    let chinese: String
}

struct Example: Codable {
    let english: String
    let chinese: String
}

struct Highlight: Codable {
    let enabled: Bool
    let letters: [String]
}

// 数据管理器
class WordDataManager: ObservableObject {
    @Published var wordsData: [WordData] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    private var localWordsData: LocalWordsData?
    
    // 计算属性：获取所有词语的数量
    var allWordsCount: Int {
        return localWordsData?.allWords.count ?? 0
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
            self.wordsData = convertToWordData(from: localWordsData)
            self.isLoading = false
        } catch {
            errorMessage = "加载数据失败: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func convertToWordData(from localData: LocalWordsData) -> [WordData] {
        var convertedData: [WordData] = []
        
        // 只使用首页显示的单词
        for homePageWord in localData.homePageWords {
            if let wordDetail = localData.allWords.first(where: { $0.english == homePageWord }) {
                // 找到相关单词（除了当前单词外的其他单词）
                let otherWords = localData.homePageWords.filter { $0 != homePageWord }
                let relatedWord1 = otherWords.first ?? ""
                let relatedWord2 = otherWords.count > 1 ? otherWords[1] : ""
                
                // 转换词组数据
                let phrases = wordDetail.phrases.map { phrase in
                    WordPhrase(english: phrase.english, chinese: phrase.chinese)
                }
                
                // 转换例句数据
                let examples = wordDetail.examples.map { example in
                    WordExample(english: example.english, chinese: example.chinese)
                }
                
                let wordData = WordData(
                    mainWord: wordDetail.english,
                    translation: wordDetail.chinese,
                    relatedWord1: relatedWord1,
                    relatedWord2: relatedWord2,
                    phonetic: wordDetail.phonetic,
                    phrases: phrases,
                    examples: examples
                )
                convertedData.append(wordData)
            }
        }
        
        return convertedData
    }
    
    // 根据英文单词获取完整的WordData
    func getWordData(for englishWord: String) -> WordData? {
        guard let localData = localWordsData,
              let wordDetail = localData.allWords.first(where: { $0.english == englishWord }) else {
            return nil
        }
        
        // 找到相关单词（除了当前单词外的其他单词）
        let otherWords = localData.homePageWords.filter { $0 != englishWord }
        let relatedWord1 = otherWords.first ?? ""
        let relatedWord2 = otherWords.count > 1 ? otherWords[1] : ""
        
        // 转换词组数据
        let phrases = wordDetail.phrases.map { phrase in
            WordPhrase(english: phrase.english, chinese: phrase.chinese)
        }
        
        // 转换例句数据
        let examples = wordDetail.examples.map { example in
            WordExample(english: example.english, chinese: example.chinese)
        }
        
        return WordData(
            mainWord: wordDetail.english,
            translation: wordDetail.chinese,
            relatedWord1: relatedWord1,
            relatedWord2: relatedWord2,
            phonetic: wordDetail.phonetic,
            phrases: phrases,
            examples: examples
        )
    }
}