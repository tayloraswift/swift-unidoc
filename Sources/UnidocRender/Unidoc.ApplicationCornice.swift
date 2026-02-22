import HTML

extension Unidoc {
    @frozen public struct ApplicationCornice {
        @usableFromInline let sitename: String
        @usableFromInline let username: String?

        @inlinable init(sitename: String, username: String?) {
            self.sitename = sitename
            self.username = username
        }
    }
}
extension Unidoc.ApplicationCornice: HTML.OutputStreamable {
    @inlinable public static func += (nav: inout HTML.ContentEncoder, self: Self) {
        nav[.div] {
            $0[.a] { $0.href = "/" } = self.sitename
        }
        nav[.div] {
            if  let username: String = self.username {
                $0[.a] { $0.href = "\(Unidoc.ServerRoot.account)" } = username
            } else {
                $0[.a] { $0.href = "\(Unidoc.ServerRoot.login)" } = "login"
            }
        }
    }
}
