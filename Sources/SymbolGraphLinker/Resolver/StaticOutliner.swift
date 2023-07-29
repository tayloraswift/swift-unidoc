import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import MarkdownABI
import MarkdownTrees
import MarkdownParsing
import MarkdownSemantics
import ModuleGraphs
import SymbolGraphCompiler
import SymbolGraphs
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
    var errors:[any StaticLinkerError]
    {
        self.resolver.errors
    }
}
extension StaticOutliner
{
    private mutating
    func outline(autolink:MarkdownInline.Autolink, in sources:[MarkdownSource]) -> Int?
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
                self.resolver.errors.append(InvalidAutolinkError<Int32>.init(
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
        parser:SwiftFlavoredMarkdownParser,
        adding extra:[MarkdownSupplement]? = nil) -> SymbolGraph.Article<Never>
    {
        //  TODO: use supplements
        let sources:[MarkdownSource] = [comment]
        return self.link(body: .init(parsing: comment.text,
                from: sources.startIndex,
                with: parser,
                as: SwiftFlavoredMarkdownComment.self),
            from: sources)
    }
    mutating
    func link(
        title:MarkdownBlock.Heading? = nil,
        body:MarkdownDocumentation,
        from sources:[MarkdownSource]) -> SymbolGraph.Article<Never>
    {
        //  No links in the headline!
        let headline:MarkdownBytecode = .init
        {
            //  Don’t emit the enclosing `h1` tag!
            for element:MarkdownInline.Block in title?.elements ?? []
            {
                element.emit(into: &$0)
            }
        }
        let overview:MarkdownBytecode = self.link(
            overview: body.overview,
            from: sources)

        let fold:Int = self.cache.fold

        //  We don’t support topics lists in non-module documentation.
        //  So we just render them into the article as lists of links.
        let details:MarkdownBytecode = self.link(
            details: body.details,
            topics: body.topics,
            from: sources)

        return .init(
            headline: headline,
            outlines: self.cache.clear(),
            overview: overview,
            details: details,
            fold: fold)
    }
    mutating
    func link(topics:[MarkdownDocumentation.Topic],
        from sources:[MarkdownSource]) -> [SymbolGraph.Topic]
    {
        topics.map
        {
            (topic:MarkdownDocumentation.Topic) in

            let overview:MarkdownBytecode = .init
            {
                (binary:inout MarkdownBinaryEncoder) in topic.visit(members: false)
                {
                    $0.outline { self.outline(autolink: $0, in: sources) }
                    $0.emit(into: &binary)
                }
            }

            let outlines:[SymbolGraph.Outline] = self.cache.clear()

            for member:MarkdownInline.Autolink in topic.members
            {
                let _:Int? = self.outline(autolink: member, in: sources)
            }

            let members:[SymbolGraph.Outline] = self.cache.clear()

            return .init(outlines: outlines,
                overview: overview,
                members: members)
        }
    }

    private mutating
    func link(overview:MarkdownBlock.Paragraph?,
        from sources:[MarkdownSource]) -> MarkdownBytecode
    {
        .init
        {
            (binary:inout MarkdownBinaryEncoder) in overview.map
            {
                $0.outline { self.outline(autolink: $0, in: sources) }
                $0.emit(into: &binary)
            }
        }
    }
    private mutating
    func link(
        details:MarkdownDocumentation.Details,
        topics:[MarkdownDocumentation.Topic],
        from sources:[MarkdownSource]) -> MarkdownBytecode
    {
        .init
        {
            (binary:inout MarkdownBinaryEncoder) in

            details.visit
            {
                $0.outline { self.outline(autolink: $0, in: sources) }
                $0.emit(into: &binary)
            }

            for topic:MarkdownDocumentation.Topic in topics
            {
                topic.visit(members: true)
                {
                    $0.outline { self.outline(autolink: $0, in: sources) }
                    $0.emit(into: &binary)
                }
            }
        }
    }
}
