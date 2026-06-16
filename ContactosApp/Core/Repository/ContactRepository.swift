import Foundation

@objc public protocol ContactRepositoryDelegate: AnyObject {
    func contactRepositoryDidChange()
}

@objc public final class ContactRepository: NSObject {
    @objc public static let shared = ContactRepository()

    @objc public weak var delegate: ContactRepositoryDelegate?

    private let storageKey = "contacts_cache_v1"
    private var contacts: [Contact] = []

    private override init() {
        super.init()
        if ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE") {
            UserDefaults.standard.removeObject(forKey: storageKey)
            contacts = Self.sampleContacts()
            persist()
        } else {
            load()
        }
    }

    @objc public func allContacts() -> [Contact] {
        contacts.sorted {
            $0.lastName.localizedCaseInsensitiveCompare($1.lastName) == .orderedAscending
                || ($0.lastName == $1.lastName
                    && $0.firstName.localizedCaseInsensitiveCompare($1.firstName) == .orderedAscending)
        }
    }

    @objc(filteredContactsMatching:)
    public func filteredContacts(matching query: String) -> [Contact] {
        ContactFilter.search(allContacts(), query: query)
    }

    @objc public func add(_ contact: Contact) {
        contacts.append(contact)
        persist()
        delegate?.contactRepositoryDidChange()
    }

    @objc public func deleteContacts(withIDs ids: [String]) {
        let idSet = Set(ids)
        contacts.removeAll { idSet.contains($0.id) }
        persist()
        delegate?.contactRepositoryDidChange()
    }

    @objc public func deleteContact(at index: Int) {
        guard index >= 0, index < contacts.count else { return }
        contacts.remove(at: index)
        persist()
        delegate?.contactRepositoryDidChange()
    }

    @objc public func contact(withID id: String) -> Contact? {
        contacts.first { $0.id == id }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Contact].self, from: data),
              !decoded.isEmpty else {
            contacts = Self.sampleContacts()
            persist()
            return
        }
        contacts = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func sampleContacts() -> [Contact] {
        [
            Contact(
                id: UUID().uuidString,
                firstName: "Ana",
                lastName: "García",
                phone: "809-555-0101",
                imageURL: PicsumImageService().imageURL(seed: "ana-garcia").absoluteString
            ),
            Contact(
                id: UUID().uuidString,
                firstName: "Luis",
                lastName: "Martínez",
                phone: "809-555-0202",
                imageURL: PicsumImageService().imageURL(seed: "luis-martinez").absoluteString
            ),
            Contact(
                id: UUID().uuidString,
                firstName: "María",
                lastName: "Rodríguez",
                phone: "809-555-0303",
                imageURL: PicsumImageService().imageURL(seed: "maria-rodriguez").absoluteString
            )
        ]
    }
}
