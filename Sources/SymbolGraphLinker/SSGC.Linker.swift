import CodelinkResolution
import Codelinks
import DoclinkResolution
import FNV1
import LexicalPaths
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Signatures
import Snippets
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import Unidoc
import SourceDiagnostics

extension SSGC
{
    public
    struct Linker:~Copyable
    {
        private
        let doccommentParser:Markdown.Parser<Markdown.SwiftComment>
        private
        let markdownParser:Markdown.Parser<Markdown.SwiftFlavor>
        private
        let swiftParser:Markdown.SwiftLanguage?
        private
        let nominations:SSGC.Nominations

        private
        var symbolizer:Symbolizer
        private
        var resources:[[String: Resource]]
        private
        var snippets:[String: Markdown.Snippet]
        private
        var router:Router
        private
        var tables:Tables

        private
        var supplements:[Int32: (source:Markdown.Source, body:Markdown.SemanticDocument)]

        public
        init(nominations:SSGC.Nominations,
            modules:[SymbolGraph.Module],
            plugins:[any Markdown.CodeLanguageType] = [])
        {
            let swift:(any Markdown.CodeLanguageType)? = plugins.first { $0.name == "swift" }
            //  If we were given a plugin that says it can highlight swift,
            //  make it the default plugin for the doccomment parser.
            self.doccommentParser = .init(plugins: plugins, default: swift)
            self.markdownParser = .init(plugins: plugins)
            self.swiftParser = swift as? Markdown.SwiftLanguage
            self.nominations = nominations

            self.symbolizer = .init(modules: modules)
            self.resources = []
            self.snippets = [:]
            self.router = .init()
            self.tables = .init()

            self.supplements = [:]
        }
    }
}

