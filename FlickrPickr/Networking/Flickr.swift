//

import Foundation
import NetworkClient

extension Service {
    nonisolated(unsafe) static let flickr = Service(server: .flickr)
}

extension Server {
    static let flickr = Server(host: "api.flickr.com")
}
