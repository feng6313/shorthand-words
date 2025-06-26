//
//  ContentView.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import SwiftUI

// 单词数据结构
struct WordData: Codable, Identifiable {
    let id: UUID
    let mainWord: String
    let translation: String
    let relatedWord1: String
    let relatedWord2: String
    
    init(mainWord: String, translation: String, relatedWord1: String, relatedWord2: String) {
        self.id = UUID()
        self.mainWord = mainWord
        self.translation = translation
        self.relatedWord1 = relatedWord1
        self.relatedWord2 = relatedWord2
    }
    
    // Custom coding keys to exclude id from JSON encoding/decoding
    enum CodingKeys: String, CodingKey {
        case mainWord, translation, relatedWord1, relatedWord2
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.mainWord = try container.decode(String.self, forKey: .mainWord)
        self.translation = try container.decode(String.self, forKey: .translation)
        self.relatedWord1 = try container.decode(String.self, forKey: .relatedWord1)
        self.relatedWord2 = try container.decode(String.self, forKey: .relatedWord2)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mainWord, forKey: .mainWord)
        try container.encode(translation, forKey: .translation)
        try container.encode(relatedWord1, forKey: .relatedWord1)
        try container.encode(relatedWord2, forKey: .relatedWord2)
    }
}

struct ContentView: View {
    // 预定义颜色数组
    let circleColors = [
        "000000", "FF0000", "2B00FF", "9900FF",
        "D69A00", "56AA53", "0174BB", "95006F",
        "D95700", "93A63E", "1CA299", "4D0095",
        "D6067F", "0E6B19", "C33131", "967439"
    ]
    
