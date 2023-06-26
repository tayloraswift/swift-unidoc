import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import MarkdownABI
import MarkdownTrees
import MarkdownParsing
import MarkdownSemantics
import ModuleGraphs
import SymbolGraphs
import UnidocCompiler
import UnidocDiagnostics

/// A type that can outline autolinks from markdown documentation and
/// statically-resolve some of the autolinks with caching.
struct StaticOutliner
{
    private
    var resolver:StaticResolver
    private
    var cache:Cache

    init(resolver:StaticResolver)
    {
        self.resolver = resolver
        self.cache = .init()
    }
}
extension StaticOutliner
{
    init(codelinks:CodelinkResolver<Int32>.Table,
        doclinks:DoclinkResolver.Table,
        imports:[ModuleIdentifier],
        namespace:ModuleIdentifier? = nil,
        culture:ModuleIdentifier,
        scope:[String] = [])
    {
        self.init(resolver: .init(
            codelinks: .init(table: codelinks, scope: .init(
                namespace: namespace ?? culture,
                imports: imports,
                path: scope)),
            doclinks: .init(table: doclinks, scope: .documentation(culture))))
    }
}
extension StaticOutliner
{
    var diagnoses:[any StaticDiagnosis]
    {
        self.resolver.diagnoses
    }
}
extension StaticOutliner
{
    private mutating
    func outline(autolink:MarkdownInline.Autolink, in sources:[MarkdownSource]) -> UInt32?
    {
        self.cache(autolink.text)
        {
            if      let doclink:Doclink = .init(autolink.text)
            {
                return self.resolver.outline(expression: autolink.text,
                    as: doclink,
                    in: sources,
                    at: autolink.source)
            }
            else if let codelink:Codelink = .init(autolink.text)
            {
                return self.resolver.outline(expression: autolink.text,
                    as: codelink,
                    in: sources,
                    at: autolink.source)
            }
            else
            {
                self.resolver.diagnoses.append(InvalidAutolinkError<Int32>.init(
                    expression: autolink.text,
                    context: autolink.source.map { .init(of: $0, in: sources) }))
                return nil
            }
        }
    }
}
extension StaticOutliner
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
