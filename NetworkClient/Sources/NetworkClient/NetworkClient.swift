//

import Foundation


public class NetworkClient {}

public protocol NetworkRequest {
    associatedtype NetworkResponse: Decodable
    var service: Service { get }
    var path: String { get }
    var jsonDecoder: JSONDecoder { get }
    var parameters: [String: String] { get }
}

public struct Server: Codable {
    let host: String
    public init(host: String) {
        self.host = host
    }
}

public extension NetworkRequest {
    private static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    var jsonDecoder: JSONDecoder {
        .default
    }
    
    var parameters: [String: String] {
        [:]
    }
    
    func start() async throws -> NetworkResponse {
        let session = URLSession.shared
        let request = createRequest(baseURL: service.baseUrl, path: path, queryItems: parameters)
        
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 401:
                throw RequestError.unauthorized
            case 500:
                throw RequestError.internalServer
            case 200...299:
                return try jsonDecoder.decode(NetworkResponse.self, from: data)
            default:
                throw RequestError.general
            }
        }
        throw RequestError.general
    }
    
    private func createRequest(baseURL: URL, path: String, queryItems: [String: String]) -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path).appendingQueryParameters(queryItems))
        request.httpMethod = "GET"
        return request
    }
}

public protocol NetworkResponse: Decodable {}

public enum RequestError: Error {
    case general
    case unauthorized
    case internalServer
}

public struct Service {
    let server: Server
    
    var baseUrl: URL {
        let urlString = "https://" + server.host
        guard let url = URL(string: urlString) else {
            fatalError("Could not generate baseUrl")
        }
        return url
    }
    
    public init(server: Server) {
        self.server = server
    }
}

extension JSONDecoder {
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { fatalError() }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url!
    }
}
