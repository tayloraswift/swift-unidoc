import CodelinkResolution
import Codelinks
import DoclinkResolution
import FNV1
import InlineArray
import LexicalPaths
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownRendering
import MarkdownSemantics
import OrderedCollections
import Signatures
import Snippets
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import Unidoc
import SourceDiagnostics

public
struct StaticLinker:~Copyable
{
    private
    let doccommentParser:Markdown.Parser<Markdown.SwiftComment>
    private
    let markdownParser:Markdown.Parser<Markdown.SwiftFlavor>
    private
    let swiftParser:Markdown.SwiftLanguage?
    private
    let nominations:Compiler.Nominations

    private
    var symbolizer:Symbolizer
    private
    var snippets:[String: Markdown.Snippet]
    private
    var router:Router
    private
    var tables:Tables

    private
    var supplements:[Int32: (source:Markdown.Source, body:Markdown.SemanticDocument)]

    public
    init(nominations:Compiler.Nominations,
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
        self.snippets = [:]
        self.router = .init()
        self.tables = .init()

        self.supplements = [:]
    }
}
extension StaticLinker
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
extension StaticLinker
{
    /// Allocates and binds addresses for the declarations stored in the given array
    /// of compiled namespaces. Binding consists of populating the full name and
    /// phylum of a declaration. This function also exposes each of the declarations
    /// for codelink resolution.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method first, before calling any others.
    public mutating
    func allocate(namespaces:[[Compiler.Namespace]]) -> [[SymbolGraph.Namespace]]
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
            ((Int, [Compiler.Namespace]), [SymbolGraph.Namespace]) in zip(zip(
                namespaces.indices,
                namespaces),
            destinations)
        {
            //  Record scalar ranges
            self.symbolizer.graph.cultures[culture].namespaces = destinations

            for (source, destination):(Compiler.Namespace, SymbolGraph.Namespace) in
                zip(sources, destinations)
            {
                let qualifier:Symbol.Module =
                    self.symbolizer.graph.namespaces[destination.index]
                for (scalar, decl) in zip(destination.range, source.decls)
                {
                    let hash:FNV24 = .init(hashing: "\(decl.id)")
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
    func allocate(decls:[Compiler.Decl]) -> ClosedRange<Int32>
    {
        var scalars:(first:Int32, last:Int32)? = nil
        for decl:Compiler.Decl in decls
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
extension StaticLinker
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
    func allocate(extensions:[Compiler.Extension]) -> [(Int32, Int)]
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

extension StaticLinker
{
    public mutating
    func attach(
        resources:[[any StaticResourceFile]],
        snippets:[any StaticTextFile],
        markdown:[[any StaticTextFile]]) throws -> [[Article]]
    {
        //  We attach snippets first, because they can be referenced by the markdown
        //  supplements. This works even if the snippet captions contain references to articles,
        //  because we only eagarly inline snippet captions as markdown AST nodes; codelink
        //  resolution does not take place until we link the written documentation.
        self.snippets = try self.attach(snippets: snippets)
        return          try self.attach(markdown: markdown)
    }

    private mutating
    func attach(
        snippets:[any StaticTextFile]) throws -> [String: Markdown.Snippet]
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
                snippet: try $1.utf8())

            $0[$1.name] = .init(id: self.symbolizer.intern($1.path),
                caption: snippet.caption,
                slices: snippet.slices,
                using: self.doccommentParser)
        }
    }

    private mutating
    func attach(
        markdown:[[any StaticTextFile]]) throws -> [[Article]]
    {
        let articles:[[Article]] = try zip(markdown.indices, markdown).map
        {
            let namespace:Symbol.Module = self.symbolizer.graph.namespaces[$0.0]

            var scalars:(first:Int32, last:Int32)? = nil
            var articles:[Article] = []

            for file:any StaticTextFile in $0.1
            {
                if  let article:Article = try self.attach(supplement: file, in: namespace)
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

            self.symbolizer.graph.cultures[$0.0].articles = scalars.map
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
                hash: .init(hashing: "\(namespace)")))
        }

        return articles
    }

    /// Parses and stores the given supplemental documentation if it has a binding
    /// that resolves to a known symbol. If the parsed article lacks a symbol binding
    /// altogether, it is considered a standalone article.
    private mutating
    func attach(supplement:any StaticTextFile, in namespace:Symbol.Module) throws -> Article?
    {
        //  We always intern the article’s file path, for diagnostics, even if
        //  we end up discarding the article.
        let file:Int32 = self.symbolizer.intern(supplement.path)
        let source:Markdown.Source = .init(file: file, text: try supplement.read())

        switch source.parse(
            markdownParser: self.markdownParser,
            snippetsTable: self.snippets,
            diagnostics: &self.tables.diagnostics)
        {
        case .supplement(.binding(let binding), let body):
            let decl:Int32?
            do
            {
                decl = try self.resolve(decl: binding, in: namespace)
            }
            catch let diagnosis as any Diagnostic<StaticSymbolicator>
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
                        $0 = (source, body)
                    }
                    else
                    {
                        self.tables.diagnostics[binding.source] = SupplementError.multiple
                    }
                } (&self.supplements[decl])

                return nil
            }
            else
            {
                return .init(standalone: nil, file: file, body: body)
            }

