//
//  ContentView.swift
//  shorthand words
//
//  Created by feng on 2025/6/25.
//

import SwiftUI

// 使用WordDataManager中的数据结构
// 这里不再重复定义，直接使用WordDataManager中的WordDetail等结构

struct ContentView: View {
    // 预定义颜色数组
    let circleColors = [
        "000000", "2B00FF", "9900FF", "D69A00",
        "56AA53", "0174BB", "95006F", "D95700",
        "93A63E", "1CA299", "4D0095", "D6067F",
        "0E6B19", "967439", "4A90E2", "8E44AD"
    ]
    
    // 数据管理器
    @StateObject private var dataManager = WordDataManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    if let firstWordDetail = dataManager.getFirstWordDetail() {
                        NavigationLink(destination: WordDetailView(wordDetail: firstWordDetail, circleColor: Color(hex: circleColors[0]))) {
                            WordBlockView(
                                wordDetail: firstWordDetail,
                                circleColor: Color(hex: circleColors[0]),
                                blockNumber: 1,
                                wordCount: dataManager.allWordsCount,
                                homePageWords: dataManager.getHomePageWords().map { $0.english }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color(hex: "f3f3f3"))
            .navigationTitle("速记1600词")
        }
    }
}

// Color扩展已在WordDetailView中定义

// 单词块视图组件
struct WordBlockView: View {
    let wordDetail: WordDetail
    let circleColor: Color
    let blockNumber: Int
    let wordCount: Int
    let homePageWords: [String]
    @State private var isCollected: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let blockWidth = geometry.size.width
            let blockHeight = blockWidth / 0.75
            
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
                                Text(wordDetail.english)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(wordDetail.chinese)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                                .position(
                                    x: blockWidth / 2,
                                    y: 20 + (blockWidth * 0.6) / 2
                                )
                            )
                        
                        // 第二个圆 - home_page_words第二个单词
                        Circle()
                            .fill(Color(hex: "EBEBEB"))
                            .frame(width: blockWidth * 0.3, height: blockWidth * 0.3)
                            .position(
                                x: 12 + (blockWidth * 0.3) / 2,
                                y: 124 + (blockWidth * 0.3) / 2
                            )
                            .overlay(
                                Text(homePageWords.count > 1 ? homePageWords[1] : "about")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(circleColor)
                                    .position(
                                        x: 12 + (blockWidth * 0.3) / 2,
                                        y: 124 + (blockWidth * 0.3) / 2
                                    )
                            )
                        
                        // 第三个圆 - home_page_words第三个单词
                        Circle()
                            .fill(circleColor)
                            .frame(width: blockWidth * 0.18, height: blockWidth * 0.18)
                            .position(
                                x: blockWidth - 24 - (blockWidth * 0.18) / 2,
                                y: 124 + (blockWidth * 0.18) / 2
                            )
                            .overlay(
                                Text(homePageWords.count > 2 ? homePageWords[2] : "sprout")
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
                                Text(String(format: "%03d", blockNumber))
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
                                Text("\(wordCount)")
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
        .aspectRatio(0.75, contentMode: .fit)
    }
}

#Preview {
    ContentView()
}
