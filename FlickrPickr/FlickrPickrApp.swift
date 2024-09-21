//

import SwiftUI


@main
struct FlickrPickrApp: App {
    @Environment(\.dataProvider) var dataProvider: PhotoDataProvider

    var body: some Scene {
        WindowGroup {
            ContentView(dataProvider: dataProvider)
        }
    }
}
