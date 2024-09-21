//

import Foundation
import RegexBuilder


struct PhotoItem: Codable {
    let title: String
    let link: URL
    let media: PhotoMedia
    let dateTaken: Date
    let description: String
    let published: Date
    let author: String
    let authorId: String
    let tags: String
}

extension PhotoItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(link)
        hasher.combine(media)
        hasher.combine(dateTaken)
        hasher.combine(description)
        hasher.combine(published)
        hasher.combine(author)
        hasher.combine(authorId)
        hasher.combine(tags)
    }
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.title == rhs.title &&
        lhs.link == rhs.link &&
        lhs.media == rhs.media &&
        lhs.dateTaken == rhs.dateTaken &&
        lhs.description == rhs.description &&
        lhs.published == rhs.published &&
        lhs.author == rhs.author &&
        lhs.authorId == rhs.authorId &&
        lhs.tags == rhs.tags
    }
}

// regex to extract the image dimensions from the description
extension PhotoItem {
    var size: CGSize? {
        let widthPattern = Regex {
            "width=\""
            Capture {
                OneOrMore(.digit)
            }
            "\""
        }
        let heightPattern = Regex {
            "height=\""
            Capture {
                OneOrMore(.digit)
            }
            "\""
        }
        guard let widthMatch = description.firstMatch(of: widthPattern),
              let heightMatch = description.firstMatch(of: heightPattern),
              let width = Int(widthMatch.1),
              let height = Int(heightMatch.1)
        else {
            return nil
        }
        
        return CGSize(width: width, height: height)
    }
}

extension PhotoItem {
    static var sample = PhotoItem(title: "Test Title", link: URL(string: "https://flickr.com")!, media: .init(m: "https://live.staticflickr.com/65535/54005488430_642610b8e9_m.jpg"), dateTaken: .now, description: "Test description.", published: .now, author: "Aaron Alexander", authorId: "123456", tags: "")
}
