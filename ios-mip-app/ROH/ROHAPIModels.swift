import Foundation

struct ROHPaginatedResponse<Item: Decodable>: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Item]
}

struct ROHPage<Item> {
    let items: [Item]
    let nextPage: URL?
}

struct ROHGraphics: Codable, Hashable {
    let logo: URL?
    let square: URL?
    let rectangular: URL?
    let itunes: URL?
    let thumbnail: URL?
    let webpThumbnail: URL?
    let collection: URL?

    enum CodingKeys: String, CodingKey {
        case logo, square, rectangular, itunes, thumbnail, collection
        case webpThumbnail = "webp_thumbnail"
    }
}

struct ROHShow: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let mediaSourceCode: String?
    let hosts: [String]
    let webURL: URL?
    let description: String?
    let languageCode: String
    let languageName: String
    let siteName: String
    let graphics: ROHGraphics

    enum CodingKeys: String, CodingKey {
        case id, title, hosts, description, graphics
        case mediaSourceCode = "media_source_code"
        case webURL = "web_url"
        case languageCode = "language_code"
        case languageName = "language_name"
        case siteName = "site_name"
    }

    var squareImageURL: URL? {
        graphics.square ?? graphics.webpThumbnail ?? graphics.thumbnail
    }

    var wideImageURL: URL? {
        graphics.rectangular ?? squareImageURL
    }
}

struct ROHEpisode: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let airDate: Date
    let podcastID: Int
    let podcast: URL?
    let seoDescription: String?
    let absolutePath: String
    let mediaURL: URL?
    let graphics: ROHGraphics

    enum CodingKeys: String, CodingKey {
        case id, title, podcast, graphics
        case airDate = "air_date"
        case podcastID = "podcast_id"
        case seoDescription = "seo_description"
        case absolutePath = "get_absolute_url"
        case mediaURL = "media_url"
    }

    var squareImageURL: URL? {
        graphics.square ?? graphics.collection ?? graphics.rectangular
    }

    var wideImageURL: URL? {
        graphics.rectangular ?? graphics.collection ?? graphics.square
    }
}

struct ROHBlog: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let enabled: Bool
    let feedOnly: Bool
    let redirectURL: URL?
    let order: Int
    let image: URL?

    enum CodingKeys: String, CodingKey {
        case id, title, enabled, order, image
        case feedOnly = "feed_only"
        case redirectURL = "redirect_url"
    }
}

struct ROHArticle: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let blog: Int
    let content: String
    let absolutePath: String
    let image: URL?
    let authors: [String]
    let date: Date

    enum CodingKeys: String, CodingKey {
        case id, title, blog, content, image, authors, date
        case absolutePath = "get_absolute_url"
    }
}

struct ROHFeature: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let order: Int
    let ctaButtonURL: URL?
    let squareImage: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, order
        case ctaButtonURL = "cta_button_url"
        case squareImage = "square_image"
    }
}

struct ROHProduct: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let description: String
    let subtitle: String
    let type: String
    let topics: [String]
    let authors: [String]
    let image: URL?
    let thumbnail: URL?
    let webpThumbnail: URL?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, description, subtitle, type, topics, authors, image, thumbnail, webpThumbnail
    }

    var cardImageURL: URL? {
        webpThumbnail ?? thumbnail ?? image
    }

    var storeURL: URL? {
        URL(string: "https://www.reviveourhearts.com/store/product/\(slug)/")
    }
}

extension JSONDecoder {
    static var roh: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let value = try decoder.singleValueContainer().decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: value) {
                return date
            }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: value) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Invalid ROH API date: \(value)"
            )
        }
        return decoder
    }
}
