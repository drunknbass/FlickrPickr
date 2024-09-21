//

import Foundation
import NetworkClient
import SwiftUI


protocol PhotoDataProvider {
    func photos(filteredBy tags: [String]) async throws -> [PhotoItem]
}


final class FlickrClient {
    let jsonDecoder = JSONDecoder()
}

extension FlickrClient: PhotoDataProvider {
    func photos(filteredBy tags: [String]) async throws -> [PhotoItem] {
        return try await PhotosRequest(tags: tags).start().items
    }
}

extension EnvironmentValues {
    @Entry var dataProvider: PhotoDataProvider = {
        // use mock data for tests
        if let testEnvironment = ProcessInfo.processInfo.environment["DATA_PROVIDER_ENV"],
           testEnvironment == "TEST_ENVIRONMENT" {
            return MockDataProvider()
        } else {
            return FlickrClient()
        }
    }()
}

final class MockDataProvider: PhotoDataProvider {
    func photos(filteredBy tags: [String]) async throws -> [PhotoItem] {
        [
            PhotoItem.sample
        ]
    }
}