extension SSGC.Linker
{
    private mutating
    func address(of decl:Symbol.Decl?) -> Int32?
    {
        decl.map { self.symbolizer.intern($0) }
    }
    /// Returns an array of local scalars for an array of declaration symbols.
    /// The scalar assignments reflect the order of the symbols in the array,
    /// so you should sort them if you want deterministic addressing.
    ///
    /// This function doesn’t expose the declarations for codelink resolution,
    /// because it is expected that the same symbols may appear in
    /// the array arguments of multiple calls to this function, and it
    /// is more efficient to expose declarations while performing a different
    /// pass.
    private mutating
    func addresses(of decls:[Symbol.Decl]) -> [Int32]
    {
        decls.map { self.symbolizer.intern($0) }
    }
    /// Returns an array of addresses for an array of vector features,
    /// exposing each vector for codelink resolution in the process.
    ///
    /// -   Parameters:
    ///     -   features:
    ///         An array of declaration symbols, assumed to be the feature
    ///         components of a collection of vector symbols with the
    ///         same heir.
    ///     -   prefix:
    ///         The lexical path of the shared heir.
    ///     -   extended:
    ///         The shared heir.
    ///     -   scalar:
    ///         The scalar for the shared heir.
    ///
    /// Unlike ``addresses(of:)``, this function adds overloads to the
    /// codelink resolver, because it’s more efficient to combine these
    /// two passes.
    private mutating
    func addresses(exposing features:[Symbol.Decl],
        prefixed prefix:(Symbol.Module, UnqualifiedPath),
        of extended:Symbol.Decl,
        at scalar:Int32) -> [Int32]
    {
        features.map
        {
            let feature:Int32 = self.symbolizer.intern($0)
            if  let (last, phylum):(String, Phylum.Decl) =
                self.symbolizer.graph.decls[feature]?.decl.map({ ($0.path.last, $0.phylum) }) ??
                self.nominations[feature: $0]
            {
                let vector:Symbol.Decl.Vector = .init($0, self: extended)
                self.tables.codelinks[prefix.0, prefix.1, last].overload(with: .init(
                    target: .vector(feature, self: scalar),
                    phylum: phylum,
                    hash: .init(hashing: "\(vector)")))
            }
            return feature
        }
    }
}
extension SSGC.Linker
{
    /// Allocates and binds addresses for the declarations stored in the given array
    /// of compiled namespaces. Binding consists of populating the full name and
    /// phylum of a declaration. This function also exposes each of the declarations
    /// for codelink resolution.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method first, before calling any others.
    public mutating
    func allocate(namespaces:[[SSGC.Namespace]]) -> [[SymbolGraph.Namespace]]
    {
        let destinations:[[SymbolGraph.Namespace]] = namespaces.map
        {
            $0.map
            {
                .init(range: self.allocate(decls: $0.decls),
                    index: self.symbolizer.intern($0.id))
            }
        }
        for ((culture, sources), destinations):
            ((Int, [SSGC.Namespace]), [SymbolGraph.Namespace]) in zip(zip(
                namespaces.indices,
                namespaces),
            destinations)
        {
            //  Record scalar ranges
            self.symbolizer.graph.cultures[culture].namespaces = destinations

            for (source, destination):(SSGC.Namespace, SymbolGraph.Namespace) in
                zip(sources, destinations)
            {
                let qualifier:Symbol.Module =
                    self.symbolizer.graph.namespaces[destination.index]
                for (scalar, decl) in zip(destination.range, source.decls)
                {
                    let hash:FNV24 = .init(truncating: .decl(decl.id))
                    //  Make the decl visible to codelink resolution.
                    self.tables.codelinks[qualifier, decl.path].overload(with: .init(
                        target: .scalar(scalar),
                        phylum: decl.phylum,
                        hash: hash))
                    //  Assign the decl a URI, and record the decl’s hash
                    //  so we will know if it has a hash collision.
                    self.router[qualifier, decl.path, decl.phylum][hash, default: []]
                        .append(scalar)
                }
            }
        }
        return destinations
    }
    private mutating
    func allocate(decls:[SSGC.Decl]) -> ClosedRange<Int32>
    {
        var scalars:(first:Int32, last:Int32)? = nil
        for decl:SSGC.Decl in decls
        {
            let scalar:Int32 = self.symbolizer.allocate(decl: decl)
            switch scalars
            {
            case  nil:              scalars = (scalar, scalar)
            case (let first, _)?:   scalars = (first,  scalar)
            }
        }
        if  case (let first, let last)? = scalars
        {
            return first ... last
        }
        else
        {
            fatalError("cannot allocate empty declaration array")
        }
    }
}
extension SSGC.Linker
{
    /// Allocates addresses for the given array of compiled extensions.
    /// This function also exposes any features manifested by the extensions for
    /// codelink resolution.
    ///
    /// -   Returns:
    ///     A (scalar, index) tuple for each compiled extension. If the
    ///     extension extends a symbol that has not yet been registered,
    ///     the scalar is newly allocated.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method second, after calling ``allocate(decls:)``.
    public mutating
    func allocate(extensions:[SSGC.Extension]) -> [(Int32, Int)]
    {
        let addresses:[Int32] = extensions.map
        {
            self.symbolizer.allocate(extension: $0)
        }
        return zip(addresses, extensions).map
        {
            let namespace:Int = self.symbolizer.intern($0.1.signature.extended.namespace)
            let qualifier:Symbol.Module = self.symbolizer.graph.namespaces[namespace]

            //  Sort *then* address, since we want deterministic addresses too.
            let conformances:[Int32] = self.addresses(
                of: $0.1.conformances.sorted())
            let features:[Int32] = self.addresses(
                exposing: $0.1.features.sorted(),
                prefixed: (qualifier, $0.1.path),
                of: $0.1.extended.type,
                at: $0.0)
            let nested:[Int32] = self.addresses(
                of: $0.1.nested.sorted())

            let index:Int = self.symbolizer.graph.decls.nodes[$0.0].push(.init(
                conditions: $0.1.conditions.map
                {
                    $0.map { self.symbolizer.intern($0) }
                },
                namespace: namespace,
                culture: $0.1.signature.culture,
                conformances: conformances,
                features: features,
                nested: nested))
            return ($0.0, index)
        }
    }
}
extension SSGC.Linker
{
    public mutating
    func attach(
        resources:[[any SSGC.ResourceFile]],
        snippets:[any SSGC.ResourceFile],
        markdown:[[any SSGC.ResourceFile]]) throws -> [[SSGC.Article]]
    {
        //  We attach snippets first, because they can be referenced by the markdown
        //  supplements. This works even if the snippet captions contain references to articles,
        //  because we only eagarly inline snippet captions as markdown AST nodes; codelink
        //  resolution does not take place until we link the written documentation.
        self.resources = resources.map
        {
            $0.reduce(into: [:])
            {
                $0[$1.name] = .init(file: $1, id: self.symbolizer.intern($1.path))
            }
        }
        self.snippets = try self.attach(snippets: snippets)
        return          try self.attach(markdown: markdown)
    }

