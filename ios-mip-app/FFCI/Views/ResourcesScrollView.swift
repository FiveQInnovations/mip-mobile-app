//
//  ResourcesScrollView.swift
//  FFCI
//
//  Resources section with horizontal scrolling and arrow controls
//

import SwiftUI

struct ResourcesScrollView: View {
    let quickTasks: [HomepageQuickTask]
    let onQuickTaskClick: (String) -> Void
    @ObservedObject var scrollTracker: ScrollTracker
    
    private let cardSpacing: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            ScrollViewReader { scrollProxy in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: cardSpacing) {
                            ForEach(Array(quickTasks.enumerated()), id: \.element.uuid) { index, task in
                                Group {
                                    if let uuid = task.uuid, !uuid.isEmpty {
                                        NavigationLink(destination: TabPageView(uuid: uuid)) {
                                            ResourcesCard(task: task)
                                        }
                                        .simultaneousGesture(TapGesture().onEnded {
                                            onQuickTaskClick(uuid)
                                        })
                                        .buttonStyle(.plain)
                                    } else if let externalUrl = task.externalUrl, let url = URL(string: externalUrl) {
                                        Link(destination: url) {
                                            ResourcesCard(task: task)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        ResourcesCard(task: task)
                                    }
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ContentWidthPreferenceKey.self, value: geo.size.width)
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: -geo.frame(in: .named("resourcesScroll")).minX)
                            }
                        )
                    }
                    .coordinateSpace(name: "resourcesScroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollTracker.updateScrollOffset(value)
                    }
                    .onPreferenceChange(ContentWidthPreferenceKey.self) { value in
                        scrollTracker.contentWidth = value
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                scrollTracker.containerWidth = geo.size.width
                            }
                        }
                    )
                    
                    // Left scroll arrow
                    if scrollTracker.canScrollLeft {
                        HStack {
                            ScrollArrowButton(direction: .left) {
                                let targetIndex = max(0, scrollTracker.visibleIndex - 1)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollProxy.scrollTo(targetIndex, anchor: .leading)
                                }
                            }
                            .padding(.leading, 8)
                            Spacer()
                        }
                    }
                    
                    // Right scroll arrow
                    if scrollTracker.canScrollRight {
                        HStack {
                            Spacer()
                            ScrollArrowButton(direction: .right) {
                                let targetIndex = min(quickTasks.count - 1, scrollTracker.visibleIndex + 1)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollProxy.scrollTo(targetIndex, anchor: .leading)
                                }
                            }
                            .padding(.trailing, 8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color(red: 0.945, green: 0.961, blue: 0.976))
    }
}
