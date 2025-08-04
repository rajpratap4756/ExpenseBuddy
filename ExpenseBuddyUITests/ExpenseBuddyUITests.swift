//
//  ExpenseBuddyUITests.swift
//  ExpenseBuddyUITests
//
//  Created by RajPratapSingh on 31/07/25.
//

import XCTest

final class ExpenseBuddyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor
    func testLoginFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Assuming "LoginView" is shown by default
        let emailTextField = app.textFields["Email"]
        let passwordSecureField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordSecureField.exists)
        XCTAssertTrue(loginButton.exists)

        emailTextField.tap()
        emailTextField.typeText("testuser@example.com")

        passwordSecureField.tap()
        passwordSecureField.typeText("password123")

        loginButton.tap()

        // Expect to land on Home screen
        let profileIcon = app.buttons["ProfileIcon"] // add accessibilityIdentifier in ProfileView
        XCTAssertTrue(profileIcon.waitForExistence(timeout: 5))
    }

    @MainActor
    func testAddExpenseFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Simulate already logged in state or reuse login code above

        let addButton = app.buttons["AddExpenseButton"] // set this identifier in your Add Expense button
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))

        addButton.tap()

        let titleField = app.textFields["ExpenseTitle"]
        let amountField = app.textFields["ExpenseAmount"]
        let saveButton = app.buttons["SaveExpense"]

        XCTAssertTrue(titleField.waitForExistence(timeout: 5))

        titleField.tap()
        titleField.typeText("Groceries")

        amountField.tap()
        amountField.typeText("250")

        saveButton.tap()

        // Verify if the expense appears in the list
        let newExpenseCell = app.staticTexts["Groceries"]
        XCTAssertTrue(newExpenseCell.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
