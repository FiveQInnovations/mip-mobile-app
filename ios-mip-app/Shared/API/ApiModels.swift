//
//  ApiModels.swift
//  FFCI
//
//  Firefighters for Christ International - API Data Models
//

import Foundation

// MARK: - Menu Models

struct MenuPage: Codable {
    let uuid: String
    let type: String
    let url: String
}

struct MenuItem: Codable {
    let label: String
    let icon: String?
    let page: MenuPage
    let externalUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case label
        case icon
        case page
        case externalUrl = "external_url"
    }
}

// MARK: - Site Meta Models

struct HomepageQuickTask: Codable {
    let uuid: String?
    let label: String?
    let description: String?
    let imageUrl: String?
    let externalUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case label
        case description
        case imageUrl = "image_url"
        case externalUrl = "external_url"
    }
}

struct HomepageFeatured: Codable {
    let uuid: String?
    let title: String?
    let description: String?
    let imageUrl: String?
    let badgeText: String?
    let externalUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case title
        case description
        case imageUrl = "image_url"
        case badgeText = "badge_text"
        case externalUrl = "external_url"
    }
}

struct SocialLink: Codable {
    let platform: String
    let url: String
}

struct SiteMeta: Codable {
    let title: String
    let social: [SocialLink]?
    let logo: String?
    let homepageQuickTasks: [HomepageQuickTask]?
    let homepageFeatured: [HomepageFeatured]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case social
        case logo
        case homepageQuickTasks = "homepage_quick_tasks"
        case homepageFeatured = "homepage_featured"
    }
    
    init(
        title: String,
        social: [SocialLink]?,
        logo: String?,
        homepageQuickTasks: [HomepageQuickTask]?,
        homepageFeatured: [HomepageFeatured]?
    ) {
        self.title = title
        self.social = social
        self.logo = logo
        self.homepageQuickTasks = homepageQuickTasks
        self.homepageFeatured = homepageFeatured
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        social = try container.decodeIfPresent([SocialLink].self, forKey: .social)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        homepageQuickTasks = try container.decodeIfPresent([HomepageQuickTask].self, forKey: .homepageQuickTasks)
        homepageFeatured = Self.decodeHomepageFeatured(from: container)
    }
    
    private static func decodeHomepageFeatured(from container: KeyedDecodingContainer<CodingKeys>) -> [HomepageFeatured]? {
        guard container.contains(.homepageFeatured) else { return nil }
        
        if let isNil = try? container.decodeNil(forKey: .homepageFeatured), isNil {
            return nil
        }
        
        if let array = try? container.decode([HomepageFeatured].self, forKey: .homepageFeatured) {
            return array
        }
        
        if let object = try? container.decode([String: HomepageFeatured].self, forKey: .homepageFeatured) {
            let numericPairs = object.compactMap { key, value -> (Int, HomepageFeatured)? in
                guard let index = Int(key) else { return nil }
                return (index, value)
            }
            
            guard numericPairs.count == object.count else { return nil }
            return numericPairs.sorted { $0.0 < $1.0 }.map(\.1)
        }
        
        // Soft-fail malformed homepage_featured payloads.
        return nil
    }
}

struct SiteData: Codable {
    let menu: [MenuItem]
    let siteData: SiteMeta
    
    enum CodingKeys: String, CodingKey {
        case menu
        case siteData = "site_data"
    }
}

// MARK: - Page Models

struct AudioData: Codable {
    let audioUrl: String?
    let audioName: String?
    let audioCredit: String?
    
    enum CodingKeys: String, CodingKey {
        case audioUrl = "audio_url"
        case audioName = "audio_name"
        case audioCredit = "audio_credit"
    }
}

struct VideoUrlData: Codable {
    let value: String?
}

struct VideoData: Codable {
    let source: String?
    let url: VideoUrlData?
}

struct CategoryDefinition: Codable {
    let name: String
    let slug: String
    let description: String?
    let count: Int?
}

struct NestedPageDataContent: Codable {
    let pageContent: String?
    let audio: AudioData?
    let audioUrl: String?
    let audioName: String?
    let audioCredit: String?
    let videoSource: String?
    let videoUrl: String?
    let videoEmbed: String?
    let categories: String?
    
    enum CodingKeys: String, CodingKey {
        case pageContent = "page_content"
        case audio
        case audioUrl = "audio_url"
        case audioName = "audio_name"
        case audioCredit = "audio_credit"
        case videoSource = "video_source"
        case videoUrl = "video_url"
        case videoEmbed = "video_embed"
        case categories
    }
}