    private mutating
    func attach(
        snippets:[any SSGC.ResourceFile]) throws -> [String: Markdown.Snippet]
    {
        guard
        let swift:Markdown.SwiftLanguage = self.swiftParser
        else
        {
            return [:]
        }

        //  Right now we only do one pass over the snippets, since no one should be referencing
        //  snippets from other snippets.
        return try snippets.reduce(into: [:])
        {
            let snippet:(caption:String, slices:[Markdown.SnippetSlice]) = swift.parse(
                snippet: try $1.read(as: [UInt8].self))

            $0[$1.name] = .init(id: self.symbolizer.intern($1.path),
                caption: snippet.caption,
                slices: snippet.slices,
                using: self.doccommentParser)
        }
    }

    private mutating
    func attach(markdown:[[any SSGC.ResourceFile]]) throws -> [[SSGC.Article]]
    {
        let articles:[[SSGC.Article]] = try markdown.indices.map
        {
            let namespace:Symbol.Module = self.symbolizer.graph.namespaces[$0]

            var scalars:(first:Int32, last:Int32)? = nil
            var articles:[SSGC.Article] = []

            for file:any SSGC.ResourceFile in markdown[$0]
            {
                if  let article:SSGC.Article = try self.attach(supplement: file, in: namespace)
                {
                    articles.append(article)

                    guard let scalar:Int32 = article.standalone
                    else
                    {
                        continue
                    }

                    switch scalars
                    {
                    case  nil:              scalars = (scalar, scalar)
                    case (let first, _)?:   scalars = (first,  scalar)
                    }
                }
            }

            self.symbolizer.graph.cultures[$0].articles = scalars.map
            {
                $0.first ... $0.last
            }

            return articles
        }

        //  Now that standalone articles have all been exposed for doclink resolution,
        //  we can link them. But before doing that, we need to register all known namespaces
        //  for codelink resolution.
        for (n, namespace):(Int, Symbol.Module) in zip(
            self.symbolizer.graph.namespaces.indices,
            self.symbolizer.graph.namespaces)
        {
            self.tables.codelinks[namespace].overload(with: .init(
                target: .scalar(n * .module),
                phylum: nil,
                hash: .init(truncating: .module(namespace))))
        }

        return articles
    }

    /// Parses and stores the given supplemental documentation if it has a binding
    /// that resolves to a known symbol. If the parsed article lacks a symbol binding
    /// altogether, it is considered a standalone article.
    private mutating
    func attach(supplement:any SSGC.ResourceFile,
        in namespace:Symbol.Module) throws -> SSGC.Article?
    {
        //  We always intern the article’s file path, for diagnostics, even if
        //  we end up discarding the article.
        let file:Int32 = self.symbolizer.intern(supplement.path)
        let source:Markdown.Source = .init(file: file,
            text: try supplement.read(as: String.self))

        let name:String = supplement.name

        let prefix:DoclinkResolver.Prefix
        let title:Markdown.BlockHeading
        let route:SSGC.Route
        let id:Symbol.Article

        let supplement:SSGC.Supplement
        do
        {
            supplement = try source.parse(
                markdownParser: self.markdownParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics)
        }
        catch let error as SSGC.SupplementError
        {
            self.tables.diagnostics[source.origin] = error
            return nil
        }
        catch // I wish swift had typed throws
        {
            fatalError("unreachable")
        }

        switch supplement.type
        {
        case .supplement(let binding):
            let decl:Int32?
            do
            {
                decl = try self.resolve(decl: binding, in: namespace)
            }
            catch let diagnosis as any Diagnostic<SSGC.Symbolicator>
            {
                self.tables.diagnostics[binding.source] = diagnosis
                return nil
            }
            catch
            {
                return nil
            }

            if  let decl:Int32
            {
                {
                    if  case nil = $0
                    {
                        $0 = (source, supplement.body)
                    }
                    else
                    {
                        self.tables.diagnostics[binding.source] = SSGC.SupplementError.multiple
                    }
                } (&self.supplements[decl])

                return nil
            }
            else
            {
                return .init(standalone: nil, file: file, body: supplement.body)
            }

        case .standalone(let heading):
            prefix = .documentation(namespace)
            title = heading
            route = .article(namespace, name)
            id = .article(namespace, name)

        case .tutorials(let headline):
            prefix = .tutorials(namespace)
            title = .h(1, text: headline)
            route = .article(namespace, "index.tutorial")
            id = .tutorial(namespace, "index")

        case .tutorial(let headline):
            //  To DocC, tutorials are an IMAX experience. To us, they are just articles.
            prefix = .tutorials(namespace)
            title = .h(1, text: headline)
            route = .article(namespace, "\(name).tutorial")
            id = .tutorial(namespace, name)
        }

        if  let scalar:Int32 = self.symbolizer.allocate(article: id, title: title)
        {
             //  Make the standalone article visible for doclink resolution.
            self.tables.doclinks[prefix, name] = scalar
            self.router[route][nil, default: []].append(scalar)
            return .init(standalone: scalar, file: file, body: supplement.body)
        }
        else if
            let titleLocation:SourceReference<Markdown.Source> = title.source
        {
            self.tables.diagnostics[titleLocation] = SSGC.ArticleError.duplicated(name: name)
            return nil
        }
        else
        {
            self.tables.diagnostics[source.origin] = SSGC.ArticleError.duplicated(name: name)
            return nil
        }
    }