    // 示例单词数据
    let wordsData = [
        WordData(mainWord: "black", translation: "黑色的", relatedWord1: "lack", relatedWord2: "look"),
        WordData(mainWord: "white", translation: "白色的", relatedWord1: "light", relatedWord2: "right"),
        WordData(mainWord: "green", translation: "绿色的", relatedWord1: "tree", relatedWord2: "free"),
        WordData(mainWord: "blue", translation: "蓝色的", relatedWord1: "true", relatedWord2: "new"),
        WordData(mainWord: "red", translation: "红色的", relatedWord1: "bed", relatedWord2: "led"),
        WordData(mainWord: "yellow", translation: "黄色的", relatedWord1: "hello", relatedWord2: "below"),
        WordData(mainWord: "orange", translation: "橙色的", relatedWord1: "range", relatedWord2: "change"),
        WordData(mainWord: "purple", translation: "紫色的", relatedWord1: "circle", relatedWord2: "simple"),
        WordData(mainWord: "brown", translation: "棕色的", relatedWord1: "down", relatedWord2: "town"),
        WordData(mainWord: "pink", translation: "粉色的", relatedWord1: "think", relatedWord2: "link"),
        WordData(mainWord: "gray", translation: "灰色的", relatedWord1: "play", relatedWord2: "way"),
        WordData(mainWord: "gold", translation: "金色的", relatedWord1: "old", relatedWord2: "cold"),
        WordData(mainWord: "silver", translation: "银色的", relatedWord1: "river", relatedWord2: "never"),
        WordData(mainWord: "clear", translation: "透明的", relatedWord1: "near", relatedWord2: "hear"),
        WordData(mainWord: "dark", translation: "深色的", relatedWord1: "park", relatedWord2: "mark"),
        WordData(mainWord: "bright", translation: "明亮的", relatedWord1: "light", relatedWord2: "night")
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let padding: CGFloat = 12
                let spacing: CGFloat = 12
                let blockWidth = (screenWidth - padding * 2 - spacing) / 2
                let blockHeight = blockWidth / 0.75
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.fixed(blockWidth), spacing: spacing),
                        GridItem(.fixed(blockWidth), spacing: 0)
                    ], spacing: spacing) {
                        ForEach(wordsData.indices, id: \.self) { index in
                            NavigationLink(destination: WordDetailView(
                                wordData: wordsData[index],
                                circleColor: Color(hex: circleColors[index % circleColors.count])
                            )) {
                                WordBlockView(
                                    wordData: wordsData[index],
                                    blockWidth: blockWidth,
                                    blockHeight: blockHeight,
                                    circleColor: Color(hex: circleColors[index % circleColors.count]),
                                    index: index
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, padding)
                    .padding(.top, padding)
                }
                .background(Color(hex: "f3f3f3"))
            }
            .navigationTitle("速记1600词")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 扩展Color以支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 单词块视图组件
struct WordBlockView: View {
    let wordData: WordData
    let blockWidth: CGFloat
    let blockHeight: CGFloat
    let circleColor: Color
    let index: Int
    @State private var isCollected: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white)
            .frame(width: blockWidth, height: blockHeight)
            .overlay(
                ZStack {
                    // 第一个圆 - 主单词（现在在上面）
                    Circle()
                        .fill(circleColor)
                        .frame(width: blockWidth * 0.6, height: blockWidth * 0.6)
                        .position(
                            x: blockWidth / 2,
                            y: 20 + (blockWidth * 0.6) / 2
                        )
                        .overlay(
                            VStack(spacing: 2) {
                                Text(wordData.mainWord)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(wordData.translation)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .position(
                                x: blockWidth / 2,
                                y: 20 + (blockWidth * 0.6) / 2
                            )
                        )
                    
                    // 第二个圆 - 相关单词1（距离上边缘124点）
                    Circle()
                        .fill(Color(hex: "EBEBEB"))
                        .frame(width: blockWidth * 0.3, height: blockWidth * 0.3)
                        .position(
                            x: 12 + (blockWidth * 0.3) / 2,
                            y: 124 + (blockWidth * 0.3) / 2
                        )
                        .overlay(
                            Text(wordData.relatedWord1)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(circleColor)
                                .position(
                                    x: 12 + (blockWidth * 0.3) / 2,
                                    y: 124 + (blockWidth * 0.3) / 2
                                )
                        )
                    
                    // 第三个圆 - 相关单词2（距离上边缘124点）
                    Circle()
                        .fill(circleColor)
                        .frame(width: blockWidth * 0.18, height: blockWidth * 0.18)
                        .position(
                            x: blockWidth - 24 - (blockWidth * 0.18) / 2,
                            y: 124 + (blockWidth * 0.18) / 2
                        )
                        .overlay(
                            Text(wordData.relatedWord2)
                                .font(.system(size: 6, weight: .semibold))
                                .foregroundColor(.white)
                                .position(
                                    x: blockWidth - 24 - (blockWidth * 0.18) / 2,
                                    y: 124 + (blockWidth * 0.18) / 2
                                )
                        )
                    
                    // 编号圆角矩形（左下角）
                    RoundedRectangle(cornerRadius: 13)
                        .fill(Color(hex: "EBEBEB"))
                        .frame(width: 45, height: 26)
                        .position(
                            x: 12 + 45 / 2,
                            y: blockHeight - 12 - 26 / 2
                        )
                        .overlay(
                            Text(String(format: "%03d", index + 1))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "878787"))
                                .position(
                                    x: 12 + 45 / 2,
                                    y: blockHeight - 12 - 26 / 2
                                )
                        )
                    
                    // 单词数量圆形（编号圆角矩形右侧4点处）
                    Circle()
                        .fill(Color(hex: "EBEBEB"))
                        .frame(width: 26, height: 26)
                        .position(
                            x: 12 + 45 + 4 + 13,
                            y: blockHeight - 12 - 13
                        )
                        .overlay(
                            Text("9")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "000000"))
                                .position(
                                    x: 12 + 45 + 4 + 13,
                                    y: blockHeight - 12 - 13
                                )
                        )
                    
                    // 收藏图标（右下角）
                    Button(action: {
                        isCollected.toggle()
                    }) {
                        Image(isCollected ? "collect_b" : "collect_w")
                            .resizable()
                            .frame(width: 26, height: 26)
                    }
                    .position(
                        x: blockWidth - 12 - 13,
                        y: blockHeight - 12 - 13
                    )
                }
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
}
