//
// https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=lunch,table
import Foundation

struct PhotoFeed: Codable {
    /*
     "title": "Recent Uploads tagged lunch and table",
             "link": "https:\/\/www.flickr.com\/photos\/",
             "description": "",
             "modified": "2024-09-14T22:07:55Z",
             "generator": "https:\/\/www.flickr.com",
             "items": [
     */
    let title: String
    let link: String
    let description: String
    let modified: Date
    let generator: String
    let items: [PhotoItem]
}
