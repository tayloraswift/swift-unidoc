import MarkdownABI

extension Unidoc {
    struct Prose {
        let outlines: [Unidoc.Outline]

        private let overview: Markdown.Bytecode?
        private let details: Markdown.Bytecode?

        private init(
            outlines: [Unidoc.Outline],
            overview: Markdown.Bytecode?,
            details: Markdown.Bytecode?
        ) {
            self.outlines = outlines
            self.overview = overview
            self.details = details
        }
    }
}
extension Unidoc.Prose {
    init(apex: __shared some Unidoc.PrincipalVertex) {
        self.init(
            outlines: apex.outlinesConcatenated,
            overview: apex.overview?.markdown,
            details: apex.details?.markdown
        )
    }
}
extension Unidoc.Prose {
    func overviewText<Context>(with context: Context) -> Unidoc.InertSection<Context>? {
        self.overview.map {
            .init(bytecode: $0, outlines: self.outlines, vertices: context)
        }
    }

    func overview(with context: any Unidoc.VertexContext) -> Unidoc.ProseSection? {
        self.overview.map {
            .init(bytecode: $0, outlines: self.outlines, context: context)
        }
    }

    func details(with context: any Unidoc.VertexContext) -> Unidoc.ProseSection? {
        self.details.map {
            .init(bytecode: $0, outlines: self.outlines, context: context)
        }
    }
}
