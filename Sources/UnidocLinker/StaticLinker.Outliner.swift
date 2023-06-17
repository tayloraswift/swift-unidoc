import Codelinks
import CodelinkResolution
import Doclinks
import MarkdownABI
import MarkdownTrees
import MarkdownParsing
import MarkdownSemantics
import ModuleGraphs
import Sources
import SymbolGraphs
import UnidocCompiler

extension StaticLinker
{
    struct Outliner
    {
        private(set)
        var diagnostics:[Diagnostic]

        private
        let articles:StandaloneResolver
        private
        let resolver:StaticResolver
        /// The implicit scope that will be used to resolve doclinks.
        private
        let culture:ModuleIdentifier
        /// The implicit scope that will be used to resolve codelinks.
        private
        let scope:[String]

        private
        var cache:Cache

        init(articles:StandaloneResolver,
            resolver:StaticResolver,
            culture:ModuleIdentifier,
            scope:[String])
        {
            self.diagnostics = []

            self.articles = articles
            self.resolver = resolver
            self.culture = culture
            self.scope = scope

            self.cache = .init()
        }
    }
}
extension StaticLinker.Outliner
{
    private mutating
    func outline(autolink:MarkdownInline.Autolink, in sources:[MarkdownSource]) -> UInt32?
    {
        if !autolink.code,
                let doclink:Doclink = .init(autolink.text)
        {
            return self.outline(doclink: doclink, in: sources, at: autolink.source)
        }
        else if let codelink:Codelink = .init(autolink.text)
        {
            return self.outline(codelink: codelink, in: sources, at: autolink.source)
        }
        else
        {
            self.diagnostics.append(.init(autolink.code ?
                    .invalidCodelink(autolink.text) :
                    .invalidDoclink(autolink.text),
                context: autolink.source.map { .init(of: $0, in: sources) }))
            return nil
        }
    }
    private mutating
    func outline(doclink:Doclink,
        in sources:[MarkdownSource],
        at source:SourceText<Int>?) -> UInt32?
    {
        self.cache(.doclink(doclink))
        {
            nil
        }
    }
    private mutating
    func outline(codelink:Codelink,
        in sources:[MarkdownSource],
        at source:SourceText<Int>?) -> UInt32?
    {
        self.cache(.codelink(codelink))
        {
            switch self.resolver.query(ascending: self.scope, link: codelink)
            {
            case nil:
                return .unresolved(codelink)

            case .one(let overload)?:
                switch overload.target
                {
                case .scalar(let address):
                    return .scalar(address)

                case .vector(let address, self: let heir):
                    return .vector(address, self: heir)
                }

            case .many(let overloads)?:
                self.diagnostics.append(.init(.ambiguousCodelink(codelink, overloads),
                    context: source.map { .init(of: $0, in: sources) }))
                return nil
            }
        }
    }
}
extension StaticLinker.Outliner
{
    mutating
    func link(comment:MarkdownSource,
        adding extra:[MarkdownDocumentationSupplement]? = nil) -> SymbolGraph.Article<Never>
    {
        //  TODO: use supplements
        let sources:[MarkdownSource] = [comment]
        return self.link(documentation: .init(parsing: comment.text,
                from: sources.startIndex,
                as: SwiftFlavoredMarkdownComment.self),
            from: sources)
    }
    mutating
    func link(documentation:MarkdownDocumentation,
        from sources:[MarkdownSource]) -> SymbolGraph.Article<Never>
    {
        let overview:MarkdownBytecode = .init
        {
            (binary:inout MarkdownBinaryEncoder) in

            documentation.overview.map
            {
                $0.outline
                {
                    self.outline(autolink: $0, in: sources)
                }
                $0.emit(into: &binary)
            }
        }

        let fold:Int = self.cache.referents.endIndex

        let details:MarkdownBytecode = .init
        {
            (binary:inout MarkdownBinaryEncoder) in

            documentation.details.visit
            {
                $0.outline
                {
                    self.outline(autolink: $0, in: sources)
                }
                $0.emit(into: &binary)
            }
        }
        return .init(referents: self.cache.referents,
            overview: overview,
            details: details,
            fold: fold)
    }
}
