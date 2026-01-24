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
    @State private var error: String?
    @State private var htmlContentHeight: CGFloat = 200
    
    var currentUuid: String {
        pageStack.isEmpty ? uuid : pageStack.last!
    }
    
    var canGoBack: Bool {
        !pageStack.isEmpty
    }
    
    var body: some View {
        NavigationStack {
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
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color("PrimaryColor"))
                                }
                            }
                        }
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
        isLoading = true
        error = nil
        htmlContentHeight = 200  // Reset to default before loading
        
        Task {
            do {
                let data = try await MipApiClient.shared.getPage(uuid: uuid)
                await MainActor.run {
                    self.pageData = data
                    self.isLoading = false
                    logger.notice("Page loaded: \(data.title), type: \(data.effectivePageType)")
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    logger.error("Failed to load page \(uuid): \(error.localizedDescription)")
                }
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

#Preview {
    TabPageView(uuid: "sample-uuid")
}
