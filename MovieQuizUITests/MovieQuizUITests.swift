import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

//    func testYesButton() throws {
//        sleep(3)
//
//        let firstPoster = app.images["Poster"]
//        let firstPosterData = firstPoster.screenshot().pngRepresentation
//
//        app.buttons["Yes"].tap()
//        sleep(3)
//
//        let secondPoster = app.images["Poster"]
//        let secondPosterData = secondPoster.screenshot().pngRepresentation
//
//        XCTAssertNotEqual(firstPosterData, secondPosterData)
//    }
    
    func testNoButton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testAlertExists() throws {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }

        let alert = app.alerts["Results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual("Этот раунд окончен!", alert.label)
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testAlertClose() throws {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Results"]
        sleep(1)
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        
        let text = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(text.label, "1/10")
    }

}
