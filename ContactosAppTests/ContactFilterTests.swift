import XCTest
@testable import ContactosApp

final class ContactFilterTests: XCTestCase {
    private var sampleContacts: [Contact] {
        [
            Contact(id: "1", firstName: "Ana", lastName: "García", phone: "809-555-0101", imageURL: ""),
            Contact(id: "2", firstName: "Luis", lastName: "Martínez", phone: "809-555-0202", imageURL: ""),
            Contact(id: "3", firstName: "María", lastName: "Rodríguez", phone: "809-555-0303", imageURL: "")
        ]
    }

    func testSearchByFirstNameIsCaseInsensitive() {
        let result = ContactFilter.search(sampleContacts, query: "ana")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.firstName, "Ana")
    }

    func testSearchByLastName() {
        let result = ContactFilter.search(sampleContacts, query: "martínez")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.lastName, "Martínez")
    }

    func testSearchByPhone() {
        let result = ContactFilter.search(sampleContacts, query: "0303")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.firstName, "María")
    }

    func testEmptyQueryReturnsAllContacts() {
        let result = ContactFilter.search(sampleContacts, query: "   ")
        XCTAssertEqual(result.count, 3)
    }
}

final class ContactValidatorTests: XCTestCase {
    func testValidPhoneRequiresMinimumDigits() {
        XCTAssertTrue(ContactValidator.isValidPhone("8095550101"))
        XCTAssertFalse(ContactValidator.isValidPhone("12345"))
    }

    func testValidNamesRequireMinimumLength() {
        XCTAssertTrue(ContactValidator.isValidFirstName("Ana"))
        XCTAssertFalse(ContactValidator.isValidFirstName("A"))
        XCTAssertTrue(ContactValidator.isValidLastName("García"))
        XCTAssertFalse(ContactValidator.isValidLastName("  "))
    }

    func testDuplicatePhoneDetection() {
        let contacts = [
            Contact(id: "1", firstName: "Ana", lastName: "García", phone: "809-555-0101", imageURL: "")
        ]

        XCTAssertTrue(ContactValidator.isDuplicate(phone: "8095550101", in: contacts))
        XCTAssertFalse(ContactValidator.isDuplicate(phone: "8095550101", in: contacts, excludingID: "1"))
    }
}