struct PageDataContent: Codable {
    let pageContent: String?
    let audio: AudioData?
    let video: VideoData?
    let audioUrl: String?
    let audioName: String?
    let audioCredit: String?
    let videoSource: String?
    let videoUrl: String?
    let videoEmbed: String?
    let categories: String?
    let content: NestedPageDataContent?
    
    enum CodingKeys: String, CodingKey {
        case pageContent = "page_content"
        case audio
        case video
        case audioUrl = "audio_url"
        case audioName = "audio_name"
        case audioCredit = "audio_credit"
        case videoSource = "video_source"
        case videoUrl = "video_url"
        case videoEmbed = "video_embed"
        case categories
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pageContent = try container.decodeIfPresent(String.self, forKey: .pageContent)
        audio = try container.decodeIfPresent(AudioData.self, forKey: .audio)
        video = try container.decodeIfPresent(VideoData.self, forKey: .video)
        audioUrl = try container.decodeIfPresent(String.self, forKey: .audioUrl)
        audioName = try container.decodeIfPresent(String.self, forKey: .audioName)
        audioCredit = try container.decodeIfPresent(String.self, forKey: .audioCredit)
        videoSource = try container.decodeIfPresent(String.self, forKey: .videoSource)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        videoEmbed = try container.decodeIfPresent(String.self, forKey: .videoEmbed)
        content = try container.decodeIfPresent(NestedPageDataContent.self, forKey: .content)
        categories = Self.decodeCategoriesString(from: container)
    }
    
    private static func decodeCategoriesString(from container: KeyedDecodingContainer<CodingKeys>) -> String? {
        guard container.contains(.categories) else { return nil }
        
        if let isNil = try? container.decodeNil(forKey: .categories), isNil {
            return nil
        }
        
        if let text = try? container.decode(String.self, forKey: .categories) {
            return text
        }
        
        if let lines = try? container.decode([String].self, forKey: .categories) {
            return lines.joined(separator: "\n")
        }
        
        // Soft-fail malformed categories payloads.
        return nil
    }
}

struct CollectionChild: Codable {
    let uuid: String
    let title: String
    let cover: String?
    let type: String?
    let categorySlug: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case title
        case cover
        case type
        case categorySlug = "category_slug"
    }
    
    init(uuid: String, title: String, cover: String?, type: String?, categorySlug: String? = nil) {
        self.uuid = uuid
        self.title = title
        self.cover = cover
        self.type = type
        self.categorySlug = categorySlug
    }
}

struct PageData: Codable {
    let pageType: String?
    let type: String?
    let title: String
    let cover: String?
    let pageContent: String?
    let children: [CollectionChild]?
    let categories: [CategoryDefinition]?
    let data: PageDataContent?
    let content: PageDataContent?
    let hasForm: Bool?
    
    enum CodingKeys: String, CodingKey {
        case pageType = "page_type"
        case type
        case title
        case cover
        case pageContent = "page_content"
        case children
        case categories
        case data
        case content
        case hasForm = "has_form"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pageType = try container.decodeIfPresent(String.self, forKey: .pageType)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        cover = try container.decodeIfPresent(String.self, forKey: .cover)
        pageContent = try container.decodeIfPresent(String.self, forKey: .pageContent)
        children = try container.decodeIfPresent([CollectionChild].self, forKey: .children)
        categories = Self.decodeCategoryDefinitions(from: container)
        data = try container.decodeIfPresent(PageDataContent.self, forKey: .data)
        content = try container.decodeIfPresent(PageDataContent.self, forKey: .content)
        hasForm = try container.decodeIfPresent(Bool.self, forKey: .hasForm)
    }
    
