//
//  FeaturedSectionView.swift
//  FFCI
//
//  Featured content section
//

import SwiftUI

struct FeaturedSectionView: View {
    let featured: [HomepageFeatured]
    let onFeaturedClick: (String) -> Void
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            ForEach(featured, id: \.uuid) { item in
                Group {
                    // Check externalUrl FIRST - external links should open in Safari
                    // If we checked uuid first, items with BOTH uuid AND externalUrl
                    // would incorrectly use NavigationLink instead of Link
                    if let externalUrl = item.externalUrl, let url = URL(string: externalUrl) {
                        Button {
                            let label = [item.title, item.description]
                                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .first { !$0.isEmpty }
                            MipAnalytics.logExternalLink(
                                url: url,
                                pageUuid: MipAnalytics.homePageUuid,
                                pageTitle: nil,
                                linkLabel: label,
                                linkSource: "featured"
                            )
                            openURL(url)
                        } label: {
                            FeaturedCard(featured: item)
                        }
                        .buttonStyle(.plain)
                    } else if let uuid = item.uuid, !uuid.isEmpty {
                        NavigationLink(destination: TabPageView(uuid: uuid)) {
                            FeaturedCard(featured: item)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            onFeaturedClick(uuid)
                        })
                        .buttonStyle(.plain)
                    } else {
                        FeaturedCard(featured: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
    }
}
