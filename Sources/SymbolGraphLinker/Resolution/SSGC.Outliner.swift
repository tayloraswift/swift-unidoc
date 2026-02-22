import LexicalPaths
import LinkResolution
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import SourceDiagnostics
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import UCF

extension SSGC {
    /// A type that can outline autolinks from markdown documentation and
    /// statically-resolve some of the autolinks with caching.
    @_spi(testable) public struct Outliner: ~Copyable {
        private(set) var resolver: OutlineResolver
        private var cache: Cache

        init(resolver: consuming OutlineResolver) {
            self.resolver = resolver
            self.cache = .init()
        }
    }
}
extension SSGC.Outliner {
    consuming func move() -> SSGC.Linker.Tables { self.resolver.tables }
}

extension SSGC.Outliner {
    @_spi(testable) public mutating func outlines() -> [SymbolGraph.Outline] {
        self.cache.clear()
    }

    @_spi(testable) public mutating func outline(reference: Markdown.AnyReference) -> Int? {
        let name: Markdown.SourceString

        switch reference {
        case .symbolic(usr: let usr):
            return self.outline(symbol: usr)

        case .lexical(ucf: let expression):
            return self.outline(ucf: expression)

        case .link(url: let url):
            switch url.scheme {
            case nil, "doc"?:
                return self.outline(doc: url.suffix, as: url.provenance)

            case let scheme?:
                return self.outline(url: url, scheme: scheme)
            }

        case .file(let link):
            name = link

        case .filePath(let link):
            //  Right now we don’t have a better way to handle file paths.
            guard
            let i: String.Index = link.string.lastIndex(of: "/") else {
                name = link
                break
            }

            name = .init(
                source: link.source,
                string: String.init(link.string[link.string.index(after: i)...])
            )

        case .location(let location):
            //  This is almost a no-op, except we can optimize away duplicated locations.
            return self.cache.add(outline: .location(location))
        }

        if  let resource: SSGC.Resource = self.resolver.locate(resource: name.string) {
            //  Historical note: we used to encode this as a vertex outline.
            return self.cache.add(
                outline: .location(.init(position: .zero, file: resource.id))
            )
        }

        self.resolver.diagnostics[name.source] = SSGC.ResourceError.fileNotFound(name.string)
        return nil
    }

    private mutating func outline(url: Markdown.SourceURL, scheme: String) -> Int? {
        let translated: SymbolGraph.Outline?

        switch scheme {
        case "http":    translated = self.resolver.translate(url: url)
        case "https":   translated = self.resolver.translate(url: url)
        default:        translated = nil
        }

        //  TODO: log translations?

        return self.cache.add(
            outline: translated ?? .url(
                "\(scheme):\(url.suffix)",
                location: url.suffix.source.start
            )
        )
    }

    private mutating func outline(ucf link: Markdown.SourceString) -> Int? {
        self.cache(link.string) {
            if  let codelink: UCF.Selector = .init(link.string) {
                return self.resolver.outline(codelink, at: link.source)
            } else {
                self.resolver.diagnostics[link.source] = SSGC.AutolinkParsingError.init(link)
                return nil
            }
        }
    }
    private mutating func outline(
        doc link: Markdown.SourceString,
        as provenance: Markdown.SourceURL.Provenance
    ) -> Int? {
        self.cache(link.string) {
            if  let doclink: Doclink = .init(doc: link.string[...]) {
                return self.resolver.outline(doclink, at: link.source, as: provenance)
            } else {
                self.resolver.diagnostics[link.source] = SSGC.AutolinkParsingError.init(link)
                return nil
            }
        }
    }

    private mutating func outline(symbol usr: Symbol.USR) -> Int? {
        let symbol: Symbol.Decl
        switch usr {
        case .scalar(let scalar):   symbol = scalar
        case .vector(let vector):   symbol = vector.feature
        case .block:                return nil
        }

        return self.cache.add(outline: .symbol(self.resolver.tables.intern(symbol)))
    }
}
extension SSGC.Outliner {
    mutating func follow(
        rename renamed: String,
        of redirect: UnqualifiedPath,
        at location: SourceLocation<Int32>?
    ) -> Int32? {
        self.resolver.resolve(rename: renamed, of: redirect, at: location)
    }

    mutating func link(
        body: Markdown.SemanticDocument,
        file: Int32?
    ) -> (SymbolGraph.Article, [[Int32]]) {
        let overview: Markdown.Bytecode

        if  let paragraph: Markdown.BlockParagraph = body.overview {
            overview = .init {
                paragraph.outline { self.outline(reference: $0) }
                paragraph.emit(into: &$0)
            }
        } else {
            overview = []
        }

        let fold: Int = self.cache.fold

        let details: Markdown.Bytecode = .init {
            (binary: inout Markdown.BinaryEncoder) in

            body.details.traverse { $0.outline { self.outline(reference: $0) } }
            body.details.emit(into: &binary)
        }

        let footer: SymbolGraph.Article.Footer?

        if  body.containsSeeAlso {
            footer = .omit
        } else if case false? = body.metadata.options.automaticSeeAlso?.value {
            footer = .omit
        } else {
            footer = nil
        }

        let article: SymbolGraph.Article = .init(
            outlines: self.cache.clear(),
            overview: overview,
            details: details,
            fold: fold,
            file: file,
            footer: footer
        )

        var topics: [[Int32]] = []
        topics.reserveCapacity(body.topics.count)

        for topic: Markdown.BlockTopic in body.topics {
            let topic: [Int32] = topic.items.reduce(into: []) {
                guard
                case .outlined(let reference) = $1 else {
                    return
                }
                switch article.outlines[reference] {
                case .vertex(let id, text: _):          $0.append(id)
                case .vector(let id, self: _, text: _): $0.append(id)
                default:                                return
                }
            }
            //  Single-item topics are worthless as curator groups.
            if  topic.count > 1 {
                topics.append(topic)
            }
        }

        return (article, topics)
    }

    mutating func link(blocks: [Markdown.BlockElement], file: Int32) -> SymbolGraph.Article {
        let rendered: Markdown.Bytecode = .init {
            for block: Markdown.BlockElement in blocks {
                block.traverse { $0.outline { self.outline(reference: $0) } }
                block.emit(into: &$0)
            }
        }

        return .init(
            outlines: self.cache.clear(),
            overview: rendered,
            details: [],
            fold: nil,
            file: file
        )
    }
}
