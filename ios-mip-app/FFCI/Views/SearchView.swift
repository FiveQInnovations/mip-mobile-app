//
//  SearchView.swift
//  FFCI
//
//  Search UI for content discovery
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "SearchView")

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    @State private var query = ""
    @State private var results: [SearchResult] = []
    @State private var isLoading = false
    @State private var hasSearched = false
    @State private var searchTask: Task<Void, Never>?
    
    private let minQueryLength = 3
    private let debounceDelay: UInt64 = 500_000_000
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                
                Divider()
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarHidden(true)
            .onAppear {
                isSearchFocused = true
            }
            .onDisappear {
                searchTask?.cancel()
            }
            .onChange(of: query) { _, newQuery in
                handleQueryChange(newQuery)
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(width: 44, height: 44)
            }
            .accessibilityIdentifier("search-back-button")
            .buttonStyle(.plain)
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search...", text: $query)
                    .focused($isSearchFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .accessibilityIdentifier("search-input")
                
                if !query.isEmpty {
                    Button(action: {
                        query = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var content: some View {
        if isLoading {
            SearchEmptyStateView(
                iconName: "magnifyingglass",
                title: "Searching...",
                subtitle: nil,
                showsProgress: true
            )
        } else if !results.isEmpty {
            resultsList
        } else if hasSearched {
            SearchEmptyStateView(
                iconName: "magnifyingglass",
                title: "No results found",
                subtitle: "Try a different search term",
                showsProgress: false
            )
        } else if !query.isEmpty {
            SearchEmptyStateView(
                iconName: "magnifyingglass",
                title: "Keep typing",
                subtitle: "Enter at least 3 characters",
                showsProgress: false
            )
        } else {
            SearchEmptyStateView(
                iconName: "magnifyingglass",
                title: "Start typing to search",
                subtitle: "Find pages and resources",
                showsProgress: false
            )
        }
    }
    
    private var resultsList: some View {
        List {
            ForEach(results, id: \.uuid) { result in
                NavigationLink(destination: TabPageView(uuid: result.uuid)) {
                    SearchResultRow(result: result)
                }
                .accessibilityIdentifier("search-result-row")
            }
        }
        .listStyle(.plain)
    }
    
    private func handleQueryChange(_ newQuery: String) {
        searchTask?.cancel()
        
        let trimmedQuery = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= minQueryLength else {
            results = []
            isLoading = false
            hasSearched = false
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: debounceDelay)
            guard !Task.isCancelled else { return }
            await performSearch(query: trimmedQuery)
        }
    }
    
    private func performSearch(query: String) async {
        if let cached = await SearchCache.shared.get(query: query) {
            await MainActor.run {
                results = cached
                isLoading = false
                hasSearched = true
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            hasSearched = true
        }
        
        do {
            let fetched = try await MipApiClient.shared.searchSite(query: query)
            guard !Task.isCancelled else { return }
            
            await SearchCache.shared.set(query: query, results: fetched)
            await MainActor.run {
                results = fetched
                isLoading = false
            }
        } catch is CancellationError {
            await MainActor.run {
                isLoading = false
            }
        } catch {
            logger.error("Search failed: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                results = []
                isLoading = false
                hasSearched = true
            }
        }
    }
}

private struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let description = result.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

private struct SearchEmptyStateView: View {
    let iconName: String
    let title: String
    let subtitle: String?
    let showsProgress: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if showsProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SearchView()
}
