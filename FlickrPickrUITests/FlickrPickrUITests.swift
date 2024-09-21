//

import Foundation
import XCTest


class FlickrPickrUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["DATA_PROVIDER_ENV"] = "TEST_ENVIRONMENT"
        app.launch()
    }
    
    func testSearchAndPhotoDetailView() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")
        
        searchField.tap()
        searchField.typeText("dog\n")
        
        let cellsExist = app.scrollViews.buttons.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(cellsExist, "Search results should appear")
        
        XCTAssertGreaterThan(app.scrollViews.buttons.count, 0, "There should be search results")
                
        let firstCell = app.scrollViews.buttons.firstMatch
        XCTAssertTrue(firstCell.exists, "First cell should exist")
        firstCell.tap()
        
        let navBarTitle = app.navigationBars.staticTexts.firstMatch
        XCTAssertTrue(navBarTitle.waitForExistence(timeout: 5), "Navigation bar title should exist in detail view")
        XCTAssertEqual(navBarTitle.label, "Test Title")

        let shareButton = app.buttons["Share"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 5), "Share button should exist in detail view")
        
        let titleText = app.staticTexts["Title"].firstMatch
        XCTAssertTrue(titleText.waitForExistence(timeout: 5), "Title should exist in detail view")
        XCTAssertEqual(titleText.value as? String, "Test Title")
        
        let descText = app.staticTexts["Description"].firstMatch
        XCTAssertTrue(descText.waitForExistence(timeout: 5), "Description should exist in detail view")
        XCTAssertEqual(descText.value as? String, "Test description.")
        
        let authorText = app.staticTexts["Author"].firstMatch
        XCTAssertTrue(authorText.waitForExistence(timeout: 5), "Author should exist in detail view")
        XCTAssertEqual(authorText.value as? String, "Aaron Alexander")
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
