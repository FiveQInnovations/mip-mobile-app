//
//  TabPageView.swift
//  FFCI
//
//  Tab page view with navigation stack for drilling into collections
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "TabPageView")
private let categoryPreviewCount = 3

struct TabPageView: View {
    let uuid: String
    @State private var pageStack: [String] = []
    @State private var pageData: PageData?
    @State private var isLoading = true
    @State private var isRefreshing = false
    @State private var error: String?
    @State private var htmlContentHeight: CGFloat = 200
    @State private var loadTask: Task<Void, Never>?
    @State private var mediaSectionsTask: Task<Void, Never>?
    @State private var mediaSections: [MediaCategorySection] = []
    @State private var isLoadingMediaSections = false
    @State private var expandedCategorySlugs: Set<String> = []
    
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
                                    .padding(.top, 2)
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
                                    let shouldGroup = shouldGroupMediaByCategory(pageData)
                                    
                                    if shouldGroup && !mediaSections.isEmpty {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Categories")
                                                .font(.title3.weight(.semibold))
                                                .padding(.horizontal, 16)
                                                .accessibilityIdentifier("media-categories-title")
                                            
                                            ForEach(mediaSections) { section in
                                                let isExpanded = expandedCategorySlugs.contains(section.category.slug)
                                                let visibleItems = isExpanded
                                                    ? section.items
                                                    : Array(section.items.prefix(categoryPreviewCount))
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    HStack(alignment: .firstTextBaseline) {
                                                        Text(section.category.name)
                                                            .font(.headline.weight(.semibold))
                                                            .foregroundColor(Color("BrandPrimaryColor"))
                                                        Spacer()
                                                        Text("\(section.items.count) \(section.items.count == 1 ? "message" : "messages")")
                                                            .font(.caption.weight(.semibold))
                                                            .foregroundColor(Color("BrandPrimaryColor"))
                                                    }
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 10)
                                                    .background(Color("BrandPrimaryColor").opacity(0.14))
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .accessibilityIdentifier("media-category-header-\(section.category.slug)")
                                                    
                                                    CollectionListView(
                                                        items: visibleItems,
                                                        onItemClick: { childUuid in
                                                            navigateToPage(uuid: childUuid)
                                                        }
                                                    )
                                                    .padding(.leading, 12)
                                                    
                                                    if section.items.count > categoryPreviewCount {
                                                        Button(action: {
                                                            if isExpanded {
                                                                expandedCategorySlugs.remove(section.category.slug)
                                                            } else {
                                                                expandedCategorySlugs.insert(section.category.slug)
                                                            }
                                                        }) {
                                                            Text(isExpanded ? "Show less" : "Show all")
                                                                .font(.subheadline.weight(.semibold))
                                                                .foregroundColor(Color("BrandPrimaryColor"))
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                        .padding(.leading, 26)
                                                        .padding(.top, 2)
                                                        .accessibilityIdentifier("media-category-toggle-\(section.category.slug)")
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                    } else {
                                        if shouldGroup && isLoadingMediaSections {
                                            ProgressView()
                                                .frame(maxWidth: .infinity)
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 8)
                                        }
                                        
                                        CollectionListView(
                                            items: children,
                                            onItemClick: { childUuid in
                                                navigateToPage(uuid: childUuid)
                                            }
                                        )
                                    }
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
                                        .foregroundColor(Color("BrandPrimaryColor"))
                                    }
                                    .accessibilityIdentifier("page-back-button")
                                }
                            }
                        }
                        .navigationBarBackButtonHidden(canGoBack)
                    }
                }
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
        mediaSectionsTask?.cancel()
        error = nil
        htmlContentHeight = 200  // Reset to default before loading
        isRefreshing = false
        mediaSections = []
        isLoadingMediaSections = false
        expandedCategorySlugs = []
        
        loadTask = Task {
            let cached = await PageCache.shared.getAnyCache(uuid)
            let hasCache = cached != nil
            let isStale = await PageCache.shared.isExpired(uuid)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                if let cached = cached {
                    self.pageData = cached
                    self.isLoading = false
                    refreshMediaSections(for: cached)
                } else {
                    self.pageData = nil
                    self.isLoading = true
                    refreshMediaSections(for: nil)
                }
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
                await MainActor.run {
                    self.pageData = data
                    self.isLoading = false
                    self.isRefreshing = false
                    refreshMediaSections(for: data)
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
                        refreshMediaSections(for: nil)
                        logger.error("Failed to load page \(uuid): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func refreshMediaSections(for pageData: PageData?) {
        mediaSectionsTask?.cancel()
        
        guard let pageData, shouldGroupMediaByCategory(pageData) else {
            mediaSections = []
            isLoadingMediaSections = false
            expandedCategorySlugs = []
            return
        }
        
        isLoadingMediaSections = true
        expandedCategorySlugs = []
        
        mediaSectionsTask = Task {
            let sections = await buildMediaCategorySections(collectionPage: pageData)
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                mediaSections = sections
                isLoadingMediaSections = false
            }
        }
    }
    
    private func navigateToPage(uuid: String) {
        logger.notice("Navigating to page: \(uuid)")
        pageStack.append(uuid)
    }
    
    private func goBack() {
        if !pageStack.isEmpty {
            pageStack.removeLast()
        }
    }
}

