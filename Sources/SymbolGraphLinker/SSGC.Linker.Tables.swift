import LinkResolution
import MarkdownSemantics
import SourceDiagnostics
import SymbolGraphs
import Symbols
import UCF

extension SSGC.Linker
{
    @_spi(testable) public
    struct Tables:~Copyable
    {
        var diagnostics:Diagnostics<SSGC.Symbolicator>

        @_spi(testable) public
        var codelinks:CodelinkResolver<Int32>.Table
        @_spi(testable) public
        var doclinks:DoclinkResolver.Table

        private
        var anchors:SSGC.AnchorResolver

        /// Interned module names. This only contains modules that are not included in the
        /// symbol graph being linked.
        private
        var modules:[Symbol.Module: Int]

        private
        var articles:[Symbol.Article: Int32]
        private
        var decls:[Symbol.Decl: Int32]
        private
        var files:[Symbol.File: Int32]

        var graph:SymbolGraph

        @_spi(testable) public
        init(diagnostics:Diagnostics<SSGC.Symbolicator> = .init(),
            codelinks:CodelinkResolver<Int32>.Table = .init(),
            doclinks:DoclinkResolver.Table = .init(),
            anchors:SSGC.AnchorResolver = .init(),
            modules:[SymbolGraph.Module] = [])
        {
            self.diagnostics = diagnostics
            self.codelinks = codelinks
            self.doclinks = doclinks
            self.anchors = anchors

            self.modules = [:]

            self.articles = [:]
            self.decls = [:]
            self.files = [:]

            self.graph = .init(modules: modules)
        }
    }
}
extension SSGC.Linker.Tables
{
    var importAll:[Symbol.Module]
    {
        .init(self.graph.namespaces[self.graph.cultures.indices])
    }
}
extension SSGC.Linker.Tables
{
    /// Indexes the given article and appends it to the symbol graph, if an article with the
    /// same mangled name has not already been indexed. (This function checks for duplicates.)
    mutating
    func allocate(article:Symbol.Article, title:consuming Markdown.BlockHeading) -> Int32?
    {
        {
            if  case nil = $0
            {
                let headline:Markdown.Bytecode = .init
                {
                    //  Don’t emit the enclosing `h1` tag!
                    for element:Markdown.InlineElement in title.elements
                    {
                        element.emit(into: &$0)
                    }
                }
                let scalar:Int32 = self.graph.articles.append(.init(headline: headline),
                    id: article)
                $0 = scalar
                return scalar
            }
            else
            {
                return nil
            }
        } (&self.articles[article])
    }

    /// Indexes the given declaration and appends it to the symbol graph.
    ///
    /// This function only populates basic information (flags and path) about the declaration,
    /// the rest should only be added after completing a full pass over all the declarations and
    /// extensions.
    ///
    /// This function doesn’t check for duplicates.
    mutating
    func allocate(decl:SSGC.Decl) -> Int32
    {
        let vertex:SymbolGraph.Decl = .init(language: decl.language,
            phylum: decl.phylum,
            kinks: decl.kinks,
            path: decl.path)

        let scalar:Int32 = self.graph.decls.append(.init(decl: vertex),
            id: decl.id)

        self.decls[decl.id] = scalar
        return scalar
    }

    /// Indexes the declaration extended by the given extension and appends the (empty)
    /// declaration to the symbol graph, if it has not already been indexed. (This function
    /// checks for duplicates.)
    mutating
    func allocate(extension:SSGC.Extension) -> Int32
    {
        let decl:Symbol.Decl = `extension`.extended.type
        let scalar:Int32 =
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.decls.append(.init(extensions: []),
                    id: decl)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.decls[decl])
        return scalar
    }
}
extension SSGC.Linker.Tables
{
    /// Returns the scalar for the given declaration symbol, registering it in the symbol table
    /// if needed. You should never call ``allocate(decl:)`` or ``allocate(extension:)`` after
    /// calling this function.
    mutating
    func intern(_ id:Symbol.Decl) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.decls.symbols.append(id)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.decls[id])
    }

    /// Returns the scalar for the given file symbol,
    /// registering it in the symbol table if needed.
    mutating
    func intern(_ id:Symbol.File) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.files.append(id)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.files[id])
    }

    mutating
    func intern(_ id:Symbol.Module) -> Int
    {
        {
            switch $0
            {
            case nil:
                let index:Int = self.graph.append(namespace: id)
                $0 = index
                return index

            case let index?:
                return index
            }
        } (&self.modules[id])
    }
    mutating
    func intern(_ id:SSGC.Namespace.ID) -> Int
    {
        switch id
        {
        case .index(let culture):   culture
        case .nominated(let id):    self.intern(id)
        }
    }
}

