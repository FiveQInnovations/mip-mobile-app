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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            ForEach(featured, id: \.uuid) { item in
                Group {
                    if let uuid = item.uuid, !uuid.isEmpty {
                        NavigationLink(destination: TabPageView(uuid: uuid)) {
                            FeaturedCard(featured: item)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            onFeaturedClick(uuid)
                        })
                        .buttonStyle(.plain)
                    } else if let externalUrl = item.externalUrl, let url = URL(string: externalUrl) {
                        Link(destination: url) {
                            FeaturedCard(featured: item)
                        }
                        .buttonStyle(.plain)
                    } else {
                        FeaturedCard(featured: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
            }
        }
    }
}
