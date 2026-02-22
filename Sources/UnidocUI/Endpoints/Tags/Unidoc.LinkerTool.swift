import HTML
import URI

extension Unidoc {
    struct LinkerTool {
        let form: LinkerForm
        let name: String

        init(form: LinkerForm, name: String) {
            self.form = form
            self.name = name
        }
    }
}
extension Unidoc.LinkerTool: HTML.OutputStreamable {
    static func += (form: inout HTML.ContentEncoder, self: Self) {
        form[.input] {
            $0.type = "hidden"
            $0.name = Unidoc.LinkerForm.package
            $0.value = "\(self.form.edition.package)"
        }
        form[.input] {
            $0.type = "hidden"
            $0.name = Unidoc.LinkerForm.version
            $0.value = "\(self.form.edition.version)"
        }
        form[.input] {
            $0.type = "hidden"
            $0.name = Unidoc.LinkerForm.back
            $0.value = self.form.back
        }

        form[.button] { $0.type = "submit"; $0.class = "text" } = self.name
    }
}
