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
    
    var body: some View {
        GeometryReader { geometry in
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
                
                Spacer()
            }
        }
        .background(Color(hex: "f3f3f3"))
        .navigationBarHidden(true)
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