    private
    func resolve(decl binding:Markdown.InlineAutolink,
        in namespace:Symbol.Module) throws -> Int32?
    {
        //  Special rule for article bindings: if the text of the codelink matches
        //  the current namespace, then the article is the primary article for
        //  that module.
        if  binding.text.string == "\(namespace)"
        {
            return nil
        }

        guard let codelink:Codelink = .init(binding.text.string)
        else
        {
            throw SSGC.AutolinkParsingError<SSGC.Symbolicator>.init(binding.text)
        }

        //  A qualified codelink with a single component that matches the current
        //  namespace is also a way to mark the primary article for that module.
        if  case .qualified = codelink.base,
            codelink.path.components.count == 1,
            codelink.path.components[0] == "\(namespace)"
        {
            return nil
        }

        let resolver:CodelinkResolver<Int32> = .init(
            table: self.tables.codelinks,
            scope: .init(
                namespace: namespace,
                imports: self.symbolizer.importAll))

        switch resolver.resolve(codelink)
        {
        case .one(let overload):
            switch overload.target
            {
            case .scalar(let scalar):
                return scalar

            case .vector(let feature, self: let heir):
                throw SSGC.SupplementBindingError.init(.vector(feature, self: heir),
                    codelink: codelink)
            }

        case .some(let overloads):
            if  overloads.isEmpty
            {
                throw SSGC.SupplementBindingError.init(.none(in: namespace),
                    codelink: codelink)
            }
            else
            {
                throw CodelinkResolutionError<SSGC.Symbolicator>.init(
                    overloads: overloads,
                    codelink: codelink)
            }
        }
    }
}

extension SSGC.Linker
{
    /// Links declarations that have already been assigned addresses.
    ///
    /// This throws an error if and only if a file system error occurs. This is fatal because
    /// there is already logic in the linker to handle the case where files are missing.
    public mutating
    func link(namespaces sources:[[SSGC.Namespace]],
        at destinations:[[SymbolGraph.Namespace]]) throws
    {
        precondition(self.symbolizer.graph.cultures.count == destinations.count)
        precondition(self.symbolizer.graph.cultures.count == sources.count)

        //  First pass: expose and link unqualified features.
        for (sources, destinations):
            ([SSGC.Namespace], [SymbolGraph.Namespace]) in zip(sources, destinations)
        {
            for (source, destination):
                (SSGC.Namespace, SymbolGraph.Namespace) in zip(sources, destinations)
            {
                let qualifier:Symbol.Module =
                    self.symbolizer.graph.namespaces[destination.index]

                for (address, decl):(Int32, SSGC.Decl) in zip(
                    destination.range,
                    source.decls)
                {
                    if  decl.features.isEmpty
                    {
                        continue
                    }

                    let features:[Int32] = self.addresses(exposing: decl.features.sorted(),
                        prefixed: (qualifier, decl.path),
                        of: decl.id,
                        at: address)

                    self.symbolizer.graph.decls.nodes[address].decl?.features = features
                }
            }
        }

        //  Second pass: link everything else.
        for (c, module):(Int, Symbol.Module) in zip(
            self.symbolizer.graph.cultures.indices,
            self.symbolizer.graph.namespaces)
        {
            let culture:Culture = .init(resources: self.resources[c],
                imports: self.symbolizer.importAll,
                module: module)

            for (source, destination):
                (SSGC.Namespace, SymbolGraph.Namespace) in zip(sources[c], destinations[c])
            {
                try self.link(decls: source.decls,
                    at: destination.range,
                    of: culture,
                    in: self.symbolizer.graph.namespaces[destination.index])
            }
        }
    }

