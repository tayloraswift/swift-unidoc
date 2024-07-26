import FNV1
import LexicalPaths
import LinkResolution
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Signatures
import Snippets
import SourceDiagnostics
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import UCF
import Unidoc

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
        let root:Symbol.FileBase?

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
        private
        var collations:ArticleCollations

        private
        init(
            plugins:[any Markdown.CodeLanguageType],
            modules:[SymbolGraph.Module],
            root:Symbol.FileBase?)
        {
            let swift:(any Markdown.CodeLanguageType)? = plugins.first { $0.name == "swift" }
            //  If we were given a plugin that says it can highlight swift,
            //  make it the default plugin for the doccomment parser.
            self.doccommentParser = .init(plugins: plugins, default: swift)
            self.markdownParser = .init(plugins: plugins)
            self.swiftParser = swift as? Markdown.SwiftLanguage
            self.root = root

            self.resources = []
            self.snippets = [:]
            self.router = .init()
            self.tables = .init(modules: modules)

            self.supplements = [:]
            self.collations = .init()
        }
    }
}
extension SSGC.Linker
{
    public
    init(
        plugins:[any Markdown.CodeLanguageType] = [],
        modules:[SymbolGraph.Module],
        allocating declarations:[SSGC.Declarations],
        extensions:[SSGC.Extensions],
        root:Symbol.FileBase? = nil)
    {
        self.init(plugins: plugins, modules: modules, root: root)

        for declarations:SSGC.Declarations in declarations
        {
            self.allocate(declarations: declarations)
        }
        for extensions:SSGC.Extensions in extensions
        {
            for node:SSGC.Extension in extensions.compiled
            {
                self.tables.allocate(decl: node.extended.type)
            }
        }
    }
}
extension SSGC.Linker
{
    private mutating
    func address(of decl:Symbol.Decl?) -> Int32?
    {
        decl.map { self.tables.intern($0) }
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
        decls.map { self.tables.intern($0) }
    }
}
extension SSGC.Linker
{
    /// Allocates and binds addresses for the given declarations. Binding consists of populating
    /// the full name and phylum of a declaration. This function also exposes each of the
    /// declarations for codelink resolution.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method first, before calling any others.
    private mutating
    func allocate(declarations:SSGC.Declarations)
    {
        guard
        let i:Int = self.tables.modules[declarations.culture]
        else
        {
            fatalError("No such module '\(declarations.culture)'")
        }

        let destinations:[SymbolGraph.Namespace] = declarations.namespaces.map
        {
            .init(
                range: self.allocate(decls: $0.decls, language: declarations.language),
                index: self.tables.intern($0.id))
        }

        for (namespace, destination):
            ((id:Symbol.Module, decls:[SSGC.Decl]), SymbolGraph.Namespace) in zip(
            declarations.namespaces,
            destinations)
        {
            for (scalar, decl) in zip(destination.range, namespace.decls)
            {
                let hash:FNV24 = .init(truncating: .decl(decl.id))
                //  Make the decl visible to codelink resolution.
                self.tables.codelinks[namespace.id, decl.path].overload(with: .init(
                    target: .scalar(scalar),
                    phylum: decl.phylum,
                    hash: hash))
                //  Assign the decl a URI, and record the decl’s hash
                //  so we will know if it has a hash collision.
                self.router[namespace.id, decl.path, decl.phylum][hash, default: []]
                    .append(scalar)
            }
        }

        self.tables.graph.cultures[i].namespaces = destinations
    }

