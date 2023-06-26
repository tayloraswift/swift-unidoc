import CodelinkResolution
import Codelinks
import DoclinkResolution
import Declarations
import FNV1
import Generics
import LexicalPaths
import MarkdownSemantics
import MarkdownParsing
import MarkdownTrees
import ModuleGraphs
import Sources
import Symbols
import SymbolGraphs
import UnidocCompiler
import UnidocDiagnostics

public
struct StaticLinker
{
    private
    let nominations:Compiler.Nominations

    private
    var symbolizer:Symbolizer
    private
    var codelinks:CodelinkResolver<Int32>.Table
    private
    var doclinks:DoclinkResolver.Table
    private
    var router:StaticRouter

    private
    var supplements:[Int32: [MarkdownDocumentationSupplement]]

    public private(set)
    var diagnoses:[any StaticDiagnosis]

    public
    init(nominations:Compiler.Nominations, modules:[ModuleDetails])
    {
        self.nominations = nominations


        self.symbolizer = .init(modules: modules)
        self.codelinks = .init()
        self.doclinks = .init()
        self.router = .init()

        self.supplements = [:]
        self.diagnoses = []
    }
}
extension StaticLinker
{
    private mutating
    func address(of scalar:ScalarSymbol?) -> Int32?
    {
        scalar.map { self.symbolizer.intern($0) }
    }
    /// Returns an array of addresses for an array of scalar symbols.
    /// The address assignments reflect the order of the symbols in the
    /// array, so you should sort them if you want deterministic
    /// addressing.
    ///
    /// This function doesn’t expose the scalars for codelink resolution,
    /// because it is expected that the same symbols may appear in
    /// the array arguments of multiple calls to this function, and it
    /// it more efficient to expose scalars while performing a different
    /// pass.
    private mutating
    func addresses(of scalars:[ScalarSymbol]) -> [Int32]
    {
        scalars.map { self.symbolizer.intern($0) }
    }
    /// Returns an array of addresses for an array of vector features,
    /// exposing each vector for codelink resolution in the process.
    ///
    /// -   Parameters:
    ///     -   features:
    ///         An array of scalar symbols, assumed to be the feature
    ///         components of a collection of vector symbols with the
    ///         same heir.
    ///     -   prefix:
    ///         The lexical path of the shared heir.
    ///     -   extended:
    ///         The shared heir.
    ///     -   address:
    ///         The address of the shared heir.
    ///
    /// Unlike ``addresses(of:)``, this function adds overloads to the
    /// codelink resolver, because it’s more efficient to combine these
    /// two passes.
    private mutating
    func addresses(exposing features:[ScalarSymbol],
        prefixed prefix:(ModuleIdentifier, UnqualifiedPath),
        of extended:ScalarSymbol,
        at address:Int32) -> [Int32]
    {
        features.map
        {
            let feature:Int32 = self.symbolizer.intern($0)
            if  let (last, phylum):(String, ScalarPhylum) =
                self.symbolizer.graph[feature]?.scalar.map({ ($0.path.last, $0.phylum) }) ??
                self.nominations[feature: $0]
            {
                let vector:VectorSymbol = .init($0, self: extended)
                self.codelinks[prefix.0, prefix.1, last].overload(with: .init(
                    target: .vector(feature, self: address),
                    phylum: phylum,
                    hash: .init(hashing: "\(vector)")))
            }
            return feature
        }
    }
}
extension StaticLinker
{
    private mutating
    func allocate(scalars:[Compiler.Scalar]) -> ClosedRange<Int32>
    {
        var addresses:(first:Int32, last:Int32)? = nil
        for scalar:Compiler.Scalar in scalars
        {
            let address:Int32 = self.symbolizer.allocate(scalar: scalar)
            switch addresses
            {
            case  nil:              addresses = (address, address)
            case (let first, _)?:   addresses = (first,   address)
            }
        }
        if  case (let first, let last)? = addresses
        {
            return first ... last
        }
        else
        {
            fatalError("cannot allocate empty scalar array")
        }
    }
    /// Allocates and binds addresses for the scalars stored in the given array
    /// of compiled namespaces. (Binding consists of populating the aperture and
    /// phylum of a scalar.) This function also exposes each of the scalars for
    /// codelink resolution.
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
                .init(range: self.allocate(scalars: $0.scalars),
                    index: self.symbolizer.intern($0.id))
            }
        }
        for ((culture, sources), destinations):
            ((Int, [Compiler.Namespace]), [SymbolGraph.Namespace]) in zip(zip(
                namespaces.indices,
                namespaces),
            destinations)
        {
            //  Record address ranges
            self.symbolizer.graph.cultures[culture].namespaces = destinations

            for (source, destination):(Compiler.Namespace, SymbolGraph.Namespace) in
                zip(sources, destinations)
            {
                let qualifier:ModuleIdentifier =
                    self.symbolizer.graph.namespaces[destination.index]
                for (address, scalar) in zip(destination.range, source.scalars)
                {
                    let hash:FNV24 = .init(hashing: "\(scalar.id)")
                    //  Make the scalar visible to codelink resolution.
                    self.codelinks[qualifier, scalar.path].overload(with: .init(
                        target: .scalar(address),
                        phylum: scalar.phylum,
                        hash: hash))
                    //  Assign the scalar a URI, and record the scalar’s hash
                    //  so we will know if it has a hash collision.
                    self.router[qualifier, scalar.path, scalar.phylum][hash, default: []]
                        .append(address)
                }
            }
        }
        return destinations
    }
    /// Allocates addresses for the given array of compiled extensions.
    /// This function also exposes any features conceived by the extensions for
    /// codelink resolution.
    ///
    /// -   Returns:
    ///     An (address, index) tuple for each compiled extension. If the
    ///     extension extends a symbol that has not yet been registered,
    ///     the address is newly allocated.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method second, after calling ``allocate(scalars:)``.
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

            let index:Int = self.symbolizer.graph.nodes[$0.0].push(.init(
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
    var imports:[ModuleIdentifier]
    {
        .init(self.symbolizer.graph.namespaces[self.symbolizer.graph.cultures.indices])
    }
}
extension StaticLinker
{
    public mutating
    func attach(supplements:[[MarkdownFile]]) throws
    {
        let standalone:[[Article]] = try zip(supplements.indices, supplements).map
        {
            let namespace:ModuleIdentifier = self.symbolizer.graph.namespaces[$0.0]

            var addresses:(first:Int32, last:Int32)? = nil
            var articles:[Article] = []

            for file:MarkdownFile in $0.1
            {
                if  let article:Article = try self.attach(supplement: file, in: namespace)
                {
                    articles.append(article)

                    guard let address:Int32 = article.address
                    else
                    {
                        continue
                    }

                    switch addresses
                    {
                    case  nil:              addresses = (address, address)
                    case (let first, _)?:   addresses = (first,   address)
                    }
                }
            }

            self.symbolizer.graph.cultures[$0.0].articles = addresses.map
            {
                $0.first ... $0.last
            }

            return articles
        }
        //  Now that standalone articles have all been exposed for doclink resolution,
        //  we can link them.
        for (culture, standalone):(Int, [Article]) in zip(
            standalone.indices,
            standalone)
        {
            let namespace:ModuleIdentifier = self.symbolizer.graph.namespaces[culture]
            for standalone:Article in standalone
            {
                var outliner:StaticOutliner = .init(
                    codelinks: self.codelinks,
                    doclinks: self.doclinks,
                    imports: self.imports,
                    culture: namespace)
                //  We pass a single-element array as the sources list, which relies
                //  on the fact that ``MarkdownDocumentationSupplement`` uses `0` as
                //  the source id by default.
                let article:SymbolGraph.Article<Never> = outliner.link(
                    documentation: standalone.parsed.article,
                    from: [standalone.source])

                if  let address:Int32 = standalone.address
                {
                    self.symbolizer.graph.articles[address].value = article
                }
                else
                {
                    self.symbolizer.graph.cultures[culture].article = article
                }

                self.diagnoses += outliner.diagnoses
            }
        }
    }
    /// Parses and stores the given supplemental documentation if it has a binding
    /// that resolves to a known symbol. If the parsed article lacks a symbol binding
    /// altogether, it is considered a standalone article.
    private mutating
    func attach(supplement:MarkdownFile,
        in namespace:ModuleIdentifier) throws -> Article?
    {
        let markdown:MarkdownDocumentationSupplement = .init(parsing: supplement.text,
            as: SwiftFlavoredMarkdown.self)
        //  We always intern the article’s file path, for diagnostics, even if
        //  we end up discarding the article.
        let source:MarkdownSource = .init(
            location: .init(position: .zero, file: self.symbolizer.intern(supplement.id)),
            text: supplement.text)
        do
        {
            switch try self.binding(of: markdown, in: namespace, source: source)
            {
            case nil:
                let address:Int32 = try
                {
                    switch $0
                    {
                    case nil:
                        let address:Int32 = self.symbolizer.graph.articles.append(.init(
                            id: supplement.name))
                        $0 = address
                        return address

                    case  _?:
                        throw DuplicateSymbolError.article(supplement.name)
                    }
                //  Make the standalone article visible for doclink resolution.
                } (&self.doclinks[.documentation(namespace), supplement.name])

                //  Assign the standalone article a URI.
                self.router[namespace, supplement.name][nil, default: []].append(address)

                return .init(address: address, parsed: markdown, source: source)

            case .module?:
                return .init(address: nil, parsed: markdown, source: source)

            case .scalar(let binding)?:
                self.supplements[binding, default: []].append(markdown)
                return nil
            }
        }
        catch let diagnosis as any StaticDiagnosis
        {
            self.diagnoses.append(diagnosis)
            return nil
        }
        catch
        {
            return nil
        }
    }

    private
    func binding(
        of supplement:MarkdownDocumentationSupplement,
        in namespace:ModuleIdentifier,
        source:MarkdownSource) throws -> ArticleBinding?
    {
        guard let autolink:MarkdownInline.Autolink = supplement.binding
        else
        {
            return nil
        }

        //  Special rule for article bindings: if the text of the codelink matches
        //  the current namespace, then the article is the primary article for
        //  that module.
        if  autolink.text == "\(namespace)"
        {
            return .module
        }
        var context:Diagnostic.Context<Int32>?
        {
            autolink.source.map { .init(of: $0.range, in: source) }
        }

        guard let codelink:Codelink = .init(autolink.text)
        else
        {
            throw InvalidAutolinkError<Int32>.init(expression: autolink.text, context: context)
        }

        let resolver:CodelinkResolver<Int32> = .init(table: self.codelinks, scope: .init(
            namespace: namespace))

        switch resolver.resolve(codelink)
        {
        case .one(let overload):
            switch overload.target
            {
            case .scalar(let address):
                return .scalar(address)

            case .vector(let feature, self: let heir):
                throw InvalidArticleBindingError.init(.vector(feature, self: heir),
                    codelink: codelink,
                    context: context)
            }

        case .some(let overloads):
            if  overloads.isEmpty
            {
                throw InvalidArticleBindingError.init(.none(in: namespace),
                    codelink: codelink,
                    context: context)
            }
            else
            {
                throw InvalidCodelinkError<Int32>.init(overloads: overloads,
                    codelink: codelink,
                    context: context)
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
        for ((sources, destinations), culture):
            (([Compiler.Namespace], [SymbolGraph.Namespace]), ModuleIdentifier) in zip(zip(
                sources,
                destinations),
            self.symbolizer.graph.namespaces)
        {
            for (source, destination) in zip(sources, destinations)
            {
                self.link(scalars: source.scalars,
                    at: destination.range,
                    of: culture,
                    in: self.symbolizer.graph.namespaces[destination.index])
            }
        }
    }
    public mutating
    func link(scalars:[Compiler.Scalar],
        at addresses:ClosedRange<Int32>,
        of culture:ModuleIdentifier,
        in namespace:ModuleIdentifier)
    {
        for (address, scalar):(Int32, Compiler.Scalar) in zip(addresses, scalars)
        {
            let declaration:Declaration<Int32> = scalar.declaration.map
            {
                self.symbolizer.intern($0)
            }

            //  Sort for deterministic addresses.
            let superforms:[Int32] = self.addresses(of: scalar.superforms.sorted())
            let features:[Int32] = self.addresses(of: scalar.features.sorted())
            let origin:Int32? = self.address(of: scalar.origin)

            let location:SourceLocation<Int32>? = scalar.location?.map
            {
                self.symbolizer.intern($0)
            }
            let article:SymbolGraph.Article<Never>? = scalar.documentation.map
            {
                var outliner:StaticOutliner = .init(
                    codelinks: self.codelinks,
                    doclinks: self.doclinks,
                    imports: self.imports,
                    namespace: namespace,
                    culture: culture,
                    scope: $0.scope)

                defer
                {
                    self.diagnoses += outliner.diagnoses
                }

                return outliner.link(comment: .init(from: $0.comment, in: location?.file),
                    adding: self.supplements.removeValue(forKey: address))
            }

            {
                $0?.declaration = declaration

                $0?.superforms = superforms
                $0?.features = features
                $0?.origin = origin

                $0?.location = location
                $0?.article = article
            } (&self.symbolizer.graph.nodes[address].scalar)
        }
    }

    public mutating
    func link(extensions:[Compiler.Extension],
        at addresses:[(Int32, Int)])
    {
        for ((address, index), `extension`):((Int32, Int), Compiler.Extension) in zip(
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

            var comment:Compiler.Documentation.Comment? = nil
            var file:FileSymbol? = nil

            for block:Compiler.Extension.Block in `extension`.blocks
            {
                if  let current:Compiler.Documentation.Comment = block.comment
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
            if  let comment
            {
                //  Need to load this before mutating the symbol graph to avoid
                //  overlapping access
                let imports:[ModuleIdentifier] = self.imports
                //  Only intern the file path for the extension block with the longest comment
                let file:Int32? = file.map { self.symbolizer.intern($0) }

                {
                    var outliner:StaticOutliner = .init(
                        codelinks: self.codelinks,
                        doclinks: self.doclinks,
                        imports: imports,
                        namespace: self.symbolizer.graph.namespaces[$0.namespace],
                        culture: self.symbolizer.graph.namespaces[$0.culture],
                        scope: [String].init(`extension`.path))

                    $0.article = outliner.link(comment: .init(from: comment, in: file))

                    self.diagnoses += outliner.diagnoses

                } (&self.symbolizer.graph.nodes[address].extensions[index])
            }
        }
    }
}
extension StaticLinker
{
    public mutating
    func finalize() throws -> SymbolGraph
    {
        for case .some(let path) in self.router.paths.values
        {
            for (hash, addresses):(FNV24?, InlineArray<Int32>) in path
            {
                if  let hash
                {
                    for stacked:Int32 in addresses
                    {
                        //  If `hash` is present, then we know the scalar is a valid
                        //  declaration node index.
                        self.symbolizer.graph.nodes[stacked].scalar?.route = .hashed
                    }
                    if  case .some(let collisions) = addresses
                    {
                        print("""
                            WARNING: FNV-1 hash collision detected! (hash: \(hash), \
                            symbols: \(collisions.map { self.symbolizer.graph.symbols[$0] }))
                            """)
                    }
                }
                else
                {
                    for stacked:Int32 in addresses
                    {
                        print("""
                            WARNING: Standalone article \
                            (\(self.symbolizer.graph.articles[stacked].id ?? "<anonymous>")) \
                            does not have a unique URL! (\(path))
                            """)
                    }
                }
            }
        }
        return self.symbolizer.graph
    }
}
