import SwiftUI

struct AddContactView: View {
    @ObservedObject var viewModel: AddContactViewModel

    var body: some View {
        Form {
            Section("Foto de perfil") {
                HStack {
                    Spacer()
                    contactImage
                    Spacer()
                }
                .listRowBackground(Color.clear)

                Button {
                    viewModel.loadRandomImage()
                } label: {
                    Label("Cargar imagen aleatoria", systemImage: "dice.fill")
                }
                .accessibilityIdentifier("randomImageButton")
            }

            Section("Datos del contacto") {
                TextField("Nombre", text: $viewModel.firstName)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("firstNameField")

                TextField("Apellido", text: $viewModel.lastName)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("lastNameField")

                TextField("Teléfono", text: $viewModel.phone)
                    .keyboardType(.phonePad)
                    .accessibilityIdentifier("phoneField")
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
    }

    @ViewBuilder
    private var contactImage: some View {
        if let imageURL = viewModel.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 120)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 72))
                        .frame(width: 120, height: 120)
                @unknown default:
                    EmptyView()
                }
            }
            .accessibilityIdentifier("contactImage")
        } else {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
                .frame(width: 120, height: 120)
        }
    }
}

#Preview("Nuevo contacto") {
    NavigationStack {
        AddContactView(viewModel: .preview)
            .navigationTitle("Nuevo contacto")
            .navigationBarTitleDisplayMode(.inline)
    }
}
