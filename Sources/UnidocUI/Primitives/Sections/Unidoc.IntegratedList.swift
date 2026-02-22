import HTML

extension Unidoc {
    struct IntegratedList {
        private let context: Unidoc.InternalPageContext
        private let items: [Unidoc.Scalar]

        private init(context: Unidoc.InternalPageContext, items: [Unidoc.Scalar]) {
            self.context = context
            self.items = items
        }
    }
}
extension Unidoc.IntegratedList {
    init?(items: [Unidoc.Scalar], with context: Unidoc.InternalPageContext) {
        if  items.isEmpty {
            return nil
        }

        self.init(context: context, items: items)
    }
}
extension Unidoc.IntegratedList: Unidoc.CollapsibleContent {
    var length: Int { self.items.count }
    var count: Int { self.items.count }
}
extension Unidoc.IntegratedList: HTML.OutputStreamable {
    static func += (section: inout HTML.ContentEncoder, self: Self) {
        section[.ul, { $0.class = "cards" }] {
            for item: Unidoc.Scalar in self.items {
                $0[.li] = self.context.card(item)
            }
        }
    }
}
