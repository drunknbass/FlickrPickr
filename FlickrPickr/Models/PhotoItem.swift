//
import Foundation

struct PhotoItem: Codable {
    let title: String
    let link: String
    let media: PhotoMedia
    let dateTaken: Date
    let description: String
    let published: Date
    let author: String
    let authorId: String
    let tags: String
}
