//
//  WordDetailView.swift
//  shorthand words
//
//  Created by feng on 2024/12/19.
//

import SwiftUI

struct WordDetailView: View {
    let wordData: WordData
    let circleColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRectangleIndex: Int? = nil
    @StateObject private var mindMapManager = MindMapDataManager()
    
    // 当前显示的思维图ID（可以根据需要动态设置）
    private let currentMindMapId = 1
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                // 状态栏下方的导航区域
                HStack(spacing: 12) {
                    // 返回按钮
                    Button(action: {
                        dismiss()
                    }) {
                        Image("back")
                            .resizable()
                            .frame(width: 100, height: 84)
                    }
                    
                    // 圆角矩形背景
                    RoundedRectangle(cornerRadius: 28)
                        .fill(circleColor)
                        .frame(height: 84)
                        .overlay(
                            Text(wordData.mainWord)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "ffffff"))
                        )
                    
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                
                // 单词详情卡
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "ffffff"))
                    .frame(height: 356)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .overlay(
                        VStack(alignment: .center, spacing: 0) {
                            // 单词 - 距离上边缘32点
                            Text(wordData.mainWord)
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundColor(Color(hex: "000000"))
                                .padding(.top, 32)
                            
                            // 音标 - 紧贴单词
                            Text("/ˈeksəmpl/")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color(hex: "5D8DFD"))
                            
                            // 翻译 - 距离卡片上边缘145点
                            Text("示例；例子；榜样")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "000000"))
                                .padding(.top, 145 - 32 - 50 - 24)
                            
                            // 分割图标 - 距离卡片上边缘191点
                            Image("parting")
                                .resizable()
                                .frame(width: 24, height: 5)
                                .padding(.top, 191 - 145 - 18)
                            
                            // 词组及翻译 - 距离卡片上边缘220点
                            VStack(alignment: .center, spacing: 2) {
                                Text("for example")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "000000"))
                                Text("例如；比如")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "000000"))
                            }
                            .padding(.top, 220 - 191 - 5)
                            
                            // 例句及翻译 - 距离卡片上边缘248点
                            VStack(alignment: .center, spacing: 2) {
                                Text("This is a good example of teamwork.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "000000"))
                                Text("这是团队合作的一个好例子。")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "000000"))
                            }
                            .padding(.top, 248 - 220 - 14)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    )
                
                // 思维图标题
                HStack {
                    Text("思维图")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color(hex: "000000"))
                        .padding(.leading, 24)
                    Spacer()
                }
                .padding(.top, 40)
                
                // 思维图背景
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "ffffff"))
                    .frame(width: geometry.size.width - 24, height: 440) // 32点上空白 + 5行矩形高度(56*5=280) + 4行矩形间距(24*4=96) + 32点下空白 = 32+280+96+32 = 440
                    .padding(.top, 4)
                    .overlay(
                        VStack(spacing: 0) {
                            if let mindMapData = mindMapManager.getMindMap(by: currentMindMapId) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 24) {
                                    // 第一个矩形
                                    createMindMapRectangle(index: 0, word: mindMapData.words[safe: 0], customColor: "#F8F8F8")
                                    
                                    // 第二个矩形
                                    createMindMapRectangle(index: 1, word: mindMapData.words[safe: 1], customColor: "#F8F8F8")
                                    
                                    // 第三个矩形
                                    createMindMapRectangle(index: 2, word: mindMapData.words[safe: 2], customColor: "#F8F8F8")
                                    
                                    // 第四个矩形
                                    createMindMapRectangle(index: 3, word: mindMapData.words[safe: 3], customColor: "#F8F8F8")
                                    
                                    // 第五个矩形
                                    createMindMapRectangle(index: 4, word: mindMapData.words[safe: 4], customColor: "#F8F8F8")
                                    
                                    // 第六个矩形
                                    createMindMapRectangle(index: 5, word: mindMapData.words[safe: 5], customColor: "#F8F8F8")
                                    
                                    // 第七个矩形
                                    createMindMapRectangle(index: 6, word: mindMapData.words[safe: 6], customColor: "#F8F8F8")
                                    
                                    // 第八个矩形
                                    createMindMapRectangle(index: 7, word: mindMapData.words[safe: 7], customColor: "#F8F8F8")
                                    
                                    // 第九个矩形
                                    createMindMapRectangle(index: 8, word: mindMapData.words[safe: 8], customColor: "#F8F8F8")
                                    
                                    // 第十个矩形
                                    createMindMapRectangle(index: 9, word: mindMapData.words[safe: 9], customColor: "#F8F8F8")
                                    
                                    // 第十一个矩形
                                    createMindMapRectangle(index: 10, word: mindMapData.words[safe: 10], customColor: "#F8F8F8")
                                    
                                    // 第十二个矩形
                                    createMindMapRectangle(index: 11, word: mindMapData.words[safe: 11], customColor: "#F8F8F8")
                                    
                                    // 第十三个矩形
                                    createMindMapRectangle(index: 12, word: mindMapData.words[safe: 12], customColor: "#F8F8F8")
                                    
                                    // 第十四个矩形
                                    createMindMapRectangle(index: 13, word: mindMapData.words[safe: 13], customColor: "#F8F8F8")
                                    
                                    // 第十五个矩形
                                    createMindMapRectangle(index: 14, word: mindMapData.words[safe: 14], customColor: "#F8F8F8")
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 32)
                                .padding(.bottom, 32)
                            } else {
                                // 如果没有数据，显示默认的15个空矩形
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 24) {
                                    // 第一个矩形
                                    createDefaultRectangle(index: 0, customColor: "#F8F8F8")
                                    
                                    // 第二个矩形
                                    createDefaultRectangle(index: 1, customColor: "#F8F8F8")
                                    
                                    // 第三个矩形
                                    createDefaultRectangle(index: 2, customColor: "#F8F8F8")
                                    
                                    // 第四个矩形
                                    createDefaultRectangle(index: 3, customColor: "#F8F8F8")
                                    
                                    // 第五个矩形
                                    createDefaultRectangle(index: 4, customColor: "#F8F8F8")
                                    
                                    // 第六个矩形
                                    createDefaultRectangle(index: 5, customColor: "#F8F8F8")
                                    
                                    // 第七个矩形
                                    createDefaultRectangle(index: 6, customColor: "#F8F8F8")
                                    
                                    // 第八个矩形
                                    createDefaultRectangle(index: 7, customColor: "#F8F8F8")
                                    
                                    // 第九个矩形
                                    createDefaultRectangle(index: 8, customColor: "#F8F8F8")
                                    
                                    // 第十个矩形
                                    createDefaultRectangle(index: 9, customColor: "#F8F8F8")
                                    
                                    // 第十一个矩形
                                    createDefaultRectangle(index: 10, customColor: "#F8F8F8")
                                    
                                    // 第十二个矩形
                                    createDefaultRectangle(index: 11, customColor: "#F8F8F8")
                                    
                                    // 第十三个矩形
                                    createDefaultRectangle(index: 12, customColor: "#F8F8F8")
                                    
                                    // 第十四个矩形
                                    createDefaultRectangle(index: 13, customColor: "#F8F8F8")
                                    
                                    // 第十五个矩形
                                    createDefaultRectangle(index: 14, customColor: "#F8F8F8")
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 32)
                                .padding(.bottom, 32)
                            }
                        }
                    )
                
                }
            }
        }
        .background(Color(hex: "f3f3f3"))
        .navigationBarHidden(true)
    }
    
    // MARK: - 辅助函数
    
    /// 创建思维图矩形（有数据时使用）
    private func createMindMapRectangle(index: Int, word: MindMapWord?, customColor: String) -> some View {
        let displayWord = word ?? MindMapWord(english: "word\(index + 1)", chinese: "单词\(index + 1)", backgroundColor: customColor)
        let backgroundColor = customColor // 使用自定义颜色覆盖JSON中的颜色
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: backgroundColor))
            .frame(height: 56)
            .overlay(
                VStack(spacing: 2) {
                    // 第一行英文：字号16，字重semibold，颜色黑色
                    Text(displayWord.english)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "000000"))
                        .lineLimit(1)
                    
                    // 第二行中文：字号12，字重medium，颜色黑色
                    Text(displayWord.chinese)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "000000"))
                        .lineLimit(1)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "9400D8"), lineWidth: selectedRectangleIndex == index ? 1 : 0)
            )
            .onTapGesture {
                selectedRectangleIndex = index
            }
    }
    
    /// 创建默认矩形（无数据时使用）
    private func createDefaultRectangle(index: Int, customColor: String) -> some View {
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: customColor))
            .frame(height: 56)
            .overlay(
                VStack(spacing: 2) {
                    // 第一行英文：字号16，字重semibold，颜色黑色
                    Text("word\(index + 1)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "000000"))
                        .lineLimit(1)
                    
                    // 第二行中文：字号12，字重medium，颜色黑色
                    Text("单词\(index + 1)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "000000"))
                        .lineLimit(1)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "9400D8"), lineWidth: selectedRectangleIndex == index ? 1 : 0)
            )
            .onTapGesture {
                selectedRectangleIndex = index
            }
    }
}

// MARK: - Array 扩展

/// Array 安全访问扩展
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    WordDetailView(
        wordData: WordData(
            mainWord: "black",
            translation: "黑色的",
            relatedWord1: "dark",
            relatedWord2: "night"
        ),
        circleColor: Color.black
    )
}
