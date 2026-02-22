import HTML

extension Unidoc {
    struct UserCard<Tools> {
        let id: Account
        let symbol: String?
        let icon: String?
        let tools: Tools?

        init(id: Account, symbol: String?, icon: String?, tools: Tools? = nil) {
            self.id = id
            self.symbol = symbol
            self.icon = icon
            self.tools = tools
        }
    }
}
extension Unidoc.UserCard: HTML.OutputStreamable where Tools: HTML.OutputStreamable {
    static func += (li: inout HTML.ContentEncoder, self: Self) {
        li[.header] {
            if  let icon: String = self.icon {
                $0[.img] { $0.class = "icon" ; $0.src = icon }
            } else {
                $0[.div] { $0.class = "icon" }
            }

            $0[.a] {
                $0.href = "\(Unidoc.UserPropertyEndpoint[self.id])"
            } = self.symbol ?? "(automated user)"

            $0[.div] { $0.class = "tools" } = self.tools
        }
    }
}
