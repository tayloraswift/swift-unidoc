import HTML
import Media
import Symbols
import URI

extension Unidoc {
    struct BuildRequestPage {
        let form: BuildForm
        let action: URI

        init(form: BuildForm, action: URI) {
            self.form = form
            self.action = action
        }
    }
}
extension Unidoc.BuildRequestPage: Unidoc.ConfirmationPage {
    var button: String { self.form.action == .cancel ? "Cancel build" : "Build package" }
    var title: String { self.form.action == .cancel ? "Cancel build?" : "Build package?" }

    func form(_ form: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        form[.p] {
            let package: URI = Unidoc.RefsEndpoint[self.form.symbol.package]
            switch self.form.action {
            case .cancel:
                $0 += "You can cancel the build for "
                $0[.a] { $0.href = "\(package)" } = "\(self.form.symbol.package)"
                $0 += " if it has not started yet."

            case .submit:
                $0 += "A builder will build the package "
                $0[.a] { $0.href = "\(package)" } = "\(self.form.symbol.package)"
                $0 += " at "
                $0[.code] = "\(self.form.symbol.ref)"
                $0 += """
                 once one becomes available. If you move the ref in the meantime, it might \
                build the new commit instead.
                """
            }
        }

        if  case .cancel = self.form.action {
            return
        }

        form[.p] {
            $0[.label] {
                $0.class = "checkbox"
                $0.title = "Build the selected version even if it already has a symbol graph."
            } content: {
                $0[.input] {
                    $0.type = "checkbox"
                    $0.name = "force"
                    $0.checked = true
                    $0.value = "true"
                }

                $0[.span] = "Force rebuild of existing documentation"
            }
        }
    }
}
