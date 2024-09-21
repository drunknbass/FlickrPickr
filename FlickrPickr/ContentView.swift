//

import Combine
import Foundation
import SwiftUI


struct ContentView: View {
    @State private var viewModel: ContentViewModel
    @State private var showLoadingIndicator: Bool = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                gridView(photos: viewModel.photos)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if showLoadingIndicator {
                    ProgressView()
                        .controlSize(.large)
                        .padding(20)
                }
            }
            .overlay {
                if viewModel.photos.isEmpty, !viewModel.searchText.isEmpty, !viewModel.isLoading {
                    ContentUnavailableView.search
                }
            }
            .navigationTitle("Photos")
            .navigationDestination(item: .init(get: { viewModel.selectedPhoto }, set: { photo in
                viewModel.selectPhoto(photo: photo)
            })) { photo in
                ContentDetailView(photo: photo)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .searchable(text: .init(get: { viewModel.searchText }, set: { text in
            viewModel.updateSearchText(text)
        }))
        .onSubmit(of: .search, viewModel.onSubmit)
        .alert("Error", isPresented: .init(get: { viewModel.shouldDisplayError }, set: { shouldDisplay in
            if !shouldDisplay {
                viewModel.dismissError()
            }
        }), presenting: viewModel.error) { error in
            Button("OK") {
                viewModel.dismissError()
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .onChange(of: viewModel.isLoading) { old, isLoading in
            withAnimation {
                showLoadingIndicator = isLoading
            }
        }
    }
    
    init(dataProvider: PhotoDataProvider) {
        _viewModel = State(wrappedValue: ContentViewModel(provider: dataProvider))
    }
    
    @ViewBuilder
    private func gridView(photos: [PhotoItem]) -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.photos, id: \.self) { photo in
                photoCell(photo: photo)
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func photoCell(photo: PhotoItem) -> some View {
        Button(action: {
            viewModel.selectPhoto(photo: photo)
        }, label: {
            ZStack {
                Color.gray.opacity(0.25)
                AsyncImage(url: URL(string: photo.media.m)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
        })
    }
}

#Preview {
    ContentView(dataProvider: MockDataProvider())
}

