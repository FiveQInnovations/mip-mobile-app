//
//  TabPageView.swift
//  FFCI
//
//  Tab page view with navigation stack for drilling into collections
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "TabPageView")

struct TabPageView: View {
    let uuid: String
    @State private var pageStack: [String] = []
    @State private var pageData: PageData?
    @State private var isLoading = true
    @State private var isRefreshing = false
    @State private var error: String?
    @State private var htmlContentHeight: CGFloat = 200
    @State private var cacheStatus: CacheStatus = .miss
    @State private var loadTask: Task<Void, Never>?
    @State private var cacheSize = 0
    @State private var lastNavigation = ""
    
    var currentUuid: String {
        pageStack.isEmpty ? uuid : pageStack.last!
    }
    
    var canGoBack: Bool {
        pageStack.count > 1
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if isLoading {
                        LoadingView()
                    } else if let error = error {
                        ErrorView(message: error) {
                            loadPage(uuid: currentUuid)
                        }
                    } else if let pageData = pageData {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Title
                                Text(pageData.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 24)
                                
                                // HTML content
                                if let htmlContent = pageData.htmlContent, !htmlContent.isEmpty {
                                    HtmlContentView(
                                        html: htmlContent,
                                        onNavigate: { childUuid in
                                            navigateToPage(uuid: childUuid)
                                        },
                                        contentHeight: $htmlContentHeight
                                    )
                                    .frame(height: htmlContentHeight)
                                    .padding(.horizontal, 0)
                                    .padding(.bottom, 8)
                                }
                                
                                // Audio player for audio items
                                if pageData.isAudioItem, let audioUrl = pageData.audioUrl {
                                    AudioPlayerView(
                                        url: audioUrl,
                                        title: pageData.audioTitle,
                                        artist: pageData.audioArtist
                                    )
                                    .padding(.horizontal, 16)
                                }
                                
                                // Collection children
                                if pageData.effectivePageType == "collection",
                                   let children = pageData.children, !children.isEmpty {
                                    CollectionListView(
                                        items: children,
                                        onItemClick: { childUuid in
                                            navigateToPage(uuid: childUuid)
                                        }
                                    )
                                }
                                
                                Spacer(minLength: 32)
                            }
                        }
                        .navigationTitle(pageData.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            if canGoBack {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: goBack) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "chevron.left")
                                            Text("Back")
                                        }
                                        .foregroundColor(Color("PrimaryColor"))
                                    }
                                    .accessibilityIdentifier("page-back-button")
                                }
                            }
                        }
                        .navigationBarBackButtonHidden(canGoBack)
                    }
                }
                
                #if DEBUG
                cacheStatusIndicator
                #endif
            }
            .task {
                if pageStack.isEmpty {
                    pageStack = [uuid]
                }
                loadPage(uuid: currentUuid)
            }
            .onChange(of: currentUuid) { oldValue, newValue in
                if oldValue != newValue {
                    loadPage(uuid: newValue)
                }
            }
        }
    }
    
    private func loadPage(uuid: String) {
        loadTask?.cancel()
        error = nil
        htmlContentHeight = 200  // Reset to default before loading
        isRefreshing = false
        cacheStatus = .miss
        
        loadTask = Task {
            let cached = await PageCache.shared.getAnyCache(uuid)
            let hasCache = cached != nil
            let isStale = await PageCache.shared.isExpired(uuid)
            let currentCacheSize = await PageCache.shared.size()
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                if let cached = cached {
                    self.pageData = cached
                    self.isLoading = false
                    self.cacheStatus = .hit
                } else {
                    self.pageData = nil
                    self.isLoading = true
                    self.cacheStatus = .miss
                }
                self.cacheSize = currentCacheSize
            }
            
            guard !hasCache || isStale else { return }
            
            await MainActor.run {
                if hasCache {
                    self.isRefreshing = true
                }
            }
            
            do {
                let data = try await MipApiClient.shared.getPage(uuid: uuid)
                guard !Task.isCancelled else { return }
                await PageCache.shared.put(uuid, data: data)
                let updatedCacheSize = await PageCache.shared.size()
                await MainActor.run {
                    self.pageData = data
                    self.isLoading = false
                    self.isRefreshing = false
                    self.cacheStatus = hasCache ? .hit : .miss
                    self.cacheSize = updatedCacheSize
                    logger.notice("Page loaded: \(data.title), type: \(data.effectivePageType)")
                    logger.notice("Audio check - isAudioItem: \(data.isAudioItem), audioUrl: \(data.audioUrl ?? "nil")")
                }
            } catch is CancellationError {
                await MainActor.run {
                    if hasCache {
                        self.isRefreshing = false
                    } else {
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    if hasCache {
                        self.isRefreshing = false
                        logger.error("Background refresh failed: \(error.localizedDescription)")
                    } else {
                        self.error = error.localizedDescription
                        self.isLoading = false
                        logger.error("Failed to load page \(uuid): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func navigateToPage(uuid: String) {
        logger.notice("Navigating to page: \(uuid)")
        lastNavigation = uuid
        pageStack.append(uuid)
    }
    
    private func goBack() {
        if !pageStack.isEmpty {
            pageStack.removeLast()
        }
    }
}

private enum CacheStatus {
    case hit
    case miss
    
    var label: String {
        switch self {
        case .hit:
            return "cache-hit"
        case .miss:
            return "cache-miss"
        }
    }
    
    var identifier: String {
        switch self {
        case .hit:
            return "page-cache-hit"
        case .miss:
            return "page-cache-miss"
        }
    }
}

#if DEBUG
private extension TabPageView {
    var cacheStatusIndicator: some View {
        Text("\(cacheStatus.label) (\(cacheSize)) s\(pageStack.count) \(currentUuid.prefix(6)) \(lastNavigation.prefix(6))")
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(6)
            .background(Color(.systemBackground).opacity(0.6))
            .cornerRadius(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(8)
            .accessibilityIdentifier(cacheStatus.identifier)
    }
}
#endif

#Preview {
    TabPageView(uuid: "sample-uuid")
}