    private mutating
    func allocate(decls:[SSGC.Decl], language:Phylum.Language) -> ClosedRange<Int32>
    {
        var scalars:(first:Int32, last:Int32)? = nil
        for decl:SSGC.Decl in decls
        {
            let scalar:Int32 = self.tables.allocate(decl: decl, language: language)
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
    func unfurl(extensions:SSGC.Extensions) -> [(Int32, Int)]
    {
        guard
        let culture:Int = self.tables.modules[extensions.culture]
        else
        {
            fatalError("No such module '\(extensions.culture)'")
        }

        return extensions.compiled.map
        {
            let extendee:Int32 = self.tables.intern($0.extended.type)
            if  extendee >= self.tables.graph.decls.nodes.endIndex
            {
                fatalError("Extendee '\($0.extended.type)' was never allocated!")
            }

            let namespace:Int = self.tables.intern($0.signature.extended.namespace)
            let qualifier:Symbol.Module = self.tables.graph.namespaces[namespace]


            let conformances:[Int32] = self.addresses(of: $0.conformances)
            let features:[Int32] = self.addresses(of: $0.features)
            let nested:[Int32] = self.addresses(of: $0.nested)

            //  Expose features for codelink resolution.
            for (f, id):(Int32, Symbol.Decl) in zip(features, $0.features)
            {
                guard
                let feature:SSGC.Extensions.Feature = extensions.features[id]
                else
                {
                    continue
                }

                let hash:FNV24 = .init(
                    hashing: "\(Symbol.Decl.Vector.init(id, self: $0.extended.type))")

                self.tables.codelinks[qualifier, $0.path, feature.lastName].overload(
                    with: .init(target: .vector(f, self: extendee),
                        phylum: feature.phylum,
                        hash: hash))
            }

            let index:Int = self.tables.graph.decls.nodes[extendee].push(.init(
                conditions: $0.conditions.map { $0.map { self.tables.intern($0) } },
                namespace: namespace,
                culture: culture,
                conformances: conformances,
                features: features,
                nested: nested))

            return (extendee, index)
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
                $0[$1.name] = .init(file: $1, id: self.tables.intern($1.path))
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
            let indexID:String?

            if  let root:Symbol.FileBase = self.root
            {
                indexID = "\(root.path)/\($1.path)"
            }
            else
            {
                indexID = nil
            }

            let snippet:(caption:String, slices:[Markdown.SnippetSlice]) = swift.parse(
                snippet: try $1.read(as: [UInt8].self),
                from: indexID)

            $0[$1.name] = .init(id: self.tables.intern($1.path),
                captionParser: self.doccommentParser,
                caption: snippet.caption,
                slices: snippet.slices)
        }
    }

    private mutating
    func attach(markdown:[[any SSGC.ResourceFile]]) throws -> [[SSGC.Article]]
    {
        let articles:[[SSGC.Article]] = try markdown.indices.map
        {
            let namespace:Symbol.Module = self.tables.graph.namespaces[$0]

            var range:(first:Int32, last:Int32)? = nil
            var articles:[SSGC.Article] = []

            for file:any SSGC.ResourceFile in markdown[$0]
            {
                if  let article:SSGC.Article = try self.attach(supplement: file, in: namespace)
                {
                    articles.append(article)

                    guard case .standalone(id: let id) = article.type
                    else
                    {
                        continue
                    }

                    switch range
                    {
                    case  nil:              range = (id,    id)
                    case (let first, _)?:   range = (first, id)
                    }
                }
            }

            self.tables.graph.cultures[$0].articles = range.map
            {
                $0.first ... $0.last
            }

            /// If there are any options with `global` scope, we need to propogate them
            /// to every other article in the same culture!
            var global:Markdown.SemanticMetadata.Options = [:]
            for article:SSGC.Article in articles
            {
                global.propogate(from: article.body.metadata.options)
            }
            for i:Int in articles.indices
            {
                articles[i].body.metadata.options.propogate(from: global)
            }

            return articles
        }

        //  Now that standalone articles have all been exposed for doclink resolution,
        //  we can link them. But before doing that, we need to register all known namespaces
        //  for codelink resolution.
        for (n, namespace):(Int, Symbol.Module) in zip(
            self.tables.graph.namespaces.indices,
            self.tables.graph.namespaces)
        {
            self.tables.codelinks[namespace].overload(with: .init(
                target: .scalar(n * .module),
                phylum: nil,
                hash: .init(truncating: .module(namespace))))
        }

        for (c, articles):(Int, [SSGC.Article]) in zip(articles.indices, articles)
        {
            let resources:[String: SSGC.Resource] = self.resources[c]
            for article:SSGC.Article in articles
            {
                try self.tables.inline(resources: resources,
                    into: article.body.details,
                    with: self.swiftParser)

                self.tables.index(article: article.body, id: article.id(in: c))
            }
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
        let file:Int32 = self.tables.intern(supplement.path)
        let source:Markdown.Source = .init(file: file,
            text: try supplement.read(as: String.self))

        let name:String = supplement.name

        let prefix:DoclinkResolver.Prefix

        let title:Markdown.Bytecode
        let titleLocation:SourceReference<Markdown.Source>?

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
        case .supplementWithHeading(let custom):
            //  Right now, the only way we can get one of these is via `@TechnologyRoot`.
            return .init(type: .culture(title: custom), file: file, body: supplement.body)

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
                return .init(type: .culture(title: nil), file: file, body: supplement.body)
            }

        case .standalone(let heading, at: let sourceLocation):
            prefix = .documentation(namespace)
            title = heading
            titleLocation = sourceLocation
            route = .article(namespace, name)
            id = .article(namespace, name)

        case .tutorials(let headline):
            prefix = .tutorials(namespace)
            title = .init { $0 += headline }
            titleLocation = nil
            route = .article(namespace, "index.tutorial")
            id = .tutorial(namespace, "index")

        case .tutorial(let headline):
            //  To DocC, tutorials are an IMAX experience. To us, they are just articles.
            prefix = .tutorials(namespace)
            title = .init { $0 += headline }
            titleLocation = nil
            route = .article(namespace, "\(name).tutorial")
            id = .tutorial(namespace, name)
        }

        if  let id:Int32 = self.tables.allocate(article: id, title: title)
        {
             //  Make the standalone article visible for doclink resolution.
            self.tables.doclinks[prefix, name] = id
            self.router[route][nil, default: []].append(id)
            return .init(type: .standalone(id: id), file: file, body: supplement.body)
        }
        else if
            let titleLocation:SourceReference<Markdown.Source>
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
            scope: .init(namespace: namespace, imports: self.tables.importAll))

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
    func collate(declarations:SSGC.Declarations) throws
    {
        guard
        let c:Int = self.tables.modules[declarations.culture]
        else
        {
            fatalError("No such module '\(declarations.culture)'")
        }

        let destinations:[SymbolGraph.Namespace] = self.tables.graph.cultures[c].namespaces
        let resources:[String: SSGC.Resource] = self.resources[c]

        for ((_, decls), destination):((_, [SSGC.Decl]), SymbolGraph.Namespace) in zip(
            declarations.namespaces,
            destinations)
        {
            for (i, decl):(Int32, SSGC.Decl) in zip(destination.range, decls)
            {
                try self.collate(decl: decl, with: resources, at: i)
            }
        }
    }

    private mutating
    func collate(decl:SSGC.Decl, with resources:[String: SSGC.Resource], at i:Int32) throws
    {
        let signature:Signature<Int32> = decl.signature.map { self.tables.intern($0) }

        //  Sort for deterministic addresses.
        let requirements:[Int32] = self.addresses(of: decl.requirements.sorted())
        let inhabitants:[Int32] = self.addresses(of: decl.inhabitants.sorted())
        let superforms:[Int32] = self.addresses(of: decl.superforms.sorted())
        let origin:Int32? = self.address(of: decl.origin)

        let location:SourceLocation<Int32>? = decl.location?.map
        {
            self.tables.intern($0)
        }

        let comment:Markdown.Source? = decl.comment.map
        {
            .init(comment: $0, in: location?.file)
        }

        let article:SSGC.ArticleCollation?
        var scope:[String] { decl.phylum.scope(trimming: decl.path) }

        switch (comment, self.supplements.removeValue(forKey: i))
        {
        case (nil, nil):
            article = nil

        case (let comment?, nil):
            /// The file associated with the doccomment is always the same as
            /// the file the declaration itself lives in, so we would only ever
            /// care about the file associated with the supplement.
            article = .init(combined: comment.parse(
                    markdownParser: self.doccommentParser,
                    snippetsTable: self.snippets,
                    diagnostics: &self.tables.diagnostics),
                scope: scope,
                file: nil)

        case (let comment?, let supplement?):
            if  case .override? = supplement.body.metadata.merge
            {
                fallthrough
            }

            let body:Markdown.SemanticDocument = comment.parse(
                markdownParser: self.doccommentParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics)

            article = .init(combined: body.merged(appending: supplement.body),
                scope: scope,
                file: supplement.source.origin?.file)

        case (nil, let supplement?):
            article = .init(combined: supplement.body,
                scope: scope,
                file: supplement.source.origin?.file)
        }

        if  let article:SSGC.ArticleCollation
        {
            try self.tables.inline(resources: resources,
                into: article.combined.details,
                with: self.swiftParser)

            self.tables.index(article: article.combined, id: i)

            self.collations[i] = article
        }

        {
            $0?.requirements = requirements
            $0?.inhabitants = inhabitants
            $0?.superforms = superforms
            $0?.origin = origin

            $0?.signature = signature
            $0?.location = location

        } (&self.tables.graph.decls.nodes[i].decl)

    }

    /// Links extensions that have already been assigned addresses.
    ///
    /// This throws an error if and only if a file system error occurs. This is fatal because
    /// there is already logic in the linker to handle the case where files are missing.
    public mutating
    func collate(extensions:[SSGC.Extension], at positions:[(Int32, Int)]) throws
    {
        for ((i, j), `extension`):((Int32, Int), SSGC.Extension) in zip(positions, extensions)
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
            let file:Int32? = location.map { self.tables.intern($0.file) }
            let markdown:Markdown.Source = .init(comment: comment, in: file)

            let collation:SSGC.ArticleCollation = .init(combined: markdown.parse(
                    markdownParser: self.doccommentParser,
                    snippetsTable: self.snippets,
                    diagnostics: &self.tables.diagnostics),
                scope: [String].init(`extension`.path),
                file: file)

            let c:Int = self.tables.graph.decls.nodes[i].extensions[j].culture

            try self.tables.inline(resources: self.resources[c],
                into: collation.combined.details,
                with: self.swiftParser)

            //  FIXME: We should index the anchors in the extension documentation, but
            //  extensions have 2-dimensional coordinates, and we don’t currently have a way to
            //  event link to them in the first place.
            self.tables.index(article: collation.combined, id: nil)

            self.collations[i, j] = collation
        }
    }
}
extension SSGC.Linker
{
    public mutating
    func link(extensions:[[(Int32, Int)]], articles:[[SSGC.Article]]) throws -> SymbolGraph
    {
        let imports:[Symbol.Module] = self.tables.importAll

        for c:Int in self.tables.graph.cultures.indices
        {
            let culture:Culture = .init(resources: self.resources[c],
                imports: imports,
                id: self.tables.graph.namespaces[c])

            for namespace:SymbolGraph.Namespace in self.tables.graph.cultures[c].namespaces
            {
                let module:Symbol.Module = self.tables.graph.namespaces[namespace.index]
                for i:Int32 in namespace.range
                {
                    let article:SSGC.ArticleCollation? = self.collations.move(i)
                    self.tables.link(article: article, of: culture, as: i, in: module)
                }
            }

            for article:SSGC.Article in articles[c]
            {
                self.tables.link(article: article, of: culture, at: c)
            }
        }

        for (i, j):(Int32, Int) in extensions.joined()
        {
            guard
            let article:SSGC.ArticleCollation = self.collations.move(i, j)
            else
            {
                continue
            }

            self.tables.link(article: article,
                extension: (i, j),
                resources: self.resources,
                imports: imports)
        }

        self.tables.graph.colorize(routes: self.router.paths, with: &self.tables.diagnostics)
        return self.tables.graph
    }

    public consuming
    func status() -> DiagnosticMessages
    {
        self.tables.diagnostics.symbolicated(with: .init(
            graph: self.tables.graph,
            root: self.root))
    }
}
