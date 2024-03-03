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

extension SSGC
{
    /// A type that can outline autolinks from markdown documentation and
    /// statically-resolve some of the autolinks with caching.
    @_spi(testable) public
    struct Outliner:~Copyable
    {
        private
        let resources:[String: SSGC.Resource]
        private
        var resolver:OutlineResolver
        private
        var cache:Cache

        init(resources:[String: SSGC.Resource], resolver:consuming OutlineResolver)
        {
            self.resources = resources
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
    private
    func locate(resource name:String) -> SSGC.Resource?
    {
        if  let resource:SSGC.Resource = self.resources[name]
        {
            return resource
        }

        if  let dot:String.Index = name.lastIndex(of: ".")
        {
            //  We can only fuzz file names for image resources!
            switch name[name.index(after: dot)...]
            {
            case "gif":     break
            case "jpg":     break
            case "jpeg":    break
            case "png":     break
            case "svg":     break
            case "webp":    break
            default:        return nil
            }

            return self.resources["\(name[..<dot])@2x\(name[dot...])"]
                ?? self.resources["\(name[..<dot])~dark\(name[dot...])"]
                ?? self.resources["\(name[..<dot])~dark@2x\(name[dot...])"]
        }
        for guess:String in ["svg", "webp", "png", "jpg", "jpeg", "gif"]
        {
            if  let resource:SSGC.Resource = self.resources["\(name).\(guess)"]
                ?? self.resources["\(name)@2x.\(guess)"]
                ?? self.resources["\(name)~dark.\(guess)"]
                ?? self.resources["\(name)~dark@2x.\(guess)"]
            {
                return resource
            }
        }

        return nil
    }
}
extension SSGC.Outliner
{
    @_spi(testable)
    public mutating
    func outlines() -> [SymbolGraph.Outline]
    {
        self.cache.clear()
    }

    @_spi(testable)
    public mutating
    func outline(reference:Markdown.AnyReference) -> Int?
    {
        let name:Markdown.SourceString

        switch reference
        {
        case .code(let link):
            return self.outline(link: link, code: true)

        case .link(let link):
            guard
            let colon:String.Index = link.string.firstIndex(of: ":")
            else
            {
                return self.outline(link: link, code: false)
            }

            switch link.string[..<colon]
            {
            case "doc":
                let trimmed:String = .init(link.string[link.string.index(after: colon)...])
                let link:Markdown.SourceString = .init(
                    source: link.source,
                    string: trimmed)

                return self.outline(link: link, code: false)

            case "http", "https":
                guard
                let start:String.Index = link.string.index(colon,
                    offsetBy: 3,
                    limitedBy: link.string.endIndex)
                else
                {
                    break
                }

                return self.outline(translating: link, to: link.string[start...])

            default:
                break
            }

            self.resolver.diagnostics[link.source] =
                SSGC.AutolinkParsingError<SSGC.Symbolicator>.init(link)

            return nil

        case .file(let link):
            name = link

        case .filePath(let link):
            //  Right now we don’t have a better way to handle file paths.
            guard
            let i:String.Index = link.string.lastIndex(of: "/")
            else
            {
                name = link
                break
            }

            name = .init(
                source: link.source,
                string: String.init(link.string[link.string.index(after: i)...]))

        case .location(let location):
            //  This is almost a no-op, except we can optimize away duplicated locations.
            return self.cache.add(outline: .location(location))
        }

        if  let resource:SSGC.Resource = self.locate(resource: name.string)
        {
            //  Historical note: we used to encode this as a vertex outline.
            return self.cache.add(
                outline: .location(.init(position: .zero, file: resource.id)))
        }

        self.resolver.diagnostics[name.source] = SSGC.ResourceError.fileNotFound(name.string)
        return nil
    }

    private mutating
    func outline(translating link:Markdown.SourceString, to url:Substring) -> Int?
    {
        self.cache.add(outline: .unresolved(web: String.init(url),
            location: link.source.start))
    }

    private mutating
    func outline(link:Markdown.SourceString, code:Bool) -> Int?
    {
        self.cache(link.string)
        {
            resolution:
            if  code
            {
                guard
                let codelink:Codelink = .init(link.string)
                else
                {
                    break resolution
                }

                if  let outline:SymbolGraph.Outline = self.resolver.outline(codelink,
                        at: link.source)
                {
                    return outline
                }

                return .unresolved(ucf: link.string, location: link.source.start)
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

                self.resolver.diagnostics[link.source] =
                    Warning.doclinkNotStaticallyResolvable(doclink)

                return .unresolved(doc: link.string, location: link.source.start)
            }

            self.resolver.diagnostics[link.source] =
                SSGC.AutolinkParsingError<SSGC.Symbolicator>.init(link)

            return nil
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
    func link(
        body:Markdown.SemanticDocument,
        file:Int32?) -> (SymbolGraph.Article, [[Int32]])
    {
        let overview:Markdown.Bytecode

        if  let paragraph:Markdown.BlockParagraph = body.overview
        {
            overview = .init
            {
                paragraph.outline { self.outline(reference: $0) }
                paragraph.emit(into: &$0)
            }
        }
        else
        {
            overview = []
        }

        let fold:Int = self.cache.fold

        let details:Markdown.Bytecode = .init
        {
            (binary:inout Markdown.BinaryEncoder) in

            body.details.traverse { $0.outline { self.outline(reference: $0) } }
            body.details.emit(into: &binary)
        }

        let article:SymbolGraph.Article = .init(
            outlines: self.cache.clear(),
            overview: overview,
            details: details,
            fold: fold,
            file: file,
            footer: body.containsSeeAlso ? .omit : nil)

        var topics:[[Int32]] = []
            topics.reserveCapacity(body.topics.count)

        for topic:Markdown.BlockTopic in body.topics
        {
            let topic:[Int32] = topic.items.reduce(into: [])
            {
                guard
                case .outlined(let reference) = $1
                else
                {
                    return
                }
                switch article.outlines[reference]
                {
                case .vertex(let id, text: _):          $0.append(id)
                case .vector(let id, self: _, text: _): $0.append(id)
                default:                                return
                }
            }
            //  Single-item topics are worthless as curator groups.
            if  topic.count > 1
            {
                topics.append(topic)
            }
        }

        return (article, topics)
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
