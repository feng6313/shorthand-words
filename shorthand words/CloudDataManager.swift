//
//  CloudDataManager.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import Foundation
import SwiftUI

// Index.json数据模型
struct IndexData: Codable {
    let groups: [String]
    let lastUpdated: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case groups
        case lastUpdated = "last_updated"
        case description
    }
}

// 云端数据管理器
class CloudDataManager: ObservableObject {
    // 阿里云OSS基础URL - 请替换为您的实际OSS域名
    private let baseURL = "https://shorthand-words-data.oss-cn-hangzhou.aliyuncs.com"
    
    // 加载指定组的单词数据
    func loadWordData(groupId: String) async throws -> LocalWordsData {
        let urlString = "\(baseURL)/words/\(groupId).json"
        NSLog("🌐 尝试加载数据: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            NSLog("❌ URL无效: \(urlString)")
            throw CloudDataError.invalidURL
        }
        
        do {
            NSLog("🔄 开始网络请求...")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // 检查HTTP响应状态
            if let httpResponse = response as? HTTPURLResponse {
                NSLog("📡 HTTP状态码: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    NSLog("❌ HTTP错误: \(httpResponse.statusCode)")
                    throw CloudDataError.httpError(httpResponse.statusCode)
                }
            }
            
            NSLog("📦 收到数据大小: \(data.count) bytes")
            
            // 解析JSON数据
            let decoder = JSONDecoder()
            let wordsData = try decoder.decode(LocalWordsData.self, from: data)
            NSLog("✅ 数据解析成功，单词数量: \(wordsData.allWords.count)")
            return wordsData
            
        } catch let error as DecodingError {
            NSLog("❌ JSON解析错误: \(error.localizedDescription)")
            throw CloudDataError.decodingError(error.localizedDescription)
        } catch {
            NSLog("❌ 网络错误: \(error.localizedDescription)")
            throw CloudDataError.networkError(error.localizedDescription)
        }
    }
    
    // 获取思维图图片URL
    func getMindMapImageURL(groupId: String) -> String {
        // 动态生成图片URL，假设图片文件名与groupId相同
        let imageURL = "\(baseURL)/image/\(groupId).png"
        NSLog("🖼️ 生成思维图URL: \(imageURL) (组ID: \(groupId))")
        return imageURL
    }
    
    // 获取可用的数据组列表 - 从阿里云OSS的index.json动态读取
    func getAvailableDataGroups() async -> [String] {
        let indexURL = "\(baseURL)/index.json"
        NSLog("🌐 尝试从index.json获取数据组列表: \(indexURL)")
        
        guard let url = URL(string: indexURL) else {
            NSLog("❌ index.json URL无效: \(indexURL)")
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // 检查HTTP响应状态
            if let httpResponse = response as? HTTPURLResponse {
                NSLog("📡 index.json HTTP状态码: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    NSLog("❌ index.json HTTP错误: \(httpResponse.statusCode)")
                    return []
                }
            }
            
            // 解析index.json
            let decoder = JSONDecoder()
            let indexData = try decoder.decode(IndexData.self, from: data)
            NSLog("✅ 成功从index.json获取数据组列表: \(indexData.groups)")
            return indexData.groups
            
        } catch {
            NSLog("❌ 获取index.json失败: \(error.localizedDescription)")
            return []
        }
    }
    
    // 检查网络连接状态 - 通过访问index.json检查
    func checkNetworkConnection() async -> Bool {
        do {
            let url = URL(string: "\(baseURL)/index.json")!
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
}

// 云端数据错误类型
enum CloudDataError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case httpError(Int)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL地址"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .decodingError(let message):
            return "数据解析错误: \(message)"
        }
    }
}

// 数据缓存管理器
class DataCacheManager {
    private let cacheDirectory: URL
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("WordsCache")
        
        // 创建缓存目录
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // 缓存单词数据
    func cacheWordData(_ data: LocalWordsData, for groupId: String) {
        let cacheURL = cacheDirectory.appendingPathComponent("\(groupId).json")
        do {
            let jsonData = try JSONEncoder().encode(data)
            try jsonData.write(to: cacheURL)
        } catch {
            NSLog("缓存数据失败: \(error)")
        }
    }
    
    // 从缓存加载数据
    func loadCachedWordData(for groupId: String) -> LocalWordsData? {
        let cacheURL = cacheDirectory.appendingPathComponent("\(groupId).json")
        do {
            let data = try Data(contentsOf: cacheURL)
            return try JSONDecoder().decode(LocalWordsData.self, from: data)
        } catch {
            return nil
        }
    }
    
    // 检查缓存是否存在
    func hasCachedData(for groupId: String) -> Bool {
        let cacheURL = cacheDirectory.appendingPathComponent("\(groupId).json")
        return FileManager.default.fileExists(atPath: cacheURL.path)
    }
    
    // 清除所有缓存
    func clearAllCache() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            NSLog("清除缓存失败: \(error)")
        }
    }
}