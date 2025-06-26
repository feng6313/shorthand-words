//
//  MindMapModels.swift
//  shorthand words
//
//  Created by feng on 2024/12/19.
//

import Foundation
import SwiftUI

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
    
    init() {
        loadMindMapData()
    }
    
    func loadMindMapData() {
        guard let url = Bundle.main.url(forResource: "mindmap_data", withExtension: "json") else {
            print("无法找到 mindmap_data.json 文件")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.mindMaps = try decoder.decode([MindMapData].self, from: data)
        } catch {
            print("解析思维图数据失败: \(error)")
        }
    }
    
    // 获取指定ID的思维图数据
    func getMindMap(by id: Int) -> MindMapData? {
        return mindMaps.first { $0.id == id }
    }
}