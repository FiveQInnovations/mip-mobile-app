//
//  C4IMoreView.swift
//  C4I
//

import SwiftUI

struct C4IMoreView: View {
    let sections: [C4IMoreSection]

    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.items) { item in
                            row(for: item)
                        }
                    }
                }
            }
            .navigationTitle("More")
        }
    }
    
    @ViewBuilder
    private func row(for item: C4IMoreItem) -> some View {
        switch item.destination {
        case .page(let uuid):
            NavigationLink(destination: TabPageView(uuid: uuid)) {
                C4IMoreRow(item: item)
            }
        case .external(let urlString):
            Button {
                guard let url = URL(string: urlString) else { return }
                MipAnalytics.logExternalLink(
                    url: url,
                    pageUuid: MipAnalytics.homePageUuid,
                    pageTitle: nil,
                    linkLabel: item.title,
                    linkSource: "more"
                )
                openURL(url)
            } label: {
                C4IMoreRow(item: item)
            }
        }
    }
}

private struct C4IMoreRow: View {
    let item: C4IMoreItem
    
    var body: some View {
        Label(item.title, systemImage: item.systemImage)
            .foregroundColor(.primary)
    }
}