extension SSGC.Linker.Tables
{
    mutating
    func index(article:Markdown.SemanticDocument, id scope:Int32?)
    {
        let anchors:SSGC.AnchorTable = self.anchors.index(
            article: article.details,
            id: scope)

        func rewrite(_ target:inout Markdown.InlineHyperlink.Target?)
        {
            var spelling:Markdown.SourceString

            switch target
            {
            case .external(let url)?:
                guard
                case "doc" = url.scheme,
                case "#"? = url.suffix.string.first
                else
                {
                    return
                }

                spelling = url.suffix
                spelling.string.removeFirst()

            case .fragment(let link)?:
                spelling = link

            default:
                return
            }

            switch anchors[normalizing: spelling.string]
            {
            case .success(let fragment):
                spelling.string = fragment
                target = .fragment(spelling)

            case .failure(let error):
                self.diagnostics[spelling.source] = error
            }
        }

        article.overview?.sanitize(with: rewrite)
        article.details.traverse
        {
            if  case let block as Markdown.BlockProse = $0
            {
                block.sanitize(with: rewrite)
            }
        }
    }

    mutating
    func inline(resources:[String: SSGC.Resource],
        into sections:Markdown.SemanticSections,
        with parser:Markdown.SwiftLanguage?) throws
    {
        var last:[String?: SSGC.ResourceText] = [:]
        try sections.traverse
        {
            guard
            case let block as Markdown.BlockCodeReference = $0
            else
            {
                return
            }

            guard
            let file:String = block.file
            else
            {
                self.diagnostics[block.source] = SSGC.ResourceError.fileRequired(
                    argument: "file")
                return
            }
            guard
            let file:SSGC.Resource = resources[file]
            else
            {
                self.diagnostics[block.source] = SSGC.ResourceError.fileNotFound(file)
                return
            }

            let code:SSGC.ResourceText = try file.text()
            defer
            {
                last[block.title] = code
            }

            let base:SSGC.ResourceText?
            switch block.base
            {
            case .file(let file)?:
                if  let file:SSGC.Resource = resources[file]
                {
                    base = try file.text()
                    break
                }

                self.diagnostics[block.source] = SSGC.ResourceError.fileNotFound(file)
                base = nil

            case .auto?:
                base = last[block.title]

            case nil:
                base = nil
            }

            block.inline(code: code, base: base, with: parser)
            block.link = .inline(file.id)
        }
    }
}
extension SSGC.Linker.Tables
{
    @_spi(testable) public mutating
    func resolving<Success>(with scopes:SSGC.OutlineResolutionScopes,
        do body:(inout SSGC.Outliner) throws -> Success) rethrows -> Success
    {
        let codelinks:CodelinkResolver<Int32>.Table = self.codelinks
        let doclinks:DoclinkResolver.Table = self.doclinks
        let anchors:SSGC.AnchorResolver = self.anchors

        var outliner:SSGC.Outliner = .init(resources: scopes.resources,
            resolver: .init(
                diagnostics: (consume self).diagnostics,
                codelinks: .init(table: codelinks, scope: scopes.codelink),
                doclinks: .init(table: doclinks, scope: scopes.doclink),
                anchors: anchors,
                origin: scopes.origin))

        do
        {
            let success:Success = try body(&outliner)
            self = .init(diagnostics: outliner.diagnostics(),
                codelinks: codelinks,
                doclinks: doclinks,
                anchors: anchors)
            return success
        }
        catch let error
        {
            self = .init(diagnostics: outliner.diagnostics(),
                codelinks: codelinks,
                doclinks: doclinks,
                anchors: anchors)
            throw error
        }
    }
}
