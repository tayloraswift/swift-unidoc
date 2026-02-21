import HTML

extension Unidoc {
    struct DisabledButton {
        let label: String
        let view: Unidoc.Permissions
        let area: Bool

        init(label: String, view: Unidoc.Permissions, area: Bool = true) {
            self.label = label
            self.view = view
            self.area = area
        }
    }
}
extension Unidoc.DisabledButton: HTML.OutputStreamable {
    static func += (form: inout HTML.ContentEncoder, self: Self) {
        form[.button] {
            $0.title = self.view.authenticated
                ? "You are not an editor of this package!"
                : "You are not logged in!"

            $0.class = self.area ? "region" : "text"
            $0.disabled = true
        } = self.label
    }
}
