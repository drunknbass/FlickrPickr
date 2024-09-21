import Foundation
import Testing
@testable import NetworkClient


@Suite("ServerTests")
struct ServerTests {
    @Test("Server initialization")
    func testServerInitialization() {
        let server = Server(host: "api.example.com")
        #expect(server.host == "api.example.com")
    }
}

@Suite("ServiceTests")
struct ServiceTests {
    @Test("Service base URL")
    func testServiceBaseUrl() {
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        #expect(service.baseUrl.absoluteString == "https://api.example.com")
    }
}

@Suite("NetworkRequestTests")
struct NetworkRequestTests {
    struct MockResponse: Decodable {
        let id: Int
        let name: String
    }

    struct MockNetworkRequest: NetworkRequest {
        typealias NetworkResponse = MockResponse
        
        var service: Service
        var path: String { "/test" }
        var parameters: [String: String] { ["key": "value"] }
        
        func start() async throws -> NetworkResponse {
            return MockResponse(id: 1, name: "Test")
        }
    }

    @Test("NetworkRequest basic functionality")
    func testNetworkRequestBasicFunctionality() async throws {
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        let request = MockNetworkRequest(service: service)
        
        let response = try await request.start()
        
        #expect(response.id == 1)
        #expect(response.name == "Test")
    }

    @Test("NetworkRequest URL construction")
    func testNetworkRequestURLConstruction() {
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        let request = MockNetworkRequest(service: service)
        
        let expectedURLString = "https://api.example.com/test?key=value"
        let constructedURLString = service.baseUrl.appendingPathComponent(request.path).appendingQueryParameters(request.parameters).absoluteString
        
        #expect(constructedURLString == expectedURLString)
    }
}

@Suite("NetworkRequestErrorHandlingTests")
struct NetworkRequestErrorHandlingTests {
    struct MockErrorNetworkRequest: NetworkRequest {
        typealias NetworkResponse = MockErrorResponse
        
        var service: Service
        var path: String { "/error" }
        var parameters: [String: String] { [:] }
        
        let simulatedError: Error?
        
        func start() async throws -> NetworkResponse {
            if let error = simulatedError {
                throw error
            }
            return MockErrorResponse(message: "Unexpected success")
        }
    }

    struct MockErrorResponse: NetworkResponse, Equatable {
        let message: String
    }

    @Test("Handle unexpected error")
    func testUnexpectedError() async throws {
        struct UnexpectedError: Error {}
        
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        let request = MockErrorNetworkRequest(service: service, simulatedError: UnexpectedError())
        
        do {
            _ = try await request.start()
            Issue.record("Expected an error to be thrown, but no error was thrown")
        } catch is RequestError {
            Issue.record("Expected UnexpectedError, but got RequestError")
        } catch is UnexpectedError {
        } catch {
            Issue.record("Expected UnexpectedError, but got \(error)")
        }
    }
}

@Suite("AdvancedNetworkRequestTests")
struct AdvancedNetworkRequestTests {
    struct MockJSONNetworkRequest: NetworkRequest {
        typealias NetworkResponse = MockJSONResponse
        
        var service: Service
        var path: String { "/json" }
        var parameters: [String: String] { [:] }
        var jsonDecoder: JSONDecoder { .default }
        
        // Custom implementation for testing
        var mockData: Data?
        var mockResponse: URLResponse?
        var mockError: Error?
        
        func start() async throws -> NetworkResponse {
            if let error = mockError {
                throw error
            }
            
            guard let data = mockData else {
                throw RequestError.general
            }
            
            return try jsonDecoder.decode(NetworkResponse.self, from: data)
        }
    }
    
    struct MockJSONResponse: Codable, Equatable {
        let id: Int
        let name: String
    }
    
    @Test("Successful JSON parsing")
    func testSuccessfulJSONParsing() async throws {
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        var request = MockJSONNetworkRequest(service: service)
        
        request.mockData = """
        {
            "id": 1,
            "name": "Test Item"
        }
        """.data(using: .utf8)
        
        let response = try await request.start()
        
        #expect(response == MockJSONResponse(id: 1, name: "Test Item"))
    }
    
    @Test("Handle network error")
    func testHandleNetworkError() async {
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        var request = MockJSONNetworkRequest(service: service)
        
        request.mockError = RequestError.general
        
        do {
            _ = try await request.start()
            Issue.record("Expected RequestError.general, but no error was thrown")
        } catch let error as RequestError {
            #expect(error == .general)
        } catch {
            Issue.record("Expected RequestError.general, but got \(error)")
        }
    }
    
    @Test("Handle invalid JSON")
    func testHandleInvalidJSON() async {
        let server = Server(host: "api.example.com")
        let service = Service(server: server)
        var request = MockJSONNetworkRequest(service: service)
        
        request.mockData = "Invalid JSON".data(using: .utf8)
        
        do {
            _ = try await request.start()
            Issue.record("Expected decoding error, but no error was thrown")
        } catch {
            #expect(true)
        }
    }
}

// Helper extension to append query parameters to URL
extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url!
    }
}
