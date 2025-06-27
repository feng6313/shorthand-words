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
    
    // 支持的数据组列表 - 动态从云端获取
    @State private var dataGroups: [String] = []
    
    // 每个数据组的数据管理器
    @State private var dataManagers: [String: WordDataManager] = [:]
    @State private var isLoading = true
    @State private var loadError: String? = nil
    @State private var cloudDataManager = CloudDataManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                if isLoading {
                    // 加载状态
                    VStack {
                        Spacer()
                        ProgressView("正在加载数据...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else if let error = loadError {
                    // 错误状态
                    VStack {
                        Spacer()
                        Text("加载失败: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("重试") {
                            refreshAllData()
                        }
                        .padding(.top, 8)
                        .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                } else {
                    // 正常内容 - 显示数据组
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(Array(dataGroups.enumerated()), id: \.offset) { index, groupId in
                                if let dataManager = dataManagers[groupId],
                                   let firstWordDetail = dataManager.getFirstWordDetail() {
                                    NavigationLink(destination: WordDetailView(wordDetail: firstWordDetail, circleColor: Color(hex: circleColors[index % circleColors.count]))) {
                                        VStack {
                                            // 数据组标题
                                            Text(groupId)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.gray)
                                                .padding(.bottom, 4)
                                            
                                            WordBlockView(
                                                wordDetail: firstWordDetail,
                                                circleColor: Color(hex: circleColors[index % circleColors.count]),
                                                blockNumber: index + 1,
                                                wordCount: dataManager.allWordsCount,
                                                homePageWords: dataManager.getHomePageWords().map { $0.english }
                                            )
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // 数据组加载失败或无数据的占位符
                                    VStack {
                                        Text(groupId)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 4)
                                        
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 200)
                                            .overlay(
                                                VStack {
                                                    Image(systemName: "exclamationmark.triangle")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(.gray)
                                                    Text("数据加载失败")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.gray)
                                                }
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .refreshable {
                        await refreshAllDataAsync()
                    }
                }
            }
            .background(Color(hex: "f3f3f3"))
            .navigationTitle("速记1600词")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadAllData()
        }
    }
    
    // MARK: - 私有方法
    
    private func loadAllData() {
        isLoading = true
        loadError = nil
        
        // 首先获取可用的数据组列表
        Task {
            let availableGroups = await cloudDataManager.getAvailableDataGroups()
            
            await MainActor.run {
                self.dataGroups = availableGroups
                
                // 初始化所有数据管理器
                for groupId in availableGroups {
                    let dataManager = WordDataManager()
                    dataManager.setCurrentGroup(groupId)
                    dataManagers[groupId] = dataManager
                }
                
                // 监听所有数据管理器的状态变化
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateAllLoadingStates()
                }
            }
        }
    }
    
    private func updateAllLoadingStates() {
        let allLoaded = dataManagers.values.allSatisfy { !$0.isLoading }
        
        if allLoaded {
            // 所有数据组加载完成
            isLoading = false
            
            // 检查是否有错误
            let errors = dataManagers.compactMap { (groupId, manager) in
                manager.errorMessage != nil ? "\(groupId): \(manager.errorMessage!)" : nil
            }
            
            if !errors.isEmpty {
                loadError = "部分数据组加载失败:\n\(errors.joined(separator: "\n"))"
            } else {
                loadError = nil
            }
        } else {
            // 仍有数据组在加载中，继续检查
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateAllLoadingStates()
            }
        }
    }
    
    private func refreshAllData() {
        isLoading = true
        loadError = nil
        
        // 刷新所有数据管理器
        for (_, dataManager) in dataManagers {
            dataManager.refreshData()
        }
        
        // 监听加载状态变化
        updateAllLoadingStates()
    }
    
    // 异步刷新方法，用于下拉刷新
    private func refreshAllDataAsync() async {
        await MainActor.run {
            isLoading = true
            loadError = nil
        }
        
        // 刷新所有数据管理器
        await MainActor.run {
            for (_, dataManager) in dataManagers {
                dataManager.refreshData()
            }
        }
        
        // 等待加载完成
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            func checkLoadingState() {
                Task { @MainActor in
                    let allLoaded = dataManagers.values.allSatisfy { !$0.isLoading }
                    
                    if allLoaded {
                        // 所有数据组加载完成
                        isLoading = false
                        
                        // 检查是否有错误
                        let errors = dataManagers.compactMap { (groupId, manager) in
                            manager.errorMessage != nil ? "\(groupId): \(manager.errorMessage!)" : nil
                        }
                        
                        if !errors.isEmpty {
                            loadError = "部分数据组加载失败:\n\(errors.joined(separator: "\n"))"
                        } else {
                            loadError = nil
                        }
                        
                        continuation.resume()
                    } else {
                        // 仍有数据组在加载中，继续检查
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            checkLoadingState()
                        }
                    }
                }
            }
            
            checkLoadingState()
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
