import URI

extension Unidoc.PackageMetadataSettingsOperation {
    enum Update {
        case general(Unidoc.PackageSettings)
        case media(Unidoc.PackageMedia)
        case build(Unidoc.BuildTemplate)
    }
}
extension Unidoc.PackageMetadataSettingsOperation.Update {
    init?(type: Unidoc.PackageMetadataSettings, form: URI.QueryEncodedForm) {
        let form: [String: String] = form.parameters.reduce(into: [:]) {
            $0[$1.key] = $1.value
        }

        switch type {
        case .general:
            guard
            let settings: Unidoc.PackageSettings = .init(parameters: form) else {
                return nil
            }

            self = .general(settings)

        case .media:
            guard
            let media: Unidoc.PackageMedia = .init(parameters: form) else {
                return nil
            }

            self = .media(media)

        case .build:
            guard
            let template: Unidoc.BuildTemplate = .init(parameters: form) else {
                return nil
            }

            self = .build(template)
        }
    }
}
