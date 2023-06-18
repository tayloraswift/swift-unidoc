import Codelinks
import CodelinkResolution
import Declarations
import Generics
import MarkdownSemantics
import MarkdownParsing
import ModuleGraphs
import Sources
import Symbols
import SymbolGraphs
import UnidocCompiler

public
struct StaticLinker
{
    private
    let nominations:Compiler.Nominations

    private
    var diagnostics:[Diagnostic]

    private
    var symbolizer:Symbolizer
    private
    var articles:StandaloneResolver
    private
    var resolver:StaticResolver

    private
    var supplements:[Int32: [MarkdownDocumentationSupplement]]

    public
    init(nominations:Compiler.Nominations,
        modules:[ModuleDetails])
    {
        self.nominations = nominations

        self.diagnostics = []

        self.symbolizer = .init(modules: modules)
        self.resolver = .init()
        self.articles = .init()

        self.supplements = [:]
    }
}
extension StaticLinker
{
    public
    func _warnings()
    {
        for diagnostic:Diagnostic in self.diagnostics
        {
            print(diagnostic)
        }
    }
}
extension StaticLinker
{
    public
    var graph:SymbolGraph { self.symbolizer.graph }
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
        prefixed prefix:(ModuleIdentifier, [String]),
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
                self.resolver.overload(prefix.0 / .init(prefix.1, last), with: .init(
                    target: .vector(feature, self: address),
                    phylum: phylum,
                    id: vector))
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
                    //  Make the scalar visible to codelink resolution.
                    self.resolver.overload(qualifier / scalar.path, with: .init(
                        target: .scalar(address),
                        phylum: scalar.phylum,
                        id: scalar.id))
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
    public mutating
    func attach(supplements:[[MarkdownFile]]) throws
    {
        let standalone:[[StandaloneArticle]] = try zip(supplements.indices, supplements).map
        {
            let namespace:ModuleIdentifier =  self.symbolizer.graph.namespaces[$0.0]

            var addresses:(first:Int32, last:Int32)? = nil
            var articles:[StandaloneArticle] = []

            for file:MarkdownFile in $0.1
            {
                if  let article:StandaloneArticle =  try self.attach(supplement: file,
                        in: namespace)
                {
                    articles.append(article)

                    switch addresses
                    {
                    case  nil:              addresses = (article.address, article.address)
                    case (let first, _)?:   addresses = (first,           article.address)
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
        for (culture, standalone):(Int, [StandaloneArticle]) in zip(
            standalone.indices,
            standalone)
        {
            let culture:ModuleIdentifier = self.symbolizer.graph.namespaces[culture]
            for standalone:StandaloneArticle in standalone
            {
                var outliner:Outliner = .init(
                    articles: self.articles,
                    resolver: self.resolver,
                    culture: culture,
                    scope: ["\(culture)"])

                //  We pass a single-element array as the sources list, which relies
                //  on the fact that ``MarkdownDocumentationSupplement`` uses `0` as
                //  the source id by default.
                self.symbolizer.graph.articles[standalone.address].value = outliner.link(
                    documentation: standalone.markdown.article,
                    from: [.init(from: standalone)])

                self.diagnostics += outliner.diagnostics
            }
        }
    }
    /// Parses and stores the given supplemental documentation if it has a binding
    /// that resolves to a known symbol. If the parsed article lacks a symbol binding
    /// altogether, it is considered a standalone article.
    private mutating
    func attach(supplement:MarkdownFile,
        in namespace:ModuleIdentifier) throws -> StandaloneArticle?
    {
        let markdown:MarkdownDocumentationSupplement = .init(parsing: supplement.text,
            as: SwiftFlavoredMarkdown.self)
        if  case nil = markdown.binding
        {
            let address:Int32 = try
            {
                switch $0
                {
                case nil:
                    let address:Int32 = self.symbolizer.graph.append(
                        article: supplement.name)
                    $0 = address
                    return address

                case  _?:
                    throw DuplicateSymbolError.article(supplement.name)
                }
            } (&self.articles[.documentation(namespace), supplement.name])

            return .init(markdown: markdown,
                address: address,
                file: self.symbolizer.intern(supplement.id),
                text: supplement.text)
        }
        if  let binding:Int32 = self.binding(of: markdown, in: namespace)
        {
            self.supplements[binding, default: []].append(markdown)
            return nil
        }
        else
        {
            return nil
        }
    }
    private
    func binding(
        of supplement:MarkdownDocumentationSupplement,
        in namespace:ModuleIdentifier) -> Int32?
    {
        guard let codelink:Codelink = supplement.binding
        else
        {
            return nil
        }

        switch self.resolver.query(ascending: ["\(namespace)"], link: codelink)
        {
        case nil:
            print("""
                Article binding '\(codelink)' does not refer to a declaration \
                in its enclosing scope (\(namespace)).
                """)
            return nil

        case .one(let overload)?:
            switch overload.target
            {
            case .scalar(let address):
                return address

            case .vector:
                print("Article binding '\(codelink)' cannot refer to a vector symbol.")
                return nil
            }

        case .many?:
            print("Article binding '\(codelink)' is ambiguous.")
            return nil
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
                var outliner:Outliner = .init(
                    articles: self.articles,
                    resolver: self.resolver,
                    culture: culture,
                    scope: ["\(namespace)"] + $0.scope)

                defer
                {
                    self.diagnostics += outliner.diagnostics
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
                //  Only intern the file path for the extension block with the longest comment
                let file:Int32? = file.map { self.symbolizer.intern($0) }

                {
                    let qualifier:ModuleIdentifier =
                        self.symbolizer.graph.namespaces[$0.namespace]

                    var outliner:Outliner = .init(
                        articles: self.articles,
                        resolver: self.resolver,
                        culture: self.symbolizer.graph.namespaces[$0.culture],
                        scope: ["\(qualifier)"] + `extension`.path)

                    $0.article = outliner.link(comment: .init(from: comment, in: file))

                    self.diagnostics += outliner.diagnostics

                } (&self.symbolizer.graph.nodes[address].extensions[index])
            }
        }
    }
}