    private static func decodeCategoryDefinitions(from container: KeyedDecodingContainer<CodingKeys>) -> [CategoryDefinition]? {
        guard container.contains(.categories) else { return nil }
        
        if let isNil = try? container.decodeNil(forKey: .categories), isNil {
            return nil
        }
        
        if let array = try? container.decode([CategoryDefinition].self, forKey: .categories) {
            return array
        }
        
        if let object = try? container.decode([String: CategoryDefinition].self, forKey: .categories) {
            let numericPairs = object.compactMap { key, value -> (Int, CategoryDefinition)? in
                guard let index = Int(key) else { return nil }
                return (index, value)
            }
            
            if numericPairs.count == object.count {
                return numericPairs.sorted { $0.0 < $1.0 }.map(\.1)
            }
            
            return object.values.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
        
        // Soft-fail malformed categories payloads.
        return nil
    }
    
    private var primaryContent: PageDataContent? {
        data ?? content
    }
    
    private var nestedContent: NestedPageDataContent? {
        primaryContent?.content
    }
    
    private static func trimCategoryValue(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
    }
    
    private static func parseCategoryDefinitions(from raw: String) -> [CategoryDefinition] {
        var parsed: [CategoryDefinition] = []
        var pendingName: String?
        
        for line in raw.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                continue
            }
            
            let normalized = trimmed.hasPrefix("-")
                ? String(trimmed.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                : trimmed
            
            if normalized.lowercased().hasPrefix("name:") {
                let rawName = String(normalized.dropFirst("name:".count))
                let cleaned = trimCategoryValue(rawName)
                pendingName = cleaned.isEmpty ? nil : cleaned
                continue
            }
            
            if normalized.lowercased().hasPrefix("slug:") {
                let rawSlug = String(normalized.dropFirst("slug:".count))
                let slug = trimCategoryValue(rawSlug)
                guard !slug.isEmpty else { continue }
                
                let name = pendingName ?? slug.replacingOccurrences(of: "-", with: " ")
                parsed.append(
                    CategoryDefinition(
                        name: name,
                        slug: slug,
                        description: nil,
                        count: nil
                    )
                )
                pendingName = nil
            }
        }
        
        return parsed
    }
    
    // Helper to get effective page type
    var effectivePageType: String {
        return pageType ?? type ?? "content"
    }
    
    // Helper to check if this is an audio item
    var isAudioItem: Bool {
        return effectivePageType == "collection-item" && type == "audio"
    }
    
    // Helper to check if this is a video item
    var isVideoItem: Bool {
        return effectivePageType == "collection-item" && type == "video"
    }
    
    // Helper to get audio URL from various locations
    var audioUrl: String? {
        return primaryContent?.audio?.audioUrl
            ?? primaryContent?.audioUrl
            ?? nestedContent?.audio?.audioUrl
            ?? nestedContent?.audioUrl
    }
    
    // Helper to get audio title
    var audioTitle: String? {
        return primaryContent?.audio?.audioName
            ?? primaryContent?.audioName
            ?? nestedContent?.audio?.audioName
            ?? nestedContent?.audioName
            ?? title
    }
    
    // Helper to get audio artist/credit
    var audioArtist: String? {
        return primaryContent?.audio?.audioCredit
            ?? primaryContent?.audioCredit
            ?? nestedContent?.audio?.audioCredit
            ?? nestedContent?.audioCredit
    }
    
    // Helper to get video URL from various locations
    var videoUrl: String? {
        return primaryContent?.video?.url?.value
            ?? primaryContent?.videoUrl
            ?? nestedContent?.videoUrl
    }
    
    // Helper to get optional video embed markup from various locations
    var videoEmbedHtml: String? {
        return primaryContent?.videoEmbed
            ?? nestedContent?.videoEmbed
    }
    
    // Helper to get HTML content
    var htmlContent: String? {
        switch effectivePageType {
        case "content":
            return pageContent
        case "collection-item":
            return primaryContent?.pageContent ?? nestedContent?.pageContent
        default:
            return nil
        }
    }
    
    // Media item category slug fallback when list payload omits category_slug.
    var categorySlug: String? {
        let raw = nestedContent?.categories ?? primaryContent?.categories
        guard let raw else { return nil }
        
        return raw
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { line in
                !line.isEmpty &&
                !line.hasPrefix("-") &&
                !line.lowercased().hasPrefix("name:") &&
                !line.lowercased().hasPrefix("slug:")
            }?
            .split(separator: ",", maxSplits: 1)
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    // Media collection category definitions from structured payload or raw YAML-like fallback.
    var categoryDefinitions: [CategoryDefinition] {
        let structured = (categories ?? [])
            .map { category in
                CategoryDefinition(
                    name: Self.trimCategoryValue(category.name),
                    slug: category.slug.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: category.description,
                    count: category.count
                )
            }
            .filter { !$0.slug.isEmpty }
        
        if !structured.isEmpty {
            return structured
        }
        
        guard let raw = primaryContent?.categories,
              raw.localizedCaseInsensitiveContains("slug:") else {
            return []
        }
        
        return Self.parseCategoryDefinitions(from: raw)
    }
}

// MARK: - Search Models

struct SearchResult: Codable {
    let uuid: String
    let title: String
    let description: String?
    let url: String
}
