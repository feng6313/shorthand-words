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
    @State private var allDataGroups: [String] = []
    @State private var displayedDataGroups: [String] = []
    
    // 每个数据组的数据管理器
    @State private var dataManagers: [String: WordDataManager] = [:]
    @State private var isLoading = true
    @State private var isLoadingMore = false
    @State private var loadError: String? = nil
    @State private var cloudDataManager = CloudDataManager()
    
    // 分页参数
    private let itemsPerPage = 10
    private var hasMoreItems: Bool {
        displayedDataGroups.count < allDataGroups.count
    }
    
    // 加载更多数据
    private func loadMoreItems() {
        guard !isLoadingMore && hasMoreItems else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let currentCount = displayedDataGroups.count
            let nextBatch = Array(allDataGroups.dropFirst(currentCount).prefix(itemsPerPage))
            
            // 初始化新的数据管理器
            for groupId in nextBatch {
                let dataManager = WordDataManager()
                dataManager.setCurrentGroup(groupId)
                dataManagers[groupId] = dataManager
            }
            
            // 添加到显示列表
            displayedDataGroups.append(contentsOf: nextBatch)
            
            // 更新加载状态
            updateAllLoadingStates()
            
            isLoadingMore = false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                if isLoading {
                    // 加载状态 - 使用iOS默认的转圈加载图标
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .background(Color.clear)
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
                            ForEach(Array(displayedDataGroups.enumerated()), id: \.offset) { index, groupId in
                                if let dataManager = dataManagers[groupId],
                                   let firstWordDetail = dataManager.getFirstWordDetail() {
                                    NavigationLink(destination: WordDetailView(wordDetail: firstWordDetail, circleColor: Color(hex: circleColors[index % circleColors.count]), wordDataManager: dataManager)) {
                                        WordBlockView(
                                            wordDetail: firstWordDetail,
                                            circleColor: Color(hex: circleColors[index % circleColors.count]),
                                            blockNumber: index + 1,
                                            wordCount: dataManager.allWordsCount,
                                            homePageWords: dataManager.getHomePageWords().map { $0.english },
                                            coreWordChinese: dataManager.getCoreWordChinese()
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // 数据组加载失败或无数据的占位符
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
                            
                            // 加载更多指示器
                            if hasMoreItems {
                                HStack {
                                    Spacer()
                                    if isLoadingMore {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(0.8)
                                        Text("加载中...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .padding(.leading, 8)
                                    } else {
                                        Button("加载更多") {
                                            loadMoreItems()
                                        }
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                                .onAppear {
                                    // 自动加载更多
                                    if !isLoadingMore {
                                        loadMoreItems()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }
            .background(isLoading ? Color.clear : Color(hex: "f3f3f3"))
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
                self.allDataGroups = availableGroups
                // 初始加载前10个
                self.displayedDataGroups = Array(availableGroups.prefix(itemsPerPage))
                
                // 初始化显示的数据管理器
                for groupId in displayedDataGroups {
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
        // 只检查当前显示的数据组
        let displayedManagers = displayedDataGroups.compactMap { dataManagers[$0] }
        let allLoaded = displayedManagers.allSatisfy { !$0.isLoading }
        
        if allLoaded {
            // 当前显示的数据组加载完成
            isLoading = false
            
            // 检查是否有错误
            let errors = displayedManagers.compactMap { manager in
                manager.errorMessage != nil ? manager.errorMessage! : nil
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
    

    
    }

// Color扩展已在WordDetailView中定义

// 单词块视图组件
struct WordBlockView: View {
    let wordDetail: WordDetail
    let circleColor: Color
    let blockNumber: Int
    let wordCount: Int
    let homePageWords: [String]
    let coreWordChinese: String
    @State private var isCollected: Bool = false
    
    // 收藏状态持久化的key - 使用blockNumber确保唯一性
    private var collectionKey: String {
        "collected_\(blockNumber)_\(wordDetail.id)"
    }
    
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
                                Text(homePageWords.count > 0 ? homePageWords[0] : wordDetail.english)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(coreWordChinese)
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
                            // 保存收藏状态到UserDefaults
                            UserDefaults.standard.set(isCollected, forKey: collectionKey)
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
        }
        .aspectRatio(0.75, contentMode: .fit)
        .onAppear {
            // 从UserDefaults加载收藏状态
            isCollected = UserDefaults.standard.bool(forKey: collectionKey)
        }
    }
}

#Preview {
    ContentView()
}
