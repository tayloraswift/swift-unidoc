import LinkResolution
import MarkdownSemantics
import SourceDiagnostics
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import UCF

extension SSGC.Linker
{
    @_spi(testable) public
    struct Tables//:~Copyable
    {
        var diagnostics:Diagnostics<SSGC.Symbolicator>

        @_spi(testable) public
        var packageLinks:UCF.ResolutionTable<UCF.PackageOverload>
        @_spi(testable) public
        var articleLinks:UCF.ArticleTable

        private(set)
        var anchors:SSGC.AnchorResolver

        private(set)
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
            packageLinks:UCF.ResolutionTable<UCF.PackageOverload> = .init(),
            articleLinks:UCF.ArticleTable = .init(),
            anchors:SSGC.AnchorResolver = .init(),
            modules:[SymbolGraph.Module] = [])
        {
            self.diagnostics = diagnostics
            self.packageLinks = packageLinks
            self.articleLinks = articleLinks
            self.anchors = anchors

            self.modules = [:]

            for (c, module):(Int, SymbolGraph.Module) in modules.enumerated()
            {
                self.modules[module.id] = c
            }

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
    ///
    /// DO NOT REPLACE `__owned` WITH `consuming`! It will miscompile due to
    /// https://github.com/apple/swift/issues/70133
    mutating
    func allocate(article:Symbol.Article, title:__owned Markdown.Bytecode) -> Int32?
    {
        {
            if  case nil = $0
            {
                let scalar:Int32 = self.graph.articles.append(.init(headline: title),
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
    func allocate(decl:SSGC.Decl, language:Phylum.Language) -> Int32
    {
        let vertex:SymbolGraph.Decl = .init(language: language,
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
    @discardableResult
    mutating
    func allocate(decl:Symbol.Decl) -> Int32
    {
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
}

extension SSGC.Linker.Tables
{
    func resolve(binding:Markdown.InlineAutolink, in namespace:Symbol.Module) throws -> Int32?
    {
        //  Special rule for article bindings: if the text of the codelink matches
        //  the current namespace, then the article is the primary article for
        //  that module.
        if  binding.text.string == "\(namespace)"
        {
            return nil
        }

        guard
        let selector:UCF.Selector = .init(binding.text.string)
        else
        {
            throw SSGC.AutolinkParsingError<SSGC.Symbolicator>.init(binding.text)
        }

        //  A qualified codelink with a single component that matches the current
        //  namespace is also a way to mark the primary article for that module.
        if  case .qualified = selector.base,
            selector.path.components.count == 1,
            selector.path.components[0] == "\(namespace)"
        {
            return nil
        }

        let resolver:UCF.ProjectWideResolver = .init(global: self.packageLinks,
            scope: .init(namespace: namespace, imports: []))

        switch resolver.resolve(selector)
        {
        case .module(let module):
            throw SSGC.SupplementBindingError.init(selector: selector,
                variant: .moduleNotAllowed(module, expected: namespace))

        case .ambiguous(let overloads, rejected: let rejected):
            throw SSGC.SupplementBindingError.init(selector: selector,
                variant: .ambiguousBinding(overloads, rejected: rejected))

        case .overload(let overload):
            guard case let overload as UCF.PackageOverload = overload
            else
            {
                fatalError("umimplemented: supplement binding not within current package!!!")
            }
            if  let heir:Int32 = overload.heir
            {
                throw SSGC.SupplementBindingError.init(selector: selector,
                    variant: .vectorNotAllowed(overload.decl, self: heir))
            }

            return overload.decl
        }
    }

    mutating
    func index(normalizing article:Markdown.SemanticDocument, id scope:Int32?)
    {
        let anchors:SSGC.AnchorTable = self.anchors.index(
            article: article.details,
            id: scope)

        func rewrite(_ target:inout Markdown.InlineHyperlink.Target?)
        {
            var spelling:Markdown.SourceString

            switch target
            {
            case .urlFragment(let anchor)?:
                spelling = anchor

            case .url(url: let url)?:
                guard
                case "doc"? = url.scheme,
                case "#"? = url.suffix.string.first
                else
                {
                    return
                }

                spelling = url.suffix
                spelling.string.removeFirst()

            default:
                return
            }

            switch anchors[normalizing: spelling.string]
            {
            case .success(let fragment):
                spelling.string = fragment
                target = .urlFragment(spelling)

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
        var outliner:SSGC.Outliner = .init(
            resolver: .init(scopes: scopes, tables: consume self))
        do
        {
            let success:Success = try body(&outliner)
            self = outliner.move()
            return success
        }
        catch let error
        {
            self = outliner.move()
            throw error
        }
    }

    mutating
    func link(article:SSGC.Article, of culture:SSGC.Linker.Culture, at c:Int)
    {
        let (linked, topics):(SymbolGraph.Article, [[Int32]]) = self.resolving(
            with: .init(culture: culture, origin: article.id(in: c)))
        {
            $0.link(body: article.body, file: article.file)
        }

        self.graph.curation += topics

        switch article.type
        {
        case .standalone(id: let id):
            self.graph.articles.nodes[id].article = linked

        case .culture(let custom):
            //  This is the article for the module’s landing page.
            {
                $0.headline = custom
                $0.article = linked
            } (&self.graph.cultures[c])
        }
    }

    mutating
    func link(article:SSGC.ArticleCollation?,
        of culture:SSGC.Linker.Culture,
        as id:Int32,
        in namespace:Symbol.Module)
    {
        let linked:SymbolGraph.Article?
        let topics:[[Int32]]
        let rename:Int32?

        if  let decl:SymbolGraph.Decl = self.graph.decls.nodes[id].decl
        {
            let renamed:String? = decl.signature.availability.universal?.renamed
                ?? decl.signature.availability.agnostic[.swift]?.renamed
                ?? decl.signature.availability.agnostic[.swiftPM]?.renamed

            if  case nil = article,
                case nil = renamed
            {
                return // Nothing to do.
            }

            ((linked, topics), rename) = self.resolving(with: .init(
                namespace: namespace,
                culture: culture,
                origin: id,
                scope: article?.scope ?? decl.phylum.scope(trimming: decl.path)))
            {
                (outliner:inout SSGC.Outliner) in
                (
                    article.map
                    {
                        outliner.link(body: $0.combined, file: $0.file)
                    } ?? (nil, []),
                    renamed.map
                    {
                        outliner.follow(rename: $0, of: decl.path, at: decl.location)
                    } ?? nil
                )
            }
        }
        else
        {
            fatalError("Attempting to typeset a declaration that has not been indexed!")
        }

        {
            $0?.renamed = rename
            $0?.article = linked
        } (&self.graph.decls.nodes[id].decl)

        self.graph.curation += topics
    }

    mutating
    func link(article:SSGC.ArticleCollation,
        extension e:(i:Int32, j:Int),
        contexts:[SSGC.Linker.Context],
        imports:[Symbol.Module])
    {
        let `extension`:SymbolGraph.Extension = self.graph.decls.nodes[e.i].extensions[e.j]
        let scopes:SSGC.OutlineResolutionScopes = .init(
            namespace: self.graph.namespaces[`extension`.namespace],
            culture: .init(resources: contexts[`extension`.culture].resources,
                imports: imports,
                id: self.graph.namespaces[`extension`.culture]),
            origin: nil,
            scope: article.scope)

        let (linked, topics):(SymbolGraph.Article, [[Int32]]) = self.resolving(with: scopes)
        {
            $0.link(body: article.combined, file: article.file)
        }

        self.graph.decls.nodes[e.i].extensions[e.j].article = linked
        self.graph.curation += topics
    }
}
