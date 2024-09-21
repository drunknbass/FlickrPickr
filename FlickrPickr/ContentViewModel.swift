//

import Foundation


@Observable
final class ContentViewModel: NSObject {
    let dataProvider: PhotoDataProvider
    
    private(set) var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var error: Error? = nil
    private(set) var photos: [PhotoItem] = []
    private(set) var selectedPhoto: PhotoItem?
    private var dataTask: Task<(), Never>?
    private var lastSearchText: String = ""
    
    var shouldDisplayDetailView: Bool {
        selectedPhoto != nil
    }
    
    var shouldDisplayError: Bool {
        error != nil
    }
    
    deinit {
        dataTask?.cancel()
    }
    
    init(provider: PhotoDataProvider) {
        dataProvider = provider
    }
    
    // Actions
    func updateSearchText(_ text: String) {
        guard lastSearchText != text else { return }
        searchText = text
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if text.count > 0 {
            isLoading = true
            self.perform(#selector(performSearch), with: nil, afterDelay: 1.5)
        } else {
            isLoading = false
        }
    }

    func onSubmit() {
        guard searchText != lastSearchText else { return }
        performSearch()
    }
    
    func selectPhoto(photo: PhotoItem?) {
        selectedPhoto = photo
    }
    
    func dismissError() {
        error = nil
    }
    
    // Debounced search
    @objc
    private func performSearch() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if !searchText.isEmpty {
            isLoading = true
            dataTask?.cancel()
            error = nil
            dataTask = Task { [weak self] in
                guard let self = self else { return }
                do {
                    let result = try await self.performSearchAsync()
                    await MainActor.run {
                        self.lastSearchText = self.searchText
                        self.photos = result
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        if !(error is CancellationError) {
                            self.error = error
                        }
                        self.lastSearchText = ""
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func performSearchAsync() async throws -> [PhotoItem] {
        try await dataProvider.photos(filteredBy: searchText.components(separatedBy: ","))
    }
}

