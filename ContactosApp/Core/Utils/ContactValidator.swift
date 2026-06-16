import Foundation

enum ContactValidator {
    static func isValidFirstName(_ name: String) -> Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    static func isValidLastName(_ lastName: String) -> Bool {
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    static func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter(\.isNumber)
        return digits.count >= 7 && digits.count <= 15
    }

    static func isDuplicate(phone: String, in contacts: [Contact], excludingID: String? = nil) -> Bool {
        let normalized = normalizePhone(phone)
        return contacts.contains { contact in
            normalizePhone(contact.phone) == normalized && contact.id != excludingID
        }
    }

    static func normalizePhone(_ phone: String) -> String {
        phone.filter(\.isNumber)
    }
}
