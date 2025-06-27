//
//  WordDetailView.swift
//  shorthand words
//
//  Created by feng on 2024/12/19.
//

import SwiftUI
import AVFoundation

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

struct WordDetailView: View {
    let wordDetail: WordDetail
    let circleColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRectangleIndex: Int? = 0
    @StateObject private var wordDataManager = WordDataManager()
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var selectedWordDetail: WordDetail? = nil
    
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
                            Text(wordDetail.english)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(Color(hex: "ffffff"))
                        )
                        .onTapGesture {
                            speakText(wordDetail.english)
                        }
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
                            // 单词 - 距离上边缘40点
                            createHighlightedText(
                                text: (selectedWordDetail ?? wordDetail).english,
                                highlightRanges: getHighlightRanges(for: (selectedWordDetail ?? wordDetail).english),
                                fontSize: 50,
                                fontWeight: .semibold
                            )
                            .padding(.top, 40)
                            .onTapGesture {
                                speakText((selectedWordDetail ?? wordDetail).english)
                            }
                            
                            // 音标 - 紧贴单词
                            Text((selectedWordDetail ?? wordDetail).phonetic)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color(hex: "5D8DFD"))
                                .onTapGesture {
                                    speakText((selectedWordDetail ?? wordDetail).english)
                                }
                            
                            // 翻译 - 距离卡片上边缘145点
                            Text((selectedWordDetail ?? wordDetail).chinese)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "000000").opacity(1)) // 确保单词卡上的中文文字不透明
                                .padding(.top, 145 - 32 - 50 - 24)
                            
                            // 分割图标 - 距离卡片上边缘191点
                            Image("parting")
                                .resizable()
                                .frame(width: 24, height: 5)
                                .padding(.top, 191 - 145 - 18)
                            
                            // 词组及翻译 - 距离卡片上边缘220点
                            VStack(alignment: .center, spacing: 2) {
                                if let firstPhrase = (selectedWordDetail ?? wordDetail).phrases.first {
                                    Text(firstPhrase.english)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "000000").opacity(1)) // 确保词组英文文字不透明
                                        .onTapGesture {
                                            speakText(firstPhrase.english)
                                        }
                                    Text(firstPhrase.chinese)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "000000").opacity(1)) // 确保词组中文文字不透明
                                }
                            }
                            .padding(.top, 220 - 191 - 5)
                            
                            // 例句及翻译 - 距离卡片上边缘248点
                            VStack(alignment: .center, spacing: 2) {
                                if let firstExample = (selectedWordDetail ?? wordDetail).examples.first {
                                    Text(firstExample.english)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "000000").opacity(1)) // 确保例句英文文字不透明
                                        .onTapGesture {
                                            speakText(firstExample.english)
                                        }
                                    Text(firstExample.chinese)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "000000").opacity(1)) // 确保例句中文文字不透明
                                }
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
                    .opacity(0)
                    .frame(width: geometry.size.width - 24, height: 440) // 32点上空白 + 5行矩形高度(56*5=280) + 4行矩形间距(24*4=96) + 32点下空白 = 32+280+96+32 = 440
                    .padding(.top, 4)
                    .background(
                        // 最底层：sss图标作为背景
                        Image("sss")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width - 24, height: 440)
                    )
                    .overlay(
                        VStack(spacing: 0) {
                            if let mindMapData = wordDataManager.getMindMap(by: currentMindMapId) {
                                VStack(spacing: 0) {
                                    // 第一行：矩形1、箭头、矩形2、箭头、矩形3
                                    HStack(spacing: 2) {
                                        createMindMapRectangle(index: 0, word: mindMapData.words[safe: 0], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 1, word: mindMapData.words[safe: 1], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 2, word: mindMapData.words[safe: 2], customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第一行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第二行：矩形4、矩形5、矩形6
                                    HStack(spacing: 2) {
                                        createMindMapRectangle(index: 3, word: mindMapData.words[safe: 3], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 4, word: mindMapData.words[safe: 4], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 5, word: mindMapData.words[safe: 5], customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第二行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第三行：矩形7、箭头、矩形8、箭头、矩形9
                                    HStack(spacing: 2) {
                                        createMindMapRectangle(index: 6, word: mindMapData.words[safe: 6], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 7, word: mindMapData.words[safe: 7], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 8, word: mindMapData.words[safe: 8], customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第三行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第四行：矩形10、箭头、矩形11、箭头、矩形12
                                    HStack(spacing: 2) {
                                        createMindMapRectangle(index: 9, word: mindMapData.words[safe: 9], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 10, word: mindMapData.words[safe: 10], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 11, word: mindMapData.words[safe: 11], customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第四行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第五行：矩形13、箭头、矩形14、箭头、矩形15
                                    HStack(spacing: 2) {
                                        createMindMapRectangle(index: 12, word: mindMapData.words[safe: 12], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 13, word: mindMapData.words[safe: 13], customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createMindMapRectangle(index: 14, word: mindMapData.words[safe: 14], customColor: "#F8F8F8")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 32)
                                .padding(.bottom, 32)
                            } else {
                                // 如果没有数据，显示默认的15个空矩形
                                VStack(spacing: 0) {
                                    // 第一行：矩形1、箭头、矩形2、箭头、矩形3
                                    HStack(spacing: 2) {
                                        createDefaultRectangle(index: 0, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 1, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 2, customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第一行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第二行：矩形4、矩形5、矩形6
                                    HStack(spacing: 2) {
                                        createDefaultRectangle(index: 3, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 4, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 5, customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第二行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第三行：矩形7、箭头、矩形8、箭头、矩形9
                                    HStack(spacing: 2) {
                                        createDefaultRectangle(index: 6, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 7, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 8, customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第三行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第四行：矩形10、箭头、矩形11、箭头、矩形12
                                    HStack(spacing: 2) {
                                        createDefaultRectangle(index: 9, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 10, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 11, customColor: "#F8F8F8")
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第四行下方的向下箭头
                                    HStack(spacing: 2) {
                                        // 左列箭头 - 与第一个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 中列箭头 - 与第二个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                        
                                        // 水平箭头占位
                                        Spacer()
                                            .frame(width: 20)
                                        
                                        // 右列箭头 - 与第三个矩形对齐
                                        HStack {
                                            Spacer()
                                            Image("arrow")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Spacer()
                                        }
                                        .frame(width: 100) // 与矩形宽度一致
                                    }
                                    .padding(.bottom, 2)
                                    
                                    // 第五行：矩形13、箭头、矩形14、箭头、矩形15
                                    HStack(spacing: 2) {
                                        createDefaultRectangle(index: 12, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 13, customColor: "#F8F8F8")
                                        
                                        Image("arrow")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        createDefaultRectangle(index: 14, customColor: "#F8F8F8")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 32)
                                .padding(.bottom, 32)
                            }
                            }
                        )
                }
                .padding(.top, 4)
            }
        }
        .background(Color(hex: "f3f3f3"))
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }
    
    // MARK: - 辅助函数
    
    /// 创建思维图矩形（有数据时使用）
    private func createMindMapRectangle(index: Int, word: MindMapWord?, customColor: String) -> some View {
        let displayWord = word ?? MindMapWord(english: "word\(index + 1)", chinese: "单词\(index + 1)", backgroundColor: customColor)
        
        // 检查单词是否为空
        let isEmpty = displayWord.english.isEmpty
        let backgroundColor = isEmpty ? "ffffff" : customColor // 空单词使用白色背景
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: backgroundColor).opacity(0))
            .frame(height: 56)
            .overlay(
                ZStack {
                    // 选中图标
                    if selectedRectangleIndex == index && !isEmpty {
                        Image("choose")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                    // 文字内容
                    VStack(spacing: 2) {
                        // 第一行英文：字号16，字重semibold，支持高亮
                        if !isEmpty {
                            createHighlightedText(
                                text: displayWord.english,
                                highlightRanges: getHighlightRanges(for: displayWord.english),
                                fontSize: 16,
                                fontWeight: .semibold
                            )
                            .opacity(0)
                            .lineLimit(1)
                        } else {
                            Text("")
                                .font(.system(size: 16, weight: .semibold))
                                .lineLimit(1)
                        }
                        
                        // 第二行中文：字号12，字重medium，颜色黑色
                        Text(displayWord.chinese)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "000000").opacity(0))
                            .lineLimit(1)
                    }
                }
            )
            .onTapGesture {
                // 空单词不可选中
                if !isEmpty {
                    selectedRectangleIndex = index
                    speakText(displayWord.english)
                    // 根据点击的单词更新上方显示的单词数据
                    selectedWordDetail = wordDataManager.getWordDetail(for: displayWord.english)
                }
            }
    }
    
    /// 创建默认矩形（无数据时使用）
    private func createDefaultRectangle(index: Int, customColor: String) -> some View {
        let backgroundColor = Color.gray.opacity(0)
        let textColor = Color.black.opacity(0)
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)
            .frame(height: 56)
            .overlay(
                ZStack {
                    // 选中图标
                    if selectedRectangleIndex == index {
                        Image("choose")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                    // 文字内容
                    VStack(spacing: 2) {
                        // 第一行英文：字号16，字重semibold，颜色黑色
                        Text("word\(index + 1)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(textColor)
                            .lineLimit(1)
                        
                        // 第二行中文：字号12，字重medium，颜色黑色
                        Text("单词\(index + 1)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textColor)
                            .lineLimit(1)
                    }
                }
            )
            .onTapGesture {
                selectedRectangleIndex = index
                speakText("word\(index + 1)")
                // 默认矩形点击时不更新单词数据
            }
    }
    
    // MARK: - 高亮文本功能
    
    /// 获取指定单词的高亮范围
    private func getHighlightRanges(for word: String) -> [HighlightRange] {
        // 从WordDataManager获取高亮信息
        if let wordDetail = wordDataManager.getWordDetail(by: word),
           let highlight = wordDetail.highlight,
           let englishHighlights = highlight.english {
            return englishHighlights
        }
        return []
    }
    
    /// 创建高亮文本
    private func createHighlightedText(text: String, highlightRanges: [HighlightRange], fontSize: CGFloat, fontWeight: Font.Weight) -> some View {
        return HStack(spacing: 0) {
            ForEach(0..<text.count, id: \.self) { index in
                let character = String(text[text.index(text.startIndex, offsetBy: index)])
                let color = getColorForIndex(index, ranges: highlightRanges)
                
                Text(character)
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(color)
            }
        }
    }
    
    /// 获取指定索引位置的颜色
    private func getColorForIndex(_ index: Int, ranges: [HighlightRange]) -> Color {
        for range in ranges {
            if index >= range.start && index < range.end {
                switch range.color {
                case "red":
                    return Color.red
                case "blue":
                    return Color.blue
                case "green":
                    return Color.green
                case "orange":
                    return Color.orange
                case "purple":
                    return Color.purple
                default:
                    return Color.red
                }
            }
        }
        return Color.black.opacity(1) // 确保单词卡上的英文文字不透明
    }
    
    // MARK: - 朗读功能
    
    /// 朗读英文文本
    private func speakText(_ text: String) {
        // 停止当前朗读
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
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
        wordDetail: WordDetail(
              id: 1,
              english: "black",
              phonetic: "/blæk/",
              chinese: "黑色的",
              phrases: [],
              examples: [],
              highlight: nil
          ),
        circleColor: Color.black
    )
}
