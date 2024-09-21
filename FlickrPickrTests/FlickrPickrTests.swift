//

import Foundation
import Testing
@testable import FlickrPickr


@Suite("ContentViewModelTests")
struct ContentViewModelTests {
    @Test("Initial state")
    func testInitialState() {
        let mockProvider = MockDataProvider()
        let viewModel = ContentViewModel(provider: mockProvider)
        
        #expect(viewModel.searchText.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)
        #expect(viewModel.photos.isEmpty)
        #expect(viewModel.selectedPhoto == nil)
        #expect(!viewModel.shouldDisplayDetailView)
        #expect(!viewModel.shouldDisplayError)
    }
    
    @Test("Update search text")
    func testUpdateSearchText() async {
        let mockProvider = MockDataProvider()
        let viewModel = ContentViewModel(provider: mockProvider)
        
        viewModel.updateSearchText("test")
        
        #expect(viewModel.searchText == "test")
        #expect(viewModel.isLoading)
        
        viewModel.perform(NSSelectorFromString("performSearch"))

        try? await Task.sleep(for: .seconds(0.001))
        
        #expect(!viewModel.isLoading)
        #expect(!viewModel.photos.isEmpty)
    }
    
    @Test("Select photo")
    func testSelectPhoto() {
        let mockProvider = MockDataProvider()
        let viewModel = ContentViewModel(provider: mockProvider)
        let photo = PhotoItem(title: "Test", link: URL(string: "https://example.com")!, media: PhotoMedia(m: ""), dateTaken: Date(), description: "", published: Date(), author: "", authorId: "", tags: "")
        
        viewModel.selectPhoto(photo: photo)
        
        #expect(viewModel.selectedPhoto == photo)
        #expect(viewModel.shouldDisplayDetailView)
    }
    
    @Test("Error handling and dismissal")
    func testErrorHandlingAndDismissal() async {
        let mockProvider = ErrorMockDataProvider()
        let viewModel = ContentViewModel(provider: mockProvider)
        
        viewModel.updateSearchText("error")
        viewModel.perform(NSSelectorFromString("performSearch"))

        try? await Task.sleep(for: .seconds(0.1))
        
        #expect(viewModel.shouldDisplayError)
        #expect(viewModel.error != nil)
        
        viewModel.dismissError()
        
        #expect(!viewModel.shouldDisplayError)
        #expect(viewModel.error == nil)
    }
    
    @Test("Perform search")
    func testPerformSearch() async {
        let mockProvider = MockDataProvider()
        let viewModel = ContentViewModel(provider: mockProvider)
        
        viewModel.updateSearchText("test")
        viewModel.perform(NSSelectorFromString("performSearch"))
        
        try? await Task.sleep(for: .seconds(0.1))
        
        #expect(!viewModel.isLoading)
        #expect(!viewModel.photos.isEmpty)
        #expect(viewModel.photos.count == 1)
        #expect(viewModel.photos[0].title == "Test Title")
    }
}

class ErrorMockDataProvider: PhotoDataProvider {
    func photos(filteredBy tags: [String]) async throws -> [PhotoItem] {
        throw NSError(domain: "ErrorMockDataProvider", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    }
}

