import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import LexicalPaths
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import UnidocDiagnostics

/// A type that can outline autolinks from markdown documentation and
/// statically-resolve some of the autolinks with caching.
struct StaticOutliner:~Copyable
{
    private
    var resolver:StaticResolver
    private
    var cache:Cache

    init(resolver:consuming StaticResolver)
    {
        self.resolver = resolver
        self.cache = .init()
    }
}
extension StaticOutliner
{
    consuming
    func diagnostics() -> DiagnosticContext<StaticSymbolicator>
    {
        (consume self).resolver.diagnostics
    }
}
extension StaticOutliner
{
    private mutating
    func outline(autolink:MarkdownInline.Autolink) -> Int?
    {
        self.cache(autolink.text)
        {
            var type:SymbolGraph.Outline.Unresolved.LinkType? = nil
            if  autolink.code
            {
                if  let codelink:Codelink = .init(autolink.text)
                {
                    if  let outline:SymbolGraph.Outline = self.resolver.outline(autolink,
                            as: codelink)
                    {
                        return outline
                    }
                    else
                    {
                        type = .ucf
                    }
                }
            }
            else if let doclink:Doclink = .init(doc: autolink.text[...])
            {
                if  let outline:SymbolGraph.Outline = self.resolver.outline(autolink,
                        as: doclink)
                {
                    return outline
                }
                //  Resolution might still succeed by reinterpreting the doclink as a codelink.
                else if !doclink.absolute,
                    let codelink:Codelink = .init(doclink.path.joined(separator: "/")),
                    let outline:SymbolGraph.Outline = self.resolver.outline(autolink,
                        as: codelink)
                {
                    return outline
                }
                else
                {
                    type = .doc
                }
            }

            if  let type:SymbolGraph.Outline.Unresolved.LinkType
            {
                return .unresolved(.init(
                    link: autolink.text,
                    type: type,
                    location: autolink.location))
            }
            else
            {
                self.resolver.diagnostics[autolink] =
                    InvalidAutolinkError<StaticSymbolicator>.init(expression: autolink.text)

                return nil
            }
        }
    }
}
extension StaticOutliner
{
    mutating
    func follow(rename renamed:String,
        of redirect:UnqualifiedPath,
        at location:SourceLocation<Int32>?) -> Int32?
    {
        self.resolver.resolve(rename: renamed, of: redirect, at: location)
    }

    mutating
    func link(attached body:MarkdownDocumentation,
        file:Int32?) -> (SymbolGraph.Article, [SymbolGraph.Topic])
    {
        let overview:MarkdownBytecode = self.link(overview: body.overview)

        let fold:Int = self.cache.fold

        let details:MarkdownBytecode = self.link(details: body.details)

        let article:SymbolGraph.Article = .init(
            outlines: self.cache.clear(),
            overview: overview,
            details: details,
            fold: fold,
            file: file)

        let topics:[SymbolGraph.Topic] = self.link(topics: body.topics)

        return (article, topics)
    }

    mutating
    func link(article body:MarkdownDocumentation,
        file:Int32?) -> SymbolGraph.Article
    {
        let overview:MarkdownBytecode = self.link(overview: body.overview)

        let fold:Int = self.cache.fold

        //  We don’t support topics lists in extension documentation.
        //  So we just render them into the article as lists of links.
        let details:MarkdownBytecode = self.link(
            details: body.details,
            topics: body.topics)

        return .init(
            outlines: self.cache.clear(),
            overview: overview,
            details: details,
            fold: fold,
            file: file)
    }

    mutating
    func link(blocks:[MarkdownBlock], file:Int32) -> SymbolGraph.Article
    {
        let rendered:MarkdownBytecode = .init
        {
            for block:MarkdownBlock in blocks
            {
                block.outline { self.outline(autolink: $0) }
                block.emit(into: &$0)
            }
        }

        return .init(
            outlines: self.cache.clear(),
            overview: rendered,
            details: [],
            fold: nil,
            file: file)
    }
}
extension StaticOutliner
{
    private mutating
    func link(topics:[MarkdownDocumentation.Topic]) -> [SymbolGraph.Topic]
    {
        topics.map
        {
            (topic:MarkdownDocumentation.Topic) in

            let overview:MarkdownBytecode = .init
            {
                (binary:inout MarkdownBinaryEncoder) in topic.visit(members: false)
                {
                    $0.outline { self.outline(autolink: $0) }
                    $0.emit(into: &binary)
                }
            }

            let outlines:[SymbolGraph.Outline] = self.cache.clear()

            for member:MarkdownInline.Autolink in topic.members
            {
                let _:Int? = self.outline(autolink: member)
            }

            let members:[SymbolGraph.Outline] = self.cache.clear()

            return .init(outlines: outlines,
                overview: overview,
                members: members)
        }
    }

    private mutating
    func link(overview:MarkdownBlock.Paragraph?) -> MarkdownBytecode
    {
        .init
        {
            (binary:inout MarkdownBinaryEncoder) in overview.map
            {
                $0.outline { self.outline(autolink: $0) }
                $0.emit(into: &binary)
            }
        }
    }

    private mutating
    func link(
        details:MarkdownDocumentation.Details,
        topics:[MarkdownDocumentation.Topic] = []) -> MarkdownBytecode
    {
        .init
        {
            (binary:inout MarkdownBinaryEncoder) in

            details.visit
            {
                $0.outline { self.outline(autolink: $0) }
                $0.emit(into: &binary)
            }

            for topic:MarkdownDocumentation.Topic in topics
            {
                topic.visit(members: true)
                {
                    $0.outline { self.outline(autolink: $0) }
                    $0.emit(into: &binary)
                }
            }
        }
    }
}
