import Symbols
import UnidocRecords

extension Unidoc {
    struct TreeMembers {
        var articles: [Unidoc.Noun]
        var types: [Unidoc.Shoot: (Unidoc.Citizenship, Phylum.DeclFlags)]
        var extra: [(Unidoc.Shoot, TreeMapper.Flags?)]

        private init(
            articles: [Unidoc.Noun],
            types: [Unidoc.Shoot: (Unidoc.Citizenship, Phylum.DeclFlags)],
            extra: [(Unidoc.Shoot, TreeMapper.Flags?)] = []
        ) {
            self.articles = articles
            self.types = types
            self.extra = extra
        }
    }
}
extension Unidoc.TreeMembers: ExpressibleByArrayLiteral {
    init(arrayLiteral: Never...) {
        self.init(articles: [], types: [:], extra: [])
    }
}
