//

import Foundation

// https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=lunch,table
struct PhotoFeed: Codable {
    let title: String
    let link: String
    let description: String
    let modified: Date
    let generator: String
    let items: [PhotoItem]
}