private struct MediaCategorySection: Identifiable {
    let category: CategoryDefinition
    let items: [CollectionChild]
    
    var id: String {
        category.slug
    }
}

private func shouldGroupMediaByCategory(_ pageData: PageData) -> Bool {
    pageData.effectivePageType == "collection" &&
    pageData.type == "audio" &&
    !pageData.categoryDefinitions.isEmpty &&
    !(pageData.children ?? []).isEmpty
}

private func normalizeCategorySlug(_ slug: String?) -> String? {
    guard let slug else { return nil }
    let trimmed = slug.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed.lowercased()
}

private func buildMediaCategorySections(collectionPage: PageData) async -> [MediaCategorySection] {
    let categories = collectionPage.categoryDefinitions
    let children = collectionPage.children ?? []
    
    guard !categories.isEmpty, !children.isEmpty else { return [] }
    
    var categoryByChildUuid = Dictionary(
        uniqueKeysWithValues: children.map { ($0.uuid, normalizeCategorySlug($0.categorySlug)) }
    )
    
    let missingCategoryChildren = children.filter { child in
        categoryByChildUuid[child.uuid] == nil
    }
    
    if !missingCategoryChildren.isEmpty {
        await withTaskGroup(of: (String, String?).self) { group in
            for child in missingCategoryChildren {
                group.addTask {
                    if Task.isCancelled {
                        return (child.uuid, nil)
                    }
                    
                    if let cachedChildPage = await PageCache.shared.getAnyCache(child.uuid) {
                        return (child.uuid, normalizeCategorySlug(cachedChildPage.categorySlug))
                    }
                    
                    do {
                        let childPage = try await MipApiClient.shared.getPage(uuid: child.uuid)
                        await PageCache.shared.put(child.uuid, data: childPage)
                        return (child.uuid, normalizeCategorySlug(childPage.categorySlug))
                    } catch {
                        logger.error("Failed to fetch media child category slug for \(child.uuid): \(error.localizedDescription)")
                        return (child.uuid, nil)
                    }
                }
            }
            
            for await (childUuid, categorySlug) in group {
                if let categorySlug {
                    categoryByChildUuid[childUuid] = categorySlug
                }
            }
        }
    }
    
    let sections = categories.compactMap { category -> MediaCategorySection? in
        let slug = normalizeCategorySlug(category.slug)
        let categoryItems = children.filter { child in
            categoryByChildUuid[child.uuid] == slug
        }
        
        guard !categoryItems.isEmpty else { return nil }
        return MediaCategorySection(category: category, items: categoryItems)
    }
    
    let categorizedIds = Set(sections.flatMap { section in
        section.items.map(\.uuid)
    })
    let uncategorizedItems = children.filter { !categorizedIds.contains($0.uuid) }
    
    guard !uncategorizedItems.isEmpty else { return sections }
    
    return sections + [
        MediaCategorySection(
            category: CategoryDefinition(
                name: "Other Messages",
                slug: "other",
                description: nil,
                count: nil
            ),
            items: uncategorizedItems
        )
    ]
}

#Preview {
    TabPageView(uuid: "sample-uuid")
}
