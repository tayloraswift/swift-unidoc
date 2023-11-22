import CodelinkResolution
import Codelinks
import DoclinkResolution
import FNV1
import LexicalPaths
import MarkdownABI
import MarkdownSemantics
import MarkdownParsing
import MarkdownAST
import ModuleGraphs
import Signatures
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import UnidocDiagnostics
import Unidoc

public
struct StaticLinker:~Copyable
{
    private
    let doccommentParser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdownComment>
    private
    let markdownParser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdown>
    private
    let nominations:Compiler.Nominations

    private
    var symbolizer:Symbolizer
    private
    var router:Router
    private
    var tables:Tables

    private
    var supplements:[Int32: Supplement]

    public
    init(nominations:Compiler.Nominations,
        modules:[ModuleDetails],
        plugins:[any MarkdownCodeLanguageType] = [])
    {
        //  If we were given a plugin that says it can highlight swift,
        //  make it the default plugin for the doccomment parser.
        self.doccommentParser = .init(plugins: plugins,
            default: plugins.first { $0.name == "swift" })
        self.markdownParser = .init(plugins: plugins)
        self.nominations = nominations

        self.symbolizer = .init(modules: modules)
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
        prefixed prefix:(ModuleIdentifier, UnqualifiedPath),
        of extended:Symbol.Decl,
        at scalar:Int32) -> [Int32]
    {
        features.map
        {
            let feature:Int32 = self.symbolizer.intern($0)
            if  let (last, phylum):(String, Unidoc.Decl) =
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
                let qualifier:ModuleIdentifier =
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
            let qualifier:ModuleIdentifier = self.symbolizer.graph.namespaces[namespace]

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
    func attach(supplements:[[MarkdownSourceFile]])
    {
        let articles:[[Article]] = zip(supplements.indices, supplements).map
        {
            let namespace:ModuleIdentifier = self.symbolizer.graph.namespaces[$0.0]

            var scalars:(first:Int32, last:Int32)? = nil
            var articles:[Article] = []

            for file:MarkdownSourceFile in $0.1
            {
                if  let article:Article = self.attach(supplement: file, in: namespace)
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
        for (n, namespace):(Int, ModuleIdentifier) in zip(
            self.symbolizer.graph.namespaces.indices,
            self.symbolizer.graph.namespaces)
        {
            self.tables.codelinks[namespace].overload(with: .init(
                target: .scalar(n * .module),
                phylum: nil,
                hash: .init(hashing: "\(namespace)")))
        }

        for (culture, articles):(Int, [Article]) in zip(articles.indices, articles)
        {
            let namespace:ModuleIdentifier = self.symbolizer.graph.namespaces[culture]
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
    /// Parses and stores the given supplemental documentation if it has a binding
    /// that resolves to a known symbol. If the parsed article lacks a symbol binding
    /// altogether, it is considered a standalone article.
    private mutating
    func attach(supplement article:MarkdownSourceFile,
        in namespace:ModuleIdentifier) -> Article?
    {
        //  We always intern the article’s file path, for diagnostics, even if
        //  we end up discarding the article.
        let file:Int32 = self.symbolizer.intern(article.path)
        let source:MarkdownSource = .init(
            location: .init(position: .zero, file: file),
            text: article.text)

        let supplement:Supplement = source.parse(using: self.markdownParser,
            with: &self.tables.diagnostics)

        guard let headline:Supplement.Headline = supplement.headline
        else
        {
            self.tables.diagnostics[source] = SupplementError.untitled
            return nil
        }

        switch headline
        {
        case .binding(let binding):
            let decl:Int32?
            do
            {
                decl = try self.resolve(decl: binding, in: namespace)
            }
            catch let diagnosis as any Diagnostic<StaticSymbolicator>
            {
                self.tables.diagnostics[binding] = diagnosis
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
                        $0 = supplement
                    }
                    else
                    {
                        self.tables.diagnostics[binding] = SupplementError.multiple
                    }
                } (&self.supplements[decl])

                return nil
            }
            else
            {
                return .init(standalone: nil, file: file, body: supplement.parsed)
            }

        case .heading(let heading):
            let id:String = .init(article.id)
            if  let scalar:Int32 = self.symbolizer.allocate(article: article.symbol,
                    title: heading)
            {
                //  Make the standalone article visible for doclink resolution.
                self.tables.doclinks[.documentation(namespace), id] = scalar
                //  Assign the standalone article a URI.
                self.router[namespace, id][nil, default: []].append(scalar)
                return .init(standalone: scalar, file: file, body: supplement.parsed)
            }
            else
            {
                self.tables.diagnostics[source] = DuplicateSymbolError.article(id: id)
                return nil
            }
        }
    }

    private
    func resolve(decl binding:MarkdownInline.Autolink,
        in namespace:ModuleIdentifier) throws -> Int32?
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
                let qualifier:ModuleIdentifier =
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
            (([Compiler.Namespace], [SymbolGraph.Namespace]), ModuleIdentifier) in zip(zip(
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
        of culture:ModuleIdentifier,
        in namespace:ModuleIdentifier)
    {
        for (address, decl):(Int32, Compiler.Decl) in zip(addresses, decls)
        {
            self.link(decl: decl, at: address, of: culture, in: namespace)
        }
    }

    private mutating
    func link(decl:Compiler.Decl,
        at address:Int32,
        of culture:ModuleIdentifier,
        in namespace:ModuleIdentifier)
    {
        let signature:Signature<Int32> = decl.signature.map { self.symbolizer.intern($0) }

        //  Sort for deterministic addresses.
        let requirements:[Int32] = self.addresses(of: decl.requirements.sorted())
        let superforms:[Int32] = self.addresses(of: decl.superforms.sorted())
        let origin:Int32? = self.address(of: decl.origin)

        let location:SourceLocation<Int32>? = decl.location?.map
        {
            self.symbolizer.intern($0)
        }

        let supplement:Supplement? = self.supplements.removeValue(forKey: address)
        let comment:MarkdownSource? = decl.comment.map
        {
            .init(comment: $0, in: location?.file)
        }

        let markdown:(parsed:MarkdownDocumentation, file:Int32?)?

        switch (comment, supplement)
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
                    using: self.doccommentParser,
                    with: &self.tables.diagnostics),
                file: nil
            )

        case (let comment?, let supplement?):
            if  case .override? = supplement.parsed.metadata.merge
            {
                fallthrough
            }

            diagnostic:
            if  case nil = supplement.parsed.metadata.merge
            {
                guard
                case nil = supplement.parsed.overview, supplement.parsed.details.isEmpty
                else
                {
                    self.tables.diagnostics[supplement.source] =
                        SupplementError.implicitConcatenation
                    break diagnostic
                }
            }

            let body:MarkdownDocumentation = comment.parse(
                using: self.doccommentParser,
                with: &self.tables.diagnostics)

            markdown =
            (
                parsed: body.merged(appending: supplement.parsed),
                file: supplement.source.location?.file
            )

        case (nil, let supplement?):
            markdown =
            (
                parsed: supplement.parsed,
                file: supplement.source.location?.file
            )
        }

        let linked:(article:SymbolGraph.Article, topics:[SymbolGraph.Topic])? = markdown.map
        {
            let (parsed, file):(MarkdownDocumentation, Int32?) = $0
            let scopes:StaticResolver.Scopes = self.symbolizer.scopes(
                namespace: namespace,
                culture: culture,
                scope: decl.phylum.scope(trimming: decl.path))

            return self.tables.resolving(with: scopes)
            {
                $0.link(attached: parsed, file: file)
            }
        }

        {
            $0?.requirements = requirements
            $0?.superforms = superforms
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
                let comment:MarkdownSource = .init(comment: comment,
                    in: file.map { self.symbolizer.intern($0) })

                let parsed:MarkdownDocumentation = comment.parse(
                    using: self.doccommentParser,
                    with: &self.tables.diagnostics)

                //  Need to load these before mutating the symbol graph to avoid
                //  overlapping access
                let importAll:[ModuleIdentifier] = self.symbolizer.importAll ;

                {
                    let scopes:StaticResolver.Scopes = .init(
                        codelink: .init(
                            namespace: self.symbolizer.graph.namespaces[$0.namespace],
                            imports: importAll,
                            path: [String].init(`extension`.path)),
                        doclink: .documentation(self.symbolizer.graph.namespaces[$0.culture]))

                    $0.article = self.tables.resolving(with: scopes)
                    {
                        $0.link(article: parsed, file: comment.location?.file)
                    }

                } (&self.symbolizer.graph.decls.nodes[scalar].extensions[index])
            }
        }
    }
}
extension StaticLinker
{
    public consuming
    func finalize() throws ->
    (
        diagnostics:DiagnosticContext<StaticSymbolicator>,
        graph:SymbolGraph
    )
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
        return (self.tables.diagnostics, self.symbolizer.graph)
    }
}
