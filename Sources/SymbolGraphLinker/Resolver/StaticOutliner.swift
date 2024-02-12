import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import LexicalPaths
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import SourceDiagnostics
import Sources
import SymbolGraphCompiler
import SymbolGraphs

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
    func diagnostics() -> Diagnostics<StaticSymbolicator>
    {
        (consume self).resolver.diagnostics
    }
}
extension StaticOutliner
{
    private mutating
    func outline(autolink:Markdown.InlineAutolink) -> Int?
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
                    location: autolink.source.start))
            }
            else
            {
                self.resolver.diagnostics[autolink.source] =
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
    func link(attached body:Markdown.SemanticDocument,
        file:Int32?) -> (SymbolGraph.Article, [SymbolGraph.Topic])
    {
        let overview:Markdown.Bytecode = self.link(overview: body.overview)

        let fold:Int = self.cache.fold

        let details:Markdown.Bytecode = self.link(details: body.details)

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
    func link(article body:Markdown.SemanticDocument,
        file:Int32?) -> SymbolGraph.Article
    {
        let overview:Markdown.Bytecode = self.link(overview: body.overview)

        let fold:Int = self.cache.fold

        //  We don’t support topics lists in extension documentation.
        //  So we just render them into the article as lists of links.
        let details:Markdown.Bytecode = self.link(
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
    func link(blocks:[Markdown.BlockElement], file:Int32) -> SymbolGraph.Article
    {
        let rendered:Markdown.Bytecode = .init
        {
            for block:Markdown.BlockElement in blocks
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
    func link(topics:[Markdown.SemanticTopic]) -> [SymbolGraph.Topic]
    {
        topics.map
        {
            (topic:Markdown.SemanticTopic) in

            let overview:Markdown.Bytecode = .init
            {
                (binary:inout Markdown.BinaryEncoder) in topic.visit(members: false)
                {
                    $0.outline { self.outline(autolink: $0) }
                    $0.emit(into: &binary)
                }
            }

            let outlines:[SymbolGraph.Outline] = self.cache.clear()

            for member:Markdown.InlineAutolink in topic.members
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
    func link(overview:Markdown.BlockParagraph?) -> Markdown.Bytecode
    {
        .init
        {
            (binary:inout Markdown.BinaryEncoder) in overview.map
            {
                $0.outline { self.outline(autolink: $0) }
                $0.emit(into: &binary)
            }
        }
    }

    private mutating
    func link(
        details:Markdown.SemanticSections,
        topics:[Markdown.SemanticTopic] = []) -> Markdown.Bytecode
    {
        .init
        {
            (binary:inout Markdown.BinaryEncoder) in

            details.visit
            {
                $0.outline { self.outline(autolink: $0) }
                $0.emit(into: &binary)
            }

            for topic:Markdown.SemanticTopic in topics
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
