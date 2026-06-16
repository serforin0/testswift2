import Foundation

@objc public class Contact: NSObject, Codable {
    @objc public let id: String
    @objc public var firstName: String
    @objc public var lastName: String
    @objc public var phone: String
    @objc public var imageURL: String

    @objc public init(
        id: String,
        firstName: String,
        lastName: String,
        phone: String,
        imageURL: String
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.imageURL = imageURL
    }

    @objc public var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, phone, imageURL
    }
}
