//
//  DataModels.swift
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
}

struct WordDetail: Codable {
    let id: Int
    let english: String
    let phonetic: String
    let chinese: String
    let phrases: [Phrase]
    let examples: [Example]
    let highlight: Highlight?
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
    let english: [HighlightRange]?
}

struct HighlightRange: Codable {
    let start: Int
    let end: Int
    let color: String
}

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