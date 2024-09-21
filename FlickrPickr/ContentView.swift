//
import Foundation
import SwiftUI

struct ContentView: View {
    @Environment(\.dataProvider) var dataProvider: FlickerDataProvider
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

@Observable
private final class ContentViewModel {
    let dataProvider: FlickerDataProvider
    
    init(dataProvider: FlickerDataProvider = APIClient()) {
        self.dataProvider = dataProvider
    }
    
    // Actions
    func didAppear() {
        //
    }
    
    func didDisappear() {
        //
    }
    
    func loadPhotos(tags: [String]) {
        //
    }
    
    
}

#Preview {
    ContentView()
}
