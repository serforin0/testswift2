import Foundation

protocol ImageAPIServiceProtocol {
    func randomImageURL() -> URL
    func imageURL(seed: String) -> URL
}

final class PicsumImageService: ImageAPIServiceProtocol {
    func randomImageURL() -> URL {
        imageURL(seed: UUID().uuidString)
    }

    func imageURL(seed: String) -> URL {
        URL(string: "https://picsum.photos/seed/\(seed)/200")!
    }
}

final class MockImageAPIService: ImageAPIServiceProtocol {
    func randomImageURL() -> URL {
        imageURL(seed: "test-contact")
    }

    func imageURL(seed: String) -> URL {
        URL(string: "https://picsum.photos/seed/\(seed)/200")!
    }
}

enum ImageAPIServiceFactory {
    static func makeDefault() -> ImageAPIServiceProtocol {
        if ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE") {
            return MockImageAPIService()
        }
        return PicsumImageService()
    }
}