        case .supplement(.heading(let heading), let body):
            let name:String = supplement.name
            let id:Symbol.Article = .init(namespace, name)

            if  let scalar:Int32 = self.symbolizer.allocate(article: id,
                    title: heading)
            {
                //  Make the standalone article visible for doclink resolution.
                self.tables.doclinks[.documentation(namespace), name] = scalar
                //  Assign the standalone article a URI.
                self.router[namespace, name][nil, default: []].append(scalar)
                return .init(standalone: scalar, file: file, body: body)
            }
            else
            {
                self.tables.diagnostics[heading.source] = DuplicateSymbolError.article(
                    name: name)
                return nil
            }

        case .tutorials(_):
            let name:String = supplement.name
            let id:Symbol.Article = .init(namespace, name)
            print("Skipping tutorial \(id)")
            return nil

        case .tutorial(let block):
            let name:String = supplement.name
            let id:Symbol.Article = .init(namespace, name)

            print("Skipping tutorial \(id)")
            return nil

        case .untitled:
            self.tables.diagnostics[source.origin] = SupplementError.untitled
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
        if  binding.text == "\(namespace)"
        {
            return nil
        }

        guard let codelink:Codelink = .init(binding.text)
        else
        {
            throw InvalidAutolinkError<StaticSymbolicator>.init(expression: binding.text)
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
                throw SupplementBindingError.init(.vector(feature, self: heir),
                    codelink: codelink)
            }

        case .some(let overloads):
            if  overloads.isEmpty
            {
                throw SupplementBindingError.init(.none(in: namespace),
                    codelink: codelink)
            }
            else
            {
                throw InvalidCodelinkError<StaticSymbolicator>.init(
                    overloads: overloads,
                    codelink: codelink)
            }
        }
    }
}

