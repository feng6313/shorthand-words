//
//  MindMapModels.swift
//  shorthand words
//
//  Created by feng on 2024/12/19.
//

import Foundation
import SwiftUI

// 导入WordDataManager中的数据结构
// 由于LocalWordsData等结构体在WordDataManager.swift中定义，这里需要确保能够访问

// 思维图单词数据模型
struct MindMapWord: Codable, Identifiable {
    let id = UUID()
    let english: String
    let chinese: String
    let backgroundColor: String
    
    private enum CodingKeys: String, CodingKey {
        case english, chinese, backgroundColor
    }
}

// 思维图数据模型
struct MindMapData: Codable, Identifiable {
    let id: Int
    let title: String
    let words: [MindMapWord]
}

// 思维图数据管理器
class MindMapDataManager: ObservableObject {
    @Published var mindMaps: [MindMapData] = []
    private var localWordsData: LocalWordsData?
    
    init() {
        loadMindMapData()
    }
    
    func loadMindMapData() {
        guard let url = Bundle.main.url(forResource: "local_words_data", withExtension: "json") else {
            print("无法找到 local_words_data.json 文件")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.localWordsData = try decoder.decode(LocalWordsData.self, from: data)
            
            // 从local_words_data.json生成思维图数据
            generateMindMapFromLocalData()
        } catch {
            print("解析本地单词数据失败: \(error)")
        }
    }
    
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