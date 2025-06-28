//
//  CloudDataManager.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import Foundation
import SwiftUI

// 数据组索引结构
struct DataGroupIndex: Codable {
    let groups: [String]
    let lastUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case groups
        case lastUpdated = "last_updated"
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
        // 直接使用groupId作为图片文件名，不再硬编码
        let imageURL = "\(baseURL)/image/\(groupId).png"
        NSLog("🖼️ 生成思维图URL: \(imageURL) (组ID: \(groupId))")
        return imageURL
    }
    
    // 检查思维图图片是否存在
    func checkMindMapImageExists(groupId: String) async -> Bool {
        let imageURL = getMindMapImageURL(groupId: groupId)
        guard let url = URL(string: imageURL) else { return false }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            NSLog("❌ 检查思维图失败: \(error.localizedDescription)")
        }
        return false
    }
    
    // 获取可用的数据组列表
    func getAvailableDataGroups() async -> [String] {
        // 首先尝试从索引文件获取文件列表
        if let indexGroups = await loadGroupsFromIndex() {
            NSLog("📋 从索引文件获取到 \(indexGroups.count) 个数据组: \(indexGroups)")
            return indexGroups
        }
        
        // 如果索引文件不存在，使用动态发现方式
        NSLog("⚠️ 索引文件不存在，使用动态发现方式")
        return await discoverAvailableGroups()
    }
    
    // 从索引文件加载数据组列表
    private func loadGroupsFromIndex() async -> [String]? {
        let indexURL = "\(baseURL)/index.json"
        guard let url = URL(string: indexURL) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let indexData = try JSONDecoder().decode(DataGroupIndex.self, from: data)
                NSLog("✅ 成功加载索引文件，包含 \(indexData.groups.count) 个数据组")
                return indexData.groups
            }
        } catch {
            NSLog("❌ 加载索引文件失败: \(error.localizedDescription)")
        }
        return nil
    }
    
    // 动态发现可用的数据组
    private func discoverAvailableGroups() async -> [String] {
        var availableGroups: [String] = []
        
        // 尝试常见的文件名模式
        let patterns = [
            // 数字模式
            (1...20).map { String(format: "out_%03d", $0) },
            // 字母模式
            ["words_a", "words_b", "words_c", "words_d", "words_e"],
            // 其他可能的模式
            ["basic", "advanced", "intermediate", "expert"],
            ["level1", "level2", "level3", "level4", "level5"]
        ].flatMap { $0 }
        
        // 并发检查所有可能的文件
        await withTaskGroup(of: String?.self) { group in
            for pattern in patterns {
                group.addTask {
                    await self.checkGroupExists(pattern)
                }
            }
            
            for await result in group {
                if let groupId = result {
                    availableGroups.append(groupId)
                }
            }
        }
        
        // 按名称排序
        availableGroups.sort()
        NSLog("📋 动态发现 \(availableGroups.count) 个可用数据组: \(availableGroups)")
        return availableGroups
    }
    
    // 检查指定数据组是否存在
    private func checkGroupExists(_ groupId: String) async -> String? {
        let urlString = "\(baseURL)/words/\(groupId).json"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                NSLog("✅ 发现可用数据组: \(groupId)")
                return groupId
            }
        } catch {
            // 静默处理错误，避免日志过多
        }
        return nil
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