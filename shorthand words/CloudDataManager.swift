//
//  CloudDataManager.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import Foundation
import SwiftUI

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
        // 根据OSS中实际存在的文件名映射
        // 从用户提供的OSS截图可以看到，images目录下有out_001.png和out_002.png
        // 但是测试发现这些文件路径返回404，可能文件名或路径不正确
        let imageFileName: String
        switch groupId {
        case "out_001":
            imageFileName = "out_001"
        case "out_002":
            imageFileName = "out_002"
        default:
            // 对于其他组ID，尝试使用out_001作为默认图片
            imageFileName = "out_001"
        }
        
        // 注意：根据OSS截图，文件在images目录下，但实际测试返回404
        // 可能需要用户确认正确的文件路径
        let imageURL = "\(baseURL)/images/\(imageFileName).png"
        NSLog("🖼️ 生成思维图URL: \(imageURL) (组ID: \(groupId))")
        NSLog("⚠️ 注意：该URL可能返回404，需要确认OSS中的实际文件路径")
        return imageURL
    }
    
    // 获取可用的数据组列表
    func getAvailableDataGroups() async -> [String] {
        // 尝试获取已知的数据组列表
        let knownGroups = ["out_001", "out_002", "out_003", "out_004"]
        var availableGroups: [String] = []
        
        for groupId in knownGroups {
            let urlString = "\(baseURL)/words/\(groupId).json"
            guard let url = URL(string: urlString) else { continue }
            
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    availableGroups.append(groupId)
                    NSLog("✅ 发现可用数据组: \(groupId)")
                }
            } catch {
                NSLog("❌ 数据组 \(groupId) 不可用: \(error.localizedDescription)")
            }
        }
        
        NSLog("📋 总共发现 \(availableGroups.count) 个可用数据组: \(availableGroups)")
        return availableGroups
    }
    
    // 检查网络连接状态
    func checkNetworkConnection() async -> Bool {
        do {
            let url = URL(string: "\(baseURL)/words/out_001.json")!
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