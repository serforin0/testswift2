import XCTest

final class ContactFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TEST_MODE"]
        app.launch()
    }

    func testCreateContactAndSeeItInList() throws {
        XCTAssertTrue(app.navigationBars["Contactos"].waitForExistence(timeout: 5))

        app.navigationBars.buttons["Nuevo"].tap()
        XCTAssertTrue(app.navigationBars["Nuevo contacto"].waitForExistence(timeout: 3))

        typeText("Pedro", into: app.textFields["firstNameField"])
        typeText("Lopez", into: app.textFields["lastNameField"])
        typeText("8095559876", into: app.textFields["phoneField"])

        XCTAssertTrue(app.navigationBars.buttons["Guardar"].isEnabled)
        app.navigationBars.buttons["Guardar"].tap()

        XCTAssertTrue(app.navigationBars["Contactos"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tables.cells.containing(NSPredicate(format: "label CONTAINS %@", "Pedro Lopez")).firstMatch.waitForExistence(timeout: 5))
    }

    func testCancelContactCreation() throws {
        app.navigationBars.buttons["Nuevo"].tap()
        XCTAssertTrue(app.navigationBars["Nuevo contacto"].waitForExistence(timeout: 3))

        app.navigationBars.buttons["Cancelar"].tap()
        XCTAssertTrue(app.navigationBars["Contactos"].waitForExistence(timeout: 3))
    }

    func testSearchContacts() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        searchField.tap()
        searchField.typeText("Ana")

        XCTAssertTrue(app.staticTexts["Ana García"].waitForExistence(timeout: 3))
    }

    private func typeText(_ text: String, into field: XCUIElement) {
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.doubleTap()

        if let currentValue = field.value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            field.typeText(deleteString)
        }

        field.typeText(text)
    }
}
