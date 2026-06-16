import SwiftUI
import UIKit

@objc public final class AddContactViewController: UIViewController {
    @objc public var onSave: ((Contact) -> Void)?
    @objc public var onCancel: (() -> Void)?

    private let viewModel = AddContactViewModel()
    private var saveButton: UIBarButtonItem?

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nuevo contacto"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancelar",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "cancelButton"

        saveButton = UIBarButtonItem(
            title: "Guardar",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        saveButton?.isEnabled = false
        saveButton?.accessibilityIdentifier = "saveButton"
        navigationItem.rightBarButtonItem = saveButton

        viewModel.onFormChanged = { [weak self] in
            self?.saveButton?.isEnabled = self?.viewModel.canSave == true
        }

        let rootView = AddContactView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func saveTapped() {
        guard let contact = viewModel.makeContact() else { return }
        onSave?(contact)
    }
}
