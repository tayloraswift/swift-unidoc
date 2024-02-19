import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import LexicalPaths
import MarkdownABI
import MarkdownAST
import MarkdownLinking
import MarkdownParsing
import MarkdownSemantics
import SourceDiagnostics
import Sources
import SymbolGraphCompiler
import SymbolGraphs

extension SSGC
{
    /// A type that can outline autolinks from markdown documentation and
    /// statically-resolve some of the autolinks with caching.
    struct Outliner:~Copyable
    {
        private
        var resolver:OutlineResolver
        private
        var cache:Cache

        init(resolver:consuming OutlineResolver)
        {
            self.resolver = resolver
            self.cache = .init()
        }
    }
}
extension SSGC.Outliner
{
    consuming
    func diagnostics() -> Diagnostics<SSGC.Symbolicator>
    {
        self.resolver.diagnostics
    }
}
extension SSGC.Outliner
{
    private mutating
    func outline(reference:Markdown.AnyReference) -> Int?
    {
        switch reference
        {
        case .code(let link):       self.outline(link: link, code: true)
        case .link(let link):       self.outline(link: link, code: false)
        case .file(let link):       nil
        case .filePath(let text):   nil
        }
    }
    private mutating
    func outline(link:Markdown.SourceString, code:Bool) -> Int?
    {
        self.cache(link.string)
        {
            var type:SymbolGraph.Outline.Unresolved.LinkType? = nil
            if  code
            {
                if  let codelink:Codelink = .init(link.string)
                {
                    if  let outline:SymbolGraph.Outline = self.resolver.outline(codelink,
                            at: link.source)
                    {
                        return outline
                    }
                    else
                    {
                        type = .ucf
                    }
                }
            }
            else if let doclink:Doclink = .init(doc: link.string[...])
            {
                if  let outline:SymbolGraph.Outline = self.resolver.outline(doclink,
                        at: link.source)
                {
                    return outline
                }
                //  Resolution might still succeed by reinterpreting the doclink as a codelink.
                else if !doclink.absolute,
                    let codelink:Codelink = .init(doclink.path.joined(separator: "/")),
                    let outline:SymbolGraph.Outline = self.resolver.outline(codelink,
                        at: link.source)
                {
                    return outline
                }
                else
                {
                    self.resolver.diagnostics[link.source] =
                        Warning.doclinkNotStaticallyResolvable(doclink)

                    type = .doc
                }
            }

            if  let type:SymbolGraph.Outline.Unresolved.LinkType
            {
                return .unresolved(.init(
                    link: link.string,
                    type: type,
                    location: link.source.start))
            }
            else
            {
                self.resolver.diagnostics[link.source] =
                    InvalidAutolinkError<SSGC.Symbolicator>.init(link)

                return nil
            }
        }
    }
}
extension SSGC.Outliner
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
                block.traverse { $0.outline { self.outline(reference: $0) } }
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
extension SSGC.Outliner
{
    private mutating
    func link(topics:[Markdown.SemanticTopic]) -> [SymbolGraph.Topic]
    {
        topics.map
        {
            (topic:Markdown.SemanticTopic) in

            topic.traverse(members: false) { $0.outline { self.outline(reference: $0) } }

            let overview:Markdown.Bytecode = .init
            {
                topic.emit(members: false, into: &$0)
            }

            let outlines:[SymbolGraph.Outline] = self.cache.clear()

            for link:Markdown.InlineAutolink in topic.members
            {
                let _:Int? = self.outline(link: link.text, code: link.code)
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
                $0.outline { self.outline(reference: $0) }
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

            details.traverse { $0.outline { self.outline(reference: $0) } }
            details.emit(into: &binary)

            for topic:Markdown.SemanticTopic in topics
            {
                topic.traverse(members: true) { $0.outline { self.outline(reference: $0) } }
                topic.emit(members: true, into: &binary)
            }
        }
    }
}
