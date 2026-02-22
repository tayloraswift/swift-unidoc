import HTML
import Media
import UnidocRender
import URI

extension Unidoc {
    struct _RecodePage {
        init() {
        }
    }
}
extension Unidoc._RecodePage {
    static var name: String { "recode" }

    static var uri: URI { Unidoc.ServerRoot.admin / Self.name }
}
extension Unidoc._RecodePage: Unidoc.StatusBearingPage {
    var status: UInt { 200 }
}
extension Unidoc._RecodePage: Unidoc.RenderablePage {
    var title: String { "Schema · Administrator Tools" }
}
extension Unidoc._RecodePage: Unidoc.StaticPage {
    var location: URI { Self.uri }
}
extension Unidoc._RecodePage: Unidoc.AdministrativePage {
    func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.h1] = "Manage Schema"
        main[.ul] {
            for target: Target in Target.allCases {
                $0[.li] {
                    $0[.form] {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(target.location)"
                        $0.method = "get"
                    } content: {
                        $0[.p] {
                            $0[.button] { $0.type = "submit" } = "Recode \(target.label)"
                        }
                    }
                }
            }
        }
    }
}
