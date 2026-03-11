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

struct PageDataContent: Codable {
    let pageContent: String?
    let audio: AudioData?
    let audioUrl: String?
    let audioName: String?
    let audioCredit: String?
    
    enum CodingKeys: String, CodingKey {
        case pageContent = "page_content"
        case audio
        case audioUrl = "audio_url"
        case audioName = "audio_name"
        case audioCredit = "audio_credit"
    }
}

struct CollectionChild: Codable {
    let uuid: String
    let title: String
    let cover: String?
    let type: String?
}

struct PageData: Codable {
    let pageType: String?
    let type: String?
    let title: String
    let cover: String?
    let pageContent: String?
    let children: [CollectionChild]?
    let data: PageDataContent?
    let hasForm: Bool?
    
    enum CodingKeys: String, CodingKey {
        case pageType = "page_type"
        case type
        case title
        case cover
        case pageContent = "page_content"
        case children
        case data
        case hasForm = "has_form"
    }
    
    // Helper to get effective page type
    var effectivePageType: String {
        return pageType ?? type ?? "content"
    }
    
    // Helper to check if this is an audio item
    var isAudioItem: Bool {
        return effectivePageType == "collection-item" && type == "audio"
    }
    
    // Helper to get audio URL from various locations
    var audioUrl: String? {
        return data?.audio?.audioUrl ?? data?.audioUrl
    }
    
    // Helper to get audio title
    var audioTitle: String? {
        return data?.audio?.audioName ?? data?.audioName ?? title
    }
    
    // Helper to get audio artist/credit
    var audioArtist: String? {
        return data?.audio?.audioCredit ?? data?.audioCredit
    }
    
    // Helper to get HTML content
    var htmlContent: String? {
        switch effectivePageType {
        case "content":
            return pageContent
        case "collection-item":
            return data?.pageContent
        default:
            return nil
        }
    }
}

// MARK: - Search Models

struct SearchResult: Codable {
    let uuid: String
    let title: String
    let description: String?
    let url: String
}