extension StaticLinker
{
    public mutating
    func link(namespaces sources:[[Compiler.Namespace]],
        at destinations:[[SymbolGraph.Namespace]])
    {
        //  First pass: expose and link unqualified features.
        for (sources, destinations):
            ([Compiler.Namespace], [SymbolGraph.Namespace]) in zip(sources, destinations)
        {
            for (source, destination):
                (Compiler.Namespace, SymbolGraph.Namespace) in zip(sources, destinations)
            {
                let qualifier:Symbol.Module =
                    self.symbolizer.graph.namespaces[destination.index]

                for (address, decl):(Int32, Compiler.Decl) in zip(
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
        for ((sources, destinations), culture):
            (([Compiler.Namespace], [SymbolGraph.Namespace]), Symbol.Module) in zip(zip(
                sources,
                destinations),
            self.symbolizer.graph.namespaces)
        {
            for (source, destination):
                (Compiler.Namespace, SymbolGraph.Namespace) in zip(sources, destinations)
            {
                self.link(decls: source.decls,
                    at: destination.range,
                    of: culture,
                    in: self.symbolizer.graph.namespaces[destination.index])
            }
        }
    }

    public mutating
    func link(decls:[Compiler.Decl],
        at addresses:ClosedRange<Int32>,
        of culture:Symbol.Module,
        in namespace:Symbol.Module)
    {
        for (address, decl):(Int32, Compiler.Decl) in zip(addresses, decls)
        {
            self.link(decl: decl, at: address, of: culture, in: namespace)
        }
    }

    private mutating
    func link(decl:Compiler.Decl,
        at address:Int32,
        of culture:Symbol.Module,
        in namespace:Symbol.Module)
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

        let linked:(article:SymbolGraph.Article, topics:[SymbolGraph.Topic])?
        let rename:Int32?

        if  markdown != nil || renamed != nil
        {
            let scopes:StaticResolver.Scopes = self.symbolizer.scopes(
                namespace: namespace,
                culture: culture,
                scope: decl.phylum.scope(trimming: decl.path))

            (linked, rename) = self.tables.resolving(with: scopes)
            {
                (outliner:inout StaticOutliner) in
                (
                    markdown.map { outliner.link(attached: $0.parsed, file: $0.file) },
                    renamed.map
                    {
                        outliner.follow(rename: $0, of: decl.path, at: location)
                    } ?? nil
                )
            }
        }
        else
        {
            linked = nil
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
            $0?.article = linked?.article
            $0?.topics = linked?.topics ?? []

        } (&self.symbolizer.graph.decls.nodes[address].decl)
    }
}
extension StaticLinker
{
    public mutating
    func link(extensions:[Compiler.Extension],
        at addresses:[(Int32, Int)])
    {
        for ((scalar, index), `extension`):((Int32, Int), Compiler.Extension) in zip(
            addresses,
            extensions)
        {
            //  Extensions can have many constituent extension blocks, each potentially
            //  with its own doccomment. It’s not clear to me how to combine them,
            //  so for now, we just keep the longest doccomment and discard all the others,
            //  like DocC does. (Except DocC does this across all extensions with the
            //  same extended type.)
            //  https://github.com/apple/swift-docc/pull/369
            var longest:Int = 0

            var comment:Compiler.Doccomment? = nil
            var file:Symbol.File? = nil

            for block:Compiler.Extension.Block in `extension`.blocks
            {
                if  let current:Compiler.Doccomment = block.comment
                {
                    //  This is really, really stupid, but we need a way to break
                    //  ties, and we can’t use source location for this, as it is
                    //  not always available.
                    let length:Int = current.text.count
                    if (longest, comment?.text ?? "") < (length, current.text)
                    {
                        longest = length
                        comment = current
                        file = block.location?.file
                    }
                }
            }
            if  let comment:Compiler.Doccomment
            {
                //  Only intern the file path for the extension block with the longest comment
                let comment:Markdown.Source = .init(comment: comment,
                    in: file.map { self.symbolizer.intern($0) })

                let parsed:Markdown.SemanticDocument = comment.parse(
                    markdownParser: self.doccommentParser,
                    snippetsTable: self.snippets,
                    diagnostics: &self.tables.diagnostics)

                //  Need to load these before mutating the symbol graph to avoid
                //  overlapping access
                let importAll:[Symbol.Module] = self.symbolizer.importAll
                ;
                {
                    let scopes:StaticResolver.Scopes = .init(
                        codelink: .init(
                            namespace: self.symbolizer.graph.namespaces[$0.namespace],
                            imports: importAll,
                            path: [String].init(`extension`.path)),
                        doclink: .documentation(self.symbolizer.graph.namespaces[$0.culture]))

                    $0.article = self.tables.resolving(with: scopes)
                    {
                        $0.link(article: parsed, file: comment.origin?.file)
                    }

                } (&self.symbolizer.graph.decls.nodes[scalar].extensions[index])
            }
        }
    }
}
extension StaticLinker
{
    public mutating
    func link(articles:[[Article]])
    {
        for (culture, articles):(Int, [Article]) in zip(articles.indices, articles)
        {
            let namespace:Symbol.Module = self.symbolizer.graph.namespaces[culture]
            for article:Article in articles
            {
                self.tables.resolving(with: self.symbolizer.scopes(culture: namespace))
                {
                    if  let standalone:Int32 = article.standalone
                    {
                        (
                            self.symbolizer.graph.articles.nodes[standalone].article,
                            self.symbolizer.graph.articles.nodes[standalone].topics
                        ) = $0.link(attached: article.body, file: article.file)
                    }
                    else
                    {
                        //  This is the article for the module’s landing page.
                        (
                            self.symbolizer.graph.cultures[culture].article,
                            self.symbolizer.graph.cultures[culture].topics
                        ) = $0.link(attached: article.body, file: article.file)
                    }
                }
            }
        }
    }
}
extension StaticLinker
{
    public mutating
    func load() throws -> SymbolGraph
    {
        for case (let path, .some(let members)) in self.router.paths
        {
            for (hash, addresses):(FNV24?, InlineArray<Int32>) in members
            {
                if  let hash:FNV24
                {
                    for stacked:Int32 in addresses
                    {
                        //  If `hash` is present, then we know the decl is a valid
                        //  declaration node index.
                        self.symbolizer.graph.decls.nodes[stacked].decl?.route = .hashed
                    }
                    guard
                    case .some(let collisions) = addresses
                    else
                    {
                        continue
                    }

                    self.tables.diagnostics[nil] = RouteCollisionError.hash(hash, collisions)
                }
                else
                {
                    let collisions:[Int32] =
                    switch addresses
                    {
                    case .one(let scalar):  [scalar]
                    case .some(let scalars): scalars
                    }

                    self.tables.diagnostics[nil] = RouteCollisionError.path(path, collisions)
                }
            }
        }

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
