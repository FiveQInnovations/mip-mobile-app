import SwiftUI

private let rohInk = Color(red: 0.03, green: 0.20, blue: 0.22)
private let rohTeal = Color(red: 0.06, green: 0.54, blue: 0.61)
private let rohCream = Color(red: 0.98, green: 0.97, blue: 0.94)

struct ROHRootView: View {
    var body: some View {
        TabView {
            NavigationStack { ROHHomeView() }
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { ROHShowsView() }
                .tabItem { Label("Shows", systemImage: "square.grid.2x2") }

            NavigationStack { ROHSearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack { ROHMoreView() }
                .tabItem { Label("More", systemImage: "ellipsis") }
        }
        .tint(rohTeal)
    }
}

private struct ROHHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ROHHeader(tagline: "LISTEN. READ. GROW.")

                VStack(alignment: .leading, spacing: 18) {
                    Text("WITH NANCY DEMOSS WOLGEMUTH")
                        .font(.caption2.weight(.bold))
                        .tracking(1.6)
                        .foregroundStyle(rohTeal)

                    Text("Helping women embrace God’s truth for grace-filled living.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    NavigationLink(value: ROHContent.episodes[0]) {
                        ROHFeaturedEpisode(episode: ROHContent.episodes[0])
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(rohInk)

                VStack(alignment: .leading, spacing: 18) {
                    ROHSectionTitle(title: "Explore shows", action: "View all")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ROHContent.shows) { show in
                                NavigationLink(value: show) {
                                    ROHShowCard(show: show, width: 138)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Text("Latest episodes")
                        .font(.system(size: 25, weight: .bold, design: .serif))
                        .foregroundStyle(rohInk)

                    ForEach(ROHContent.episodes.dropFirst()) { episode in
                        NavigationLink(value: episode) {
                            ROHEpisodeRow(episode: episode)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .background(rohCream)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: ROHEpisode.self) { episode in
            ROHEpisodeDetailView(episode: episode)
        }
        .navigationDestination(for: ROHShow.self) { show in
            ROHShowDetailView(show: show)
        }
    }
}

private struct ROHFeaturedEpisode: View {
    let episode: ROHEpisode

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ROHRemoteImage(url: episode.imageURL)
                .frame(height: 190)

            VStack(alignment: .leading, spacing: 8) {
                Text("TODAY’S EPISODE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(rohTeal)
                Text(episode.title)
                    .font(.system(size: 27, weight: .bold, design: .serif))
                    .foregroundStyle(rohInk)
                Text(episode.series.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(rohTeal)

                HStack {
                    Label("PLAY EPISODE", systemImage: "play.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(rohTeal, in: RoundedRectangle(cornerRadius: 6))
                    Spacer()
                    Text("\(episode.date)  ·  \(episode.duration)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct ROHShowsView: View {
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ROHHeader(title: "Shows")
                Text("Seven programs. One place to listen, search, and follow the full Revive Our Hearts archive.")
                    .font(.system(size: 27, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                    ForEach(ROHContent.shows) { show in
                        NavigationLink(value: show) {
                            ROHShowCard(show: show)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(rohCream)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: ROHShow.self) { show in
            ROHShowDetailView(show: show)
        }
    }
}

private struct ROHSearchView: View {
    @State private var query = ""

    private var episodes: [ROHEpisode] {
        guard !query.isEmpty else { return ROHContent.episodes }
        return ROHContent.episodes.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.series.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ROHHeader(title: "Search")

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(rohTeal)
                        TextField("Search episodes and series", text: $query)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(rohTeal.opacity(0.25)))
                    .accessibilityIdentifier("search-input")

                    Text(query.isEmpty ? "RECENT EPISODES" : "SEARCH RESULTS")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)

                    if episodes.isEmpty {
                        ContentUnavailableView.search(text: query)
                    } else {
                        ForEach(episodes) { episode in
                            NavigationLink(value: episode) {
                                ROHEpisodeRow(episode: episode)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(rohCream)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: ROHEpisode.self) { episode in
            ROHEpisodeDetailView(episode: episode)
        }
    }
}

private struct ROHMoreView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ROHHeader(title: "More")

                VStack(alignment: .leading, spacing: 24) {
                    ROHWordmark()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)

                    Text("Helping women thrive in Christ.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(rohInk)

                    Text("This exploratory prototype brings the Revive Our Hearts podcast family into a focused listening experience.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    ROHLinkCard(title: "Visit ReviveOurHearts.com", subtitle: "Articles, videos, and events", icon: "safari") {
                        openURL(URL(string: "https://www.reviveourhearts.com/")!)
                    }
                    ROHLinkCard(title: "Ways to give", subtitle: "Support the ministry", icon: "heart") {
                        openURL(URL(string: "https://www.reviveourhearts.com/donate/")!)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PROTOTYPE CONTENT")
                            .font(.caption.weight(.bold))
                            .tracking(1.4)
                        Text("Public episode metadata and artwork are presented as static sample content. No account or private data is used.")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(20)
            }
        }
        .background(rohCream)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct ROHEpisodeDetailView: View {
    let episode: ROHEpisode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ROHRemoteImage(url: episode.imageURL)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(episode.series.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(rohTeal)
                Text(episode.title)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(rohInk)
                Text("\(episode.date)  ·  \(episode.duration)")
                    .foregroundStyle(.secondary)
                Button(action: {}) {
                    Label("Play episode", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(rohTeal, in: RoundedRectangle(cornerRadius: 10))
                }
                Text("Listen as the Revive Our Hearts team opens Scripture and offers practical encouragement for grace-filled living.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .background(rohCream)
        .navigationTitle("Episode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ROHShowDetailView: View {
    let show: ROHShow

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ROHRemoteImage(url: show.imageURL)
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(show.title)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(rohInk)
                Text(show.isActive ? "ACTIVE SHOW" : "ARCHIVE")
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(rohTeal)
                Text("Biblical teaching and honest conversation to help women live out God’s truth with freedom, fullness, and fruitfulness.")
                    .foregroundStyle(.secondary)
                Text("Latest episodes")
                    .font(.title2.bold())
                    .foregroundStyle(rohInk)
                ForEach(ROHContent.episodes.prefix(3)) { episode in
                    ROHEpisodeRow(episode: episode)
                    Divider()
                }
            }
            .padding(20)
        }
        .background(rohCream)
        .navigationTitle(show.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ROHHeader: View {
    var title: String?
    var tagline: String?

    init(title: String? = nil, tagline: String? = nil) {
        self.title = title
        self.tagline = tagline
    }

    var body: some View {
        HStack {
            ROHWordmark()
            Spacer()
            Text(title ?? tagline ?? "")
                .font(title == nil ? .caption2.weight(.bold) : .title3.weight(.bold))
                .tracking(title == nil ? 1.8 : 0)
                .foregroundStyle(title == nil ? rohTeal : rohInk)
        }
        .padding(.horizontal, 20)
        .frame(height: 62)
        .background(rohCream)
        .overlay(alignment: .bottom) { Divider() }
    }
}

private struct ROHWordmark: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "heart")
                .font(.headline)
            Text("Revive Our Hearts")
                .font(.custom("Snell Roundhand", size: 20).weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(rohInk)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Revive Our Hearts")
    }
}

private struct ROHSectionTitle: View {
    let title: String
    let action: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .serif))
                .foregroundStyle(rohInk)
            Spacer()
            Text(action)
                .font(.caption.weight(.bold))
                .foregroundStyle(rohTeal)
        }
    }
}

private struct ROHShowCard: View {
    let show: ROHShow
    var width: CGFloat? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ROHRemoteImage(url: show.imageURL)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 11))
            Text(show.title)
                .font(.headline)
                .foregroundStyle(rohInk)
                .lineLimit(2)
            Text(show.isActive ? "Active show" : "Archive")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: width, alignment: .leading)
    }
}

private struct ROHEpisodeRow: View {
    let episode: ROHEpisode

    var body: some View {
        HStack(spacing: 12) {
            ROHRemoteImage(url: episode.imageURL)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 3) {
                Text(episode.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(rohInk)
                    .lineLimit(2)
                Text(episode.series)
                    .font(.subheadline)
                    .foregroundStyle(rohTeal)
                Text("\(episode.date)  ·  \(episode.duration)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 6)
            Image(systemName: "play.fill")
                .foregroundStyle(rohTeal)
                .frame(width: 42, height: 42)
                .overlay(Circle().stroke(rohTeal.opacity(0.3)))
        }
        .contentShape(Rectangle())
    }
}

private struct ROHLinkCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(rohTeal)
                    .frame(width: 28)
                VStack(alignment: .leading) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(rohInk)
            .padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct ROHRemoteImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                ZStack {
                    rohInk.opacity(0.12)
                    Image(systemName: "photo").foregroundStyle(rohTeal)
                }
            default:
                ZStack {
                    rohInk.opacity(0.08)
                    ProgressView().tint(rohTeal)
                }
            }
        }
        .clipped()
    }
}

private struct ROHShow: Identifiable, Hashable {
    let id: String
    let title: String
    let imageURL: URL
    let isActive: Bool
}

private struct ROHEpisode: Identifiable, Hashable {
    let id: String
    let title: String
    let series: String
    let date: String
    let duration: String
    let imageURL: URL
}

private enum ROHContent {
    static let baseURL = "https://roh-mobile-app-prototype.1-five-q-innovations.workers.dev/content"

    static let shows = [
        ROHShow(id: "roh", title: "Revive Our Hearts", imageURL: url("shows/revive-our-hearts.jpg"), isActive: true),
        ROHShow(id: "weekend", title: "Revive Our Hearts Weekend", imageURL: url("shows/weekend.jpg"), isActive: true),
        ROHShow(id: "seeking-him", title: "Seeking Him", imageURL: url("shows/seeking-him.jpg"), isActive: true),
        ROHShow(id: "true-girl", title: "True Girl", imageURL: url("shows/true-girl.jpg"), isActive: true),
        ROHShow(id: "grounded", title: "Grounded", imageURL: url("shows/grounded.jpg"), isActive: false),
        ROHShow(id: "deep-well", title: "The Deep Well with Erin Davis", imageURL: url("shows/the-deep-well.jpg"), isActive: false),
        ROHShow(id: "bible-studies", title: "Revive Our Hearts Bible Studies", imageURL: url("shows/bible-studies.webp"), isActive: false)
    ]

    static let episodes = [
        ROHEpisode(id: "defined", title: "Defined by More Than Marriage", series: "Embracing Singleness", date: "Aug 4, 2026", duration: "29:45", imageURL: url("episodes/revive-our-hearts/defined-by-more-than-marriage.jpg")),
        ROHEpisode(id: "colleen", title: "Remembering Colleen Chao", series: "Revive Our Hearts", date: "Aug 3, 2026", duration: "32:06", imageURL: url("episodes/revive-our-hearts/remembering-colleen-chao.jpg")),
        ROHEpisode(id: "singleness", title: "Embracing Singleness (E1)", series: "Revive Our Hearts", date: "Aug 3, 2026", duration: "32:45", imageURL: url("episodes/revive-our-hearts/defined-by-more-than-marriage.jpg")),
        ROHEpisode(id: "manifesto-15", title: "Exploring the True Woman Manifesto (Ep15)", series: "Revive Our Hearts", date: "Jul 31, 2026", duration: "25:03", imageURL: url("episodes/revive-our-hearts/training-generation-1.jpg")),
        ROHEpisode(id: "manifesto-14", title: "Exploring the True Woman Manifesto (E14)", series: "Revive Our Hearts", date: "Jul 30, 2026", duration: "24:53", imageURL: url("episodes/revive-our-hearts/training-generation-1.jpg")),
        ROHEpisode(id: "girl-truth", title: "The Truth Your Girl Desperately Needs", series: "Revive Our Hearts Weekend", date: "Aug 1, 2026", duration: "25:12", imageURL: url("episodes/weekend/the-truth-your-girl-desperately-needs.jpg"))
    ]

    private static func url(_ path: String) -> URL {
        URL(string: "\(baseURL)/\(path)")!
    }
}

#Preview {
    ROHRootView()
}