    private mutating
    func link(decls:[SSGC.Decl],
        at addresses:ClosedRange<Int32>,
        of culture:Culture,
        in namespace:Symbol.Module) throws
    {
        for (address, decl):(Int32, SSGC.Decl) in zip(addresses, decls)
        {
            try self.link(decl: decl, at: address, of: culture, in: namespace)
        }
    }

    private mutating
    func link(decl:SSGC.Decl,
        at address:Int32,
        of culture:Culture,
        in namespace:Symbol.Module) throws
    {
        let signature:Signature<Int32> = decl.signature.map { self.symbolizer.intern($0) }

        //  Sort for deterministic addresses.
        let requirements:[Int32] = self.addresses(of: decl.requirements.sorted())
        let inhabitants:[Int32] = self.addresses(of: decl.inhabitants.sorted())
        let superforms:[Int32] = self.addresses(of: decl.superforms.sorted())
        let origin:Int32? = self.address(of: decl.origin)

        let location:SourceLocation<Int32>? = decl.location?.map
        {
            self.symbolizer.intern($0)
        }

        let comment:Markdown.Source? = decl.comment.map
        {
            .init(comment: $0, in: location?.file)
        }

        let markdown:(parsed:Markdown.SemanticDocument, file:Int32?)?

        switch (comment, self.supplements.removeValue(forKey: address))
        {
        case (nil, nil):
            markdown = nil

        case (let comment?, nil):
            /// The file associated with the doccomment is always the same as
            /// the file the declaration itself lives in, so we would only ever
            /// care about the file associated with the supplement.
            markdown =
            (
                parsed: comment.parse(
                    markdownParser: self.doccommentParser,
                    snippetsTable: self.snippets,
                    diagnostics: &self.tables.diagnostics),
                file: nil
            )

        case (let comment?, let supplement?):
            if  case .override? = supplement.body.metadata.merge
            {
                fallthrough
            }

            let body:Markdown.SemanticDocument = comment.parse(
                markdownParser: self.doccommentParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics)

            markdown =
            (
                parsed: body.merged(appending: supplement.body),
                file: supplement.source.origin?.file
            )

        case (nil, let supplement?):
            markdown =
            (
                parsed: supplement.body,
                file: supplement.source.origin?.file
            )
        }

        let renamed:String? = signature.availability.universal?.renamed
            ?? signature.availability.agnostic[.swift]?.renamed
            ?? signature.availability.agnostic[.swiftPM]?.renamed

        let article:SymbolGraph.Article?
        let rename:Int32?

        if  let sections:Markdown.SemanticSections = markdown?.parsed.details
        {
            try self.tables.inline(resources: culture.resources,
                into: sections,
                with: self.swiftParser)
        }
        if  markdown != nil || renamed != nil
        {
            (article, rename) = self.tables.resolving(with: .init(
                namespace: namespace,
                culture: culture,
                scope: decl.phylum.scope(trimming: decl.path)))
            {
                (outliner:inout SSGC.Outliner) in
                (
                    markdown.map
                    {
                        let (article, topics):(SymbolGraph.Article, [[Int32]]) = outliner.link(
                            body: $0.parsed,
                            file: $0.file)

                        self.symbolizer.graph.curation += topics
                        return article
                    },
                    renamed.map
                    {
                        outliner.follow(rename: $0, of: decl.path, at: location)
                    } ?? nil
                )
            }
        }
        else
        {
            article = nil
            rename = nil
        }

        {
            $0?.requirements = requirements
            $0?.inhabitants = inhabitants
            $0?.superforms = superforms
            $0?.renamed = rename
            $0?.origin = origin

            $0?.signature = signature
            $0?.location = location
            $0?.article = article

        } (&self.symbolizer.graph.decls.nodes[address].decl)
    }
}
extension SSGC.Linker
{
    /// Links extensions that have already been assigned addresses.
    ///
    /// This throws an error if and only if a file system error occurs. This is fatal because
    /// there is already logic in the linker to handle the case where files are missing.
    public mutating
    func link(extensions:[SSGC.Extension], at addresses:[(Int32, Int)]) throws
    {
        for ((scalar, index), `extension`):((Int32, Int), SSGC.Extension) in zip(
            addresses,
            extensions)
        {
            //  Extensions can have many constituent extension blocks, each potentially
            //  with its own doccomment. It’s not clear to me how to combine them,
            //  so for now, we just keep the longest doccomment and discard all the others,
            //  like DocC does. (Except DocC does this across all extensions with the
            //  same extended type.)
            //  https://github.com/apple/swift-docc/pull/369
            var location:SourceLocation<Symbol.File>? = nil
            var comment:SSGC.DocumentationComment? = nil
            var longest:Int = 0

            for block:SSGC.Extension.Block in `extension`.blocks
            {
                if  let current:SSGC.DocumentationComment = block.comment
                {
                    //  This is really, really stupid, but we need a way to break
                    //  ties, and we can’t use source location for this, as it is
                    //  not always available.
                    let length:Int = current.text.count
                    if (longest, comment?.text ?? "") < (length, current.text)
                    {
                        location = block.location
                        comment = current
                        longest = length
                    }
                }
            }

            guard
            let comment:SSGC.DocumentationComment
            else
            {
                continue
            }

            //  Only intern the file path for the extension block with the longest comment
            let file:Int32? = location.map { self.symbolizer.intern($0.file) }
            let markdown:Markdown.Source = .init(comment: comment, in: file)

            //  Need to load these before mutating the symbol graph to avoid
            //  overlapping access
            let imports:[Symbol.Module] = self.symbolizer.importAll
            let parsed:Markdown.SemanticDocument = markdown.parse(
                markdownParser: self.doccommentParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics)

            try
            {
                let culture:Culture = .init(resources: self.resources[$0.culture],
                    imports: imports,
                    module: self.symbolizer.graph.namespaces[$0.culture])

                try self.tables.inline(resources: culture.resources,
                    into: parsed.details,
                    with: self.swiftParser)

                let scopes:SSGC.OutlineResolutionScopes = .init(
                    namespace: self.symbolizer.graph.namespaces[$0.namespace],
                    culture: culture,
                    scope: [String].init(`extension`.path))

                let topics:[[Int32]]

                ($0.article, topics) = self.tables.resolving(with: scopes)
                {
                    $0.link(body: parsed, file: file)
                }

                self.symbolizer.graph.curation += topics

            } (&self.symbolizer.graph.decls.nodes[scalar].extensions[index])
        }
    }
}
extension SSGC.Linker
{
    /// Links articles that have already been assigned addresses.
    ///
    /// This throws an error if and only if a file system error occurs. This is fatal because
    /// there is already logic in the linker to handle the case where files are missing.
    public mutating
    func link(articles:[[SSGC.Article]]) throws
    {
        for c:Int in articles.indices
        {
            let culture:Culture = .init(resources: self.resources[c],
                imports: self.symbolizer.importAll,
                module: self.symbolizer.graph.namespaces[c])

            for article:SSGC.Article in articles[c]
            {
                try self.tables.inline(resources: culture.resources,
                    into: article.body.details,
                    with: self.swiftParser)

                self.tables.resolving(with: .init(culture: culture))
                {
                    let (documentation, topics):(SymbolGraph.Article, [[Int32]]) = $0.link(
                        body: article.body,
                        file: article.file)

                    self.symbolizer.graph.curation += topics

                    if  let a:Int32 = article.standalone
                    {
                        self.symbolizer.graph.articles.nodes[a].article = documentation
                    }
                    else
                    {
                        //  This is the article for the module’s landing page.
                        self.symbolizer.graph.cultures[c].article = documentation
                    }
                }
            }
        }
    }
}
extension SSGC.Linker
{
    public mutating
    func load() throws -> SymbolGraph
    {
        self.symbolizer.graph.colorize(routes: self.router.paths,
            with: &self.tables.diagnostics)

        return self.symbolizer.graph
    }

    public consuming
    func status(root:Symbol.FileBase?) -> DiagnosticMessages
    {
        self.tables.diagnostics.symbolicated(with: .init(
            graph: self.symbolizer.graph,
            root: root))
    }
}
