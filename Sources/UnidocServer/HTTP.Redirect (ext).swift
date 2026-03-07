import HTTP
import Unidoc
import UnidocRender

extension HTTP.Redirect {
    @inlinable public static var login: Self { .temporary("\(Unidoc.ServerRoot.login)") }
}
