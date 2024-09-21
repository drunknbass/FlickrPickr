//

import Foundation
import NetworkClient


struct PhotosRequest: NetworkRequest {
    typealias NetworkResponse = PhotoFeed
    let service: Service = .flickr
    let filter: [String]
    var path: String
    
    var parameters: [String: String] {
        ["format": "json",
         "nojsoncallback": "1",
         "tags": filter.joined(separator: ",")]
    }
    
    init(tags: [String]) {
        path = "/services/feeds/photos_public.gne"
        filter = tags
    }
}
