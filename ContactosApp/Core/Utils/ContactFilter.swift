import Foundation

enum ContactFilter {
    static func search(_ contacts: [Contact], query: String) -> [Contact] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return contacts }

        let normalizedQuery = trimmed.lowercased()

        return contacts.filter { contact in
            contact.firstName.lowercased().contains(normalizedQuery)
                || contact.lastName.lowercased().contains(normalizedQuery)
                || contact.phone.lowercased().contains(normalizedQuery)
                || contact.fullName.lowercased().contains(normalizedQuery)
        }
    }
}
