# ContactosApp — Prueba Técnica iOS

Aplicación iOS de **gestión de contactos** que cumple los requisitos de la prueba técnica: listado en Objective-C, formulario en SwiftUI, consumo de API pública de imágenes, arquitectura MVVM y tests.

## Descripción

Permite listar, buscar, crear y eliminar contactos con foto de perfil obtenida desde [Picsum Photos](https://picsum.photos/). La lista principal está en **Objective-C (UIKit)** y el formulario de alta en **SwiftUI**.

## Requisitos

- Xcode 15 o superior
- iOS 16.0+
- Conexión a internet (carga de imágenes desde Picsum)

## Cómo ejecutar

1. Clona el repositorio:
   ```bash
   git clone https://github.com/serforin0/testswift2.git
   cd testswift2
   ```
2. Abre el proyecto:
   ```bash
   open ContactosApp.xcodeproj
   ```
3. Selecciona un simulador iPhone.
4. Pulsa **Cmd + R** para compilar y ejecutar.

## Cómo ejecutar tests

```bash
xcodebuild test \
  -project ContactosApp.xcodeproj \
  -scheme ContactosApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

O desde Xcode: **Cmd + U**

## Arquitectura

**MVVM** con capa de datos compartida:

| Capa | Tecnología | Responsabilidad |
|------|------------|-----------------|
| Listado | Objective-C + UIKit | Tabla, búsqueda, borrado, navegación |
| Alta | SwiftUI | Formulario, imagen API, botón aleatorio |
| Core | Swift | Modelo, repositorio, servicio API, validaciones |
| Puente | Bridging Header + `@objc` | Comunicación ObjC ↔ Swift |

## Funcionalidades

### Listado (Objective-C)
- Barra de navegación: **Nuevo**, título **Contactos**, **Borrar** (modo edición)
- Barra de búsqueda por nombre, apellido o teléfono
- Tabla con imagen, nombre completo y teléfono
- Eliminación por swipe o en modo edición

### Alta (SwiftUI)
- **Cancelar** / **Guardar**
- Imagen desde Picsum (`AsyncImage`)
- Botón **Cargar imagen aleatoria**
- Campos: Nombre, Apellido, Teléfono

## API utilizada

- Imágenes: `https://picsum.photos/seed/{seed}/200`
- Servicio: `PicsumImageService` con protocolo `ImageAPIServiceProtocol` para inyección de dependencias

## Tests incluidos

### Unit Tests (`ContactosAppTests`)
- Filtro de búsqueda por nombre, apellido y teléfono
- Validación de nombres y teléfono
- Detección de teléfonos duplicados

### UI Tests (`ContactosAppUITests`)
- Flujo completo: Nuevo → Guardar → Listado
- Cancelar formulario de alta
- Búsqueda de contactos

## Persistencia

Los contactos se guardan en **UserDefaults** (JSON codificado). La app incluye 3 contactos de ejemplo al primer arranque.

## Estructura del proyecto

```
ContactosApp/
├── App/              # AppDelegate (ObjC), SceneDelegate (Swift)
├── List/             # Listado en Objective-C
├── Add/              # Formulario SwiftUI + wrapper @objc
├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Repository/
│   └── Utils/
├── ContactosAppTests/
└── ContactosAppUITests/
```

## Decisiones técnicas

- **ObjC en listado**: cumple el requisito de pantalla principal en Objective-C con `UITableView` nativo.
- **SwiftUI en alta**: formulario moderno con carga de imágenes.
- **`AddContactViewController`**: wrapper `@objc` que embebe SwiftUI vía `UIHostingController`.
- **`ContactRepository`**: singleton `@objc` accesible desde el ViewModel en ObjC.
- **DI y mocks**: `ImageAPIServiceProtocol` + `MockImageAPIService` para tests UI.
