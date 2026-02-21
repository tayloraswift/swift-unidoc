import HTML
import Symbols
import UnidocRecords

extension Unidoc {
    struct BuildFormTool {
        let form: BuildForm
        let area: BuildButton
        let disabled: Inhibitor?

        init(form: BuildForm, area: BuildButton, disabled: Inhibitor? = nil) {
            self.form = form
            self.area = area
            self.disabled = disabled
        }
    }
}
extension Unidoc.BuildFormTool {
    static func shortcut(
        buildable: String?,
        submitted: Bool,
        package: Symbol.Package,
        label: String,
        view: Unidoc.Permissions
    ) -> Self {
        let area: Unidoc.BuildButton = .init(text: label, type: .region)

        guard
        let buildable: String else {
            //  Use the empty string for the ref, as the form should not be submittable at all.
            return .init(
                form: .init(
                    symbol: .init(package: package, ref: ""),
                    action: .submit
                ),
                area: area,
                disabled: .unavailable
            )
        }

        let form: Unidoc.BuildForm = .init(
            symbol: .init(package: package, ref: buildable),
            action: .submit
        )

        if  submitted {
            return .init(form: form, area: area, disabled: .alreadySubmitted)
        }

        guard view.authenticated else {
            return .init(form: form, area: area, disabled: .unauthenticated)
        }

        guard view.editor else {
            return .init(form: form, area: area, disabled: .unauthorized)
        }

        return .init(form: form, area: area)
    }

    static func control(pending build: Unidoc.PendingBuild, view: Unidoc.Permissions) -> Self {
        let area: Unidoc.BuildButton = .init(text: nil, type: .inline)
        let form: Unidoc.BuildForm = .init(symbol: build.name, action: .cancel)

        guard case nil = build.launched else {
            return .init(form: form, area: area, disabled: .alreadyStarted)
        }

        guard view.authenticated else {
            return .init(form: form, area: area, disabled: .unauthenticated)
        }

        guard view.editor else {
            return .init(form: form, area: area, disabled: .unauthorized)
        }

        return .init(form: form, area: area)
    }
}
extension Unidoc.BuildFormTool: HTML.OutputStreamable {
    static func += (form: inout HTML.ContentEncoder, self: Self) {
        form[.input] {
            $0.type = "hidden"
            $0.name = Unidoc.BuildForm.symbol
            $0.value = "\(self.form.symbol)"
        }

        form[.input] {
            $0.type = "hidden"
            $0.name = Unidoc.BuildForm.action
            $0.value = "\(self.form.action)"
        }

        let label: String

        switch self.form.action {
        case .submit:   label = self.area.text ?? "Request build"
        case .cancel:   label = self.area.text ?? "Cancel build"
        }

        form[.button] {
            switch self.area.type {
            case .inline:   $0.class = "text"
            case .region:   $0.class = "region"
            }

            $0.type = "submit"

            guard
            let inhibitor: Inhibitor = self.disabled else {
                return
            }

            $0.disabled = true

            switch inhibitor {
            case .alreadyStarted:   $0.title = "This build has already started!"
            case .alreadySubmitted: $0.title = "This build has already been queued!"
            case .unauthenticated:  $0.title = "You are not logged in!"
            case .unauthorized:     $0.title = "You are not an editor of this package!"
            case .unavailable:      $0.title = "This repository does not have such a tag yet!"
            }
        } = label
    }
}
