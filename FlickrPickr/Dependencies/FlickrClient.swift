//

import Foundation
import SwiftUI

//
protocol FlickerDataProvider {
    func photos(filteredBy tags: [String]) async throws -> [PhotoItem]
}


final class APIClient {
    let jsonDecoder = JSONDecoder()
}

extension APIClient: FlickerDataProvider {
    func photos(filteredBy tags: [String]) async throws -> [PhotoItem] {
        let url = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(tags.joined(separator: ", "))")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let photoFeed = try jsonDecoder.decode(PhotoFeed.self, from: data)
        return photoFeed.items
    }
}

//
extension EnvironmentValues {
    @Entry var dataProvider: FlickerDataProvider = APIClient()
}
