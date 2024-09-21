# FlickrPickr

FlickrPickr is a simple photo search client built with SwiftUI, featuring a minimal network client framework. It's designed around URLSession and uses a generic dataProvider abstraction for the app's view models.

## Requirements

- Xcode 16 or later (Download from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12))
- iOS 18.0 or later
- Swift 5.9 or later

## Features

- Search for photos using Flickr's public feed
- Display search results in a grid layout
- View detailed information about each photo
- Share photos directly from the app

## Architecture

The app is built with the following key components:

- **NetworkClient**: A lightweight networking framework built around URLSession
- **FlickrClient**: Implements the PhotoDataProvider protocol to fetch photos from Flickr
- **ContentViewModel**: Manages the app's state and business logic
- **ContentView**: The main view of the app, displaying the search interface and photo grid
- **ContentDetailView**: Displays detailed information about a selected photo

## Running the Project

To build and run the tests, use the following command:

```bash
xcodebuild -scheme FlickrPickr -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test