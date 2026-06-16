import Foundation
import Combine

@MainActor
final class AddContactViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var imageURL: URL?
    @Published var errorMessage: String?

    var onFormChanged: (() -> Void)?

    private let imageService: ImageAPIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        imageService: ImageAPIServiceProtocol = ImageAPIServiceFactory.makeDefault(),
        loadsInitialImage: Bool = true
    ) {
        self.imageService = imageService
        bindFormChanges()
        if loadsInitialImage {
            loadRandomImage()
        }
    }

    static var preview: AddContactViewModel {
        let viewModel = AddContactViewModel(loadsInitialImage: false)
        viewModel.firstName = "Ana"
        viewModel.lastName = "García"
        viewModel.phone = "809-555-0101"
        return viewModel
    }

    private func bindFormChanges() {
        Publishers.CombineLatest3($firstName, $lastName, $phone)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.onFormChanged?()
            }
            .store(in: &cancellables)
    }

    var canSave: Bool {
        ContactValidator.isValidFirstName(firstName)
            && ContactValidator.isValidLastName(lastName)
            && ContactValidator.isValidPhone(phone)
    }

    func loadRandomImage() {
        imageURL = imageService.randomImageURL()
        errorMessage = nil
    }

    func makeContact() -> Contact? {
        guard canSave else { return nil }

        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if ContactValidator.isDuplicate(phone: trimmedPhone, in: ContactRepository.shared.allContacts()) {
            errorMessage = "Ya existe un contacto con este teléfono."
            return nil
        }

        return Contact(
            id: UUID().uuidString,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: trimmedPhone,
            imageURL: imageURL?.absoluteString ?? ""
        )
    }
}
