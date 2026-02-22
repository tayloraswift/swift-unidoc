import UnidocRecords

extension Unidoc.Mesh {
    @frozen public struct Vertices: Sendable {
        public let landing: Unidoc.LandingVertex

        public var articles: [Unidoc.ArticleVertex]
        public var cultures: [Unidoc.CultureVertex]
        public var decls: [Unidoc.DeclVertex]
        public var files: [Unidoc.FileVertex]
        public var products: [Unidoc.ProductVertex]
        public var foreign: [Unidoc.ForeignVertex]

        @inlinable public init(
            landing: Unidoc.LandingVertex,
            articles: [Unidoc.ArticleVertex] = [],
            cultures: [Unidoc.CultureVertex] = [],
            decls: [Unidoc.DeclVertex] = [],
            files: [Unidoc.FileVertex] = [],
            products: [Unidoc.ProductVertex] = [],
            foreign: [Unidoc.ForeignVertex] = []
        ) {
            self.landing = landing

            self.articles = articles
            self.cultures = cultures
            self.decls = decls
            self.files = files
            self.products = products
            self.foreign = foreign
        }
    }
}
