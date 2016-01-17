//
//  TelegramUITests.swift
//  TelegramUITests
//
//  Created by Markus Chmelar on 17/01/16.
//
//

import XCTest
import Foundation

// Caveats: Make sure that "Hardware -> Keyboard -> Connect hardware keyboard" is off in the Simulator Settings!
class TelegramUITests: XCTestCase {
    let phoneNumber = ""    // TODO: Enter your Phone Number here
    let userName = ""       // TODO: Enter the User-Name for Testing here
    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()
    
    let app = XCUIApplication()
    let timeout = 60.0
        
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_1_SkipOnboarding() {
        let app = XCUIApplication()
        
        // Check if we are on the "Telegram" Introduction Screen
        let initialViewTitle = app.staticTexts["Telegram"]
        XCTAssert(initialViewTitle.exists)

        // Tap the "Start Messaging" Button to skip the onboarding
        app.buttons["Start Messaging"].tap()
        
        // Check that we are on the Sign-Up Screen with a testField for our Phone Number
        XCTAssert(app.staticTexts["Your Phone"].exists)
        XCTAssert(app.textFields["Your phone number"].exists)
    }
    
    func test_2_Registration() {
        let app = XCUIApplication()
        
        // Check if we are on the "Telegram" Introduction Screen
        let initialViewTitle = app.staticTexts["Telegram"]
        XCTAssert(initialViewTitle.exists)
        
        // Skip Onboarding
        app.buttons["Start Messaging"].tap()
        
        // Open the Country Selection
        app.buttons["USA"].tap()
        
        // Choose Austria
        app.tables.staticTexts["Austria"].tap()
        
        // Enter Phone Number
        let yourPhoneNumberTextField = app.textFields["Your phone number"]
        yourPhoneNumberTextField.typeText(phoneNumber)
        app.navigationBars["TGLoginPhone"].buttons["Next"].tap()
        
        // Get Registration Token from Local Server
        guard let confirmationCode = TelegraphHelper.getConfirmationCode() else {
            XCTFail("Failed to get the Registration Token")
            return
        }
        
        // Enter Confirmation Code
        let codeTextField = app.textFields["Code"]
        let exists = NSPredicate(format: "exists == true")
        // Wait for the Confirmation Code Textfield to actually appear because it takes a while
        expectationForPredicate(exists, evaluatedWithObject: codeTextField, handler: nil)
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
        codeTextField.typeText(confirmationCode)
        
        // Assert that we are in the Chats View
        let viewTitle = app.navigationBars.staticTexts["Chats"]
        
        // Wait for the viewTitle to actually appear because it takes a while
        expectationForPredicate(exists, evaluatedWithObject: viewTitle, handler: nil)
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func test_3_ReceiveMessage() {
        let app = XCUIApplication()
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        // Check if we are on the "Chat" Screen
        let initialViewTitle = app.navigationBars.staticTexts["Chats"]
        XCTAssert(initialViewTitle.exists)
        
        // Send a Test-Message to ourself
        let message = "Testmessage \(NSDate())"
        TelegraphHelper.sendMessage(message)
        
        // Wait for the message to appear
        // This testcase is a little bit fragile.
        // We would like to just query for the message content, but because the whole Cell-Content is one single label in this app, we have to include the Time (e.g. 8:12) in the exact correct format
        let cellText = "\(dateString), \(message), \(userName)"
        let messageCell = app.tables.cells.staticTexts[cellText]
        let exists = NSPredicate(format: "exists == true")
        // Wait for the Confirmation Code Textfield to actually appear because it takes a while
        expectationForPredicate(exists, evaluatedWithObject: messageCell, handler: nil)
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
        
        // Enter the conversation
        messageCell.tap()
    }
    
    func test_4_SendMessage() {
        let app = XCUIApplication()
        
        // Check if we are on the "Chats" Screen
        let initialViewTitle = app.staticTexts["Chats"]
        XCTAssert(initialViewTitle.exists)
        
        // Click the top cell to open the chat
        app.tables.cells.elementBoundByIndex(0).tap()
        
        // Enter a message
        let message = "Testmessage \(NSDate())"
        

        
//        // Record Audio
//        // Tapping the "Record Audio Button" would work, but is not requested for the testcase
//        let button = XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(1)
//        button.tap()
//        sleep(1)
//        button.tap()
        
        
        // This does not work because the Text-Input is not a TextView (and also not TextField either), its a completely custom control that cant be selected via XCUIQuery
        let messageTextView = app.childrenMatchingType(.TextView).element
        // Test fails here because there is no TextView in the Hierarchy (also no TextField as well as no static text "Message" (which is the visible placeholder text in the field)
        // Selection as recorded with the recording feature does not work as well
        messageTextView.typeText(message)
        
        // Send the message
        app.buttons["Send"].tap()
        
        let actualMessage = TelegraphHelper.getLastMessage()
        XCTAssertEqual(message, actualMessage)
    }
    
    func test_5_CreateGroupChat() {
        let app = XCUIApplication()
        let groupName = "test \(dateFormatter.stringFromDate(NSDate()))"
        
        // Check if we are on the "Chat" Screen
        let initialViewTitle = app.navigationBars.staticTexts["Chats"]
        XCTAssert(initialViewTitle.exists)

        // Tap "New Chat"
        app.navigationBars["Chats"].buttons["Compose"].tap()
        // Tap "New Group"
        app.tables.staticTexts["New Group"].tap()
        
        // Select Members
        // This does just select the first Cell.
        // Its not possible to reliably select a cell by the users name, because the cells are custom cells and only have on text view that also oncludes the text when the user was last online
        // or when the user is currently online (e.g. "last seen 1 hour ago") and the query would have to match the whole text with the exact "last seen" text
        app.tables.cells.elementBoundByIndex(0).tap()
        
        // Tap "New Group"
        let newGroupNavigationBar = app.navigationBars["New Group"]
        newGroupNavigationBar.buttons["Next"].tap()
        
        // Enter Group-Name
        let groupNameTextField = app.collectionViews.textFields["Group Name"]
        groupNameTextField.typeText(groupName)

        // Tap "Create"
        newGroupNavigationBar.buttons["Create"].tap()
        
        // Assert that we are in the Group View
        let viewTitle = app.navigationBars.staticTexts[groupName]
        
        let exists = NSPredicate(format: "exists == true")
        // Wait for the viewTitle to actually appear because it takes a while
        expectationForPredicate(exists, evaluatedWithObject: viewTitle, handler: nil)
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
    }
}
