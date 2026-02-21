import HTML
import Media
import UnidocRender
import URI

extension Unidoc {
    public protocol ConfirmationPage: StatusBearingPage, ApplicationPage, DynamicPage {
        /// The form encoding to use.
        static var encoding: MediaSubtype { get }

        /// The path to post to and pre-populated parameters to submit.
        var action: URI { get }
        /// The button text to show.
        var button: String { get }
        /// The page title to show.
        var title: String { get }

        /// Adds additional content to the form.
        func form(_ form: inout HTML.ContentEncoder, format: Unidoc.RenderFormat)
    }
}
extension Unidoc.ConfirmationPage {
    @inlinable public var status: UInt { 200 }
}
extension Unidoc.ConfirmationPage {
    /// The default form encoding, which is `application/x-www-form-urlencoded`.
    @inlinable public static var encoding: MediaSubtype { .x_www_form_urlencoded }

    public func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.header, { $0.class = "hero" }] {
            $0[.h1] = self.title
        }

        main[.form] {
            $0.enctype = "\(MediaType.application(Self.encoding))"
            $0.action = "\(self.action.path)"
            $0.method = "post"
        } content: {
            self.form(&$0, format: format)

            $0[.p] {
                $0[.button] { $0.class = "region" ; $0.type = "submit" } = self.button
            }

            guard
            let query: URI.Query = self.action.query else {
                return
            }

            for (key, value): (String, String) in query.parameters {
                $0[.input] {
                    $0.type = "hidden"
                    $0.name = key
                    $0.value = value
                }
            }
        }
    }
}
